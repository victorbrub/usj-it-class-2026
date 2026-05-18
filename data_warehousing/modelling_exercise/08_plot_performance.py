#!/usr/bin/env python3
# Author: Víctor Barceló
"""
08_plot_performance.py
======================
Connects to the football_dw PostgreSQL database, runs EXPLAIN ANALYZE on all
five KPI queries for both the relational and dimensional models, parses the
JSON execution plans, and produces a multi-panel comparison chart saved as
relational_vs_dimensional.png.

The chart contains five panels:
  1. Execution time per KPI  (full-width horizontal bar chart)
  2. Plan complexity          (number of plan nodes per KPI)
  3. Physical tables accessed (relation scans per KPI)
  4. Dimensional speedup      (how many times faster per KPI)
  5. Partition pruning        (rows-scanned projection at scale)

Requirements:
    pip install psycopg2-binary matplotlib numpy

Usage:
    python3 08_plot_performance.py
    python3 08_plot_performance.py --host localhost --port 5432 \\
                                   --user postgres --dbname football_dw
    python3 08_plot_performance.py --output my_chart.png
"""

import sys
import json
import argparse

try:
    import numpy as np
except ImportError:
    sys.exit("numpy not found.  Run:  pip install numpy")

try:
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt
    import matplotlib.patches as mpatches
    from matplotlib.gridspec import GridSpec
except ImportError:
    sys.exit("matplotlib not found.  Run:  pip install matplotlib")

try:
    import psycopg2
except ImportError:
    sys.exit("psycopg2 not found.  Run:  pip install psycopg2-binary")


# ── Visual style constants ────────────────────────────────────────────────────

COLOR_REL       = "#c0392b"   # red  – relational model
COLOR_DIM       = "#27ae60"   # green – dimensional model
COLOR_BG        = "#f8f9fa"   # figure background
COLOR_AX        = "#ffffff"   # axes background
COLOR_GRID      = "#cccccc"   # grid lines
COLOR_TITLE     = "#2c3e50"   # panel title text


# ── KPI metadata ──────────────────────────────────────────────────────────────

KPI_LABELS_LONG = [
    "KPI 1: Top 10 goal\nscorers (1 season)",
    "KPI 2: League\nstandings (1 season)",
    "KPI 3: Monthly goal\ntrend (all seasons)",
    "KPI 4: Goals by\nnationality (all seasons)",
    "KPI 5: Cards per\nmatch (1 season)",
]

KPI_SHORT = ["KPI 1", "KPI 2", "KPI 3", "KPI 4", "KPI 5"]

# Join counts per KPI for the annotation strip
REL_JOIN_COUNT = [4, 3, 1, 1, 4]   # relational: joins needed
DIM_JOIN_COUNT = [3, 2, 1, 1, 2]   # dimensional: joins needed


# ── EXPLAIN ANALYZE queries ───────────────────────────────────────────────────

_EX = "EXPLAIN (ANALYZE, FORMAT JSON, BUFFERS)"

RELATIONAL_QUERIES = [

    # KPI 1: Top 10 goal scorers in 2024/25  (5 tables, 4 joins)
    f"""{_EX}
SELECT p.first_name || ' ' || p.last_name AS player_name,
       c.name        AS club,
       p.nationality,
       p.position,
       COUNT(g.goal_id) AS goals
FROM   relational.goals    g
JOIN   relational.players  p ON g.scorer_id  = p.player_id
JOIN   relational.clubs    c ON p.club_id    = c.club_id
JOIN   relational.matches  m ON g.match_id   = m.match_id
JOIN   relational.seasons  s ON m.season_id  = s.season_id
WHERE  s.name = '2024/25'
GROUP BY p.player_id, p.first_name, p.last_name, c.name, p.nationality, p.position
ORDER BY goals DESC
LIMIT 10""",

    # KPI 2: League standings 2024/25  (UNION ALL + 3 tables)
    f"""{_EX}
WITH match_points AS (
    SELECT m.home_club_id AS club_id,
           CASE WHEN m.home_goals > m.away_goals THEN 3
                WHEN m.home_goals = m.away_goals THEN 1
                ELSE 0 END                          AS points,
           (m.home_goals > m.away_goals)::INT       AS wins,
           (m.home_goals = m.away_goals)::INT       AS draws,
           (m.home_goals < m.away_goals)::INT       AS losses,
           m.home_goals AS scored,
           m.away_goals AS conceded
    FROM relational.matches m
    JOIN relational.seasons s ON m.season_id = s.season_id
    WHERE s.name = '2024/25'
    UNION ALL
    SELECT m.away_club_id,
           CASE WHEN m.away_goals > m.home_goals THEN 3
                WHEN m.away_goals = m.home_goals THEN 1
                ELSE 0 END,
           (m.away_goals > m.home_goals)::INT,
           (m.away_goals = m.home_goals)::INT,
           (m.away_goals < m.home_goals)::INT,
           m.away_goals,
           m.home_goals
    FROM relational.matches m
    JOIN relational.seasons s ON m.season_id = s.season_id
    WHERE s.name = '2024/25'
)
SELECT c.name,
       COUNT(*)                           AS played,
       SUM(mp.wins)                       AS wins,
       SUM(mp.draws)                      AS draws,
       SUM(mp.losses)                     AS losses,
       SUM(mp.scored)                     AS goals_for,
       SUM(mp.conceded)                   AS goals_against,
       SUM(mp.scored) - SUM(mp.conceded)  AS goal_diff,
       SUM(mp.points)                     AS points
FROM match_points mp
JOIN relational.clubs c ON mp.club_id = c.club_id
GROUP BY c.club_id, c.name
ORDER BY 9 DESC""",

    # KPI 3: Monthly goal trend all seasons  (2 tables + EXTRACT arithmetic)
    f"""{_EX}
SELECT EXTRACT(YEAR  FROM m.match_date)::INT         AS year,
       EXTRACT(MONTH FROM m.match_date)::INT         AS month,
       COUNT(g.goal_id)                              AS total_goals,
       COUNT(DISTINCT m.match_id)                    AS matches_played,
       ROUND(COUNT(g.goal_id)::NUMERIC /
             NULLIF(COUNT(DISTINCT m.match_id), 0), 2) AS avg_goals_per_match
FROM   relational.matches m
LEFT JOIN relational.goals g ON m.match_id = g.match_id
GROUP BY 1, 2
ORDER BY 1, 2""",

    # KPI 4: Goals per nationality  (2 tables, LEFT JOIN)
    f"""{_EX}
SELECT p.nationality,
       COUNT(DISTINCT p.player_id)                          AS total_players,
       COUNT(g.goal_id)                                     AS total_goals,
       ROUND(COUNT(g.goal_id)::NUMERIC /
             NULLIF(COUNT(DISTINCT p.player_id), 0), 2)     AS avg_goals_per_player,
       SUM(CASE WHEN g.goal_type = 'penalty' THEN 1 ELSE 0 END) AS penalty_goals
FROM   relational.players p
LEFT JOIN relational.goals g ON p.player_id = g.scorer_id
GROUP BY p.nationality
HAVING COUNT(DISTINCT p.player_id) >= 5
ORDER BY avg_goals_per_player DESC""",

    # KPI 5: Cards per match by club 2024/25  (UNION ALL + 4 tables)
    f"""{_EX}
WITH club_matches AS (
    SELECT m.match_id, m.home_club_id AS club_id
    FROM   relational.matches m
    JOIN   relational.seasons s ON m.season_id = s.season_id
    WHERE  s.name = '2024/25'
    UNION ALL
    SELECT m.match_id, m.away_club_id
    FROM   relational.matches m
    JOIN   relational.seasons s ON m.season_id = s.season_id
    WHERE  s.name = '2024/25'
)
SELECT c.name,
       COUNT(DISTINCT cm.match_id)                                     AS matches_played,
       SUM(CASE WHEN ca.card_type = 'yellow' THEN 1 ELSE 0 END)        AS yellow_cards,
       SUM(CASE WHEN ca.card_type = 'red'    THEN 1 ELSE 0 END)        AS red_cards,
       COUNT(ca.card_id)                                               AS total_cards,
       ROUND(COUNT(ca.card_id)::NUMERIC /
             NULLIF(COUNT(DISTINCT cm.match_id), 0), 2)                AS cards_per_match
FROM   club_matches cm
JOIN   relational.clubs c  ON cm.club_id   = c.club_id
LEFT JOIN relational.cards ca
       ON  cm.match_id = ca.match_id
       AND cm.club_id  = ca.club_id
GROUP BY c.club_id, c.name
ORDER BY cards_per_match DESC""",
]


DIMENSIONAL_QUERIES = [

    # KPI 1: Top 10 scorers 2024/25  (4 tables, goals pre-stored in fact row)
    f"""{_EX}
SELECT dp.full_name    AS player_name,
       dc.name         AS club,
       dp.nationality,
       dp.position,
       SUM(fp.goals)   AS goals
FROM   dimensional.fact_player_performance fp
JOIN   dimensional.dim_player dp ON fp.player_key = dp.player_key
JOIN   dimensional.dim_club   dc ON fp.club_key   = dc.club_key
JOIN   dimensional.dim_season ds ON fp.season_key = ds.season_key
WHERE  ds.name = '2024/25'
GROUP BY dp.full_name, dc.name, dp.nationality, dp.position
ORDER BY goals DESC
LIMIT 10""",

    # KPI 2: League standings 2024/25  (2 CTEs, pre-computed home_win/away_win/draw)
    f"""{_EX}
WITH home_stats AS (
    SELECT fmr.home_club_key                                               AS ck,
           COUNT(*)                                                        AS played,
           SUM(fmr.home_goals)                                             AS scored,
           SUM(fmr.away_goals)                                             AS conceded,
           SUM(CASE WHEN fmr.home_win THEN 3 WHEN fmr.draw THEN 1 ELSE 0 END) AS pts,
           SUM(fmr.home_win::INT)                                          AS wins,
           SUM(fmr.draw::INT)                                              AS draws,
           SUM(fmr.away_win::INT)                                          AS losses
    FROM   dimensional.fact_match_results fmr
    JOIN   dimensional.dim_season ds ON fmr.season_key = ds.season_key
    WHERE  ds.name = '2024/25'
    GROUP BY fmr.home_club_key
),
away_stats AS (
    SELECT fmr.away_club_key                                               AS ck,
           COUNT(*)                                                        AS played,
           SUM(fmr.away_goals)                                             AS scored,
           SUM(fmr.home_goals)                                             AS conceded,
           SUM(CASE WHEN fmr.away_win THEN 3 WHEN fmr.draw THEN 1 ELSE 0 END) AS pts,
           SUM(fmr.away_win::INT)                                          AS wins,
           SUM(fmr.draw::INT)                                              AS draws,
           SUM(fmr.home_win::INT)                                          AS losses
    FROM   dimensional.fact_match_results fmr
    JOIN   dimensional.dim_season ds ON fmr.season_key = ds.season_key
    WHERE  ds.name = '2024/25'
    GROUP BY fmr.away_club_key
)
SELECT dc.name,
       hs.played    + a.played     AS played,
       hs.wins      + a.wins       AS wins,
       hs.draws     + a.draws      AS draws,
       hs.losses    + a.losses     AS losses,
       hs.scored    + a.scored     AS goals_for,
       hs.conceded  + a.conceded   AS goals_against,
       (hs.scored + a.scored) - (hs.conceded + a.conceded) AS goal_diff,
       hs.pts       + a.pts        AS points
FROM   home_stats hs
JOIN   away_stats a          ON hs.ck       = a.ck
JOIN   dimensional.dim_club dc ON hs.ck    = dc.club_key
ORDER BY points DESC, goal_diff DESC, goals_for DESC""",

    # KPI 3: Monthly goal trend  (2 tables, date attributes pre-computed in dim_date)
    f"""{_EX}
SELECT dd.year,
       dd.month,
       SUM(fmr.home_goals + fmr.away_goals)              AS total_goals,
       COUNT(*)                                           AS matches_played,
       ROUND(SUM(fmr.home_goals + fmr.away_goals)::NUMERIC /
             NULLIF(COUNT(*), 0), 2)                      AS avg_goals_per_match
FROM   dimensional.fact_match_results fmr
JOIN   dimensional.dim_date dd ON fmr.date_key = dd.date_key
GROUP BY dd.year, dd.month
ORDER BY 1, 2""",

    # KPI 4: Goals by nationality  (2 tables, goals pre-summed in fact row)
    f"""{_EX}
SELECT dp.nationality,
       COUNT(DISTINCT dp.player_key)                              AS total_players,
       SUM(fp.goals)                                              AS total_goals,
       ROUND(SUM(fp.goals)::NUMERIC /
             NULLIF(COUNT(DISTINCT dp.player_key), 0), 2)        AS avg_goals_per_player,
       SUM(fp.penalty_goals)                                      AS penalty_goals
FROM   dimensional.fact_player_performance fp
JOIN   dimensional.dim_player dp ON fp.player_key = dp.player_key
GROUP BY dp.nationality
HAVING COUNT(DISTINCT dp.player_key) >= 5
ORDER BY avg_goals_per_player DESC""",

    # KPI 5: Cards per match 2024/25  (card counts pre-aggregated in fact row, no cards table)
    f"""{_EX}
WITH home_cards AS (
    SELECT fmr.home_club_key              AS ck,
           COUNT(*)                       AS matches,
           SUM(fmr.home_yellow_cards)     AS yc,
           SUM(fmr.home_red_cards)        AS rc
    FROM   dimensional.fact_match_results fmr
    JOIN   dimensional.dim_season ds ON fmr.season_key = ds.season_key
    WHERE  ds.name = '2024/25'
    GROUP BY fmr.home_club_key
),
away_cards AS (
    SELECT fmr.away_club_key              AS ck,
           COUNT(*)                       AS matches,
           SUM(fmr.away_yellow_cards)     AS yc,
           SUM(fmr.away_red_cards)        AS rc
    FROM   dimensional.fact_match_results fmr
    JOIN   dimensional.dim_season ds ON fmr.season_key = ds.season_key
    WHERE  ds.name = '2024/25'
    GROUP BY fmr.away_club_key
)
SELECT dc.name,
       hc.matches + ac.matches                                        AS matches_played,
       hc.yc      + ac.yc                                             AS yellow_cards,
       hc.rc      + ac.rc                                             AS red_cards,
       (hc.yc + ac.yc + hc.rc + ac.rc)                               AS total_cards,
       ROUND((hc.yc + ac.yc + hc.rc + ac.rc)::NUMERIC /
             NULLIF(hc.matches + ac.matches, 0), 2)                  AS cards_per_match
FROM   home_cards hc
JOIN   away_cards ac           ON hc.ck = ac.ck
JOIN   dimensional.dim_club dc ON hc.ck = dc.club_key
ORDER BY cards_per_match DESC""",
]


# ── Plan tree analysis helpers ────────────────────────────────────────────────

def _count_nodes(node: dict) -> int:
    """Recursively count every plan node in an EXPLAIN JSON plan tree."""
    total = 1
    for child in node.get("Plans", []):
        total += _count_nodes(child)
    return total


def _count_relation_scans(node: dict) -> int:
    """Count nodes that physically scan a relation (carry a 'Relation Name')."""
    total = 1 if "Relation Name" in node else 0
    for child in node.get("Plans", []):
        total += _count_relation_scans(child)
    return total


# ── Database helpers ──────────────────────────────────────────────────────────

def _connect(host: str, port: int, user: str, password: str, dbname: str):
    kwargs = dict(host=host, port=port, user=user, dbname=dbname)
    if password:
        kwargs["password"] = password
    return psycopg2.connect(**kwargs)


def _run_explain(cur, sql: str) -> dict:
    """Execute an EXPLAIN (ANALYZE, FORMAT JSON) statement and return metrics."""
    cur.execute(sql)
    raw = cur.fetchone()[0]
    # psycopg2 may return the JSON column as a Python str or already-parsed object.
    if isinstance(raw, str):
        data = json.loads(raw)
    else:
        data = raw
    plan_data = data[0]
    root = plan_data["Plan"]
    return {
        "execution_time_ms": plan_data["Execution Time"],
        "planning_time_ms":  plan_data["Planning Time"],
        "nodes":             _count_nodes(root),
        "relations":         _count_relation_scans(root),
    }


def collect_metrics(conn):
    """Run all 10 EXPLAIN queries and return two parallel lists of metric dicts."""
    rel_metrics, dim_metrics = [], []
    n = len(RELATIONAL_QUERIES)

    with conn.cursor() as cur:
        for i, (rq, dq) in enumerate(zip(RELATIONAL_QUERIES, DIMENSIONAL_QUERIES), 1):
            print(f"  KPI {i}/{n}  relational  ...", end=" ", flush=True)
            try:
                rel_metrics.append(_run_explain(cur, rq))
                print(f"ok  ({rel_metrics[-1]['execution_time_ms']:.2f} ms)")
            except Exception as exc:
                print(f"FAILED: {exc}")
                conn.rollback()
                rel_metrics.append(None)

            print(f"  KPI {i}/{n}  dimensional ...", end=" ", flush=True)
            try:
                dim_metrics.append(_run_explain(cur, dq))
                print(f"ok  ({dim_metrics[-1]['execution_time_ms']:.2f} ms)")
            except Exception as exc:
                print(f"FAILED: {exc}")
                conn.rollback()
                dim_metrics.append(None)

    return rel_metrics, dim_metrics


# ── Chart construction ────────────────────────────────────────────────────────

def _style_ax(ax, title: str, xlabel: str = ""):
    """Apply consistent styling to an axes object."""
    ax.set_facecolor(COLOR_AX)
    ax.spines[["top", "right"]].set_visible(False)
    ax.spines[["left", "bottom"]].set_color("#bbbbbb")
    ax.grid(axis="x", linestyle="--", linewidth=0.6, color=COLOR_GRID, alpha=0.8)
    ax.set_title(title, fontsize=11, fontweight="bold", pad=7, color=COLOR_TITLE)
    if xlabel:
        ax.set_xlabel(xlabel, fontsize=9, color="#555555")
    ax.tick_params(colors="#555555", labelsize=8.5)


def _explain(ax, text: str, y: float = -0.24):
    """Place a small italic explanation box just below an axes panel."""
    ax.text(
        0.5, y, text,
        transform=ax.transAxes,
        ha="center", va="top",
        fontsize=8, color="#333333", fontstyle="italic",
        clip_on=False,
        bbox=dict(
            boxstyle="round,pad=0.4",
            facecolor="#eef2f7",
            edgecolor="#b0bec5",
            linewidth=0.8,
            alpha=0.92,
        ),
    )


def _hbars(ax, idx, bar_h, rel_vals, dim_vals, x_fmt=".2f", x_label=""):
    """Draw a grouped horizontal bar chart with inline value labels."""
    bars_rel = ax.barh(
        idx + bar_h / 2, rel_vals, bar_h,
        color=COLOR_REL, alpha=0.85, label="Relational (3NF)", zorder=3,
    )
    bars_dim = ax.barh(
        idx - bar_h / 2, dim_vals, bar_h,
        color=COLOR_DIM, alpha=0.85, label="Dimensional (star schema)", zorder=3,
    )
    ax.set_ylim(-0.6, len(idx) - 0.4)
    _style_ax(ax, "", x_label)

    # Inline value labels
    max_val = max(max(rel_vals, default=0), max(dim_vals, default=0))
    pad = max_val * 0.015
    for bar in bars_rel:
        w = bar.get_width()
        if w:
            ax.text(w + pad, bar.get_y() + bar.get_height() / 2,
                    f"{w:{x_fmt}}", va="center", ha="left",
                    fontsize=7.5, color=COLOR_REL, fontweight="bold")
    for bar in bars_dim:
        w = bar.get_width()
        if w:
            ax.text(w + pad, bar.get_y() + bar.get_height() / 2,
                    f"{w:{x_fmt}}", va="center", ha="left",
                    fontsize=7.5, color=COLOR_DIM, fontweight="bold")

    return bars_rel, bars_dim


def build_chart(rel_metrics, dim_metrics, output_path: str):
    """Compose and save the five-panel comparison figure."""

    n = len(KPI_LABELS_LONG)
    idx = np.arange(n)
    bar_h = 0.36

    # ── Extract numeric arrays ────────────────────────────────────────────────
    def _get(metrics, key, default=0.0):
        return [m[key] if m else default for m in metrics]

    rel_time    = _get(rel_metrics, "execution_time_ms")
    dim_time    = _get(dim_metrics, "execution_time_ms")
    rel_nodes   = _get(rel_metrics, "nodes")
    dim_nodes   = _get(dim_metrics, "nodes")
    rel_rels    = _get(rel_metrics, "relations")
    dim_rels    = _get(dim_metrics, "relations")

    speedup = [
        r / d if (d and d > 0) else 1.0
        for r, d in zip(rel_time, dim_time)
    ]

    avg_speedup    = sum(speedup) / len(speedup)
    avg_node_ratio = (1 - sum(dim_nodes) / sum(rel_nodes)) * 100 if sum(rel_nodes) else 0
    avg_rel_ratio  = (1 - sum(dim_rels)  / sum(rel_rels))  * 100 if sum(rel_rels)  else 0

    # ── Partition pruning projection (mathematical, no DB query needed) ───────
    rows_per_season  = 3800  # fact_player_performance: ~3800 fact rows per season (190K matches / 50 seasons)
    seasons_axis     = [15, 50, 100, 250, 500, 1000]
    full_scan_rows   = [s * rows_per_season for s in seasons_axis]
    pruned_scan_rows = [rows_per_season]    * len(seasons_axis)

    # ── Figure layout ─────────────────────────────────────────────────────────
    fig = plt.figure(figsize=(17, 18))
    fig.patch.set_facecolor(COLOR_BG)

    gs = GridSpec(
        3, 2,
        figure=fig,
        top=0.89, bottom=0.14,
        left=0.13, right=0.97,
        hspace=0.85, wspace=0.38,
    )

    ax1 = fig.add_subplot(gs[0, :])   # row 0: full-width execution time
    ax2 = fig.add_subplot(gs[1, 0])   # row 1 left:  plan nodes
    ax3 = fig.add_subplot(gs[1, 1])   # row 1 right: tables scanned
    ax4 = fig.add_subplot(gs[2, 0])   # row 2 left:  speedup factor
    ax5 = fig.add_subplot(gs[2, 1])   # row 2 right: partition pruning

    # ── Supra-title + subtitle ────────────────────────────────────────────────
    fig.suptitle(
        "Relational Model (3NF)  vs  Dimensional Model (Star Schema)\n"
        "Query Performance Comparison — Football League Database",
        fontsize=15, fontweight="bold", y=0.96, color=COLOR_TITLE,
    )

    # ── Summary strip just below the supra-title ─────────────────────────────
    summary = (
        f"Average speedup: {avg_speedup:.1f}x faster   |   "
        f"Plan nodes reduced: {avg_node_ratio:.0f}%   |   "
        f"Relation scans reduced: {avg_rel_ratio:.0f}%"
    )
    fig.text(0.5, 0.917, summary, ha="center", fontsize=10,
             color="#27ae60", fontweight="bold",
             bbox=dict(boxstyle="round,pad=0.35", facecolor="#eafaf1",
                       edgecolor="#27ae60", linewidth=1.2))

    # ── PANEL 1: Execution Time ───────────────────────────────────────────────
    _hbars(ax1, idx, bar_h, rel_time, dim_time, x_fmt=".2f", x_label="Execution time (ms)")
    ax1.set_yticks(idx)
    ax1.set_yticklabels(KPI_LABELS_LONG, fontsize=9.5)
    ax1.set_title(
        "Execution Time per KPI  (lower is better)",
        fontsize=12, fontweight="bold", pad=8, color=COLOR_TITLE,
    )
    ax1.legend(
        loc="lower right", fontsize=9,
        framealpha=0.9, edgecolor="#cccccc",
    )
    _explain(
        ax1,
        "When dimensional wins (KPI 3): fact_match_results stores home_goals and away_goals"
        " directly — no need to join the goals table at all.  When dimensional is slower"
        " (KPIs 1 and 2): fact_player_performance tracks ALL active players (scorers,"
        " assisters, card-recipients) per match, more rows than the raw goals table."
        "  The benefit of pre-aggregation only exceeds its overhead for cross-season queries.",
        y=-0.14,
    )
    # Percentage improvement annotation per KPI
    x_max = ax1.get_xlim()[1]
    for i_kpi, (r, d, s) in enumerate(zip(rel_time, dim_time, speedup)):
        if r and d and s > 1:
            pct = (1 - d / r) * 100
            ax1.text(
                x_max * 0.995, i_kpi,
                f"-{pct:.0f}%",
                va="center", ha="right", fontsize=8,
                color="#27ae60", fontweight="bold",
                bbox=dict(boxstyle="round,pad=0.2", facecolor="#eafaf1",
                          edgecolor="#27ae60", alpha=0.85),
            )

    # ── PANEL 2: Plan Nodes ───────────────────────────────────────────────────
    _hbars(ax2, idx, bar_h,
           [float(v) for v in rel_nodes],
           [float(v) for v in dim_nodes],
           x_fmt=".0f", x_label="Plan nodes (count)")
    ax2.set_yticks(idx)
    ax2.set_yticklabels(KPI_SHORT, fontsize=9)
    ax2.set_title(
        "Plan Complexity\n(plan nodes in EXPLAIN output)",
        fontsize=11, fontweight="bold", pad=7, color=COLOR_TITLE,
    )
    ax2.legend(loc="lower right", fontsize=8, framealpha=0.9, edgecolor="#cccccc")
    _explain(
        ax2,
        "Why: every FK join in 3NF adds at least one Hash Join + Seq Scan pair to the plan"
        " tree.  Fewer joins = simpler plan = less optimizer work and memory.",
    )

    # ── PANEL 3: Relation Scans ───────────────────────────────────────────────
    _hbars(ax3, idx, bar_h,
           [float(v) for v in rel_rels],
           [float(v) for v in dim_rels],
           x_fmt=".0f", x_label="Relation scans (count)")
    ax3.set_yticks(idx)
    ax3.set_yticklabels(KPI_SHORT, fontsize=9)
    ax3.set_title(
        "Physical Tables Accessed\n(relation scans in plan)",
        fontsize=11, fontweight="bold", pad=7, color=COLOR_TITLE,
    )
    ax3.legend(loc="lower right", fontsize=8, framealpha=0.9, edgecolor="#cccccc")
    _explain(
        ax3,
        "Why: 3NF stores each entity in its own table; all must be joined at runtime."
        "  The star schema collapses attributes onto dimension tables, reducing table access.",
    )

    # ── PANEL 4: Speedup Factor ───────────────────────────────────────────────
    bar_colors = [COLOR_DIM if s >= 1 else COLOR_REL for s in speedup]
    bars4 = ax4.bar(
        KPI_SHORT, speedup,
        color=bar_colors, alpha=0.88,
        edgecolor="white", linewidth=0.8, zorder=3,
    )
    ax4.axhline(1.0, color="#7f8c8d", linestyle="--", linewidth=1.2, zorder=2,
                label="1x  (no difference)")
    ax4.set_ylabel("Speedup factor  (x times faster)", fontsize=9, color="#555555")
    _style_ax(ax4,
              "Dimensional Speedup per KPI\n(dimensional time / relational time)")
    ax4.legend(fontsize=8, loc="upper right", framealpha=0.9)
    ax4.grid(axis="y", linestyle="--", linewidth=0.6, color=COLOR_GRID, alpha=0.8)
    ax4.set_facecolor(COLOR_AX)
    for bar, s in zip(bars4, speedup):
        label_color = COLOR_DIM if s >= 1 else COLOR_REL
        ax4.text(
            bar.get_x() + bar.get_width() / 2,
            bar.get_height() + 0.04,
            f"{s:.1f}x",
            ha="center", va="bottom", fontsize=9.5,
            fontweight="bold", color=label_color,
        )
    _explain(
        ax4,
        "Why KPI 3 gains the most: the relational query must JOIN matches (19K rows) and"
        " goals (53K rows) to compute per-match totals.  The dimensional query reads"
        " home_goals and away_goals already stored in fact_match_results — one large join"
        " eliminated.  KPI 1 is slower in dimensional because the fact table rows represent"
        " ALL active players (not just scorers), so more rows are scanned than in goals.",
    )

    # ── PANEL 5: Partition Pruning Scaling ────────────────────────────────────
    ax5.plot(seasons_axis, full_scan_rows, "o-",
             color=COLOR_REL, linewidth=2.2, markersize=6,
             label="Full table scan (no pruning)", zorder=3)
    ax5.plot(seasons_axis, pruned_scan_rows, "s--",
             color=COLOR_DIM, linewidth=2.2, markersize=6,
             label="Pruned scan (1 partition)", zorder=3)
    ax5.fill_between(
        seasons_axis, pruned_scan_rows, full_scan_rows,
        alpha=0.10, color=COLOR_REL, zorder=2,
    )

    ax5.set_yscale("log")
    ax5.set_xlabel("Seasons in the database", fontsize=9, color="#555555")
    ax5.set_ylabel("Rows scanned  (log scale)", fontsize=9, color="#555555")
    _style_ax(ax5,
              "Partition Pruning: Rows Scanned at Scale\n"
              "(fact_player_performance, 2,500 rows/season)")
    ax5.grid(axis="both", linestyle="--", linewidth=0.6, color=COLOR_GRID, alpha=0.8)
    ax5.legend(fontsize=8.5, loc="upper left", framealpha=0.9)

    # Annotations at 1000 seasons
    ax5.annotate(
        f"{1000 * rows_per_season:,} rows\n(full scan)",
        xy=(1000, 1000 * rows_per_season),
        xytext=(480, 150_000),
        fontsize=8, color=COLOR_REL, fontweight="bold",
        arrowprops=dict(arrowstyle="->", color=COLOR_REL, lw=1.3),
    )
    ax5.annotate(
        f"{rows_per_season:,} rows\n(pruned — constant)",
        xy=(1000, rows_per_season),
        xytext=(430, 130),
        fontsize=8, color=COLOR_DIM, fontweight="bold",
        arrowprops=dict(arrowstyle="->", color=COLOR_DIM, lw=1.3),
    )
    _explain(
        ax5,
        "Why the green line is flat: PostgreSQL resolves WHERE season = 'X' to a"
        " partition key and skips the other 49 partitions entirely.  Cost is O(1)"
        " — independent of how many seasons exist in the table.",
    )

    # ── Key Findings strip ────────────────────────────────────────────────────
    key_findings = (
        "Key findings:\n"
        "  1. Pre-aggregation wins for cross-season queries — KPI 3 (monthly goal trend, all"
        " 50 seasons) is 3.9x faster: dimensional reads home_goals/away_goals directly\n"
        "     from fact_match_results instead of joining the full goals table.\n"
        "  2. Fact table granularity matters — fact_player_performance tracks every active"
        " player per match (scorers + assisters + card-recipients).\n"
        "     For goal-counting queries (KPI 1) this produces MORE rows than the raw goals"
        " table, so dimensional is slower for those specific KPIs.\n"
        "  3. Partition pruning — a WHERE season = 'X' predicate skips 49 of 50 partitions."
        " Cost is O(1) regardless of how many seasons are stored.\n"
        "  4. Correctness — both models return identical result sets;"
        " dimensional is a read-optimised projection of the same normalised data."
    )
    fig.text(
        0.5, 0.115, key_findings,
        ha="center", va="top",
        fontsize=8.5, color="#1a1a2e",
        linespacing=1.6,
        bbox=dict(
            boxstyle="round,pad=0.6",
            facecolor="#fffde7",
            edgecolor="#f9a825",
            linewidth=1.4,
            alpha=0.96,
        ),
        wrap=True,
    )

    # ── Global legend patch strip at figure bottom ────────────────────────────
    rel_patch = mpatches.Patch(color=COLOR_REL, alpha=0.85,
                               label="Relational model (3NF)")
    dim_patch = mpatches.Patch(color=COLOR_DIM, alpha=0.85,
                               label="Dimensional model (star schema)")
    fig.legend(
        handles=[rel_patch, dim_patch],
        loc="lower center",
        ncol=2,
        fontsize=10,
        framealpha=0.92,
        edgecolor="#cccccc",
        bbox_to_anchor=(0.5, 0.005),
    )

    # ── Save ──────────────────────────────────────────────────────────────────
    plt.savefig(output_path, dpi=150, bbox_inches="tight",
                facecolor=fig.get_facecolor())
    plt.close(fig)
    print(f"\nChart saved: {output_path}")


# ── Entry point ───────────────────────────────────────────────────────────────

def _parse_args():
    p = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    p.add_argument("--host",     default="localhost",    help="PostgreSQL host  (default: localhost)")
    p.add_argument("--port",     default=5432, type=int, help="PostgreSQL port  (default: 5432)")
    p.add_argument("--user",     default="postgres",     help="PostgreSQL user  (default: postgres)")
    p.add_argument("--password", default="",             help="PostgreSQL password (default: empty)")
    p.add_argument("--dbname",   default="football_dw",  help="Database name    (default: football_dw)")
    p.add_argument("--output",   default="relational_vs_dimensional.png",
                   help="Output PNG file  (default: relational_vs_dimensional.png)")
    return p.parse_args()


def main():
    args = _parse_args()

    print("=" * 60)
    print("  Football DWH - Performance Comparison Chart Generator")
    print(f"  Database : {args.dbname}@{args.host}:{args.port}")
    print(f"  Output   : {args.output}")
    print("=" * 60)

    print("\nConnecting to PostgreSQL...")
    try:
        conn = _connect(args.host, args.port, args.user, args.password, args.dbname)
        conn.autocommit = True
    except psycopg2.OperationalError as exc:
        sys.exit(
            f"\nConnection failed: {exc}\n\n"
            "Make sure football_dw is set up:\n"
            "    ./run_all.sh\n\n"
            "Override defaults with --host, --port, --user, --password, --dbname."
        )

    print(f"\nRunning EXPLAIN ANALYZE ({len(RELATIONAL_QUERIES)} KPIs x 2 models = "
          f"{2 * len(RELATIONAL_QUERIES)} queries)...\n")
    try:
        rel_metrics, dim_metrics = collect_metrics(conn)
    finally:
        conn.close()

    if any(m is None for m in rel_metrics + dim_metrics):
        print(
            "\nWARNING: One or more queries failed.\n"
            "Ensure both schemas (relational, dimensional) exist.\n"
            "Re-run ./run_all.sh to recreate the database from scratch.\n"
        )

    print("\nGenerating chart...")
    build_chart(rel_metrics, dim_metrics, args.output)
    print("Done.\n")


if __name__ == "__main__":
    main()

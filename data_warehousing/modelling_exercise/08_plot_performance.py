#!/usr/bin/env python3
# Author: Víctor Barceló
"""
Relational (3NF) vs Dimensional (star schema) query cost comparison.

Saved as: relational_vs_dimensional.png

Run from the modelling_exercise/ folder:
    python3 08_plot_performance.py

Requirements:
    pip install matplotlib numpy

Cost model
----------
"Cost units" = rows_processed * join_depth
  rows_processed : rows the query engine touches across all table scans
  join_depth     : number of JOIN operations in the query plan (a proxy
                   for CPU hashing/sorting overhead)

This is a simplified model for teaching purposes. Real PostgreSQL costs
also include I/O page fetches, index traversal, and memory spills, but
rows × joins captures the dominant driver at analytical workloads.

Calibration (football_dw, 380 matches/season, 500 players, 20 clubs)
----------------------------------------------------------------------
Single-season KPI (e.g. "top scorers in 2024/25"):
  Relational : 380 matches + 1067 goals + 500 players + 20 clubs = ~1967 rows
               with idx_matches_season + idx_goals_match (index pushdown)
               join depth = 4
  Dimensional: ~2500 fact_player_performance partition rows
               + 500 dim_player + 20 dim_club = ~3020 rows (partition prune)
               join depth = 3

Cross-season KPI (e.g. "monthly goal trend, all seasons"):
  Relational : (380 matches + 1067 goals) per season = ~1447 rows/season
               join depth = 4  →  slope = 5788 cost units/season
  Dimensional: 380 fact_match_results rows per season (goals pre-aggregated)
               + dim_date overhead (~5000 rows, constant)
               join depth = 2  →  slope = 760 cost units/season
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.ticker as mticker

# =============================================================================
# Cost model parameters
# =============================================================================
# --- Relational ---
REL_ROWS_SINGLE   = 1967    # rows touched for a single-season filter (constant)
REL_JOINS_SINGLE  = 4
REL_ROWS_CROSS    = 1447    # additional rows per season for a full-scan KPI
REL_JOINS_CROSS   = 4
REL_DIM_OVERHEAD  = 520     # clubs + players hash tables (constant)

# --- Dimensional ---
DIM_FACT_PER_SZN  = 2500    # fact_player_performance rows per season partition
DIM_JOINS_SINGLE  = 3
DIM_FACT_MATCH    = 380     # fact_match_results rows per season
DIM_JOINS_CROSS   = 2
DIM_DIM_OVERHEAD  = 5520    # dim_date (5475 rows) + dim_player + dim_club

# Cost unit = rows × join_depth
def cost(rows, joins):
    return rows * joins

seasons = np.arange(1, 201)

# Single-season KPI
rel_single  = cost(REL_ROWS_SINGLE  + REL_DIM_OVERHEAD, REL_JOINS_SINGLE)
dim_single  = cost(DIM_FACT_PER_SZN + DIM_DIM_OVERHEAD, DIM_JOINS_SINGLE)
# Both flat — use np.full
rel_single_arr = np.full(len(seasons), float(rel_single))
dim_single_arr = np.full(len(seasons), float(dim_single))

# Dimensional without partitioning: must scan all seasons
dim_single_no_part = cost(DIM_FACT_PER_SZN * seasons + DIM_DIM_OVERHEAD, DIM_JOINS_SINGLE)

# Cross-season KPI (all seasons in the DB)
# Relational: dimensional overhead is constant (clubs/players), transactional rows grow
rel_cross = cost(REL_ROWS_CROSS * seasons + REL_DIM_OVERHEAD, REL_JOINS_CROSS)
# Dimensional: fact_match_results grows, dim_date is constant
dim_cross = cost(DIM_FACT_MATCH  * seasons + DIM_DIM_OVERHEAD, DIM_JOINS_CROSS)

# Current dataset
N_CURRENT = 15

# =============================================================================
# Plot
# =============================================================================
COLORS = {
    'rel'        : '#1565C0',   # blue  — relational
    'dim_part'   : '#2E7D32',   # green — dimensional + partition
    'dim_nopart' : '#C62828',   # red   — dimensional, no partition
    'marker'     : '#757575',   # grey  — current-scale marker
}

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
fig.suptitle(
    'Relational (3NF) vs Dimensional (star schema) — query cost at scale\n'
    'Cost units = rows processed × join depth',
    fontsize=13, fontweight='bold'
)

# ---------------------------------------------------------------------------
# Panel 1 — single-season filter  (e.g. "top scorers in 2024/25")
# ---------------------------------------------------------------------------
ax1.plot(seasons, dim_single_no_part / 1_000,
         color=COLORS['dim_nopart'], lw=2.5,
         label='Dimensional — no partitioning  [O(n)]')
ax1.plot(seasons, rel_single_arr / 1_000,
         color=COLORS['rel'], lw=2, linestyle='--',
         label=f'Relational — index pushdown  [O(1)]  {REL_JOINS_SINGLE} joins')
ax1.plot(seasons, dim_single_arr / 1_000,
         color=COLORS['dim_part'], lw=2.5, linestyle='-.',
         label=f'Dimensional — RANGE partitioned  [O(1)]  {DIM_JOINS_SINGLE} joins')

# Current-dataset vertical line
ax1.axvline(N_CURRENT, color=COLORS['marker'], lw=1, ls=':')
ax1.text(N_CURRENT + 2, ax1.get_ylim()[1] * 0.05 if ax1.get_ylim()[1] > 0 else 20,
         f'n={N_CURRENT}\n(current)', fontsize=8, color=COLORS['marker'])

# Annotate join count boxes
for y_val, col, label in [
    (rel_single / 1_000,  COLORS['rel'],      f'{REL_JOINS_SINGLE} joins'),
    (dim_single / 1_000,  COLORS['dim_part'], f'{DIM_JOINS_SINGLE} joins'),
]:
    ax1.annotate(
        label,
        xy=(195, y_val),
        xytext=(150, y_val),
        fontsize=8.5, color=col, va='center',
        arrowprops=dict(arrowstyle='->', color=col, lw=0.8),
        bbox=dict(boxstyle='round,pad=0.2', fc='white', ec=col, alpha=0.8),
    )

ax1.set_title('Single-season KPI\n(e.g. "top scorers in 2024/25")', fontsize=11)
ax1.set_xlabel('Total seasons stored in the database')
ax1.set_ylabel('Query cost (rows × joins, thousands)')
ax1.legend(fontsize=9, loc='upper left')
ax1.grid(True, alpha=0.25)
ax1.yaxis.set_major_formatter(mticker.FuncFormatter(lambda x, _: f'{x:,.0f}k'))
ax1.set_xlim(0, 200)
ax1.set_ylim(0, None)

# Fix the text annotation y-position now that ylim is set
for child in ax1.get_children():
    pass  # annotations already placed relatively

# ---------------------------------------------------------------------------
# Panel 2 — cross-season analytical KPI  (e.g. "monthly goal trend, all time")
# ---------------------------------------------------------------------------
ax2.plot(seasons, rel_cross  / 1_000,
         color=COLORS['rel'],      lw=2.5,
         label=f'Relational — {REL_JOINS_CROSS} joins × (goals+matches)/season  [steeper slope]')
ax2.plot(seasons, dim_cross  / 1_000,
         color=COLORS['dim_part'], lw=2.5, linestyle='-.',
         label=f'Dimensional — {DIM_JOINS_CROSS} joins × (pre-aggregated fact)/season  [lower slope]')

ax2.axvline(N_CURRENT, color=COLORS['marker'], lw=1, ls=':')
ax2.text(N_CURRENT + 2, (rel_cross[-1] / 1_000) * 0.05,
         f'n={N_CURRENT}\n(current)', fontsize=8, color=COLORS['marker'])

# Annotate the ratio at n=200
ratio = rel_cross[-1] / dim_cross[-1]
ax2.annotate(
    f'Relational is ~{ratio:.1f}x\nmore expensive\nat n=200',
    xy=(200, rel_cross[-1] / 1_000),
    xytext=(130, rel_cross[-1] / 1_000 * 0.6),
    fontsize=8.5, color=COLORS['rel'],
    arrowprops=dict(arrowstyle='->', color=COLORS['rel'], lw=1),
    bbox=dict(boxstyle='round,pad=0.3', fc='white', ec=COLORS['rel'], alpha=0.85),
)

# Annotate slope labels
ax2.text(185, (rel_cross[-1] / 1_000) * 1.01,
         f'slope ≈ {cost(REL_ROWS_CROSS, REL_JOINS_CROSS):,}/season',
         fontsize=7.5, color=COLORS['rel'], ha='right')
ax2.text(185, (dim_cross[-1] / 1_000) * 1.05,
         f'slope ≈ {cost(DIM_FACT_MATCH, DIM_JOINS_CROSS):,}/season',
         fontsize=7.5, color=COLORS['dim_part'], ha='right')

ax2.set_title('Cross-season analytical KPI\n(e.g. "monthly goal trend, all seasons")', fontsize=11)
ax2.set_xlabel('Total seasons stored in the database')
ax2.set_ylabel('Query cost (rows × joins, thousands)')
ax2.legend(fontsize=9, loc='upper left')
ax2.grid(True, alpha=0.25)
ax2.yaxis.set_major_formatter(mticker.FuncFormatter(lambda x, _: f'{x:,.0f}k'))
ax2.set_xlim(0, 200)
ax2.set_ylim(0, None)

plt.tight_layout()
out = 'relational_vs_dimensional.png'
plt.savefig(out, dpi=150, bbox_inches='tight')
print(f'Saved: {out}')

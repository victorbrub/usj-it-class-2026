#!/usr/bin/env bash
# Author: Víctor Barceló
# =============================================================================
# run_kpis.sh - Run all KPI queries on both models and generate the chart
# =============================================================================
# Usage:
#   ./run_kpis.sh [dbname] [host] [port] [user] [password]
#
# Defaults:
#   dbname   = football_dw
#   host     = localhost
#   port     = 5432
#   user     = postgres
#   password = postgres
#
# What this script does:
#   1. Runs the five relational KPI queries  (plain results + EXPLAIN plans)
#   2. Runs the five dimensional KPI queries (plain results + EXPLAIN plans)
#   3. Runs the partition pruning demo
#   4. Generates relational_vs_dimensional.png via 08_plot_performance.py
#
# Run ./run_all.sh first to set up the database.
# =============================================================================

set -euo pipefail

DB_NAME="${1:-football_dw}"
DB_HOST="${2:-localhost}"
DB_PORT="${3:-5432}"
DB_USER="${4:-postgres}"
DB_PASS="${5:-postgres}"

# Export password so psql never prompts interactively.
if [ -n "${DB_PASS}" ]; then
    export PGPASSWORD="${DB_PASS}"
fi

PSQL="psql -h ${DB_HOST} -p ${DB_PORT} -U ${DB_USER} -d ${DB_NAME}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SEP="============================================================"

echo "${SEP}"
echo "  Football DWH - KPI Comparison"
echo "  Database : ${DB_NAME}@${DB_HOST}:${DB_PORT}"
echo "${SEP}"
echo ""

# ── Step 1: Relational KPI queries ────────────────────────────────────────────
echo "${SEP}"
echo "  [1/4] KPI queries on the RELATIONAL model (3NF)"
echo "${SEP}"
${PSQL} -f "${SCRIPT_DIR}/05_kpis_relational.sql"

echo ""

# ── Step 2: Dimensional KPI queries ───────────────────────────────────────────
echo "${SEP}"
echo "  [2/4] KPI queries on the DIMENSIONAL model (star schema)"
echo "${SEP}"
${PSQL} -f "${SCRIPT_DIR}/06_kpis_dimensional.sql"

echo ""

# ── Step 3: Partition pruning demo ────────────────────────────────────────────
echo "${SEP}"
echo "  [3/4] Partition pruning demo"
echo "${SEP}"
${PSQL} -f "${SCRIPT_DIR}/07_partition_pruning_demo.sql"

echo ""

# ── Step 4: Performance chart ─────────────────────────────────────────────────
echo "${SEP}"
echo "  [4/4] Generating performance chart"
echo "${SEP}"

CHART_SCRIPT="${SCRIPT_DIR}/08_plot_performance.py"

if ! command -v python3 &>/dev/null; then
    echo "python3 not found — skipping chart generation."
    echo "Install Python 3 and run:  python3 08_plot_performance.py"
elif [ ! -f "${CHART_SCRIPT}" ]; then
    echo "08_plot_performance.py not found — skipping chart generation."
else
    # Build the password argument only when a password was supplied.
    PASS_ARG=""
    if [ -n "${DB_PASS}" ]; then
        PASS_ARG="--password ${DB_PASS}"
    fi

    python3 "${CHART_SCRIPT}" \
        --host     "${DB_HOST}"  \
        --port     "${DB_PORT}"  \
        --user     "${DB_USER}"  \
        --dbname   "${DB_NAME}"  \
        ${PASS_ARG}
fi

echo ""
echo "${SEP}"
echo "  Done."
echo ""
echo "  Open relational_vs_dimensional.png to see the comparison chart."
echo "  See README.md for the exercise instructions and reflection questions."
echo "${SEP}"

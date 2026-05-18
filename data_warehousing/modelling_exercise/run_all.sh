#!/usr/bin/env bash
# Author: Víctor Barceló
# =============================================================================
# run_all.sh - Set up the football_dw database from scratch
# =============================================================================
# Usage:
#   ./run_all.sh [dbname] [host] [port] [user] [password]
#
# Defaults:
#   dbname   = football_dw
#   host     = localhost
#   port     = 5432
#   user     = postgres
#   password = (empty — relies on .pgpass or peer/trust auth)
#
# The script will DROP and recreate the target database, so any existing data
# in that database will be lost.
# =============================================================================

set -euo pipefail

DB_NAME="${1:-football_dw}"
DB_HOST="${2:-localhost}"
DB_PORT="${3:-5432}"
DB_USER="${4:-postgres}"
DB_PASS="${5:-postgres}"

# Export password so psql never prompts interactively.
# If no password is provided the variable is left unset and .pgpass / peer
# auth is used as before.
if [ -n "${DB_PASS}" ]; then
    export PGPASSWORD="${DB_PASS}"
fi

PSQL="psql -h ${DB_HOST} -p ${DB_PORT} -U ${DB_USER}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "============================================================"
echo "  Football Data Warehouse - Setup"
echo "  Target database : ${DB_NAME}"
echo "  Host            : ${DB_HOST}:${DB_PORT}"
echo "  User            : ${DB_USER}"
echo "============================================================"
echo ""

# Drop and recreate the database
echo "[1/6] Dropping existing database '${DB_NAME}' (if any)..."
${PSQL} -d postgres -c "DROP DATABASE IF EXISTS ${DB_NAME};" 2>/dev/null || true

echo "[1/6] Creating database '${DB_NAME}'..."
${PSQL} -d postgres -c "CREATE DATABASE ${DB_NAME};"

# Run scripts in order
echo "[2/6] Creating relational schema..."
${PSQL} -d "${DB_NAME}" -f "${SCRIPT_DIR}/01_relational_schema.sql"

echo "[3/6] Populating relational data (this may take 5-10 minutes with 10 leagues and 50 seasons)..."
${PSQL} -d "${DB_NAME}" -f "${SCRIPT_DIR}/02_relational_data.sql"

echo "[4/6] Creating dimensional schema..."
${PSQL} -d "${DB_NAME}" -f "${SCRIPT_DIR}/03_dimensional_schema.sql"

echo "[5/6] Running ETL into dimensional model..."
${PSQL} -d "${DB_NAME}" -f "${SCRIPT_DIR}/04_dimensional_etl.sql"

echo "[6/6] Setup complete."
echo ""
echo "============================================================"
echo "  Next steps:"
echo "  Run all KPI queries and generate the comparison chart:"
echo "    ./run_kpis.sh ${DB_NAME} ${DB_HOST} ${DB_PORT} ${DB_USER}"
echo ""
echo "  Or connect manually:"
echo "    psql -h ${DB_HOST} -p ${DB_PORT} -U ${DB_USER} -d ${DB_NAME}"
echo "    \\i 05_kpis_relational.sql"
echo "    \\i 06_kpis_dimensional.sql"
echo ""
echo "  See README.md for the full exercise instructions."
echo "============================================================"

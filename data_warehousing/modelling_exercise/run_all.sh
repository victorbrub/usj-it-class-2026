#!/usr/bin/env bash
# Author: Víctor Barceló
# =============================================================================
# run_all.sh - Set up the football_dw database from scratch
# =============================================================================
# Usage:
#   ./run_all.sh [dbname] [host] [port] [user]
#
# Defaults:
#   dbname = football_dw
#   host   = localhost
#   port   = 5432
#   user   = postgres
#
# The script will DROP and recreate the target database, so any existing data
# in that database will be lost.
# =============================================================================

set -euo pipefail

DB_NAME="${1:-football_dw}"
DB_HOST="${2:-localhost}"
DB_PORT="${3:-5432}"
DB_USER="${4:-postgres}"

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

echo "[3/6] Populating relational data (this may take 30-60 seconds)..."
${PSQL} -d "${DB_NAME}" -f "${SCRIPT_DIR}/02_relational_data.sql"

echo "[4/6] Creating dimensional schema..."
${PSQL} -d "${DB_NAME}" -f "${SCRIPT_DIR}/03_dimensional_schema.sql"

echo "[5/6] Running ETL into dimensional model..."
${PSQL} -d "${DB_NAME}" -f "${SCRIPT_DIR}/04_dimensional_etl.sql"

echo "[6/6] Setup complete."
echo ""
echo "============================================================"
echo "  Next steps:"
echo "  - Open 05_kpis_relational.sql in psql or a SQL client"
echo "  - Open 06_kpis_dimensional.sql in psql or a SQL client"
echo "  - Run the EXPLAIN ANALYZE queries and compare the plans"
echo "  - See README.md for the full exercise instructions"
echo ""
echo "  Quick connect:"
echo "  psql -h ${DB_HOST} -p ${DB_PORT} -U ${DB_USER} -d ${DB_NAME}"
echo "============================================================"

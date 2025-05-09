# Buat tabel staging untuk accounts

CREATE TABLE IF NOT EXISTS stg_accounts (
    AccountID TEXT,
    code TEXT,
    Name TEXT,
    bank_account_number TEXT,
    currency TEXT
)

# Buat tabel staging untuk balance sheet
CREATE TABLE IF NOT EXISTS stg_balance_sheet (
    account TEXT,
    account_id TEXT,
    date_report TEXT,
    value REAL
)

# Buat tabel dim_account
CREATE TABLE dim_account (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    account_id TEXT,
    code TEXT,
    name TEXT,
    bank_account_number TEXT,
    currency TEXT,
    valid_from TEXT,
    valid_to TEXT,
    is_current INTEGER
)

# Buat tabel fact_balance_sheet
CREATE TABLE fact_balance_sheet (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    account_id TEXT,
    value REAL,
    date_report TEXT,
    dim_account_id INTEGER,
    FOREIGN KEY (dim_account_id) REFERENCES dim_account(id)
)

# Update dim_account (SCD Type 2)
SELECT id, code, name, bank_account_number, currency
        FROM dim_account
        WHERE account_id = ? AND is_current = 1

INSERT saldo + dim_account_id (JOIN ke akun aktif)
INSERT INTO fact_balance_sheet (account_id, value, date_report, dim_account_id)
SELECT s.account_id, s.value, s.date_report, d.id
FROM stg_balance_sheet s
JOIN dim_account d ON s.account_id = d.account_id AND d.is_current = 1
LEFT JOIN fact_balance_sheet f
  ON f.account_id = s.account_id AND f.date_report = s.date_report
WHERE f.account_id IS NULL


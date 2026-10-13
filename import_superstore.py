from pathlib import Path
import pandas as pd
import mysql.connector

# ==================================================
# 1. KONFIGURASI
# ==================================================

FOLDER = Path(__file__).resolve().parent
CSV_FILE = FOLDER / "Sample_Superstore.csv"

DB_CONFIG = {
    "host": "127.0.0.1",
    "port": 3306,
    "user": "root",
    "password": "",  # Isi jika MySQL kamu memakai password
    "database": "customer_sales_analysis",
}

EXPECTED_COLUMNS = [
    "Row ID", "Order ID", "Order Date", "Ship Date",
    "Ship Mode", "Customer ID", "Customer Name",
    "Segment", "Country", "City", "State", "Postal Code",
    "Region", "Product ID", "Category", "Sub-Category",
    "Product Name", "Sales", "Quantity", "Discount", "Profit"
]


def main():
    # ==================================================
    # 2. BACA DAN VALIDASI CSV
    # ==================================================

    if not CSV_FILE.exists():
        raise FileNotFoundError(
            f"File tidak ditemukan: {CSV_FILE}"
        )

    print("Membaca CSV...")
    df = pd.read_csv(CSV_FILE, encoding="utf-8-sig")
    df.columns = df.columns.str.strip()

    if list(df.columns) != EXPECTED_COLUMNS:
        print("Header yang ditemukan:")
        print(df.columns.tolist())
        raise ValueError(
            "Header CSV tidak cocok dengan 21 kolom "
            "yang diharapkan."
        )

    if df.empty:
        raise ValueError("Dataset tidak memiliki data.")

    print(f"Jumlah baris CSV : {len(df):,}")
    print(f"Jumlah kolom CSV: {len(df.columns)}")

    # ==================================================
    # 3. BERSIHKAN DAN KONVERSI TIPE DATA
    # ==================================================

    for col in ["Order Date", "Ship Date"]:
        df[col] = pd.to_datetime(
            df[col], errors="raise"
        ).dt.date

    for col in ["Row ID", "Quantity"]:
        df[col] = pd.to_numeric(
            df[col], errors="raise"
        ).astype("int64")

    for col in ["Sales", "Discount", "Profit"]:
        df[col] = pd.to_numeric(
            df[col], errors="raise"
        )

    # Postal Code disimpan sebagai teks agar nol di depan
    # tidak hilang. Nilai kosong tetap NULL.
    postal = pd.to_numeric(
        df["Postal Code"], errors="coerce"
    )
    df["Postal Code"] = postal.map(
        lambda x: str(int(x)) if pd.notna(x) else None
    )

    # Data kosong lainnya dikonversi menjadi None untuk MySQL
    df = df.astype(object).where(pd.notna(df), None)

    # ==================================================
    # 4. HUBUNGKAN KE MYSQL
    # ==================================================

    conn = None
    cursor = None

    try:
        conn = mysql.connector.connect(**DB_CONFIG)
        cursor = conn.cursor()
        print("Koneksi MySQL berhasil.")

        cursor.execute("""
            CREATE TABLE IF NOT EXISTS superstore (
                row_id INT NOT NULL PRIMARY KEY,
                order_id VARCHAR(30) NOT NULL,
                order_date DATE NOT NULL,
                ship_date DATE NOT NULL,
                ship_mode VARCHAR(40),
                customer_id VARCHAR(30),
                customer_name VARCHAR(120),
                segment VARCHAR(40),
                country VARCHAR(100),
                city VARCHAR(120),
                state VARCHAR(120),
                postal_code VARCHAR(20),
                region VARCHAR(40),
                product_id VARCHAR(40),
                category VARCHAR(60),
                sub_category VARCHAR(60),
                product_name TEXT,
                sales DECIMAL(15,4),
                quantity INT,
                discount DECIMAL(8,4),
                profit DECIMAL(15,4)
            ) ENGINE=InnoDB
              DEFAULT CHARSET=utf8mb4
              COLLATE=utf8mb4_unicode_ci
        """)

        # Hindari impor ganda jika tabel sudah berisi data
        cursor.execute("SELECT COUNT(*) FROM superstore")
        existing_rows = cursor.fetchone()[0]

        if existing_rows > 0:
            raise RuntimeError(
                f"Tabel superstore sudah berisi {existing_rows:,} "
                "baris. Impor dibatalkan untuk mencegah duplikasi. "
                "Periksa tabel sebelum mencoba lagi."
            )

        # ==================================================
        # 5. MASUKKAN DATA
        # ==================================================

        insert_sql = """
            INSERT INTO superstore (
                row_id, order_id, order_date, ship_date,
                ship_mode, customer_id, customer_name,
                segment, country, city, state, postal_code,
                region, product_id, category, sub_category,
                product_name, sales, quantity, discount, profit
            ) VALUES (
                %s, %s, %s, %s, %s, %s, %s,
                %s, %s, %s, %s, %s, %s, %s, %s,
                %s, %s, %s, %s, %s, %s
            )
        """

        columns = [
            "Row ID", "Order ID", "Order Date", "Ship Date",
            "Ship Mode", "Customer ID", "Customer Name",
            "Segment", "Country", "City", "State", "Postal Code",
            "Region", "Product ID", "Category", "Sub-Category",
            "Product Name", "Sales", "Quantity", "Discount", "Profit"
        ]

        rows = list(
            df[columns].itertuples(index=False, name=None)
        )

        batch_size = 500

        for start in range(0, len(rows), batch_size):
            batch = rows[start:start + batch_size]
            cursor.executemany(insert_sql, batch)
            conn.commit()

            print(
                f"Diimpor: {min(start + len(batch), len(rows)):,}"
                f"/{len(rows):,} baris"
            )

        # ==================================================
        # 6. VALIDASI HASIL
        # ==================================================

        cursor.execute("""
            SELECT
                COUNT(*),
                COUNT(DISTINCT order_id),
                ROUND(SUM(sales), 2),
                ROUND(SUM(profit), 2)
            FROM superstore
        """)

        total_rows, total_orders, total_sales, total_profit = (
            cursor.fetchone()
        )

        print("\n===== HASIL IMPOR =====")
        print(f"Total baris     : {total_rows:,}")
        print(f"Jumlah order unik: {total_orders:,}")
        print(f"Total sales     : {total_sales}")
        print(f"Total profit    : {total_profit}")
        print("Impor berhasil.")

    except Exception:
        if conn is not None and conn.is_connected():
            conn.rollback()
        raise

    finally:
        if cursor is not None:
            cursor.close()
        if conn is not None and conn.is_connected():
            conn.close()


if __name__ == "__main__":
    main()
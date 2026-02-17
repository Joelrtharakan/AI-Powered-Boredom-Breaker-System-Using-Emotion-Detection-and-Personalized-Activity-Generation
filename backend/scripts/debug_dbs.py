import sqlite3
import os
import glob

def check_db(db_file):
    print(f"--- Checking {db_file} ---")
    if not os.path.exists(db_file):
        print("File does not exist.")
        return

    try:
        conn = sqlite3.connect(db_file)
        cursor = conn.cursor()
        cursor.execute("PRAGMA table_info(users)")
        columns = [row[1] for row in cursor.fetchall()]
        print(f"Columns in 'users': {columns}")
        if "profile_picture" in columns:
            print("✅ 'profile_picture' column FOUND.")
        else:
            print("❌ 'profile_picture' column MISSING.")
        conn.close()
    except Exception as e:
        print(f"Error reading {db_file}: {e}")
    print("\n")

def main():
    print(f"Current Working Directory: {os.getcwd()}")
    db_files = glob.glob("**/*.db", recursive=True)
    print(f"Found .db files: {db_files}\n")

    for db in db_files:
        check_db(db)

if __name__ == "__main__":
    main()

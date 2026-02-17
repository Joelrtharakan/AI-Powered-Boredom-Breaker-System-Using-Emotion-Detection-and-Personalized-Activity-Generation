import sqlite3
import os

DB_FILE = "boredom_breaker.db"

def add_column():
    if not os.path.exists(DB_FILE):
        print(f"Database file {DB_FILE} not found!")
        return

    conn = sqlite3.connect(DB_FILE)
    cursor = conn.cursor()

    try:
        # Check if column exists
        cursor.execute("PRAGMA table_info(users)")
        columns = [row[1] for row in cursor.fetchall()]
        
        if "profile_picture" in columns:
            print("Column 'profile_picture' already exists in 'users' table.")
        else:
            print("Adding 'profile_picture' column to 'users' table...")
            cursor.execute("ALTER TABLE users ADD COLUMN profile_picture TEXT")
            conn.commit()
            print("Successfully added 'profile_picture' column.")
            
    except Exception as e:
        print(f"Error: {e}")
    finally:
        conn.close()

if __name__ == "__main__":
    add_column()

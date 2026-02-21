import sqlite3
import base64

conn = sqlite3.connect("boredom_breaker.db")
c = conn.cursor()

# Insert dummy data
test_data = b'\x00\x01\x02\x03\x04\x05\xFF\xFE\xFD'
b64_in = base64.b64encode(test_data).decode('utf-8')
c.execute("INSERT INTO lockbox (user_id, label, encrypted_data) VALUES (1, 'Test Blob', ?)", (base64.b64decode(b64_in),))
conn.commit()

# Retrieve
c.execute("SELECT encrypted_data FROM lockbox WHERE label = 'Test Blob' ORDER BY id DESC LIMIT 1")
retrieved = c.fetchone()[0]

b64_out = base64.b64encode(retrieved).decode('utf-8')

print("Input: ", b64_in)
print("Output:", b64_out)
print("Match: ", b64_in == b64_out)

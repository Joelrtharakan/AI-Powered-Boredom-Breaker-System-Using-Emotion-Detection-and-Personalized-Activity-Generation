import sqlite3
import base64
from Cryptodome.Cipher import AES
from Cryptodome.Util.Padding import unpad

# Get data from DB
conn = sqlite3.connect("boredom_breaker.db")
c = conn.cursor()
c.execute("SELECT encrypted_data FROM lockbox ORDER BY id ASC LIMIT 1")
row = c.fetchone()
conn.close()

if not row:
    print("No data")
    exit(1)

blob = row[0]

# Generate common passcodes
candidates = ["000000", "123456", "111111", "999999", "123123"]

for passcode in candidates:
    key_str = passcode.ljust(32, '0')
    key = key_str.encode('utf-8')
    iv = bytes(16)
    
    # Dart Encrypt with AESMode.sic and PKCS7 padding
    # sic mode is CTR
    try:
        cipher = AES.new(key, AES.MODE_CTR, nonce=iv[:8], initial_value=iv[8:])
        decrypted_padded = cipher.decrypt(blob)
        # Attempt to unpad PKCS7
        decrypted = unpad(decrypted_padded, 16)
        print(f"SUCCESS with passcode '{passcode}': {decrypted.decode('utf-8')}")
    except Exception as e:
        # padding error usually means wrong key
        pass

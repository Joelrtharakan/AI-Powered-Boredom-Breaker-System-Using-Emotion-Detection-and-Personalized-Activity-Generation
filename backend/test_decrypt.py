import base64
from Cryptodome.Cipher import AES
from Cryptodome.Util.Padding import unpad

blob = base64.b64decode("gZdLu8o1/rNDKeOB2e7PXtaD9Rv4IVGaSvlDHz9UoD6uQTuHvM49enIHUnudRK3L")

key = "123456".ljust(32, '0').encode('utf-8')  # Change to the actual user pin if known. Let's try 123456... wait I don't know the user's PIN! 
# Let's try to decrypt assuming default dart AES defaults. Dart's encrypt defaults to SIC (CTR).

try:
    print("Testing SIC/CTR")
    iv = bytes(16)
    cipher = AES.new(key, AES.MODE_CTR, nonce=iv[:8], initial_value=bytes(8))  # CTR mode in Python
    # wait python pycryptodome requires nonce and initial_value
except Exception as e:
    print(e)

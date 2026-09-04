#!/usr/bin/env python3
"""
KelasFun Serial Generator v3
Generate serial activation codes untuk distribusi ke user.

Usage:
    python serial_generator.py              → Generate 10 serials
    python serial_generator.py 50           → Generate 50 serials
    python serial_generator.py --file       → Save to serials.txt
    python serial_generator.py --validate KFUN-XXXX-XXXX-XXXX  → Validate
"""

import hashlib
import random
import re
import sys
import os

SALT = "KELASFUN_2024_SCHOOL_MGMT"
CHARS = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'  # no I,O,0,1

def compute_checksum(serial_id: str) -> str:
    data = f"{serial_id}{SALT}".encode('utf-8')
    h = int(hashlib.sha256(data).hexdigest()[:8], 16)
    c1 = CHARS[h % len(CHARS)]
    c2 = CHARS[(h // len(CHARS)) % len(CHARS)]
    return c1 + c2

def generate_serial() -> str:
    serial_id = ''.join(random.choice(CHARS) for _ in range(10))
    checksum = compute_checksum(serial_id)
    full = serial_id + checksum  # 12 chars
    return f"{full[0:4]}-{full[4:8]}-{full[8:12]}"

def validate_serial(serial: str) -> bool:
    serial = serial.strip().upper()
    if not re.match(r'^[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}$', serial):
        return False
    
    payload = serial.replace('-', '')  # 12 chars
    if len(payload) != 12:
        return False
    
    id_part = payload[:10]
    checksum = payload[10:12]
    expected = compute_checksum(id_part)
    return checksum == expected

def main():
    count = 10
    save_file = False
    args = sys.argv[1:]
    
    if '--file' in args:
        save_file = True
        args.remove('--file')
    
    if '--validate' in args:
        idx = args.index('--validate')
        target = args[idx + 1] if idx + 1 < len(args) else ""
        print(f"Serial: {target}")
        print(f"Valid:  {'✓ VALID' if validate_serial(target) else '✗ INVALID'}")
        return
    
    if args:
        try: count = int(args[0])
        except: pass
    
    print("=" * 50)
    print("  🔑 KelasFun Serial Generator v3.0")
    print("=" * 50)
    print(f"\n  Format: XXXX-XXXX-XXXX (prefix KFUN di app)\n")
    
    serials = []
    for i in range(count):
        serial = generate_serial()
        valid = validate_serial(serial)
        serials.append(serial)
        print(f"  {i+1:3d}. KFUN-{serial}  [{'✓' if valid else '✗'}]")
    
    print(f"\n  Total: {len(serials)} | All valid: {all(validate_serial(s) for s in serials)}")
    
    if save_file:
        with open("serials.txt", 'w') as f:
            f.write("KelasFun Serial Activation Codes\n")
            f.write("=" * 50 + "\n\n")
            for i, s in enumerate(serials, 1):
                f.write(f"{i:3d}. KFUN-{s}\n")
            f.write(f"\nTotal: {len(serials)} serials\n")
        print(f"  Saved to: {os.path.abspath('serials.txt')}")
    
    print("\n  Kirim serial ke user via WhatsApp!")

if __name__ == '__main__':
    main()

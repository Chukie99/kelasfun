# kelasFun License Server

Server untuk mengelola lisensi aplikasi kelasFun.

## Fitur

- Generate license key
- Validasi license key + device ID
- Reset license (untuk device hilang/rusak)
- Admin panel untuk manage lisensi

## Cara Menjalankan

### 1. Install dependencies

```bash
cd license_server
npm install
```

### 2. Jalankan server

```bash
npm start
```

Server akan berjalan di port 3000.

### 3. Setup environment variable (opsional)

```bash
set ADMIN_KEY=your_secret_admin_key
```

## API Endpoints

### Generate License Keys

```http
POST /api/generate
Content-Type: application/json

{
  "count": 10,
  "adminKey": "admin123"
}
```

Response:
```json
{
  "success": true,
  "keys": ["XXXX-XXXX-XXXX-XXXX", ...]
}
```

### Validate License

```http
POST /api/validate
Content-Type: application/json

{
  "licenseKey": "XXXX-XXXX-XXXX-XXXX",
  "deviceId": "device_id_from_app"
}
```

Response (success):
```json
{
  "valid": true,
  "message": "License valid",
  "licenseKey": "XXXX-XXXX-XXXX-XXXX",
  "activatedAt": "2024-01-01T00:00:00.000Z"
}
```

Response (already activated on another device):
```json
{
  "valid": false,
  "error": "License is already activated on another device",
  "hint": "Contact admin to reset your license"
}
```

### Reset License

```http
POST /api/reset
Content-Type: application/json

{
  "licenseKey": "XXXX-XXXX-XXXX-XXXX",
  "adminKey": "admin123"
}
```

Response:
```json
{
  "success": true,
  "message": "License reset successfully. User can now activate on a new device."
}
```

### Get All Licenses

```http
GET /api/licenses?adminKey=admin123
```

## Deploy

### Option 1: Railway

```bash
npm install -g @railway/cli
railway login
railway init
railway up
```

### Option 2: Heroku

```bash
heroku create kelasfun-license-server
git push heroku master
```

### Option 3: VPS/Server

```bash
# Install PM2
npm install -g pm2

# Jalankan server
pm2 start server.js --name kelasfun-license

# Auto restart saat server restart
pm2 save
pm2 startup
```

## Security Notes

1. **Ganti admin key default** dengan key yang aman
2. **Gunakan HTTPS** di produksi
3. **Backup database** (licenses.json) secara berkala
4. **Rate limiting** untuk mencegah brute force

## Database

License disimpan di `licenses.json`. Format:

```json
{
  "licenses": [
    {
      "key": "XXXX-XXXX-XXXX-XXXX",
      "deviceId": "hashed_device_id",
      "userName": "Nama User",
      "activatedAt": "2024-01-01T00:00:00.000Z",
      "status": "active",
      "createdAt": "2024-01-01T00:00:00.000Z"
    }
  ],
  "secretKey": "your_secret_key"
}
```

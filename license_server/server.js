const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const crypto = require('crypto');
const fs = require('fs');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(bodyParser.json());

// Database file
const DB_FILE = path.join(__dirname, 'licenses.json');

// Load database
function loadDB() {
    if (fs.existsSync(DB_FILE)) {
        return JSON.parse(fs.readFileSync(DB_FILE, 'utf8'));
    }
    return { licenses: [], secretKey: crypto.randomBytes(32).toString('hex') };
}

// Save database
function saveDB(data) {
    fs.writeFileSync(DB_FILE, JSON.stringify(data, null, 2));
}

// Generate license key
function generateKey() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    let key = '';
    for (let i = 0; i < 4; i++) {
        if (i > 0) key += '-';
        for (let j = 0; j < 4; j++) {
            key += chars.charAt(Math.floor(Math.random() * chars.length));
        }
    }
    return key;
}

// Generate signature untuk license key
function generateSignature(key, deviceId, secretKey) {
    return crypto
        .createHmac('sha256', secretKey)
        .update(`${key}:${deviceId}`)
        .digest('hex');
}

// API: Generate license keys
app.post('/api/generate', (req, res) => {
    const { count = 1, adminKey } = req.body;
    
    // Validasi admin key (dalam produksi, gunakan environment variable)
    if (adminKey !== process.env.ADMIN_KEY && adminKey !== 'admin123') {
        return res.status(401).json({ error: 'Invalid admin key' });
    }
    
    const db = loadDB();
    const keys = [];
    
    for (let i = 0; i < count; i++) {
        let key;
        do {
            key = generateKey();
        } while (db.licenses.some(l => l.key === key));
        
        const license = {
            key,
            deviceId: null,
            userName: null,
            activatedAt: null,
            status: 'unused',
            createdAt: new Date().toISOString()
        };
        
        db.licenses.push(license);
        keys.push(key);
    }
    
    saveDB(db);
    res.json({ success: true, keys });
});

// API: Validate license
app.post('/api/validate', (req, res) => {
    const { licenseKey, deviceId } = req.body;
    
    if (!licenseKey || !deviceId) {
        return res.status(400).json({ error: 'Missing licenseKey or deviceId' });
    }
    
    const db = loadDB();
    const license = db.licenses.find(l => l.key === licenseKey.toUpperCase());
    
    if (!license) {
        return res.status(404).json({ valid: false, error: 'License key not found' });
    }
    
    // Jika license belum digunakan, aktivasi
    if (license.status === 'unused') {
        license.deviceId = deviceId;
        license.status = 'active';
        license.activatedAt = new Date().toISOString();
        saveDB(db);
        
        return res.json({ 
            valid: true, 
            message: 'Activation successful',
            licenseKey: license.key,
            activatedAt: license.activatedAt
        });
    }
    
    // Jika sudah aktif, cek device ID
    if (license.deviceId === deviceId) {
        return res.json({ 
            valid: true, 
            message: 'License valid',
            licenseKey: license.key,
            activatedAt: license.activatedAt
        });
    }
    
    // Device tidak cocok
    return res.status(403).json({ 
        valid: false, 
        error: 'License is already activated on another device',
        hint: 'Contact admin to reset your license'
    });
});

// API: Reset license (untuk device hilang/rusak)
app.post('/api/reset', (req, res) => {
    const { licenseKey, adminKey } = req.body;
    
    if (adminKey !== process.env.ADMIN_KEY && adminKey !== 'admin123') {
        return res.status(401).json({ error: 'Invalid admin key' });
    }
    
    const db = loadDB();
    const license = db.licenses.find(l => l.key === licenseKey.toUpperCase());
    
    if (!license) {
        return res.status(404).json({ error: 'License key not found' });
    }
    
    license.deviceId = null;
    license.userName = null;
    license.activatedAt = null;
    license.status = 'unused';
    
    saveDB(db);
    
    res.json({ 
        success: true, 
        message: 'License reset successfully. User can now activate on a new device.'
    });
});

// API: Get all licenses
app.get('/api/licenses', (req, res) => {
    const { adminKey } = req.query;
    
    if (adminKey !== process.env.ADMIN_KEY && adminKey !== 'admin123') {
        return res.status(401).json({ error: 'Invalid admin key' });
    }
    
    const db = loadDB();
    res.json({ licenses: db.licenses });
});

// API: Health check
app.get('/api/health', (req, res) => {
    res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Start server
app.listen(PORT, () => {
    console.log(`License server running on port ${PORT}`);
    console.log(`Health check: http://localhost:${PORT}/api/health`);
});

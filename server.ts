import express from 'express';
import { createServer as createViteServer } from 'vite';
import path from 'path';
import fs from 'fs';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const isProduction = process.env.NODE_ENV === 'production';
const PORT = Number(process.env.PORT) || 3000;

// Local embedded database directory
const DATA_DIR = path.resolve(__dirname, 'data');
const DB_FILE = path.resolve(DATA_DIR, 'lab_hive_db.json');

if (!fs.existsSync(DATA_DIR)) {
  fs.mkdirSync(DATA_DIR, { recursive: true });
}

interface PCItem {
  id: string;
  pcNumber: string;
  processor: string;
  ram: string;
  status: 'Normal' | 'Rusak';
  updatedAt: string;
  notes?: string;
}

interface SupportItem {
  id: string;
  name: string;
  qty: number;
  condition: 'Baik' | 'Rusak' | 'Perlu Cek';
  location?: string;
  updatedAt: string;
}

interface RepairLog {
  id: string;
  target: string;
  issue: string;
  action: string;
  technician: string;
  createdAt: string;
}

interface LabDatabase {
  pc_box: PCItem[];
  support_box: SupportItem[];
  log_box: RepairLog[];
}

function getInitialLabData(): LabDatabase {
  const now = new Date().toISOString();
  return {
    pc_box: [
      {
        id: 'pc_1',
        pcNumber: 'PC-01',
        processor: 'Intel Core i5-12400',
        ram: '16 GB DDR4',
        status: 'Normal',
        updatedAt: now,
        notes: 'Posisi meja baris depan kiri',
      },
      {
        id: 'pc_2',
        pcNumber: 'PC-02',
        processor: 'Intel Core i5-12400',
        ram: '16 GB DDR4',
        status: 'Normal',
        updatedAt: now,
        notes: 'Posisi meja baris depan tengah',
      },
      {
        id: 'pc_3',
        pcNumber: 'PC-03',
        processor: 'AMD Ryzen 5 5600G',
        ram: '16 GB DDR4',
        status: 'Normal',
        updatedAt: now,
        notes: 'Posisi meja baris depan kanan',
      },
      {
        id: 'pc_4',
        pcNumber: 'PC-04',
        processor: 'Intel Core i3-10100',
        ram: '8 GB DDR4',
        status: 'Rusak',
        updatedAt: now,
        notes: 'Power supply drop, mati saat beban berat',
      },
    ],
    support_box: [
      {
        id: 'sup_1',
        name: 'Switch Gigabit 24-Port',
        qty: 2,
        condition: 'Baik',
        location: 'Rak Server Utama',
        updatedAt: now,
      },
      {
        id: 'sup_2',
        name: 'Proyektor Epson HDMI',
        qty: 1,
        condition: 'Baik',
        location: 'Langit-langit Tengah',
        updatedAt: now,
      },
      {
        id: 'sup_3',
        name: 'UPS ICA 1200VA',
        qty: 4,
        condition: 'Perlu Cek',
        location: 'Meja Instruktur & Server',
        updatedAt: now,
      },
      {
        id: 'sup_4',
        name: 'Kabel LAN Tester Digital',
        qty: 2,
        condition: 'Baik',
        location: 'Lemari Toolkit Teknisi',
        updatedAt: now,
      },
    ],
    log_box: [
      {
        id: 'log_1',
        target: 'PC-04',
        issue: 'PC mati mendadak saat beban kerja berat',
        action: 'Pemeriksaan voltase PSU, perlu pergantian unit power supply 450W',
        technician: 'Rian Pratama',
        createdAt: new Date(Date.now() - 3 * 3600 * 1000).toISOString(),
      },
      {
        id: 'log_2',
        target: 'Switch Gigabit 24-Port',
        issue: 'Port LAN 7 dan 8 intermittent',
        action: 'Pembersihan pin RJ45 dan reset konfigurasi switch',
        technician: 'Budi Santoso',
        createdAt: new Date(Date.now() - 24 * 3600 * 1000).toISOString(),
      },
    ],
  };
}

let db: LabDatabase;

function loadDatabase(): LabDatabase {
  try {
    if (fs.existsSync(DB_FILE)) {
      const raw = fs.readFileSync(DB_FILE, 'utf-8');
      const parsed = JSON.parse(raw);
      if (parsed && Array.isArray(parsed.pc_box) && Array.isArray(parsed.support_box) && Array.isArray(parsed.log_box)) {
        return parsed;
      }
    }
  } catch (err) {
    console.error('Error reading lab hive local db:', err);
  }

  const initial = getInitialLabData();
  saveDatabase(initial);
  return initial;
}

function saveDatabase(data: LabDatabase) {
  try {
    fs.writeFileSync(DB_FILE, JSON.stringify(data, null, 2), 'utf-8');
  } catch (err) {
    console.error('Error writing lab hive db:', err);
  }
}

db = loadDatabase();

async function startServer() {
  const app = express();
  app.use(express.json());

  // === API ENDPOINTS (HIVE CE 3-BOX ARCHITECTURE) ===

  // 1. Get all boxes
  app.get('/api/state', (_req, res) => {
    res.json({ success: true, data: db });
  });

  // --- PC BOX ENDPOINTS ---
  app.post('/api/pc', (req, res) => {
    const { id, pcNumber, processor, ram, status, notes } = req.body;
    if (!pcNumber) {
      return res.status(400).json({ success: false, error: 'Nomor PC harus diisi' });
    }

    const existingIndex = db.pc_box.findIndex((p) => p.id === id);
    const item: PCItem = {
      id: id || 'pc_' + Date.now(),
      pcNumber: pcNumber.trim(),
      processor: processor?.trim() || 'Intel Core i5',
      ram: ram?.trim() || '16 GB',
      status: status === 'Rusak' ? 'Rusak' : 'Normal',
      updatedAt: new Date().toISOString(),
      ...(notes && notes.trim() ? { notes: notes.trim() } : {}),
    };

    if (existingIndex >= 0) {
      db.pc_box[existingIndex] = item;
    } else {
      db.pc_box.push(item);
    }

    saveDatabase(db);
    res.json({ success: true, data: item });
  });

  app.post('/api/pc/:id/toggle', (req, res) => {
    const pc = db.pc_box.find((p) => p.id === req.params.id);
    if (!pc) {
      return res.status(404).json({ success: false, error: 'PC tidak ditemukan' });
    }

    pc.status = pc.status === 'Normal' ? 'Rusak' : 'Normal';
    pc.updatedAt = new Date().toISOString();
    saveDatabase(db);
    res.json({ success: true, data: pc });
  });

  app.delete('/api/pc/:id', (req, res) => {
    const index = db.pc_box.findIndex((p) => p.id === req.params.id);
    if (index === -1) {
      return res.status(404).json({ success: false, error: 'PC tidak ditemukan' });
    }
    const removed = db.pc_box.splice(index, 1)[0];
    saveDatabase(db);
    res.json({ success: true, data: removed });
  });

  // --- SUPPORT BOX ENDPOINTS ---
  app.post('/api/support', (req, res) => {
    const { id, name, qty, condition, location } = req.body;
    if (!name) {
      return res.status(400).json({ success: false, error: 'Nama barang harus diisi' });
    }

    const existingIndex = db.support_box.findIndex((s) => s.id === id);
    const item: SupportItem = {
      id: id || 'sup_' + Date.now(),
      name: name.trim(),
      qty: Math.max(0, parseInt(qty, 10) || 1),
      condition: ['Baik', 'Rusak', 'Perlu Cek'].includes(condition) ? condition : 'Baik',
      location: location?.trim() || undefined,
      updatedAt: new Date().toISOString(),
    };

    if (existingIndex >= 0) {
      db.support_box[existingIndex] = item;
    } else {
      db.support_box.push(item);
    }

    saveDatabase(db);
    res.json({ success: true, data: item });
  });

  app.post('/api/support/:id/qty', (req, res) => {
    const item = db.support_box.find((s) => s.id === req.params.id);
    if (!item) {
      return res.status(404).json({ success: false, error: 'Barang tidak ditemukan' });
    }

    const delta = parseInt(req.body.delta, 10) || 0;
    item.qty = Math.max(0, item.qty + delta);
    item.updatedAt = new Date().toISOString();
    saveDatabase(db);
    res.json({ success: true, data: item });
  });

  app.delete('/api/support/:id', (req, res) => {
    const index = db.support_box.findIndex((s) => s.id === req.params.id);
    if (index === -1) {
      return res.status(404).json({ success: false, error: 'Barang tidak ditemukan' });
    }
    const removed = db.support_box.splice(index, 1)[0];
    saveDatabase(db);
    res.json({ success: true, data: removed });
  });

  // --- LOG BOX ENDPOINTS ---
  app.post('/api/logs', (req, res) => {
    const { target, issue, action, technician } = req.body;
    if (!target || !issue || !action) {
      return res.status(400).json({ success: false, error: 'Target, masalah, dan tindakan wajib diisi' });
    }

    const newLog: RepairLog = {
      id: 'log_' + Date.now(),
      target: target.trim(),
      issue: issue.trim(),
      action: action.trim(),
      technician: technician?.trim() || 'Teknisi Lab',
      createdAt: new Date().toISOString(),
    };

    db.log_box.unshift(newLog);
    saveDatabase(db);
    res.json({ success: true, data: newLog });
  });

  app.delete('/api/logs/:id', (req, res) => {
    const index = db.log_box.findIndex((l) => l.id === req.params.id);
    if (index === -1) {
      return res.status(404).json({ success: false, error: 'Log tidak ditemukan' });
    }
    const removed = db.log_box.splice(index, 1)[0];
    saveDatabase(db);
    res.json({ success: true, data: removed });
  });

  if (!isProduction) {
    const vite = await createViteServer({
      server: { middlewareMode: true },
      appType: 'spa',
    });
    app.use(vite.middlewares);
  } else {
    app.use(express.static(path.resolve(__dirname, 'dist')));
    app.get('*', (_req, res) => {
      res.sendFile(path.resolve(__dirname, 'dist', 'index.html'));
    });
  }

  app.listen(PORT, '0.0.0.0', () => {
    console.log(`[LabTrack Server] Listening on http://0.0.0.0:${PORT}`);
    console.log(`[Hive CE Local DB] 3 boxes active at: ${DB_FILE}`);
  });
}

startServer();

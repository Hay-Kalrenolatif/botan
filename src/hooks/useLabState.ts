import { useState, useEffect, useCallback } from 'react';
import { PCItem, SupportItem, RepairLog, LabDatabaseState } from '../types';

const defaultInitialLabState: LabDatabaseState = {
  pc_box: [
    {
      id: 'pc_1',
      pcNumber: 'PC-01',
      processor: 'Intel Core i5-12400',
      ram: '16 GB DDR4',
      status: 'Normal',
      updatedAt: new Date().toISOString(),
      notes: 'Posisi meja baris depan kiri',
    },
    {
      id: 'pc_2',
      pcNumber: 'PC-02',
      processor: 'Intel Core i5-12400',
      ram: '16 GB DDR4',
      status: 'Normal',
      updatedAt: new Date().toISOString(),
      notes: 'Posisi meja baris depan tengah',
    },
    {
      id: 'pc_3',
      pcNumber: 'PC-03',
      processor: 'AMD Ryzen 5 5600G',
      ram: '16 GB DDR4',
      status: 'Normal',
      updatedAt: new Date().toISOString(),
      notes: 'Posisi meja baris depan kanan',
    },
    {
      id: 'pc_4',
      pcNumber: 'PC-04',
      processor: 'Intel Core i3-10100',
      ram: '8 GB DDR4',
      status: 'Rusak',
      updatedAt: new Date().toISOString(),
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
      updatedAt: new Date().toISOString(),
    },
    {
      id: 'sup_2',
      name: 'Proyektor Epson HDMI',
      qty: 1,
      condition: 'Baik',
      location: 'Langit-langit Tengah',
      updatedAt: new Date().toISOString(),
    },
    {
      id: 'sup_3',
      name: 'UPS ICA 1200VA',
      qty: 4,
      condition: 'Perlu Cek',
      location: 'Meja Instruktur & Server',
      updatedAt: new Date().toISOString(),
    },
    {
      id: 'sup_4',
      name: 'Kabel LAN Tester Digital',
      qty: 2,
      condition: 'Baik',
      location: 'Lemari Toolkit Teknisi',
      updatedAt: new Date().toISOString(),
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

export function useLabState() {
  const [data, setData] = useState<LabDatabaseState>(() => {
    try {
      const cached = localStorage.getItem('lab_hive_cache_v1');
      if (cached) return JSON.parse(cached);
    } catch {
      // ignore
    }
    return defaultInitialLabState;
  });

  const [isLoading, setIsLoading] = useState(true);

  const updateData = useCallback((next: LabDatabaseState) => {
    setData(next);
    try {
      localStorage.setItem('lab_hive_cache_v1', JSON.stringify(next));
    } catch {
      // ignore
    }
  }, []);

  const fetchState = useCallback(async () => {
    try {
      setIsLoading(true);
      const res = await fetch('/api/state');
      if (res.ok) {
        const json = await res.json();
        if (json.success && json.data) {
          updateData(json.data);
        }
      }
    } catch {
      // fallback to local cache
    } finally {
      setIsLoading(false);
    }
  }, [updateData]);

  useEffect(() => {
    fetchState();
  }, [fetchState]);

  // --- PC ACTIONS ---
  const savePC = useCallback(
    async (pc: Omit<PCItem, 'updatedAt'>) => {
      const updatedPC: PCItem = {
        ...pc,
        updatedAt: new Date().toISOString(),
      };

      const existingIndex = data.pc_box.findIndex((p) => p.id === pc.id);
      const nextPCs = [...data.pc_box];
      if (existingIndex >= 0) {
        nextPCs[existingIndex] = updatedPC;
      } else {
        nextPCs.push(updatedPC);
      }

      updateData({ ...data, pc_box: nextPCs });

      try {
        await fetch('/api/pc', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(updatedPC),
        });
      } catch {
        // cached
      }
    },
    [data, updateData]
  );

  const togglePCStatus = useCallback(
    async (id: string) => {
      const pc = data.pc_box.find((p) => p.id === id);
      if (!pc) return;

      const newStatus = pc.status === 'Normal' ? 'Rusak' : 'Normal';
      const updated = { ...pc, status: newStatus as 'Normal' | 'Rusak', updatedAt: new Date().toISOString() };
      const nextPCs = data.pc_box.map((p) => (p.id === id ? updated : p));
      updateData({ ...data, pc_box: nextPCs });

      try {
        await fetch(`/api/pc/${id}/toggle`, { method: 'POST' });
      } catch {
        // cached
      }
    },
    [data, updateData]
  );

  const deletePC = useCallback(
    async (id: string) => {
      const nextPCs = data.pc_box.filter((p) => p.id !== id);
      updateData({ ...data, pc_box: nextPCs });

      try {
        await fetch(`/api/pc/${id}`, { method: 'DELETE' });
      } catch {
        // cached
      }
    },
    [data, updateData]
  );

  // --- SUPPORT ITEM ACTIONS ---
  const saveSupportItem = useCallback(
    async (item: Omit<SupportItem, 'updatedAt'>) => {
      const updatedItem: SupportItem = {
        ...item,
        updatedAt: new Date().toISOString(),
      };

      const existingIndex = data.support_box.findIndex((s) => s.id === item.id);
      const nextSupports = [...data.support_box];
      if (existingIndex >= 0) {
        nextSupports[existingIndex] = updatedItem;
      } else {
        nextSupports.push(updatedItem);
      }

      updateData({ ...data, support_box: nextSupports });

      try {
        await fetch('/api/support', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(updatedItem),
        });
      } catch {
        // cached
      }
    },
    [data, updateData]
  );

  const updateSupportQty = useCallback(
    async (id: string, delta: number) => {
      const item = data.support_box.find((s) => s.id === id);
      if (!item) return;

      const newQty = Math.max(0, item.qty + delta);
      const updated = { ...item, qty: newQty, updatedAt: new Date().toISOString() };
      const nextSupports = data.support_box.map((s) => (s.id === id ? updated : s));
      updateData({ ...data, support_box: nextSupports });

      try {
        await fetch(`/api/support/${id}/qty`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ delta }),
        });
      } catch {
        // cached
      }
    },
    [data, updateData]
  );

  const deleteSupportItem = useCallback(
    async (id: string) => {
      const nextSupports = data.support_box.filter((s) => s.id !== id);
      updateData({ ...data, support_box: nextSupports });

      try {
        await fetch(`/api/support/${id}`, { method: 'DELETE' });
      } catch {
        // cached
      }
    },
    [data, updateData]
  );

  // --- REPAIR LOG ACTIONS ---
  const saveRepairLog = useCallback(
    async (log: Omit<RepairLog, 'id' | 'createdAt'>) => {
      const newLog: RepairLog = {
        id: 'log_' + Date.now(),
        ...log,
        createdAt: new Date().toISOString(),
      };

      const nextLogs = [newLog, ...data.log_box];
      updateData({ ...data, log_box: nextLogs });

      try {
        await fetch('/api/logs', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(log),
        });
      } catch {
        // cached
      }
    },
    [data, updateData]
  );

  const deleteRepairLog = useCallback(
    async (id: string) => {
      const nextLogs = data.log_box.filter((l) => l.id !== id);
      updateData({ ...data, log_box: nextLogs });

      try {
        await fetch(`/api/logs/${id}`, { method: 'DELETE' });
      } catch {
        // cached
      }
    },
    [data, updateData]
  );

  return {
    pc_box: data.pc_box,
    support_box: data.support_box,
    log_box: data.log_box,
    isLoading,
    savePC,
    togglePCStatus,
    deletePC,
    saveSupportItem,
    updateSupportQty,
    deleteSupportItem,
    saveRepairLog,
    deleteRepairLog,
    refresh: fetchState,
  };
}

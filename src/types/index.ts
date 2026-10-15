export interface PCItem {
  id: string;
  pcNumber: string;
  processor: string;
  ram: string;
  status: 'Normal' | 'Rusak';
  updatedAt: string;
  notes?: string;
}

export interface SupportItem {
  id: string;
  name: string;
  qty: number;
  condition: 'Baik' | 'Rusak' | 'Perlu Cek';
  location?: string;
  updatedAt: string;
}

export interface RepairLog {
  id: string;
  target: string;
  issue: string;
  action: string;
  technician: string;
  createdAt: string;
}

export interface LabDatabaseState {
  pc_box: PCItem[];
  support_box: SupportItem[];
  log_box: RepairLog[];
}

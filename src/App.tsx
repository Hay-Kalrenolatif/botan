import React, { useState } from 'react';
import {
  LayoutDashboard,
  Monitor,
  Server,
  Wrench,
  Plus,
  Trash2,
  Edit2,
  CheckCircle2,
  AlertTriangle,
  Clock,
  MapPin,
  Cpu,
  Layers,
  HardDrive,
  X,
  Bell,
  ArrowRight,
  User,
} from 'lucide-react';
import { useLabState } from './hooks/useLabState';
import { ConcentricRing } from './components/ConcentricRing';
import { PCItem, SupportItem, RepairLog } from './types';
import { clamp, numFmt, fd, fdt } from './utils/machine';

export default function App() {
  const lab = useLabState();
  const [tab, setTab] = useState<number>(0);
  const [notificationOpen, setNotificationOpen] = useState(false);

  // Filter states
  const [pcFilter, setPcFilter] = useState<'Semua' | 'Normal' | 'Rusak'>('Semua');
  const [supportFilter, setSupportFilter] = useState<'Semua' | 'Baik' | 'Cek/Rusak'>('Semua');

  // Form Modals
  const [pcModalOpen, setPcModalOpen] = useState(false);
  const [editingPC, setEditingPC] = useState<PCItem | null>(null);
  const [pcNum, setPcNum] = useState('');
  const [pcProc, setPcProc] = useState('Intel Core i5-12400');
  const [pcRam, setPcRam] = useState('16 GB DDR4');
  const [pcStatus, setPcStatus] = useState<'Normal' | 'Rusak'>('Normal');
  const [pcNotes, setPcNotes] = useState('');

  const [supportModalOpen, setSupportModalOpen] = useState(false);
  const [editingSupport, setEditingSupport] = useState<SupportItem | null>(null);
  const [supName, setSupName] = useState('');
  const [supQty, setSupQty] = useState('1');
  const [supCondition, setSupCondition] = useState<'Baik' | 'Rusak' | 'Perlu Cek'>('Baik');
  const [supLocation, setSupLocation] = useState('');

  const [logModalOpen, setLogModalOpen] = useState(false);
  const [logTarget, setLogTarget] = useState('');
  const [logIssue, setLogIssue] = useState('');
  const [logAction, setLogAction] = useState('');
  const [logTech, setLogTech] = useState('');

  // Delete Confirmations
  const [deletePCConfirm, setDeletePCConfirm] = useState<PCItem | null>(null);
  const [deleteSupportConfirm, setDeleteSupportConfirm] = useState<SupportItem | null>(null);
  const [deleteLogConfirm, setDeleteLogConfirm] = useState<RepairLog | null>(null);

  // Toast
  const [toast, setToast] = useState<{ msg: string; isError?: boolean } | null>(null);
  const showToast = (msg: string, isError = false) => {
    setToast({ msg, isError });
    setTimeout(() => setToast(null), 3000);
  };

  // Calculations
  const totalPC = lab.pc_box.length;
  const normalPC = lab.pc_box.filter((p) => p.status === 'Normal').length;
  const brokenPC = totalPC - normalPC;
  const pcReadyPct = totalPC === 0 ? 1.0 : clamp(normalPC / totalPC);

  const totalSupportQty = lab.support_box.reduce((sum, s) => sum + s.qty, 0);
  const goodSupportQty = lab.support_box
    .filter((s) => s.condition === 'Baik')
    .reduce((sum, s) => sum + s.qty, 0);
  const supportReadyPct = totalSupportQty === 0 ? 1.0 : clamp(goodSupportQty / totalSupportQty);

  const brokenSupportCount = lab.support_box.filter(
    (s) => s.condition === 'Rusak' || s.condition === 'Perlu Cek'
  ).length;

  const hasIssues = brokenPC > 0 || brokenSupportCount > 0;

  // Filtered lists
  const filteredPCs = lab.pc_box.filter((p) => {
    if (pcFilter === 'Normal') return p.status === 'Normal';
    if (pcFilter === 'Rusak') return p.status === 'Rusak';
    return true;
  });

  const filteredSupports = lab.support_box.filter((s) => {
    if (supportFilter === 'Baik') return s.condition === 'Baik';
    if (supportFilter === 'Cek/Rusak') return s.condition !== 'Baik';
    return true;
  });

  // Open PC form
  const handleOpenPCForm = (existing?: PCItem) => {
    if (existing) {
      setEditingPC(existing);
      setPcNum(existing.pcNumber);
      setPcProc(existing.processor);
      setPcRam(existing.ram);
      setPcStatus(existing.status);
      setPcNotes(existing.notes || '');
    } else {
      setEditingPC(null);
      setPcNum(`PC-${String(totalPC + 1).padStart(2, '0')}`);
      setPcProc('Intel Core i5-12400');
      setPcRam('16 GB DDR4');
      setPcStatus('Normal');
      setPcNotes('');
    }
    setPcModalOpen(true);
  };

  // Open Support form
  const handleOpenSupportForm = (existing?: SupportItem) => {
    if (existing) {
      setEditingSupport(existing);
      setSupName(existing.name);
      setSupQty(existing.qty.toString());
      setSupCondition(existing.condition);
      setSupLocation(existing.location || '');
    } else {
      setEditingSupport(null);
      setSupName('');
      setSupQty('1');
      setSupCondition('Baik');
      setSupLocation('');
    }
    setSupportModalOpen(true);
  };

  return (
    <div className="min-h-screen bg-[#0A0F0B] text-white flex justify-center selection:bg-[#A8E6D8]/20">
      <div className="w-full max-w-md min-h-screen flex flex-col relative pb-28">
        {/* HEADER */}
        <header className="px-5 pt-5 pb-3 flex items-center justify-between sticky top-0 bg-[#0A0F0B]/95 backdrop-blur-md z-30 border-b border-[#233027]/40">
          <div className="flex items-center gap-3">
            {/* Logo */}
            <div className="w-10 h-10 rounded-2xl bg-gradient-to-br from-[#A8E6D8] to-[#E8E48C] p-[2px] shadow-lg shadow-[#A8E6D8]/20">
              <div className="w-full h-full bg-[#0A0F0B] rounded-[14px] flex items-center justify-center relative">
                <div className="w-4 h-4 bg-[#0A0F0B] border-2 border-[#A8E6D8] rounded-md"></div>
                <div className="w-2 h-2 bg-[#A8E6D8] rounded-full absolute"></div>
              </div>
            </div>
            <div>
              <h1 className="text-base font-extrabold tracking-tight text-white flex items-center gap-1.5">
                LTrack
                <span className="text-[9px] font-bold text-[#A8E6D8] px-1.5 py-0.5 rounded-full bg-[#A8E6D8]/10 border border-[#A8E6D8]/25">
                  SMART LAB
                </span>
              </h1>
            </div>
          </div>

          <div className="flex items-center gap-2">
            <button
              onClick={() => setNotificationOpen(true)}
              className="w-10 h-10 rounded-xl bg-[#151B17] border border-[#233027] flex items-center justify-center text-white/70 hover:text-[#A8E6D8] transition relative active:scale-95"
            >
              <Bell className="w-4 h-4" />
              {hasIssues && (
                <span className="absolute top-2.5 right-2.5 w-2.5 h-2.5 rounded-full bg-[#F08A4B] animate-pulse shadow-sm shadow-[#F08A4B]" />
              )}
            </button>
          </div>
        </header>

        {/* CONTENT */}
        <main className="flex-1 px-5 pt-3">
          {/* MENU 1: RINGKASAN & GAMBARAN SINGKAT */}
          {tab === 0 && (
            <div className="space-y-4 animate-in fade-in duration-300">
              <div className="text-center pt-2">
                <span className="text-xs text-white/50 font-medium">Lab</span>
                <h2 className="text-2xl font-bold tracking-tight text-white mt-0.5">
                  Kesiapan Fasilitas<br />&amp; Inventaris
                </h2>
              </div>

              {/* Concentric Ring Status */}
              <div className="bg-[#151B17] border border-[#233027] rounded-3xl p-5 shadow-xl flex flex-col items-center">
                <ConcentricRing
                  values={[pcReadyPct, supportReadyPct, 1.0]}
                  colors={['#A8E6D8', '#E8E48C', '#E3B8F5']}
                  size={195}
                >
                  <span className="text-3xl font-extrabold text-white tracking-tight">
                    {Math.round(pcReadyPct * 100)}%
                  </span>
                  <span className="text-[11px] font-medium text-white/50">Kesiapan PC</span>
                </ConcentricRing>

                {/* Legend Items */}
                <div className="w-full bg-[#1B241F] rounded-2xl p-2.5 mt-4 grid grid-cols-3 gap-2 text-center border border-[#233027]/60">
                  <div className="flex flex-col items-center">
                    <span className="text-sm font-bold text-white">
                      {normalPC} / {totalPC}
                    </span>
                    <div className="flex items-center gap-1.5 mt-0.5">
                      <span className="w-2 h-2 rounded-full bg-[#A8E6D8]" />
                      <span className="text-[10px] text-white/60 font-medium">PC Normal</span>
                    </div>
                  </div>

                  <div className="flex flex-col items-center">
                    <span className="text-sm font-bold text-white">
                      {Math.round(supportReadyPct * 100)}%
                    </span>
                    <div className="flex items-center gap-1.5 mt-0.5">
                      <span className="w-2 h-2 rounded-full bg-[#E8E48C]" />
                      <span className="text-[10px] text-white/60 font-medium">Pendukung</span>
                    </div>
                  </div>

                  <div className="flex flex-col items-center">
                    <span className="text-sm font-bold text-white">{lab.log_box.length}</span>
                    <div className="flex items-center gap-1.5 mt-0.5">
                      <span className="w-2 h-2 rounded-full bg-[#E3B8F5]" />
                      <span className="text-[10px] text-white/60 font-medium">Servis</span>
                    </div>
                  </div>
                </div>
              </div>

              {/* Alert Banner */}
              {hasIssues && (
                <div
                  onClick={() => setTab(1)}
                  className="bg-[#151B17] border border-[#F08A4B]/35 rounded-3xl p-4 shadow-lg cursor-pointer flex items-center gap-3.5 hover:border-[#F08A4B]/60 transition"
                >
                  <div className="w-10 h-10 rounded-2xl bg-[#F08A4B]/15 text-[#F08A4B] flex items-center justify-center shrink-0">
                    <AlertTriangle className="w-5 h-5" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <h4 className="text-xs font-bold text-[#F08A4B]">Perlu Penanganan Teknis</h4>
                    <p className="text-[11px] text-white/70 mt-0.5 leading-snug">
                      {brokenPC > 0 && `${brokenPC} unit PC rusak. `}
                      {brokenSupportCount > 0 && `${brokenSupportCount} alat pendukung perlu perbaikan.`}
                    </p>
                  </div>
                  <ArrowRight className="w-4 h-4 text-white/30 shrink-0" />
                </div>
              )}

              {/* 3 Fitur Utama Shortcut Cards */}
              <div className="space-y-3 pt-1">
                <span className="text-xs font-bold text-white/60 block">Akses Cepat</span>

                {/* Card 1: PC Management */}
                <div
                  onClick={() => setTab(1)}
                  className="bg-[#151B17] border border-[#233027] rounded-3xl p-4 shadow-md hover:border-[#A8E6D8]/30 transition cursor-pointer flex items-center gap-3.5 active:scale-[0.99]"
                >
                  <div className="w-11 h-11 rounded-2xl bg-[#A8E6D8]/10 text-[#A8E6D8] border border-[#A8E6D8]/20 flex items-center justify-center shrink-0">
                    <Monitor className="w-5 h-5" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center justify-between">
                      <h4 className="text-sm font-bold text-white">Manajemen Unit PC</h4>
                      <span className="text-[10px] font-bold text-[#A8E6D8] bg-[#A8E6D8]/10 px-2 py-0.5 rounded-full">
                        {totalPC} unit
                      </span>
                    </div>
                    <p className="text-[11px] text-white/50 mt-0.5 truncate">
                      Spesifikasi prosesor, RAM &amp; status ({normalPC} Normal, {brokenPC} Rusak)
                    </p>
                  </div>
                  <ArrowRight className="w-4 h-4 text-white/30 shrink-0" />
                </div>

                {/* Card 2: Support Inventory */}
                <div
                  onClick={() => setTab(2)}
                  className="bg-[#151B17] border border-[#233027] rounded-3xl p-4 shadow-md hover:border-[#E8E48C]/30 transition cursor-pointer flex items-center gap-3.5 active:scale-[0.99]"
                >
                  <div className="w-11 h-11 rounded-2xl bg-[#E8E48C]/10 text-[#E8E48C] border border-[#E8E48C]/20 flex items-center justify-center shrink-0">
                    <Server className="w-5 h-5" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center justify-between">
                      <h4 className="text-sm font-bold text-white">Inventaris Pendukung Lab</h4>
                      <span className="text-[10px] font-bold text-[#E8E48C] bg-[#E8E48C]/10 px-2 py-0.5 rounded-full">
                        {lab.support_box.length} item
                      </span>
                    </div>
                    <p className="text-[11px] text-white/50 mt-0.5 truncate">
                      Switch, proyektor, UPS &amp; alat jaringan ({totalSupportQty} total unit)
                    </p>
                  </div>
                  <ArrowRight className="w-4 h-4 text-white/30 shrink-0" />
                </div>

                {/* Card 3: Repair Log */}
                <div
                  onClick={() => setTab(3)}
                  className="bg-[#151B17] border border-[#233027] rounded-3xl p-4 shadow-md hover:border-[#E3B8F5]/30 transition cursor-pointer flex items-center gap-3.5 active:scale-[0.99]"
                >
                  <div className="w-11 h-11 rounded-2xl bg-[#E3B8F5]/10 text-[#E3B8F5] border border-[#E3B8F5]/20 flex items-center justify-center shrink-0">
                    <Wrench className="w-5 h-5" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center justify-between">
                      <h4 className="text-sm font-bold text-white">Log Riwayat Perbaikan</h4>
                      <span className="text-[10px] font-bold text-[#E3B8F5] bg-[#E3B8F5]/10 px-2 py-0.5 rounded-full">
                        {lab.log_box.length} log
                      </span>
                    </div>
                    <p className="text-[11px] text-white/50 mt-0.5 truncate">
                      {lab.log_box.length > 0
                        ? `Terakhir: ${lab.log_box[0].target} oleh ${lab.log_box[0].technician}`
                        : 'Pencatatan kerusakan & tindakan teknisi'}
                    </p>
                  </div>
                  <ArrowRight className="w-4 h-4 text-white/30 shrink-0" />
                </div>
              </div>
            </div>
          )}

          {/* MENU 2: MANAJEMEN PC & SPESIFIKASI */}
          {tab === 1 && (
            <div className="space-y-4 animate-in fade-in duration-300">
              <div className="text-center">
                <h2 className="text-xl font-bold text-white">Manajemen PC &amp; Spesifikasi</h2>
              </div>

              {/* Segmented Filter */}
              <div className="bg-[#1B241F] p-1 rounded-2xl flex border border-[#233027]">
                {(['Semua', 'Normal', 'Rusak'] as const).map((mode) => (
                  <button
                    key={mode}
                    onClick={() => setPcFilter(mode)}
                    className={`flex-1 py-2 text-xs font-bold rounded-xl transition ${
                      pcFilter === mode ? 'bg-[#E8E48C] text-[#0A0F0B] shadow' : 'text-white/60'
                    }`}
                  >
                    {mode}
                  </button>
                ))}
              </div>

              {/* Counter Row */}
              <div className="grid grid-cols-2 gap-3">
                <div className="bg-[#151B17] border border-[#233027] rounded-2xl p-3.5 flex items-center justify-between">
                  <div>
                    <span className="text-[11px] text-white/50 font-medium">PC Normal</span>
                    <div className="text-xl font-bold text-[#A8E6D8] mt-0.5">{normalPC} Unit</div>
                  </div>
                  <CheckCircle2 className="w-5 h-5 text-[#A8E6D8]" />
                </div>

                <div className="bg-[#151B17] border border-[#233027] rounded-2xl p-3.5 flex items-center justify-between">
                  <div>
                    <span className="text-[11px] text-white/50 font-medium">PC Rusak</span>
                    <div className={`text-xl font-bold mt-0.5 ${brokenPC > 0 ? 'text-[#F08A4B]' : 'text-white/70'}`}>
                      {brokenPC} Unit
                    </div>
                  </div>
                  <AlertTriangle className={`w-5 h-5 ${brokenPC > 0 ? 'text-[#F08A4B]' : 'text-white/30'}`} />
                </div>
              </div>

              {/* Action Bar */}
              <div className="flex items-center justify-between pt-1">
                <span className="text-xs font-bold text-white/70">
                  Daftar Unit PC ({filteredPCs.length})
                </span>
                <button
                  onClick={() => handleOpenPCForm()}
                  className="flex items-center gap-1 text-xs font-bold text-[#A8E6D8] hover:underline"
                >
                  <Plus className="w-3.5 h-3.5" />
                  PC Baru
                </button>
              </div>

              {/* PC Cards List */}
              <div className="space-y-3">
                {filteredPCs.map((pc) => {
                  const isNormal = pc.status === 'Normal';
                  const col = isNormal ? '#A8E6D8' : '#F08A4B';

                  return (
                    <div
                      key={pc.id}
                      className="bg-[#151B17] border border-[#233027] rounded-3xl p-4 shadow-md space-y-3"
                    >
                      <div className="flex items-center justify-between">
                        <div className="flex items-center gap-3">
                          <div
                            className="w-10 h-10 rounded-2xl flex items-center justify-center shrink-0 border"
                            style={{
                              backgroundColor: `${col}15`,
                              borderColor: `${col}35`,
                              color: col,
                            }}
                          >
                            <Monitor className="w-5 h-5" />
                          </div>
                          <div>
                            <div className="flex items-center gap-2">
                              <h4 className="text-sm font-bold text-white">{pc.pcNumber}</h4>
                              <span
                                className="text-[10px] font-bold px-2 py-0.5 rounded-full"
                                style={{
                                  backgroundColor: `${col}18`,
                                  color: col,
                                  border: `1px solid ${col}30`,
                                }}
                              >
                                {pc.status}
                              </span>
                            </div>
                            <span className="text-[10px] text-white/40">Diperbarui {fd(pc.updatedAt)}</span>
                          </div>
                        </div>

                        <div className="flex items-center gap-1">
                          <button
                            onClick={() => handleOpenPCForm(pc)}
                            className="text-white/40 hover:text-white p-1"
                            title="Edit PC"
                          >
                            <Edit2 className="w-4 h-4" />
                          </button>
                          <button
                            onClick={() => setDeletePCConfirm(pc)}
                            className="text-white/40 hover:text-[#F08A4B] p-1"
                            title="Hapus PC"
                          >
                            <Trash2 className="w-4 h-4" />
                          </button>
                        </div>
                      </div>

                      {/* Specs Box */}
                      <div className="bg-[#1B241F] rounded-2xl p-3 space-y-2 border border-[#233027]/60 text-xs">
                        <div className="flex items-center justify-between">
                          <span className="text-white/50 flex items-center gap-1.5">
                            <Cpu className="w-3.5 h-3.5 text-white/40" />
                            Prosesor
                          </span>
                          <span className="font-semibold text-white">{pc.processor}</span>
                        </div>
                        <div className="flex items-center justify-between">
                          <span className="text-white/50 flex items-center gap-1.5">
                            <HardDrive className="w-3.5 h-3.5 text-white/40" />
                            RAM
                          </span>
                          <span className="font-semibold text-[#E8E48C]">{pc.ram}</span>
                        </div>
                        {pc.notes && (
                          <div className="pt-1.5 border-t border-[#233027] text-[11px] text-white/60">
                            Catatan: {pc.notes}
                          </div>
                        )}
                      </div>

                      {/* Toggle status button */}
                      <button
                        onClick={() => {
                          lab.togglePCStatus(pc.id);
                          showToast(
                            isNormal
                              ? `${pc.pcNumber} ditandai sebagai Rusak`
                              : `${pc.pcNumber} ditandai kembali Normal!`,
                            isNormal
                          );
                        }}
                        className={`w-full py-2 rounded-xl text-xs font-bold transition flex items-center justify-center gap-1.5 ${
                          isNormal
                            ? 'bg-[#F08A4B]/15 text-[#F08A4B] border border-[#F08A4B]/30 hover:bg-[#F08A4B]/25'
                            : 'bg-[#A8E6D8]/15 text-[#A8E6D8] border border-[#A8E6D8]/30 hover:bg-[#A8E6D8]/25'
                        }`}
                      >
                        {isNormal ? (
                          <>
                            <AlertTriangle className="w-3.5 h-3.5" />
                            Tandai Sebagai Rusak
                          </>
                        ) : (
                          <>
                            <CheckCircle2 className="w-3.5 h-3.5" />
                            Tandai Normal (Siap Pakai)
                          </>
                        )}
                      </button>
                    </div>
                  );
                })}

                {filteredPCs.length === 0 && (
                  <div className="text-center py-12 px-4 bg-[#151B17]/40 border border-dashed border-[#233027] rounded-3xl">
                    <Monitor className="w-10 h-10 text-white/20 mx-auto mb-2" />
                    <p className="text-xs text-white/50">Tidak ada unit PC pada filter ini</p>
                    <button
                      onClick={() => handleOpenPCForm()}
                      className="mt-3 px-4 py-2 rounded-xl bg-[#A8E6D8]/15 text-[#A8E6D8] text-xs font-bold hover:bg-[#A8E6D8]/25 transition"
                    >
                      + Tambah Unit PC
                    </button>
                  </div>
                )}
              </div>
            </div>
          )}

          {/* MENU 3: INVENTARIS PENDUKUNG LAB */}
          {tab === 2 && (
            <div className="space-y-4 animate-in fade-in duration-300">
              <div className="text-center">
                <h2 className="text-xl font-bold text-white">Inventaris Pendukung Lab</h2>
              </div>

              {/* Segmented Filter */}
              <div className="bg-[#1B241F] p-1 rounded-2xl flex border border-[#233027]">
                {(['Semua', 'Baik', 'Cek/Rusak'] as const).map((mode) => (
                  <button
                    key={mode}
                    onClick={() => setSupportFilter(mode)}
                    className={`flex-1 py-2 text-xs font-bold rounded-xl transition ${
                      supportFilter === mode ? 'bg-[#E8E48C] text-[#0A0F0B] shadow' : 'text-white/60'
                    }`}
                  >
                    {mode}
                  </button>
                ))}
              </div>

              {/* Summary Counter */}
              <div className="bg-[#151B17] border border-[#233027] rounded-2xl p-4 flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-xl bg-[#E8E48C]/10 text-[#E8E48C] flex items-center justify-center">
                    <Server className="w-5 h-5" />
                  </div>
                  <div>
                    <span className="text-[11px] text-white/50">Total Inventaris Pendukung</span>
                    <div className="text-base font-bold text-white mt-0.5">
                      {totalSupportQty} Unit ({goodSupportQty} Baik)
                    </div>
                  </div>
                </div>
                <button
                  onClick={() => handleOpenSupportForm()}
                  className="px-3.5 py-2 bg-[#E8E48C] text-[#0A0F0B] font-bold text-xs rounded-xl hover:bg-[#E8E48C]/90 transition"
                >
                  + Tambah
                </button>
              </div>

              {/* Action Bar */}
              <div className="flex items-center justify-between pt-1">
                <span className="text-xs font-bold text-white/70">
                  Daftar Perangkat ({filteredSupports.length})
                </span>
              </div>

              {/* Support Items Cards */}
              <div className="space-y-3">
                {filteredSupports.map((item) => {
                  const col =
                    item.condition === 'Baik'
                      ? '#A8E6D8'
                      : item.condition === 'Perlu Cek'
                      ? '#E8E48C'
                      : '#F08A4B';

                  return (
                    <div
                      key={item.id}
                      className="bg-[#151B17] border border-[#233027] rounded-3xl p-4 shadow-md space-y-3"
                    >
                      <div className="flex items-center justify-between">
                        <div className="flex items-center gap-3">
                          <div
                            className="w-10 h-10 rounded-2xl flex items-center justify-center font-bold text-sm shrink-0 border"
                            style={{
                              backgroundColor: `${col}15`,
                              borderColor: `${col}35`,
                              color: col,
                            }}
                          >
                            {item.qty}
                          </div>
                          <div>
                            <h4 className="text-sm font-bold text-white">{item.name}</h4>
                            {item.location && (
                              <p className="text-[11px] text-white/50 flex items-center gap-1 mt-0.5">
                                <MapPin className="w-3 h-3" />
                                {item.location}
                              </p>
                            )}
                          </div>
                        </div>

                        <div className="flex items-center gap-1">
                          <span
                            className="text-[10px] font-bold px-2 py-0.5 rounded-full mr-1"
                            style={{
                              backgroundColor: `${col}18`,
                              color: col,
                              border: `1px solid ${col}30`,
                            }}
                          >
                            {item.condition}
                          </span>
                          <button
                            onClick={() => handleOpenSupportForm(item)}
                            className="text-white/40 hover:text-white p-1"
                          >
                            <Edit2 className="w-4 h-4" />
                          </button>
                          <button
                            onClick={() => setDeleteSupportConfirm(item)}
                            className="text-white/40 hover:text-[#F08A4B] p-1"
                          >
                            <Trash2 className="w-4 h-4" />
                          </button>
                        </div>
                      </div>

                      {/* Quick Quantity Adjuster Row */}
                      <div className="bg-[#1B241F] rounded-xl px-3 py-2 flex items-center justify-between text-xs">
                        <span className="text-white/50">Kuantitas Unit:</span>
                        <div className="flex items-center gap-3">
                          <button
                            onClick={() => lab.updateSupportQty(item.id, -1)}
                            className="w-7 h-7 rounded-lg bg-[#151B17] text-white/70 hover:text-white flex items-center justify-center font-bold"
                          >
                            -
                          </button>
                          <span className="font-bold text-white w-8 text-center">{item.qty}</span>
                          <button
                            onClick={() => lab.updateSupportQty(item.id, 1)}
                            className="w-7 h-7 rounded-lg bg-[#A8E6D8]/20 text-[#A8E6D8] hover:bg-[#A8E6D8]/30 flex items-center justify-center font-bold"
                          >
                            +
                          </button>
                        </div>
                      </div>
                    </div>
                  );
                })}

                {filteredSupports.length === 0 && (
                  <div className="text-center py-12 px-4 bg-[#151B17]/40 border border-dashed border-[#233027] rounded-3xl">
                    <Server className="w-10 h-10 text-white/20 mx-auto mb-2" />
                    <p className="text-xs text-white/50">Belum ada alat pendukung pada filter ini</p>
                    <button
                      onClick={() => handleOpenSupportForm()}
                      className="mt-3 px-4 py-2 rounded-xl bg-[#E8E48C]/15 text-[#E8E48C] text-xs font-bold hover:bg-[#E8E48C]/25 transition"
                    >
                      + Tambah Alat Pendukung
                    </button>
                  </div>
                )}
              </div>
            </div>
          )}

          {/* MENU 4: LOG RIWAYAT PERBAIKAN */}
          {tab === 3 && (
            <div className="space-y-4 animate-in fade-in duration-300">
              <div className="text-center">
                <h2 className="text-xl font-bold text-white">Log Riwayat Perbaikan</h2>
              </div>

              {/* Log Stats Card */}
              <div className="bg-[#151B17] border border-[#233027] rounded-2xl p-4 flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-xl bg-[#E3B8F5]/10 text-[#E3B8F5] flex items-center justify-center">
                    <Wrench className="w-5 h-5" />
                  </div>
                  <div>
                    <span className="text-[11px] text-white/50">Total Tindakan Servis</span>
                    <div className="text-base font-bold text-white mt-0.5">
                      {lab.log_box.length} Log Tersimpan
                    </div>
                  </div>
                </div>
                <button
                  onClick={() => {
                    setLogTarget('');
                    setLogIssue('');
                    setLogAction('');
                    setLogTech('');
                    setLogModalOpen(true);
                  }}
                  className="px-3.5 py-2 bg-[#E3B8F5] text-[#0A0F0B] font-bold text-xs rounded-xl hover:bg-[#E3B8F5]/90 transition"
                >
                  + Catat Servis
                </button>
              </div>

              {/* Action Bar */}
              <div className="flex items-center justify-between pt-1">
                <span className="text-xs font-bold text-white/70">Riwayat Tindakan Terbaru</span>
              </div>

              {/* Log Cards */}
              <div className="space-y-3">
                {lab.log_box.map((item) => (
                  <div
                    key={item.id}
                    className="bg-[#151B17] border border-[#233027] rounded-3xl p-4 shadow-md space-y-2.5"
                  >
                    <div className="flex items-center justify-between">
                      <div className="flex items-center gap-2">
                        <span className="px-2.5 py-0.5 rounded-lg bg-[#E3B8F5]/15 text-[#E3B8F5] border border-[#E3B8F5]/30 text-xs font-bold flex items-center gap-1.5">
                          <Wrench className="w-3 h-3" />
                          {item.target}
                        </span>
                        <span className="text-[11px] text-white/40">{fdt(item.createdAt)}</span>
                      </div>
                      <button
                        onClick={() => setDeleteLogConfirm(item)}
                        className="text-white/40 hover:text-[#F08A4B] p-1"
                      >
                        <Trash2 className="w-4 h-4" />
                      </button>
                    </div>

                    {/* Problem */}
                    <div className="flex items-start gap-2 text-xs">
                      <AlertTriangle className="w-3.5 h-3.5 text-[#F08A4B] shrink-0 mt-0.5" />
                      <div>
                        <span className="text-white/50 block text-[10px]">Gejala Kerusakan:</span>
                        <span className="font-semibold text-white">{item.issue}</span>
                      </div>
                    </div>

                    {/* Solution Action */}
                    <div className="bg-[#1B241F] rounded-2xl p-3 border border-[#233027]/50 text-xs space-y-1.5">
                      <div className="flex items-center gap-1.5 text-[#A8E6D8] font-bold text-[11px]">
                        <CheckCircle2 className="w-3.5 h-3.5" />
                        Tindakan Solusi:
                      </div>
                      <p className="text-white/80 leading-relaxed text-[11px]">{item.action}</p>
                      <div className="pt-1 flex items-center gap-1.5 text-white/40 text-[10px] font-mono">
                        <User className="w-3 h-3" />
                        Teknisi: {item.technician}
                      </div>
                    </div>
                  </div>
                ))}

                {lab.log_box.length === 0 && (
                  <div className="text-center py-12 px-4 bg-[#151B17]/40 border border-dashed border-[#233027] rounded-3xl">
                    <Wrench className="w-10 h-10 text-white/20 mx-auto mb-2" />
                    <p className="text-xs text-white/50">Belum ada log perbaikan yang dicatat</p>
                  </div>
                )}
              </div>
            </div>
          )}
        </main>

        {/* BOTTOM NAVIGATION BAR */}
        <nav className="fixed bottom-4 left-0 right-0 z-40 flex justify-center px-4 pointer-events-none">
          <div className="pointer-events-auto w-full max-w-md bg-[#131915]/90 backdrop-blur-xl border border-[#A8E6D8]/25 rounded-[32px] p-1.5 shadow-2xl flex items-center justify-around relative">
            {/* Sliding Pill Indicator */}
            <div
              className="absolute top-1.5 bottom-1.5 w-[22%] bg-[#A8E6D8]/15 border border-[#A8E6D8] rounded-[24px] shadow-[0_0_12px_rgba(168,230,216,0.3)] transition-all duration-300 ease-out"
              style={{ left: `${tab * 25 + 1.5}%` }}
            />

            {[
              { id: 0, label: 'Beranda', icon: LayoutDashboard },
              { id: 1, label: 'PC Lab', icon: Monitor },
              { id: 2, label: 'Pendukung', icon: Server },
              { id: 3, label: 'Log Servis', icon: Wrench },
            ].map((item) => {
              const Icon = item.icon;
              const isActive = tab === item.id;
              return (
                <button
                  key={item.id}
                  onClick={() => setTab(item.id)}
                  className={`w-1/4 py-2 flex flex-col items-center justify-center relative z-10 transition-transform ${
                    isActive ? 'scale-110' : 'opacity-60 hover:opacity-100'
                  }`}
                  title={item.label}
                >
                  <Icon className={`w-5 h-5 ${isActive ? 'text-[#A8E6D8]' : 'text-white/60'}`} />
                  <span
                    className={`text-[9px] font-bold mt-0.5 ${
                      isActive ? 'text-[#A8E6D8]' : 'text-white/40'
                    }`}
                  >
                    {item.label}
                  </span>
                </button>
              );
            })}
          </div>
        </nav>

        {/* MODAL: FORM PC */}
        {pcModalOpen && (
          <div className="fixed inset-0 z-50 bg-black/80 backdrop-blur-sm flex items-end justify-center p-0 md:p-4">
            <div className="w-full max-w-md bg-[#151B17] border-t md:border border-[#233027] rounded-t-[32px] md:rounded-[32px] p-6 space-y-4 max-h-[90vh] overflow-y-auto">
              <div className="w-12 h-1 bg-white/20 rounded-full mx-auto" />
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <Monitor className="w-5 h-5 text-[#A8E6D8]" />
                  <h3 className="text-lg font-bold text-white">
                    {editingPC ? 'Edit Spesifikasi PC' : 'Tambah Unit PC Baru'}
                  </h3>
                </div>
                <button onClick={() => setPcModalOpen(false)} className="text-white/40 hover:text-white">
                  <X className="w-5 h-5" />
                </button>
              </div>

              <div>
                <label className="text-xs text-white/60 block mb-1">Nomor / Label PC</label>
                <input
                  type="text"
                  placeholder="Contoh: PC-01"
                  value={pcNum}
                  onChange={(e) => setPcNum(e.target.value)}
                  className="w-full bg-[#0E1410] border border-[#233027] rounded-xl px-3.5 py-2.5 text-white text-sm focus:border-[#A8E6D8] focus:outline-none"
                />
              </div>

              <div>
                <label className="text-xs text-white/60 block mb-1">Tipe Prosesor</label>
                <input
                  type="text"
                  placeholder="Intel Core i5-12400"
                  value={pcProc}
                  onChange={(e) => setPcProc(e.target.value)}
                  className="w-full bg-[#0E1410] border border-[#233027] rounded-xl px-3.5 py-2.5 text-white text-sm focus:border-[#A8E6D8] focus:outline-none"
                />
                <div className="flex flex-wrap gap-1.5 mt-2">
                  {['Core i5-12400', 'Core i7-13700', 'Ryzen 5 5600G', 'Core i3-12100'].map((p) => (
                    <button
                      key={p}
                      type="button"
                      onClick={() => setPcProc(p)}
                      className="px-2.5 py-1 rounded-lg bg-[#A8E6D8]/10 text-[#A8E6D8] border border-[#A8E6D8]/20 text-[11px] font-semibold hover:bg-[#A8E6D8]/20"
                    >
                      {p}
                    </button>
                  ))}
                </div>
              </div>

              <div>
                <label className="text-xs text-white/60 block mb-1">Kapasitas RAM</label>
                <input
                  type="text"
                  placeholder="16 GB DDR4"
                  value={pcRam}
                  onChange={(e) => setPcRam(e.target.value)}
                  className="w-full bg-[#0E1410] border border-[#233027] rounded-xl px-3.5 py-2.5 text-white text-sm focus:border-[#A8E6D8] focus:outline-none"
                />
                <div className="flex gap-2 mt-2">
                  {['8 GB DDR4', '16 GB DDR4', '32 GB DDR4', '16 GB DDR5'].map((r) => (
                    <button
                      key={r}
                      type="button"
                      onClick={() => setPcRam(r)}
                      className="px-2 py-1 rounded-lg bg-[#E8E48C]/10 text-[#E8E48C] border border-[#E8E48C]/20 text-[11px] font-semibold hover:bg-[#E8E48C]/20"
                    >
                      {r}
                    </button>
                  ))}
                </div>
              </div>

              <div>
                <label className="text-xs text-white/60 block mb-1.5">Status Operasional Unit</label>
                <div className="grid grid-cols-2 gap-3">
                  <button
                    type="button"
                    onClick={() => setPcStatus('Normal')}
                    className={`py-2.5 rounded-xl text-xs font-bold transition flex items-center justify-center gap-1.5 border ${
                      pcStatus === 'Normal'
                        ? 'bg-[#A8E6D8]/20 text-[#A8E6D8] border-[#A8E6D8]'
                        : 'bg-[#1B241F] text-white/50 border-[#233027]'
                    }`}
                  >
                    <CheckCircle2 className="w-4 h-4" />
                    Normal (Siap Pakai)
                  </button>
                  <button
                    type="button"
                    onClick={() => setPcStatus('Rusak')}
                    className={`py-2.5 rounded-xl text-xs font-bold transition flex items-center justify-center gap-1.5 border ${
                      pcStatus === 'Rusak'
                        ? 'bg-[#F08A4B]/20 text-[#F08A4B] border-[#F08A4B]'
                        : 'bg-[#1B241F] text-white/50 border-[#233027]'
                    }`}
                  >
                    <AlertTriangle className="w-4 h-4" />
                    Rusak / Kendala
                  </button>
                </div>
              </div>

              <div>
                <label className="text-xs text-white/60 block mb-1">Catatan Tambahan (Opsional)</label>
                <input
                  type="text"
                  placeholder="Contoh: Baris meja kiri depan"
                  value={pcNotes}
                  onChange={(e) => setPcNotes(e.target.value)}
                  className="w-full bg-[#0E1410] border border-[#233027] rounded-xl px-3.5 py-2.5 text-white text-xs focus:border-[#A8E6D8] focus:outline-none"
                />
              </div>

              <div className="pt-2">
                <button
                  onClick={() => {
                    if (!pcNum.trim()) {
                      showToast('Nomor / Label PC wajib diisi', true);
                      return;
                    }
                    lab.savePC({
                      id: editingPC ? editingPC.id : 'pc_' + Date.now(),
                      pcNumber: pcNum.trim(),
                      processor: pcProc.trim() || 'Intel Core i5',
                      ram: pcRam.trim() || '16 GB',
                      status: pcStatus,
                      notes: pcNotes.trim() || undefined,
                    });
                    setPcModalOpen(false);
                    showToast(`${pcNum} berhasil disimpan ke pc_box!`);
                  }}
                  className="w-full py-3 bg-[#A8E6D8] text-[#0A0F0B] font-bold text-sm rounded-2xl hover:bg-[#A8E6D8]/90 transition"
                >
                  {editingPC ? 'Perbarui Data PC' : 'Simpan'}
                </button>
              </div>
            </div>
          </div>
        )}

        {/* MODAL: FORM SUPPORT ITEM */}
        {supportModalOpen && (
          <div className="fixed inset-0 z-50 bg-black/80 backdrop-blur-sm flex items-end justify-center p-0 md:p-4">
            <div className="w-full max-w-md bg-[#151B17] border-t md:border border-[#233027] rounded-t-[32px] md:rounded-[32px] p-6 space-y-4 max-h-[90vh] overflow-y-auto">
              <div className="w-12 h-1 bg-white/20 rounded-full mx-auto" />
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <Server className="w-5 h-5 text-[#E8E48C]" />
                  <h3 className="text-lg font-bold text-white">
                    {editingSupport ? 'Edit Alat Pendukung' : 'Tambah Inventaris Pendukung'}
                  </h3>
                </div>
                <button onClick={() => setSupportModalOpen(false)} className="text-white/40 hover:text-white">
                  <X className="w-5 h-5" />
                </button>
              </div>

              <div>
                <label className="text-xs text-white/60 block mb-1">Nama Barang Non-PC</label>
                <input
                  type="text"
                  placeholder="Contoh: Switch Gigabit 24-Port"
                  value={supName}
                  onChange={(e) => setSupName(e.target.value)}
                  className="w-full bg-[#0E1410] border border-[#233027] rounded-xl px-3.5 py-2.5 text-white text-sm focus:border-[#E8E48C] focus:outline-none"
                />
                <div className="flex flex-wrap gap-1.5 mt-2">
                  {['Switch Hub 24-Port', 'Proyektor HDMI', 'UPS 1200VA', 'Kabel LAN Cat6 50M', 'Crimping Tool'].map((preset) => (
                    <button
                      key={preset}
                      type="button"
                      onClick={() => setSupName(preset)}
                      className="px-2 py-0.5 rounded-lg bg-[#E8E48C]/10 text-[#E8E48C] border border-[#E8E48C]/20 text-[10px] font-semibold hover:bg-[#E8E48C]/20"
                    >
                      {preset}
                    </button>
                  ))}
                </div>
              </div>

              <div>
                <label className="text-xs text-white/60 block mb-1">Jumlah Unit</label>
                <input
                  type="number"
                  value={supQty}
                  onChange={(e) => setSupQty(e.target.value)}
                  className="w-full bg-[#0E1410] border border-[#233027] rounded-xl px-3.5 py-2.5 text-white text-sm focus:border-[#E8E48C] focus:outline-none"
                />
                <div className="flex gap-2 mt-2">
                  {[1, 5, 10].map((v) => (
                    <button
                      key={v}
                      type="button"
                      onClick={() => setSupQty(String((parseInt(supQty || '0', 10) || 0) + v))}
                      className="px-2.5 py-1 rounded-lg bg-[#A8E6D8]/10 text-[#A8E6D8] border border-[#A8E6D8]/20 text-xs font-bold hover:bg-[#A8E6D8]/20"
                    >
                      +{v}
                    </button>
                  ))}
                </div>
              </div>

              <div>
                <label className="text-xs text-white/60 block mb-1.5">Kondisi Barang</label>
                <div className="grid grid-cols-3 gap-2">
                  {(['Baik', 'Perlu Cek', 'Rusak'] as const).map((cond) => {
                    const isSel = supCondition === cond;
                    const col = cond === 'Baik' ? '#A8E6D8' : cond === 'Perlu Cek' ? '#E8E48C' : '#F08A4B';
                    return (
                      <button
                        key={cond}
                        type="button"
                        onClick={() => setSupCondition(cond)}
                        className="py-2.5 rounded-xl text-xs font-bold border transition"
                        style={{
                          backgroundColor: isSel ? `${col}20` : '#1B241F',
                          borderColor: isSel ? col : '#233027',
                          color: isSel ? col : 'rgba(255,255,255,0.6)',
                        }}
                      >
                        {cond}
                      </button>
                    );
                  })}
                </div>
              </div>

              <div>
                <label className="text-xs text-white/60 block mb-1">Lokasi / Tempat Simpan (Opsional)</label>
                <input
                  type="text"
                  placeholder="Contoh: Rak Server Utama / Meja Instruktur"
                  value={supLocation}
                  onChange={(e) => setSupLocation(e.target.value)}
                  className="w-full bg-[#0E1410] border border-[#233027] rounded-xl px-3.5 py-2.5 text-white text-xs focus:border-[#E8E48C] focus:outline-none"
                />
              </div>

              <div className="pt-2">
                <button
                  onClick={() => {
                    if (!supName.trim()) {
                      showToast('Nama barang wajib diisi', true);
                      return;
                    }
                    const q = Math.max(1, parseInt(supQty || '1', 10) || 1);
                    lab.saveSupportItem({
                      id: editingSupport ? editingSupport.id : 'sup_' + Date.now(),
                      name: supName.trim(),
                      qty: q,
                      condition: supCondition,
                      location: supLocation.trim() || undefined,
                    });
                    setSupportModalOpen(false);
                    showToast(`${supName} (${q} unit) disimpan ke support_box`);
                  }}
                  className="w-full py-3 bg-[#E8E48C] text-[#0A0F0B] font-bold text-sm rounded-2xl hover:bg-[#E8E48C]/90 transition"
                >
                  {editingSupport ? 'Perbarui Barang' : 'Simpan'}
                </button>
              </div>
            </div>
          </div>
        )}

        {/* MODAL: FORM REPAIR LOG */}
        {logModalOpen && (
          <div className="fixed inset-0 z-50 bg-black/80 backdrop-blur-sm flex items-end justify-center p-0 md:p-4">
            <div className="w-full max-w-md bg-[#151B17] border-t md:border border-[#233027] rounded-t-[32px] md:rounded-[32px] p-6 space-y-4 max-h-[90vh] overflow-y-auto">
              <div className="w-12 h-1 bg-white/20 rounded-full mx-auto" />
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <Wrench className="w-5 h-5 text-[#E3B8F5]" />
                  <h3 className="text-lg font-bold text-white">Catat Riwayat Perbaikan</h3>
                </div>
                <button onClick={() => setLogModalOpen(false)} className="text-white/40 hover:text-white">
                  <X className="w-5 h-5" />
                </button>
              </div>

              <div>
                <label className="text-xs text-white/60 block mb-1">Target PC / Alat</label>
                <input
                  type="text"
                  placeholder="Contoh: PC-04"
                  value={logTarget}
                  onChange={(e) => setLogTarget(e.target.value)}
                  className="w-full bg-[#0E1410] border border-[#233027] rounded-xl px-3.5 py-2.5 text-white text-sm focus:border-[#E3B8F5] focus:outline-none"
                />
                {lab.pc_box.length > 0 && (
                  <div className="flex flex-wrap gap-1.5 mt-2">
                    {lab.pc_box.map((p) => (
                      <button
                        key={p.id}
                        type="button"
                        onClick={() => setLogTarget(p.pcNumber)}
                        className="px-2 py-0.5 rounded-lg bg-[#E3B8F5]/10 text-[#E3B8F5] border border-[#E3B8F5]/20 text-[10px] font-semibold hover:bg-[#E3B8F5]/20"
                      >
                        {p.pcNumber}
                      </button>
                    ))}
                  </div>
                )}
              </div>

              <div>
                <label className="text-xs text-white/60 block mb-1">Jenis Kerusakan / Gejala</label>
                <input
                  type="text"
                  placeholder="Contoh: Blue screen saat render / PSU mati"
                  value={logIssue}
                  onChange={(e) => setLogIssue(e.target.value)}
                  className="w-full bg-[#0E1410] border border-[#233027] rounded-xl px-3.5 py-2.5 text-white text-sm focus:border-[#E3B8F5] focus:outline-none"
                />
              </div>

              <div>
                <label className="text-xs text-white/60 block mb-1">Tindakan Perbaikan / Solusi</label>
                <input
                  type="text"
                  placeholder="Contoh: Ganti power supply 450W & uji beban 1 jam"
                  value={logAction}
                  onChange={(e) => setLogAction(e.target.value)}
                  className="w-full bg-[#0E1410] border border-[#233027] rounded-xl px-3.5 py-2.5 text-white text-sm focus:border-[#E3B8F5] focus:outline-none"
                />
              </div>

              <div>
                <label className="text-xs text-white/60 block mb-1">Nama Teknisi Penanggung Jawab</label>
                <input
                  type="text"
                  placeholder="Nama teknisi"
                  value={logTech}
                  onChange={(e) => setLogTech(e.target.value)}
                  className="w-full bg-[#0E1410] border border-[#233027] rounded-xl px-3.5 py-2.5 text-white text-sm focus:border-[#E3B8F5] focus:outline-none"
                />
              </div>

              <div className="pt-2">
                <button
                  onClick={() => {
                    if (!logTarget.trim() || !logIssue.trim() || !logAction.trim()) {
                      showToast('Lengkapi target, masalah, dan tindakan perbaikan', true);
                      return;
                    }
                    lab.saveRepairLog({
                      target: logTarget.trim(),
                      issue: logIssue.trim(),
                      action: logAction.trim(),
                      technician: logTech.trim() || 'Teknisi Lab',
                    });
                    setLogModalOpen(false);
                    showToast(`Log perbaikan ${logTarget} berhasil disimpan ke log_box!`);
                  }}
                  className="w-full py-3 bg-[#E3B8F5] text-[#0A0F0B] font-bold text-sm rounded-2xl hover:bg-[#E3B8F5]/90 transition"
                >
                  Simpan
                </button>
              </div>
            </div>
          </div>
        )}

        {/* MODAL: NOTIFICATIONS */}
        {notificationOpen && (
          <div className="fixed inset-0 z-50 bg-black/80 backdrop-blur-sm flex items-end justify-center p-0 md:p-4">
            <div className="w-full max-w-md bg-[#151B17] border-t md:border border-[#233027] rounded-t-[32px] md:rounded-[32px] p-6 space-y-4 max-h-[85vh] overflow-y-auto">
              <div className="w-12 h-1 bg-white/20 rounded-full mx-auto" />
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <Bell className="w-5 h-5 text-[#A8E6D8]" />
                  <h3 className="text-lg font-bold text-white">Status Lab &amp; Alarm</h3>
                </div>
                <button onClick={() => setNotificationOpen(false)} className="text-white/40 hover:text-white">
                  <X className="w-5 h-5" />
                </button>
              </div>

              {!hasIssues ? (
                <div className="text-center py-8 space-y-2">
                  <CheckCircle2 className="w-12 h-12 text-[#A8E6D8] mx-auto opacity-80" />
                  <h4 className="text-sm font-bold text-white/80">Semua Unit Lab Siap Pakai</h4>
                  <p className="text-xs text-white/40">Seluruh PC dan inventaris dalam kondisi normal.</p>
                </div>
              ) : (
                <div className="space-y-2.5">
                  {lab.pc_box
                    .filter((p) => p.status === 'Rusak')
                    .map((p) => (
                      <div
                        key={p.id}
                        className="p-3.5 rounded-2xl bg-[#1B241F] border border-[#F08A4B]/30 flex items-start gap-3"
                      >
                        <AlertTriangle className="w-4 h-4 text-[#F08A4B] shrink-0 mt-0.5" />
                        <div>
                          <p className="text-xs font-bold text-white">{p.pcNumber} dalam Kondisi Rusak</p>
                          <p className="text-[11px] text-white/60 mt-0.5">
                            {p.notes || `Spesifikasi: ${p.processor}, ${p.ram}. Perlu tindakan teknisi.`}
                          </p>
                        </div>
                      </div>
                    ))}

                  {lab.support_box
                    .filter((s) => s.condition !== 'Baik')
                    .map((s) => (
                      <div
                        key={s.id}
                        className="p-3.5 rounded-2xl bg-[#1B241F] border border-[#E8E48C]/30 flex items-start gap-3"
                      >
                        <AlertTriangle className="w-4 h-4 text-[#E8E48C] shrink-0 mt-0.5" />
                        <div>
                          <p className="text-xs font-bold text-white">
                            {s.name} ({s.condition})
                          </p>
                          <p className="text-[11px] text-white/60 mt-0.5">
                            Lokasi: {s.location || 'Laboratorium'}. Kuantitas: {s.qty} unit.
                          </p>
                        </div>
                      </div>
                    ))}
                </div>
              )}

              <button
                onClick={() => setNotificationOpen(false)}
                className="w-full py-3 bg-[#A8E6D8]/15 text-[#A8E6D8] font-bold text-sm rounded-2xl hover:bg-[#A8E6D8]/25 transition"
              >
                Tutup
              </button>
            </div>
          </div>
        )}

        {/* MODAL: DELETE PC */}
        {deletePCConfirm && (
          <div className="fixed inset-0 z-50 bg-black/80 backdrop-blur-sm flex items-center justify-center p-4">
            <div className="w-full max-w-sm bg-[#151B17] border border-[#233027] rounded-3xl p-5 space-y-4">
              <h3 className="text-lg font-bold text-white">Hapus Data PC?</h3>
              <p className="text-xs text-white/70 leading-relaxed">
                Unit &ldquo;{deletePCConfirm.pcNumber}&rdquo; ({deletePCConfirm.processor}) akan dihapus
                secara permanen dari pc_box.
              </p>
              <div className="flex gap-2 justify-end pt-2">
                <button
                  onClick={() => setDeletePCConfirm(null)}
                  className="px-4 py-2 text-xs font-semibold text-white/60 hover:text-white"
                >
                  Batal
                </button>
                <button
                  onClick={() => {
                    lab.deletePC(deletePCConfirm.id);
                    showToast(`${deletePCConfirm.pcNumber} dihapus dari pc_box`);
                    setDeletePCConfirm(null);
                  }}
                  className="px-4 py-2 rounded-xl bg-[#F08A4B] text-[#0A0F0B] text-xs font-bold hover:bg-[#F08A4B]/90 transition"
                >
                  Hapus
                </button>
              </div>
            </div>
          </div>
        )}

        {/* MODAL: DELETE SUPPORT */}
        {deleteSupportConfirm && (
          <div className="fixed inset-0 z-50 bg-black/80 backdrop-blur-sm flex items-center justify-center p-4">
            <div className="w-full max-w-sm bg-[#151B17] border border-[#233027] rounded-3xl p-5 space-y-4">
              <h3 className="text-lg font-bold text-white">Hapus Alat Pendukung?</h3>
              <p className="text-xs text-white/70 leading-relaxed">
                Barang &ldquo;{deleteSupportConfirm.name}&rdquo; ({deleteSupportConfirm.qty} unit) akan
                dihapus dari support_box.
              </p>
              <div className="flex gap-2 justify-end pt-2">
                <button
                  onClick={() => setDeleteSupportConfirm(null)}
                  className="px-4 py-2 text-xs font-semibold text-white/60 hover:text-white"
                >
                  Batal
                </button>
                <button
                  onClick={() => {
                    lab.deleteSupportItem(deleteSupportConfirm.id);
                    showToast(`${deleteSupportConfirm.name} dihapus dari support_box`);
                    setDeleteSupportConfirm(null);
                  }}
                  className="px-4 py-2 rounded-xl bg-[#F08A4B] text-[#0A0F0B] text-xs font-bold hover:bg-[#F08A4B]/90 transition"
                >
                  Hapus
                </button>
              </div>
            </div>
          </div>
        )}

        {/* MODAL: DELETE LOG */}
        {deleteLogConfirm && (
          <div className="fixed inset-0 z-50 bg-black/80 backdrop-blur-sm flex items-center justify-center p-4">
            <div className="w-full max-w-sm bg-[#151B17] border border-[#233027] rounded-3xl p-5 space-y-4">
              <h3 className="text-lg font-bold text-white">Hapus Log Perbaikan?</h3>
              <p className="text-xs text-white/70 leading-relaxed">
                Catatan servis untuk {deleteLogConfirm.target} pada {fdt(deleteLogConfirm.createdAt)} akan
                dihapus dari log_box.
              </p>
              <div className="flex gap-2 justify-end pt-2">
                <button
                  onClick={() => setDeleteLogConfirm(null)}
                  className="px-4 py-2 text-xs font-semibold text-white/60 hover:text-white"
                >
                  Batal
                </button>
                <button
                  onClick={() => {
                    lab.deleteRepairLog(deleteLogConfirm.id);
                    showToast('Log perbaikan dihapus');
                    setDeleteLogConfirm(null);
                  }}
                  className="px-4 py-2 rounded-xl bg-[#F08A4B] text-[#0A0F0B] text-xs font-bold hover:bg-[#F08A4B]/90 transition"
                >
                  Hapus
                </button>
              </div>
            </div>
          </div>
        )}

        {/* TOAST NOTIFICATION */}
        {toast && (
          <div className="fixed top-20 left-1/2 transform -translate-x-1/2 z-50 max-w-sm w-[90%] pointer-events-none">
            <div
              className={`p-3.5 rounded-2xl border shadow-2xl flex items-center gap-3 backdrop-blur-md animate-in slide-in-from-top-4 duration-200 ${
                toast.isError
                  ? 'bg-[#1B241F] border-[#F08A4B]/40 text-[#F08A4B]'
                  : 'bg-[#1B241F] border-[#A8E6D8]/40 text-[#A8E6D8]'
              }`}
            >
              {toast.isError ? (
                <AlertTriangle className="w-4 h-4 shrink-0" />
              ) : (
                <CheckCircle2 className="w-4 h-4 shrink-0" />
              )}
              <span className="text-xs font-semibold text-white">{toast.msg}</span>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}

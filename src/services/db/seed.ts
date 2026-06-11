import Database from '@tauri-apps/plugin-sql'

export type TubeEntry = {
  gauge: number
  color: string
  use: string
  flowRate: string
}

export type IVCompatibility = {
  drugA: string
  drugB: string
  compatible: boolean
  notes: string
}

const TUBES: TubeEntry[] = [
  { gauge: 14, color: 'Naranja', use: 'Cirugía/ trauma', flowRate: '15-30 mL/min' },
  { gauge: 16, color: 'Gris', use: 'UCI, quirófano', flowRate: '10-20 mL/min' },
  { gauge: 18, color: 'Verde', use: 'Quirófano, reanimación', flowRate: '5-10 mL/min' },
  { gauge: 20, color: 'Rosa', use: 'Pediátricos, adultos', flowRate: '3-5 mL/min' },
  { gauge: 22, color: 'Azul', use: 'UCI pediátrica', flowRate: '1-3 mL/min' },
  { gauge: 24, color: 'Amarillo', use: 'Neonatología', flowRate: '0.5-1 mL/min' },
]

const IV_COMPAT: IVCompatibility[] = [
  { drugA: 'Ampicilina', drugB: 'Gentamicina', compatible: true, notes: 'Compatible Y-site' },
  { drugA: 'Dopamina', drugB: 'Furosemida', compatible: false, notes: 'Incompatible — precipita' },
  { drugA: 'Solurol', drugB: 'Cloruro de potasio', compatible: true, notes: 'Concentración < 40 mEq/L' },
  { drugA: 'Fenitoína', drugB: 'D5W', compatible: false, notes: 'Precipita en solución ácida' },
  { drugA: 'Heparina', drugB: 'Warfarina', compatible: true, notes: 'No mezclar en misma línea' },
  { drugA: 'Metoclopramida', drugB: 'Diazepam', compatible: false, notes: 'Incompatible Y-site' },
  { drugA: 'Insulina regular', drugB: 'Glucosado 5%', compatible: true, notes: 'Mezclable en Y-site' },
  { drugA: 'Vancomicina', drugB: 'Furosemida', compatible: true, notes: 'Riesgo de toxicidad renal' },
]

export async function init(db: Database) {
  await db.execute(`
    CREATE TABLE IF NOT EXISTS tubes (
      gauge INTEGER PRIMARY KEY,
      color TEXT NOT NULL,
      use TEXT NOT NULL,
      flowRate TEXT NOT NULL
    )
  `)
  await db.execute(`
    CREATE TABLE IF NOT EXISTS iv_compatibilities (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      drugA TEXT NOT NULL,
      drugB TEXT NOT NULL,
      compatible INTEGER NOT NULL,
      notes TEXT
    )
  `)
  await db.execute(`
    CREATE TABLE IF NOT EXISTS calculations (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      formula TEXT NOT NULL,
      params TEXT NOT NULL,
      result REAL NOT NULL,
      unit TEXT NOT NULL,
      description TEXT,
      createdAt TEXT NOT NULL DEFAULT (datetime('now'))
    )
  `)
}

export async function seed(db: Database) {
  for (const t of TUBES) {
    await db.execute(
      'INSERT OR IGNORE INTO tubes (gauge, color, use, flowRate) VALUES (?,?,?,?)',
      [t.gauge, t.color, t.use, t.flowRate]
    )
  }
  for (const c of IV_COMPAT) {
    await db.execute(
      'INSERT OR IGNORE INTO iv_compatibilities (drugA, drugB, compatible, notes) VALUES (?,?,?,?)',
      [c.drugA, c.drugB, c.compatible ? 1 : 0, c.notes]
    )
  }
}

export async function getTubes(_db: Database) {
  return TUBES
}

export async function getIVCompat(_db: Database) {
  return IV_COMPAT
}

export async function saveCalculation(_db: Database, _row: { formula: string; params: string; result: number; unit: string; description?: string }) {
  // Pendiente: implementar en build Tauri completo
}

export async function getCalculations(_db: Database) {
  // Pendiente: implementar en build Tauri completo
  return []
}

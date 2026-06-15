import Database from '@tauri-apps/plugin-sql'
import { init, seed } from './seed'

let dbInstance: Database | null = null

export async function getDb(): Promise<Database> {
  if (dbInstance) return dbInstance
  dbInstance = await Database.load('sqlite:quicknurse.db')
  await init(dbInstance)
  await seed(dbInstance)
  return dbInstance
}

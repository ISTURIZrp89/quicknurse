import { configureStore } from '@reduxjs/toolkit'
import { persistStore, persistReducer } from 'redux-persist'
import storage from 'redux-persist/lib/storage'
import { combineReducers } from '@reduxjs/toolkit'
import authSlice from './slices/authSlice'
import settingsSlice from './slices/settingsSlice'
import calculatorsSlice from './slices/calculatorsSlice'
import aiSlice from './slices/aiSlice'
import patientsSlice from './slices/patientsSlice'

const persistConfig = {
  key: 'quicknurse',
  version: 1,
  storage,
  whitelist: ['auth', 'settings'],
}

const rootReducer = combineReducers({
  auth: authSlice,
  settings: settingsSlice,
  calculators: calculatorsSlice,
  ai: aiSlice,
  patients: patientsSlice,
})

const persistedReducer = persistReducer(persistConfig, rootReducer)

export const store = configureStore({
  reducer: persistedReducer,
  middleware: (getDefaultMiddleware) =>
    getDefaultMiddleware({
      serializableCheck: {
        ignoredActions: ['persist/PERSIST', 'persist/REHYDRATE'],
      },
    }),
})

export const persistor = persistStore(store)

export type RootState = ReturnType<typeof store.getState>
export type AppDispatch = typeof store.dispatch

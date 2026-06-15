# Ventilación Mecánica (VM) — Conceptos y Manejo

**Fuente**: Mechanical Ventilation (ARDSNet Protocol), SEMICYUC (Sociedad Española de Medicina Intensiva y Unidades Coronarias), Global Weaning Network, ATS/ERS Guidelines

---

## Indicaciones de Ventilación Mecánica

### Indicaciones Generales

| Categoría | Indicación | Criterios |
|-----------|-----------|-----------|
| **Insuficiencia respiratoria hipoxémica** | PaO2 <55 mmHg con FiO2 ≥50% | PaO2/FiO2 <200 |
| **Insuficiencia respiratoria hipercápnica** | PaCO2 >50 mmHg + pH <7.25 | Acidosis respiratoria descompensada |
| **Protección de vía aérea** | Glasgow ≤8, alteración del estado mental | Riesgo de aspiración |
| **Fallo ventilatorio** | FR >35 rpm, fatiga muscular respiratoria | PaCO2 ↑, pH ↓ |
| **Shock refractario** | PAM <65 mmHg a pesar de vasopresores | Necesidad de reducir trabajo respiratorio |

### Indicaciones Específicas

- **ARDS/SDRA**: PaO2/FiO2 <200 + infiltrados bilaterales + presión enclavamiento ≤18 mmHg
- **EPOC exacerbado**: pH <7.25 + PaCO2 >60 mmHg a pesar de tratamiento óptimo
- **Asma severo**: PaCO2 normal o elevado + fatiga muscular
- **TEC severo**: Glasgow ≤8 + necesidad de hiperventilación controlada (evitar PCO2 <30)
- **Post-paro cardíaco**: Protección de vía aérea + control PaCO2

## Modos Ventilatorios

### Clasificación de Modos

#### Control por Volumen (VCV)

```
Configuración: Vt = 6-8 ml/kg, FR = 12-16 rpm, Flujo = 30-60 L/min
Ventaja: Vt garantizado
Desventaja: Presión variable (riesgo de barotrauma)
```

| Parámetro | Descripción |
|-----------|-------------|
| **Vt** (Volumen corriente) | 6-8 ml/kg peso ideal |
| **FR** (Frecuencia respiratoria) | 12-16 rpm (ajustar a PaCO2) |
| **Flujo inspiratorio** | 30-60 L/min |
| **Pausa inspiratoria** | 0.2-0.5 s para medir Plateau |
| **Sensibilidad** | -2 cmH2O (asistido) o 2 L/min (flujo) |

#### Control por Presión (PCV)

```
Configuración: Presión inspiratoria controlada, Tiempo inspiratorio
Ventaja: Presión controlada, menor riesgo barotrauma
Desventaja: Vt variable (depende de compliance y resistencia)
```

| Parámetro | Descripción |
|-----------|-------------|
| **Presión inspiratoria (PC)** | Ajustar para Vt 6-8 ml/kg (típico 10-20 cmH2O) |
| **Tiempo inspiratorio** | 0.8-1.2 s (relación I:E 1:2 a 1:3) |
| **FR** | 12-16 rpm |
| **PEEP** | 5-20 cmH2O (según oxigenación) |

#### SIMV (Sincronized Intermittent Mandatory Ventilation)

```
Configuración: Vt/PC obligatorio + presión soporte espontáneo
Ventaja: Transición de VM a espontáneo
Desventaja: Puede aumentar trabajo respiratorio
```

- **SIMV-VC**: Respiración obligatoria volumétrica + espontáneas con soporte
- **SIMV-PC**: Respiración obligatoria presurizada + espontáneas con soporte
- **Indicación**: Destete o adaptación inicial

#### PSV (Pressure Support Ventilation)

```
Configuración: Presión soporte sobre PEEP
Ventaja: Cómodo, sincronizado, útil para destete
Desventaja: Vt depende del esfuerzo del paciente, no modo seguro en apneas
```

| Parámetro | Descripción |
|-----------|-------------|
| **Presión soporte (PS)** | 5-20 cmH2O (ajustar para Vt 6-8 ml/kg) |
| **PEEP** | 5-8 cmH2O |
| **Sensibilidad** | -1 a -2 cmH2O o 1-2 L/min |
| **Rampa** | 0.1-0.3 s (subida rápida) |

### Otros Modos

| Modo | Descripción | Uso principal |
|------|-------------|---------------|
| **BIPAP/APRV** | Presión alta/baja alternante con espontáneo | SDRA con reclutamiento |
| **CPAP** | Presión positiva continua sin soporte | Destete avanzado, apnea del sueño |
| **PAV** | Asistencia proporcional según compliance | Destete, disminución trabajo respiratorio |
| **NAVA** | Ventilación controlada por señal eléctrica diafragmática | Destete difícil, sincronización óptima |

## Configuración Inicial

### Parámetros Iniciales Recomendados

| Parámetro | Valor inicial | Rango |
|-----------|--------------|-------|
| **Modo** | SIMV-VC o PCV | Según preferencia |
| **Vt** | 6-8 ml/kg peso ideal | 4-8 ml/kg (SDRA: 6 ml/kg) |
| **FR** | 12-16 rpm | 10-24 rpm (ajustar a PaCO2) |
| **PEEP** | 5 cmH2O | 5-20 cmH2O (según FiO2/PEEP tabla) |
| **FiO2** | 1.0 (inicial) | ↓ a 0.4-0.6 lo antes posible |
| **Relación I:E** | 1:2 | 1:1 a 1:4 (SDRA: invertir I:E) |
| **Flujo inspiratorio** | 60 L/min | 30-80 L/min |
| **Sensibilidad** | -2 cmH2O (flujo 2 L/min) | Ajustar según esfuerzo |

### Cálculo de Peso Ideal (PBW)

**Hombres**: PBW (kg) = 50 + 0.91 × (altura en cm - 152.4)
**Mujeres**: PBW (kg) = 45.5 + 0.91 × (altura en cm - 152.4)

### PEEP/FiO2 (Tabla ARDSNet)

| FiO2 | 0.3 | 0.4 | 0.4 | 0.5 | 0.5 | 0.6 | 0.7 | 0.7 | 0.8 | 0.9 | 1.0 |
|------|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|
| PEEP | 5 | 5 | 8 | 8 | 10 | 10 | 10 | 12 | 14 | 14 | 16-24 |

## Monitorización en VM

### Parámetros Esenciales

| Parámetro | Rango normal | Significado de alarma |
|-----------|-------------|----------------------|
| **Vt (volumen corriente)** | 6-8 ml/kg PBW | Bajo: compliance, fuga; Alto: sobrepresión |
| **Volumen minuto (Vm)** | 5-8 L/min | Bajo: hipoventilación; Alto: hiperventilación |
| **Ppeak (presión pico)** | <35 cmH2O | Resistencia de vía aérea, obstrucción, mordida |
| **Pplateau (presión plateau)** | <30 cmH2O (SDRA: <28) | Compliance pulmonar — riesgo barotrauma si >30 |
| **PEEP total** | 5-15 cmH2O | PEEP intrínseca si >3 cmH2O por encima PEEP set |
| **Compliance estática** | 60-100 ml/cmH2O | <30: pulmón rígido (SDRA, fibrosis, edema) |
| **Resistencia** | 5-15 cmH2O/L/s | >20: obstrucción (broncoespasmo, secreciones) |

### Cálculos de Mecánica Pulmonar

**Compliance estática** (Cstat): `Cstat = Vt / (Pplateau - PEEPtotal)` (normal 60-100 ml/cmH2O)

**Resistencia**: `R = (Ppeak - Pplateau) / Flujo` (normal 5-15 cmH2O/L/s)

**Constante de tiempo** (τ): `τ = Compliance × Resistencia` (normal 0.5-1.0 s)

### Gasometría en VM

| Objetivo | Rango |
|----------|-------|
| pH | 7.35-7.45 (permitir hipercapnia permisiva si SDRA: pH >7.25) |
| PaCO2 | 35-45 mmHg (permitir hasta 60 mmHg si SDRA) |
| PaO2 | 55-80 mmHg (SpO2 88-95%) |
| PaO2/FiO2 | >300 (mejorar) |

## Estrategias de Ventilación Protectora

### Ventilación Protectora en SDRA (Basada en ARDSNet)

| Componente | Recomendación |
|-----------|---------------|
| **Volumen corriente** | 6 ml/kg PBW (reducir a 4 ml/kg si Pplateau >30) |
| **Presión plateau** | <30 cmH2O (ideal <28) |
| **PEEP** | Ajustar según tabla PEEP/FiO2 (PEEP alta en SDRA moderado-severo) |
| **Driving pressure** (ΔP = Vt/Cstat) | <15 cmH2O (asociado a menor mortalidad) |
| **Hipercapnia permisiva** | Permitir PaCO2 alta si pH >7.20-7.25 |
| **Maniobras de reclutamiento** | Considerar si hipoxemia severa refractaria |

### SDRA: Clasificación de Berlín (PaO2/FiO2 con PEEP ≥5)

| Severidad | PaO2/FiO2 | Mortalidad |
|-----------|-----------|------------|
| **Leve** | 200-300 | 27% |
| **Moderado** | 100-200 | 32% |
| **Severo** | <100 | 45% |

### Ventilación en Decúbito Prono

| Indicación | Protocolo |
|-----------|-----------|
| PaO2/FiO2 <150 con PEEP ≥10 y FiO2 ≥0.6 | Prono ≥16 horas/día |
| Monitorizar: Desplazamiento TET, úlceras, PA, SpO2 | Contraindicaciones: HIC, inestabilidad hemodinámica, trauma columna |

### Otras Terapias en SDRA Severo

| Terapia | Indicación | Consideraciones |
|---------|-----------|----------------|
| **BNM (bloqueo neuromuscular)** | PaO2/FiO2 <150, asincronía severa | Infusión cisatracurio 15-37 mg/h x 48h |
| **Óxido nítrico inhalado** | Hipoxemia severa, Hipertensión pulmonar | Mejora oxigenación (no mortalidad) |
| **ECMO (V-V)** | PaO2/FiO2 <80 con FiO2 1.0 x 6h o pH <7.25 + PaCO2 >60 | Centro experto, venovenosa |
| **Surfactante** | Neonatos/lactantes (SDRA neonatal) | No rutina en adultos |

## Sedación y Analgesia en VM

| Fármaco | Dosis bolo | Infusión | Objetivo RASS |
|---------|-----------|----------|---------------|
| Propofol | 0.5-1 mg/kg | 1-3 mg/kg/h | -2 a 0 (sedación ligera) |
| Midazolam | 1-3 mg | 1-5 mg/h | -2 a -5 (sedación profunda) |
| Fentanilo | 50-100 mcg | 25-100 mcg/h | Analgesia |
| Remifentanilo | — | 0.05-0.2 mcg/kg/min | Analgesia (metabolismo esterasas) |
| Dexmedetomidina | 0.5-1 mcg/kg en 10 min | 0.2-0.7 mcg/kg/h | Sedación consciente, sin depresión respiratoria |
| Ketamina | 0.5-1 mg/kg | 2-5 mcg/kg/min | Analgesia, broncodilatación |

### Estrategias de Sedación

- **Sedación dirigida por objetivo (RASS)**: Evaluar cada 1-2h
- **Interrupción diaria de sedación** (Diario de sedación): Evaluar readiness para extubación
- **Preferir sedantes no benzodiacepínicos** (menor delirio, menor estancia UCI)
- **Evaluación de dolor**: CPOT o BPS

## Destete (Weaning) de la VM

### Criterios de Destete (Readiness Weaning Trial)

| Parámetro | Criterio |
|-----------|----------|
| **Oxigenación** | PaO2/FiO2 >150-200, PEEP ≤8, FiO2 ≤0.4-0.5 |
| **Hemodinámica** | Sin vasopresores o dosis bajas, sin arritmias |
| **Neurológica** | Glasgow ≥13, reflejo tusígeno presente |
| **Muscular** | PIM (Presión inspiratoria máxima) < -20 a -30 cmH2O |
| **Respiratorio** | FR <30 rpm, Vt espontáneo >5 ml/kg, sin asincronía |

### Prueba de Ventilación Espontánea (SBT)

| Método | Configuración | Duración | Éxito |
|--------|--------------|----------|-------|
| **T-tube** | Sin soporte ventilatorio | 30-120 min | FR <35, SpO2 >90%, sin signos de distress |
| **PSV bajo** | PS 5-8 cmH2O + PEEP 5 | 30-120 min | Vt >5 ml/kg, FR/Vt <105 |
| **CPAP** | CPAP 5 cmH2O | 30-120 min | Estabilidad hemodinámica |

### Criterios de Fracaso de SBT

- FR >35 rpm sostenida
- SpO2 <90%
- FC >140 lpm o cambio >20%
- PAS >180 o <90 mmHg
- Signos de distress: tiraje, asincronía toracoabdominal, diaforesis
- Ansiedad/agitación severa

### Extubación

- **Realizar SBT exitoso** → Decisión de extubar
- **Prueba de fuga**: Desinflar balón TET → oír fuga audible (si no hay fuga, riesgo de estridor post-extubación)
- **Preparación**: Aspirar secreciones, sentar al paciente, oxígeno (Venturi 50% o cánula nasal 3 L/min)
- **Equipo listo**: BVM, mascarilla de Venturi, equipo de reintubación
- **Post-extubación**: Fisioterapia respiratoria, humidificación, evitar opioides excesivos
- **Fracaso de extubación**: Reintubación en <48h (15-20% de los casos)

### Ventilación No Invasiva (VNI) Post-Extubación

| Indicación | Modalidad | Configuración |
|-----------|-----------|---------------|
| Prevención de fallo post-extubación (alto riesgo) | CPAP o BIPAP | EPAP 5-10, IPAP 10-20 |
| EPOC reagudizado | BIPAP | EPAP 4-6, IPAP 8-16 |
| EAP (edema agudo pulmón) | CPAP | CPAP 5-10 cmH2O |

## Complicaciones de la VM

| Complicación | Causa | Prevención | Manejo |
|-------------|-------|-----------|--------|
| **Barotrauma/Neumotórax** | Pplateau >30, PEEP alta, volutrauma | Ventilación protectora | Drenaje torácico, reducir presión |
| **VAP (Neumonía asociada VM)** | Aspiración, contaminación circuito | Cabeza elevada 30-45°, higiene oral, cambio circuito no rutinario | Antibióticos (cultivos previos) |
| **Hipotensión inducida** | PEEP alta, disminución retorno venoso, sedación | Fluidoterapia, vasopresores | Reducir PEEP si es posible |
| **Asincronía paciente-ventilador** | Mal ajuste de sensibilidad, flujo, modo | Optimizar parámetros, sedación | Cambiar modo, ajustar sensibilidad |
| **Atrofia diafragmática** | VM prolongada sin esfuerzo espontáneo | PSV diario, entrenamiento muscular | Destete precoz |
| **Estenosis traqueal** | Balón TET sobreinflado, tiempo prolongado | Presión balón <30 cmH2O (ideal 20-25) | Traqueostomía (dilatación o quirúrgica) |

---

> **Descargo de responsabilidad**: Esta guía es un recurso educativo basado en el protocolo ARDSNet, guías SEMICYUC y evidencia actual. El manejo de la ventilación mecánica debe individualizarse según la patología subyacente, las características del paciente y los recursos disponibles. No reemplaza la formación específica en medicina intensiva ni el juicio clínico del profesional tratante.

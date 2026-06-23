# Triaje Manchester (MTS) — Sistema de Priorización en Urgencias

## Fuentes y Referencias
- **Manchester Triage Group (MTG) / Advanced Life Support Group (ALSG)** — Manchester Triage System, 3ª ed. 2020
- **Grupo Español de Triaje (GET-SEMES)** — Adaptación española MTS
- **NICE Guidelines NG97** — Emergency and acute medical care
- **UpToDate 2024** — "Triage in the emergency department"
- **European Triaje Scale (ETS)** — Comparativa internacional

---

## Principios del MTS
- **Priorización clínica, NO diagnóstico**. Asigna urgencia basándose en **presentación clínica (queja principal)**.
- **5 niveles de prioridad** con colores y tiempos máximos de espera.
- **Discriminadores** (sí/no) por presentacion → derivan a nivel.
- **Reevaluación obligatoria** si espera supera tiempo objetivo o cambia condición.

---

## Niveles de Prioridad (Colores / Tiempos / Acción)

| Nivel | Color | Tiempo MÁX espera | Acción enfermería/médico |
|-------|-------|-------------------|--------------------------|
| **1** | 🔴 **ROJO** | **0 min (Inmediato)** | **Reanimación / Estabilización inmediata**. Médico + enfermería dedicados. Box reanimación. |
| **2** | 🟠 **NARANJA** | **10 min** | **Muy urgente**. Valoración médica ≤10 min. Monitor continuo. Vía IV. Analgesia si dolor. |
| **3** | 🟡 **AMARILLO** | **30 min** | **Urgente**. Valoración médica ≤30 min. Signos vitales c/15-30 min. |
| **4** | 🟢 **VERDE** | **60-120 min** | **Estándar / Diferible**. Valoración médica ≤60-120 min. Signos vitales ingreso + c/60 min. |
| **5** | 🔵 **AZUL** | **120-240 min** | **No urgente / Administrativo**. Derivación a atención primaria / cita programada. |

> **Regla de oro**: "Mejor sobre-triaje (subir nivel) que infra-triaje (bajar nivel)". Si duda → **nivel superior**.

---

## 52 Presentaciones Clínicas (Quejas Principales) — Algoritmo discriminadores

### FLUJO GENERAL por presentación:
1. **Identificar presentación** (ej: "Dolor torácico", "Dificultad respiratoria", "Traumatismo craneal")
2. **Aplicar discriminadores en orden** (de mayor a menor urgencia)
3. **Primer discriminador POSITIVO** → asigna ese nivel
4. **Si todos NEGATIVOS** → nivel por defecto de la presentación

---

### PRESENTACIONES CRÍTICAS (Nivel 1/2 por defecto)

| Presentación | Nivel defecto | Discriminadores clave → Nivel |
|--------------|---------------|-------------------------------|
| **Paro cardiorrespiratorio** | **1** | — |
| **Obstrucción vía aérea** | **1** | — |
| **Inconsciencia / GCS <9** | **1** | GCS ≤8 → 1; GCS 9-12 → 2 |
| **Convulsión activa / Status epiléptico** | **1** | Activa → 1; Post-ictal estable → 2 |
| **Shock / Hipoperfusión** | **1** | PAM <65 + signos hipoperfusión → 1 |
| **Dolor torácico sugerente isquemia** | **2** | **Dolor actual + ECG isquemia** → 1; Dolor actual + factores riesgo → 2; Dolor resuelto → 3 |
| **Dificultad respiratoria grave** | **2** | **Sat <90% / FR>30 / uso accesorios / cianosis** → 1; Moderada (FR 25-30, sat 90-94%) → 2; Leve → 3 |
| **Hemorragia masiva / Shock hemorrágico** | **1** | Incontrolada / signos shock → 1; Controlada pero inestable → 2 |

---

### PRESENTACIONES COMUNES — Discriminadores resumen

#### **Dolor Abdominal**
| Discriminador | Nivel |
|---------------|-------|
| Dolor + shock / inestabilidad hemodinámica | 1 |
| Dolor + abdomen agudo quirúrgico (defensa, contractura, peritonismo) | 2 |
| Dolor intenso (EVA ≥7) + vómitos / fiebre | 2 |
| Dolor moderado (EVA 4-6) | 3 |
| Dolor leve (EVA 1-3) | 4 |

#### **Traumatismo Craneal**
| Discriminador | Nivel |
|---------------|-------|
| GCS ≤8 / convulsión / déficit focal / sangrado otorrinolaringológico | 1 |
| GCS 9-12 / amnesia >30min / vómitos repetidos / anticoagulado / >65a | 2 |
| GCS 13-14 / pérdida conciencia breve / cefalea / vómito único | 3 |
| Traumatismo leve, asintomático, GCS 15 | 4 |

#### **Quemaduras**
| Discriminador | Nivel |
|---------------|-------|
| Vía aérea comprometida / quemadura circunferencial / >20% SCQ (adulto) / >10% (niño/anciano) / zonas críticas (cara, manos, genitales, pliegues) / eléctrica / química | 1 |
| 10-20% SCQ / zonas críticas sin compromiso vital / dolor severo | 2 |
| 5-10% SCQ / dolor moderado | 3 |
| <5% SCQ superficial / dolor leve | 4 |

#### **Intoxicación / Sobredosis**
| Discriminador | Nivel |
|---------------|-------|
| Inconsciente / GCS <9 / convulsión / inestabilidad hemodinámica / cianosis | 1 |
| Somnolencia (GCS 9-12) / agitación severa / taquicardia >130 / hipotensión / hipertermia | 2 |
| Sintomático estable (náuseas, vómitos, dolor abdominal, GCS 13-14) | 3 |
| Asintomático / ingestión conocida bajo umbral tóxico | 4 |

#### **Problemas Psiquiátricos / Conducta Agitada**
| Discriminador | Nivel |
|---------------|-------|
| Riesgo inminente agresividad / auto/hetero-lesión / arma | 1 (seguridad + médica) |
| Agitación severa / psicosis aguda / riesgo fuga / requiere contención | 2 |
| Ansiedad moderada / ideación suicida sin plan / demanda voluntaria | 3 |
| Consulta administrativa / derivación / seguimiento | 4 |

#### **Fiebre / Síndrome Infeccioso**
| Discriminador | Nivel |
|---------------|-------|
| <3 meses (RN) con fiebre ≥38°C / signos sepsis (qSOFA≥2) / shock / inmunodeprimido grave | 1 |
| 3-36 meses con fiebre ≥39°C + signos alarma (letargo, fontanela, nega alimentación) / fiebre >5d | 2 |
| Fiebre + foco claro (ORL, urinario) + buen estado general | 3 |
| Fiebre baja / sin foco / buen estado >36 meses | 4 |

#### **Dolor Lumbar / Ciática**
| Discriminador | Nivel |
|---------------|-------|
| Síndrome cauda equina (retención urinaria, anestesia silla de montar, deficit motor) | 1 |
| Fiebre + dolor lumbar (sospecha espondilodiscitis) / trauma severo / tumor conocido | 2 |
| Dolor irradiado + déficit neurológico leve / dolor intenso limitante | 3 |
| Dolor mecánico bajo sin signos alarma | 4 |

---

## Reevaluación Obligatoria (MTS)

| Situación | Acción |
|-----------|--------|
| **Espera > tiempo objetivo del nivel** | Re-triaje completo (nuevo MTS) |
| **Cambio en condición clínica** | Re-triaje inmediato |
| **Paciente abandona sala espera** | Registrar + avisar médico si nivel 1-3 |
| **Ingreso a box / camilla** | Signos vitales completos + re-triaje si indicado |

---

## Enfermería en Triaje — Competencias clave

| Habilidad | Descripción |
|-----------|-------------|
| **Entrevista dirigida** | Preguntas cerradas por discriminadores (max 2-3 min) |
| **Signos vitales completos** | FC, PA, FR, SatO₂, Temp, GCS, Glucemia capilar, EVA dolor |
| **Identificación presentación** | Clasificar queja principal en 1 de 52 algoritmos |
| **Aplicación discriminadores** | Orden secuencial, detener en primer positivo |
| **Comunicación efectiva** | Explicar nivel, tiempo estimado, aviso si empeora |
| **Documentación** | Hora triaje, presentación, discriminadores +/-, nivel asignado, enfermera, signos vitales |
| **Seguridad** | Identificación pulsera, alergias, aislamiento si infeccioso, pertenencias |

---

## Pediatría — Adaptaciones MTS (Paediatric MTS)

| Diferencia clave | Detalle |
|------------------|---------|
| **Presentaciones específicas** | Llanto inconsolable, rechazo alimentación,.guias, ictericia, fontanela |
| **Signos vitales pediátricos** | Tablas por edad (FC, FR, PA, Temp) |
| **Saturación** | <92% = hipoxemia (vs <90% adulto) |
| **GCS pediátrico** | Adaptado <5 años (respuesta verbal/motora) |
| **Peso** | Fundamental para dosis / fluidoterapia |
| **Discriminadores** | Incluyen: "parece enfermo grave", "no interactúa", "no tolera líquidos" |

---

## Comparativa MTS vs Otros Sistemas

| Sistema | Niveles | Método | Uso principal |
|---------|---------|--------|---------------|
| **MTS (Manchester)** | 5 | Algoritmos por presentación (52) | **UK, España, Portugal, Brasil, Australia** |
| **ESI (Emergency Severity Index)** | 5 | Recursos esperados + estabilidad | **USA, Canadá, algunos EU** |
| **CTAS (Canadian)** | 5 | Presentación + signos vitales + tiempo | **Canadá** |
| **SAT (Sistema Andorrano/ Español antiguo)** | 5 | Similar MTS | **España (histórico)** |
| **GET (Grupo Español Triaje)** | 5 | Adaptación MTS + protocolos SEMES | **España (actual)** |

---

## Indicadores de Calidad Triaje

| Indicador | Estándar |
|-----------|----------|
| **Tiempo triaje completo** | ≤5 min (adulto) / ≤10 min (pediátrico) |
| **Concordancia triaje-revisión médica** | ≥90% (kappa >0.8) |
| **Infra-triaje (nivel asignado > real)** | <1-2% (nivel 1-2) |
| **Sobre-triaje (nivel asignado < real)** | 10-20% aceptable (seguridad) |
| **Re-triaje por espera excedida** | 100% cumplimiento |
| **Satisfacción usuario (comunicación)** | ≥80% |

---

## Referencias completas
1. Manchester Triage Group. **Manchester Triage System (3rd ed.)**. Wiley-Blackwell 2020.
2. Gil Boyne J, et al. **Guía de Triaje de la Sociedad Española de Medicina de Urgencias y Emergencias (SEMES)**. 2021.
3. NICE. **NG97: Emergency and acute medical care in over 16s**. 2018 (updated 2023).
4. Miró Ò, et al. **Validación del Manchester Triage System en urgencias españolas**. Emergencias 2015;27:123-130.
5. UpToDate. **Triage in the emergency department**. 2024.
6. Australasian College for Emergency Medicine. **Australasian Triage Scale (ATS)**. 2020.
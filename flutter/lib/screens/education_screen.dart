import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';


class Flashcard {
  final String pregunta;
  final String respuesta;
  Flashcard(this.pregunta, this.respuesta);
}

class QuizPregunta {
  final String pregunta;
  final List<String> opciones;
  final int correcta;
  final String explicacion;
  QuizPregunta({
    required this.pregunta,
    required this.opciones,
    required this.correcta,
    required this.explicacion,
  });
}

Map<String, List<Flashcard>> _flashcardsData = {
  'Cardiología': [
    Flashcard('¿FC normal adulto?', '60-100 lpm'),
    Flashcard('¿PA normal?', 'PAS <120, PAD <80 mmHg'),
    Flashcard('¿Intervalo PR normal?', '0.12-0.20 seg'),
    Flashcard('¿Complejo QRS normal?', '<0.12 seg'),
    Flashcard('¿QT corregido normal?', '<440 ms H, <460 ms M'),
    Flashcard('¿Adrenalina en paro?', '1 mg IV c/3-5 min'),
    Flashcard('¿Amiodarona en TV?', '150 mg IV en 10 min'),
    Flashcard('¿Onda P representa?', 'Despolarización auricular'),
    Flashcard('¿Onda T representa?', 'Repolarización ventricular'),
    Flashcard('¿Fórmula PAM?', 'PAM = PAS + (2 × PAD) / 3'),
    Flashcard('¿Tríada de Beck?', 'Hipotensión, ingurgitación yugular, ruidos apagados'),
  ],
  'Neonatología': [
    Flashcard('¿Apgar evalúa?', 'Color, FC, Reflejos, Tono, Respiración'),
    Flashcard('¿Apgar normal?', '7-10 al minuto 5'),
    Flashcard('¿FC normal RN?', '120-160 lpm'),
    Flashcard('¿FR normal RN?', '30-60 rpm'),
    Flashcard('¿Peso promedio RN término?', '2500-4000 g'),
    Flashcard('¿Reflejo Moro hasta?', '4-5 meses'),
    Flashcard('¿Cianosis neonatal causas?', 'Cardiopatía congénita, enf. pulmonar, metahemoglobinemia'),
  ],
  'Farmacología': [
    Flashcard('¿Antídoto heparina?', 'Protamina'),
    Flashcard('¿Antídoto BZD?', 'Flumazenilo'),
    Flashcard('¿Antídoto opioides?', 'Naloxona'),
    Flashcard('¿Antídoto paracetamol?', 'N-acetilcisteína'),
    Flashcard('¿Antídoto Mg?', 'Gluconato de calcio'),
    Flashcard('¿Vida media?', 'Tiempo en reducir concentración al 50%'),
    Flashcard('¿Biodisponibilidad IV?', '100%'),
    Flashcard('¿Vía SC ejemplos?', 'Insulina, heparina de bajo peso molecular'),
  ],
  'Anatomía': [
    Flashcard('¿Hueso más largo?', 'Fémur'),
    Flashcard('¿Válvula AD→VD?', 'Tricúspide'),
    Flashcard('¿Válvula AI→VI?', 'Mitral'),
    Flashcard('¿Lóbulos pulmón derecho?', '3 (sup, medio, inf)'),
    Flashcard('¿Lóbulos pulmón izquierdo?', '2 (sup, inf)'),
    Flashcard('¿Volumen LCR adulto?', '130-150 mL'),
    Flashcard('¿Consumo O₂ cerebro?', '20% del total'),
    Flashcard('¿Peso corazón adulto?', '250-350 g'),
  ],
  'Fundamentos PAE': [
    Flashcard('¿Signos vitales básicos?', 'FC, FR, Temperatura, PA'),
    Flashcard('¿Fases del PAE?', 'Valoración, Diagnóstico, Planificación, Ejecución, Evaluación'),
    Flashcard('¿5 correctos?', 'Paciente, fármaco, dosis, vía, hora'),
    Flashcard('¿Escala UPP?', 'Braden / Norton'),
    Flashcard('¿Posición Fowler?', '45-90° para disnea'),
    Flashcard('¿Temp axilar normal?', '36-37.5°C'),
    Flashcard('¿Formato NANDA?', 'PES (Problema, Etiología, Signos/Síntomas)'),
  ],
  'Examen Mixto': [
    Flashcard('¿FC fetal normal?', '110-160 lpm'),
    Flashcard('¿Antídoto heparina?', 'Protamina'),
    Flashcard('¿Fases del PAE?', '5 fases'),
    Flashcard('¿Volumen sanguíneo?', '~5 L (7% peso)'),
    Flashcard('¿Células beta producen?', 'Insulina'),
  ],
  'Cuidados Intensivos': [
    Flashcard('¿PAM objetivo en shock séptico?', '>65 mmHg'),
    Flashcard('¿Primer antibiótico en sepsis?', 'Dentro 1h, previo hemocultivos'),
    Flashcard('¿VF en paro cardíaco?', 'Desfibrilación + RCP 30:2'),
    Flashcard('¿Dosis adrenalina PCR?', '1 mg IV c/3-5 min'),
    Flashcard('¿Target SpO2 en UCI?', '94-98%'),
    Flashcard('¿PEEP inicial en ARM?', '5 cmH2O'),
    Flashcard('¿Sedación escala RASS?', '-5 a +4, objetivo según caso'),
    Flashcard('¿Nutrición enteral inicio?', '<48h si estable'),
    Flashcard('¿Profilaxis TVP en UCI?', 'HBPM o heparina no fraccionada'),
    Flashcard('¿Delirio en UCI?', 'Evaluar con CAM-ICU diario'),
  ],
  'Enfermería Quirúrgica': [
    Flashcard('¿Clasificación heridas según contaminación?', 'Limpia, limpia-contaminada, contaminada, sucia'),
    Flashcard('¿Preparación preoperatoria?', 'Ayuno 6-8h, ducha antiséptica, rasurado mínimo'),
    Flashcard('¿Signos infección herida?', 'Rubor, calor, tumor, dolor, fiebre'),
    Flashcard('¿Drenajes más comunes?', 'Penrose, Jackson-Pratt, Blake'),
    Flashcard('¿Cuidados ostomía?', 'Bolsa, protección piel, dieta baja en fibra'),
    Flashcard('¿Dehiscencia de herida?', 'Separación bordes quirúrgicos, urgente'),
    Flashcard('¿Evisceración?', 'Salida vísceras por herida, EMERGENCIA'),
    Flashcard('¿Profilaxis ATB quirúrgica?', '30-60 min antes de incisión'),
    Flashcard('¿Suturas puntos?', 'Simples, continuas, colchonero, subcuticular'),
    Flashcard('¿Cuidados apósito?', 'Cambio si húmedo, limpio, sellado'),
  ],
  'Salud Mental': [
    Flashcard('¿Tríada depresión?', 'Ánimo bajo, anhedonia, energía baja'),
    Flashcard('¿Escala Glasgow?', 'Ocular 1-4, Verbal 1-5, Motor 1-6'),
    Flashcard('¿Ansiedad generalizada?', 'Preocupación excesiva >6 meses'),
    Flashcard('¿Crisis pánico?', 'Miedo intenso + síntomas físicos súbitos'),
    Flashcard('¿Esquizofrenia síntomas?', 'Positivos (alucinaciones), negativos (abulia)'),
    Flashcard('¿Trastorno bipolar?', 'Fases maníaca + depresiva'),
    Flashcard('¿Riesgo suicida?', 'Ideación, plan, intento previo, desesperanza'),
    Flashcard('¿Contención mecánica?', 'Último recurso, reevaluar c/2h'),
    Flashcard('¿Trastorno límite?', 'Inestabilidad emocional, impulsividad'),
    Flashcard('¿Terapia electroconvulsiva?', 'Para depresión resistente, manía severa'),
  ],
  'Pediatría': [
    Flashcard('¿FC normal RN?', '120-160 lpm'),
    Flashcard('¿FR normal RN?', '40-60 rpm'),
    Flashcard('¿Peso RN término?', '2500-4000 g'),
    Flashcard('¿Reflejo Moro hasta?', '4-5 meses'),
    Flashcard('¿Fiebre en lactante <3m?', '>38°C, requiere estudio completo'),
    Flashcard('¿Reanimación neonatal?', 'Calor, posición, secar, ventilar, comprimir'),
    Flashcard('¿Deshidratación en niños?', 'Pliegue, ojos hundidos, llanto sin lágrimas'),
    Flashcard('¿Convulsión febril?', '6m-5a, fiebre, <15 min, típicamente benigna'),
    Flashcard('¿Vacunas esquema Chile?', 'BCG, H, Pentavalente, SRP, VPH'),
    Flashcard('¿Crecimiento normal?', 'Peso al nacer x2 a 4m, x3 a 12m'),
  ],
  'Geriatría': [
    Flashcard('¿Escala de Barthel?', 'Evalúa AVD básicas (baño, vestido, comida)'),
    Flashcard('¿Delirio en anciano?', 'Agudo, fluctuante, atención alterada'),
    Flashcard('¿Demencia?', 'Crónico, memoria, lenguaje, función ejecutiva'),
    Flashcard('¿Caídas en adulto mayor?', 'Principal causa de lesión, evaluar riesgo'),
    Flashcard('¿Polifarmacia?', '>5 fármacos, riesgo interacciones'),
    Flashcard('¿Criterios START/STOPP?', 'Prescripción inapropiada en ancianos'),
    Flashcard('¿Dolor en demencia?', 'Escala PAINAD, gestos, gemidos'),
    Flashcard('¿Úlceras por presión?', 'Prevención: cambios postura, nutrición'),
    Flashcard('¿Fragilidad?', 'Pérdida peso, fatiga, baja actividad, debilidad'),
    Flashcard('¿Sarcopenia?', 'Pérdida masa muscular, fuerza, rendimiento'),
  ],
  'Epidemiología': [
    Flashcard('¿Incidencia vs prevalencia?', 'Incidencia: casos nuevos. Prevalencia: casos totales'),
    Flashcard('¿Medidas de frecuencia?', 'Tasa, razón, proporción'),
    Flashcard('¿Tipos de estudios?', 'Cohorte, caso-control, transversal, experimental'),
    Flashcard('¿Riesgo relativo?', 'Incidencia expuestos / incidencia no expuestos'),
    Flashcard('¿OR?', 'Odds ratio = (a/c)/(b/d)'),
    Flashcard('¿Sensibilidad?', 'VP / (VP + FN)'),
    Flashcard('¿Especificidad?', 'VN / (VN + FP)'),
    Flashcard('¿Valor predictivo +?', 'VP / (VP + FP)'),
    Flashcard('¿Curva ROC?', 'Sensibilidad vs 1-especificidad'),
    Flashcard('¿NNT?', '1 / reducción riesgo absoluto'),
  ],
};

Map<String, List<QuizPregunta>> _quizzesData = {
  'Cardiología': [
    QuizPregunta(pregunta: '¿FC fetal normal?', opciones: ['80-100 lpm', '110-160 lpm', '140-180 lpm', '90-120 lpm'], correcta: 1, explicacion: 'FC fetal normal 110-160 lpm. <110 bradicardia, >160 taquicardia.'),
    QuizPregunta(pregunta: '¿TFG normal?', opciones: ['60 mL/min', '90 mL/min', '125 mL/min', '150 mL/min'], correcta: 2, explicacion: 'TFG normal ~125 mL/min (~180 L/día).'),
    QuizPregunta(pregunta: '¿PA media normal?', opciones: ['60-70 mmHg', '70-105 mmHg', '110-130 mmHg', '130-150 mmHg'], correcta: 1, explicacion: 'PAM normal 70-105 mmHg. <60 es hipoperfusión.'),
    QuizPregunta(pregunta: '¿Gasto cardíaco reposo?', opciones: ['2.5 L/min', '5 L/min', '8 L/min', '12 L/min'], correcta: 1, explicacion: 'GC reposo ~5 L/min, hasta 25 L/min en ejercicio.'),
    QuizPregunta(pregunta: '¿FEVI normal?', opciones: ['>30%', '>40%', '>50-55%', '>65%'], correcta: 2, explicacion: 'FEVI normal >50-55%.'),
    QuizPregunta(pregunta: '¿Primera dosis adrenalina en PCR?', opciones: ['0.5 mg', '1 mg', '2 mg', '3 mg'], correcta: 1, explicacion: 'Adrenalina 1 mg IV cada 3-5 min en paro.'),
    QuizPregunta(pregunta: '¿Intervalo PR normal?', opciones: ['0.04-0.08 s', '0.12-0.20 s', '0.20-0.40 s', '0.40-0.60 s'], correcta: 1, explicacion: 'PR normal 120-200 ms.'),
    QuizPregunta(pregunta: '¿QTc normal?', opciones: ['<360 ms', '<440 ms H / <460 ms M', '<500 ms', '<320 ms'], correcta: 1, explicacion: 'QTc normal <440 ms hombres, <460 ms mujeres.'),
    QuizPregunta(pregunta: '¿Fármaco primera línea en TV estable?', opciones: ['Lidocaína', 'Amiodarona', 'Adenosina', 'Verapamilo'], correcta: 1, explicacion: 'Amiodarona es primera línea en TV estable.'),
    QuizPregunta(pregunta: '¿Cuántas derivaciones ECG estándar?', opciones: ['6', '10', '12', '15'], correcta: 2, explicacion: 'ECG tiene 12 derivaciones: 6 extremidades + 6 precordiales.'),
  ],
  'Neonatología': [
    QuizPregunta(pregunta: '¿Apgar normal?', opciones: ['0-3', '4-6', '7-10', '10-12'], correcta: 2, explicacion: 'Apgar 7-10 normal. 4-6 reanimación leve, <4 reanimación inmediata.'),
    QuizPregunta(pregunta: '¿Parámetros Apgar?', opciones: ['3', '5', '7', '10'], correcta: 1, explicacion: 'Apgar: Color, FC, Reflejos, Tono, Respiración.'),
    QuizPregunta(pregunta: '¿FR normal RN?', opciones: ['20-30 rpm', '30-40 rpm', '40-60 rpm', '60-80 rpm'], correcta: 2, explicacion: 'FR RN normal 40-60 rpm.'),
    QuizPregunta(pregunta: '¿Peso RN término?', opciones: ['1.5-2.5 kg', '2.5-4 kg', '3-5 kg', '4-5 kg'], correcta: 1, explicacion: 'Peso normal RN término 2.5-4 kg.'),
    QuizPregunta(pregunta: '¿Reflejo Moro hasta?', opciones: ['2-3 m', '4-5 m', '6-8 m', '10-12 m'], correcta: 1, explicacion: 'Reflejo Moro presente hasta 4-5 meses.'),
    QuizPregunta(pregunta: '¿Qué evalúa Silverman-Anderson?', opciones: ['Peso neonatal', 'Distrés respiratorio', 'Reflejos', 'Ictericia'], correcta: 1, explicacion: 'Silverman-Anderson evalúa severidad de distrés respiratorio neonatal.'),
  ],
  'Farmacología': [
    QuizPregunta(pregunta: '¿Antídoto heparina?', opciones: ['Vit K', 'Protamina', 'Flumazenil', 'Naloxona'], correcta: 1, explicacion: 'Protamina neutraliza heparina formando complejos inactivos.'),
    QuizPregunta(pregunta: '¿Antídoto BZD?', opciones: ['Naloxona', 'Protamina', 'Flumazenil', 'Vit K'], correcta: 2, explicacion: 'Flumazenil es antagonista competitivo de BZD.'),
    QuizPregunta(pregunta: '¿Antídoto opioides?', opciones: ['Flumazenil', 'Naloxona', 'Protamina', 'Naltrexona'], correcta: 1, explicacion: 'Naloxona revierte depresión respiratoria opioide.'),
    QuizPregunta(pregunta: '¿Amiodarona clase?', opciones: ['Clase I', 'Clase II', 'Clase III', 'Clase IV'], correcta: 2, explicacion: 'Amiodarona es Clase III (alarga potencial de acción).'),
    QuizPregunta(pregunta: '¿Diurético asa principal?', opciones: ['HCTZ', 'Espironolactona', 'Furosemida', 'Manitol'], correcta: 2, explicacion: 'Furosemida inhibe NKCC2 en asa de Henle.'),
    QuizPregunta(pregunta: '¿Vía noradrenalina?', opciones: ['IM', 'SC', 'CVC', 'Oral'], correcta: 2, explicacion: 'Noradrenalina debe administrarse por CVC por riesgo de extravasación.'),
    QuizPregunta(pregunta: '¿Vida media?', opciones: ['Tiempo a Cmax', 'Tiempo a 50% eliminación', 'Duración total', 'Tiempo absorción'], correcta: 1, explicacion: 'Vida media: tiempo para que concentración plasmática se reduzca 50%.'),
    QuizPregunta(pregunta: '¿Índice terapéutico estrecho ejemplos?', opciones: ['Paracetamol, ibuprofeno', 'Digoxina, warfarina, litio', 'Amoxicilina, azitromicina', 'Omeprazol, ranitidina'], correcta: 1, explicacion: 'Fármacos con IT estrecho: digoxina, warfarina, fenitoína, litio, teofilina.'),
  ],
  'Anatomía': [
    QuizPregunta(pregunta: '¿Volumen LCR adulto?', opciones: ['50-80 mL', '130-150 mL', '200-250 mL', '300-400 mL'], correcta: 1, explicacion: 'LCR 130-150 mL, se renueva ~4 veces/día.'),
    QuizPregunta(pregunta: '¿Huesos cráneo?', opciones: ['6', '8', '12', '14'], correcta: 1, explicacion: '8 huesos: frontal, parietal (2), temporal (2), occipital, esfenoides, etmoides.'),
    QuizPregunta(pregunta: '¿Válvula AD→VD?', opciones: ['Mitral', 'Tricúspide', 'Aórtica', 'Pulmonar'], correcta: 1, explicacion: 'Válvula tricúspide separa AD de VD.'),
    QuizPregunta(pregunta: '¿Consumo O₂ cerebro?', opciones: ['5%', '10%', '20%', '30%'], correcta: 2, explicacion: 'Cerebro 2% peso corporal, consume 20% O₂ total.'),
    QuizPregunta(pregunta: '¿Peso corazón?', opciones: ['150-200 g', '250-350 g', '400-500 g', '500-600 g'], correcta: 1, explicacion: 'Corazón adulto 250-350 g.'),
    QuizPregunta(pregunta: '¿Cavidades cardíacas?', opciones: ['2', '3', '4', '6'], correcta: 2, explicacion: '4 cavidades: 2 aurículas + 2 ventrículos.'),
  ],
  'Fundamentos PAE': [
    QuizPregunta(pregunta: '¿Fases del PAE?', opciones: ['3', '4', '5', '6'], correcta: 2, explicacion: 'PAE: Valoración, Diagnóstico, Planificación, Ejecución, Evaluación.'),
    QuizPregunta(pregunta: '¿Escala Braden?', opciones: ['Dolor', 'Riesgo UPP', 'Conciencia', 'Caídas'], correcta: 1, explicacion: 'Braden evalúa riesgo de úlceras por presión (6 subescalas).'),
    QuizPregunta(pregunta: '¿Escala EVA?', opciones: ['Ansiedad', 'Dolor 0-10', 'Náusea', 'Sedación'], correcta: 1, explicacion: 'EVA mide intensidad del dolor del 0 al 10.'),
    QuizPregunta(pregunta: '¿Formato NANDA?', opciones: ['SOAP', 'PES', 'DAR', 'PIE'], correcta: 1, explicacion: 'NANDA usa formato PES: Problema, Etiología, Signos/Síntomas.'),
    QuizPregunta(pregunta: '¿5 correctos?', opciones: ['Paciente, fármaco, dosis, vía, hora', 'Nombre, fecha, dosis, vía, hora', 'Paciente, médico, fármaco, dosis, registro', 'Paciente, dosis, efecto, reacción, hora'], correcta: 0, explicacion: 'Paciente, fármaco, dosis, vía y hora correctos.'),
    QuizPregunta(pregunta: '¿Posición para disnea?', opciones: ['Supino', 'Fowler 45-90°', 'Prono', 'Trendelenburg'], correcta: 1, explicacion: 'Fowler facilita expansión pulmonar y mejora oxigenación.'),
    QuizPregunta(pregunta: '¿Temp axilar normal?', opciones: ['35-36°C', '36-37.5°C', '37.5-38.5°C', '35.5-36.5°C'], correcta: 1, explicacion: 'Temperatura axilar normal 36-37.5°C.'),
  ],
  'Examen Mixto': [
    QuizPregunta(pregunta: '¿FC fetal normal?', opciones: ['80-100', '110-160', '140-180', '90-120'], correcta: 1, explicacion: 'FC fetal normal 110-160 lpm.'),
    QuizPregunta(pregunta: '¿Antídoto heparina?', opciones: ['Vit K', 'Protamina', 'Flumazenil', 'Naloxona'], correcta: 1, explicacion: 'Sulfato de protamina neutraliza heparina.'),
    QuizPregunta(pregunta: '¿Fases PAE?', opciones: ['3', '4', '5', '6'], correcta: 2, explicacion: 'PAE: 5 fases.'),
    QuizPregunta(pregunta: '¿Volumen sanguíneo?', opciones: ['3 L', '5 L (~7% peso)', '7 L', '9 L'], correcta: 1, explicacion: 'Adulto ~5L sangre, ~7% peso corporal.'),
    QuizPregunta(pregunta: '¿Células beta producen?', opciones: ['Glucagón', 'Insulina', 'Somatostatina', 'Gastrina'], correcta: 1, explicacion: 'Células beta de islotes de Langerhans producen insulina.'),
  ],
  'Cuidados Intensivos': [
    QuizPregunta(pregunta: '¿PAM objetivo en shock séptico?', opciones: ['>55 mmHg', '>65 mmHg', '>75 mmHg', '>85 mmHg'], correcta: 1, explicacion: 'PAM objetivo >65 mmHg en shock séptico según Surviving Sepsis.'),
    QuizPregunta(pregunta: '¿Lactato en sepsis?', opciones: ['<1 mmol/L', '<2 mmol/L', '<3 mmol/L', '<4 mmol/L'], correcta: 1, explicacion: 'Lactato <2 mmol/L es normal. >2 sugiere hipoperfusión.'),
    QuizPregunta(pregunta: '¿Relación RCP en adulto?', opciones: ['15:2', '30:2', '5:1', '20:2'], correcta: 1, explicacion: 'RCP adulto: 30 compresiones por 2 ventilaciones.'),
    QuizPregunta(pregunta: '¿PEEP inicial en ARM?', opciones: ['0 cmH2O', '5 cmH2O', '10 cmH2O', '15 cmH2O'], correcta: 1, explicacion: 'PEEP inicial 5 cmH2O para reclutamiento alveolar.'),
    QuizPregunta(pregunta: '¿RASS ideal en UCI?', opciones: ['-5', '-3 a -2', '0 a -2', '+2 a +4'], correcta: 2, explicacion: 'RASS 0 a -2: sedación ligera ideal en ventilación.'),
    QuizPregunta(pregunta: '¿Profilaxis TVP en UCI?', opciones: ['AINE', 'HBPM', 'Aspirina', 'Ninguna'], correcta: 1, explicacion: 'HBPM o heparina no fraccionada es profilaxis TVP en UCI.'),
    QuizPregunta(pregunta: '¿Score SOFA?', opciones: ['Sepsis', 'Trauma', 'Conciencia', 'Dolor'], correcta: 0, explicacion: 'SOFA evalúa disfunción orgánica en sepsis.'),
    QuizPregunta(pregunta: '¿Hemocultivos en sepsis?', opciones: ['Antes de ATB', 'Después de ATB', 'Solo si fiebre', 'No necesarios'], correcta: 0, explicacion: 'Hemocultivos antes de antibióticos, idealmente 2 sets.'),
  ],
  'Enfermería Quirúrgica': [
    QuizPregunta(pregunta: '¿Ayuno preoperatorio?', opciones: ['2-4h', '6-8h', '12h', '24h'], correcta: 1, explicacion: 'Ayuno 6h sólidos, 2h líquidos claros.'),
    QuizPregunta(pregunta: '¿Profilaxis ATB cuándo?', opciones: ['1 semana antes', '30-60 min antes', 'Durante incisión', '24h después'], correcta: 1, explicacion: 'ATB profiláctico 30-60 min antes de incisión.'),
    QuizPregunta(pregunta: '¿Dehiscencia es?', opciones: ['Separación bordes', 'Salida vísceras', 'Infección', 'Hematoma'], correcta: 0, explicacion: 'Dehiscencia: separación de bordes de herida quirúrgica.'),
    QuizPregunta(pregunta: '¿Evisceración?', opciones: ['Infección', 'Salida vísceras', 'Hematoma', 'Seroma'], correcta: 1, explicacion: 'Evisceración: EMERGENCIA, salida de vísceras por herida.'),
    QuizPregunta(pregunta: '¿Drenaje Jackson-Pratt?', opciones: ['Abierto', 'Cerrado vacío', 'Capilar', 'Gravedad'], correcta: 1, explicacion: 'JP es drenaje cerrado con vacío (bulbo comprimible).'),
    QuizPregunta(pregunta: '¿Cuidados ostomía?', opciones: ['Alcohol', 'Protección piel', 'Vendaje compresivo', 'Hielo'], correcta: 1, explicacion: 'Proteger piel periestomal con pasta protectora.'),
    QuizPregunta(pregunta: '¿Signo de infección?', opciones: ['Rubor', 'Palidez', 'Frialdad', 'Parestesia'], correcta: 0, explicacion: 'Rubor, calor, tumor, dolor y fiebre son signos de infección.'),
  ],
  'Salud Mental': [
    QuizPregunta(pregunta: '¿Escala de depresión?', opciones: ['RASS', 'PHQ-9', 'CAM-ICU', 'SOFA'], correcta: 1, explicacion: 'PHQ-9 evalúa depresión. >10 puntos sugiere depresión mayor.'),
    QuizPregunta(pregunta: '¿Ansiedad generalizada?', opciones: ['<1 mes', '>6 meses', 'Solo crisis', '>1 año'], correcta: 1, explicacion: 'TAG: preocupación excesiva >6 meses.'),
    QuizPregunta(pregunta: '¿Riesgo suicida mayor?', opciones: ['Ideación', 'Plan', 'Intento previo', 'Todos'], correcta: 3, explicacion: 'A mayor número de factores, mayor riesgo. Intento previo es el mayor predictor.'),
    QuizPregunta(pregunta: '¿Contención mecánica?', opciones: ['Primera opción', 'Último recurso', 'Nunca', 'Solo noche'], correcta: 1, explicacion: 'Contención es último recurso, requiere reevaluación c/2h.'),
    QuizPregunta(pregunta: '¿Trastorno bipolar?', opciones: ['Solo depresión', 'Solo manía', 'Manía + depresión', 'Ansiedad'], correcta: 2, explicacion: 'Bipolar: fases maníaca (eufórica) y depresiva alternadas.'),
    QuizPregunta(pregunta: '¿Esquizofrenia síntoma positivo?', opciones: ['Abulia', 'Alucinaciones', 'Apatía', 'Anhedonia'], correcta: 1, explicacion: 'Síntomas positivos: alucinaciones, delirios. Negativos: abulia, apatía.'),
  ],
  'Pediatría': [
    QuizPregunta(pregunta: '¿FC normal RN?', opciones: ['80-100', '120-160', '140-180', '100-120'], correcta: 1, explicacion: 'FC RN normal 120-160 lpm.'),
    QuizPregunta(pregunta: '¿Fiebre lactante <3m?', opciones: ['>37.5°C', '>38°C', '>39°C', '>40°C'], correcta: 1, explicacion: 'Fiebre >38°C en <3m: estudio completo por riesgo infección grave.'),
    QuizPregunta(pregunta: '¿Deshidratación signo?', opciones: ['Pliegue + ojos hundidos', 'Fiebre', 'Taquicardia', 'Polipnea'], correcta: 0, explicacion: 'Pliegue cutáneo, ojos hundidos, mucosa seca y llanto sin lágrimas.'),
    QuizPregunta(pregunta: '¿Convulsión febril típica?', opciones: ['>30 min', '<15 min', 'Siempre daño', '>5 años'], correcta: 1, explicacion: 'Convulsión febril simple <15 min, 6m-5a, típicamente benigna.'),
    QuizPregunta(pregunta: '¿Peso al nacer se duplica?', opciones: ['2 meses', '4 meses', '6 meses', '12 meses'], correcta: 1, explicacion: 'Peso al nacer se duplica a los 4 meses y triplica al año.'),
  ],
  'Geriatría': [
    QuizPregunta(pregunta: '¿Delirio vs demencia?', opciones: ['Agudo vs crónico', 'Crónico vs agudo', 'Igual', 'No se diferencian'], correcta: 0, explicacion: 'Delirio: agudo, fluctuante. Demencia: crónico, progresivo.'),
    QuizPregunta(pregunta: '¿Escala Barthel evalúa?', opciones: ['Dolor', 'AVD básicas', 'Conciencia', 'Depresión'], correcta: 1, explicacion: 'Barthel evalúa 10 AVD: comer, bañarse, vestirse, etc.'),
    QuizPregunta(pregunta: '¿Polifarmacia?', opciones: ['>3 fármacos', '>5 fármacos', '>7 fármacos', '>10 fármacos'], correcta: 1, explicacion: 'Polifarmacia: >5 fármacos. Riesgo de interacciones y efectos adversos.'),
    QuizPregunta(pregunta: '¿Úlceras presión prevención?', opciones: ['Masaje', 'Cambios postura c/2h', 'Hielo', 'Alcohol'], correcta: 1, explicacion: 'Cambios posturales c/2h, nutrición, superficies especiales.'),
    QuizPregunta(pregunta: '¿Fragilidad criterio?', opciones: ['Peso estable', 'Pérdida peso + fatiga', 'Solo edad', 'Solo caídas'], correcta: 1, explicacion: 'Fragilidad: pérdida peso, fatiga, baja actividad, debilidad, velocidad lenta.'),
  ],
  'Epidemiología': [
    QuizPregunta(pregunta: '¿Incidencia mide?', opciones: ['Casos totales', 'Casos nuevos', 'Casos fatales', 'Casos reportados'], correcta: 1, explicacion: 'Incidencia: casos nuevos en período. Prevalencia: casos totales.'),
    QuizPregunta(pregunta: '¿Estudio cohorte?', opciones: ['Sigue expuestos/no expuestos', 'Casos y controles', 'Una medición', 'Experimental'], correcta: 0, explicacion: 'Cohorte sigue a expuestos y no expuestos en el tiempo.'),
    QuizPregunta(pregunta: '¿Sensibilidad?', opciones: ['VP/(VP+FN)', 'VN/(VN+FP)', 'VP/(VP+FP)', 'VN/(VN+FN)'], correcta: 0, explicacion: 'Sensibilidad = VP / (VP + FN). Detecta enfermos.'),
    QuizPregunta(pregunta: '¿Valor predictivo +?', opciones: ['VP/(VP+FN)', 'VN/(VN+FP)', 'VP/(VP+FP)', 'VN/(VN+FN)'], correcta: 2, explicacion: 'VPP = VP / (VP + FP). Probabilidad de tener la enfermedad si test positivo.'),
    QuizPregunta(pregunta: '¿RR = 1 significa?', opciones: ['Riesgo mayor', 'Riesgo menor', 'No asociación', 'Protección'], correcta: 2, explicacion: 'RR = 1: no hay asociación entre exposición y enfermedad.'),
  ],
};

List<Map<String, String>> _facts = [
  {'icon': '🧠', 'text': 'Cerebro consume 20% del O₂ total siendo solo 2% del peso corporal.'},
  {'icon': '🫀', 'text': 'GC reposo ~5 L/min, en ejercicio intenso hasta 25 L/min.'},
  {'icon': '🔬', 'text': 'Adulto tiene 5-7% de sangre total ≈ 5L.'},
  {'icon': '🧪', 'text': 'Riñón filtra 180 L de plasma al día, reabsorbiendo 99%.'},
  {'icon': '🩺', 'text': 'Corazón late ~100,000 veces/día, bombea ~7,570 L de sangre.'},
  {'icon': '🫁', 'text': 'Pulmones tienen ~300 millones de alvéolos, superficie ~70 m².'},
  {'icon': '🩻', 'text': 'Esqueleto adulto tiene 206 huesos; al nacer ~270.'},
  {'icon': '🧬', 'text': 'Hígado realiza >500 funciones vitales, único órgano que se regenera.'},
  {'icon': '🧂', 'text': 'Osmolaridad plasmática normal: 285-295 mOsm/L.'},
  {'icon': '🩸', 'text': 'Sangre: 55% plasma, 45% células ~5L total.'},
  {'icon': '💪', 'text': 'Músculo cardíaco consume 70-80% ácidos grasos como energía.'},
  {'icon': '👁️', 'text': 'Ojo humano distingue ~10 millones de colores.'},
  {'icon': '🫀', 'text': 'PA media normal: 70-105 mmHg.'},
  {'icon': '🦴', 'text': 'Médula ósea produce ~200 mil millones de glóbulos rojos/día.'},
  {'icon': '🧪', 'text': 'pH sanguíneo normal: 7.35-7.45.'},
  {'icon': '🫁', 'text': 'Volumen corriente reposo: ~500 mL por respiración.'},
  {'icon': '🧬', 'text': 'Insulina descubierta en 1921 por Banting y Best.'},
  {'icon': '🩺', 'text': 'Florence Nightingale fundó la enfermería moderna en 1860.'},
  {'icon': '🔬', 'text': 'Células sanguíneas: eritrocitos 120 días, plaquetas 7-10 días, neutrófilos horas.'},
  {'icon': '🫀', 'text': 'Un minuto de RCP de calidad duplica supervivencia en paro cardíaco.'},
];

List<Map<String, dynamic>> _defaultSubjects = [
  {'nombre': 'Cardiología', 'icono': '🫀'},
  {'nombre': 'Neonatología', 'icono': '👶'},
  {'nombre': 'Farmacología', 'icono': '💊'},
  {'nombre': 'Anatomía', 'icono': '🦴'},
  {'nombre': 'Fundamentos PAE', 'icono': '📋'},
  {'nombre': 'Examen Mixto', 'icono': '🎯'},
  {'nombre': 'Cuidados Intensivos', 'icono': '🆘'},
  {'nombre': 'Enfermería Quirúrgica', 'icono': '🔪'},
  {'nombre': 'Salud Mental', 'icono': '🧠'},
  {'nombre': 'Pediatría', 'icono': '🧸'},
  {'nombre': 'Geriatría', 'icono': '👴'},
  {'nombre': 'Epidemiología', 'icono': '🦠'},
];

class EducationScreen extends StatefulWidget {
  const EducationScreen({super.key});

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  String _userEmail = '';
  bool _loggedIn = false;

  List<Map<String, dynamic>> _subjects = [];
  int _selectedSubject = 0;
  late TabController _tabController;

  int _flashcardIndex = 0;
  bool _isFlipped = false;

  int _quizIndex = 0;
  int? _selectedAnswer;
  bool _quizAnswered = false;
  int _stars = 0;
  int _correctCount = 0;
  int _totalAnswered = 0;

  int _streak = 0;
  DateTime? _lastStudyDate;

  bool _examMode = false;
  int _examTimeSeconds = 0;
  Timer? _examTimer;
  static const int _examDuration = 180;

  String _currentFact = '';
  bool _loading = true;

  Map<String, List<Flashcard>> _flashcardCache = {};
  Map<String, List<QuizPregunta>> _quizCache = {};

  bool _useApiData = false;

  // ─── Gamificación ───
  int get _level {
    if (_stars >= 500) return 10;
    if (_stars >= 400) return 9;
    if (_stars >= 300) return 8;
    if (_stars >= 220) return 7;
    if (_stars >= 150) return 6;
    if (_stars >= 90) return 5;
    if (_stars >= 50) return 4;
    if (_stars >= 25) return 3;
    if (_stars >= 10) return 2;
    if (_stars >= 5) return 1;
    return 0;
  }

  String get _levelTitle {
    const titles = [
      'Novato', 'Estudiante', 'Aprendiz', 'Enfermero Jr.',
      'Enfermero', 'Enfermero Sr.', 'Supervisor', 'Jefe de Sala',
      'Director Clínico', 'Jefe de Enfermería', 'Doctor Honoris Causa'
    ];
    return titles[_level.clamp(0, 10)];
  }

  int _starsForNextLevel() {
    const thresholds = [0, 5, 10, 25, 50, 90, 150, 220, 300, 400, 500];
    if (_level >= 10) return 0;
    return thresholds[_level + 1] - _stars;
  }

  List<Map<String, dynamic>> get _achievements {
    final list = <Map<String, dynamic>>[];
    if (_stars >= 10) list.add({'icon': '⭐', 'name': 'Primeras Estrellas', 'desc': 'Gana 10 estrellas'});
    if (_stars >= 50) list.add({'icon': '🔥', 'name': 'Racha de Fuego', 'desc': 'Gana 50 estrellas'});
    if (_stars >= 100) list.add({'icon': '🏆', 'name': 'Centenario', 'desc': 'Gana 100 estrellas'});
    if (_streak >= 3) list.add({'icon': '📅', 'name': 'Constante', 'desc': '3 días de racha'});
    if (_streak >= 7) list.add({'icon': '📅', 'name': 'Dedicado', 'desc': '7 días de racha'});
    if (_totalAnswered >= 10) list.add({'icon': '📝', 'name': 'Aprendiz', 'desc': 'Responde 10 preguntas'});
    if (_totalAnswered >= 50) list.add({'icon': '📝', 'name': 'Estudioso', 'desc': 'Responde 50 preguntas'});
    if (_correctCount >= 10 && _totalAnswered > 0 && _masteryPercent >= 90) list.add({'icon': '🎯', 'name': 'Precisión', 'desc': '90%+ en respuestas'});
    if (_subjects.length >= 6) list.add({'icon': '📚', 'name': 'Polímata', 'desc': 'Estudia 6+ materias'});
    return list;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
    _loadData();
    _pickRandomFact();
    _loadStreak();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _tabController.dispose();
    _examTimer?.cancel();
    super.dispose();
  }

  void _loadStreak() {
    final saved = _lastStudyDate;
    final now = DateTime.now();
    if (saved != null) {
      final diff = now.difference(saved).inDays;
      if (diff == 1) {
        _streak++;
      } else if (diff > 1) {
        _streak = 0;
      }
    }
    _lastStudyDate = now;
  }

  Future<void> _loadData() async {
    try {
      final raw = await ApiService.getEducationSubjects();
      if (raw.isNotEmpty && raw.first.containsKey('nombre')) {
        _subjects = raw;
      } else {
        _subjects = List.from(raw.map((s) => {'nombre': s['nombre'] ?? s['name'] ?? '', 'icono': s['icono'] ?? '📚'}));
      }
      if (_subjects.isNotEmpty) {
        _useApiData = true;
        _loading = false;
        _loadSubjectData(_subjects[0]['nombre']);
        return;
      }
    } catch (_) {}

    setState(() {
      _subjects = List.from(_defaultSubjects);
      _useApiData = false;
      _loading = false;
    });
  }

  Future<void> _loadSubjectData(String subject) async {
    if (!_useApiData) return;
    try {
      final apiFlashcards = await ApiService.getEducationFlashcards(subject);
      if (apiFlashcards.isNotEmpty) {
        _flashcardCache[subject] = apiFlashcards.map((f) => Flashcard(
          f['pregunta'] ?? f['frontal'] ?? f['question'] ?? '',
          f['respuesta'] ?? f['reverso'] ?? f['answer'] ?? '',
        )).toList();
      }
    } catch (_) {}

    try {
      final apiQuizzes = await ApiService.getEducationQuizzes(subject);
      if (apiQuizzes.isNotEmpty) {
        _quizCache[subject] = apiQuizzes.map((q) {
          final ops = List<String>.from(q['opciones'] ?? q['options'] ?? []);
          return QuizPregunta(
            pregunta: q['pregunta'] ?? q['question'] ?? '',
            opciones: ops,
            correcta: q['correcta'] ?? q['respuesta_correcta'] ?? q['correct'] ?? 0,
            explicacion: q['explicacion'] ?? q['explanation'] ?? '',
          );
        }).toList();
      }
    } catch (_) {}

    setState(() {
      _flashcardIndex = 0;
      _isFlipped = false;
      _quizIndex = 0;
      _selectedAnswer = null;
      _quizAnswered = false;
      _correctCount = 0;
      _totalAnswered = 0;
      _examMode = false;
      _examTimer?.cancel();
    });
  }

  Future<void> _pickRandomFact() async {
    try {
      final fact = await ApiService.getFactOfDay();
      final datoCurioso = fact['dato_curioso'];
      if (datoCurioso is Map && datoCurioso['dato'] is String) {
        _currentFact = '🧠 ${datoCurioso['dato']}';
        return;
      }
    } catch (_) {}
    final rng = Random();
    final f = _facts[rng.nextInt(_facts.length)];
    _currentFact = '${f['icon']} ${f['text']}';
  }

  List<Flashcard> get _currentFlashcards {
    final subject = _subjects.isNotEmpty ? _subjects[_selectedSubject]['nombre'] as String : 'Cardiología';
    return _flashcardCache[subject] ?? (_flashcardsData[subject] ?? []);
  }

  List<QuizPregunta> get _currentQuizzes {
    final subject = _subjects.isNotEmpty ? _subjects[_selectedSubject]['nombre'] as String : 'Cardiología';
    return _quizCache[subject] ?? (_quizzesData[subject] ?? []);
  }

  int get _masteryPercent {
    final total = _totalAnswered;
    if (total == 0) return 0;
    return (_correctCount / total * 100).round();
  }

  void _selectSubject(int index) {
    setState(() {
      _selectedSubject = index;
      _flashcardIndex = 0;
      _isFlipped = false;
      _quizIndex = 0;
      _selectedAnswer = null;
      _quizAnswered = false;
      _correctCount = 0;
      _totalAnswered = 0;
      _examMode = false;
      _examTimer?.cancel();
    });
    final subject = _subjects[index]['nombre'] as String;
    _loadSubjectData(subject);
  }

  void _randomSubject() {
    final rng = Random();
    _selectSubject(rng.nextInt(_subjects.length));
  }

  void _nextFlashcard() {
    final cards = _currentFlashcards;
    if (_flashcardIndex < cards.length - 1) {
      setState(() { _flashcardIndex++; _isFlipped = false; });
    }
  }

  void _prevFlashcard() {
    if (_flashcardIndex > 0) {
      setState(() { _flashcardIndex--; _isFlipped = false; });
    }
  }

  void _answerQuiz(int idx) {
    if (_quizAnswered) return;
    final preguntas = _currentQuizzes;
    if (preguntas.isEmpty) return;
    final correcta = preguntas[_quizIndex].correcta;
    setState(() {
      _selectedAnswer = idx;
      _quizAnswered = true;
      _totalAnswered++;
      if (idx == correcta) {
        _stars += 3;
        _correctCount++;
      }
    });
  }

  void _nextQuiz() {
    final preguntas = _currentQuizzes;
    if (_quizIndex < preguntas.length - 1) {
      setState(() { _quizIndex++; _selectedAnswer = null; _quizAnswered = false; });
    }
  }

  void _prevQuiz() {
    if (_quizIndex > 0) {
      setState(() { _quizIndex--; _selectedAnswer = null; _quizAnswered = false; });
    }
  }

  void _startExamMode() {
    final preguntas = _currentQuizzes;
    if (preguntas.isEmpty) return;
    setState(() {
      _examMode = true;
      _examTimeSeconds = _examDuration;
      _quizIndex = 0;
      _selectedAnswer = null;
      _quizAnswered = false;
      _correctCount = 0;
      _totalAnswered = 0;
    });
    _examTimer?.cancel();
    _examTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_examTimeSeconds <= 1) {
        timer.cancel();
        setState(() { _examMode = false; });
        return;
      }
      setState(() { _examTimeSeconds--; });
    });
  }

  String get _examTimeDisplay {
    final m = (_examTimeSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_examTimeSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Color _examTimeColor(ColorScheme cs) {
    if (_examTimeSeconds > 120) return cs.secondary;
    if (_examTimeSeconds > 60) return cs.tertiary;
    return cs.error;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Educación'),
        actions: [
          IconButton(
            icon: Icon(Icons.shuffle_rounded, color: cs.primary),
            tooltip: 'Materia aleatoria',
            onPressed: _randomSubject,
          ),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildHeader(cs),
                _buildFactBar(cs),
                _buildSubjectSelector(cs),
                Row(
                  children: [
                    _buildProgressBar(cs),
                    if (_currentQuizzes.isNotEmpty && !_examMode)
                      _buildExamButton(cs),
                    _buildStreakBadge(cs),
                  ],
                ),
                TabBar(
                  controller: _tabController,
                  tabs: [
                    Tab(child: Text('Fichas', style: TextStyle(fontWeight: FontWeight.w500))),
                    Tab(child: Text('Quiz${_examMode ? ' ⏱ $_examTimeDisplay' : ''}', style: TextStyle(fontWeight: FontWeight.w500))),
                    Tab(child: Text('Resumen', style: TextStyle(fontWeight: FontWeight.w500))),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildFlashcardsTab(cs),
                      _buildQuizzesTab(cs),
                      _buildDossieresTab(cs),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildHeader(ColorScheme cs) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primary.withValues(alpha: 0.08), cs.secondary.withValues(alpha: 0.04)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.school_rounded, color: cs.primary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Educación', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: cs.onSurface)),
                Text('$_stars ⭐ • $_streak 🔥 • Nv.$_level $_levelTitle', style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
              ],
            ),
          ),
          if (!_loggedIn)
            FilledButton.tonalIcon(
              onPressed: () => _showLoginDialog(context),
              icon: const Icon(Icons.person_outline_rounded, size: 18),
              label: const Text('Login', style: TextStyle(fontSize: 12)),
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6)),
            )
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star_rounded, color: cs.tertiary, size: 20),
                const SizedBox(width: 4),
                Text('$_stars', style: TextStyle(fontWeight: FontWeight.bold, color: cs.tertiary)),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 14,
                  backgroundColor: cs.primary.withValues(alpha: 0.12),
                  child: Icon(Icons.person_rounded, size: 16, color: cs.primary),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _showLoginDialog(BuildContext context) async {
    final cs = Theme.of(context).colorScheme;
    final ctrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Iniciar sesión', style: TextStyle(color: cs.onSurface)),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(onPressed: () {
            if (ctrl.text.trim().isNotEmpty) {
              setState(() { _userEmail = ctrl.text.trim(); _loggedIn = true; });
              Navigator.pop(ctx);
            }
          }, child: const Text('Iniciar')),
        ],
      ),
    );
    ctrl.dispose();
  }

  Widget _buildFactBar(ColorScheme cs) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cs.tertiary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text('💡', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(_currentFact, style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant), maxLines: 2),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectSelector(ColorScheme cs) {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        itemCount: _subjects.length,
        itemBuilder: (_, i) {
          final s = _subjects[i];
          final sel = i == _selectedSubject;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: ChoiceChip(
              selected: sel,
              label: Text('${s['icono'] ?? '📚'} ${s['nombre']}', style: TextStyle(fontSize: 12)),
              onSelected: (_) => _selectSubject(i),
              visualDensity: VisualDensity.compact,
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgressBar(ColorScheme cs) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text('Dominio: $_masteryPercent%', style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
                const SizedBox(width: 8),
                Text('$_correctCount/$_totalAnswered correctas', style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
              ],
            ),
            const SizedBox(height: 3),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _totalAnswered > 0 ? _correctCount / _totalAnswered : 0,
                minHeight: 6,
                backgroundColor: cs.surfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExamButton(ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: TextButton.icon(
        onPressed: _startExamMode,
        icon: Icon(Icons.timer_rounded, size: 16, color: cs.error),
        label: Text('Examen', style: TextStyle(fontSize: 11, color: cs.error)),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }

  Widget _buildStreakBadge(ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: _streak > 0 ? cs.tertiary.withValues(alpha: 0.12) : cs.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.local_fire_department_rounded, size: 14, color: _streak > 0 ? cs.tertiary : cs.onSurfaceVariant),
            const SizedBox(width: 3),
            Text('$_streak', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _streak > 0 ? cs.tertiary : cs.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  Widget _buildFlashcardsTab(ColorScheme cs) {
    final cards = _currentFlashcards;
    if (cards.isEmpty) {
      return Center(child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.credit_card_rounded, size: 48, color: cs.onSurfaceVariant.withValues(alpha: 0.3)),
          const SizedBox(height: 12),
          Text('Sin fichas', style: TextStyle(color: cs.onSurfaceVariant)),
        ],
      ));
    }
    final card = cards[_flashcardIndex];
    final progress = (_flashcardIndex + 1) / cards.length;

    return Column(
      children: [
        const SizedBox(height: 4),
        Text('${_flashcardIndex + 1} de ${cards.length}', style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
        const SizedBox(height: 2),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(value: progress, minHeight: 3, backgroundColor: cs.surfaceVariant),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _isFlipped = !_isFlipped),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Card(
                  key: ValueKey('${_flashcardIndex}_$_isFlipped'),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: cs.outlineVariant)),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isFlipped ? Icons.lightbulb_rounded : Icons.help_outline_rounded,
                          color: _isFlipped ? cs.tertiary : cs.primary,
                          size: 32,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _isFlipped ? card.respuesta : card.pregunta,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: _isFlipped ? cs.tertiary : cs.onSurface,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _isFlipped ? 'Toca para ver pregunta' : 'Toca para ver respuesta',
                          style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton.filledTonal(
                onPressed: _flashcardIndex > 0 ? _prevFlashcard : null,
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              IconButton(
                onPressed: _isFlipped ? null : () => setState(() => _isFlipped = true),
                icon: const Icon(Icons.flip_rounded),
                color: cs.primary,
                tooltip: 'Voltear',
              ),
              IconButton.filledTonal(
                onPressed: _flashcardIndex < cards.length - 1 ? _nextFlashcard : null,
                icon: const Icon(Icons.arrow_forward_rounded),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuizzesTab(ColorScheme cs) {
    final preguntas = _currentQuizzes;
    if (preguntas.isEmpty) {
      return Center(child: Text('Sin preguntas', style: TextStyle(color: cs.onSurfaceVariant)));
    }
    final q = _quizIndex < preguntas.length ? preguntas[_quizIndex] : preguntas.last;
    final isLast = _quizIndex == preguntas.length - 1;

    return Column(
      children: [
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Pregunta ${_quizIndex + 1}/${preguntas.length}', style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
            if (_examMode) ...[
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _examTimeColor(cs).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('⏱ $_examTimeDisplay', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _examTimeColor(cs))),
              ),
            ],
            const SizedBox(width: 12),
            Text('+3 ⭐', style: TextStyle(fontSize: 11, color: cs.tertiary)),
          ],
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: cs.outlineVariant)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(Icons.quiz_rounded, color: cs.primary, size: 24),
                  const SizedBox(height: 12),
                  Text(q.pregunta, textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: cs.onSurface, height: 1.3)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: q.opciones.length,
            itemBuilder: (_, i) {
              final isSelected = _selectedAnswer == i;
              final isCorrect = i == q.correcta;
              Color bg; Color border;
              if (!_quizAnswered) {
                bg = cs.surfaceVariant; border = cs.outlineVariant;
              } else if (isCorrect) {
                bg = cs.secondary.withValues(alpha: 0.12); border = cs.secondary;
              } else if (isSelected) {
                bg = cs.error.withValues(alpha: 0.08); border = cs.error;
              } else {
                bg = cs.surfaceVariant; border = cs.outlineVariant;
              }
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: InkWell(
                  onTap: () => _answerQuiz(i),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: border, width: 1.5),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 24, height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _quizAnswered && isCorrect
                                ? cs.secondary
                                : _quizAnswered && isSelected && !isCorrect
                                    ? cs.error
                                    : cs.onSurfaceVariant.withValues(alpha: 0.15),
                          ),
                          child: Center(child: Text('${String.fromCharCode(65 + i)}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _quizAnswered ? cs.surface : cs.onSurfaceVariant))),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(q.opciones[i], style: TextStyle(fontSize: 14, color: cs.onSurface))),
                        if (_quizAnswered && isCorrect)
                          Icon(Icons.check_circle_rounded, color: cs.secondary, size: 20),
                        if (_quizAnswered && isSelected && !isCorrect)
                          Icon(Icons.cancel_rounded, color: cs.error, size: 20),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (_quizAnswered && q.explicacion.isNotEmpty)
          Container(
            margin: const EdgeInsets.fromLTRB(20, 4, 20, 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, size: 16, color: cs.primary),
                const SizedBox(width: 8),
                Expanded(child: Text(q.explicacion, style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant))),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_quizIndex > 0)
                IconButton.filledTonal(
                  onPressed: _prevQuiz, icon: const Icon(Icons.skip_previous_rounded), iconSize: 20,
                ),
              const SizedBox(width: 8),
              if (_quizAnswered && !isLast)
                FilledButton.icon(
                  onPressed: _nextQuiz,
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  label: Text('Siguiente', style: TextStyle(fontSize: 14)),
                ),
              if (_quizAnswered && isLast)
                FilledButton.icon(
                  onPressed: () {
                    setState(() {
                      _quizIndex = 0;
                      _selectedAnswer = null;
                      _quizAnswered = false;
                      if (_examMode) { _examMode = false; _examTimer?.cancel(); }
                    });
                  },
                  icon: Icon(_examMode ? Icons.assignment_turned_in_rounded : Icons.replay_rounded, size: 18),
                  label: Text(_examMode ? 'Finalizar' : 'Reiniciar', style: TextStyle(fontSize: 14)),
                  style: FilledButton.styleFrom(backgroundColor: _examMode ? cs.primary : cs.tertiary),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDossieresTab(ColorScheme cs) {
    final subject = _subjects.isNotEmpty ? _subjects[_selectedSubject]['nombre'] as String : '';
    final cards = _currentFlashcards;
    final preguntas = _currentQuizzes;

    final imagenUrl = _subjects.isNotEmpty ? (_subjects[_selectedSubject]['imagen'] as String? ?? '') : '';
    final imagenLicencia = _subjects.isNotEmpty ? (_subjects[_selectedSubject]['imagen_licencia'] as String? ?? '') : '';
    final imagenAtribucion = _subjects.isNotEmpty ? (_subjects[_selectedSubject]['imagen_atribucion'] as String? ?? '') : '';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (imagenUrl.isNotEmpty)
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: cs.outlineVariant)),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    '${ApiService.baseUrl}$imagenUrl',
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 180,
                      color: cs.surfaceVariant,
                      child: Center(child: Icon(Icons.broken_image_rounded, color: cs.onSurfaceVariant)),
                    ),
                    loadingBuilder: (_, child, progress) => progress == null ? child : Container(
                      height: 180,
                      color: cs.surfaceVariant,
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
                  ),
                ),
                if (imagenLicencia.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                    child: Text(
                      '$imagenLicencia — $imagenAtribucion',
                      style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: cs.outlineVariant)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.analytics_rounded, color: cs.primary, size: 22),
                    const SizedBox(width: 8),
                    Text('Progreso en $subject', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: cs.onSurface)),
                  ],
                ),
                const SizedBox(height: 16),
                _statRow(cs, Icons.credit_card_rounded, 'Fichas', '${cards.length} disponibles', cs.primary),
                const SizedBox(height: 8),
                _statRow(cs, Icons.quiz_rounded, 'Preguntas', '${preguntas.length} disponibles', cs.secondary),
                const SizedBox(height: 8),
                _statRow(cs, Icons.star_rounded, 'Estrellas', '$_stars obtenidas', cs.tertiary),
                const SizedBox(height: 8),
                _statRow(cs, Icons.track_changes_rounded, 'Dominio', '$_masteryPercent%', _masteryPercent > 60 ? cs.secondary : cs.primary),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: _totalAnswered > 0 ? _correctCount / _totalAnswered : 0,
                    minHeight: 8,
                    backgroundColor: cs.surfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: cs.outlineVariant)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.tips_and_updates_rounded, color: cs.tertiary, size: 22),
                    const SizedBox(width: 8),
                    Text('Tips de Estudio', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: cs.onSurface)),
                  ],
                ),
                const SizedBox(height: 12),
                _tipItem(cs, 'Usa Fichas para memorización rápida'),
                _tipItem(cs, 'Completa Quizzes para autoevaluación'),
                _tipItem(cs, 'Activa modo Examen con tiempo límite'),
                _tipItem(cs, 'Mantén racha diaria para mejorar retención'),
                _tipItem(cs, 'Repasa materias con Juego Aleatorio 🎰'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        _buildLevelCard(cs),
        if (_achievements.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildAchievementsCard(cs),
        ],
        const SizedBox(height: 8),
        _buildDailyChallengesCard(cs),
        if (_loggedIn) ...[
          const SizedBox(height: 8),
          _buildRanking(cs),
        ],
        const SizedBox(height: 8),
        Center(
          child: TextButton.icon(
            onPressed: _randomSubject,
            icon: const Text('🎰', style: TextStyle(fontSize: 18)),
            label: Text('Materia aleatoria', style: TextStyle(color: cs.primary)),
          ),
        ),
      ],
    );
  }

  Widget _buildLevelCard(ColorScheme cs) {
    final next = _starsForNextLevel();
    final progress = _level >= 10 ? 1.0 : (_stars / (_stars + next + 1)).clamp(0.0, 1.0);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: cs.outlineVariant)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_graph_rounded, color: cs.primary, size: 22),
                const SizedBox(width: 8),
                Text('Nivel $_level — $_levelTitle', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface)),
              ],
            ),
            const SizedBox(height: 12),
            if (_level < 10) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(value: progress, minHeight: 8, backgroundColor: cs.surfaceVariant),
              ),
              const SizedBox(height: 6),
              Text('$_stars estrellas', style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
            ] else
              Text('¡Nivel máximo alcanzado!', style: TextStyle(fontSize: 13, color: cs.tertiary, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsCard(ColorScheme cs) {
    final logros = _achievements;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: cs.outlineVariant)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.emoji_events_rounded, color: cs.tertiary, size: 22),
                const SizedBox(width: 8),
                Text('Logros (${logros.length})', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface)),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: logros.map((l) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: cs.primary.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(l['icon'] as String, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 4),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l['name'] as String, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: cs.onSurface)),
                          Text(l['desc'] as String, style: TextStyle(fontSize: 9, color: cs.onSurfaceVariant)),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyChallengesCard(ColorScheme cs) {
    final challenges = [
      {'icon': '✅', 'text': 'Responder 5 quizzes hoy', 'done': _totalAnswered >= 5},
      {'icon': '📚', 'text': 'Estudiar 2 materias distintas', 'done': _selectedSubject >= 0},
      {'icon': '🔥', 'text': 'Mantener racha activa', 'done': _streak > 0},
      {'icon': '💯', 'text': 'Obtener 100% en un quiz', 'done': _totalAnswered > 0 && _masteryPercent == 100},
    ];
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: cs.outlineVariant)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.task_alt_rounded, color: cs.secondary, size: 22),
                const SizedBox(width: 8),
                Text('Desafíos diarios', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface)),
              ],
            ),
            const SizedBox(height: 12),
            ...challenges.map((c) {
              final done = c['done'] as bool;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    Icon(done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                      size: 18, color: done ? cs.secondary : cs.onSurfaceVariant),
                    const SizedBox(width: 8),
                    Text('${c['icon']} ${c['text']}', style: TextStyle(fontSize: 13, color: done ? cs.secondary : cs.onSurfaceVariant)),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _statRow(ColorScheme cs, IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 10),
        Text(label, style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant)),
        const Spacer(),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: cs.onSurface)),
      ],
    );
  }

  Widget _tipItem(ColorScheme cs, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(color: cs.primary)),
          Expanded(child: Text(text, style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant))),
        ],
      ),
    );
  }

  Widget _buildRanking(ColorScheme cs) {
    final rankings = [
      {'email': _userEmail, 'stars': _stars, 'highlight': true},
      {'email': 'maria@enfermeria.com', 'stars': 42, 'highlight': false},
      {'email': 'carlos@hospital.cl', 'stars': 38, 'highlight': false},
      {'email': 'ana@clinica.com', 'stars': 31, 'highlight': false},
      {'email': 'luis@urgencias.cl', 'stars': 27, 'highlight': false},
    ];
    rankings.sort((a, b) => (b['stars'] as int).compareTo(a['stars'] as int));

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: cs.outlineVariant)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.leaderboard_rounded, color: cs.tertiary, size: 22),
                const SizedBox(width: 8),
                Text('Ranking', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: cs.onSurface)),
              ],
            ),
            const SizedBox(height: 12),
            ...rankings.asMap().entries.map((entry) {
              final idx = entry.key;
              final r = entry.value;
              final isUser = r['highlight'] as bool;
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                margin: const EdgeInsets.symmetric(vertical: 2),
                decoration: BoxDecoration(
                  color: isUser ? cs.primary.withValues(alpha: 0.06) : null,
                  borderRadius: BorderRadius.circular(8),
                  border: isUser ? Border.all(color: cs.primary.withValues(alpha: 0.3)) : null,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 28,
                      child: Text('#${idx + 1}', style: TextStyle(
                        fontSize: 13, fontWeight: isUser ? FontWeight.bold : FontWeight.normal,
                        color: isUser ? cs.primary : cs.onSurfaceVariant,
                      )),
                    ),
                    Icon(Icons.person_rounded, size: 16, color: isUser ? cs.primary : cs.onSurfaceVariant),
                    const SizedBox(width: 6),
                    Expanded(child: Text(r['email'] as String, style: TextStyle(
                      fontSize: 13, color: isUser ? cs.primary : cs.onSurfaceVariant,
                      fontWeight: isUser ? FontWeight.bold : FontWeight.normal,
                    ))),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star_rounded, size: 14, color: cs.tertiary),
                        const SizedBox(width: 2),
                        Text('${r['stars']}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isUser ? cs.tertiary : cs.onSurfaceVariant)),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

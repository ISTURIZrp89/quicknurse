import re

# Reglas clinicas offline en espanol - triage multinivel
# Cada patron: regex -> (diagnostico, confianza, recomendacion)

TRIAJE_REGLAS = [
    # CARDIOVASCULAR
    (r"(dolor\s+(de?\s+)?pecho|dolor\s+en\s+el\s+pecho|presion\s+en\s+el\s+pecho|infarto|paro\s+cardiaco|angina)",
     "Sindrome Coronario Agudo", 0.95, "EMERGENCIA - Llame 911/112 inmediatamente"),
    (r"(palpitaciones|corazon\s+rapido|taquicardia|arritmia|latido\s+irregular)",
     "Arritmia Cardiaca", 0.85, "URGENTE - Valoracion cardiologica en 1h"),
    (r"(hipertension|presion\s+alta|PA\s+alta|tension\s+alta)",
     "Hipertension Arterial", 0.85, "Control PA cada 15min - Evaluar dano organo diana"),
    # RESPIRATORIO
    (r"(dificultad\s+para\s+respirar|disnea|falta\s+de\s+aire|ahogo|insuficiencia\s+respiratoria)",
     "Insuficiencia Respiratoria", 0.88, "URGENTE - O2 suplementario, valorar gasometria"),
    (r"(tos\s+con\s+sangre|hemoptisis|esputo\s+sanguinolento)",
     "Hemoptisis", 0.90, "URGENTE - Evaluar origen pulmonar, posible TBC/neoplasia"),
    (r"(sibilancias|pito\s+pecho|broncoespasmo|asma|EPOC)",
     "Crisis Asmatica/EPOC", 0.85, "Broncodilatadores, O2, corticoides inhalados"),
    (r"(neumonia|fiebre\s+alta\s+tos|dolor\s+toracico\s+respirar|expectoracion\s+purulenta)",
     "Neumonia", 0.85, "Antibioticos, O2, radiografia de torax"),
    (r"(apnea|dejo\s+de\s+respirar|respiracion\s+agonica|paro\s+respiratorio)",
     "Paro Respiratorio", 0.98, "EMERGENCIA - RCP inmediato, 911/112, DEA"),
    # NEUROLOGIA
    (r"(derrame|ACV|ictus|hemiplejia|paralisis\s+repentina|perdida\s+fuerza|debilidad\s+un\s+lado)",
     "Accidente Cerebrovascular", 0.92, "EMERGENCIA - Codigo Ictus, ventana trombolisis 4.5h"),
    (r"(convulsion|ataque|epilepsia|crisis\s+comicial|status\s+epilepticus)",
     "Crisis Convulsiva", 0.90, "URGENTE - Proteger via aerea, benzodiacepinas si activa"),
    (r"(dolor\s+de\s+cabeza|cefalea|jaqueca|migrana|dolor\s+cabeza\s+intenso)",
     "Cefalea", 0.75, "Valorar signos alarma (rigidez nucal, focalizacion)"),
    (r"(meningitis|rigidez\s+nucal|fiebre\s+dolor\s+cabeza|petequias)",
     "Sospecha de Meningitis", 0.88, "EMERGENCIA - Puncion lumbar, antibioticos empiricos"),
    # GASTROINTESTINAL
    (r"(dolor\s+abdominal|dolor\s+barriga|dolor\s+vientre|abdomen\s+agudo)",
     "Dolor Abdominal", 0.75, "Valorar signos peritonismo, ayuno, cirugia si indicado"),
    (r"(vomito|nausea|emesis|arcadas)",
     "Nauseas/Vomitos", 0.75, "Antiemeticos, valorar deshidratacion, electrolitos"),
    (r"(diarrea|deposiciones\s+liquidas|gastroenteritis|enteritis)",
     "Gastroenteritis", 0.80, "Hidratacion oral/IV, loperamida si no hay sangre"),
    (r"(sangre\s+heces|melena|hematoquecia|recto\s+sangrante|sangre\s+en\s+popo)",
     "Hemorragia Digestiva", 0.88, "URGENTE - Endoscopia, monitoreo hemodinamico"),
    # INFECCIOSO
    (r"(covid|coronavirus|sars-cov-2|perdida\s+olor|perdida\s+gusto)",
     "COVID-19", 0.85, "Aislamiento, prueba, monitoreo sat O2"),
    (r"(tuberculosis|TBC|tos\s+cronica\s+fiebre|sudor\s+nocturno)",
     "Tuberculosis", 0.82, "Aislamiento, baciloscopia, tratamiento DOTS"),
    # SEPSIS / FIEBRE
    (r"(sepsis|septicemia|infeccion\s+generalizada|infeccion\s+grave)",
     "Sepsis", 0.88, "EMERGENCIA - Hemoquimio, ATB, liquidos, monitoreo"),
    (r"(fiebre|temperatura\s+alta|calentura|pirexia)",
     "Sindrome Febril", 0.75, "Antipireticos, valorar foco infeccioso, hemocultivos"),
    # TRAUMA
    (r"(fractura|hueso\s+roto|caida|traumatismo|accidente)",
     "Fractura/Trauma", 0.85, "Inmovilizar, radiografia, valorar necesidad de reduccion"),
    (r"(politrauma|accidente\s+automovil|atropello|caida\s+altura)",
     "Politraumatismo", 0.95, "EMERGENCIA - Codigo Trauma, inmovilizacion columna"),
    # PSIQUIATRIA
    (r"(suicidio|ideas\s+suicidas|querer\s+morir|autolesion|cortarse)",
     "Riesgo Suicida", 0.92, "EMERGENCIA - Evaluacion psiquiatrica urgente, seguridad"),
    (r"(ansiedad|nervios|ataque\s+panico|angustia|miedo\s+intenso)",
     "Crisis de Ansiedad", 0.80, "Contencion, tecnicas grounding, valorar benzodiacepinas"),
]

# Sintomas de alerta (red flags) que elevan prioridad
RED_FLAGS = [
    r"(dolor\s+pecho|disnea\s+reposo|saturacion\s+baja|hipoxemia)",
    r"(confusion|alteracion\s+conciencia|glasgow\s+bajo)",
    r"(tension\s+muy\s+baja|shock|hipotension\s+grave|PA\s+menor\s+90)",
    r"(fiebre\s+muy\s+alta|temperatura\s+mayor\s+39|hiperpirexia)",
    r"(sangrado\s+abundante|hemorragia\s+no\s+controla)",
    r"(dolor\s+intenso\s+10|escala\s+dolor\s+10)",
    r"(conmocion|craneoencefalico|trauma\s+craneal)",
    r"(embarazo\s+sangrado|amenaza\s+aborto|ectopico)",
]


def evaluar_sintomas(sintomas: str, age: int | None = None, sex: str | None = None, vital_signs: dict | None = None) -> dict:
    """Evalua sintomas contra reglas offline. Retorna diagnostico, confianza, recomendacion."""
    texto = sintomas.lower().strip()

    # Analisis de signos vitales para red flags automaticos
    vs_red_flag, vs_issues = analisis_signos_vitales(age, vital_signs)
    tiene_red_flag = any(re.search(rf, texto) for rf in RED_FLAGS) or vs_red_flag

    prioridad = "emergencia" if tiene_red_flag else "urgente"

    for patron, diagnosis, confianza, recomendacion in TRIAJE_REGLAS:
        if re.search(patron, texto):
            if tiene_red_flag:
                confianza = min(confianza + 0.1, 0.99)
                prioridad = "emergencia"
            if vs_issues:
                recomendacion += " | " + "; ".join(vs_issues)
            return {
                "diagnosis": diagnosis,
                "confidence": round(confianza, 2),
                "recommendation": recomendacion,
                "source": "offline_rules",
                "priority": prioridad,
                "red_flag": tiene_red_flag,
            }

    # Sin match en reglas: devolver observacion con signos vitales abnormal
    if vs_issues:
        return {
            "diagnosis": "Sintomas inespecificos con signos vitales anormales",
            "confidence": 0.55,
            "recommendation": "Vigilancia estrecha. Signos vitales: " + "; ".join(vs_issues),
            "source": "offline_rules_vital_signs",
            "priority": "urgente",
            "red_flag": vs_red_flag,
        }

    return {
        "diagnosis": "Síntomas inespecíficos",
        "confidence": 0.50,
        "recommendation": "Vigilancia por 24h. Si empeoran, buscar atencion medica.",
        "source": "offline_rules",
        "priority": prioridad,
        "red_flag": tiene_red_flag,
    }


def analisis_signos_vitales(age: int | None, vital_signs: dict | None) -> tuple[bool, list[str]]:
    """Analiza signos vitales y retorna (tiene_red_flag, lista_issues)."""
    if not vital_signs:
        return False, []
    issues = []
    red_flag = False

    if "spo2" in vital_signs:
        spo2 = vital_signs["spo2"]
        if spo2 < 85:
            issues.append(f"SpO2 {spo2}% - HIPEREMIA GRAVE")
            red_flag = True
        elif spo2 < 92:
            issues.append(f"SpO2 {spo2}% - HIPEREMIA")
            red_flag = True

    if "pa" in vital_signs and vital_signs["pa"]:
        pa_str = str(vital_signs["pa"])
        if "/" in pa_str:
            try:
                sys, dia = pa_str.split("/")
                sys = int(sys)
                dia = int(dia)
                if sys < 90 or dia < 60:
                    issues.append(f"PA {sys}/{dia} - HIPOTENSION GRAVE")
                    red_flag = True
                elif sys > 180 or dia > 120:
                    issues.append(f"PA {sys}/{dia} - HIPERTENSION GRAVE")
                    red_flag = True
            except:
                pass

    if "fc" in vital_signs:
        fc = vital_signs["fc"]
        if fc > 130:
            issues.append(f"FC {fc} - TAQUICARDIA GRAVE")
            red_flag = True
        elif fc < 50:
            issues.append(f"FC {fc} - BRADICARDIA GRAVE")
            red_flag = True
        elif fc > 110:
            issues.append(f"FC {fc} - TAQUICARDIA")

    if "temp" in vital_signs:
        temp = vital_signs["temp"]
        if temp > 39.5:
            issues.append(f"Temp {temp}C - HIPERPIREXIA")
            red_flag = True
        elif temp < 35:
            issues.append(f"Temp {temp}C - HIPOTERMIA")
            red_flag = True

    if age is not None and age < 2:
        issues.append(f"Edad {age} anios - PACIENTE PEDIATRICO VULNERABLE")
        red_flag = True

    return red_flag, issues
# Informe de resultats
### Enquesta d'avaluació de la coherència — Fundació Escola Cristiana de Catalunya (FECC)

*Anàlisi exploratòria sobre 143 respostes (102 amb docència directa). Escales Likert 1–7. Tots els resultats s'interpreten com a **tendències exploratòries**; el disseny és observacional i **correlacional ≠ causal**. Les xifres provenen de l'execució real del script `analisi_enquesta.R`.*

---

## 1. Mètode i decisions analítiques

**Constructes.** Tres blocs:
- **Bloc 1 · Funcionament de la xarxa** (17 ítems): coherència de propòsit, contextualització, comunicació/mediació, feedback, adaptació, lideratge, connexió multinivell, reflexió i confiança.
- **Bloc 2 · Sensació d'energia** (ít. 18, 19, 20) i **Recuperació energètica** (ít. 26, 27).
- **Bloc 3 · Alineament de propòsit vital–professió** (ít. 28, 29, 31).

**Decisions psicomètriques.** Inversió dels ítems redactats en negatiu (6, 13, 19, 27); **eliminació dels ítems 21 i 30** per baixa coherència amb la seva escala. Tota l'anàlisi es fa **en paral·lel amb l'estructura teòrica i amb l'estructura empírica** (derivada d'AFE).

**Tècniques.** Fiabilitat amb **omega de McDonald** (preferible a alfa en escales curtes). Comparacions de subgrups **no paramètriques** (Mann-Whitney / Kruskal-Wallis) per la no-normalitat Likert, amb **mides d'efecte** (r, ε², Cohen d) i **correcció per comparacions múltiples** (Holm/BH). Correlacions de **Spearman** amb IC 95% per bootstrap.

---

## 2. Descriptius dels constructes (escala 1–7)

| Constructe | Mitjana | DE | Lectura |
|---|---|---|---|
| **Alineament de propòsit** | **6,29** | 0,76 | Molt alt |
| **Funcionament de la xarxa** | **5,35** | 0,61 | Alt |
| Sensació d'energia | 4,84 | 0,75 | Mitjà |
| Recuperació energètica | 4,83 | 1,20 | Mitjà (molt dispers) |

L'alineament de propòsit personal–professional és el punt **més fort**; l'energia i la recuperació, els més baixos i (la recuperació) amb molta variabilitat entre persones.

---

## 3. Fiabilitat (omega de McDonald)

### 3.1 Blocs principals (estructura teòrica)
| Constructe | Ítems | α | **ω** | Valoració |
|---|---|---|---|---|
| Funcionament de la xarxa | 17 | 0,82 | **0,86** | Bona ✅ |
| Alineament de propòsit | 3 | 0,81 | **0,82** | Bona ✅ |
| Recuperació energètica | 2 | 0,61 | 0,63 | Feble ⚠️ |
| Sensació d'energia | 3 | 0,40 | 0,57 | Insuficient ⚠️ |

### 3.2 Dimensions teòriques del Bloc 1
| Dimensió | Ítems | ω | Valoració |
|---|---|---|---|
| D1 Coherència de propòsit | 1–4 | 0,83 | Bona |
| D3 Comunicació i mediació | 7, 8 | 0,83 | Bona |
| D4 Feedback i aprenentatge | 9, 10, 16 | 0,77 | Acceptable |
| D5 Adaptació | 11, 12 | 0,60 | Feble |
| D2, Dm, D6, D6.1, D7, D8 | 1 ítem | — | (no aplica) |

### 3.3 Factors empírics (els que recomano per a publicació)
**Bloc 1 → 3 factors empírics:**
| Factor empíric | Ítems | ω | Valoració |
|---|---|---|---|
| **EF3 · Coherència de propòsit i prioritats** | 1, 2, 3, 4, 5 | **0,85** | Bona ✅ |
| **EF2 · Funcionament de l'equip** (feedback, adaptació, reflexió) | 9, 10, 11, 12, 15 | **0,79** | Acceptable ✅ |
| **EF1 · Comunicació, connexió i confiança en la xarxa** | 7, 8, 14, 16, 17 | **0,83** | Bona ✅ |

*L'ítem 13 s'ha exclòs d'EF1 (vegeu §4.1); en excloure'l, la fiabilitat d'EF1 puja de 0,77 a 0,83.*

**Bloc 2 + 3 → 2 factors empírics:**
| Factor empíric | Ítems | ω | Valoració |
|---|---|---|---|
| **BF1 · Propòsit** | 28, 29, 31 | **0,82** | Bona ✅ |
| **BF2 · Energia + Recuperació** (fusionats) | 18, 19, 26, 27 | 0,67 | Feble ⚠️ |

**Destacat:** els **tres factors empírics del Bloc 1 són fiables** (ω 0,77–0,85), igual o millor que les dimensions teòriques fines. El bloc d'energia continua sent feble fins i tot en la versió empírica fusionada (ω 0,67).

---

## 4. Estructura factorial exploratòria (AFE)

### 4.1 Bloc 1
- Adequació correcta: **KMO = 0,75**; Bartlett **p < 0,001**.
- L'**anàlisi paral·lela suggereix 3 factors** (no les 8–9 dimensions teòriques previstes).
- Índexs d'ajust per nombre de factors:

| Solució | Variància explicada | TLI | RMSEA |
|---|---|---|---|
| 3 factors | 52,4 % | 0,63 | 0,157 |
| 4 factors | 59,3 % | 0,71 | 0,139 |
| 5 factors | 63,6 % | 0,74 | 0,130 |

- **Composició empírica vs teoria** (factor on carrega més cada ítem):

| Factor empíric | Recull les dimensions teòriques | Interpretació |
|---|---|---|
| EF3 | D1 + D2 | Coherència de propòsit i contextualització |
| EF2 | D4 + D5 + D7 | Vida i funcionament de l'equip propi |
| EF1 | D3 + D6.1 + D8 (+16) | Comunicació, connexió i confiança en el sistema |

- **Dos ítems queden fora dels índexs empírics** (es mantenen als constructes teòrics):
  - **Ítem 6** ("missatges contradictoris del sistema"): càrrega < 0,30 en tots els factors.
  - **Ítem 13** ("massa responsabilitats en les mateixes persones"): tot i parlar d'equip, empíricament **no carrega a l'equip** (0,21) sinó al factor de sistema amb **signe negatiu i contradictori** (−0,60) i amb càrrega repartida. En excloure'l, EF1 millora (ω 0,77 → 0,83). Tots dos són ítems redactats en negatiu.

### 4.2 Bloc 2 + 3 (validesa discriminant)
- KMO = 0,72; l'anàlisi paral·lela suggereix **2 factors**.
- **El propòsit se separa nítidament** com a factor propi; **l'energia i la recuperació NO es diferencien** empíricament (van juntes en un sol factor). Ajust de la solució de 2 factors: var = 49 %, TLI = 0,87, RMSEA = 0,114.
- **Conclusió:** la distinció teòrica energia vs recuperació no es sosté empíricament; el propòsit sí que és un constructe distint.

---

## 5. Relació entre coherència i energia — **P3** (resultat central)

Correlacions de Spearman entre les tres dimensions principals (IC 95% bootstrap), totes **significatives**:

| Relació | ρ | IC 95% |
|---|---|---|
| **Propòsit ↔ Energia** | **0,43** | [0,29 – 0,56] |
| Funcionament ↔ Propòsit | 0,38 | [0,22 – 0,51] |
| **Funcionament ↔ Energia** | **0,35** | [0,21 – 0,49] |

**Matriu de correlacions entre constructes (Spearman):**

| | Func. | Energia | Recup. | Propòsit |
|---|---|---|---|---|
| **Funcionament** | 1,00 | 0,35 | 0,16 | 0,38 |
| **Energia** | 0,35 | 1,00 | 0,39 | 0,43 |
| **Recuperació** | 0,16 | 0,39 | 1,00 | 0,30 |
| **Propòsit** | 0,38 | 0,43 | 0,30 | 1,00 |

**Quina faceta de coherència mou l'energia** (factors empírics del Bloc 1 ↔ energia):
- **EF2 · Equip propi**: ρ = 0,33 [0,18 – 0,48]
- **EF1 · Sistema/xarxa**: ρ = 0,32 [0,16 – 0,47]
- EF3 · Coherència de propòsit: ρ = 0,22 [0,07 – 0,38] ← la més feble

**Destacat (P3):** hi ha una **associació positiva moderada entre coherència i energia**. El vincle més fort és **propòsit ↔ energia**. Quan es descompon la coherència de xarxa, l'energia es lliga sobretot a les facetes **operatives i properes** —el funcionament de l'**equip propi** i la comunicació/confiança en el **sistema** (ρ ≈ 0,32–0,33)—, i menys a la coherència de propòsit institucional abstracte (ρ = 0,22). La **recuperació** és força independent de la coherència (ρ 0,05–0,16).

---

## 6. Diferències per subgrups — **P1 / P2**

### 6.1 Nivell jeràrquic
Kruskal-Wallis sobre els constructes: l'única diferència que **supera la correcció** és en el factor empíric **EF1 (comunicació/sistema)**: H = 13,7, **p_ajustada = 0,030**, ε² = 0,08 (efecte mitjà). El post-hoc de Dunn mostra que el grup **"Comunitat i altres agents"** (entitats FECC, Comité d'ètica) es diferencia significativament del **Nucli operatiu** (p = 0,003) i de la **Governança intermèdia** (p = 0,005). La resta de constructes són homogenis entre nivells.

### 6.2 Rol (multi-pertinença; Mann-Whitney)
| Rol (n) | Troballa | p |
|---|---|---|
| **Professorat** (21) | percep **menys coherència de sistema** | ≈ 0,006 |
| **Personal FECC** (17) | reporta **més energia** | ≈ 0,025 |
| **Titularitat** (35) | més coherència d'**equip propi** | ≈ 0,013 |

*(Prevalença multi-rol: Equip directiu 62, Titularitat 35, Professorat 21, GdE 18, Personal FECC 17, Entitat FECC 12, Resp. de xarxa 7, Comité d'ètica 5, PAS 1.)*

### 6.3 Etapa educativa (entre docents)
- **Primària** → més funcionament i coherència de propòsit (efecte gran, d ≈ 0,5; p creu el llindar després de corregir).
- **ESO** → menys coherència de propòsit.
- **FP** → més energia.

### 6.4 Xarxa d'escoles (denominació)
Aquesta comparació es fa **només sobre escoles** (respostes amb docència/intervenció directa, n = 102: **66 en xarxa** vs **36 independents**), per no barrejar-hi el personal FECC central. Restringint així, l'efecte **s'atenua** respecte de la mostra completa: pertànyer a una xarxa s'associa a puntuacions **lleugerament més baixes** en **coherència de propòsit** (dimensió D1 / factor EF3, p ≈ 0,04) i, com a tendència, en energia (p ≈ 0,05). La resta de constructes no difereixen significativament. *(La versió anterior sobre tota la mostra sobreestimava aquest efecte perquè el grup "no xarxa" incloïa personal central sense denominació.)*

### 6.5 Complexitat del centre i context territorial
**Sense diferències significatives.** Ni el tram de complexitat ni el servei territorial discriminen els constructes.

---

## 7. Projectes estratègics de la FECC (hipòtesi de participació)

Hipòtesi: els participants haurien de mostrar més coherència, energia i propòsit. Resultat **parcial i, en energia, contrari** (Cohen d amb signe; + = participants més alts):

| Projecte (n participants) | Coherència | Energia | Propòsit |
|---|---|---|---|
| **EeX** (25) | **+0,30 a +0,64** (factor empíric) | −0,23 | **+0,39** ✅ |
| EeXAMC (30) | −0,16 a −0,34 | **−0,36** | −0,04 ❌ |
| EdD (7) | −0,13 | −0,51 | −0,33 |
| **GdE** com a projecte (18) | sense guany | +0,19 | −0,13 |
| **Participar en algun** (61) | +0,05 | **−0,47** | +0,16 |

**Destacat:** només **EeX** s'associa a **més coherència i propòsit** (efecte notable en el factor empíric de propòsit, d = 0,64). En canvi, la **participació en projectes (sobretot EeXAMC) s'associa a menys energia**, amb un gradient dosi-resposta. Com que és observacional, pot reflectir **desgast** dels projectes o **autoselecció** (s'hi impliquen persones ja més estirades).

---

## 8. Variables de control

- **Trajectòria d'energia percebuda** (ítems 23 i 25): fort correlat de l'energia actual (ρ ≈ 0,37–0,40; p_ajustada < 0,001) i de la recuperació (ρ ≈ 0,27–0,33). Una direcció "creixent/estable" s'associa a energia alta; "decreixent/fluctuant", a energia baixa. Conjuntament expliquen **≈ 25 %** de la variància de l'energia.
- **Antiguitat al rol** (ítem 24): pràcticament **sense relació** amb cap constructe (lleu negativa amb funcionament, ρ = −0,17).
- **Nombre de rols** (polivalència): **no** s'associa a menys energia → la hipòtesi de sobrecàrrega **no es confirma** (fins i tot tendència lleugerament positiva).

---

## 9. Síntesi per orientar les entrevistes

1. **Coherència ↔ energia**: explorar com l'**alineament de propòsit** i la **coherència de l'equip proper** sostenen l'energia (els vincles més forts).
2. **Contrast de mirades**: el **professorat** percep el sistema/xarxa més fluix que el **personal FECC i la direcció** → indagar el perquè d'aquesta distància.
3. **Gradient jeràrquic**: la percepció de la mediació/sistema (EF1) diferencia el grup central (entitats FECC/Comité) de l'operatiu.
4. **Projectes**: entendre per què **EeX** s'associa a més coherència però la participació en general a **menys energia** (càrrega? selecció?).
5. **Energia fluctuant**: aprofundir en els qui viuen l'energia com a "alts i baixos", que puntuen tan baix com els qui la viuen en declivi.

---

## 10. Conclusions i limitacions

**Conclusions.**
1. Funcionament de la xarxa i alineament de propòsit són mesures **sòlides i fiables**; el bloc d'energia és **feble** (cautela).
2. L'estructura empírica del Bloc 1 són **3 factors** robustos (propòsit / equip / sistema); energia i recuperació **no es diferencien** empíricament.
3. **Coherència i energia estan positivament relacionades** (P3), amb el propòsit i la coherència d'equip com a vincles principals.
4. Les diferències més útils (P1/P2) són el **gradient jeràrquic** i el contrast **professorat vs FECC/direcció**; el **territori i la complexitat no discriminen**.
5. **EeX** destaca en coherència; la participació en projectes s'associa a **menys energia**.

**Limitacions.**
- Mostra modesta (n = 143) i subgrups petits → **potència limitada**; en una graella global de comparacions, cap efecte supera la correcció FDR (els resultats es basen en hipòtesis dirigides + mides d'efecte).
- Disseny **observacional** → **no causal**.
- L'AFE prové de la **mateixa mostra** que els contrastos → caldria **confirmar l'estructura (CFA) en una mostra independent**.
- **Fiabilitat baixa del bloc d'energia** → conclusions energètiques provisionals.

*Sortides completes (taules i gràfics) a la carpeta `sortides/` i als fitxers `resultats_*.xlsx`.*

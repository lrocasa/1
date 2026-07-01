# Informe d'anàlisi — Enquesta d'avaluació de la coherència
### Fundació Escola Cristiana de Catalunya (FECC)

**Mostra:** 143 respostes (102 amb docència/intervenció directa) · **73 escoles** · escales Likert 1–7.
**Naturalesa:** estudi **exploratori** i **transversal** (observacional). Es reporten mides d'efecte i correccions per comparacions múltiples. **No s'infereix causalitat.** Resultats de l'execució reproduïble de `analisi_enquesta.R`.

> **Nomenclatura (per evitar confusions):**
> - **Connexió de propòsit vital-personal** (o *Connexió propòsit*) = BLOC 3, ítems 28, 29, 31 (ω=0,82). És l'alineació entre el propòsit personal i la feina.
> - **EF3 · Coherència de propòsit** (o *EF3*) = factor empíric del Bloc 1 (ítems 1–5): la percepció que la xarxa comparteix una mateixa raó de ser i prioritats.
> Són coses **diferents**: la primera és personal-laboral; la segona, institucional.
>
> Símbols: ✅ robust · ⚠️ cautela · ❌ hipòtesi no confirmada.

---

## 1. Descriptius dels constructes

| Constructe | Mitjana (1–7) | DE |
|---|---|---|
| **Connexió de propòsit vital-personal** | **6,29** | 0,76 |
| **Funcionament de la xarxa** | **5,35** | 0,61 |
| Sensació d'energia | 4,84 | 0,75 |
| Recuperació | 4,83 | 1,20 |

![Mitjana per dimensió del Bloc 1](figures/bloc1_per_dimensio.png)

---

## 2. Fiabilitat (omega de McDonald)

| Constructe | Ítems | ω | Valoració |
|---|---|---|---|
| Funcionament de la xarxa | 17 | **0,86** | Bona ✅ |
| **Connexió de propòsit vital-personal** | 3 | **0,82** | Bona ✅ |
| Recuperació | 2 | 0,63 | Feble ⚠️ |
| Sensació d'energia | 3 | 0,57 | Insuficient ⚠️ |

**Factors empírics del Bloc 1:** **EF3 · Coherència de propòsit** ω=0,85 · **EF1 · Comunicació/sistema** ω=0,83 · **EF2 · Coherència d'equip** ω=0,79. Empíric energia+recuperació (fusionat) ω=0,67.

> ⚠️ El **bloc d'energia** és feble; conclusions provisionals. Vegeu la §11 (com millorar-ho a la propera enquesta).

---

## 3. Estructura factorial (AFE del Bloc 1)

KMO=0,75, Bartlett p<0,001 → factoritzable. L'anàlisi paral·lela indica **3 factors**:

| Factor | Ítems | Interpretació |
|---|---|---|
| **EF3 · Coherència de propòsit** | 1, 2, 3, 4, 5 | Raó de ser i prioritats compartides |
| **EF2 · Coherència d'equip** | 9, 10, 11, 12, 15 | Feedback, adaptació i reflexió de l'equip |
| **EF1 · Comunicació/sistema** | 7, 8, 14, 16, 17 | Comunicació, connexió multinivell i confiança |

![Scree i anàlisi paral·lela](figures/afe_scree.png)

- **Ítems exclosos** (per baix ajust; es mantenen als constructes teòrics): **6** i **13**.
- **Bloc 2+3:** energia i recuperació **no es diferencien** empíricament; la Connexió de propòsit **sí** que és un factor distint.

> ⚠️ AFE sobre la mateixa mostra → estructura exploratòria; caldria CFA en mostra independent.

---

## 4. Relació coherència–energia — **P3**

### 4.1 Correlacions (Spearman, IC 95% bootstrap)
| Relació | ρ | IC 95% |
|---|---|---|
| **Connexió propòsit ↔ Energia** | **0,43** | [0,29 – 0,56] |
| Funcionament ↔ Connexió propòsit | 0,38 | [0,22 – 0,51] |
| **Funcionament ↔ Energia** | **0,35** | [0,21 – 0,49] |

![Correlacions entre constructes](figures/fig_correlacions_constructes.png)
![Dispersió P3](figures/fig_P3_dispersio.png)

Faceta de coherència més lligada a l'energia: **EF2 · Equip (ρ=0,33)** i **EF1 · Sistema (ρ=0,32)** per sobre d'**EF3 · Coherència de propòsit (ρ=0,22)**. La recuperació és força independent de la coherència.

### 4.2 Regressió múltiple (prova directa de P3)
Model de l'energia (R²=0,25; betes estandarditzades):

| Predictor | β | p |
|---|---|---|
| **Connexió de propòsit** | **0,33** | <0,001 |
| **EF2 · Coherència d'equip** | **0,26** | 0,003 |
| EF1 · Sistema | 0,03 | ns |
| EF3 · Coherència de propòsit | 0,01 | ns |

![Predictors de l'energia](figures/fig_regressio_energia.png)

Recuperació: R²=0,10 (només la Connexió de propòsit hi contribueix). Supòsits verificats; errors robustos HC3 consistents.

### 4.3 Direccionalitat (mediació)
Efectes indirectes significatius **en tots dos sentits** (mediació parcial); la Connexió de propòsit com a mediador és una mica més forta (35% vs 21%). ⚠️ Transversal → no causal.

**Conclusió P3:** coherència i energia estan **positivament relacionades** (moderat). El que més sosté l'energia és la **connexió de propòsit** i la **coherència d'equip**, no la coherència del sistema.

---

## 5. Diferències per subgrups — **P1 / P2**

> **Potència:** en una graella global cap efecte supera la correcció FDR. Els resultats són **exploratoris** (tests dirigits + mides d'efecte). Es donen mitjanes concretes per grup.

### 5.1 Nivell jeràrquic (mitjanes 1–7)
| Nivell (n) | Funcion. | Energia | Recup. | Connexió prop. | EF3 | EF2 | **EF1·Sistema** |
|---|---|---|---|---|---|---|---|
| Nucli operatiu (45) | 5,16 | 4,69 | 4,66 | 6,21 | 5,59 | 5,12 | **5,86** |
| Governança intermèdia (47) | 5,35 | 4,89 | 4,77 | 6,27 | 5,64 | 5,40 | **6,02** |
| Governança de sistema (43) | 5,50 | 4,86 | 5,03 | 6,41 | 5,81 | 5,64 | **6,24** |
| Comunitat i altres (8) | 5,54 | 5,25 | 5,06 | 6,21 | 5,98 | 5,18 | **6,70** |

**Gradient clar:** com més amunt al sistema de governança, **més alta la percepció de coherència del sistema (EF1)** — de 5,86 (operatiu) a 6,70 (comunitat/central). És l'única diferència que **supera la correcció** (Kruskal-Wallis p_ajustada=0,030; ε²=0,08). Interpretació: **els qui estan més a prop del centre veuen el sistema més coherent; els de peu d'aula, més fluix.**

![Constructes per nivell jeràrquic](figures/fig_nivell_jerarquic.png)

### 5.2 Rol (multi-pertinença; mitjanes 1–7)
| Rol (n) | Funcion. | Energia | Recup. | Connexió | EF3 | EF2 | EF1 |
|---|---|---|---|---|---|---|---|
| Equip directiu (62) | 5,36 | 4,77 | 4,79 | 6,32 | 5,76 | 5,32 | 6,20 |
| Titularitat (35) | 5,45 | 4,79 | 4,73 | **6,48** | 5,66 | **5,70** | 6,16 |
| Professorat (21) | 5,15 | 4,70 | 4,83 | 6,24 | 5,60 | 5,30 | **5,56** |
| GdE (18) | 5,22 | 4,96 | 4,81 | 6,20 | 5,32 | 5,28 | 5,97 |
| Personal FECC (17) | 5,59 | **5,25** | **5,29** | 6,31 | 5,95 | 5,61 | 6,20 |
| Comité d'ètica (5) | 5,65 | 5,73 | 5,80 | 6,73 | 5,80 | 5,80 | 6,68 |
| *Mostra* | 5,35 | 4,84 | 4,83 | 6,29 | 5,69 | 5,37 | 6,07 |

Lectures: **Professorat** = valor més baix en **EF1·Sistema (5,56)** → és qui percep el sistema més fluix. **Personal FECC** = els més alts en **energia i recuperació**. **Titularitat** = més alts en **coherència d'equip (EF2)** i connexió de propòsit. El **Comité d'ètica** (n=5, cautela) puntua alt en gairebé tot.

![Mitjana de cada constructe per rol](figures/fig_rol_heatmap.png)

### 5.3 Etapa educativa (docents; mitjanes 1–7)
| Etapa (n) | Funcion. | Energia | Connexió | EF3 | EF2 | EF1 |
|---|---|---|---|---|---|---|
| Infantil (15) | 5,47 | 4,62 | 6,40 | 5,91 | 5,44 | 6,04 |
| Primària (43) | 5,47 | 4,70 | 6,38 | 5,97 | 5,36 | 6,14 |
| ESO (44) | 5,20 | 4,67 | 6,14 | **5,43** | 5,27 | 5,97 |
| Batxillerat (23) | 5,10 | 4,68 | 5,99 | 5,50 | 5,10 | 5,85 |
| FP (6) | 5,28 | **5,50** | 6,83 | 5,81 | 5,13 | 5,96 |

**Primària/Infantil** més positives en funcionament i EF3; **ESO/Batxillerat** més crítiques (menys EF3 i connexió de propòsit); **FP** (n=6, cautela) destaca en energia.

### 5.4 Context territorial i complexitat del centre
**Cap diferència significativa** en cap constructe. El territori i la complexitat **no discriminen**.

### 5.5 Xarxa d'escoles (només escoles, n=102: 66 en xarxa vs 36 independents)
Mitjanes (xarxa vs independent):

| Constructe | En xarxa | Independent | p |
|---|---|---|---|
| **EF3 · Coherència de propòsit** | 5,56 | **5,98** | **0,036** |
| Connexió de propòsit | 6,20 | 6,44 | 0,066 |
| Recuperació | 4,52 | 4,97 | 0,063 |
| Energia | 4,67 | 4,87 | 0,192 |
| Funcionament | 5,25 | 5,41 | 0,162 |
| EF2 · Equip / EF1 · Sistema | ≈ igual | ≈ igual | ns |

Les escoles **independents** tendeixen a puntuar **més alt** en coherència de propòsit (significatiu), i com a tendència també en connexió de propòsit i recuperació. ⚠️ Efecte petit; el grup "independent" és petit (36). *Nota: sobre la mostra sencera (incloent-hi personal central) l'efecte semblava més gran, però quedava inflat per barrejar-hi qui no és d'escola; en restringir a escoles s'atenua.*

---

## 6. Variables de control (ítems 23, 24, 25) i polivalència

**Relació amb els constructes (Spearman):**

| | Connexió propòsit | EF2 · Equip | EF3 · Coher. propòsit |
|---|---|---|---|
| **23 · tendència energia (curs)** | +0,23* | **+0,30*** | +0,13 |
| **25 · tendència energia (rol)** | +0,21* | **+0,27*** | −0,01 |
| **24 · anys al rol** | +0,05 | −0,03 | −0,15 |

- La **trajectòria d'energia** (23, 25) es relaciona sobretot amb la **coherència d'equip (EF2)** i, en menor grau, amb la **connexió de propòsit** — no amb l'EF3. (I amb l'energia actual, ρ≈0,37–0,40; explica ~25% de la variància.)
- **Antiguitat (24):** sense relació rellevant; lleu tendència negativa amb EF3 (−0,15) i funcionament.
- **Nombre de rols** (polivalència): **no** s'associa a menys energia ❌ (la sobrecàrrega per multi-rol no es confirma).

---

## 7. Projectes estratègics de la FECC

| Projecte | Efecte destacat |
|---|---|
| **EeX** | **+ coherència/propòsit** (EF3 d=+0,58) ✅ |
| EeXAMC | **− energia** (d=−0,36) ❌ |
| EdD (n=7) | − energia (poca potència) |
| **Participar en general** | **− energia** (d=−0,47) i gradient dosi-resposta ❌ |
| GdE (com a projecte) | sense guany de coherència |

A **nivell d'escola**, les que participen tenen **més càrrega d'estrès** (p=0,018, sobretot cansament físic i càrrega) i **menys energia** (p=0,044).

> ⚠️ Observacional: **desgast** dels projectes o **autoselecció**. Hipòtesi clau per a entrevistes.

---

## 8. Nivell d'escola (ICC)

**Component d'escola (ICC):** Energia 0,25 · Recuperació 0,26 · Funcionament 0,16 · Connexió propòsit ~0. L'energia és, en part, un fenomen **de centre**; la connexió de propòsit és **individual**.

![Energia mitjana per escola](figures/fig_energia_per_escola.png)

Ni xarxa, ni complexitat, ni territori **expliquen** l'energia de l'escola → el "efecte escola" ve de factors no mesurats (clima, direcció concreta…). ⚠️ Amb 31 escoles petites no es fan models multinivell; s'informa com a limitació (no-independència).

---

## 9. Perfils de participants (clústers)

> ⚠️ *Gap statistic* → **estructura feble** (gradient, no tipus nítids). Perfils = **base per al mostreig intencional**, no tipologia robusta. Es mostren dues operacionalitzacions i dos nivells de detall (k=3 i k=5).

### 9.1 Versió A · 3 macro-constructes (Funcionament, Energia/Recuperació, Connexió propòsit)
**k=3:**
| Perfil | n | Funcionament | Energia/Recup | Connexió propòsit |
|---|---|---|---|---|
| Alt | 64 | 5,84 | 5,09 | 6,73 |
| Baix en tot | 43 | 4,94 | 4,03 | 5,50 |
| Baixa coherència però amb energia | 36 | 4,95 | 5,33 | 6,44 |

### 9.2 Versió B · 5 dimensions (EF3, EF2, EF1, Energia/Recuperació, Connexió propòsit)
**k=3:**
| Perfil | n | EF3 | EF2 | EF1 | Energia/Recup | Connexió |
|---|---|---|---|---|---|---|
| Alineats i amb energia | 79 | 6,13 | 5,77 | 6,44 | 5,15 | 6,75 |
| Coherents però drenats | 49 | 5,46 | 5,02 | 5,91 | **4,38** | 5,56 |
| Poc coherents però amb energia/propòsit | 15 | 4,19 | 4,44 | 4,67 | 4,66 | 6,27 |

**k=5** afegeix el perfil **"Tot baix" (n≈16)**: baixos en coherència, energia i propòsit alhora → grup de **risc**.

![Perfils de clúster (B5, k=5)](figures/clusters_B5_perfils_k5.png)
![Distribució 3D dels perfils (A3, k=5)](figures/clusters_A3_3D_k5.png)

**Desacoblaments** (útils per a entrevista): *coherents però drenats* (alta coherència, baixa energia) i *poc coherents però amb energia*.

---

## 10. Constrenyiments (ítem 22) — **P2**

**Més prevalents:** Excés de càrrega **66%** · Falta de temps **64%** · Interrupcions **59%** · Conflictes 35% · Cansament físic 35%.

![Factors d'estrès més freqüents](figures/factors_estres.png)

**Combinacions més freqüents:** *càrrega + temps* (48%), *temps + interrupcions* (43%) → el **"triangle de la sobrecàrrega"**.
**Associacions més fortes (lift):** *cansament físic + situacions personals* (1,76), *conflictes + tasques no alineades* (1,68).

![Co-ocurrència de factors d'estrès](figures/estres_coocurrencia_heatmap.png)

**Distribució:** rang **1–9** factors/persona, mitjana 3,5, **asimètrica a la dreta** (no normal). Els **molt sobrecarregats (≥6 factors, n=14)** reporten **menys energia, recuperació i connexió de propòsit** (i menys coherència d'equip), però **no** menys EF3/EF1.

![Distribució del nombre de factors](figures/estres_distribucio_nfactors.png)

---

## 11. Recomanacions de mesura per a la propera enquesta

Per què alguns ítems donen problemes i com millorar-los:

| Element | Per què falla | Com millorar-ho |
|---|---|---|
| **Ítem 6** (missatges contradictoris) | Redactat en negatiu i mesura soroll **extern** (Departament, inspecció, sindicats), diferent de "la FECC comunica bé" | Reformular en positiu i cap al rol de la FECC ("la FECC m'ajuda a interpretar els missatges contradictoris"); o fer-ne una **dimensió pròpia amb 3 ítems** |
| **Ítem 13** (responsabilitats concentrades) | Negatiu; parla d'equip però empíricament es lliga al sistema amb signe contradictori | Reformular en positiu ("les responsabilitats estan ben repartides al meu equip") i afegir **2-3 ítems** de *lideratge distribuït* |
| **Ítems 21 i 30** (drena l'energia / tasques que aporten poc) | Negatius; els enquestats els responen de manera **inconsistent** (aquiescència/doble negació) | Evitar formulacions negatives aïllades; si es volen, posar-ne **diverses** i comprovar-ne la direcció al pilotatge |
| **Bloc Energia** (ω=0,57) | Poques ítems que **barregen vigor i esgotament** en una sola escala curta | Usar una escala validada (p. ex. adaptar *vigor* de l'UWES) amb **4–6 ítems** en direcció consistent; separar *vigor* i *esgotament* amb prou ítems cadascun |
| **Recuperació** (ω=0,63) | Només **2 ítems** | Ampliar a **3–4 ítems** |
| **Dimensions d'1 ítem** (D2, D6, D6.1, D7, D8) | Amb un sol ítem **no es pot mesurar la fiabilitat** | Cada dimensió amb **≥3 ítems** |

**Regla general:** reduir els ítems redactats en negatiu (6, 13, 21, 30 han estat justament els problemàtics) i garantir **≥3 ítems per dimensió** en direcció coherent. Això faria més fiables l'energia i, sobretot, permetria mesurar bé dimensions com el lideratge distribuït.

---

## 12. Síntesi per a les entrevistes (mostreig intencional)

1. **Perfil positiu** (alineats amb energia) — cas de referència.
2. **Perfil "tot baix" / molt sobrecarregats (≥6 factors)** — casos crítics.
3. **Coherents però drenats** (alta coherència, baixa energia) — sovint direcció; el desgast malgrat el propòsit.
4. **Poc coherents però amb energia** — què els sosté.
5. Contrast **professorat (EF1 baix) vs personal FECC/direcció**.
6. **Projectes estratègics** (valor vs càrrega) i **sobrecàrrega operativa**.

---

## 13. Conclusions i limitacions

**Conclusions.**
1. Funcionament de la xarxa i Connexió de propòsit són mesures **fiables**; el bloc d'energia és **feble**.
2. La coherència del Bloc 1 es resumeix en **3 factors** (EF3 propòsit / EF2 equip / EF1 sistema); energia i recuperació **no es diferencien**.
3. **Coherència i energia estan positivament relacionades** (P3); el motor és la **connexió de propòsit** i la **coherència d'equip**.
4. Hi ha un **gradient jeràrquic** en la percepció del sistema (EF1) i un contrast **professorat vs FECC/direcció**; **territori i complexitat no discriminen**.
5. La **participació en projectes** s'associa a **més estrès i menys energia** (excepte EeX, lligat a més coherència).
6. El bloqueig dominant és la **sobrecàrrega operativa**; hi ha un grup petit "tot baix" en risc.

**Limitacions.**
- Mostra modesta (n=143) i subgrups petits → **potència limitada**.
- Disseny **transversal/observacional** → **no causal**.
- Estructura empírica i clústers de la **mateixa mostra** → cal **validació externa**.
- **Fiabilitat baixa** del bloc d'energia.
- Respostes niades en escoles (ICC≈0,25 energia) → lleugera **no-independència** no modelada.

---

*Detall numèric complet: fitxers `resultats_*.xlsx` i carpeta `sortides/` generats per `analisi_enquesta.R` (no inclosos al repositori: contenen dades identificatives).*

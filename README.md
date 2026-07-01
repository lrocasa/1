# Anàlisi de l'enquesta d'avaluació de la coherència (FECC)

Anàlisi quantitativa d'una enquesta sobre **coherència de la xarxa**, **sensació
d'energia/recuperació** i **alineament de propòsit** a les escoles de la FECC
(143 respostes). L'estudi és **exploratori i transversal** (fase quantitativa
d'un disseny mixt que orienta unes entrevistes posteriors).

## Contingut del repositori

| Fitxer | Què és |
|---|---|
| `analisi_enquesta.R` | Script complet i comentat de tota l'anàlisi (té un índex al capçal). |
| `informe_complet.md` | Informe de resultats (editable; es renderitza a GitHub). |
| `informe_complet.pdf` | El mateix informe en PDF (per compartir / previsualitzar). |
| `figures/` | Gràfics que apareixen a l'informe (agregats, sense dades personals). |
| `.gitignore` | Manté fora del repositori les dades i les sortides amb informació identificativa. |

> ⚠️ **Dades i privacitat.** El fitxer de dades (`.xlsx`) i la carpeta de sortides
> (`sortides/`) **NO són al repositori**: contenen identificadors (correus). Cal
> tenir el fitxer de dades en local per executar el script.

## Com executar l'script

1. Obre `analisi_enquesta.R` a **RStudio**.
2. A la **secció 1**, ajusta la ruta del fitxer de dades:
   ```r
   fitxer <- "RUTA/AL/TEU/Resultats de la mostra de l'enquesta.xlsx"
   ```
3. Executa-ho tot de dalt a baix (**Ctrl+Alt+R** o el botó **Source**).
   El bloc inicial **instal·la automàticament** els paquets que faltin
   (tidyverse, readxl, psych, janitor, writexl, rstatix, effectsize, MBESS...).
4. Els resultats es generen a la carpeta **`sortides/`**:
   - taules `resultats_*.xlsx` (fiabilitat, segmentadors, regressió, clústers, etc.)
   - gràfics `.png`.

*Requisit:* R ≥ 4.1. Primera execució: pot trigar uns minuts (instal·lació de
paquets i càlculs amb bootstrap).

## Estructura de l'anàlisi (què fa el script)

- **Seccions 0–14:** preparació de dades, neteja, constructes, fiabilitat (alpha i **omega**), descriptius.
- **PARTs B–S:** segmentadors, ítems de control, **AFE**, dimensions empíriques,
  rols, projectes FECC, subgrups no paramètrics, correlacions (**P3**),
  nivell d'escola (**ICC**), **regressió** i **mediació**, **clústers** (perfils
  per a entrevistes), co-ocurrències d'estrès i gràfics per a l'informe.

## Preguntes de recerca

- **P1/P2** — diferències en coherència/energia per rol, nivell jeràrquic i context; constrenyiments predominants.
- **P3** — relació entre coherència i energia.

## Nota metodològica

Mostra modesta (n=143) i disseny observacional: els resultats són **exploratoris**;
es reporten mides d'efecte i correccions per comparacions múltiples i **no
s'infereix causalitat**. Vegeu les cauteles (⚠️) a `informe_complet.md`.

# ============================================================================
#  ANÀLISI DE L'ENQUESTA D'AVALUACIÓ DE LA COHERÈNCIA (FECC)
#  ----------------------------------------------------------------------------
#  Dades: "Resultats de la mostra de l'enquesta.xlsx"
#         full "enquesta-davaluació-de-la-coher"  (143 respostes x 89 columnes)
#
#  Estructura de variables:
#    - Identificatives (Token ... EdD)          -> segmentació
#    - Filtre "docència directa" (Sí/No)        -> habilita etapes i àmbits
#    - Etapes educatives  (multiresposta 0/1)
#    - Àmbits docents     (multiresposta 0/1)
#    - Ítems d'investigació: escales Likert 1-7 + algunes ordinals/multiresposta
#
#  COM USAR-LO: canvia la ruta de 'fitxer' a la línia de sota i executa de dalt
#  a baix (Ctrl+Alt+R a RStudio). Els resultats es desen a la carpeta 'sortides/'.
# ============================================================================

# ---- 0. Paquets -----------------------------------------------------------
# Si no els tens instal·lats, descomenta i executa una sola vegada:
# install.packages(c("tidyverse", "readxl", "psych", "janitor", "writexl"))

library(tidyverse)   # dplyr, ggplot2, tidyr, readr...
library(readxl)      # llegir .xlsx
library(psych)       # alpha de Cronbach, descriptives
library(janitor)     # neteja de noms / taules de freqüència
library(writexl)     # exportar a Excel

# ---- 1. Carregar dades ----------------------------------------------------
fitxer <- "Resultats de la mostra de l'enquesta.xlsx"   # <-- AJUSTA LA RUTA

dades <- read_excel(fitxer, sheet = "enquesta-davaluació-de-la-coher")

cat("Dimensions:", nrow(dades), "files x", ncol(dades), "columnes\n")

# ---- 2. Reanomenar columnes a noms curts i manejables ---------------------
# Treballem per posició perquè els enunciats originals són molt llargs.
# (Els índexs de R comencen a 1; aquí coincideixen amb l'ordre del full.)

noms_curts <- c(
  # identificatives (1-12)
  "Token","id_persona","Cargo","Subcargo","Escola","Denominacio",
  "Complexitat","ServeiTerritorial","Poblacio","EeX","EeXAMC","EdD",
  # consentiment (13-15)
  "Consent","Consent_text","Consent_descr",
  # filtre (16)
  "DocenciaDirecta",
  # etapes multiresposta (17-23)
  "et_Infantil","et_Primaria","et_ESO","et_Batx","et_FP","et_Especial","et_Altres",
  # àmbits multiresposta (24-28)
  "am_Sociolinguistic","am_CientificTec","am_Digital","am_Pastoral","am_Altres",
  # COHERÈNCIA: ítems 1-17 Likert 1-7 (29-45)
  paste0("coh", sprintf("%02d", 1:17)),
  # espai obert (46)
  "obert_coherencia",
  # ENERGIA: ítems 18-21 (47-50) + mitjana ja calculada a l'Excel (51)
  "en18","en19","en20","en21","media_18_21",
  # QUÈ ET DRENA L'ENERGIA: multiresposta (52-65) + altres text (66)
  "dr_Carrega","dr_Temps","dr_Interrupcions","dr_Claredat","dr_Conflictes",
  "dr_Suport","dr_Reunions","dr_SenseSentit","dr_NoAlineat","dr_Canvis",
  "dr_Incertesa","dr_Cansament","dr_Personal","dr_Altres","dr_Altres_text",
  # ítems ordinals i de recuperació (67-71)
  "q23_tendencia_curs","q24_anys_rol","q25_tendencia_rol","en26","en27",
  # espai obert (72)
  "obert_energia",
  # PROPÒSIT: ítems 28-31 (73-76)
  "prop28","prop29","prop30","prop31",
  # espai obert (77)
  "obert_proposit",
  # contacte (78)
  "vol_entrevista",
  # metadades del formulari (79-89)
  "reg_id","data_entrada","data_update","url_origen","trans_id",
  "import_pag","data_pag","estat_pag","entry_id","agent","ip_usuari"
)

stopifnot(length(noms_curts) == ncol(dades))   # comprovació de seguretat
names(dades) <- noms_curts

# ---- 3. Variables multiresposta: de text/buit -> 0/1 ----------------------
# Cada columna conté el text de la categoria si la van marcar, o NA si no.
a_binaria <- function(x) as.integer(!is.na(x) & x != "")

vars_etapes <- c("et_Infantil","et_Primaria","et_ESO","et_Batx",
                 "et_FP","et_Especial","et_Altres")
vars_ambits <- c("am_Sociolinguistic","am_CientificTec","am_Digital",
                 "am_Pastoral","am_Altres")
vars_drena  <- c("dr_Carrega","dr_Temps","dr_Interrupcions","dr_Claredat",
                 "dr_Conflictes","dr_Suport","dr_Reunions","dr_SenseSentit",
                 "dr_NoAlineat","dr_Canvis","dr_Incertesa","dr_Cansament",
                 "dr_Personal","dr_Altres")

dades <- dades %>%
  mutate(across(all_of(c(vars_etapes, vars_ambits, vars_drena)), a_binaria))

# ---- 4. Assegurar que els ítems Likert són numèrics -----------------------
items_coh  <- paste0("coh", sprintf("%02d", 1:17))
items_en   <- c("en18","en19","en20","en21","en26","en27")
items_prop <- c("prop28","prop29","prop30","prop31")

dades <- dades %>%
  mutate(across(all_of(c(items_coh, items_en, items_prop)), as.numeric))

# ---- 5. Invertir els ítems redactats en negatiu ---------------------------
# Escala 1-7: el valor invertit és (7 + 1) - x = 8 - x.
# Així, després de la inversió, "alt = millor" en TOTS els ítems d'una escala.
inv <- function(x) 8 - x

dades <- dades %>%
  mutate(
    en19_r  = inv(en19),    # "em costa posar-me en marxa"
    en21_r  = inv(en21),    # "em drena l'energia"
    en27_r  = inv(en27),    # "vaig acumulant cansament"
    prop30_r = inv(prop30), # "tasques que aporten poc al propòsit"
    coh13_r = inv(coh13)    # "massa responsabilitats en les mateixes persones"
  )

# ---- 6. Índexs (mitjanes d'escala) ----------------------------------------
# rowMeans amb na.rm = TRUE: calcula la mitjana amb els ítems contestats.
dades <- dades %>%
  mutate(
    idx_coherencia = rowMeans(across(all_of(items_coh)), na.rm = TRUE),
    idx_energia    = rowMeans(cbind(en18, en19_r, en20, en21_r), na.rm = TRUE),
    idx_recuperacio= rowMeans(cbind(en26, en27_r), na.rm = TRUE),
    idx_proposit   = rowMeans(cbind(prop28, prop29, prop30_r, prop31), na.rm = TRUE)
  )

# ---- 7. Descriptius dels ítems Likert -------------------------------------
desc_coh <- dades %>%
  select(all_of(items_coh)) %>%
  psych::describe() %>%
  as.data.frame() %>%
  rownames_to_column("item") %>%
  select(item, n, mean, sd, min, max)
print(desc_coh)

# ---- 8. Fiabilitat (alpha de Cronbach) ------------------------------------
# Important: fer servir les versions invertides on calgui.
cat("\n--- Alpha de Cronbach: COHERÈNCIA (17 ítems) ---\n")
alpha_coh <- psych::alpha(dades[, items_coh], check.keys = TRUE)
print(alpha_coh$total)

cat("\n--- Alpha: ENERGIA (18,19r,20,21r) ---\n")
print(psych::alpha(dades[, c("en18","en19_r","en20","en21_r")])$total)

# ---- 9. Freqüències de les multiresposta ----------------------------------
freq_multi <- function(df, vars, etiqueta) {
  df %>%
    summarise(across(all_of(vars), ~ sum(.x, na.rm = TRUE))) %>%
    pivot_longer(everything(), names_to = "categoria", values_to = "n") %>%
    mutate(grup = etiqueta,
           pct  = round(100 * n / nrow(df), 1)) %>%
    arrange(desc(n))
}

# Etapes i àmbits només tenen sentit per a qui fa docència directa:
docents <- dades %>% filter(DocenciaDirecta == "Sí")

freq_etapes <- freq_multi(docents, vars_etapes, "Etapa")
freq_ambits <- freq_multi(docents, vars_ambits, "Àmbit")
freq_drena  <- freq_multi(dades,  vars_drena,  "Drena energia")
print(freq_etapes); print(freq_ambits); print(freq_drena)

# ---- 10. Creuaments per segments (exemples) -------------------------------
# Mitjana de coherència per tipus de càrrec i per servei territorial.
coh_per_cargo <- dades %>%
  group_by(Cargo) %>%
  summarise(n = n(),
            coherencia = round(mean(idx_coherencia, na.rm = TRUE), 2),
            .groups = "drop") %>%
  arrange(desc(coherencia))
print(coh_per_cargo)

# Filtre Sí/No
print(janitor::tabyl(dades, DocenciaDirecta))

# ---- 11. Gràfics (ggplot2) ------------------------------------------------
if (!dir.exists("sortides")) dir.create("sortides")

# 11a. Mitjana de cada ítem de coherència (ordenat)
g1 <- desc_coh %>%
  mutate(item = fct_reorder(item, mean)) %>%
  ggplot(aes(x = mean, y = item)) +
  geom_col(fill = "#2c7fb8") +
  geom_text(aes(label = round(mean, 2)), hjust = -0.1, size = 3) +
  scale_x_continuous(limits = c(0, 7.5), breaks = 1:7) +
  labs(title = "Coherència: mitjana per ítem (escala 1-7)",
       x = "Mitjana", y = NULL) +
  theme_minimal()
ggsave("sortides/coherencia_per_item.png", g1, width = 8, height = 6, dpi = 150)

# 11b. Freqüència d'etapes
g2 <- ggplot(freq_etapes, aes(x = n, y = fct_reorder(categoria, n))) +
  geom_col(fill = "#31a354") +
  geom_text(aes(label = paste0(n, " (", pct, "%)")), hjust = -0.1, size = 3) +
  labs(title = "Etapes educatives (docents, n = 102)", x = "Respostes", y = NULL) +
  xlim(0, max(freq_etapes$n) * 1.2) +
  theme_minimal()
ggsave("sortides/etapes.png", g2, width = 8, height = 5, dpi = 150)

# 11c. Distribució dels índexs
g3 <- dades %>%
  select(idx_coherencia, idx_energia, idx_recuperacio, idx_proposit) %>%
  pivot_longer(everything(), names_to = "index", values_to = "valor") %>%
  ggplot(aes(x = valor)) +
  geom_histogram(bins = 15, fill = "#756bb1") +
  facet_wrap(~ index, scales = "free_y") +
  labs(title = "Distribució dels índexs (1-7)", x = NULL, y = "Freqüència") +
  theme_minimal()
ggsave("sortides/distribucio_indexs.png", g3, width = 9, height = 6, dpi = 150)

# ---- 12. Exportar resultats a Excel ---------------------------------------
write_xlsx(
  list(
    "Descriptius_coherencia" = desc_coh,
    "Freq_etapes"            = freq_etapes,
    "Freq_ambits"            = freq_ambits,
    "Freq_drena"             = freq_drena,
    "Coherencia_per_cargo"   = coh_per_cargo
  ),
  "sortides/resultats_analisi.xlsx"
)

cat("\nFet! Mira la carpeta 'sortides/' (gràfics .png i resultats_analisi.xlsx)\n")

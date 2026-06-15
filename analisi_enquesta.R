# ============================================================================
#  ANÀLISI DE L'ENQUESTA D'AVALUACIÓ DE LA COHERÈNCIA (FECC)
#  ----------------------------------------------------------------------------
#  Dades: "Resultats de la mostra de l'enquesta.xlsx"
#         full "enquesta-davaluació-de-la-coher"  (143 respostes x 89 columnes)
#
#  ESTRUCTURA DE CONSTRUCTES
#  -------------------------
#  BLOC 1 · FUNCIONAMENT DE LA XARXA  (ítems 1-17, Likert 1-7)
#     D1  Coherència de propòsit i prioritats ... ít. 1, 2, 3, 4
#     D2  Contextualització local ............... ít. 5
#     D3  Comunicació i mediació ................ ít. 6, 7, 8
#     D4  Feedback i aprenentatge ............... ít. 9, 10, 16
#     D5  Adaptació ............................. ít. 11, 12
#     D6  Lideratge distribuït .................. ít. 13
#     D6.1 Connexió multinivell ................. ít. 14
#     D7  Reflexió de constrenyiments ........... ít. 15
#     D8  Confiança (eficàcia col·lectiva) ...... ít. 17
#
#  BLOC 2 · SENSACIÓ D'ENERGIA I RECUPERACIÓ
#     Sensació d'energia ....................... ít. 18, 19, 20, 21
#     Recuperació energètica percebuda ......... ít. 26, 27
#
#  ÍTEM 22  (solt) ............... factors que més estrès causen (multiresposta)
#  ÍTEMS 23, 24, 25 (solts) ...... Trajectòria energètica percebuda (control)
#
#  BLOC 3 · ALINEAMENT PROPÒSIT VITAL – PROFESSIÓ ... ít. 28, 29, 30, 31
#
#  ÍTEMS INVERTITS (negatiu -> alt = pitjor): 6, 13, 19, 21, 27, 30
#
#  COM USAR-LO: ajusta la ruta de 'fitxer' i executa de dalt a baix
#  (Ctrl+Alt+R a RStudio). Els resultats es desen a la carpeta 'sortides/'.
# ============================================================================

# ---- 0. Paquets -----------------------------------------------------------
# install.packages(c("tidyverse","readxl","psych","janitor","writexl"))
library(tidyverse)
library(readxl)
library(psych)
library(janitor)
library(writexl)

# ---- 1. Carregar dades ----------------------------------------------------
fitxer <- "Resultats de la mostra de l'enquesta.xlsx"   # <-- AJUSTA LA RUTA
dades <- read_excel(fitxer, sheet = "enquesta-davaluació-de-la-coher")
cat("Dimensions:", nrow(dades), "files x", ncol(dades), "columnes\n")

# ---- 2. Reanomenar columnes a noms curts ----------------------------------
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
  # BLOC 1: ítems 1-17 (29-45)
  paste0("coh", sprintf("%02d", 1:17)),
  # espai obert (46)
  "obert_bloc1",
  # BLOC 2 - Sensació d'energia: ítems 18-21 (47-50) + mitjana de l'Excel (51, NO s'usa)
  "en18","en19","en20","en21","media_18_21",
  # ÍTEM 22 - factors d'estrès: multiresposta (52-65) + altres text (66)
  "dr_Carrega","dr_Temps","dr_Interrupcions","dr_Claredat","dr_Conflictes",
  "dr_Suport","dr_Reunions","dr_SenseSentit","dr_NoAlineat","dr_Canvis",
  "dr_Incertesa","dr_Cansament","dr_Personal","dr_Altres","dr_Altres_text",
  # ítems 23,24,25 (control) + recuperació 26,27 (67-71)
  "q23_tendencia_curs","q24_anys_rol","q25_tendencia_rol","en26","en27",
  # espai obert (72)
  "obert_energia",
  # BLOC 3 - propòsit: ítems 28-31 (73-76)
  "prop28","prop29","prop30","prop31",
  # espai obert (77)
  "obert_proposit",
  # contacte (78)
  "vol_entrevista",
  # metadades del formulari (79-89)
  "reg_id","data_entrada","data_update","url_origen","trans_id",
  "import_pag","data_pag","estat_pag","entry_id","agent","ip_usuari"
)
stopifnot(length(noms_curts) == ncol(dades))
names(dades) <- noms_curts

# ---- 3. Multiresposta: de text/buit -> 0/1 --------------------------------
a_binaria <- function(x) as.integer(!is.na(x) & x != "")

vars_etapes <- c("et_Infantil","et_Primaria","et_ESO","et_Batx",
                 "et_FP","et_Especial","et_Altres")
vars_ambits <- c("am_Sociolinguistic","am_CientificTec","am_Digital",
                 "am_Pastoral","am_Altres")
vars_estres <- c("dr_Carrega","dr_Temps","dr_Interrupcions","dr_Claredat",
                 "dr_Conflictes","dr_Suport","dr_Reunions","dr_SenseSentit",
                 "dr_NoAlineat","dr_Canvis","dr_Incertesa","dr_Cansament",
                 "dr_Personal","dr_Altres")

dades <- dades %>%
  mutate(across(all_of(c(vars_etapes, vars_ambits, vars_estres)), a_binaria))

# ---- 4. Ítems Likert a numèric --------------------------------------------
items_bloc1 <- paste0("coh", sprintf("%02d", 1:17))
items_energ <- c("en18","en19","en20","en21","en26","en27")
items_prop  <- c("prop28","prop29","prop30","prop31")
dades <- dades %>%
  mutate(across(all_of(c(items_bloc1, items_energ, items_prop)), as.numeric))

# ---- 5. Invertir ítems negatius (escala 1-7: invertit = 8 - x) ------------
# Invertits: 6, 13 (Bloc 1); 19, 21 (energia); 27 (recuperació); 30 (propòsit)
inv <- function(x) 8 - x
dades <- dades %>%
  mutate(
    coh06_r  = inv(coh06),
    coh13_r  = inv(coh13),
    en19_r   = inv(en19),
    en21_r   = inv(en21),
    en27_r   = inv(en27),
    prop30_r = inv(prop30)
  )

# Vector dels 17 ítems de Bloc 1 amb les versions invertides on cal.
# (s'usa per a l'índex global i l'alpha del bloc)
bloc1_corregits <- c("coh01","coh02","coh03","coh04","coh05",
                     "coh06_r","coh07","coh08","coh09","coh10",
                     "coh11","coh12","coh13_r","coh14","coh15","coh16","coh17")

# ---- 6. Definició de dimensions (Bloc 1) ----------------------------------
# Cada dimensió és la llista d'ítems (ja corregits) que la componen.
dimensions <- list(
  D1_Coherencia_proposit   = c("coh01","coh02","coh03","coh04"),
  D2_Contextualitzacio     = c("coh05"),
  D3_Comunicacio_mediacio  = c("coh06_r","coh07","coh08"),
  D4_Feedback_aprenentatge = c("coh09","coh10","coh16"),
  D5_Adaptacio             = c("coh11","coh12"),
  D6_Lideratge_distribuit  = c("coh13_r"),
  D6_1_Connexio_multinivell= c("coh14"),
  D7_Reflexio_constreny    = c("coh15"),
  D8_Confianca_eficacia    = c("coh17")
)

# Crea una columna d'índex per a cada dimensió (mitjana dels seus ítems).
for (nom in names(dimensions)) {
  dades[[nom]] <- rowMeans(dades[, dimensions[[nom]], drop = FALSE], na.rm = TRUE)
}

# ---- 7. Índexs dels constructes -------------------------------------------
dades <- dades %>%
  mutate(
    # BLOC 1 global
    idx_funcionament_xarxa = rowMeans(across(all_of(bloc1_corregits)), na.rm = TRUE),
    # BLOC 2
    idx_sensacio_energia   = rowMeans(cbind(en18, en19_r, en20, en21_r), na.rm = TRUE),
    idx_recuperacio        = rowMeans(cbind(en26, en27_r), na.rm = TRUE),
    # BLOC 3
    idx_alineament_proposit= rowMeans(cbind(prop28, prop29, prop30_r, prop31), na.rm = TRUE)
  )

# ---- 8. Fiabilitat (alpha de Cronbach) ------------------------------------
# Només per a escales amb >= 2 ítems (les dimensions d'1 ítem no tenen alpha).
alpha_segur <- function(df, items, etiqueta) {
  if (length(items) < 2) {
    cat(sprintf("  %-28s: 1 sol ítem (sense alpha)\n", etiqueta)); return(invisible(NULL))
  }
  a <- psych::alpha(df[, items], warnings = FALSE)$total$raw_alpha
  cat(sprintf("  %-28s: alpha = %.3f (%d ítems)\n", etiqueta, a, length(items)))
}

cat("\n--- Fiabilitat dels constructes ---\n")
alpha_segur(dades, bloc1_corregits,                  "BLOC 1 Funcionament xarxa")
alpha_segur(dades, c("en18","en19_r","en20","en21_r"),"Sensació d'energia")
alpha_segur(dades, c("en26","en27_r"),                "Recuperació energètica")
alpha_segur(dades, c("prop28","prop29","prop30_r","prop31"), "BLOC 3 Alineament propòsit")
cat("\n--- Fiabilitat per dimensió (Bloc 1) ---\n")
for (nom in names(dimensions)) alpha_segur(dades, dimensions[[nom]], nom)

# ---- 9. Descriptius dels ítems de Bloc 1 ----------------------------------
desc_bloc1 <- dades %>%
  select(all_of(items_bloc1)) %>%
  psych::describe() %>% as.data.frame() %>%
  rownames_to_column("item") %>%
  select(item, n, mean, sd, min, max)
print(desc_bloc1)

# Descriptius de tots els índexs/dimensions
desc_indexs <- dades %>%
  select(starts_with("D1_"), starts_with("D2_"), starts_with("D3_"),
         starts_with("D4_"), starts_with("D5_"), starts_with("D6"),
         starts_with("D7_"), starts_with("D8_"), starts_with("idx_")) %>%
  psych::describe() %>% as.data.frame() %>%
  rownames_to_column("construct") %>%
  select(construct, n, mean, sd, min, max)
print(desc_indexs)

# ---- 10. Freqüències de les multiresposta ----------------------------------
freq_multi <- function(df, vars, etiqueta) {
  df %>%
    summarise(across(all_of(vars), ~ sum(.x, na.rm = TRUE))) %>%
    pivot_longer(everything(), names_to = "categoria", values_to = "n") %>%
    mutate(grup = etiqueta, pct = round(100 * n / nrow(df), 1)) %>%
    arrange(desc(n))
}
docents <- dades %>% filter(DocenciaDirecta == "Sí")
freq_etapes <- freq_multi(docents, vars_etapes, "Etapa")
freq_ambits <- freq_multi(docents, vars_ambits, "Àmbit")
freq_estres <- freq_multi(dades,  vars_estres, "Factor d'estrès (ít.22)")
print(freq_etapes); print(freq_ambits); print(freq_estres)

# ---- 11. Trajectòria energètica percebuda (ítems control 23, 25) ----------
# Categòriques ordinals; les deixem com a factor ordenat per descriure.
nivells_tend <- c("Clarament decreixent","Lleugerament decreixent","Estable",
                  "Lleugerament creixent","Clarament creixent",
                  "Fluctuant (alts i baixos marcats)")
dades <- dades %>%
  mutate(q23_tendencia_curs = factor(q23_tendencia_curs, levels = nivells_tend),
         q25_tendencia_rol  = factor(q25_tendencia_rol,  levels = nivells_tend))
print(janitor::tabyl(dades, q23_tendencia_curs))
print(janitor::tabyl(dades, q25_tendencia_rol))
print(janitor::tabyl(dades, q24_anys_rol))

# ---- 12. Dimensions/constructes per SEGMENTADOR ---------------------------
# Funció genèrica: mitjana de cada constructe segons la variable de segment.
# Exemples de segmentadors: Cargo, ServeiTerritorial, Complexitat, Denominacio,
# EeX, EdD, DocenciaDirecta...
resum_per_segment <- function(df, segment,
                              constructes = c("idx_funcionament_xarxa",
                                              "idx_sensacio_energia",
                                              "idx_recuperacio",
                                              "idx_alineament_proposit")) {
  df %>%
    group_by(across(all_of(segment))) %>%
    summarise(n = n(),
              across(all_of(constructes), ~ round(mean(.x, na.rm = TRUE), 2)),
              .groups = "drop") %>%
    arrange(desc(.data[[constructes[1]]]))
}

# Exemple amb les 8 dimensions del Bloc 1 segons Servei Territorial:
dims_bloc1 <- names(dimensions)
print(resum_per_segment(dades, "ServeiTerritorial", dims_bloc1))
# Exemple constructes globals per tipus de càrrec:
print(resum_per_segment(dades, "Cargo"))

# ---- 13. Gràfics (ggplot2) ------------------------------------------------
if (!dir.exists("sortides")) dir.create("sortides")

g1 <- desc_bloc1 %>%
  mutate(item = fct_reorder(item, mean)) %>%
  ggplot(aes(mean, item)) +
  geom_col(fill = "#2c7fb8") +
  geom_text(aes(label = round(mean, 2)), hjust = -0.1, size = 3) +
  scale_x_continuous(limits = c(0, 7.5), breaks = 1:7) +
  labs(title = "Bloc 1 · Funcionament de la xarxa: mitjana per ítem",
       subtitle = "Escala 1-7 (ítems 6 i 13 ja invertits)", x = "Mitjana", y = NULL) +
  theme_minimal()
ggsave("sortides/bloc1_per_item.png", g1, width = 8, height = 6, dpi = 150)

g2 <- desc_indexs %>%
  filter(str_starts(construct, "D")) %>%
  mutate(construct = fct_reorder(construct, mean)) %>%
  ggplot(aes(mean, construct)) +
  geom_col(fill = "#1c9099") +
  geom_text(aes(label = round(mean, 2)), hjust = -0.1, size = 3) +
  scale_x_continuous(limits = c(0, 7.5), breaks = 1:7) +
  labs(title = "Bloc 1 · Mitjana per dimensió (D1-D8)", x = "Mitjana", y = NULL) +
  theme_minimal()
ggsave("sortides/bloc1_per_dimensio.png", g2, width = 8, height = 5, dpi = 150)

g3 <- ggplot(freq_estres, aes(n, fct_reorder(categoria, n))) +
  geom_col(fill = "#d95f0e") +
  geom_text(aes(label = paste0(n, " (", pct, "%)")), hjust = -0.1, size = 3) +
  xlim(0, max(freq_estres$n) * 1.25) +
  labs(title = "Ítem 22 · Factors que més drenen l'energia", x = "Respostes", y = NULL) +
  theme_minimal()
ggsave("sortides/factors_estres.png", g3, width = 8, height = 6, dpi = 150)

# ---- 14. Exportar resultats -----------------------------------------------
write_xlsx(
  list(
    "Descriptius_items_bloc1" = desc_bloc1,
    "Descriptius_constructes" = desc_indexs,
    "Freq_etapes"             = freq_etapes,
    "Freq_ambits"             = freq_ambits,
    "Freq_factors_estres"     = freq_estres,
    "Dimensions_x_ServeiTerr" = resum_per_segment(dades, "ServeiTerritorial", dims_bloc1),
    "Constructes_x_Cargo"     = resum_per_segment(dades, "Cargo")
  ),
  "sortides/resultats_analisi.xlsx"
)

cat("\nFet! Revisa la carpeta 'sortides/' (gràfics .png i resultats_analisi.xlsx)\n")

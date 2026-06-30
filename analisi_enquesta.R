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
#     D3  Comunicació i mediació ................ ít. 7, 8
#     Dm  Coherència missatges als centres ...... ít. 6 (invertit)
#     D4  Feedback i aprenentatge ............... ít. 9, 10, 16
#     D5  Adaptació ............................. ít. 11, 12
#     D6  Lideratge distribuït .................. ít. 13
#     D6.1 Connexió multinivell ................. ít. 14
#     D7  Reflexió de constrenyiments ........... ít. 15
#     D8  Confiança (eficàcia col·lectiva) ...... ít. 17
#
#  BLOC 2 · SENSACIÓ D'ENERGIA I RECUPERACIÓ
#     Sensació d'energia ....................... ít. 18, 19, 20  (ít.21 ELIMINAT)
#     Recuperació energètica percebuda ......... ít. 26, 27
#
#  ÍTEM 22  (solt) ............... factors que més estrès causen (multiresposta)
#  ÍTEMS 23, 24, 25 (solts) ...... Trajectòria energètica percebuda (control)
#
#  BLOC 3 · ALINEAMENT PROPÒSIT VITAL – PROFESSIÓ ... ít. 28, 29, 31 (ít.30 ELIMINAT)
#
#  ÍTEMS INVERTITS (negatiu -> alt = pitjor): 6, 13, 19, 27
#
#  COM USAR-LO: ajusta la ruta de 'fitxer' i executa de dalt a baix
#  (Ctrl+Alt+R a RStudio). Els resultats es desen a la carpeta 'sortides/'.
# ============================================================================

# ---- 0. Paquets -----------------------------------------------------------
# Aquest bloc instal·la els paquets que faltin i els carrega automàticament.
# IMPORTANT: executa SEMPRE el script sencer des d'aquí (o fes 'Source').
paquets <- c("tidyverse","readxl","psych","janitor","writexl",
             "rstatix","effectsize","MBESS")
for (p in paquets) {
  if (!requireNamespace(p, quietly = TRUE)) {
    install.packages(p, repos = "https://cloud.r-project.org")
  }
  library(p, character.only = TRUE)
}
# Comprovació: el pipe %>% ha d'estar disponible
if (!exists("%>%")) stop("El paquet 'tidyverse' no s'ha carregat. Revisa la instal·lació.")

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
# Invertits: 6, 13 (Bloc 1); 19 (energia); 27 (recuperació).
# (ít.21 i ít.30 s'han eliminat de l'anàlisi -> no s'inverteixen.)
inv <- function(x) 8 - x
dades <- dades %>%
  mutate(
    coh06_r  = inv(coh06),
    coh13_r  = inv(coh13),
    en19_r   = inv(en19),
    en27_r   = inv(en27)
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
  D3_Comunicacio_mediacio  = c("coh07","coh08"),
  Dm_Coherencia_missatges  = c("coh06_r"),   # ít.6 com a dimensió pròpia
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
# Decisions preses:
#  * Sensació d'energia = 18, 19(inv), 20 (ít.21 eliminat). Escala curta i feble
#    (alpha ~0.40) però amb tots els ítems en la direcció correcta.
#  * BLOC 3 = 28, 29, 31 (ít.30 eliminat).
dades <- dades %>%
  mutate(
    idx_funcionament_xarxa = rowMeans(across(all_of(bloc1_corregits)), na.rm = TRUE),
    idx_energia            = rowMeans(cbind(en18, en19_r, en20), na.rm = TRUE),
    idx_recuperacio        = rowMeans(cbind(en26, en27_r), na.rm = TRUE),
    idx_alineament_proposit= rowMeans(cbind(prop28, prop29, prop31), na.rm = TRUE)
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
alpha_segur(dades, bloc1_corregits,                "BLOC 1 Funcionament xarxa")
alpha_segur(dades, c("en18","en19_r","en20"),      "Sensació d'energia (18,19r,20)")
alpha_segur(dades, c("en26","en27_r"),             "Recuperació energètica")
alpha_segur(dades, c("prop28","prop29","prop31"),  "BLOC 3 Alineament propòsit")

cat("\n--- Fiabilitat per dimensió (Bloc 1) ---\n")
for (nom in names(dimensions)) alpha_segur(dades, dimensions[[nom]], nom)

# ---- 8b. Consistència interna: coeficient OMEGA de McDonald ---------------
# L'omega és preferible a l'alfa de Cronbach, especialment en escales reduïdes,
# perquè no assumeix tau-equivalència (que tots els ítems pesin igual sobre el
# factor). És condició necessària per interpretar els blocs amb garanties.
#
# Regla de càlcul segons el nombre d'ítems:
#   >= 3 ítems  -> omega total de McDonald  (psych::omega, model d'1 factor)
#    = 2 ítems  -> coeficient de Spearman-Brown (l'omega no és identificable)
#    = 1 ítem   -> no aplica (ítem únic)
# Interpretació orientativa: >=.70 acceptable, >=.80 bona, >=.90 excel·lent.

# Nombre de rèpliques bootstrap per als IC (baixa'l a 500 si va lent)
B_BOOT <- 1000
set.seed(2024)   # reproducibilitat dels IC

# IC de la fiabilitat per bootstrap:
#  >=3 ítems -> omega amb IC BCa via MBESS::ci.reliability
#   =2 ítems -> IC percentil de Spearman-Brown (bootstrap manual)
omega_ic <- function(x, k, B = B_BOOT) {
  x <- x[stats::complete.cases(x), , drop = FALSE]
  if (k < 2) return(c(NA_real_, NA_real_))
  if (k == 2) {
    bs <- replicate(B, {
      idx <- sample(nrow(x), replace = TRUE)
      r <- suppressWarnings(cor(x[idx, 1], x[idx, 2]))
      2 * r / (1 + r)
    })
    return(unname(quantile(bs, c(.025, .975), na.rm = TRUE)))
  }
  res <- tryCatch(
    MBESS::ci.reliability(data = x, type = "omega",
                          interval.type = "bca", B = B),
    error = function(e) NULL)
  if (is.null(res)) c(NA_real_, NA_real_) else c(res$ci.lower, res$ci.upper)
}

fiab_omega <- function(df, items, etiqueta) {
  k <- length(items)
  x <- df[, items, drop = FALSE]
  n <- sum(stats::complete.cases(x))
  a <- if (k >= 2) suppressWarnings(psych::alpha(x, warnings = FALSE)$total$raw_alpha)
       else NA_real_
  if (k < 2) {
    om <- NA_real_; met <- "1 ítem (no aplica)"
  } else if (k == 2) {
    r  <- cor(x[[1]], x[[2]], use = "pairwise.complete.obs")
    om <- 2 * r / (1 + r)                       # Spearman-Brown
    met <- "Spearman-Brown (2 ítems)"
  } else {
    om <- tryCatch(
      suppressWarnings(suppressMessages(
        psych::omega(x, nfactors = 1, plot = FALSE, flip = FALSE)$omega.tot)),
      error = function(e) NA_real_)
    met <- "omega total (McDonald)"
  }
  ic <- if (k >= 2) omega_ic(x, k) else c(NA_real_, NA_real_)
  tibble(escala = etiqueta, n_items = k, n = n,
         alpha = round(a, 3), omega = round(om, 3),
         omega_ic_low = round(ic[1], 3), omega_ic_high = round(ic[2], 3),
         metode = met)
}

interpreta <- function(o) cut(o, c(-Inf, .60, .70, .80, .90, Inf),
  labels = c("insuficient","qüestionable","acceptable","bona","excel·lent"))

# Escales principals (blocs de l'instrument)
escales_blocs <- list(
  "BLOC 1 · Funcionament de la xarxa" = bloc1_corregits,
  "BLOC 2 · Sensació d'energia"       = c("en18","en19_r","en20"),
  "BLOC 2 · Recuperació energètica"   = c("en26","en27_r"),
  "BLOC 3 · Alineament propòsit"      = c("prop28","prop29","prop31")
)
taula_fiab <- map_dfr(names(escales_blocs),
                      ~ fiab_omega(dades, escales_blocs[[.x]], .x)) %>%
  mutate(valoracio = interpreta(omega))
cat("\n===== CONSISTÈNCIA INTERNA (omega de McDonald) — BLOCS =====\n")
print(as.data.frame(taula_fiab), row.names = FALSE)

# Mateix càlcul per a les dimensions del Bloc 1
taula_fiab_dim <- map_dfr(names(dimensions),
                          ~ fiab_omega(dades, dimensions[[.x]], .x)) %>%
  mutate(valoracio = interpreta(omega))
cat("\n===== CONSISTÈNCIA INTERNA — DIMENSIONS DEL BLOC 1 =====\n")
print(as.data.frame(taula_fiab_dim), row.names = FALSE)

# ---- 9. Descriptius dels ítems de Bloc 1 ----------------------------------
desc_bloc1 <- dades %>%
  select(all_of(items_bloc1)) %>%
  psych::describe() %>% as.data.frame() %>%
  rownames_to_column("item") %>%
  select(item, n, mean, sd, min, max)
print(desc_bloc1)

# Descriptius dels ítems d'energia 18-21 (es reporten individualment perquè
# NO formen una escala fiable) i de recuperació/propòsit.
desc_energia <- dades %>%
  select(en18, en19, en20, en26, en27, prop28, prop29, prop31) %>%
  psych::describe() %>% as.data.frame() %>%
  rownames_to_column("item") %>%
  select(item, n, mean, sd, min, max)
print(desc_energia)

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
                                              "idx_energia",
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
    "Fiabilitat_omega_blocs"  = taula_fiab,
    "Fiabilitat_omega_dims"   = taula_fiab_dim,
    "Descriptius_items_bloc1" = desc_bloc1,
    "Descriptius_energia_prop"= desc_energia,
    "Descriptius_constructes" = desc_indexs,
    "Freq_etapes"             = freq_etapes,
    "Freq_ambits"             = freq_ambits,
    "Freq_factors_estres"     = freq_estres,
    "Dimensions_x_ServeiTerr" = resum_per_segment(dades, "ServeiTerritorial", dims_bloc1),
    "Constructes_x_Cargo"     = resum_per_segment(dades, "Cargo")
  ),
  "sortides/resultats_analisi.xlsx"
)

# ===========================================================================
#  PART B · ANÀLISI PER SEGMENTADORS  (tests + mida de l'efecte + correcció)
# ===========================================================================

# ---- B1. Preparar les variables de segment --------------------------------
dades <- dades %>%
  mutate(
    # Complexitat en 4 trams
    Complexitat_grup = cut(as.numeric(Complexitat),
                           breaks = c(-Inf, 0.30, 0.50, 0.60, Inf),
                           labels = c("0-0,30","0,31-0,50","0,51-0,60","0,61-1")),
    # Servei Territorial: "0" = Central/FECC; serveis amb n<6 -> "Altres ST"
    ServeiTerr_grup = ServeiTerritorial %>% as.character() %>%
      dplyr::recode("0" = "Central/FECC") %>% replace_na("(sense dada)") %>%
      factor() %>% fct_lump_min(min = 6, other_level = "Altres ST"),
    # Indicadors 0/1 -> No/Sí
    EeX_f    = factor(EeX,    levels = c(0,1), labels = c("No","Sí")),
    EeXAMC_f = factor(EeXAMC, levels = c(0,1), labels = c("No","Sí")),
    EdD_f    = factor(EdD,    levels = c(0,1), labels = c("No","Sí")),

    # Cargo agrupat segons la classificació definida (9 grups)
    Cargo_grup = fct_collapse(factor(Cargo),
      "Titularitat"    = c("Titular"),
      "Equip directiu" = c("Director General","Cap Estudis ESO","Subdirector",
                           "Cap Estudis Primaria","Cap Estudis Batxillerat",
                           "Coordinador Infantil"),
      "Personal FECC"  = c("FECC"),
      "Professorat"    = c("Professor o mestre","Pastoral","TIC","Mestre de Primària",
                           "Mestre/a","Orientador (DOP)","COCOBE"),
      "Entitat FECC"   = c("APSEC","CCAPAC","APPEC"),
      "GdE"            = c("GdE Àmbit digital","GdE Matemàtiques","GdE Comprensió lectora",
                           "GdE Identitat Curricular","GdE Indicadors","GdE Cura"),
      "Responsables de xarxa" = c("Responsable de xarxa"),
      "Comité d'ètica" = c("Comité d'ètica"),
      "PAS"            = c("PAS"))
  )

constructes_clau <- c("idx_funcionament_xarxa","idx_energia",
                      "idx_recuperacio","idx_alineament_proposit")
segmentadors <- c("ServeiTerr_grup","Complexitat_grup","Cargo_grup",
                  "EeX_f","EeXAMC_f","EdD_f")

# ---- B2. Funció d'anàlisi: omnibus + mida d'efecte + correcció ------------
# 2 grups  -> Welch t-test (+ Mann-Whitney) i Cohen d
# 3+ grups -> Welch ANOVA  (+ Kruskal-Wallis) i eta2
# La correcció de Holm s'aplica DINS de cada segmentador (família de 4 tests).
compara_segment <- function(df, seg, constructes = constructes_clau,
                            min_cell = 3) {
  map_dfr(constructes, function(v) {
    d <- df %>% transmute(grp = droplevels(factor(.data[[seg]])),
                          y = .data[[v]]) %>% drop_na()
    # treure del test els grups amb menys de 'min_cell' casos (p.ex. PAS = 1)
    d <- d %>% group_by(grp) %>% filter(n() >= min_cell) %>%
      ungroup() %>% mutate(grp = droplevels(grp))
    k <- nlevels(d$grp)
    if (k < 2 || nrow(d) < 10) return(NULL)
    if (k == 2) {
      tt <- t.test(y ~ grp, data = d)
      mw <- suppressWarnings(wilcox.test(y ~ grp, data = d))
      es <- effectsize::cohens_d(y ~ grp, data = d)        # amb IC 95%
      tibble(segmentador = seg, construct = v, k = k, n = nrow(d),
             test = "Welch t", p = tt$p.value, p_noparam = mw$p.value,
             efecte = abs(es$Cohens_d), ef_ic_low = es$CI_low,
             ef_ic_high = es$CI_high, mesura = "Cohen d")
    } else {
      wa <- oneway.test(y ~ grp, data = d)
      kw <- kruskal.test(y ~ grp, data = d)
      es <- effectsize::eta_squared(aov(y ~ grp, data = d), partial = FALSE) # amb IC
      tibble(segmentador = seg, construct = v, k = k, n = nrow(d),
             test = "Welch ANOVA", p = wa$p.value, p_noparam = kw$p.value,
             efecte = es$Eta2[1], ef_ic_low = es$CI_low[1],
             ef_ic_high = es$CI_high[1], mesura = "eta2")
    }
  }) %>%
    mutate(p_adj = p.adjust(p, method = "holm"),
           sig = cut(p_adj, c(-Inf, .001, .01, .05, Inf),
                     labels = c("***","**","*","ns")))
}

# Interpretació orientativa de la mida d'efecte:
#   Cohen d: 0.2 petit · 0.5 mitjà · 0.8 gran
#   eta2:    0.01 petit · 0.06 mitjà · 0.14 gran

# ---- B3. Taula global de tests --------------------------------------------
taula_tests <- map_dfr(segmentadors, ~ compara_segment(dades, .x)) %>%
  mutate(across(c(p, p_noparam, p_adj, efecte, ef_ic_low, ef_ic_high),
                ~ round(.x, 4)))
cat("\n===== TESTS PER SEGMENTADOR (4 constructes globals) =====\n")
cat("p_adj = Holm dins de cada segmentador; efecte amb IC 95%\n")
print(as.data.frame(taula_tests), row.names = FALSE)

# ---- B3b. Mateixos tests a nivell de DIMENSIONS (D1-D8, Dm) ----------------
dims_cols <- names(dimensions)   # columnes d'índex de dimensió creades a la secció 6
taula_tests_dim <- map_dfr(segmentadors,
                           ~ compara_segment(dades, .x, constructes = dims_cols)) %>%
  mutate(across(c(p, p_noparam, p_adj, efecte, ef_ic_low, ef_ic_high),
                ~ round(.x, 4)))
cat("\n===== TESTS PER SEGMENTADOR (dimensions del Bloc 1) =====\n")
print(as.data.frame(taula_tests_dim), row.names = FALSE)

# ---- B4. Post-hoc (Games-Howell) per als omnibus significatius (k>2) ------
significatius <- taula_tests %>% filter(k > 2, p_adj < 0.05)
posthoc_list <- list()
if (nrow(significatius) > 0) {
  for (i in seq_len(nrow(significatius))) {
    seg <- significatius$segmentador[i]; v <- significatius$construct[i]
    d <- dades %>% transmute(grp = droplevels(factor(.data[[seg]])),
                             y = .data[[v]]) %>% drop_na() %>%
      group_by(grp) %>% filter(n() >= 3) %>% ungroup() %>%
      mutate(grp = droplevels(grp))
    ph <- rstatix::games_howell_test(d, y ~ grp)
    cat(sprintf("\n--- Post-hoc Games-Howell: %s ~ %s ---\n", v, seg))
    print(ph %>% select(group1, group2, estimate, p.adj, p.adj.signif))
    posthoc_list[[paste(v, seg, sep = "__")]] <- ph
  }
} else cat("\n(Cap omnibus de 3+ grups significatiu després de la correcció.)\n")

# ---- B5. Mitjanes (amb DE i n) per grup, per a cada segmentador -----------
mitjanes_segment <- function(df, seg, constructes = constructes_clau) {
  df %>% filter(!is.na(.data[[seg]])) %>%
    group_by(grup = .data[[seg]]) %>%
    summarise(n = n(),
              across(all_of(constructes),
                     list(m = ~round(mean(.x, na.rm = TRUE), 2),
                          de = ~round(sd(.x, na.rm = TRUE), 2))),
              .groups = "drop") %>%
    mutate(segmentador = seg, .before = 1)
}
taules_mitjanes <- map(segmentadors, ~ mitjanes_segment(dades, .x))
names(taules_mitjanes) <- segmentadors
walk(taules_mitjanes, ~ print(as.data.frame(.x), row.names = FALSE))

# ---- B6. Gràfic: mitjana dels constructes per cada segmentador ------------
graf_segment <- function(df, seg) {
  df %>% filter(!is.na(.data[[seg]])) %>%
    select(grp = all_of(seg), all_of(constructes_clau)) %>%
    pivot_longer(-grp, names_to = "construct", values_to = "valor") %>%
    group_by(grp, construct) %>%
    summarise(m = mean(valor, na.rm = TRUE),
              se = sd(valor, na.rm = TRUE)/sqrt(sum(!is.na(valor))), .groups="drop") %>%
    ggplot(aes(grp, m)) +
    geom_col(fill = "#4575b4") +
    geom_errorbar(aes(ymin = m-se, ymax = m+se), width = .2) +
    facet_wrap(~ construct, scales = "free_y") +
    coord_cartesian(ylim = c(1, 7)) +
    labs(title = paste("Constructes per", seg), x = NULL, y = "Mitjana (1-7)") +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 35, hjust = 1))
}
for (seg in segmentadors)
  ggsave(paste0("sortides/segment_", seg, ".png"), graf_segment(dades, seg),
         width = 9, height = 6, dpi = 150)

# ---- B8. Factors d'estrès (ítem 22) per segmentador -----------------------
# % de cada grup que marca cada factor + test d'associació (chi-quadrat;
# Fisher si hi ha cel·les esperades petites). Correcció BH per segmentador.
estres_pct_segment <- function(df, seg) {
  df %>% filter(!is.na(.data[[seg]])) %>%
    group_by(grup = .data[[seg]]) %>%
    summarise(n = n(),
              across(all_of(vars_estres), ~ round(100 * mean(.x, na.rm = TRUE), 1)),
              .groups = "drop") %>%
    mutate(segmentador = seg, .before = 1)
}
estres_tests_segment <- function(df, seg, min_cell = 5) {
  d <- df %>% filter(!is.na(.data[[seg]])) %>%
    group_by(grp = .data[[seg]]) %>% filter(n() >= min_cell) %>%
    ungroup() %>% mutate(grp = droplevels(factor(grp)))
  map_dfr(vars_estres, function(f) {
    tb <- table(d$grp, d[[f]])
    if (ncol(tb) < 2 || nrow(tb) < 2) return(tibble(segmentador=seg, factor=f, p=NA_real_))
    p <- tryCatch(suppressWarnings(chisq.test(tb)$p.value),
                  error = function(e) tryCatch(fisher.test(tb)$p.value,
                                               error = function(e) NA_real_))
    tibble(segmentador = seg, factor = f, p = p)
  }) %>% mutate(p_adj = p.adjust(p, method = "BH"))
}
estres_pct  <- map(segmentadors, ~ estres_pct_segment(dades, .x)) %>%
  setNames(segmentadors)
estres_tests <- map_dfr(segmentadors, ~ estres_tests_segment(dades, .x)) %>%
  mutate(across(c(p, p_adj), ~ round(.x, 4)))
cat("\n===== FACTORS D'ESTRÈS (ít.22) x SEGMENTADOR: tests d'associació =====\n")
print(as.data.frame(filter(estres_tests, !is.na(p))), row.names = FALSE)

# ---- B7. Exportar resultats inferencials ----------------------------------
fulls_export <- c(list("Tests_constructes" = taula_tests,
                       "Tests_dimensions"  = taula_tests_dim,
                       "Estres_tests"      = estres_tests),
                  setNames(taules_mitjanes, paste0("Mitj_", segmentadors)),
                  setNames(estres_pct, substr(paste0("Estres_", segmentadors), 1, 31)),
                  if (length(posthoc_list)) setNames(
                    lapply(posthoc_list, as.data.frame),
                    substr(paste0("PH_", names(posthoc_list)), 1, 31)))
write_xlsx(fulls_export, "sortides/resultats_segmentadors.xlsx")

# ===========================================================================
#  PART C · ÍTEMS DE CONTROL (23, 24, 25)
#  ítems 23 i 25 = trajectòria energètica (ordinal -2..+2 + flag 'Fluctuant')
#  ítem 24       = antiguitat al rol (ordinal 1..5)
#  Rol: validesa bivariada (Spearman) + covariables de control en models.
# ===========================================================================

# ---- C1. Recodificació (robusta a accents/guions, via grepl) ---------------
dir_code <- function(x) dplyr::case_when(
  grepl("Clarament decreixent",   x) ~ -2,
  grepl("Lleugerament decreixent",x) ~ -1,
  grepl("Estable",                x) ~  0,
  grepl("Lleugerament creixent",  x) ~  1,
  grepl("Clarament creixent",     x) ~  2,
  TRUE ~ NA_real_)                       # 'Fluctuant' queda NA en la direcció

dades <- dades %>%
  mutate(
    q23_dir   = dir_code(as.character(q23_tendencia_curs)),
    q23_fluct = as.integer(grepl("Fluctuant", as.character(q23_tendencia_curs))),
    q25_dir   = dir_code(as.character(q25_tendencia_rol)),
    q25_fluct = as.integer(grepl("Fluctuant", as.character(q25_tendencia_rol))),
    q24_anys_ord = dplyr::case_when(
      grepl("Menys",    as.character(q24_anys_rol)) ~ 1,
      grepl("^1",       as.character(q24_anys_rol)) ~ 2,   # 1-3 anys
      grepl("^4",       as.character(q24_anys_rol)) ~ 3,   # 4-6 anys
      grepl("^7",       as.character(q24_anys_rol)) ~ 4,   # 7-10 anys
      grepl("Més de 10",as.character(q24_anys_rol)) ~ 5,
      TRUE ~ NA_real_),
    # versió de la direcció amb Fluctuant=0 (per als models; el flag l'absorbeix)
    q23_dir0 = ifelse(q23_fluct == 1, 0, q23_dir),
    q25_dir0 = ifelse(q25_fluct == 1, 0, q25_dir)
  )

# ---- C2. Validesa bivariada: Spearman controls <-> constructes -------------
controls_ord <- c("q23_dir","q25_dir","q24_anys_ord")
cor_controls <- map_dfr(controls_ord, function(v) {
  map_dfr(constructes_clau, function(cc) {
    d <- dades %>% select(x = all_of(v), y = all_of(cc)) %>% drop_na()
    ct <- suppressWarnings(cor.test(d$x, d$y, method = "spearman"))
    tibble(control = v, construct = cc, n = nrow(d),
           rho = unname(ct$estimate), p = ct$p.value)
  })
}) %>% mutate(p_adj = p.adjust(p, method = "BH"),
             across(c(rho, p, p_adj), ~ round(.x, 4)))
cat("\n===== CONTROLS (23,25 direcció; 24 anys) x CONSTRUCTES: Spearman =====\n")
print(as.data.frame(cor_controls), row.names = FALSE)

# Flags 'Fluctuant' (binaris) vs constructes: diferència de mitjanes
fluct_efecte <- map_dfr(c("q23_fluct","q25_fluct"), function(v) {
  map_dfr(constructes_clau, function(cc) {
    d <- dades %>% select(g = all_of(v), y = all_of(cc)) %>% drop_na()
    tt <- t.test(y ~ g, data = d)
    tibble(flag = v, construct = cc,
           dif_No_menys_Si = round(diff(rev(tt$estimate)), 2),
           p = round(tt$p.value, 4))
  })
})
cat("\n===== Efecte de 'Fluctuant' (Sí vs No) sobre els constructes =====\n")
print(as.data.frame(fluct_efecte), row.names = FALSE)

# ---- C3. Models de control: jerarquia M0 (controls) -> M1 (+ segmentador) --
# Pregunta: el segmentador aporta variància MÉS ENLLÀ dels controls?
controls_form <- "q23_dir0 + q23_fluct + q25_dir0 + q25_fluct + q24_anys_ord"

model_control <- function(construct, seg) {
  d <- dades %>%
    transmute(y = .data[[construct]], grp = droplevels(factor(.data[[seg]])),
              q23_dir0, q23_fluct, q25_dir0, q25_fluct, q24_anys_ord) %>%
    group_by(grp) %>% filter(n() >= 3) %>% ungroup() %>%
    mutate(grp = droplevels(grp)) %>% drop_na()
  if (nrow(d) < 20 || nlevels(d$grp) < 2) return(NULL)
  M0 <- lm(as.formula(paste("y ~", controls_form)), data = d)
  M1 <- update(M0, . ~ . + grp)
  an <- anova(M0, M1)
  tibble(construct = construct, segmentador = seg, n = nrow(d),
         R2_controls = round(summary(M0)$r.squared, 3),
         R2_total    = round(summary(M1)$r.squared, 3),
         dR2_segment = round(summary(M1)$r.squared - summary(M0)$r.squared, 3),
         F_segment   = round(an$F[2], 2),
         p_segment   = round(an$`Pr(>F)`[2], 4))
}
models_control <- map_dfr(constructes_clau, function(cc)
  map_dfr(segmentadors, ~ model_control(cc, .x))) %>%
  group_by(construct) %>% mutate(p_seg_adj = round(p.adjust(p_segment, "holm"), 4)) %>%
  ungroup()
cat("\n===== MODELS DE CONTROL: aportació del segmentador sobre els controls =====\n")
print(as.data.frame(models_control), row.names = FALSE)

# Coeficients del model NOMÉS amb controls, per a cada constructe (quins controls pesen)
coef_controls <- map_dfr(constructes_clau, function(cc) {
  d <- dades %>% transmute(y = .data[[cc]], q23_dir0, q23_fluct,
                           q25_dir0, q25_fluct, q24_anys_ord) %>% drop_na()
  m <- lm(as.formula(paste("y ~", controls_form)), data = d)
  broom_like <- as.data.frame(summary(m)$coefficients)
  tibble(construct = cc, terme = rownames(broom_like),
         beta = round(broom_like[,1], 3), p = round(broom_like[,4], 4),
         R2 = round(summary(m)$r.squared, 3))
})
cat("\n===== Coeficients dels models només-controls =====\n")
print(as.data.frame(coef_controls), row.names = FALSE)

# ---- C4. Exportar -----------------------------------------------
write_xlsx(list(
  "Spearman_controls" = cor_controls,
  "Fluctuant_efecte"  = fluct_efecte,
  "Models_control"    = models_control,
  "Coef_controls"     = coef_controls
), "sortides/resultats_control.xlsx")

# ===========================================================================
#  PART D · ANÀLISI FACTORIAL EXPLORATÒRIA (AFE) del BLOC 1
#  Decisions: explorar 3-5 factors · matriu POLICÒRICA · rotació OBLIMIN ·
#  casos complets (listwise). Objectiu: veure si els 17 ítems s'agrupen en
#  les dimensions teòriques previstes.
# ===========================================================================
items_afe <- bloc1_corregits                      # 17 ítems (6 i 13 invertits)
dades_afe <- na.omit(as.data.frame(dades[, items_afe]))
cat("\n===== AFE · BLOC 1 =====\nCasos (listwise):", nrow(dades_afe),
    "| Ítems:", length(items_afe), "\n")

# ---- D1. Adequació mostral ------------------------------------------------
Rpoly <- psych::polychoric(dades_afe)$rho        # matriu de correlacions policòrica
kmo   <- psych::KMO(Rpoly)
bart  <- psych::cortest.bartlett(Rpoly, n = nrow(dades_afe))
cat(sprintf("KMO global = %.3f | Bartlett: chi2=%.0f, p=%.2g\n",
            kmo$MSA, bart$chisq, bart$p.value))

# ---- D2. Nombre de factors: anàlisi paral·lela (referència) ---------------
set.seed(2024)
pa <- psych::fa.parallel(dades_afe, fm = "minres", fa = "fa", cor = "poly",
                         plot = FALSE, n.iter = 100)
cat("Factors suggerits per anàlisi paral·lela:", pa$nfact, "\n")

# Mapa teòric ítem -> dimensió (per comparar amb l'empíric)
teoria_dim <- c(coh01="D1",coh02="D1",coh03="D1",coh04="D1",coh05="D2",
                coh06_r="Dm",coh07="D3",coh08="D3",coh09="D4",coh10="D4",
                coh11="D5",coh12="D5",coh13_r="D6",coh14="D6.1",coh15="D7",
                coh16="D4",coh17="D8")

# ---- D3. Solucions de 3, 4 i 5 factors (policòrica + oblimin) -------------
afe_models   <- list()
afe_loadings <- list()
afe_resum    <- list()
for (k in 3:5) {
  fa_k <- psych::fa(Rpoly, nfactors = k, rotate = "oblimin",
                    fm = "minres", n.obs = nrow(dades_afe))
  afe_models[[paste0("F", k)]] <- fa_k

  # Càrregues en format llarg + assignació al factor dominant + dimensió teòrica
  L <- unclass(fa_k$loadings)
  ld <- as.data.frame(round(L, 3)) %>% rownames_to_column("item")
  ld$factor_dominant <- paste0("MR", apply(abs(L), 1, which.max))
  ld$carrega_max     <- round(apply(L, 1, function(r) r[which.max(abs(r))]), 3)
  ld$dimensio_teorica<- teoria_dim[ld$item]
  afe_loadings[[paste0("F", k)]] <- ld

  vexp <- sum(fa_k$Vaccounted["Proportion Var", ])
  afe_resum[[paste0("F", k)]] <- tibble(
    n_factors = k, var_explicada = round(100*vexp,1),
    TLI = round(fa_k$TLI,3), RMSEA = round(fa_k$RMSEA[1],3),
    BIC = round(fa_k$BIC,1))

  cat(sprintf("\n--- AFE %d factors --- var=%.1f%% | TLI=%.2f | RMSEA=%.3f\n",
              k, 100*vexp, fa_k$TLI, fa_k$RMSEA[1]))
  print(fa_k$loadings, cutoff = 0.30, sort = TRUE)         # càrregues > .30
  cat("Correlacions entre factors (Phi):\n"); print(round(fa_k$Phi, 2))
}
afe_resum <- bind_rows(afe_resum)
cat("\n--- Comparació de solucions ---\n"); print(as.data.frame(afe_resum), row.names = FALSE)

# ---- D4. Gràfic scree / anàlisi paral·lela --------------------------------
png("sortides/afe_scree.png", width = 800, height = 600, res = 110)
psych::fa.parallel(dades_afe, fm = "minres", fa = "fa", cor = "poly", n.iter = 100,
                   main = "AFE Bloc 1 · Scree i anàlisi paral·lela")
dev.off()

# ---- D5. Exportar ---------------------------------------------------------
write_xlsx(c(list("Resum_solucions" = afe_resum),
             setNames(afe_loadings, paste0("Carregues_", names(afe_loadings)))),
           "sortides/resultats_afe.xlsx")

# ===========================================================================
#  PART E · DIMENSIONS EMPÍRIQUES (segons l'AFE de 3 factors del Bloc 1)
#  Es deriven AUTOMÀTICAMENT de la solució de 3 factors i es repeteix tota
#  l'anàlisi (fiabilitat + segmentadors + controls) EN PARAL·LEL a la teòrica
#  (les dimensions teòriques es mantenen intactes).
#  EF1/EF2/EF3 = factors empírics (MR de l'AFE). Mira 'assig_emp' per veure
#  quins ítems conté cada factor i posar-hi una etiqueta de contingut.
# ===========================================================================
fa3 <- afe_models[["F3"]]
L3  <- unclass(fa3$loadings)
CARREGA_MIN <- 0.30

# Assignació de cada ítem al factor on carrega més
assig_emp <- tibble(
  item    = rownames(L3),
  factor  = paste0("EF", apply(abs(L3), 1, which.max)),
  carrega = round(apply(L3, 1, function(r) r[which.max(abs(r))]), 3)) %>%
  mutate(assignat = abs(carrega) >= CARREGA_MIN,
         dimensio_teorica = teoria_dim[item])
cat("\n===== DIMENSIONS EMPÍRIQUES (AFE 3 factors) =====\n")
print(as.data.frame(assig_emp), row.names = FALSE)

# Ítems per factor (només assignats) i construcció dels índexs empírics
emp_items <- assig_emp %>% filter(assignat) %>% { split(.$item, .$factor) }
for (f in names(emp_items)) {
  its <- emp_items[[f]]
  mat <- do.call(cbind, lapply(its, function(it) {
    crg <- assig_emp$carrega[assig_emp$item == it]
    x <- dades[[it]]; if (crg < 0) 8 - x else x       # reverteix si càrrega < 0
  }))
  dades[[paste0("idx_", f)]] <- rowMeans(mat, na.rm = TRUE)
}
constructes_emp <- paste0("idx_", names(emp_items))

# ---- E1. Fiabilitat (omega) dels factors empírics -------------------------
taula_fiab_emp <- map_dfr(names(emp_items),
  ~ fiab_omega(dades, emp_items[[.x]], paste0("Empíric ", .x))) %>%
  mutate(valoracio = interpreta(omega))
cat("\n--- Fiabilitat (omega) dels factors empírics ---\n")
print(as.data.frame(taula_fiab_emp), row.names = FALSE)

# ---- E2. Segmentadors sobre els factors empírics --------------------------
taula_tests_emp <- map_dfr(segmentadors,
  ~ compara_segment(dades, .x, constructes = constructes_emp)) %>%
  mutate(across(c(p,p_noparam,p_adj,efecte,ef_ic_low,ef_ic_high), ~round(.x,4)))
cat("\n--- Tests per segmentador (factors empírics) ---\n")
print(as.data.frame(taula_tests_emp), row.names = FALSE)

# ---- E3. Models de control sobre els factors empírics ---------------------
models_control_emp <- map_dfr(constructes_emp, function(cc)
  map_dfr(segmentadors, ~ model_control(cc, .x))) %>%
  group_by(construct) %>% mutate(p_seg_adj = round(p.adjust(p_segment,"holm"),4)) %>%
  ungroup()
cat("\n--- Models de control (factors empírics) ---\n")
print(as.data.frame(models_control_emp), row.names = FALSE)

# ---- E4. Exportar ---------------------------------------------------------
write_xlsx(list(
  "Assignacio_items"  = assig_emp,
  "Fiabilitat_omega"  = taula_fiab_emp,
  "Tests_segmentador" = taula_tests_emp,
  "Models_control"    = models_control_emp
), "sortides/resultats_empiriques.xlsx")

cat("\nFet! Revisa la carpeta 'sortides/':\n",
    " - resultats_analisi.xlsx (descriptius i fiabilitat teòrica)\n",
    " - resultats_segmentadors.xlsx (tests, mitjanes, post-hoc)\n",
    " - resultats_control.xlsx (ítems 23-24-25: validesa i models)\n",
    " - resultats_afe.xlsx (anàlisi factorial exploratòria del Bloc 1)\n",
    " - resultats_empiriques.xlsx (dimensions empíriques: fiab. + segm. + control)\n",
    " - gràfics .png (inclòs afe_scree.png)\n")

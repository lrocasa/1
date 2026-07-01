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

# ---- 2b. Neteja de la Denominació (a nivell d'escola) ----------------------
# (i) Propagació dins l'escola: si alguna resposta d'una escola té denominació,
#     s'assigna a totes; si TOTES són buides, l'escola no és de xarxa. Corregeix
#     COR DE MARIA, IPSE, MARE DEL DIVÍ PASTOR, SANT JOAN BOSCO, STA TERESA JESÚS.
# (ii) Correccions manuals: escoles sense CAP denominació però que pertanyen a una
#     xarxa (confirmat per l'usuària a partir del nom de l'escola).
den_buit <- function(x) is.na(x) | trimws(as.character(x)) %in% c("0","","NA","nan")
norm_esc <- function(x) gsub("\\s+", " ",
  stringi::stri_trans_general(toupper(trimws(as.character(x))), "Latin-ASCII"))

dades <- dades %>%
  group_by(.k = norm_esc(Escola)) %>%
  mutate(.den_esc = { v <- Denominacio[!den_buit(Denominacio)]
                      if (length(v) > 0) as.character(v[1]) else NA_character_ },
         Denominacio = ifelse(!den_buit(Escola) & den_buit(Denominacio) & !is.na(.den_esc),
                              .den_esc, as.character(Denominacio))) %>%
  ungroup() %>% select(-.k, -.den_esc)

correccions_xarxa <- c(
  "ESCOLA PROFESSIONAL SALESIANA SARRIA" = "Salesians Catalunya",
  "FEDAC - CANET"        = "Fundació Educativa Dominiques de l'Anunciata Pare Coll - FEDAC",
  "FEDAC - SANT FELIU"   = "Fundació Educativa Dominiques de l'Anunciata Pare Coll - FEDAC",
  "VEDRUNA MALGRAT DE MAR" = "Fundació Vedruna Catalunya Educació",
  "VEDRUNA TARREGA"      = "Fundació Vedruna Catalunya Educació",
  "NADIS - SAGRAT COR SARRIA"       = "Congregació del Sagrat Cor (RSCJ)",
  "PADRE DAMIAN SAGRADOS CORAZONES" = "Congregació dels Sagrats Cors (SS.CC.)",
  "REGINA CARMELI"                  = "Germanes Carmelites de Sant Josep")
.k_esc <- norm_esc(dades$Escola)
for (.nm in names(correccions_xarxa))
  dades$Denominacio[.k_esc == .nm & den_buit(dades$Denominacio)] <- correccions_xarxa[[.nm]]
rm(.k_esc)

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
    # Xarxa d'escoles: NOMÉS té sentit per a ESCOLES. Considerem "escola" qui fa
    # docència/intervenció directa (DocenciaDirecta == "Sí"); la resta (personal
    # FECC central, etc.) queda com NA i s'exclou de tota anàlisi de Xarxa.
    # Dins les escoles: té denominació (nom) -> forma part d'una xarxa (Sí);
    # "0"/buit -> escola independent (No).
    Xarxa = factor(
      ifelse(is.na(DocenciaDirecta) | DocenciaDirecta != "Sí", NA_character_,
        ifelse(is.na(Denominacio) |
               trimws(as.character(Denominacio)) %in% c("0","","NA","nan"),
               "No", "Sí")),
      levels = c("No","Sí")),

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
                  "EeX_f","EeXAMC_f","EdD_f","Xarxa")

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
# fa.parallel policòric pot fallar en algunes versions de psych -> fallback Pearson
pa <- tryCatch(psych::fa.parallel(dades_afe, fm = "minres", fa = "fa", cor = "poly",
                                  plot = FALSE, n.iter = 100), error = function(e) NULL)
if (is.null(pa))
  pa <- tryCatch(psych::fa.parallel(dades_afe, fm = "minres", fa = "fa",
                                    plot = FALSE, n.iter = 100), error = function(e) NULL)
cat("Factors suggerits per anàlisi paral·lela:",
    if (is.null(pa)) "no disponible" else pa$nfact, "\n")

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
tryCatch(
  psych::fa.parallel(dades_afe, fm = "minres", fa = "fa", cor = "poly", n.iter = 100,
                     main = "AFE Bloc 1 · Scree i anàlisi paral·lela"),
  error = function(e)
    psych::fa.parallel(dades_afe, fm = "minres", fa = "fa", n.iter = 100,
                       main = "AFE Bloc 1 · Scree i anàlisi paral·lela (Pearson)"))
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
# Ítems problemàtics exclosos dels factors empírics (contingut incoherent amb la
# ubicació empírica i/o càrrega negativa contradictòria). Es mantenen als teòrics.
#  - coh06_r: ja cau per sota del llindar
#  - coh13_r: càrrega -0,60 a EF1 (signe contradictori) i parla d'equip, no de sistema
items_exclosos_emp <- c("coh13_r")

# Assignació de cada ítem al factor on carrega més
assig_emp <- tibble(
  item    = rownames(L3),
  factor  = paste0("EF", apply(abs(L3), 1, which.max)),
  carrega = round(apply(L3, 1, function(r) r[which.max(abs(r))]), 3)) %>%
  mutate(assignat = abs(carrega) >= CARREGA_MIN & !item %in% items_exclosos_emp,
         dimensio_teorica = teoria_dim[item])
cat("\n===== DIMENSIONS EMPÍRIQUES (AFE 3 factors) =====\n")
print(as.data.frame(assig_emp), row.names = FALSE)
exclosos_e <- assig_emp$item[!assig_emp$assignat]
cat("Ítems exclosos dels índexs empírics (càrrega <", CARREGA_MIN, "):",
    if (length(exclosos_e)) paste(exclosos_e, collapse = ", ") else "cap",
    "  (segueixen als constructes TEÒRICS)\n")

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

# ===========================================================================
#  PART F · AFE CONJUNTA de BLOC 2 + BLOC 3
#  Objectiu: comprovar la validesa discriminant -> si energia, recuperació i
#  propòsit s'agrupen en factors diferents. ~10 ítems (orientatiu amb n=143).
#  Mateixa metodologia: policòrica, oblimin, anàlisi paral·lela.
# ===========================================================================
# NOMÉS ítems retinguts: el 21 i el 30 estan ELIMINATS per decisió i NO entren.
df_f <- dades %>% transmute(
  en18, en19r = en19_r, en20,
  en26, en27r = en27_r,
  prop28, prop29, prop31)
df_f <- na.omit(as.data.frame(df_f))
cat("\n===== AFE conjunta BLOC 2 + BLOC 3 (ítems retinguts) =====\nCasos:", nrow(df_f),
    "| Ítems:", ncol(df_f), "\n")

teoria_f <- c(en18="Energia",en19r="Energia",en20="Energia",
              en26="Recuperació",en27r="Recuperació",
              prop28="Propòsit",prop29="Propòsit",prop31="Propòsit")

Rf   <- psych::polychoric(df_f)$rho
kmo_f<- psych::KMO(Rf)
bar_f<- psych::cortest.bartlett(Rf, n = nrow(df_f))
cat(sprintf("KMO = %.3f | Bartlett p = %.2g\n", kmo_f$MSA, bar_f$p.value))
set.seed(2024)
pa_f <- tryCatch(psych::fa.parallel(df_f, fm = "minres", fa = "fa", cor = "poly",
                                    plot = FALSE, n.iter = 100), error = function(e) NULL)
if (is.null(pa_f))
  pa_f <- tryCatch(psych::fa.parallel(df_f, fm = "minres", fa = "fa",
                                      plot = FALSE, n.iter = 100), error = function(e) NULL)
cat("Factors suggerits per paral·lela:",
    if (is.null(pa_f)) "no disponible" else pa_f$nfact, "\n")

afe23_loadings <- list(); afe23_models <- list()
for (k in 2:3) {
  fa_k <- psych::fa(Rf, nfactors = k, rotate = "oblimin",
                    fm = "minres", n.obs = nrow(df_f))
  afe23_models[[paste0("F",k)]] <- fa_k
  L <- unclass(fa_k$loadings)
  ld <- as.data.frame(round(L,3)) %>% rownames_to_column("item") %>%
    mutate(factor_dominant = paste0("MR", apply(abs(L),1,which.max)),
           dimensio_teorica = teoria_f[item])
  afe23_loadings[[paste0("F",k)]] <- ld
  cat(sprintf("\n--- %d factors --- var=%.1f%% | TLI=%.2f | RMSEA=%.3f\n",
      k, 100*sum(fa_k$Vaccounted["Proportion Var",]), fa_k$TLI, fa_k$RMSEA[1]))
  print(fa_k$loadings, cutoff = 0.30, sort = TRUE)
  cat("Correlacions entre factors (Phi):\n"); print(round(fa_k$Phi,2))
}

# ---- F2. Operacionalitzar els factors empírics del Bloc 2+3 (solució 2 factors)
# L'AFE mostra que Energia i Recuperació NO es separen (van juntes) i que el
# Propòsit és un factor a part. Construïm aquests factors empírics i hi repetim
# fiabilitat + segmentadors + controls (com al Bloc 1), en paral·lel als teòrics.
L2 <- unclass(afe23_models[["F2"]]$loadings)
assig_b23 <- tibble(
  item    = rownames(L2),
  factor  = paste0("BF", apply(abs(L2),1,which.max)),
  carrega = round(apply(L2,1,function(r) r[which.max(abs(r))]),3)) %>%
  mutate(assignat = abs(carrega) >= CARREGA_MIN,
         dimensio_teorica = teoria_f[item])
cat("\n===== FACTORS EMPÍRICS Bloc 2+3 (2 factors) =====\n")
print(as.data.frame(assig_b23), row.names = FALSE)
exclosos_f <- assig_b23$item[!assig_b23$assignat]
cat("Ítems exclosos dels índexs empírics (càrrega <", CARREGA_MIN, "):",
    if (length(exclosos_f)) paste(exclosos_f, collapse = ", ") else "cap",
    "  (segueixen als constructes TEÒRICS)\n")

# Per construir els índexs reaprofitem columnes de 'dades' (reversions ja fetes).
col_de <- function(it) dplyr::case_when(
  it == "en19r" ~ "en19_r",
  it == "en27r" ~ "en27_r",
  TRUE          ~ it)

emp_items_b23 <- assig_b23 %>% filter(assignat) %>% { split(.$item, .$factor) }
for (f in names(emp_items_b23)) {
  cols <- vapply(emp_items_b23[[f]], col_de, character(1))
  dades[[paste0("idx_", f)]] <- rowMeans(dades[, cols, drop = FALSE], na.rm = TRUE)
}
constructes_b23 <- paste0("idx_", names(emp_items_b23))

# Fiabilitat (omega) dels factors empírics Bloc 2+3
fiab_items_b23 <- lapply(emp_items_b23, function(its) vapply(its, col_de, character(1)))
taula_fiab_b23 <- map_dfr(names(fiab_items_b23),
  ~ fiab_omega(dades, fiab_items_b23[[.x]], paste0("Empíric Bloc2+3 ", .x))) %>%
  mutate(valoracio = interpreta(omega))
cat("\n--- Fiabilitat (omega) factors empírics Bloc 2+3 ---\n")
print(as.data.frame(taula_fiab_b23), row.names = FALSE)

# Segmentadors i models de control sobre els factors empírics Bloc 2+3
taula_tests_b23 <- map_dfr(segmentadors,
  ~ compara_segment(dades, .x, constructes = constructes_b23)) %>%
  mutate(across(c(p,p_noparam,p_adj,efecte,ef_ic_low,ef_ic_high), ~round(.x,4)))
cat("\n--- Tests per segmentador (factors empírics Bloc 2+3) ---\n")
print(as.data.frame(taula_tests_b23), row.names = FALSE)

models_control_b23 <- map_dfr(constructes_b23, function(cc)
  map_dfr(segmentadors, ~ model_control(cc, .x))) %>%
  group_by(construct) %>% mutate(p_seg_adj = round(p.adjust(p_segment,"holm"),4)) %>%
  ungroup()
cat("\n--- Models de control (factors empírics Bloc 2+3) ---\n")
print(as.data.frame(models_control_b23), row.names = FALSE)

write_xlsx(c(setNames(afe23_loadings, paste0("Carregues_", names(afe23_loadings))),
             list("Assignacio_items"  = assig_b23,
                  "Fiabilitat_omega"  = taula_fiab_b23,
                  "Tests_segmentador" = taula_tests_b23,
                  "Models_control"    = models_control_b23)),
           "sortides/resultats_afe_bloc23.xlsx")

# ---- PART C (versió EMPÍRICA): controls 23-24-25 vs constructes empírics ---
# Completa l'estudi perquè la validesa dels controls també es faci sobre els
# factors empírics (Bloc 1 + Bloc 2+3), no només sobre els teòrics (PART C).
constr_emp_all <- c(constructes_emp, constructes_b23)
cor_controls_emp <- map_dfr(controls_ord, function(v) {
  map_dfr(constr_emp_all, function(cc) {
    d <- dades %>% select(x = all_of(v), y = all_of(cc)) %>% drop_na()
    ct <- suppressWarnings(cor.test(d$x, d$y, method = "spearman"))
    tibble(control = v, construct = cc, n = nrow(d),
           rho = unname(ct$estimate), p = ct$p.value)
  })
}) %>% mutate(p_adj = p.adjust(p, "BH"), across(c(rho,p,p_adj), ~round(.x,4)))
cat("\n--- Controls 23-24-25 vs constructes EMPÍRICS (Spearman) ---\n")
print(as.data.frame(cor_controls_emp), row.names = FALSE)

coef_controls_emp <- map_dfr(constr_emp_all, function(cc) {
  d <- dades %>% transmute(y = .data[[cc]], q23_dir0, q23_fluct,
                           q25_dir0, q25_fluct, q24_anys_ord) %>% drop_na()
  m <- lm(as.formula(paste("y ~", controls_form)), data = d)
  bl <- as.data.frame(summary(m)$coefficients)
  tibble(construct = cc, terme = rownames(bl), beta = round(bl[,1],3),
         p = round(bl[,4],4), R2 = round(summary(m)$r.squared,3))
})
write_xlsx(list("Spearman_controls_emp" = cor_controls_emp,
                "Coef_controls_emp"     = coef_controls_emp),
           "sortides/resultats_control_empiric.xlsx")

# ===========================================================================
#  PART G · ROLS MÚLTIPLES (Cargo + Subcargo) com a indicadors 0/1
#  Una persona pot tenir diversos càrrecs. Es combinen Cargo + Subcargos
#  (separats per '/') en indicadors binaris per grup de rol (multi-pertinença,
#  com etapes/àmbits). Per a cada rol es compara qui el té vs qui no, sobre
#  els constructes. Una fila per persona (n=143): independència preservada.
# ===========================================================================
map_rol <- function(x) {
  x <- trimws(x)
  dplyr::case_when(
    grepl("GdE", x)                  ~ "GdE",
    grepl("Responsable de xarxa", x) ~ "Responsables de xarxa",
    x == "Titular"                   ~ "Titularitat",
    grepl("Director|Subdirector|Cap [Ee]studis|Coordinador Infantil|Coordinador CF", x) ~ "Equip directiu",
    grepl("Comité d'ètica", x)       ~ "Comité d'ètica",
    x %in% c("APSEC","CCAPAC","APPEC") ~ "Entitat FECC",
    grepl("FECC|Tècnic|Responsable", x) ~ "Personal FECC",  # inclou Tècnic i Responsable (NO Col·laboradora: s'elimina)
    grepl("Professor|Mestre|Pastoral|TIC|Orientador|COCOBE", x) ~ "Professorat",
    x == "PAS"                       ~ "PAS",
    TRUE                             ~ NA_character_)
}

# Conjunt de rols per persona (Cargo + Subcargo separat per '/')
rols_persona <- lapply(seq_len(nrow(dades)), function(i) {
  toks <- c(as.character(dades$Cargo[i]),
            unlist(strsplit(as.character(dades$Subcargo[i]), "/", fixed = TRUE)))
  toks <- trimws(toks); toks <- toks[!toks %in% c("", "0", "NA", "nan")]
  unique(stats::na.omit(map_rol(toks)))
})
grups_rol <- sort(unique(stats::na.omit(unlist(rols_persona))))

# Indicadors 0/1 (factor No/Sí) per a cada grup de rol
for (gr in grups_rol) {
  ind <- vapply(rols_persona, function(r) as.integer(gr %in% r), integer(1))
  dades[[paste0("rolind_", gr)]] <- factor(ind, levels = c(0,1), labels = c("No","Sí"))
}

# Prevalença (multi-pertinença) vs Cargo principal sol
prevalenca_rols <- tibble(
  rol = grups_rol,
  n_multi = sapply(grups_rol, function(gr) sum(vapply(rols_persona, function(r) gr %in% r, logical(1))))
) %>% arrange(desc(n_multi))
cat("\n===== PREVALENÇA DE ROLS (multi-pertinença: Cargo + Subcargo) =====\n")
print(as.data.frame(prevalenca_rols), row.names = FALSE)

# Tests "té el rol vs no", per a cada rol amb >=5 membres, sobre TOTS els
# constructes (teòrics + empírics del Bloc 1 + empírics del Bloc 2+3).
rol_segs   <- paste0("rolind_", prevalenca_rols$rol[prevalenca_rols$n_multi >= 5])
constr_tot <- c(constructes_clau, constructes_emp, constructes_b23)
tests_rols <- map_dfr(rol_segs, ~ compara_segment(dades, .x, constructes = constr_tot)) %>%
  mutate(across(c(p,p_noparam,p_adj,efecte,ef_ic_low,ef_ic_high), ~ round(.x,4)))
cat("\n===== TESTS: TÉ EL ROL vs NO, per constructe (Cohen d, IC, p Holm) =====\n")
print(as.data.frame(tests_rols), row.names = FALSE)

# Nombre de rols per persona (polivalència / possible sobrecàrrega): variable
# CONTÍNUA -> correlació de Spearman amb els constructes (teòric + empíric).
dades$n_rols <- vapply(rols_persona, length, integer(1))
cat("\n--- Nombre de rols per persona ---\n"); print(table(dades$n_rols))
cor_nrols <- map_dfr(constr_tot, function(cc) {
  d <- dades %>% transmute(x = n_rols, y = .data[[cc]]) %>% drop_na()
  ct <- suppressWarnings(cor.test(d$x, d$y, method = "spearman"))
  tibble(construct = cc, n = nrow(d),
         rho = round(unname(ct$estimate),3), p = round(ct$p.value,4))
}) %>% mutate(p_adj = round(p.adjust(p, "BH"),4))
cat("\n--- n_rols vs constructes (Spearman) ---\n")
print(as.data.frame(cor_nrols), row.names = FALSE)

write_xlsx(list("Prevalenca_rols" = prevalenca_rols, "Tests_rols" = tests_rols,
                "n_rols_Spearman" = cor_nrols),
           "sortides/resultats_rols_multiples.xlsx")

# ===========================================================================
#  PART H · HIPÒTESI: participació en projectes estratègics FECC
#  EeX, EeXAMC, EdD = participació en projectes (formacions, assessoraments...).
#  H1: els participants haurien de mostrar MÉS coherència, energia i propòsit.
#  Es comprova amb DIRECCIÓ de l'efecte (Sí - No) sobre tots els constructes.
#  ATENCIÓ: és observacional -> no permet inferir causalitat (pot haver-hi
#  autoselecció: qui ja està millor/pitjor s'apunta més als projectes).
# ===========================================================================
# GdE (Grup d'Experts) compta TAMBÉ com a projecte estratègic (a més de rol).
dades <- dades %>% mutate(
  GdE_proj = rolind_GdE,                                   # factor No/Sí (creat a PART G)
  n_projectes_FECC = (EeX == 1) + (EeXAMC == 1) + (EdD == 1) + (rolind_GdE == "Sí"),
  particip_FECC = factor(as.integer(n_projectes_FECC >= 1),
                         levels = c(0,1), labels = c("No","Sí")))

# Test direccional Sí vs No (d amb signe: + = participants MÉS alts)
prova_hipotesi <- function(df, var, constructes) {
  map_dfr(constructes, function(cc) {
    d <- df %>% transmute(g = droplevels(factor(.data[[var]])),
                          y = .data[[cc]]) %>% drop_na()
    if (nlevels(d$g) < 2 || any(table(d$g) < 3)) return(NULL)
    m  <- tapply(d$y, d$g, mean)
    nN <- sum(d$g=="No"); nS <- sum(d$g=="Sí")
    sp <- sqrt(((nN-1)*var(d$y[d$g=="No"]) + (nS-1)*var(d$y[d$g=="Sí"]))/(nN+nS-2))
    tt <- t.test(y ~ g, data = d)
    tibble(variable = var, construct = cc, n_Si = nS,
           mitj_No = round(m["No"],2), mitj_Si = round(m["Sí"],2),
           dif = round(m["Sí"]-m["No"],2),
           d_signe = round((m["Sí"]-m["No"])/sp, 3),
           p = round(tt$p.value, 4))
  })
}
vars_fecc  <- c("EeX_f","EeXAMC_f","EdD_f","GdE_proj","particip_FECC")
constr_tot <- c(constructes_clau, constructes_emp, constructes_b23)
tests_hipotesi <- map_dfr(vars_fecc, ~ prova_hipotesi(dades, .x, constr_tot)) %>%
  group_by(variable) %>% mutate(p_adj = round(p.adjust(p,"holm"),4)) %>% ungroup()
cat("\n===== HIPÒTESI projectes FECC: participant (Sí) vs no =====\n")
cat("d_signe > 0 -> participants MÉS alts (a favor de la hipòtesi)\n")
print(as.data.frame(tests_hipotesi), row.names = FALSE)

# Dosi-resposta: nombre de projectes vs constructes (Spearman)
dosi_fecc <- map_dfr(constr_tot, function(cc) {
  d <- dades %>% transmute(x = n_projectes_FECC, y = .data[[cc]]) %>% drop_na()
  ct <- suppressWarnings(cor.test(d$x, d$y, method = "spearman"))
  tibble(construct = cc, rho = round(unname(ct$estimate),3), p = round(ct$p.value,4))
})
cat("\n--- Dosi-resposta (nombre de projectes FECC, Spearman) ---\n")
print(as.data.frame(dosi_fecc), row.names = FALSE)

write_xlsx(list("Hipotesi_FECC" = tests_hipotesi, "Dosi_resposta" = dosi_fecc),
           "sortides/resultats_hipotesi_FECC.xlsx")

# ===========================================================================
#  PART I · ANÀLISI COMPARATIVA PER SUBGRUPS (no paramètrica)  [resol P1/P2]
#  Proves de Mann-Whitney (2 grups) i Kruskal-Wallis (3+), adequades per la
#  no-normalitat de les escales Likert. Subgrups: ROL (multi-pertinença),
#  NIVELL JERÀRQUIC i CONTEXT TERRITORIAL. Sobre constructes teòrics i empírics.
#  Mides d'efecte: r (Mann-Whitney), epsilon² (Kruskal-Wallis). Post-hoc: Dunn.
# ===========================================================================

# ---- I1. Nivell jeràrquic (definit per l'usuària; multi-rol -> nivell més alt)
map_nivell <- function(x) {
  x <- trimws(x)
  dplyr::case_when(
    grepl("Director.* [Gg]eneral", x) ~ "Governança de sistema",   # Dir. General/adjunt
    grepl("Responsable", x)           ~ "Governança de sistema",   # Resp. de xarxa i Resp.
    grepl("GdE", x)                   ~ "Governança intermèdia",
    x == "Titular"                    ~ "Governança intermèdia",
    grepl("Tècnic", x)                ~ "Governança intermèdia",
    grepl("Directora|Subdirector|Cap [Ee]studis|Coordinador Infantil|Coordinador CF", x) ~ "Nucli operatiu",
    grepl("Professor|Mestre|Pastoral|TIC|Orientador|COCOBE", x) ~ "Nucli operatiu",
    x == "PAS"                        ~ "Nucli operatiu",
    x %in% c("APSEC","CCAPAC","APPEC") | grepl("Comité d'ètica", x) ~ "Comunitat i altres",
    TRUE ~ NA_character_)             # 'FECC' genèric: el resolen els altres tokens (subcargo)
}
prio_niv <- c("Governança de sistema"=4, "Governança intermèdia"=3,
              "Nucli operatiu"=2, "Comunitat i altres"=1)
dades$NivellJerarquic <- factor(vapply(seq_len(nrow(dades)), function(i) {
  toks <- c(as.character(dades$Cargo[i]),
            unlist(strsplit(as.character(dades$Subcargo[i]), "/", fixed = TRUE)))
  toks <- trimws(toks); toks <- toks[!toks %in% c("","0","NA","nan")]
  ls <- stats::na.omit(map_nivell(toks))
  if (length(ls) == 0) NA_character_ else names(which.max(prio_niv[ls]))
}, character(1)),
levels = c("Nucli operatiu","Governança intermèdia","Governança de sistema","Comunitat i altres"))
cat("\n===== NIVELL JERÀRQUIC (distribució) =====\n")
print(table(dades$NivellJerarquic, useNA = "ifany"))

constr_tot <- c(constructes_clau, constructes_emp, constructes_b23)

# ---- I2. Kruskal-Wallis (3+ grups): nivell jeràrquic i territori -----------
kw_subgrups <- function(df, fvar, constructes, min_cell = 3) {
  map_dfr(constructes, function(cc) {
    d <- df %>% transmute(g = droplevels(factor(.data[[fvar]])), y = .data[[cc]]) %>%
      drop_na() %>% group_by(g) %>% filter(n() >= min_cell) %>% ungroup() %>%
      mutate(g = droplevels(g))
    if (nlevels(d$g) < 2) return(NULL)
    kt <- kruskal.test(y ~ g, data = d)
    es <- tryCatch(rstatix::kruskal_effsize(d, y ~ g)$effsize, error = function(e) NA_real_)
    tibble(variable = fvar, construct = cc, k = nlevels(d$g), n = nrow(d),
           H = round(unname(kt$statistic),2), p = round(kt$p.value,4),
           epsilon2 = round(es,3))
  }) %>% mutate(p_adj = round(p.adjust(p, "holm"),4))
}
tests_kw <- bind_rows(
  kw_subgrups(dades, "NivellJerarquic", constr_tot),
  kw_subgrups(dades, "ServeiTerr_grup", constr_tot))
cat("\n===== KRUSKAL-WALLIS · nivell jeràrquic i territori =====\n")
print(as.data.frame(tests_kw), row.names = FALSE)

# Post-hoc de Dunn (Holm) per als Kruskal-Wallis significatius
kw_sig <- tests_kw %>% filter(p_adj < 0.05)
dunn_list <- list()
for (i in seq_len(nrow(kw_sig))) {
  fvar <- kw_sig$variable[i]; cc <- kw_sig$construct[i]
  d <- dades %>% transmute(g = droplevels(factor(.data[[fvar]])), y = .data[[cc]]) %>% drop_na()
  ph <- rstatix::dunn_test(d, y ~ g, p.adjust.method = "holm")
  dunn_list[[paste(fvar, cc, sep="__")]] <- as.data.frame(ph)
  cat(sprintf("\n--- Dunn post-hoc: %s ~ %s ---\n", cc, fvar))
  print(ph[, c("group1","group2","statistic","p.adj","p.adj.signif")])
}
if (!nrow(kw_sig)) cat("\n(Cap Kruskal-Wallis significatiu després de la correcció.)\n")

# ---- I3. Mann-Whitney (té el rol vs no), per als rols amb >=5 membres ------
mw_rols <- function(df, rol_vars, constructes, min_cell = 5) {
  map_dfr(rol_vars, function(rv) {
    map_dfr(constructes, function(cc) {
      d <- df %>% transmute(g = droplevels(factor(.data[[rv]])), y = .data[[cc]]) %>% drop_na()
      if (nlevels(d$g) < 2 || any(table(d$g) < min_cell)) return(NULL)
      wt <- suppressWarnings(wilcox.test(y ~ g, data = d))
      r  <- tryCatch(rstatix::wilcox_effsize(d, y ~ g)$effsize, error = function(e) NA_real_)
      m  <- tapply(d$y, d$g, median)
      tibble(rol = sub("rolind_","",rv), construct = cc,
             md_No = round(m["No"],2), md_Si = round(m["Sí"],2),
             p = round(wt$p.value,4), r_efecte = round(r,3))
    })
  }) %>% group_by(rol) %>% mutate(p_adj = round(p.adjust(p,"holm"),4)) %>% ungroup()
}
rol_vars   <- paste0("rolind_", prevalenca_rols$rol[prevalenca_rols$n_multi >= 5])
tests_mw_rols <- mw_rols(dades, rol_vars, constr_tot)
cat("\n===== MANN-WHITNEY · rol (multi-pertinença) té vs no =====\n")
print(as.data.frame(tests_mw_rols), row.names = FALSE)

# ---- I4. Exportar ---------------------------------------------------------
write_xlsx(c(list("KW_nivell_territori" = tests_kw,
                  "MW_rols"             = tests_mw_rols),
             if (length(dunn_list)) setNames(dunn_list,
               substr(paste0("Dunn_", names(dunn_list)),1,31))),
           "sortides/resultats_subgrups_noparam.xlsx")

# ===========================================================================
#  PART J · ETAPES (cursos) i ÀMBITS + CORRELACIONS ENTRE CONSTRUCTES
#  - Etapes/àmbits: indicadors 0/1; només té sentit en DOCENTS. Mann-Whitney
#    "imparteix en aquesta etapa/àmbit vs no" entre els docents.
#  - Correlacions de Spearman entre els constructes (teòrics + empírics).
# ===========================================================================
docents_df <- dades %>% filter(DocenciaDirecta == "Sí")

mw_binari <- function(df, vars, constructes, min_cell = 5) {
  map_dfr(vars, function(v) {
    map_dfr(constructes, function(cc) {
      d <- df %>% transmute(g = factor(ifelse(.data[[v]] == 1, "Sí", "No"),
                                       levels = c("No","Sí")),
                            y = .data[[cc]]) %>% drop_na() %>% mutate(g = droplevels(g))
      if (nlevels(d$g) < 2 || any(table(d$g) < min_cell)) return(NULL)
      wt <- suppressWarnings(wilcox.test(y ~ g, data = d))
      r  <- tryCatch(rstatix::wilcox_effsize(d, y ~ g)$effsize, error = function(e) NA_real_)
      m  <- tapply(d$y, d$g, median)
      tibble(variable = v, construct = cc,
             md_No = round(m["No"],2), md_Si = round(m["Sí"],2),
             p = round(wt$p.value,4), r_efecte = round(r,3))
    })
  }) %>% group_by(variable) %>% mutate(p_adj = round(p.adjust(p,"holm"),4)) %>% ungroup()
}
tests_etapes <- mw_binari(docents_df, vars_etapes, constr_tot)
tests_ambits <- mw_binari(docents_df, vars_ambits, constr_tot)
cat("\n===== ETAPES (cursos) · Mann-Whitney (només docents) =====\n")
print(as.data.frame(tests_etapes), row.names = FALSE)
cat("\n===== ÀMBITS · Mann-Whitney (només docents) =====\n")
print(as.data.frame(tests_ambits), row.names = FALSE)

# Correlacions de Spearman ENTRE constructes (teòrics + empírics del Bloc 1)
constr_corr <- c(constructes_clau, constructes_emp)
cc_obj <- psych::corr.test(dades[, constr_corr], method = "spearman", adjust = "holm")
cat("\n===== CORRELACIONS ENTRE CONSTRUCTES (Spearman, r) =====\n")
print(round(cc_obj$r, 2))
cat("\n(p ajustada Holm a sota de la diagonal de cc_obj$p)\n")

write_xlsx(list(
  "Etapes_MW"  = tests_etapes,
  "Ambits_MW"  = tests_ambits,
  "Correl_r"   = as.data.frame(round(cc_obj$r,3)) %>% rownames_to_column("constructe"),
  "Correl_p"   = as.data.frame(round(cc_obj$p,4)) %>% rownames_to_column("constructe")
), "sortides/resultats_comparacions_extra.xlsx")

# ===========================================================================
#  PART L · CORRELACIÓ ENTRE LES 3 DIMENSIONS PRINCIPALS (P3)
#  Spearman entre Funcionament de la xarxa, Alineació de propòsits i Sensació
#  d'energia, amb IC 95% per bootstrap. Explora la relació coherència<->energia.
#  Es fa en teòric i, en l'empíric, es mira quina FACETA de coherència (factors
#  del Bloc 1) es lliga més a l'energia.
# ===========================================================================
set.seed(2024)
sp_ci <- function(a, b, B = 2000) {
  d <- na.omit(data.frame(x = a, y = b)); n <- nrow(d)
  rho <- cor(d$x, d$y, method = "spearman")
  pe  <- suppressWarnings(cor.test(d$x, d$y, method = "spearman"))$p.value
  bs  <- replicate(B, { idx <- sample(n, replace = TRUE)
                        suppressWarnings(cor(d$x[idx], d$y[idx], method = "spearman")) })
  ci  <- quantile(bs, c(.025, .975), na.rm = TRUE)
  tibble(rho = round(rho,3), ic_low = round(unname(ci[1]),3),
         ic_high = round(unname(ci[2]),3), p = round(pe,4), n = n)
}

# 3 dimensions principals (teòric)
parelles <- list(
  c("Funcionament","Energia",   "idx_funcionament_xarxa","idx_energia"),
  c("Propòsit","Energia",       "idx_alineament_proposit","idx_energia"),
  c("Funcionament","Propòsit",  "idx_funcionament_xarxa","idx_alineament_proposit"))
cor3_teoric <- map_dfr(parelles, function(p)
  bind_cols(tibble(dim_A = p[1], dim_B = p[2]),
            sp_ci(dades[[p[3]]], dades[[p[4]]])))
cat("\n===== P3 · CORRELACIÓ ENTRE LES 3 DIMENSIONS (teòric, Spearman + IC95%) =====\n")
print(as.data.frame(cor3_teoric), row.names = FALSE)

# Empíric: quina faceta de coherència (factors del Bloc 1) es lliga a l'energia
corE_facetes <- map_dfr(constructes_emp, function(f)
  bind_cols(tibble(faceta = f, vs = "Energia"),
            sp_ci(dades[[f]], dades$idx_energia)))
cat("\n===== P3 · ENERGIA vs facetes empíriques de coherència (Bloc 1) =====\n")
print(as.data.frame(corE_facetes), row.names = FALSE)

write_xlsx(list("P3_3dimensions" = cor3_teoric, "P3_energia_facetes" = corE_facetes),
           "sortides/resultats_correlacio_P3.xlsx")

# ===========================================================================
#  PART M · ACORD I VARIÀNCIA A NIVELL D'ESCOLA
#  Explora si les persones d'una mateixa escola "comparteixen resultats":
#   - ICC(1): quanta variància d'un constructe és ENTRE escoles (fenomen d'escola)
#   - ICC(2): fiabilitat de la MITJANA de l'escola
#   - rwg(j): consens/acord dels companys dins de cada escola
#  Només escoles amb >=2 respostes. Anàlisi DESCRIPTIVA/EXPLORATÒRIA: amb poques
#  escoles i mides petites NO es fan models multinivell inferencials.
# ===========================================================================
dades <- dades %>% mutate(escola_key = norm_esc(Escola))
esc_valides <- dades %>% filter(!den_buit(Escola)) %>%
  count(escola_key) %>% filter(n >= 2) %>% pull(escola_key)
dd_esc <- dades %>% filter(escola_key %in% esc_valides)
cat(sprintf("\n===== ACORD INTRA-ESCOLA (%d escoles amb >=2 respostes, %d respostes) =====\n",
            length(esc_valides), nrow(dd_esc)))

constr_esc <- c(constructes_clau, constructes_emp)

# ICC(1) i ICC(2) via ANOVA d'un factor (constructe ~ escola)
icc_fn <- function(df, cc) {
  d <- df %>% transmute(g = escola_key, y = .data[[cc]]) %>% drop_na()
  k <- dplyr::n_distinct(d$g); N <- nrow(d)
  if (k < 2 || N <= k) return(c(ICC1 = NA_real_, ICC2 = NA_real_))
  grand <- mean(d$y); grp <- split(d$y, d$g)
  nj <- sapply(grp, length); mj <- sapply(grp, mean)
  MSB <- sum(nj * (mj - grand)^2) / (k - 1)
  MSW <- sum(sapply(grp, function(y) sum((y - mean(y))^2))) / (N - k)
  n0  <- (N - sum(nj^2)/N) / (k - 1)
  c(ICC1 = round((MSB - MSW)/(MSB + (n0 - 1)*MSW), 3),
    ICC2 = round((MSB - MSW)/MSB, 3))
}
taula_icc <- map_dfr(constr_esc, function(cc) {
  v <- icc_fn(dd_esc, cc); tibble(construct = cc, ICC1 = v["ICC1"], ICC2 = v["ICC2"])
})
cat("\n--- ICC (quanta variància és ENTRE escoles) ---\n")
print(as.data.frame(taula_icc), row.names = FALSE)

# rwg(j): consens dins de cada escola per a les escales principals
sigma_eu <- (7^2 - 1) / 12    # variància nul·la uniforme (7 opcions) = 4
rwg_one <- function(mat) {
  mat <- as.matrix(mat)
  sbar <- mean(apply(mat, 2, var, na.rm = TRUE), na.rm = TRUE)
  J <- ncol(mat); num <- J * (1 - sbar/sigma_eu)
  max(num / (num + sbar/sigma_eu), 0)
}
escales_rwg <- list(Funcionament = items_bloc1,
                    Energia = c("en18","en19","en20"),
                    Proposit = c("prop28","prop29","prop31"))
rwg_res <- map_dfr(names(escales_rwg), function(nm) {
  its <- escales_rwg[[nm]]
  sp  <- split(as.data.frame(dd_esc)[, its, drop = FALSE], dd_esc$escola_key)
  sp  <- sp[sapply(sp, nrow) >= 2]
  vals <- sapply(sp, rwg_one)
  tibble(escala = nm, escoles = length(vals),
         rwg_mediana = round(median(vals, na.rm = TRUE), 2),
         pct_acord_alt = round(100 * mean(vals >= 0.70, na.rm = TRUE), 0))
})
cat("\n--- Consens intra-escola rwg(j) (>=0,70 = acord acceptable) ---\n")
print(as.data.frame(rwg_res), row.names = FALSE)

write_xlsx(list("ICC_escola" = taula_icc, "rwg_consens" = rwg_res),
           "sortides/resultats_acord_escola.xlsx")

# ===========================================================================
#  PART N · ANÀLISI A NIVELL D'ESCOLA (unitat = escola)
#  Agrega els constructes a la MITJANA de cada escola i prova els segmentadors
#  D'ESCOLA (xarxa, complexitat, territori). Complementa l'anàlisi individual;
#  té sentit sobretot per als constructes amb component d'escola (energia,
#  recuperació, funcionament). Exploratori (n d'escoles baixa).
# ===========================================================================
# nombre de factors d'estrès marcats per persona (per agregar-lo a escola)
dades <- dades %>% mutate(n_estres = rowSums(across(all_of(vars_estres)), na.rm = TRUE))

escola_nivell <- dades %>% filter(!den_buit(Escola)) %>%
  group_by(escola_key) %>%
  summarise(n_resp = n(),
            across(all_of(constr_esc), ~ mean(.x, na.rm = TRUE)),
            across(all_of(vars_estres), ~ mean(.x, na.rm = TRUE)),  # proporció per factor
            n_estres_esc = mean(n_estres, na.rm = TRUE),            # càrrega mitjana d'estrès
            Xarxa_esc = if (any(!den_buit(Denominacio))) "Sí" else "No",
            particip_FECC_esc = if (any(particip_FECC == "Sí", na.rm = TRUE)) "Sí" else "No",
            Complexitat_m = mean(suppressWarnings(as.numeric(Complexitat)), na.rm = TRUE),
            ServeiTerr_esc = { t <- table(ServeiTerr_grup)
                               if (length(t)) names(t)[which.max(t)] else NA_character_ },
            .groups = "drop") %>%
  mutate(Xarxa_esc = factor(Xarxa_esc, levels = c("No","Sí")),
         particip_FECC_esc = factor(particip_FECC_esc, levels = c("No","Sí")),
         Complexitat_grup_esc = cut(Complexitat_m, c(-Inf,.30,.50,.60,Inf),
                                    labels = c("0-0,30","0,31-0,50","0,51-0,60","0,61-1")))
cat(sprintf("\n===== ANÀLISI A NIVELL D'ESCOLA (%d escoles) =====\n", nrow(escola_nivell)))
cat("En xarxa:", sum(escola_nivell$Xarxa_esc=="Sí"), "| independents:",
    sum(escola_nivell$Xarxa_esc=="No"), "\n")

mw_esc <- function(df, seg, constructes) {
  r <- map_dfr(constructes, function(cc) {
    d <- df %>% transmute(g = droplevels(factor(.data[[seg]])), y = .data[[cc]]) %>% drop_na()
    if (nlevels(d$g) != 2 || any(table(d$g) < 3)) return(NULL)
    wt <- suppressWarnings(wilcox.test(y ~ g, data = d))
    e  <- tryCatch(rstatix::wilcox_effsize(d, y ~ g)$effsize, error = function(e) NA_real_)
    m  <- tapply(d$y, d$g, median)
    tibble(segmentador = seg, construct = cc, n_escoles = nrow(d),
           md_No = round(m["No"],2), md_Si = round(m["Sí"],2),
           p = round(wt$p.value,4), r_efecte = round(e,3))
  })
  if (nrow(r)) r %>% mutate(p_adj = round(p.adjust(p,"holm"),4)) else r
}
kw_esc <- function(df, seg, constructes, min_cell = 3) {
  r <- map_dfr(constructes, function(cc) {
    d <- df %>% transmute(g = droplevels(factor(.data[[seg]])), y = .data[[cc]]) %>% drop_na() %>%
      group_by(g) %>% filter(n() >= min_cell) %>% ungroup() %>% mutate(g = droplevels(g))
    if (nlevels(d$g) < 2) return(NULL)
    kt <- kruskal.test(y ~ g, data = d)
    e  <- tryCatch(rstatix::kruskal_effsize(d, y ~ g)$effsize, error = function(e) NA_real_)
    tibble(segmentador = seg, construct = cc, k = nlevels(d$g), n_escoles = nrow(d),
           H = round(unname(kt$statistic),2), p = round(kt$p.value,4), epsilon2 = round(e,3))
  })
  if (nrow(r)) r %>% mutate(p_adj = round(p.adjust(p,"holm"),4)) else r
}
tests_escola_xarxa   <- mw_esc(escola_nivell, "Xarxa_esc", constr_esc)
tests_escola_complex <- kw_esc(escola_nivell, "Complexitat_grup_esc", constr_esc)
tests_escola_territ  <- kw_esc(escola_nivell, "ServeiTerr_esc", constr_esc)
cat("\n--- Xarxa (escola): Mann-Whitney ---\n");   print(as.data.frame(tests_escola_xarxa), row.names = FALSE)
cat("\n--- Complexitat (escola): Kruskal-Wallis ---\n"); print(as.data.frame(tests_escola_complex), row.names = FALSE)
cat("\n--- Servei Territorial (escola): Kruskal-Wallis ---\n"); print(as.data.frame(tests_escola_territ), row.names = FALSE)

# --- Participació en projectes estratègics FECC (a nivell d'escola) ---------
# Escola "participa" si ALGUN dels seus enquestats participa en algun projecte.
tests_escola_fecc <- mw_esc(escola_nivell, "particip_FECC_esc",
                            c(constr_esc, "n_estres_esc"))
cat(sprintf("\n--- Participació FECC (escola): %d participen / %d no ---\n",
            sum(escola_nivell$particip_FECC_esc=="Sí"), sum(escola_nivell$particip_FECC_esc=="No")))
print(as.data.frame(tests_escola_fecc), row.names = FALSE)

# --- Factors d'estrès agregats a nivell d'escola ---------------------------
prev_estres_esc <- escola_nivell %>%
  summarise(across(all_of(vars_estres), ~ round(mean(.x, na.rm = TRUE), 2))) %>%
  pivot_longer(everything(), names_to = "factor", values_to = "prop_mitjana_escola") %>%
  arrange(desc(prop_mitjana_escola))
cat("\n--- Factors d'estrès: proporció mitjana per escola (top) ---\n")
print(as.data.frame(head(prev_estres_esc, 8)), row.names = FALSE)

# quins factors d'estrès concrets difereixen segons participació FECC (escola)
tests_estres_fecc <- mw_esc(escola_nivell, "particip_FECC_esc", vars_estres)
cat("\n--- Factors d'estrès per participació FECC (escola): Mann-Whitney ---\n")
print(as.data.frame(tests_estres_fecc %>% arrange(p)), row.names = FALSE)

# càrrega d'estrès de l'escola per xarxa i correlació amb energia
tests_estres_xarxa <- mw_esc(escola_nivell, "Xarxa_esc", "n_estres_esc")
cat("\n--- Càrrega d'estrès (escola) per xarxa ---\n"); print(as.data.frame(tests_estres_xarxa), row.names = FALSE)
ce <- suppressWarnings(cor.test(escola_nivell$n_estres_esc, escola_nivell$idx_energia, method = "spearman"))
cat(sprintf("Correlació (escola) càrrega d'estrès <-> energia: rho=%.2f p=%.3f\n",
            unname(ce$estimate), ce$p.value))

write_xlsx(list("Escoles_mitjanes" = escola_nivell,
                "Xarxa_escola"     = tests_escola_xarxa,
                "Complexitat_escola" = tests_escola_complex,
                "Territori_escola" = tests_escola_territ,
                "ParticipacioFECC_escola" = tests_escola_fecc,
                "Estres_prevalenca_escola" = prev_estres_esc,
                "Estres_x_ParticipFECC" = tests_estres_fecc,
                "Estres_carrega_xarxa" = tests_estres_xarxa),
           "sortides/resultats_nivell_escola.xlsx")

# ===========================================================================
#  PART O · REGRESSIÓ MÚLTIPLE (prova analítica directa de P3)
#  DV: energia i recuperació. Predictors: dimensions de coherència + alineament
#  de propòsit. Coeficients ESTANDARDITZATS (pes comparable). Es comproven els
#  supòsits (normalitat, homoscedasticitat, independència dels residus) i es
#  reporten ERRORS ROBUSTOS (HC3) com a alternativa si hi ha heteroscedasticitat.
# ===========================================================================
z <- function(x) as.numeric(scale(x))
dreg <- dades %>% transmute(
  energia      = z(idx_energia),      recuperacio  = z(idx_recuperacio),
  funcionament = z(idx_funcionament_xarxa), proposit = z(idx_alineament_proposit),
  EF1 = z(idx_EF1), EF2 = z(idx_EF2), EF3 = z(idx_EF3))

# --- errors robustos HC3 i diagnòstic de supòsits (base R, sense paquets extra)
robust_se <- function(m) {
  X <- model.matrix(m); u <- resid(m); h <- hatvalues(m)
  bread <- solve(crossprod(X)); meat <- crossprod(X * (u/(1 - h)))
  sqrt(diag(bread %*% meat %*% bread))
}
coef_taula <- function(m) {
  s <- summary(m)$coefficients; rse <- robust_se(m)
  data.frame(terme = rownames(s), beta = round(s[,1],3), se = round(s[,2],3),
             p = round(s[,4],4), se_HC3 = round(rse,3),
             p_HC3 = round(2*pt(abs(s[,1]/rse), m$df.residual, lower.tail=FALSE),4),
             row.names = NULL)
}
diagnostic <- function(m, nom) {
  r <- resid(m); f <- fitted(m)
  bp <- summary(lm(I(r^2) ~ f)); bp_p <- pf(bp$fstatistic[1], bp$fstatistic[2],
                                            bp$fstatistic[3], lower.tail = FALSE)
  tibble(model = nom, n = length(r),
         R2 = round(summary(m)$r.squared,3), R2_adj = round(summary(m)$adj.r.squared,3),
         shapiro_p = round(shapiro.test(r)$p.value,3),          # normalitat residus
         BreuschPagan_p = round(unname(bp_p),3),                # homoscedasticitat
         DurbinWatson = round(sum(diff(r)^2)/sum(r^2),2))       # independència (~2 = ok)
}

# --- Models principals: ENERGIA i RECUPERACIÓ ------------------------------
m_en_emp  <- lm(energia ~ EF1 + EF2 + EF3 + proposit, data = dreg)   # empíric
m_en_teo  <- lm(energia ~ funcionament + proposit, data = dreg)      # teòric
m_rec_emp <- lm(recuperacio ~ EF1 + EF2 + EF3 + proposit, data = dreg)
m_rec_teo <- lm(recuperacio ~ funcionament + proposit, data = dreg)

models <- list("Energia ~ coherència(emp)+propòsit" = m_en_emp,
               "Energia ~ funcionament(teo)+propòsit" = m_en_teo,
               "Recuperació ~ coherència(emp)+propòsit" = m_rec_emp,
               "Recuperació ~ funcionament(teo)+propòsit" = m_rec_teo)
diag_models <- map_dfr(names(models), ~ diagnostic(models[[.x]], .x))
cat("\n===== REGRESSIÓ · supòsits i ajust dels models =====\n")
print(as.data.frame(diag_models), row.names = FALSE)
for (nm in names(models)) {
  cat("\n--- ", nm, " ---\n", sep=""); print(coef_taula(models[[nm]]))
}

# --- Direccionalitat coherència <-> propòsit -------------------------------
m_coh_de_prop <- lm(funcionament ~ proposit, data = dreg)
m_prop_de_coh <- lm(proposit ~ funcionament, data = dreg)
cat(sprintf("\n===== Direccionalitat (regressió simple, R2 idèntic per simetria) =====\n"))
cat(sprintf("Funcionament ~ Propòsit : R2=%.3f | Propòsit ~ Funcionament : R2=%.3f\n",
            summary(m_coh_de_prop)$r.squared, summary(m_prop_de_coh)$r.squared))
cat("NOTA: amb regressió simple el R2 és el mateix en tots dos sentits (= r^2);\n",
    "la 'direcció' NO es pot decidir així. Caldria un model de mediació/SEM.\n")

# --- Relacions ENTRE factors del Bloc 1 ------------------------------------
m_ef1 <- lm(EF1 ~ EF2 + EF3, data = dreg)
m_ef2 <- lm(EF2 ~ EF1 + EF3, data = dreg)
m_ef3 <- lm(EF3 ~ EF1 + EF2, data = dreg)
cat("\n===== Relacions entre factors del Bloc 1 (betes estandarditzades) =====\n")
for (nm in c("EF1~EF2+EF3","EF2~EF1+EF3","EF3~EF1+EF2")) {
  m <- list(get("m_ef1"), get("m_ef2"), get("m_ef3"))[[match(nm, c("EF1~EF2+EF3","EF2~EF1+EF3","EF3~EF1+EF2"))]]
  cat("\n--- ", nm, " (R2=", round(summary(m)$r.squared,3), ") ---\n", sep=""); print(coef_taula(m))
}

# --- Gràfics de residus dels models principals -----------------------------
for (nm in c("m_en_emp","m_rec_emp")) {
  png(paste0("sortides/regressio_residus_", nm, ".png"), width = 900, height = 700, res = 110)
  par(mfrow = c(2,2)); plot(get(nm)); dev.off()
}

write_xlsx(c(list("Diagnostic_models" = diag_models),
             setNames(lapply(models, coef_taula), substr(paste0("Coef_", names(models)),1,31))),
           "sortides/resultats_regressio.xlsx")

# ===========================================================================
#  PART P · MEDIACIÓ (direccionalitat coherència <-> propòsit sobre l'energia)
#  Efecte indirecte a*b amb IC per bootstrap (Preacher-Hayes), en base R.
#  Es proven les DUES direccions competidores. NOTA: amb dades transversals la
#  mediació és 'consistent amb' un mecanisme, però NO en demostra la causalitat.
# ===========================================================================
mediacio <- function(df, X, M, Y, B = 2000) {
  f <- na.omit(df[, c(X, M, Y)]); names(f) <- c("X","M","Y"); n <- nrow(f)
  a  <- coef(lm(M ~ X, f))["X"]
  mY <- lm(Y ~ X + M, f); b <- coef(mY)["M"]; cp <- coef(mY)["X"]
  c_tot <- coef(lm(Y ~ X, f))["X"]; ab <- a*b
  boot <- replicate(B, { i <- sample(n, replace = TRUE); gg <- f[i,]
    coef(lm(M ~ X, gg))["X"] * coef(lm(Y ~ X + M, gg))["M"] })
  ci <- quantile(boot, c(.025, .975), na.rm = TRUE)
  tibble(X = X, M = M, Y = Y,
         efecte_total_c = round(unname(c_tot),3), directe_c_prima = round(unname(cp),3),
         indirecte_ab = round(unname(ab),3),
         ic_low = round(unname(ci[1]),3), ic_high = round(unname(ci[2]),3),
         prop_mediada = round(unname(ab/c_tot),2),
         mediacio = ifelse(ci[1]*ci[2] > 0, "SÍ (IC exclou 0)", "no"))
}
set.seed(2024)
taula_mediacio <- bind_rows(
  mediacio(dreg, "proposit", "funcionament", "energia"),   # coherència mitjança propòsit->energia
  mediacio(dreg, "funcionament", "proposit", "energia"),   # propòsit mitjança coherència->energia
  mediacio(dreg, "proposit", "EF2", "energia"),            # (coherència = equip, EF2)
  mediacio(dreg, "EF2", "proposit", "energia"))
cat("\n===== MEDIACIÓ (efecte indirecte a*b amb IC bootstrap) =====\n")
print(as.data.frame(taula_mediacio), row.names = FALSE)
cat("Interpretació: 'mediació=SÍ' vol dir que l'efecte indirecte és significatiu;\n",
    "amb dades transversals indica compatibilitat amb el mecanisme, NO causalitat.\n")
write_xlsx(list("Mediacio" = taula_mediacio), "sortides/resultats_mediacio.xlsx")

# ===========================================================================
#  PART Q · ANÀLISI DE CLÚSTERS (perfils per a interpretació i mostreig)
#  Dues versions EMPÍRIQUES:
#   A) 3 macro-constructes: funcionament, energia/recuperació, propòsit
#   B) 6 dimensions: coherència (propòsit/equip/xarxa) + energia + recuperació + propòsit
#  k-means (k triat per silueta; triangulat amb colze i gap), validat amb Ward.
#  NOTA: el gap statistic indica estructura feble -> perfils DESCRIPTIUS per a
#  mostreig intencional (contrastats, extrems, mixtos), no tipologia robusta.
# ===========================================================================
library(cluster)
dades <- dades %>% mutate(idx_energia_recup = rowMeans(cbind(idx_energia, idx_recuperacio), na.rm = TRUE))

fer_clusters <- function(cols, labels, nom, coh_vec, en_vec) {
  M  <- as.matrix(dades[, cols]); colnames(M) <- labels
  ok <- stats::complete.cases(M) & !is.na(coh_vec) & !is.na(en_vec)
  M  <- M[ok, , drop = FALSE]; Xc <- scale(M)
  ids <- dades$id_persona[ok]; seg <- dades[ok, c("Cargo_grup","NivellJerarquic","particip_FECC")]
  set.seed(2024)
  sil <- sapply(2:6, function(k) mean(cluster::silhouette(kmeans(Xc,k,nstart=25)$cluster, dist(Xc))[,3]))
  k_opt <- (2:6)[which.max(sil)]
  gap <- tryCatch(cluster::clusGap(Xc, kmeans, K.max = 6, B = 50, nstart = 25)$Tab[,"gap"],
                  error = function(e) rep(NA_real_, 6))
  set.seed(2024); km2 <- kmeans(Xc, k_opt, nstart = 50)
  km3 <- kmeans(Xc, 3, nstart = 50); km5 <- kmeans(Xc, 5, nstart = 50)
  hc <- hclust(dist(Xc), "ward.D2")
  base <- tibble(id_persona = ids) %>% bind_cols(as_tibble(M)) %>%
    mutate(cluster = factor(km2$cluster), cluster3 = factor(km3$cluster),
           cluster5 = factor(km5$cluster), cluster_hc = factor(cutree(hc, k_opt)),
           z_coh = as.numeric(scale(coh_vec[ok])), z_en = as.numeric(scale(en_vec[ok])),
           discordanca = round(z_coh - z_en, 2)) %>% bind_cols(seg)
  perfil2 <- base %>% group_by(cluster) %>%
    summarise(n = n(), across(all_of(labels), ~ round(mean(.x),2)), .groups = "drop")
  perfil3 <- base %>% group_by(cluster3) %>%
    summarise(n = n(), across(all_of(labels), ~ round(mean(.x),2)), .groups = "drop")
  perfil5 <- base %>% group_by(cluster5) %>%
    summarise(n = n(), across(all_of(labels), ~ round(mean(.x),2)), .groups = "drop") %>%
    arrange(across(all_of(labels[length(labels)])))   # ordenat pel darrer (propòsit)
  cen <- km2$centers[km2$cluster, , drop = FALSE]
  base$dist_c <- round(sqrt(rowSums((Xc - cen)^2)), 2)
  base$dist_g <- round(sqrt(rowSums(Xc^2)), 2)
  repr  <- base %>% group_by(cluster) %>% slice_min(dist_c, n = 2, with_ties = FALSE) %>% ungroup()
  extr  <- base %>% slice_max(dist_g, n = 6)
  mixt1 <- base %>% filter(z_coh > 0.5, z_en < -0.5) %>% arrange(desc(discordanca))
  mixt2 <- base %>% filter(z_coh < -0.5, z_en > 0.5) %>% arrange(discordanca)
  cat(sprintf("\n===== CLÚSTERS versió %s (n=%d) =====\n", nom, nrow(base)))
  cat("Silueta k2..6:", paste(round(sil,3), collapse=" "), "| k triat:", k_opt,
      "| gap(k1)=", round(gap[1],2), "\n")
  cat("Perfil k=", k_opt, ":\n", sep=""); print(as.data.frame(perfil2), row.names = FALSE)
  cat("Perfil k=3:\n"); print(as.data.frame(perfil3), row.names = FALSE)
  cat("Perfil k=5:\n"); print(as.data.frame(perfil5), row.names = FALSE)
  cat(sprintf("Casos mixtos: alta coh+baixa energia=%d | baixa coh+alta energia=%d\n",
              nrow(mixt1), nrow(mixt2)))
  # --- Gràfics: dispersió (mapa PCA) i dendrograma (jeràrquic) --------------
  graf_perfil <- function(perf, clcol, titol) {
    perf %>% tidyr::pivot_longer(all_of(labels), names_to = "constructe", values_to = "m") %>%
      mutate(constructe = factor(constructe, levels = labels), grp = factor(.data[[clcol]])) %>%
      ggplot2::ggplot(ggplot2::aes(constructe, m, group = grp, color = grp)) +
      ggplot2::geom_line(linewidth = 1) + ggplot2::geom_point(size = 2) +
      ggplot2::coord_cartesian(ylim = c(1, 7)) +
      ggplot2::labs(title = titol, x = NULL, y = "Mitjana (1-7)", color = "Clúster") +
      ggplot2::theme_minimal() +
      ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 25, hjust = 1))
  }
  tryCatch({
    for (kk in c(3, 5)) {
      cl <- if (kk == 3) km3$cluster else km5$cluster
      ggsave(paste0("sortides/clusters_", nom, "_mapa_k", kk, ".png"),
             factoextra::fviz_cluster(list(data = Xc, cluster = cl),
               geom = "point", ellipse.type = "convex", palette = "Set2") +
               ggplot2::labs(title = paste0("Distribució per clúster (k=", kk, ") · versió ", nom)),
             width = 8, height = 6, dpi = 120)
      ggsave(paste0("sortides/clusters_", nom, "_dendrograma_k", kk, ".png"),
             factoextra::fviz_dend(hc, k = kk, cex = 0.4, show_labels = FALSE, palette = "Set2") +
               ggplot2::labs(title = paste0("Dendrograma jeràrquic (Ward, k=", kk, ") · versió ", nom)),
             width = 9, height = 6, dpi = 120)
    }
    # gràfic de PERFILS (línies de mitjanes per clúster) — més interpretable
    ggsave(paste0("sortides/clusters_", nom, "_perfils_k3.png"),
           graf_perfil(perfil3, "cluster3", paste0("Perfils de clúster (k=3) · versió ", nom)),
           width = 8, height = 5, dpi = 120)
    ggsave(paste0("sortides/clusters_", nom, "_perfils_k5.png"),
           graf_perfil(perfil5, "cluster5", paste0("Perfils de clúster (k=5) · versió ", nom)),
           width = 8.5, height = 5, dpi = 120)
    # gràfic 3D (3 constructes si n'hi ha 3; si no, 3 primeres components) per k=3 i k=5
    if (ncol(M) == 3) { P3 <- as.matrix(M); axl <- labels } else {
      pc <- prcomp(Xc); P3 <- pc$x[, 1:3]; axl <- paste0("Dim", 1:3) }
    for (kk in c(3, 5)) {
      cl <- if (kk == 3) base$cluster3 else base$cluster5
      png(paste0("sortides/clusters_", nom, "_3D_k", kk, ".png"), width = 850, height = 750, res = 110)
      scatterplot3d::scatterplot3d(P3, color = as.integer(cl), pch = 19,
        xlab = axl[1], ylab = axl[2], zlab = axl[3],
        main = paste0("Gràfic 3D · versió ", nom, " (color = clúster k=", kk, ")"))
      dev.off()
    }
  }, error = function(e) cat("(gràfics de clúster omesos:", conditionMessage(e), ")\n"))
  write_xlsx(list(Perfil_k2 = perfil2, Perfil_k3 = perfil3, Perfil_k5 = perfil5,
                  Representatius = repr, Extrems = extr, Mixt_coh_sense_energia = mixt1,
                  Mixt_energia_sense_coh = mixt2, Assignacio = base),
             paste0("sortides/resultats_clusters_", nom, ".xlsx"))
  invisible(base)
}

clA <- fer_clusters(
  cols   = c("idx_funcionament_xarxa","idx_energia_recup","idx_alineament_proposit"),
  labels = c("Funcionament","EnergiaRecup","Proposit"),
  nom    = "A3", coh_vec = dades$idx_funcionament_xarxa, en_vec = dades$idx_energia_recup)

# Versió B · 5 dimensions: energia i recuperació FUSIONADES (l'AFE mostra que no
# es diferencien empíricament -> separar-les no seria justificable).
clB <- fer_clusters(
  cols   = c("idx_EF3","idx_EF2","idx_EF1","idx_energia_recup","idx_alineament_proposit"),
  labels = c("CoherProposit","CoherEquip","CoherXarxa","EnergiaRecup","Proposit"),
  nom    = "B5", coh_vec = rowMeans(dades[, c("idx_EF1","idx_EF2","idx_EF3")], na.rm = TRUE),
  en_vec = dades$idx_energia_recup)

# ===========================================================================
#  PART R · FREQÜÈNCIES i CO-OCURRÈNCIES dels factors d'estrès (ítem 22)  [P2]
#  Identifica els constrenyiments més prevalents i les seves combinacions més
#  freqüents (parelles), amb la força d'associació (Jaccard i lift).
# ===========================================================================
etiq_estres <- c(dr_Carrega="Excés de càrrega", dr_Temps="Falta de temps",
  dr_Interrupcions="Interrupcions", dr_Claredat="Falta de claredat",
  dr_Conflictes="Conflictes", dr_Suport="Manca de suport", dr_Reunions="Reunions poc útils",
  dr_SenseSentit="Sense sentit", dr_NoAlineat="Tasques no alineades",
  dr_Canvis="Canvis/inestabilitat", dr_Incertesa="Incertesa", dr_Cansament="Cansament físic",
  dr_Personal="Situacions personals", dr_Altres="Altres")

E <- as.matrix(dades[, vars_estres]); E[is.na(E)] <- 0
colnames(E) <- etiq_estres[colnames(E)]
n_tot <- nrow(E)

# Freqüència (prevalença) de cada factor
freq_factors <- tibble(factor = colnames(E), n = colSums(E)) %>%
  mutate(pct = round(100 * n / n_tot, 1)) %>% arrange(desc(n))
cat("\n===== FREQÜÈNCIA dels factors d'estrès (ítem 22) =====\n")
print(as.data.frame(freq_factors), row.names = FALSE)
cat(sprintf("Nombre mitjà de factors per persona: %.1f\n", mean(rowSums(E))))

# Matriu de co-ocurrència (quants marquen cada parella)
co <- crossprod(E)                     # diagonal = individuals; fora = parelles
diag_co <- diag(co)
# parelles úniques amb Jaccard i lift
pares <- expand.grid(a = colnames(E), b = colnames(E), stringsAsFactors = FALSE) %>%
  filter(a < b) %>%
  mutate(ambdos = co[cbind(a, b)],
         nomes_a = diag_co[a], nomes_b = diag_co[b],
         pct_mostra = round(100 * ambdos / n_tot, 1),
         jaccard = round(ambdos / (nomes_a + nomes_b - ambdos), 2),
         esperat = nomes_a * nomes_b / n_tot,
         lift = round(ambdos / esperat, 2)) %>%
  arrange(desc(ambdos))
cat("\n===== CO-OCURRÈNCIES més FREQÜENTS (top parelles) =====\n")
print(as.data.frame(head(pares %>% select(a,b,ambdos,pct_mostra,jaccard,lift), 12)), row.names = FALSE)
cat("\n===== ASSOCIACIONS més FORTES (lift, parelles amb >=8 casos) =====\n")
print(as.data.frame(pares %>% filter(ambdos >= 8) %>% arrange(desc(lift)) %>%
        select(a,b,ambdos,jaccard,lift) %>% head(10)), row.names = FALSE)

# Heatmap de co-ocurrència (% de la mostra que marca les dues)
co_pct <- round(100 * co / n_tot, 0); co_long <- as.data.frame(as.table(co_pct))
names(co_long) <- c("f1","f2","pct")
g_co <- ggplot(co_long, aes(f1, f2, fill = pct)) + geom_tile() +
  geom_text(aes(label = pct), size = 2.6) +
  scale_fill_gradient(low = "white", high = "#c0392b") +
  labs(title = "Co-ocurrència de factors d'estrès (% de la mostra)", x = NULL, y = NULL, fill = "%") +
  theme_minimal() + theme(axis.text.x = element_text(angle = 40, hjust = 1))
ggsave("sortides/estres_coocurrencia_heatmap.png", g_co, width = 9, height = 7, dpi = 120)

write_xlsx(list("Frequencia_factors" = freq_factors,
                "Coocurrencies_parelles" = pares,
                "Matriu_coocurrencia" = as.data.frame(co) %>% rownames_to_column("factor")),
           "sortides/resultats_coocurrencia_estres.xlsx")

cat("\nFet! Revisa la carpeta 'sortides/':\n",
    " - resultats_analisi.xlsx (descriptius i fiabilitat teòrica)\n",
    " - resultats_segmentadors.xlsx (tests, mitjanes, post-hoc)\n",
    " - resultats_correlacio_P3.xlsx (3 dimensions principals: coherència<->energia)\n",
    " - resultats_regressio.xlsx (regressió múltiple + supòsits + errors robustos)\n",
    " - resultats_mediacio.xlsx (mediació coherència/propòsit -> energia)\n",
    " - resultats_coocurrencia_estres.xlsx (freqüències i co-ocurrències ítem 22)\n",
    " - resultats_clusters_A3.xlsx i _B5.xlsx (perfils + casos per a entrevistes)\n",
    " - resultats_acord_escola.xlsx (ICC i consens intra-escola)\n",
    " - resultats_nivell_escola.xlsx (constructes agregats per escola + segmentadors)\n",
    " - resultats_control.xlsx (ítems 23-24-25 vs constructes TEÒRICS)\n",
    " - resultats_control_empiric.xlsx (ítems 23-24-25 vs constructes EMPÍRICS)\n",
    " - resultats_afe.xlsx (AFE del Bloc 1)\n",
    " - resultats_afe_bloc23.xlsx (AFE conjunta Bloc 2 + Bloc 3)\n",
    " - resultats_empiriques.xlsx (dimensions empíriques: fiab. + segm. + control)\n",
    " - resultats_rols_multiples.xlsx (rols múltiples Cargo+Subcargo)\n",
    " - resultats_hipotesi_FECC.xlsx (hipòtesi projectes FECC, inclòs GdE)\n",
    " - resultats_subgrups_noparam.xlsx (Mann-Whitney/Kruskal-Wallis: rol, nivell, territori)\n",
    " - resultats_comparacions_extra.xlsx (etapes, àmbits i correlacions entre constructes)\n",
    " - gràfics .png (inclòs afe_scree.png)\n")

source(here::here("R", "00_dependencies.R"))

mi_dat <- readRDS(here::here("data", "processed", "adult_income_mi.rds")) %>%
  filter(
    !is.na(multimorbidity), !is.na(education4), !is.na(age_group), !is.na(sex),
    !is.na(race_ethnicity), !is.na(marital4), !is.na(region), !is.na(poverty4),
    IMPNUM_A %in% 1:10
  )

imp_split <- split(mi_dat, mi_dat$IMPNUM_A)
if (length(imp_split) != 10L) stop("Expected 10 NHIS income imputations.")

imp_obj <- mitools::imputationList(imp_split)
mi_design <- survey::svydesign(
  ids = ~PPSU,
  strata = ~PSTRAT,
  weights = ~WTFA_A,
  nest = TRUE,
  data = imp_obj
)

fits_income <- with(
  mi_design,
  survey::svyglm(
    multimorbidity ~ education4 + poverty4 + age_group + sex + race_ethnicity + marital4 + region,
    family = quasibinomial()
  )
)
pooled_income <- mitools::MIcombine(fits_income)

b <- pooled_income$coefficients
v <- pooled_income$variance
se <- sqrt(diag(v))
pooled_tbl <- tibble::tibble(
  term = names(b),
  estimate_log = as.numeric(b),
  std_error = as.numeric(se),
  odds_ratio = exp(estimate_log),
  conf_low = exp(estimate_log - 1.96 * std_error),
  conf_high = exp(estimate_log + 1.96 * std_error),
  z = estimate_log / std_error,
  p_value = 2 * pnorm(abs(z), lower.tail = FALSE)
)
readr::write_csv(pooled_tbl, here::here("outputs", "tables", "income_multiple_imputation_model.csv"))
capture.output(summary(pooled_income), file = here::here("outputs", "logs", "income_mi_model_summary.txt"))
saveRDS(pooled_income, here::here("data", "processed", "income_mi_model.rds"))
message("Multiply-imputed poverty model complete.")

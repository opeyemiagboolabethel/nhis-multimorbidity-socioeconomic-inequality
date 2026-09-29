source(here::here("R", "00_dependencies.R"))

dat <- readRDS(here::here("data", "processed", "adult_analysis.rds"))
des <- survey::svydesign(ids = ~PPSU, strata = ~PSTRAT, weights = ~WTFA_A, nest = TRUE, data = dat)

complete_model <- subset(
  des,
  !is.na(multimorbidity) & !is.na(education4) & !is.na(age_group) & !is.na(sex) &
    !is.na(race_ethnicity) & !is.na(marital4) & !is.na(region)
)

m1 <- survey::svyglm(
  multimorbidity ~ education4 + age_group + sex + race_ethnicity,
  design = complete_model,
  family = quasibinomial()
)

m2 <- survey::svyglm(
  multimorbidity ~ education4 + age_group + sex + race_ethnicity + marital4 + region,
  design = complete_model,
  family = quasibinomial()
)

m3 <- survey::svyglm(
  multimorbidity ~ education4 * age_group + sex + race_ethnicity + marital4 + region,
  design = complete_model,
  family = quasibinomial()
)

m_count <- survey::svyglm(
  mm_count ~ education4 * age_group + sex + race_ethnicity + marital4 + region,
  design = complete_model,
  family = quasipoisson(link = "log")
)

# Sensitivity: physical-only multimorbidity.
physical_model <- subset(
  des,
  !is.na(physical_multimorbidity) & !is.na(education4) & !is.na(age_group) & !is.na(sex) &
    !is.na(race_ethnicity) & !is.na(marital4) & !is.na(region)
)
m_physical <- survey::svyglm(
  physical_multimorbidity ~ education4 * age_group + sex + race_ethnicity + marital4 + region,
  design = physical_model,
  family = quasibinomial()
)

extract_model <- function(fit, model_name, exponentiate = TRUE) {
  b <- coef(fit)
  se <- sqrt(diag(vcov(fit)))
  out <- tibble::tibble(
    model = model_name,
    term = names(b),
    estimate_log = as.numeric(b),
    std_error = as.numeric(se),
    p_value = 2 * pnorm(abs(b / se), lower.tail = FALSE),
    conf_low_log = b - 1.96 * se,
    conf_high_log = b + 1.96 * se
  )
  if (exponentiate) {
    out <- out %>% mutate(
      estimate = exp(estimate_log),
      conf_low = exp(conf_low_log),
      conf_high = exp(conf_high_log)
    )
  } else {
    out <- out %>% mutate(estimate = estimate_log, conf_low = conf_low_log, conf_high = conf_high_log)
  }
  out
}

model_results <- bind_rows(
  extract_model(m1, "Model 1: demographic adjustment"),
  extract_model(m2, "Model 2: full main effects"),
  extract_model(m3, "Model 3: education x age interaction"),
  extract_model(m_count, "Count model: education x age", TRUE),
  extract_model(m_physical, "Sensitivity: physical multimorbidity")
)
readr::write_csv(model_results, here::here("outputs", "tables", "regression_models.csv"))

# Wald test for the education-by-age interaction as a block.
interaction_test <- tryCatch(
  survey::regTermTest(m3, ~education4:age_group),
  error = function(e) NULL
)
if (!is.null(interaction_test)) {
  capture.output(interaction_test, file = here::here("outputs", "logs", "interaction_wald_test.txt"))
}

saveRDS(list(m1 = m1, m2 = m2, m3 = m3, count = m_count, physical = m_physical),
        here::here("data", "processed", "main_models.rds"))
message("Primary survey-weighted models complete.")

source(here::here("R", "00_dependencies.R"))

dat <- readRDS(here::here("data", "processed", "adult_analysis.rds"))

des <- survey::svydesign(
  ids = ~PPSU,
  strata = ~PSTRAT,
  weights = ~WTFA_A,
  nest = TRUE,
  data = dat
)


# Overall estimates
overall_mm <- survey::svymean(~multimorbidity, des, na.rm = TRUE)
overall_count <- survey::svymean(~mm_count, des, na.rm = TRUE)

overall_tbl <- tibble::tibble(
  metric = c("Multimorbidity prevalence", "Mean chronic-condition count"),
  estimate = c(as.numeric(coef(overall_mm)), as.numeric(coef(overall_count))),
  se = c(as.numeric(SE(overall_mm)), as.numeric(SE(overall_count)))
) %>%
  mutate(ci_low = estimate - 1.96 * se, ci_high = estimate + 1.96 * se)
readr::write_csv(overall_tbl, here::here("outputs", "tables", "overall_estimates.csv"))

# Weighted prevalence by age and education.
age_edu <- survey::svyby(
  ~multimorbidity,
  ~age_group + education4,
  des,
  survey::svymean,
  na.rm = TRUE,
  vartype = c("se", "ci"),
  keep.names = FALSE
) %>% as.data.frame() %>% tibble::as_tibble()

readr::write_csv(age_edu, here::here("outputs", "tables", "multimorbidity_by_age_education.csv"))

# Weighted prevalence by race/ethnicity and age.
age_race <- survey::svyby(
  ~multimorbidity,
  ~age_group + race_ethnicity,
  des,
  survey::svymean,
  na.rm = TRUE,
  vartype = c("se", "ci"),
  keep.names = FALSE
) %>% as.data.frame() %>% tibble::as_tibble()
readr::write_csv(age_race, here::here("outputs", "tables", "multimorbidity_by_age_race.csv"))

# Condition-specific weighted prevalence by age group.
condition_vars <- c(
  "hypertension", "heart_disease", "stroke", "current_asthma", "cancer", "diabetes",
  "copd", "arthritis", "kidney_disease", "liver_disease", "depression", "anxiety"
)
condition_by_age <- purrr::map_dfr(condition_vars, function(v) {
  f <- as.formula(paste0("~", v))
  out <- survey::svyby(f, ~age_group, des, survey::svymean, na.rm = TRUE, vartype = "ci", keep.names = FALSE) %>%
    as.data.frame() %>% tibble::as_tibble()
  names(out)[names(out) == v] <- "prevalence"
  out %>% mutate(condition = v)
})
readr::write_csv(condition_by_age, here::here("outputs", "tables", "condition_prevalence_by_age.csv"))

# Compact weighted sample profile.
weighted_cat <- function(var) {
  survey::svyby(~multimorbidity, as.formula(paste0("~", var)), des, survey::svymean, na.rm = TRUE, vartype = "se", keep.names = FALSE) %>%
    as.data.frame() %>% tibble::as_tibble() %>% mutate(variable = var)
}
profile <- dplyr::bind_rows(
  weighted_cat("age_group"),
  weighted_cat("education4"),
  weighted_cat("sex"),
  weighted_cat("race_ethnicity")
)
readr::write_csv(profile, here::here("outputs", "tables", "weighted_profile.csv"))

saveRDS(des, here::here("data", "processed", "survey_design.rds"))
message("Descriptive survey analysis complete.")

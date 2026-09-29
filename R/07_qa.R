source(here::here("R", "00_dependencies.R"))

adult_raw <- readr::read_csv(here::here("data", "raw", "adult24.csv"), show_col_types = FALSE, progress = FALSE)
income_raw <- readr::read_csv(here::here("data", "raw", "adultinc24.csv"), show_col_types = FALSE, progress = FALSE)
dat <- readRDS(here::here("data", "processed", "adult_analysis.rds"))
mi_dat <- readRDS(here::here("data", "processed", "adult_income_mi.rds"))

income_counts <- mi_dat %>% count(HHX, name = "n_imputations")
condition_vars <- c("hypertension", "heart_disease", "stroke", "current_asthma", "cancer", "diabetes", "copd", "arthritis", "kidney_disease", "liver_disease", "depression", "anxiety")

qa <- tibble::tribble(
  ~check, ~value, ~expected, ~status,
  "Adult raw records", nrow(adult_raw), 32629, ifelse(nrow(adult_raw) == 32629, "PASS", "CHECK"),
  "Adult income raw records", nrow(income_raw), 326290, ifelse(nrow(income_raw) == 326290, "PASS", "CHECK"),
  "Unique adult HHX", dplyr::n_distinct(dat$HHX), 32629, ifelse(dplyr::n_distinct(dat$HHX) == 32629, "PASS", "CHECK"),
  "Income imputations per adult: minimum", min(income_counts$n_imputations), 10, ifelse(min(income_counts$n_imputations) == 10, "PASS", "CHECK"),
  "Income imputations per adult: maximum", max(income_counts$n_imputations), 10, ifelse(max(income_counts$n_imputations) == 10, "PASS", "CHECK"),
  "Negative survey weights", sum(dat$WTFA_A < 0, na.rm = TRUE), 0, ifelse(sum(dat$WTFA_A < 0, na.rm = TRUE) == 0, "PASS", "CHECK")
)
readr::write_csv(qa, here::here("outputs", "tables", "qa_checks.csv"))

missingness <- tibble::tibble(
  variable = c("multimorbidity", "education4", "age_group", "sex", "race_ethnicity", "marital4", condition_vars),
  missing_n = vapply(c("multimorbidity", "education4", "age_group", "sex", "race_ethnicity", "marital4", condition_vars), function(v) sum(is.na(dat[[v]])), numeric(1)),
  missing_pct = missing_n / nrow(dat)
)
readr::write_csv(missingness, here::here("outputs", "tables", "missingness.csv"))

weighted_population <- sum(dat$WTFA_A, na.rm = TRUE)
writeLines(
  c(
    paste0("Weighted adult population represented: ", format(round(weighted_population), big.mark = ",")),
    paste0("Complete multimorbidity outcome records: ", sum(!is.na(dat$multimorbidity)), " / ", nrow(dat)),
    paste0("QA completed: ", Sys.time())
  ),
  here::here("outputs", "logs", "qa_summary.txt")
)
message("QA complete.")

source(here::here("R", "00_dependencies.R"))

adult_path <- here::here("data", "raw", "adult24.csv")
income_path <- here::here("data", "raw", "adultinc24.csv")

if (!file.exists(adult_path) || !file.exists(income_path)) {
  stop("Raw NHIS files are missing. Run R/01_download_data.R first.")
}

required_adult <- c(
  "HHX", "WTFA_A", "PPSU", "PSTRAT", "REGION", "AGEP_A", "SEX_A",
  "HISPALLP_A", "EDUCP_A", "MARSTAT_A", "EMPWRKLSW1_A",
  "HYPEV_A", "CHDEV_A", "ANGEV_A", "MIEV_A", "STREV_A", "ASEV_A", "ASTILL_A",
  "CANEV_A", "DIBEV_A", "COPDEV_A", "ARTHEV_A", "KIDWEAKEV_A", "LIVEREV_A",
  "DEPEV_A", "ANXEV_A"
)
required_income <- c("HHX", "IMPNUM_A", "POVRATTC_A", "RATCAT_A")

# Read only the variables used in the analysis and keep them as character initially.
# This avoids parser warnings from unrelated columns in the full public-use files.
adult <- readr::read_csv(
  adult_path,
  col_select = dplyr::all_of(required_adult),
  col_types = readr::cols(.default = readr::col_character()),
  progress = FALSE
)
income <- readr::read_csv(
  income_path,
  col_select = dplyr::all_of(required_income),
  col_types = readr::cols(.default = readr::col_character()),
  progress = FALSE
)

names(adult) <- toupper(names(adult))
names(income) <- toupper(names(income))

missing_vars <- setdiff(required_adult, names(adult))
if (length(missing_vars) > 0) stop("Missing expected adult variables: ", paste(missing_vars, collapse = ", "))

recode_yes_no <- function(x) {
  x <- suppressWarnings(as.integer(x))
  dplyr::case_when(
    x == 1 ~ 1L,
    x == 2 ~ 0L,
    TRUE ~ NA_integer_
  )
}

combine_any_condition <- function(...) {
  m <- cbind(...)
  apply(m, 1, function(z) {
    if (any(z == 1, na.rm = TRUE)) return(1L)
    if (all(!is.na(z)) && all(z == 0)) return(0L)
    NA_integer_
  })
}

adult_analysis <- adult %>%
  transmute(
    HHX = as.character(HHX),
    WTFA_A = suppressWarnings(as.numeric(WTFA_A)),
    PPSU = suppressWarnings(as.numeric(PPSU)),
    PSTRAT = suppressWarnings(as.numeric(PSTRAT)),
    region_code = suppressWarnings(as.integer(REGION)),
    age_code = suppressWarnings(as.integer(AGEP_A)),
    sex_code = suppressWarnings(as.integer(SEX_A)),
    race_code = suppressWarnings(as.integer(HISPALLP_A)),
    education_code = suppressWarnings(as.integer(EDUCP_A)),
    marital_code = suppressWarnings(as.integer(MARSTAT_A)),
    employment_code = suppressWarnings(as.integer(EMPWRKLSW1_A)),
    region = factor(region_code, levels = 1:4, labels = c("Northeast", "Midwest", "South", "West")),
    age = if_else(age_code %in% 18:85, as.numeric(age_code), NA_real_),
    age_group = case_when(
      age_code >= 18 & age_code <= 34 ~ "18-34",
      age_code >= 35 & age_code <= 49 ~ "35-49",
      age_code >= 50 & age_code <= 64 ~ "50-64",
      age_code >= 65 & age_code <= 85 ~ "65+",
      TRUE ~ NA_character_
    ),
    sex = case_when(sex_code == 1 ~ "Male", sex_code == 2 ~ "Female", TRUE ~ NA_character_),
    race_ethnicity = case_when(
      race_code == 1 ~ "Hispanic",
      race_code == 2 ~ "Non-Hispanic White",
      race_code == 3 ~ "Non-Hispanic Black",
      race_code == 4 ~ "Non-Hispanic Asian",
      race_code %in% 5:7 ~ "Other / multiple",
      TRUE ~ NA_character_
    ),
    education4 = case_when(
      education_code %in% 0:3 ~ "Less than high school",
      education_code == 4 ~ "High school graduate",
      education_code %in% 5:7 ~ "Some college / associate",
      education_code %in% 8:10 ~ "Bachelor's or higher",
      TRUE ~ NA_character_
    ),
    marital4 = case_when(
      marital_code %in% 1:3 ~ "Married",
      marital_code %in% 4:6 ~ "Widowed / divorced / separated",
      marital_code == 7 ~ "Never married",
      marital_code == 8 ~ "Living with partner",
      TRUE ~ NA_character_
    ),
    employed = case_when(
      employment_code == 1 ~ "Worked last week",
      employment_code == 2 ~ "Did not work last week",
      TRUE ~ NA_character_
    ),
    hypertension = recode_yes_no(HYPEV_A),
    coronary_heart_disease = recode_yes_no(CHDEV_A),
    angina = recode_yes_no(ANGEV_A),
    heart_attack = recode_yes_no(MIEV_A),
    stroke = recode_yes_no(STREV_A),
    asthma_ever = recode_yes_no(ASEV_A),
    asthma_still = recode_yes_no(ASTILL_A),
    cancer = recode_yes_no(CANEV_A),
    diabetes = recode_yes_no(DIBEV_A),
    copd = recode_yes_no(COPDEV_A),
    arthritis = recode_yes_no(ARTHEV_A),
    kidney_disease = recode_yes_no(KIDWEAKEV_A),
    liver_disease = recode_yes_no(LIVEREV_A),
    depression = recode_yes_no(DEPEV_A),
    anxiety = recode_yes_no(ANXEV_A)
  ) %>%
  mutate(
    age_group = factor(age_group, levels = c("18-34", "35-49", "50-64", "65+")),
    sex = factor(sex, levels = c("Male", "Female")),
    race_ethnicity = factor(race_ethnicity, levels = c("Non-Hispanic White", "Non-Hispanic Black", "Hispanic", "Non-Hispanic Asian", "Other / multiple")),
    education4 = factor(education4, levels = c("Bachelor's or higher", "Some college / associate", "High school graduate", "Less than high school")),
    marital4 = factor(marital4, levels = c("Married", "Living with partner", "Never married", "Widowed / divorced / separated")),
    heart_disease = combine_any_condition(coronary_heart_disease, angina, heart_attack),
    current_asthma = case_when(
      asthma_ever == 0 ~ 0L,
      asthma_ever == 1 & asthma_still == 1 ~ 1L,
      asthma_ever == 1 & asthma_still == 0 ~ 0L,
      TRUE ~ NA_integer_
    )
  ) %>%
  select(-region_code, -age_code, -sex_code, -race_code, -education_code, -marital_code, -employment_code)

condition_vars <- c(
  "hypertension", "heart_disease", "stroke", "current_asthma", "cancer", "diabetes",
  "copd", "arthritis", "kidney_disease", "liver_disease", "depression", "anxiety"
)
physical_condition_vars <- setdiff(condition_vars, c("depression", "anxiety"))

adult_analysis <- adult_analysis %>%
  rowwise() %>%
  mutate(
    condition_nonmissing = sum(!is.na(c_across(all_of(condition_vars)))),
    mm_count = if_else(condition_nonmissing == length(condition_vars), sum(c_across(all_of(condition_vars))), NA_real_),
    physical_nonmissing = sum(!is.na(c_across(all_of(physical_condition_vars)))),
    physical_mm_count = if_else(physical_nonmissing == length(physical_condition_vars), sum(c_across(all_of(physical_condition_vars))), NA_real_)
  ) %>%
  ungroup() %>%
  mutate(
    multimorbidity = if_else(!is.na(mm_count), as.integer(mm_count >= 2), NA_integer_),
    complex_multimorbidity = if_else(!is.na(mm_count), as.integer(mm_count >= 3), NA_integer_),
    physical_multimorbidity = if_else(!is.na(physical_mm_count), as.integer(physical_mm_count >= 2), NA_integer_)
  )

income_keep <- income %>%
  transmute(
    HHX = as.character(HHX),
    IMPNUM_A = suppressWarnings(as.integer(IMPNUM_A)),
    POVRATTC_A = suppressWarnings(as.numeric(POVRATTC_A)),
    RATCAT_A = suppressWarnings(as.integer(RATCAT_A)),
    poverty4 = case_when(
      RATCAT_A %in% 1:3 ~ "<100% FPL",
      RATCAT_A %in% 4:7 ~ "100-199% FPL",
      RATCAT_A %in% 8:11 ~ "200-399% FPL",
      RATCAT_A %in% 12:14 ~ "400%+ FPL",
      TRUE ~ NA_character_
    )
  ) %>%
  mutate(poverty4 = factor(poverty4, levels = c("400%+ FPL", "200-399% FPL", "100-199% FPL", "<100% FPL")))

adult_income_mi <- adult_analysis %>%
  left_join(income_keep, by = "HHX")

saveRDS(adult_analysis, here::here("data", "processed", "adult_analysis.rds"))
saveRDS(adult_income_mi, here::here("data", "processed", "adult_income_mi.rds"))

readr::write_csv(
  tibble::tibble(condition = condition_vars),
  here::here("data", "processed", "condition_definition.csv")
)

message("Prepared analysis data saved to data/processed/.")

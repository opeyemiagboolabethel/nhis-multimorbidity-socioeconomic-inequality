source(here::here("R", "00_dependencies.R"))

dir.create(here::here("outputs", "figures"), recursive = TRUE, showWarnings = FALSE)

age_edu <- readr::read_csv(here::here("outputs", "tables", "multimorbidity_by_age_education.csv"), show_col_types = FALSE)
condition_age <- readr::read_csv(here::here("outputs", "tables", "condition_prevalence_by_age.csv"), show_col_types = FALSE)
models <- readr::read_csv(here::here("outputs", "tables", "regression_models.csv"), show_col_types = FALSE)

# Figure 1: social gradient across adulthood.
p1 <- ggplot(age_edu, aes(x = age_group, y = multimorbidity, group = education4, linetype = education4, shape = education4)) +
  geom_line(linewidth = 0.8) +
  geom_point(size = 2.5) +
  geom_errorbar(aes(ymin = ci_l, ymax = ci_u), width = 0.08, linewidth = 0.4) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1), limits = c(0, NA)) +
  labs(
    title = "Multimorbidity follows a socioeconomic gradient across adulthood",
    subtitle = "Survey-weighted prevalence by age group and educational attainment, NHIS 2024",
    x = "Age group", y = "Multimorbidity prevalence", linetype = "Education", shape = "Education",
    caption = "Multimorbidity = at least 2 of 12 chronic physical or mental health conditions. Error bars show 95% CIs."
  ) +
  theme_minimal(base_size = 11) +
  theme(legend.position = "bottom", plot.title.position = "plot", panel.grid.minor = element_blank())

ggsave(here::here("outputs", "figures", "figure_1_multimorbidity_age_education.png"), p1, width = 9, height = 6, dpi = 320)

# Figure 2: chronic-condition patterning by age.
condition_labels <- c(
  hypertension = "Hypertension", heart_disease = "Heart disease", stroke = "Stroke",
  current_asthma = "Current asthma", cancer = "Cancer", diabetes = "Diabetes", copd = "COPD",
  arthritis = "Arthritis", kidney_disease = "Kidney disease", liver_disease = "Liver disease",
  depression = "Depression", anxiety = "Anxiety"
)
condition_age <- condition_age %>%
  mutate(condition_label = factor(condition_labels[condition], levels = rev(unname(condition_labels))))

p2 <- ggplot(condition_age, aes(x = age_group, y = condition_label, fill = prevalence)) +
  geom_tile() +
  geom_text(aes(label = scales::percent(prevalence, accuracy = 1)), size = 3) +
  scale_fill_viridis_c(labels = scales::percent_format(accuracy = 1), option = "C", end = 0.9) +
  labs(
    title = "Chronic-condition burden changes markedly across adulthood",
    subtitle = "Survey-weighted condition prevalence, NHIS 2024",
    x = "Age group", y = NULL, fill = "Prevalence"
  ) +
  theme_minimal(base_size = 11) +
  theme(panel.grid = element_blank(), plot.title.position = "plot")

ggsave(here::here("outputs", "figures", "figure_2_condition_heatmap.png"), p2, width = 8.5, height = 6.5, dpi = 320)

# Figure 3: adjusted odds ratios from the main-effects model.
forest <- models %>%
  filter(model == "Model 2: full main effects", term != "(Intercept)") %>%
  mutate(term_clean = term %>%
           str_replace_all("education4", "Education: ") %>%
           str_replace_all("age_group", "Age: ") %>%
           str_replace_all("race_ethnicity", "Race/ethnicity: ") %>%
           str_replace_all("marital4", "Marital status: ") %>%
           str_replace_all("region", "Region: ") %>%
           str_replace_all("sexFemale", "Sex: Female")) %>%
  arrange(estimate) %>%
  mutate(term_clean = factor(term_clean, levels = term_clean))

p3 <- ggplot(forest, aes(x = estimate, y = term_clean)) +
  geom_vline(xintercept = 1, linetype = "dashed") +
  geom_errorbar(aes(xmin = conf_low, xmax = conf_high), width = 0.18, orientation = "y") +
  geom_point(size = 2.2) +
  scale_x_log10() +
  labs(
    title = "Adjusted associations with multimorbidity",
    subtitle = "Survey-weighted logistic regression; odds ratios on a log scale",
    x = "Adjusted odds ratio (95% CI)", y = NULL
  ) +
  theme_minimal(base_size = 10.5) +
  theme(panel.grid.minor = element_blank(), plot.title.position = "plot")

ggsave(here::here("outputs", "figures", "figure_3_adjusted_odds_ratios.png"), p3, width = 9, height = 7, dpi = 320)

message("Publication-quality figures saved to outputs/figures/.")

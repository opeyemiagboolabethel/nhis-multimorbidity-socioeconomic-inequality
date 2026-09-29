required_packages <- c(
  "readr", "dplyr", "tidyr", "ggplot2", "forcats", "stringr", "purrr",
  "survey", "mitools", "scales", "glue", "here", "patchwork"
)

missing_packages <- required_packages[!vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing_packages) > 0) {
  install.packages(missing_packages, repos = "https://cloud.r-project.org")
}

suppressPackageStartupMessages({
  library(readr)
  library(dplyr)
  library(tidyr)
  library(ggplot2)
  library(forcats)
  library(stringr)
  library(purrr)
  library(survey)
  library(mitools)
  library(scales)
  library(glue)
  library(here)
  library(patchwork)
})

options(survey.lonely.psu = "adjust")
options(scipen = 999)

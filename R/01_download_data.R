source(here::here("R", "00_dependencies.R"))

# NHIS files are small, but some networks are slow to the CDC FTP mirror.
# Use a generous timeout and validate ZIP integrity before extraction.
options(timeout = max(getOption("timeout"), 600))

dir.create(here::here("data", "raw"), recursive = TRUE, showWarnings = FALSE)

sources <- tibble::tribble(
  ~name, ~url, ~zip_name, ~expected_csv,
  "sample_adult", "https://ftp.cdc.gov/pub/Health_Statistics/NCHS/Datasets/NHIS/2024/adult24csv.zip", "adult24csv.zip", "adult24.csv",
  "imputed_income", "https://ftp.cdc.gov/pub/Health_Statistics/NCHS/Datasets/NHIS/2024/adultinc24csv.zip", "adultinc24csv.zip", "adultinc24.csv"
)

zip_is_valid <- function(path) {
  if (!file.exists(path) || file.info(path)$size <= 0) return(FALSE)
  tryCatch({
    utils::unzip(path, list = TRUE)
    TRUE
  }, error = function(e) FALSE, warning = function(w) FALSE)
}

download_one <- function(url, zip_name) {
  zip_path <- here::here("data", "raw", zip_name)

  if (!zip_is_valid(zip_path)) {
    if (file.exists(zip_path)) unlink(zip_path, force = TRUE)
    message("Downloading: ", url)
    ok <- tryCatch({
      utils::download.file(url, zip_path, mode = "wb", method = "libcurl", quiet = FALSE)
      TRUE
    }, error = function(e) FALSE)
    if (!ok) {
      utils::download.file(url, zip_path, mode = "wb", quiet = FALSE)
    }
  }

  if (!zip_is_valid(zip_path)) {
    unlink(zip_path, force = TRUE)
    stop("Downloaded file is incomplete or not a valid ZIP: ", zip_name,
         ". Download it manually from the CDC URL and place it in data/raw/.")
  }

  zip_path
}

for (i in seq_len(nrow(sources))) {
  expected_path <- here::here("data", "raw", sources$expected_csv[i])
  if (!file.exists(expected_path)) {
    zip_path <- download_one(sources$url[i], sources$zip_name[i])
    utils::unzip(zip_path, exdir = here::here("data", "raw"), overwrite = TRUE)
  }
}

adult_csv <- list.files(here::here("data", "raw"), pattern = "^adult24\\.csv$", full.names = TRUE, ignore.case = TRUE)
income_csv <- list.files(here::here("data", "raw"), pattern = "^adultinc24\\.csv$", full.names = TRUE, ignore.case = TRUE)

if (length(adult_csv) != 1L || length(income_csv) != 1L) {
  stop("Expected adult24.csv and adultinc24.csv after extraction. Check data/raw/.")
}

message("NHIS files are ready in data/raw/")

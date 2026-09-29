# Reproducibility

## Software
R 4.3+ is recommended. The pipeline installs missing CRAN packages automatically.

## One-command run

Open `project_03_nhis_multimorbidity.Rproj` and execute:

```r
source("run_all.R")
```

The pipeline:

1. downloads the two official CDC/NCHS 2024 NHIS ZIP files
2. validates ZIP integrity and extracts the CSV files
3. reads only the analytical variables required for the project
4. prepares the multimorbidity and socioeconomic variables
5. performs QA and missingness checks
6. creates survey-weighted descriptive estimates
7. fits the main regression, interaction, count and sensitivity models
8. pools the 10 income imputations
9. exports figures, tables and model logs

The download routine uses a 600-second timeout to accommodate slower CDC file transfers.

## Official data sources

- 2024 NHIS documentation: https://www.cdc.gov/nchs/nhis/documentation/2024-nhis.html
- Sample Adult CSV ZIP: https://ftp.cdc.gov/pub/Health_Statistics/NCHS/Datasets/NHIS/2024/adult24csv.zip
- Adult imputed-income CSV ZIP: https://ftp.cdc.gov/pub/Health_Statistics/NCHS/Datasets/NHIS/2024/adultinc24csv.zip
- Adult codebook: https://ftp.cdc.gov/pub/Health_Statistics/NCHS/Dataset_Documentation/NHIS/2024/Adult-codebook.pdf
- Survey description: https://ftp.cdc.gov/pub/Health_Statistics/NCHS/Dataset_Documentation/NHIS/2024/srvydesc-508.pdf
- Income imputation methods: https://ftp.cdc.gov/pub/Health_Statistics/NCHS/Dataset_Documentation/NHIS/2024/NHIS2024-imputation-techdoc-508.pdf

## Git policy

The raw public-use data are intentionally excluded from the repository. They are reproducibly downloaded from CDC/NCHS. Processed `.rds` objects are also excluded because they can be recreated by the pipeline. Analytical result tables and figures are retained in Git.

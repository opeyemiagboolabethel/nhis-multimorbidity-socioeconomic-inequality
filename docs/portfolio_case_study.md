# Portfolio Case Study

## Challenge

Multimorbidity is often presented as an aging problem, but chronic-condition accumulation is also socially patterned. The analytical challenge was to quantify how education and poverty relate to multimorbidity while respecting the complex NHIS survey design and the CDC's multiply imputed income data.

## What I built

A fully reproducible R workflow that:

- downloads official CDC/NCHS public-use files
- selects and recodes the analytical variables
- constructs 12-condition and physical-only multimorbidity measures
- applies NHIS weights, strata and pseudo-PSUs
- calculates weighted prevalence and confidence intervals
- fits survey-weighted logistic and quasi-Poisson models
- tests education × age interaction as a block
- combines all 10 income imputations using Rubin's rules
- runs data-quality checks
- exports publication-style figures and machine-readable result tables

## Technical skills demonstrated

**R:** data wrangling, functions, reproducible pipelines, modelling, visualization  
**Survey statistics:** `survey` package, complex designs, weighted regression  
**Missing data:** multiple imputation combining with `mitools`  
**Quantitative sociology:** social stratification, age-patterned inequality, cautious life-course interpretation  
**Research engineering:** QA, project structure, reproducibility, documentation

## Key analytical result

Educational inequality was not uniform across adulthood. The gap in weighted multimorbidity prevalence between adults with less than high school education and those with a bachelor's degree or higher was approximately 17 percentage points among ages 50–64. A formal interaction test confirmed heterogeneity across age groups.

Family poverty showed an additional gradient: adults below the federal poverty line had about twice the adjusted odds of multimorbidity compared with those at 400%+ FPL after pooling all 10 income imputations.

## Why this matters for a data portfolio

The project goes beyond dashboarding. It demonstrates the ability to work with real national health microdata, understand complex survey design, handle missing-income uncertainty appropriately, build defensible statistical models, validate results, and communicate findings without overstating causal claims.

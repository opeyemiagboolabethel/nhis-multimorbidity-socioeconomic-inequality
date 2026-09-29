# Analysis Plan

## Title
**Socioeconomic Stratification and Multimorbidity Across Adulthood in the United States: A Survey-Weighted Analysis of the 2024 National Health Interview Survey**

## Purpose
This is a reproducible quantitative-sociology portfolio project examining whether socioeconomic inequality in multimorbidity varies across stages of adulthood.

## Primary research question
How is educational attainment associated with multimorbidity among U.S. adults, and does the magnitude of this association differ across age groups?

## Secondary questions
1. Does family poverty status show an independent association with multimorbidity after accounting for education and demographic characteristics?
2. Do results remain when multimorbidity is restricted to physical chronic conditions?
3. How does the condition composition of multimorbidity differ across adulthood?

## Population
Adults aged 18 years and older in the 2024 NHIS Sample Adult public-use file, representing the U.S. civilian noninstitutionalized population.

## Outcome
Primary: multimorbidity, defined as at least two of 12 chronic conditions: hypertension, heart disease, stroke, current asthma, cancer, diabetes, COPD, arthritis, kidney disease, liver disease, depression, and anxiety.

Secondary outcomes:
- chronic-condition count (0–12)
- complex multimorbidity (3+ conditions)
- physical multimorbidity excluding depression and anxiety

## Main exposure
Education:
- Bachelor's degree or higher
- Some college or associate degree
- High school graduate
- Less than high school

## Age groups
- 18–34
- 35–49
- 50–64
- 65+

Age group is treated as an effect modifier in a cross-sectional age-pattern analysis, not as evidence of within-person life-course change.

## Covariates
Sex, race/ethnicity, marital status, and U.S. Census region. Employment is retained for possible supplementary working-age analyses rather than automatically treated as a confounder across all ages.

## Poverty analysis
Family income-to-poverty ratio is analyzed using all 10 NHIS multiply imputed income datasets:
- <100% FPL
- 100–199% FPL
- 200–399% FPL
- 400%+ FPL

## Survey design
All population estimates and regression models use the NHIS final annual Sample Adult weight (`WTFA_A`), pseudo-PSU (`PPSU`), and pseudo-stratum (`PSTRAT`).

## Models
1. Survey-weighted logistic regression: education + age + sex + race/ethnicity.
2. Full main-effects model adding marital status and region.
3. Education × age-group interaction model.
4. Survey-weighted quasi-Poisson count model for number of chronic conditions.
5. Multiply imputed poverty model pooled using Rubin's rules.
6. Physical-multimorbidity sensitivity analysis.

## Interpretation
Results are associations, not causal effects. Age-group contrasts are not longitudinal trajectories. Adjusted racial/ethnic coefficients are descriptive and should not be interpreted as biological effects.

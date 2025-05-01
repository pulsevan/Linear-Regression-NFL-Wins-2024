# Linear Regression NFL Wins 2024

## Project Goal

This project aims to predict the number of regular-season wins for NFL teams in the 2024 season using multiple linear regression. The analysis focuses on identifying which offensive statistical metrics significantly correlate with team wins.

## Data Source

The data used for this analysis was sourced from [Pro-Football-Reference](https://www.pro-football-reference.com/years/2024/) for the 2024 NFL regular season. It includes team scoring statistics and detailed offensive metrics.

## Methodology

1.  **Data Import & Cleaning:** Imported AFC and NFC scoring data, along with team offense statistics. Cleaned team names by removing playoff indicators ('*' or '+').
2.  **Data Merging:** Combined AFC, NFC, and offensive stats into a single dataframe (`full_df`).
3.  **Feature Selection:** Removed potentially confounding variables like Points Differential (PD), Simple Rating System (SRS) metrics (calculated post-season), and Points For (PF), as other offensive metrics contribute to PF.
4.  **Model Building:**
    * Built an initial multiple linear regression model (`base_lm`) using all remaining offensive metrics to predict Wins (W).
    * Utilized stepwise regression (`step()`) with AIC based on dataset size (`k = log(nrow(full_df))`) to refine the model and identify potentially significant predictors.
5.  **Final Model:** Based on the stepwise results and further analysis for statistical significance, a final simplified linear regression model (`step2`) was created focusing on the most impactful predictors.
6.  **Analysis & Visualization:** The script includes code for model summary statistics (`summary()`), diagnostic plots (Residuals vs Fitted, Normal Q-Q), descriptive statistics, and visualizations like histograms, boxplots (using `ggplot2`), and a correlation matrix (`corrplot`) to explore the data and model results.

## Key Findings

The final regression model identified the following offensive metrics as significant predictors of regular-season wins for the 2024 NFL season:

* **Total First Downs (Tot1stD)**
* **Turnovers (TO.)**

These two predictors both have p-values near 0 and the full model had a p-value also near 0. With an adjusted R² of 0.711, this model accounts of 71.1% of variability in NFL team wins in 2024.

Potential future work includes adding in multiple seasons as well as adding in defensive statistics. 

## Technology Stack

* **Language:** R
* **Core Packages:**
    * `tidyverse` (for data manipulation and potentially `ggplot2`)
    * `ggplot2` (for plotting)
    * `reshape2` (used in plotting code)
    * `corrplot` (for correlation matrix visualization)

## Setup & Usage

1.  **Prerequisites:** Ensure you have R and RStudio (or another R environment) installed.
2.  **Install Packages:** If you don't have the necessary packages, install them in R:
    ```R
    install.packages(c("tidyverse", "ggplot2", "reshape2", "corrplot"))
    ```
3.  **Download Data:** Obtain the relevant CSV files for the 2024 season from Pro-Football-Reference (or use the ones included in this repository).
4.  **Update File Paths:** **Crucially**, open the `LinReg.R` script and **update the file paths** in the `read.csv()` functions to point to the location where you saved the data files on your computer.
    ```R
    # Example - MODIFY THESE LINES in LinReg.R:
    afc <- read.csv("YOUR/PATH/TO/pfrAFCScoring.csv") %>% mutate(Conference = "AFC")
    nfc <- read.csv("YOUR/PATH/TO/pfrNFCscoring.csv") %>% mutate(Conference = "NFC")
    teamOffense <- read.csv("YOUR/PATH/TO/pfrTeamOffense.csv") %>%
      select(-c(PF, G, Rk, EXP, FL))
    ```
5.  **Run the Script:** Execute the `LinReg.R` script in your R environment. The script will perform the data processing, model building, and generate summaries and plots in the R console/plot window.


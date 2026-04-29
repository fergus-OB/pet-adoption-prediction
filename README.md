# Pet Adoption Prediction

A predictive modelling project analysing pet adoption speed using tabular, text-derived, and image-derived features from a Petfinder-style dataset.

This project was completed as a final-year Financial Mathematics project and is being cleaned for public portfolio use.

## Project Overview

The goal of this project is to predict pet adoption speed and identify factors associated with faster or slower adoption outcomes.

The analysis includes:

- Data cleaning and preprocessing
- Feature engineering from structured pet profile data
- Text/image-derived metadata exploration
- Logistic regression modelling
- LASSO regularisation for feature selection
- Model evaluation using AUC/ROC and repeated validation
- Interpretation of key predictors affecting adoption speed

## Project Structure

```text
pet-adoption-prediction/
├── data/
│   └── README.md
├── outputs/
│   └── README.md
├── report/
│   └── README.md
├── src/
│   ├── README.md
│   ├── preprocessing.R
│   ├── exploratory_analysis.R
│   ├── logistic_regression.R
│   ├── lasso_model.R
│   └── model_comparison.R
├── requirements.txt
└── README.md
```

## Workflow

The project follows a clean modelling workflow:

1. **Data preprocessing**  
   `src/preprocessing.R` loads the Petfinder-style tabular data, creates a binary adoption-speed target, engineers additional features, joins breed and colour labels, groups rare breeds, and prepares the modelling dataset.

2. **Exploratory analysis**  
   `src/exploratory_analysis.R` contains visual and summary analysis used to understand adoption-speed patterns across age, breed, health indicators, colour, and other pet attributes.

3. **Baseline logistic regression**  
   `src/logistic_regression.R` defines reusable functions for fitting a baseline logistic regression model and a stepwise AIC-selected logistic regression model.

4. **LASSO regularised logistic regression**  
   `src/lasso_model.R` trains a cross-validated LASSO logistic regression model using `glmnet`, evaluates accuracy and AUC, and saves selected features and model outputs.

5. **Model comparison**  
   `src/model_comparison.R` compares baseline logistic regression, stepwise logistic regression, and LASSO logistic regression using accuracy and AUC.

## How to Run

This repository does not include the full raw dataset.

To run the project locally, download the dataset and place the required files in:

```text
data/raw/
```

Expected files:

```text
data/raw/train.csv
data/raw/breed_labels.csv
data/raw/color_labels.csv
```

Then run the scripts from the project root:

```r
source("src/preprocessing.R")
source("src/exploratory_analysis.R")
source("src/lasso_model.R")
source("src/model_comparison.R")
```

## Outputs

The modelling scripts save outputs to the `outputs/` folder, including:

```text
lasso_selected_features.csv
lasso_model_evaluation.csv
lasso_cv_curve.png
lasso_roc_curve.png
model_comparison.csv
model_auc_comparison.png
```

## Skills Demonstrated

- Data cleaning and feature engineering in R
- Binary classification modelling
- Logistic regression
- Stepwise model selection using AIC
- LASSO regularisation with cross-validation
- Model evaluation using accuracy, ROC curves, and AUC
- Reproducible project organisation
- Clear separation between raw data, source code, reports, and outputs

## Notes

The original project included exploratory work with tabular, text-derived, and image-derived features. This public version focuses on cleaned, recruiter-readable scripts and documentation rather than raw experimental notebooks.

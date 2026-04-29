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

## Repository Structure

```text
pet-adoption-prediction/
├── data/
│   └── sample/
├── notebooks/
│   └── README.md
├── src/
│   ├── preprocessing.R
│   ├── feature_engineering.R
│   ├── modelling.R
│   └── evaluation.R
├── outputs/
│   └── README.md
├── report/
│   └── README.md
├── README.md
├── LICENSE
└── .gitignore

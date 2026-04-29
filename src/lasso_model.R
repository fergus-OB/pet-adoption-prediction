# ================================================================
# LASSO Logistic Regression Model
# Pet Adoption Prediction Project
#
# Purpose:
#   Train and evaluate a LASSO-regularised logistic regression model
#   for predicting slower pet adoption outcomes.
#
# Target:
#   binary_AdoptionSpeed
#   0 = adopted within 30 days
#   1 = adopted after 30 days
#
# Notes:
#   - This script uses the preprocessing functions defined in
#     src/preprocessing.R.
#   - PetID is excluded from modelling because it is an identifier.
#   - glmnet is used for cross-validated LASSO regularisation.
# ================================================================


# -----------------------------
# 1. Load required packages
# -----------------------------

required_packages <- c(
  "tidyverse",
  "glmnet",
  "caret",
  "pROC"
)

installed_packages <- rownames(installed.packages())

for (pkg in required_packages) {
  if (!(pkg %in% installed_packages)) {
    install.packages(pkg)
  }
}

library(tidyverse)
library(glmnet)
library(caret)
library(pROC)


# -----------------------------
# 2. Load preprocessing functions
# -----------------------------

source("src/preprocessing.R")


# -----------------------------
# 3. Build modelling dataset
# -----------------------------

petfinder_files <- load_petfinder_data(
  train_path = "data/raw/train.csv",
  breed_labels_path = "data/raw/breed_labels.csv",
  color_labels_path = "data/raw/color_labels.csv"
)

cleaned_data <- prepare_petfinder_data(
  train = petfinder_files$train,
  breed_labels = petfinder_files$breed_labels,
  color_labels = petfinder_files$color_labels
)

model_data <- create_modelling_dataset(cleaned_data)

cat("Modelling dataset created successfully.\n")
cat("Rows:", nrow(model_data), "\n")
cat("Columns:", ncol(model_data), "\n")


# -----------------------------
# 4. Basic validation
# -----------------------------

target_variable <- "binary_AdoptionSpeed"

if (!(target_variable %in% names(model_data))) {
  stop("Target variable 'binary_AdoptionSpeed' not found in modelling dataset.")
}

# Remove ID column before modelling.
if ("PetID" %in% names(model_data)) {
  model_data <- model_data %>% select(-PetID)
}


# -----------------------------
# 5. Train-test split
# -----------------------------

set.seed(123)

train_index <- createDataPartition(
  model_data[[target_variable]],
  p = 0.80,
  list = FALSE
)

train_data <- model_data[train_index, ]
test_data  <- model_data[-train_index, ]

cat("Training rows:", nrow(train_data), "\n")
cat("Testing rows:", nrow(test_data), "\n")


# -----------------------------
# 6. Prepare model matrices
# -----------------------------

# glmnet requires numeric matrix inputs.
# model.matrix converts categorical variables into dummy variables.

x_train <- model.matrix(
  binary_AdoptionSpeed ~ .,
  data = train_data
)[, -1]

y_train <- train_data$binary_AdoptionSpeed

x_test <- model.matrix(
  binary_AdoptionSpeed ~ .,
  data = test_data
)[, -1]

y_test <- test_data$binary_AdoptionSpeed


# -----------------------------
# 7. Cross-validated LASSO model
# -----------------------------

set.seed(123)

lasso_cv <- cv.glmnet(
  x = x_train,
  y = y_train,
  family = "binomial",
  alpha = 1,
  type.measure = "auc",
  nfolds = 10
)

best_lambda <- lasso_cv$lambda.min
one_se_lambda <- lasso_cv$lambda.1se

cat("Best lambda:", best_lambda, "\n")
cat("One-standard-error lambda:", one_se_lambda, "\n")


# -----------------------------
# 8. Generate predictions
# -----------------------------

predicted_probabilities <- predict(
  lasso_cv,
  newx = x_test,
  s = "lambda.min",
  type = "response"
)

predicted_classes <- ifelse(predicted_probabilities > 0.5, 1, 0)


# -----------------------------
# 9. Model evaluation
# -----------------------------

confusion_matrix <- table(
  Predicted = predicted_classes,
  Actual = y_test
)

accuracy <- mean(predicted_classes == y_test)

roc_curve <- roc(
  response = y_test,
  predictor = as.vector(predicted_probabilities)
)

auc_score <- auc(roc_curve)

cat("\nConfusion Matrix:\n")
print(confusion_matrix)

cat("\nAccuracy:", round(accuracy, 4), "\n")
cat("AUC:", round(as.numeric(auc_score), 4), "\n")


# -----------------------------
# 10. Extract selected features
# -----------------------------

lasso_coefficients <- coef(lasso_cv, s = "lambda.min")

selected_features <- as.matrix(lasso_coefficients) %>%
  as.data.frame() %>%
  rownames_to_column("feature") %>%
  rename(coefficient = s1) %>%
  filter(coefficient != 0) %>%
  arrange(desc(abs(coefficient)))

cat("\nNumber of selected features:", nrow(selected_features), "\n")
print(selected_features)


# -----------------------------
# 11. Save outputs
# -----------------------------

if (!dir.exists("outputs")) {
  dir.create("outputs")
}

write.csv(
  selected_features,
  "outputs/lasso_selected_features.csv",
  row.names = FALSE
)

evaluation_summary <- data.frame(
  model = "LASSO Logistic Regression",
  target = "binary_AdoptionSpeed",
  best_lambda = best_lambda,
  one_se_lambda = one_se_lambda,
  accuracy = accuracy,
  auc = as.numeric(auc_score)
)

write.csv(
  evaluation_summary,
  "outputs/lasso_model_evaluation.csv",
  row.names = FALSE
)

png("outputs/lasso_cv_curve.png", width = 900, height = 700)
plot(lasso_cv)
title("Cross-Validation Curve for LASSO Logistic Regression")
dev.off()

png("outputs/lasso_roc_curve.png", width = 900, height = 700)
plot(
  roc_curve,
  main = paste("LASSO ROC Curve - AUC:", round(as.numeric(auc_score), 4))
)
dev.off()

cat("\nLASSO model outputs saved successfully.\n")

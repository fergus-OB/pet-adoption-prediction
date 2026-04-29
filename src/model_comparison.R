# ================================================================
# Model Comparison
# Pet Adoption Prediction Project
#
# Purpose:
#   Compare baseline logistic regression, stepwise logistic
#   regression, and LASSO logistic regression models.
#
# Target:
#   binary_AdoptionSpeed
#   0 = adopted within 30 days
#   1 = adopted after 30 days
#
# Notes:
#   - This script uses preprocessing.R to prepare the modelling data.
#   - This script uses logistic_regression.R for reusable logistic
#     regression functions.
#   - LASSO is fitted directly using glmnet.
# ================================================================


# -----------------------------
# 1. Load required packages
# -----------------------------

required_packages <- c(
  "tidyverse",
  "caret",
  "glmnet",
  "pROC",
  "MASS"
)

installed_packages <- rownames(installed.packages())

for (pkg in required_packages) {
  if (!(pkg %in% installed_packages)) {
    install.packages(pkg)
  }
}

library(tidyverse)
library(caret)
library(glmnet)
library(pROC)
library(MASS)


# -----------------------------
# 2. Load project functions
# -----------------------------

source("src/preprocessing.R")
source("src/logistic_regression.R")


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
# 4. Train-test split
# -----------------------------

set.seed(123)

train_index <- createDataPartition(
  model_data$binary_AdoptionSpeed,
  p = 0.80,
  list = FALSE
)

train_data <- model_data[train_index, ]
test_data  <- model_data[-train_index, ]

cat("Training rows:", nrow(train_data), "\n")
cat("Testing rows:", nrow(test_data), "\n")


# -----------------------------
# 5. Helper evaluation function
# -----------------------------

evaluate_predictions <- function(model_name, actual, probabilities, threshold = 0.5) {
  predicted_class <- ifelse(probabilities >= threshold, 1, 0)

  accuracy <- mean(predicted_class == actual)

  roc_curve <- roc(
    response = actual,
    predictor = as.vector(probabilities),
    quiet = TRUE
  )

  auc_score <- auc(roc_curve)

  data.frame(
    model = model_name,
    accuracy = as.numeric(accuracy),
    auc = as.numeric(auc_score)
  )
}


# -----------------------------
# 6. Baseline logistic regression
# -----------------------------

baseline_model <- fit_baseline_logistic_model(train_data)

baseline_probabilities <- predict_logistic_probabilities(
  model = baseline_model,
  new_data = test_data
)

baseline_results <- evaluate_predictions(
  model_name = "Baseline Logistic Regression",
  actual = test_data$binary_AdoptionSpeed,
  probabilities = baseline_probabilities
)


# -----------------------------
# 7. Stepwise logistic regression
# -----------------------------

stepwise_model <- fit_stepwise_logistic_model(baseline_model)

stepwise_probabilities <- predict_logistic_probabilities(
  model = stepwise_model,
  new_data = test_data
)

stepwise_results <- evaluate_predictions(
  model_name = "Stepwise Logistic Regression",
  actual = test_data$binary_AdoptionSpeed,
  probabilities = stepwise_probabilities
)


# -----------------------------
# 8. LASSO logistic regression
# -----------------------------

# Remove ID column before creating model matrices.
lasso_train_data <- train_data %>% select(-PetID)
lasso_test_data  <- test_data %>% select(-PetID)

x_train <- model.matrix(
  binary_AdoptionSpeed ~ .,
  data = lasso_train_data
)[, -1]

y_train <- lasso_train_data$binary_AdoptionSpeed

x_test <- model.matrix(
  binary_AdoptionSpeed ~ .,
  data = lasso_test_data
)[, -1]

y_test <- lasso_test_data$binary_AdoptionSpeed

set.seed(123)

lasso_cv <- cv.glmnet(
  x = x_train,
  y = y_train,
  family = "binomial",
  alpha = 1,
  type.measure = "auc",
  nfolds = 10
)

lasso_probabilities <- predict(
  lasso_cv,
  newx = x_test,
  s = "lambda.min",
  type = "response"
)

lasso_results <- evaluate_predictions(
  model_name = "LASSO Logistic Regression",
  actual = y_test,
  probabilities = lasso_probabilities
)


# -----------------------------
# 9. Combine model results
# -----------------------------

model_comparison <- bind_rows(
  baseline_results,
  stepwise_results,
  lasso_results
) %>%
  arrange(desc(auc))

cat("\nModel Comparison:\n")
print(model_comparison)

best_model <- model_comparison %>%
  slice_max(order_by = auc, n = 1)

cat("\nBest model by AUC:\n")
print(best_model)


# -----------------------------
# 10. Save comparison outputs
# -----------------------------

if (!dir.exists("outputs")) {
  dir.create("outputs")
}

write_csv(
  model_comparison,
  "outputs/model_comparison.csv"
)

auc_plot <- ggplot(model_comparison, aes(x = reorder(model, auc), y = auc)) +
  geom_col() +
  coord_flip() +
  labs(
    title = "Model AUC Comparison",
    x = "Model",
    y = "AUC"
  ) +
  theme_minimal()

ggsave(
  filename = "outputs/model_auc_comparison.png",
  plot = auc_plot,
  width = 8,
  height = 5
)

cat("\nModel comparison outputs saved successfully.\n")

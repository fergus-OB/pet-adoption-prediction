# logistic_regression.R
#
# Logistic regression modelling for the Pet Adoption Prediction project.
#
# This script contains reusable functions for fitting:
# - a baseline logistic regression model
# - a stepwise logistic regression model using AIC
#
# Target:
#   binary_AdoptionSpeed
#   0 = adopted within 30 days
#   1 = adopted after 30 days

library(dplyr)
library(MASS)

fit_baseline_logistic_model <- function(modelling_data) {
  glm(
    binary_AdoptionSpeed ~
      Type +
      Gender +
      MaturitySize +
      FurLength +
      Health +
      Quantity +
      PhotoAmt +
      Log10_Age +
      VaccinatedBinary +
      DewormedBinary +
      SterilizedBinary +
      CrossBreed +
      Tri_Colour +
      Fee_binary +
      BreedName +
      ColorNamePrimary +
      ColorNameSecondary,
    data = modelling_data,
    family = binomial
  )
}

fit_stepwise_logistic_model <- function(baseline_model) {
  stepAIC(
    baseline_model,
    direction = "both",
    trace = FALSE
  )
}

predict_logistic_probabilities <- function(model, new_data) {
  predict(
    model,
    newdata = new_data,
    type = "response"
  )
}

classify_probabilities <- function(probabilities, threshold = 0.5) {
  ifelse(probabilities >= threshold, 1, 0)
}

calculate_accuracy <- function(predicted_class, actual_class) {
  mean(predicted_class == actual_class)
}

summarise_logistic_model <- function(model) {
  summary(model)
}

# Example usage:
#
# source("src/preprocessing.R")
#
# data <- load_petfinder_data()
# cleaned_data <- prepare_petfinder_data(
#   train = data$train,
#   breed_labels = data$breed_labels,
#   color_labels = data$color_labels
# )
# modelling_data <- create_modelling_dataset(cleaned_data)
#
# baseline_model <- fit_baseline_logistic_model(modelling_data)
# stepwise_model <- fit_stepwise_logistic_model(baseline_model)
#
# probabilities <- predict_logistic_probabilities(stepwise_model, modelling_data)
# predicted_class <- classify_probabilities(probabilities)
# accuracy <- calculate_accuracy(predicted_class, modelling_data$binary_AdoptionSpeed)
#
# accuracy
# summary(stepwise_model)

# preprocessing.R
#
# Data cleaning and feature engineering for the Pet Adoption Prediction project.
#
# This script prepares the Petfinder.my training data for modelling by:
# - creating a binary adoption-speed target
# - transforming skewed age values
# - creating binary health/status indicators
# - joining breed and colour labels
# - grouping rare breeds
# - preparing a cleaned modelling dataset
#
# The full raw dataset is not included in this repository.
# Expected local files:
#   data/raw/train.csv
#   data/raw/breed_labels.csv
#   data/raw/color_labels.csv

library(dplyr)
library(readr)

load_petfinder_data <- function(
    train_path = "data/raw/train.csv",
    breed_labels_path = "data/raw/breed_labels.csv",
    color_labels_path = "data/raw/color_labels.csv"
) {
  train <- read_csv(train_path, show_col_types = FALSE)
  breed_labels <- read_csv(breed_labels_path, show_col_types = FALSE)
  color_labels <- read_csv(color_labels_path, show_col_types = FALSE)

  list(
    train = train,
    breed_labels = breed_labels,
    color_labels = color_labels
  )
}

prepare_petfinder_data <- function(train, breed_labels, color_labels, rare_breed_threshold = 100) {
  # Create binary target:
  # 0 = adopted within 30 days
  # 1 = adopted after 30 days
  train <- train %>%
    mutate(
      binary_AdoptionSpeed = ifelse(AdoptionSpeed %in% c(3, 4), 1, 0),
      Log10_Age = log10(Age + 1),
      VaccinatedBinary = ifelse(Vaccinated == 1, 1, 0),
      DewormedBinary = ifelse(Dewormed == 1, 1, 0),
      SterilizedBinary = ifelse(Sterilized == 1, 1, 0),
      CrossBreed = ifelse(Breed2 == 0, 0, 1),
      Tri_Colour = ifelse(Color3 == 0, 0, 1),
      Fee_binary = ifelse(Fee > 0, 1, 0)
    )

  # Join primary breed label
  train <- train %>%
    left_join(
      breed_labels,
      by = c("Breed1" = "BreedID")
    ) %>%
    rename(BreedName = BreedName)

  # Join primary and secondary colour labels
  train <- train %>%
    left_join(
      color_labels,
      by = c("Color1" = "ColorID")
    ) %>%
    rename(ColorNamePrimary = ColorName) %>%
    left_join(
      color_labels,
      by = c("Color2" = "ColorID")
    ) %>%
    rename(ColorNameSecondary = ColorName)

  # Group rare breeds into a single category to reduce high-cardinality noise
  breed_counts <- train %>%
    count(BreedName, name = "count")

  rare_breeds <- breed_counts %>%
    filter(count < rare_breed_threshold) %>%
    pull(BreedName)

  train <- train %>%
    mutate(
      BreedName = ifelse(BreedName %in% rare_breeds, "Rare Breed", BreedName),
      BreedName = as.factor(BreedName),
      ColorNamePrimary = as.factor(ColorNamePrimary),
      ColorNameSecondary = ifelse(is.na(ColorNameSecondary), "Solid", ColorNameSecondary),
      ColorNameSecondary = as.factor(ColorNameSecondary),
      Gender = as.factor(Gender),
      Type = as.factor(Type),
      MaturitySize = as.factor(MaturitySize),
      FurLength = as.factor(FurLength),
      Health = as.factor(Health)
    )

  train
}

create_modelling_dataset <- function(cleaned_data) {
  modelling_data <- cleaned_data %>%
    select(
      binary_AdoptionSpeed,
      PetID,
      Type,
      Gender,
      MaturitySize,
      FurLength,
      Health,
      Quantity,
      State,
      PhotoAmt,
      Log10_Age,
      VaccinatedBinary,
      DewormedBinary,
      SterilizedBinary,
      CrossBreed,
      Tri_Colour,
      Fee_binary,
      BreedName,
      ColorNamePrimary,
      ColorNameSecondary
    ) %>%
    na.omit()

  modelling_data
}

# Example usage:
#
# data <- load_petfinder_data()
# cleaned_data <- prepare_petfinder_data(
#   train = data$train,
#   breed_labels = data$breed_labels,
#   color_labels = data$color_labels
# )
# modelling_data <- create_modelling_dataset(cleaned_data)
# head(modelling_data)

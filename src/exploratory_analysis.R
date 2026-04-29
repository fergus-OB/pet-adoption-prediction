# exploratory_analysis.R
#
# Exploratory data analysis plots for the Pet Adoption Prediction project.
#
# This script assumes the data has already been cleaned using preprocessing.R.
# It creates selected EDA figures used to understand the target variable,
# age distribution, and relationship between age and adoption speed.

library(ggplot2)
library(dplyr)

create_output_dir <- function(output_dir = "outputs") {
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }
}

plot_adoption_speed_distribution <- function(data, output_dir = "outputs") {
  create_output_dir(output_dir)

  plot <- ggplot(data, aes(x = factor(AdoptionSpeed))) +
    geom_bar(fill = "limegreen", colour = "black") +
    labs(
      title = "Distribution of Adoption Speed",
      x = "Adoption Speed: 0 = <1 day, 1 = 1-7, 2 = 8-30, 3 = 31-90, 4 = 100+",
      y = "Frequency"
    ) +
    theme_minimal()

  ggsave(
    filename = file.path(output_dir, "adoption_speed_distribution.png"),
    plot = plot,
    width = 8,
    height = 5
  )

  plot
}

plot_binary_adoption_speed_distribution <- function(data, output_dir = "outputs") {
  create_output_dir(output_dir)

  plot <- ggplot(data, aes(x = factor(binary_AdoptionSpeed))) +
    geom_bar(fill = "orange", colour = "black") +
    labs(
      title = "Distribution of Binary Adoption Speed",
      x = "0 = adopted within 30 days, 1 = adopted after 30 days",
      y = "Frequency"
    ) +
    theme_minimal()

  ggsave(
    filename = file.path(output_dir, "binary_adoption_speed_distribution.png"),
    plot = plot,
    width = 8,
    height = 5
  )

  plot
}

plot_age_distribution <- function(data, output_dir = "outputs") {
  create_output_dir(output_dir)

  plot <- ggplot(data, aes(x = Age)) +
    geom_histogram(bins = 30, fill = "red", colour = "black") +
    labs(
      title = "Distribution of Age",
      x = "Age in Months",
      y = "Frequency"
    ) +
    theme_minimal()

  ggsave(
    filename = file.path(output_dir, "age_distribution.png"),
    plot = plot,
    width = 8,
    height = 5
  )

  plot
}

plot_log10_age_distribution <- function(data, output_dir = "outputs") {
  create_output_dir(output_dir)

  plot <- ggplot(data, aes(x = Log10_Age)) +
    geom_histogram(bins = 30, fill = "dodgerblue", colour = "black") +
    labs(
      title = "Distribution of Log10 Age",
      x = "Log10(Age + 1)",
      y = "Frequency"
    ) +
    theme_minimal()

  ggsave(
    filename = file.path(output_dir, "log10_age_distribution.png"),
    plot = plot,
    width = 8,
    height = 5
  )

  plot
}

plot_log10_age_by_adoption_speed <- function(data, output_dir = "outputs") {
  create_output_dir(output_dir)

  plot <- ggplot(
    data,
    aes(
      x = factor(binary_AdoptionSpeed),
      y = Log10_Age,
      fill = factor(binary_AdoptionSpeed)
    )
  ) +
    geom_boxplot() +
    labs(
      title = "Log10 Age by Adoption Speed",
      x = "Adoption Speed: 0 = <=30 days, 1 = >30 days",
      y = "Log10(Age + 1)"
    ) +
    theme_minimal() +
    theme(legend.position = "none")

  ggsave(
    filename = file.path(output_dir, "log10_age_by_adoption_speed.png"),
    plot = plot,
    width = 8,
    height = 5
  )

  plot
}

run_exploratory_analysis <- function(cleaned_data, output_dir = "outputs") {
  plot_adoption_speed_distribution(cleaned_data, output_dir)
  plot_binary_adoption_speed_distribution(cleaned_data, output_dir)
  plot_age_distribution(cleaned_data, output_dir)
  plot_log10_age_distribution(cleaned_data, output_dir)
  plot_log10_age_by_adoption_speed(cleaned_data, output_dir)
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
#
# run_exploratory_analysis(cleaned_data)

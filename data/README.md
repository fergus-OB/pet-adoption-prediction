# Data

This project uses the Petfinder.my Adoption Prediction dataset.

The full raw dataset is not included in this repository because it contains many large CSV, JSON, and image files.

Dataset source:

- Petfinder.my Adoption Prediction competition on Kaggle

The modelling workflow uses:

- Tabular pet profile data
- Text-derived sentiment features
- Image-derived metadata
- Adoption speed labels

A small sample dataset may be added later for demonstration purposes.

## Expected Raw Files

This repository does not include the full raw Petfinder.my dataset.

To run the scripts, download the dataset locally and place the following files in `data/raw/`:

- `train.csv`
- `breed_labels.csv`
- `color_labels.csv`

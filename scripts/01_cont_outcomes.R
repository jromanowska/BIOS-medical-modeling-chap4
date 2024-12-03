# DESCRIPTION: Some examples of modeling with continuous outcomes
# AUTHOR: Julia Romanowska
# DATE CREATED: 2024-12-03
# DATE LAST MODIFIFED:

# setup ----
library(medicaldata)
library(tidyverse)

# read data ----
data(theoph)
theoph <- as_tibble(theoph)
theoph

# explore ----
skimr::skim(theoph)


# model ----

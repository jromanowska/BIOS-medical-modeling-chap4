# DESCRIPTION: Some examples of modeling with binary outcomes
# AUTHOR: Julia Romanowska
# DATE CREATED: 2024-12-16
# DATE LAST MODIFIFED:

# setup ----
library(medicaldata)
library(tidyverse)
library(performance)
library(rpart)
library(caret)
library(ranger) # for random forests
library(naniar)

data(cath, package = "medicaldata")
(cath <- as_tibble(cath))

# explore ----
skimr::skim(cath)

ggplot(cath, aes(age, choleste)) +
  geom_miss_point() +
  facet_wrap(vars(sex)) +
  theme_bw()

cath_fcts <- cath |>
  mutate(across(c(sex, sigdz, tvdlm), as.factor))

GGally::ggpairs(cath_fcts)

# try some trees ----
(cath_tree1 <- rpart(
  formula = sigdz ~ .,
  data = cath_fcts,
  method = "anova"
))
plotcp(cath_tree1)

# cannot do this with missing values:
(cath_tree2 <- caret::train(
  sigdz ~ .,
  data = cath_fcts,
  method = "rpart"
))

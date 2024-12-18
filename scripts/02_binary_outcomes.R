# DESCRIPTION: Some examples of modeling with binary outcomes
# AUTHOR: Julia Romanowska
# DATE CREATED: 2024-12-16
# DATE LAST MODIFIFED:

# setup ----
library(medicaldata)
library(tidyverse)
library(performance)
library(rpart)
library(rattle)
library(caret)
library(ranger) # for random forests
library(naniar)

data(cath, package = "medicaldata")
(cath <- as_tibble(cath))

# explore ----
skimr::skim(cath)

ggplot(cath, aes(age, choleste)) +
  geom_miss_point() +
  facet_wrap(
    vars(sex),
    labeller = label_both
  ) +
  theme_bw()

ggplot(cath, aes(sigdz, choleste)) +
  geom_miss_point(position = position_jitter(width = 0.3)) +
  theme_bw()

cath_fcts <- cath |>
  mutate(across(c(sex, sigdz, tvdlm), as.factor))

GGally::ggpairs(cath_fcts)

# try some trees ----
cath_non_missing <- cath_fcts |>
  filter(!is.na(choleste))
cath_non_missing
## create train-test split
split_data <- createDataPartition(
  cath_non_missing$sigdz,
  p = 0.7,
  list = FALSE
)
cath_train <- cath_non_missing[split_data, ]
cath_test <- cath_non_missing[-split_data, ]

(cath_tree1 <- rpart(
  formula = sigdz ~ .,
  data = cath_train,
  method = "anova"
))
fancyRpartPlot(cath_tree1)

plotcp(cath_tree1)

## caret cross-validation
(cath_tree2 <- caret::train(
  sigdz ~ .,
  data = cath_train,
  method = "rpart",
  trControl = trainControl(method = "cv", number = 10),
  tuneLength = 20
))
ggplot(cath_tree2)

## feature interpretation
vip(
  cath_tree2,
  
)

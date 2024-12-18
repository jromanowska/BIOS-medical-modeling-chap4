# DESCRIPTION: Some examples of modeling with binary outcomes
# AUTHOR: Julia Romanowska
# DATE CREATED: 2024-12-16
# DATE LAST MODIFIFED: 2024-12-18

# setup ----
library(medicaldata)
library(tidyverse)
library(performance)
library(rpart)
library(rattle)
library(caret)
library(ranger) # for random forests
library(naniar)

# BINARY REGRESSION ----
## read data ----
data(cath, package = "medicaldata")
(cath <- as_tibble(cath) |>
  mutate(across(c(sex, sigdz, tvdlm), as.factor)))

## explore ----
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

## model ----
model_and_check <- function(
  formula,
  my_data
){
  print(cur_model <- glm(
    formula,
    family = "binomial",
    data = my_data
  ))
  print(cur_model |>
    broom::tidy(exp = TRUE, conf.int = TRUE))

  print(r2(cur_model))

  return(invisible(cur_model))
}

cath_model1 <- model_and_check(
  sigdz ~ age + sex + cad_dur + choleste,
  my_data = cath
)

cath_model2 <- model_and_check(
  sigdz ~ age + sex + cad_dur,
  my_data = cath
)

GGally::ggpairs(cath)

cath_model3 <- model_and_check(
  sigdz ~ age * cad_dur + sex + choleste,
  my_data = cath
)

cath_model4 <- model_and_check(
  sigdz ~ age + sex + cad_dur + choleste + tvdlm,
  my_data = cath
)

# TREES ----
data(indo_rct, package = "medicaldata")
indo_rct <- as_tibble(indo_rct)
glimpse(indo_rct)

## explore ----
skimr::skim(indo_rct)

# 'bleed' has almost no values!
indo_rct <- indo_rct |>
  select(-bleed)

## try some trees ----
### create train-test split
split_data <- createDataPartition(
  indo_rct$outcome,
  p = 0.7,
  list = FALSE
)
indo_rct_train <- indo_rct[split_data, ]
indo_rct_test <- indo_rct[-split_data, ]

#### regression
(indo_rct_tree1 <- rpart(
  formula = outcome ~ .,
  data = indo_rct_train,
  method = "anova"
))
fancyRpartPlot(indo_rct_tree1)

#### classification
(indo_rct_tree1 <- rpart(
  formula = outcome ~ .,
  data = indo_rct_train,
  method = "class"
))
fancyRpartPlot(indo_rct_tree1)

plotcp(indo_rct_tree1)

## try with caret ----
(indo_rct_tree2 <- train(
  outcome ~ .,
  data = indo_rct_train,
  method = "rpart",
  trControl = trainControl(method = "cv", number = 10),
  tuneLength = 20
))
ggplot(indo_rct_tree2) +
  theme_bw()

# MARS ----
(indo_rct_mars1 <- earth::earth(
  outcome ~ .,
  data = indo_rct_train
))
summary(indo_rct_mars1)$coefficients |> head(10)
plot(indo_rct_mars1)

## adding interactions ----
(indo_rct_mars2 <- earth::earth(
  outcome ~ .,
  data = indo_rct_train,
  degree = 2
))
summary(indo_rct_mars2)$coefficients |> head(10)
plot(indo_rct_mars2)

# DESCRIPTION: Some examples of modeling with continuous outcomes
# AUTHOR: Julia Romanowska
# DATE CREATED: 2024-12-03
# DATE LAST MODIFIFED: 2024-12-16

# setup ----
library(medicaldata)
library(tidyverse)
library(performance)

# read data ----
data(theoph)
theoph <- as_tibble(theoph)
theoph

# explore ----
skimr::skim(theoph)

(simple_lines <- ggplot(theoph) +
  aes(Time, conc) +
  geom_line() +
  theme_minimal() +
  facet_grid(rows = vars(Subject)))

## max.concentration and half-conc time ----
(theoph_max_conc <- theoph |>
  group_by(Subject) |>
  summarise(
    max_conc = max(conc),
    # these should not change:
    Wt = unique(Wt),
    Dose = unique(Dose)
  ) |>
  mutate(half_max_conc = max_conc / 2)
)
(theoph_max_conc <- theoph_max_conc |>
  left_join(
    theoph |>
      select(Subject, conc, Time),
    by = join_by("Subject" == "Subject", "max_conc" == "conc")
  ) |>
  rename(max_time = Time)
)

simple_lines +
  geom_hline(
    data = theoph_max_conc,
    aes(yintercept = half_max_conc)
  ) +
  geom_vline(
    data = theoph_max_conc,
    aes(xintercept = max_time)
  )

ggplot(theoph_max_conc) +
  aes(max_conc, Wt) +
  geom_point() +
  theme_minimal()

ggplot(theoph_max_conc) +
  aes(max_time, Wt) +
  geom_point() +
  theme_minimal()

ggplot(theoph_max_conc) +
  aes(Dose, Wt) +
  geom_point() +
  theme_minimal()

# model ----
(max_time_model <- lm(
  max_time ~ Wt,
  data = theoph_max_conc
))
max_time_model |>
  broom::tidy(conf.int = TRUE)

check_model(max_time_model)

## this model includes co-linear terms! ----
(max_time_model2 <- lm(
  max_time ~ Wt + Dose,
  data = theoph_max_conc
))
max_time_model2 |>
  broom::tidy(conf.int = TRUE)

check_model(max_time_model2)

## performance tests ----
model_performance(max_time_model)

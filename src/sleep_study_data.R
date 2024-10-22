library(data.table) 

sleep_randomization <- data.table(
  id    = 1:100, 
  treat = sample(x = c('treat_first', 'treat_second'), size = 100, replace = TRUE)
)

participant_demographics <- data.table(
  id             = 1:100, 
  age            = round(rnorm(n = 100, mean = 30, sd = 4)),
  coffee         = sample(c(0, 1, 2, 3, 4, 5), size = 100, replace = TRUE, prob = c(.45, .25, .1, .1, .05, .05)),
  baseline_sleep = rnorm(n=100, mean=7, sd = 2)
)

participant_demographics[age <= 27 ,          bedfellows := sample(c(0, 1, 2), size = .N, replace = TRUE, prob = c(.8, .15, .05))]
participant_demographics[age > 27 & age < 30, bedfellows := sample(c(0, 1, 2), size = .N, replace = TRUE, prob = c(.7, .25, .05))]
participant_demographics[age > 30,            bedfellows := sample(c(0, 1, 2), size = .N, replace = TRUE, prob = c(.4, .55, .05))]
participant_demographics[age < 30 , dogs := sample(c(0, 1, 2), size = .N, replace = TRUE, prob = c(.8, .15, .05))]
participant_demographics[age >= 30, dogs := sample(c(0, 1, 2), size = .N, replace = TRUE, prob = c(.7, .25, .05))]

outcome_measurements <- data.table(
  expand.grid(
    id     = 1:100,
    period = 1:20
  )
)

outcome_measurements <- merge(outcome_measurements, participant_demographics, all.x = TRUE)
outcome_measurements <- merge(outcome_measurements, sleep_randomization, all.x = TRUE)

outcome_measurements[period < 11 & treat == "treat_first",  sleep := baseline_sleep + (.1*rnorm(n=.N, mean = 0.25, sd = 0.5)*age)]
outcome_measurements[period < 11 & treat == "treat_second", sleep := baseline_sleep + rnorm(n=.N, mean=0, sd=0.5)]
outcome_measurements[period > 10 & treat == "treat_first",  sleep := baseline_sleep + (.25*rnorm(n=.N, mean = 0.25, sd = 0.5)*age)]
outcome_measurements[period > 10 & treat == "treat_second", sleep := baseline_sleep + (.1*rnorm(n=.N, mean = 0.25, sd = 0.5)*age)]

outcome_measurements <- outcome_measurements[ , .(id, period, sleep)]

save(sleep_randomization, participant_demographics, outcome_measurements, file = "sleep_study.Rdata")

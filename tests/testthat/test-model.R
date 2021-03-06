local_edition(3)
local_reproducible_output()



test_that("check empty model",{
  expect_snapshot(check(model()))
})

test_that("check simple model",{
  expect_snapshot(check(simple_model()))
})


test_that("required crtl records", {
  simple_model() %>%
    render() %>%
    expect_contains("$PROBLEM") %>%
    expect_contains("$INPUT") %>%
    expect_contains("$PRED")
})

test_that("prm normal distribution", {
  simple_model(prm = prm_normal("k", mean = 2, var = 0.5)) %>%
    render(options = assemblerr_options(prm.use_mu_referencing = TRUE)) %>%
    expect_contains("MU_1 = THETA(1)") %>%
    expect_contains("K = MU_1 + ETA(1)") %>%
    expect_contains("$OMEGA 0.5") %>%
    expect_match("\\$THETA .*2")
})

test_that("prm log-normal distribution", {
  simple_model(prm = prm_log_normal("k", median = 2, var_log = 0.09)) %>%
    render(options = assemblerr_options(prm.use_mu_referencing = TRUE)) %>%
    expect_contains("MU_1 = LOG(THETA(1))") %>%
    expect_contains("K = EXP(MU_1 + ETA(1))") %>%
    expect_contains("$OMEGA 0.09") %>%
    expect_match("\\$THETA .*2")
})

test_that("prm novar distribution", {
  simple_model(prm = prm_no_var("k", value = 5)) %>%
  render(options = assemblerr_options(prm.use_mu_referencing = TRUE)) %>%
    expect_contains("K = THETA(1)") %>%
    expect_match("\\$THETA .*5")
})

test_that("prm logit distribution", {
  simple_model(prm = prm_logit_normal("k", mean_logit = 1, var_logit = 2)) %>%
    render(options = assemblerr_options(prm.use_mu_referencing = TRUE)) %>%
    expect_contains("MU_1 = LOG(THETA(1))/(1 - LOG(THETA(1)))") %>%
    expect_contains("LOGIT_K = MU_1 + ETA(1)") %>%
    expect_contains("K = EXP(LOGIT_K)/(1 + EXP(LOGIT_K))") %>%
    expect_match("\\$THETA .*1") %>%
    expect_contains("$OMEGA 2")
})


test_that("obs additive", {
  simple_model(obs = obs_additive(c ~ conc, var_add = 2)) %>%
    render() %>%
    expect_contains("C = CONC") %>%
    expect_contains("Y = C + EPS(1)") %>%
    expect_contains("$SIGMA 2")
})

test_that("obs proportional", {
  simple_model(obs = obs_proportional(c ~ conc, var_prop = 0.2)) %>%
    render() %>%
    expect_contains("C = CONC") %>%
    expect_contains("Y = C + C * EPS(1)") %>%
    expect_contains("$SIGMA 0.2")
})

test_that("obs combined", {
  simple_model(obs = obs_combined(c ~ conc, var_prop = 0.2, var_add = 2)) %>%
    render() %>%
    expect_contains("C = CONC") %>%
    expect_contains("Y = C + EPS(1) + C * EPS(2)") %>%
    expect_contains("$SIGMA 0.2") %>%
    expect_contains("$SIGMA 2")

})

test_that("obs without lhs", {
  simple_model(obs = obs_additive(~ conc)) %>%
    render() %>%
    expect_does_not_contain("C = CONC") %>%
    expect_contains("Y = CONC + EPS(1)") %>%
    expect_contains("$SIGMA")
})

test_that("adding variables from a dataset", {
  m <- simple_model(vars = NULL)
  local_create_nonmem_test_directory()
  df <- data.frame(ID = 1, TIME = 1, DV = 1, DOSE = 1, C0 = 1)
  write.csv(df, "data.csv", quote = FALSE, row.names = FALSE)
  m <- m +
    dataset(path = "data.csv")
  render(m) %>%
    expect_contains("$INPUT ID TIME DV DOSE") %>%
    expect_contains("$DATA data.csv IGNORE=@")
})

test_that("adding variables from a dataset with duplicated columns", {
  m <- simple_model(vars = NULL)
  local_create_nonmem_test_directory()
  df <- data.frame(ID = 1, TIME = 1, DV = 1, DOSE = 1, DOSE = 2, C0 = 1, check.names = FALSE)
  write.csv(df, "data.csv", quote = FALSE, row.names = FALSE)
  expect_warning(
    m <- m +
      dataset(path = "data.csv")
  )
  render(m) %>%
    expect_contains("$INPUT ID TIME DV DOSE DOSE_1") %>%
    expect_contains("$DATA data.csv IGNORE=@")
})



test_that("adding incompatible building block", {
  m <- simple_model()

  expect_warning(
    m + pk_absorption_fo()
  )
})

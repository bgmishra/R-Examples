library(precrec)

context("FT 2: Fortify curves")
# Test fortify(model, ...)

ft2_check_libs <- function() {
  if (requireNamespace("ggplot2", quietly = TRUE)) {
    TRUE
  } else {
    FALSE
  }
}

ft2_create_mscurves <- function() {
  s1 <- c(1, 2, 3, 4)
  s2 <- c(5, 6, 7, 8)
  s3 <- c(2, 4, 6, 8)
  scores <- join_scores(s1, s2, s3)

  l1 <- c(1, 0, 1, 1)
  l2 <- c(0, 1, 1, 1)
  l3 <- c(1, 1, 0, 1)
  labels <- join_labels(l1, l2, l3)

  mdat <- mmdata(scores, labels)
  evalmod(mdat)
}

ft2_create_smcurves <- function(raw_curves = FALSE) {
  s1 <- c(1, 2, 3, 4)
  s2 <- c(5, 6, 7, 8)
  s3 <- c(2, 4, 6, 8)
  scores <- join_scores(s1, s2, s3)

  l1 <- c(1, 0, 1, 1)
  l2 <- c(0, 1, 1, 1)
  l3 <- c(1, 1, 0, 1)
  labels <- join_labels(l1, l2, l3)

  mdat <- mmdata(scores, labels, expd_first = "dsids")
  evalmod(mdat, raw_curves = raw_curves)
}

ft2_create_mmcurves <- function(raw_curves = FALSE) {
  s1 <- c(1, 2, 3, 4)
  s2 <- c(5, 6, 7, 8)
  s3 <- c(2, 4, 6, 8)
  s4 <- c(2, 4, 6, 8)
  scores <- join_scores(s1, s2, s3, s4)

  l1 <- c(1, 0, 1, 1)
  l2 <- c(0, 1, 1, 1)
  l3 <- c(1, 1, 0, 1)
  l4 <- c(1, 1, 0, 1)
  labels <- join_labels(l1, l2, l3, l4)

  mdat <- mmdata(scores, labels, modnames = c("m1", "m2"), dsids = c(1, 2),
                 expd_first = "modnames")
  evalmod(mdat, raw_curves = raw_curves)
}

test_that("fortify sscurves", {
  if (!ft2_check_libs()) {
    skip("Libraries cannot be loaded")
  }

  data(P10N10)
  curves <- evalmod(scores = P10N10$scores, labels = P10N10$labels)

  curve_df <- ggplot2::fortify(curves)
  expect_true(is.list(curve_df))
})

test_that("fortify mscurves", {
  if (!ft2_check_libs()) {
    skip("Libraries cannot be loaded")
  }

  curves <- ft2_create_mscurves()

  curve_df <- ggplot2::fortify(curves)
  expect_true(is.list(curve_df))
})

test_that("fortify smcurves", {
  if (!ft2_check_libs()) {
    skip("Libraries cannot be loaded")
  }

  curves <- ft2_create_smcurves(raw_curves = TRUE)

  curve_df <- ggplot2::fortify(curves)
  expect_true(is.list(curve_df))
})

test_that("fortify mmcurves", {
  if (!ft2_check_libs()) {
    skip("Libraries cannot be loaded")
  }

  curves <- ft2_create_mmcurves(raw_curves = TRUE)

  curve_df <- ggplot2::fortify(curves)
  expect_true(is.list(curve_df))
})

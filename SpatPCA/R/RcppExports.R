# This file was generated by Rcpp::compileAttributes
# Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

tpm2 <- function(z, P, Phi) {
    .Call('SpatPCA_tpm2', PACKAGE = 'SpatPCA', z, P, Phi)
}

spatpcacv2_rcpp <- function(sxyr, Yr, M, K, tau1r, tau2r, gammar, nkr, maxit, tol, l2r) {
    .Call('SpatPCA_spatpcacv2_rcpp', PACKAGE = 'SpatPCA', sxyr, Yr, M, K, tau1r, tau2r, gammar, nkr, maxit, tol, l2r)
}

eigenest_rcpp <- function(phir, Yr, gamma, phi2r) {
    .Call('SpatPCA_eigenest_rcpp', PACKAGE = 'SpatPCA', phir, Yr, gamma, phi2r)
}


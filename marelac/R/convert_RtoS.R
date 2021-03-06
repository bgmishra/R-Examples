## -----------------------------------------------------------------------------
## Compute Salinity from Conductivity, Temperature, and Pressure
## -----------------------------------------------------------------------------

convert_RtoS <- function (R = 1, t = 25, p = max(0, P-1.013253), P = 1.013253) {

  P   <- p * 10 # uses decibar in calculations, hydrostatic pressure
  C_P <- (2.070e-5 + (-6.370e-10 + 3.989e-15 * P) * P) * P

  DT  <- t - 15.0
  R_T <- 0.6766097 + (2.00564e-2 + (1.104259e-4 +
         (-6.9698e-7 + 1.0031e-9 * t) * t) * t) * t
  A_T <- 4.215e-1 + -3.107e-3 * t
  B_T <- 1.0 + (3.426e-2 + 4.464e-4 * t) * t

  RT  <- R/(R_T * (1.0 + C_P / (B_T + A_T * R)))
  RT  <- sqrt(abs(RT))

  DS  <- (DT / (1 + 0.0162*DT) ) * (0.0005 + (-0.0056 + (-0.0066 +
         (-0.0375 + (0.0636 + -0.0144 * RT) * RT) * RT) * RT) * RT)

  return(0.0080 + (-0.1692 + (25.3851 + (14.0941 + (-7.0261 +
         2.7081 * RT) * RT) * RT) * RT) * RT + DS)
}


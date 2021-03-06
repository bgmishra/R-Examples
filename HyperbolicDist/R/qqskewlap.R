# QQ-plot for the skew-Laplace distribution
qqskewlap <- function(y, Theta, main = "Skew-Laplace Q-Q Plot",
                      xlab = "Theoretical Quantiles",
                      ylab = "Sample Quantiles",
                      plot.it = TRUE, line = TRUE, ...){
  if (has.na <- any(ina <- is.na(y))) {
    yN <- y
    y <- y[!ina]
  }
  if (0 == (n <- length(y))) 
    stop("y is empty or has only NAs")
  x <- qskewlap(ppoints(n), Theta)[order(order(y))]
  if (has.na) {
    y <- x
    x <- yN
    x[!ina] <- y
    y <- yN
  }
  if(plot.it) 
    plot(x, y, main = main, xlab = xlab, ylab = ylab, ...) 
    title(sub=paste("Theta = (",
          round(Theta[1], 3), "," , round(Theta[2], 3), ",",
          round(Theta[3], 3), ")", sep = ""))
  
  if(line) abline(0,1)
  
  invisible(list(x = x, y = y))
} ## End of qqskewlap()

### PP-plot for the skew-Laplace distribution
ppskewlap <- function(y, Theta, main = "Skew-Laplace P-P Plot",
                      xlab = "Uniform Quantiles",
                      ylab = "Probability-integral-transformed Data",
                      plot.it = TRUE, line = TRUE, ...){
  if (has.na <- any(ina <- is.na(y))) {
    yN <- y
    y <- y[!ina]
  }
  if(0 == (n <- length(y)))
    stop("data is empty")

  yvals <- pskewlap(y, Theta)
  xvals <- ppoints(n, a = 1/2)[order(order(y))]
  if (has.na) {
    y <- yvals
    x <- xvals
    yvals <- yN
    yvals[!ina] <- y
    xvals <- yN
    xvals[!ina] <- x
  }
  if (plot.it)
    plot(xvals, yvals, main = main, xlab = xlab, ylab = ylab,
         ylim = c(0,1), xlim = c(0,1), ...)
    title(sub=paste("Theta = (",
          round(Theta[1], 3), ",", round(Theta[2], 3), ",",
          round(Theta[3], 3), ")", sep = ""))
  
  if (line) abline(0,1)
  
  invisible(list(x = xvals, y = yvals))
} ## End of ppskewlap()


  


# 'There is more to the truth than the facts'


#' Description: Draw regression curve with smoothed error bars 
#' based on the Visually-Weighted Regression by Solomon M. Hsiang; see
#' http://www.fight-entropy.com/2012/07/visually-weighted-regression.html
#' The R implementation is based on Felix Schonbrodt's code from 
#' http://www.nicebread.de/visually-weighted-watercolor-plots-new-variants-please-vote/
#'
#' Arguments:
#'   @param formula formula
#'   @param data data
#'   @param main figure title
#'   @param B number bootstrapped smoothers
#'   @param shade plot the shaded confidence region?
#'   @param shade.alpha shade.alpha: should the CI shading fade out at 
#'          the edges? (by reducing alpha; 0 = no alpha decrease, 
#'	    0.1 = medium alpha decrease, 0.5 = strong alpha decrease)
#'   @param spag plot spaghetti lines?
#'   @param mweight should the median smoother be visually weighted?
#'   @param show.lm should the linear regresison line be plotted?
#'   @param show.median show median smoother
#'   @param median.col median color
#'   @param show.CI should the 95\% CI limits be plotted?
#'   @param method the fitting function for the spaghettis; default: loess
#'   @param bw define a default b/w-palette (TRUE/FALSE)
#'   @param slices number of slices in x and y direction for the shaded
#'     region. Higher numbers make a smoother plot, but takes longer to
#'     draw. I wouldn'T go beyond 500
#'   @param palette provide a custom color palette for the watercolors
#'   @param ylim restrict range of the watercoloring
#'   @param quantize either "continuous", or "SD". In the latter case, 
#'     we get three color regions for 1, 2, and 3 SD (an idea of John Mashey)
#'   @param ... further parameters passed to the fitting function, 
#'     in the case of loess, for example, "span = .9", or 
#'     "family = 'symmetric'"
#'
#' Returns:
#'   @return ggplot2 object
#'
#' @export 
#'
#' @importFrom reshape2 melt
#' @import dplyr
#' @import RColorBrewer
#' @import ggplot2
#'
#' @examples \dontrun{library(dplyr); library(RColorBrewer); 
#'   	     	      library(ggplot2); data(iris); 
#'		      p <- regression_plot(Sepal.Length ~ Sepal.Width, iris)}
#' @aliases vwReg
#' @references See citation("microbiome") 
#' @author Based on the original version from Felix Schonbrodt. 
#'         Modified by Leo Lahti \email{microbiome-admin@@googlegroups.com}
#' @keywords utilities

regression_plot <- function(formula, data, main=NULL, B=1000, shade=TRUE, shade.alpha=.1, spag=FALSE, mweight=TRUE, show.lm=FALSE, show.median = TRUE, median.col = "white", show.CI=FALSE, method=loess, bw=FALSE, slices=200, palette=colorRampPalette(c("#FFEDA0", "#DD0000"), bias=2)(20), ylim=NULL, quantize = "continuous", ...) {

  # Circumvent warnings
  . <- NULL
  aes <- NULL

  # ------------------

  # Circumvent global variable binding warnings
  x <- NA
  y <- NA
  dens.scaled <- NA
  alpha.factor <- NA
  value <- NA
  group <- NA
  M <- NA
  w3 <- NA
  UL <- NA
  LL <- NA

  # ------------------

  IV <- all.vars(formula)[2]
  DV <- all.vars(formula)[1]

  data$IV <- data[[IV]]
  data$DV <- data[[DV]]
  data[[IV]] <- data[[DV]] <- NULL

  data <- arrange(data, IV) %>% 
          select(IV, DV) %>%
	  filter(!is.na(IV) & !is.na(DV)) %>%
	  filter(!is.infinite(IV) & !is.infinite(DV))
  # na.omit(data[order(data[[IV]]), c(IV, DV)])
  if (bw) palette <- colorRampPalette(c("#EEEEEE", "#999999", "#333333"), bias=2)(20)


  message("Computing boostrapped smoothers ...")
  newx <- data.frame(seq(min(data$IV), max(data$IV), length=slices))
  colnames(newx) <- "IV"

  l0.boot <- matrix(NA, nrow=nrow(newx), ncol=B)
  formula <- DV ~ IV
  l0 <- method(formula, data)
  for (i in 1:B) {
    data2 <- data[sample(nrow(data), replace=TRUE), ]
    data2 <- data2[order(data2$IV), ]

    if (class(l0)=="loess") {
      m1 <- method(formula, data2, control = loess.control(surface = "i", statistics="a", trace.hat="a"), ...)
    } else {
      m1 <- method(formula, data2, ...)
    }
      l0.boot[, i] <- predict(m1, newdata=newx)
    }

    # compute median and CI limits of bootstrap

    CI.boot <- t(apply(l0.boot, 1, function(x) quantile(x, prob=c(.025, .5, .975, pnorm(c(-3, -2, -1, 0, 1, 2, 3))), na.rm=TRUE)))
    colnames(CI.boot)[1:10] <- c("LL", "M", "UL", paste0("SD", 1:7))
    CI.boot <- as.data.frame(CI.boot)

    CI.boot$x <- newx[, 1]
    CI.boot$width <- CI.boot$UL - CI.boot$LL

    # scale the CI width to the range 0 to 1 and flip it (bigger numbers = narrower CI)
    CI.boot$w2 <- (CI.boot$width - min(CI.boot$width))
    CI.boot$w3 <- 1-(CI.boot$w2/max(CI.boot$w2))

    message("convert bootstrapped spaghettis to long format")
    b2 <- melt(l0.boot)
    b2$x <- newx[,1]
    colnames(b2) <- c("index", "B", "value", "x")

    p1 <- ggplot(data, aes_string(x="IV", y="DV")) + theme_bw()

    if (shade) {
       quantize <- match.arg(quantize, c("continuous", "SD"))

       if (quantize == "continuous") {
       	  message("Computing density estimates for each vertical cut ...")
      	  flush.console()
      	  if (is.null(ylim)) {
          min_value <- min(min(l0.boot, na.rm=TRUE), min(data$DV, na.rm=TRUE))
          max_value <- max(max(l0.boot, na.rm=TRUE), max(data$DV, na.rm=TRUE))
          ylim <- c(min_value, max_value)
      }

      message("vertical cross-sectional density estimate")

      d2 <- b2[, c("x", "value")] %>% group_by(x) %>% do(data.frame(density(.$value, na.rm = TRUE, n = slices, from=ylim[[1]], to=ylim[[2]])[c("x", "y")]))
      #d2 <- b2[, c("x", "value")] %>% group_by(x) %>% { density(.$value, na.rm = TRUE, n = slices, from=ylim[[1]], to=ylim[[2]])[c("x", "y")] }
      d2 <- data.frame(d2)
      names(d2) <- c("y", "dens")
      d2$x <- rep(unique(b2$x), each = slices)
      d2 <- d2[, c("x", "y", "dens")]

      # Was
      #d2 <- ddply(b2[, c("x", "value")], .(x), function(df) {
      #  res <- data.frame(density(df$value, na.rm = TRUE, n = slices, from=ylim[[1]], to=ylim[[2]])[c("x", "y")]);
      #  colnames(res) <- c("y", "dens");
      #  return(res)
      #}, .progress=.progress)

      maxdens <- max(d2$dens)
      mindens <- min(d2$dens)
      d2$dens.scaled <- (d2$dens - mindens)/maxdens

      message("Tile approach")
      d2$alpha.factor <- d2$dens.scaled^shade.alpha
      p1 <- p1 + geom_tile(data=d2, aes(x=x, y=y, fill=dens.scaled, alpha=alpha.factor)) 
      p1 <- p1 + scale_fill_gradientn("dens.scaled", colours=palette) 
      p1 <- p1 + scale_alpha_continuous(range = c(0.001, 1))
    }   

    if (quantize == "SD") {
      message("Polygon approach")
      SDs <- melt(CI.boot[, c("x", paste0("SD", 1:7))], id.vars="x")
      count <- 0
      d3 <- data.frame()
      col <- c(1,2,3,3,2,1)
      for (i in 1:6) {
        seg1 <- SDs[SDs$variable == paste0("SD", i), ]
	seg2 <- SDs[SDs$variable == paste0("SD", i+1), ]
	seg <- rbind(seg1, seg2[nrow(seg2):1, ])
	seg$group <- count
	seg$col <- col[i]
	count <- count + 1
	d3 <- rbind(d3, seg)
     }

     p1 <- p1 + geom_polygon(data=d3, aes(x=x, y=value, color=NULL, fill=col, group=group)) 
     p1 <- p1 + scale_fill_gradientn("dens.scaled", colours=palette, values=seq(-1, 3, 1))
     }
  }

  message("Build ggplot figure ...")
  flush.console()
  if (spag) {

    p1 <- p1 + geom_path(data=b2, aes(x=x, y=value, group=B), size=0.7, alpha=10/B, color="darkblue")

  }

  if (show.median) {
    if (mweight) {

      p1 <- p1 + geom_path(data=CI.boot, aes(x=x, y=M, alpha=w3^3), size=.6, linejoin="mitre", color=median.col)
    } else {
      p1 <- p1 + geom_path(data=CI.boot, aes(x=x, y=M), size = 0.6, linejoin="mitre", color=median.col)
    }
  }

  #message("Confidence limits")
  if (show.CI) {
    p1 <- p1 + geom_path(data=CI.boot, aes(x=x, y=UL, group=B), size=1, color="red")
    p1 <- p1 + geom_path(data=CI.boot, aes(x=x, y=LL, group=B), size=1, color="red")
  }

  #message("plain linear regression line")
  if (show.lm) {
    p1 <- p1 + geom_smooth(method="lm", color="darkgreen", se=FALSE)
  }

  p1 <- p1 + geom_point(size=1, shape=21, fill="white", color="black")

  #message("title")
  if (is.null(main)) {
    p1 <- p1 + ggtitle(main)
  }

  #message("guides")
  p <- p1 + guides(color = "none") 

  p <- p + xlab(IV)
  p <- p + ylab(DV)

  p 

}




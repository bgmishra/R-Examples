## ---- include=FALSE, echo=FALSE------------------------------------------
library(knitr)
opts_chunk$set(fig.path = 'figure/pos-', fig.align = 'center', fig.show = 'hold',
               fig.width = 7, fig.height = 4)
options(warnPartialMatchArgs = FALSE)

## ------------------------------------------------------------------------
library(ggplot2)
library(ggpmisc)
library(xts)
library(lubridate)

## ------------------------------------------------------------------------
class(austres)
austres.df <- try_data_frame(austres)
class(austres.df)
lapply(austres.df, "class")
head(austres.df, 4)

## ------------------------------------------------------------------------
austres.df <- try_data_frame(austres, as.numeric = TRUE)
lapply(austres.df, "class")
head(austres.df, 4)

## ------------------------------------------------------------------------
class(lynx)
lynx.df <- try_data_frame(lynx)
class(lynx.df)
lapply(lynx.df, "class")
head(lynx.df, 3)

## ------------------------------------------------------------------------
lynx.df <- try_data_frame(lynx, "year")
head(lynx.df, 3)

## ------------------------------------------------------------------------
lynx_n.df <- try_data_frame(lynx, "year", as.numeric = TRUE)
lapply(lynx_n.df, "class")
head(lynx_n.df, 3)

## ------------------------------------------------------------------------
try_data_frame(1:5)

## ------------------------------------------------------------------------
try_data_frame(letters[1:5])

## ------------------------------------------------------------------------
try_data_frame(factor(letters[1:5]))

## ------------------------------------------------------------------------
try_data_frame(list(x = rep(1,5), y = 1:5))

## ------------------------------------------------------------------------
try_data_frame(data.frame(x = rep(1,5), y = 1:5))

## ------------------------------------------------------------------------
try_data_frame(matrix(1:10, ncol = 2))

## ------------------------------------------------------------------------
ggplot(lynx.df, aes(time, V.lynx)) + geom_line() + 
  stat_peaks(colour = "red") +
  stat_peaks(geom = "text", colour = "red", vjust = -0.5) +
  ylim(-100, 7300)

## ------------------------------------------------------------------------
ggplot(lynx_n.df, aes(time, V.lynx)) + geom_line() + 
  stat_peaks(colour = "red") +
  stat_peaks(geom = "text", colour = "red", vjust = -0.5) +
  ylim(-100, 7300)

## ------------------------------------------------------------------------
ggplot(lynx.df, aes(time, V.lynx)) + geom_line() + 
  stat_peaks(colour = "red") +
  stat_peaks(geom = "text", colour = "red", vjust = -0.5, x.label.fmt = "%Y") +
  stat_valleys(colour = "blue") +
  stat_valleys(geom = "text", colour = "blue", vjust = 1.5, x.label.fmt = "%Y") +
  ylim(-100, 7300)

## ------------------------------------------------------------------------
ggplot(lynx_n.df, aes(time, V.lynx)) + geom_line() + 
  stat_peaks(colour = "red") +
  stat_peaks(geom = "text", colour = "red", vjust = -0.5, x.label.fmt = "%4.0f") +
  stat_valleys(colour = "blue") +
  stat_valleys(geom = "text", colour = "blue", vjust = 1.5, x.label.fmt = "%4.0f") +
  ylim(-100, 7300)

## ------------------------------------------------------------------------
ggplot(lynx.df, aes(time, V.lynx)) + geom_line() + 
  stat_peaks(colour = "red") +
  stat_peaks(geom = "text", colour = "red", angle = 66,
             hjust = -0.1, x.label.fmt = "%Y") +
  ylim(NA, 7800)

## ------------------------------------------------------------------------
ggplot(lynx.df, aes(time, V.lynx)) + geom_line() + 
  stat_peaks(colour = "red") +
  stat_peaks(geom = "rug", colour = "red") +
  stat_valleys(colour = "blue") +
  stat_valleys(geom = "rug", colour = "blue")

## ------------------------------------------------------------------------
set.seed(4321)
# generate artificial data
x <- 1:100
y <- (x + x^2 + x^3) + rnorm(length(x), mean = 0, sd = mean(x^3) / 4)
my.data <- data.frame(x, 
                      y, 
                      group = c("A", "B"), 
                      y2 = y * c(0.5,2),
                      block = c("a", "a", "b", "b"))

## ------------------------------------------------------------------------
formula <- y ~ poly(x, 3, raw = TRUE)
ggplot(my.data, aes(x, y)) +
  geom_point() +
  geom_smooth(method = "lm", formula = formula) +
  stat_poly_eq(formula = formula, parse = TRUE)

## ------------------------------------------------------------------------
formula <- y ~ poly(x, 3, raw = TRUE)
ggplot(my.data, aes(x, y)) +
  geom_point() +
  geom_smooth(method = "lm", formula = formula) +
  stat_poly_eq(aes(label = ..adj.rr.label..), formula = formula, 
               parse = TRUE)

## ------------------------------------------------------------------------
formula <- y ~ poly(x, 3, raw = TRUE)
ggplot(my.data, aes(x, y)) +
  geom_point() +
  geom_smooth(method = "lm", formula = formula) +
  stat_poly_eq(aes(label = ..AIC.label..), 
               formula = formula, 
               parse = TRUE)

## ------------------------------------------------------------------------
formula <- y ~ poly(x, 3, raw = TRUE)
ggplot(my.data, aes(x, y)) +
  geom_point() +
  geom_smooth(method = "lm", formula = formula) +
  stat_poly_eq(aes(label = ..eq.label..), formula = formula, 
               parse = TRUE)

## ------------------------------------------------------------------------
formula <- y ~ poly(x, 3, raw = TRUE)
ggplot(my.data, aes(x, y)) +
  geom_point() +
  geom_smooth(method = "lm", formula = formula) +
  stat_poly_eq(aes(label =  paste(..eq.label.., ..adj.rr.label.., sep = "~~~~")),
               formula = formula, parse = TRUE)

## ------------------------------------------------------------------------
formula <- y ~ poly(x, 3, raw = TRUE)
ggplot(my.data, aes(x, y)) +
  geom_point() +
  geom_smooth(method = "lm", formula = formula) +
  stat_poly_eq(aes(label = paste("atop(", ..AIC.label.., ",", ..BIC.label.., ")", sep = "")), 
               formula = formula, 
               parse = TRUE)

## ------------------------------------------------------------------------
formula <- y ~ poly(x, 3, raw = TRUE)
ggplot(my.data, aes(x, y)) +
  geom_point() +
  geom_smooth(method = "lm", formula = formula) +
  stat_poly_eq(aes(label = ..eq.label..),
               eq.with.lhs = FALSE,
               formula = formula, parse = TRUE)

## ------------------------------------------------------------------------
formula <- y ~ poly(x, 3, raw = TRUE)
ggplot(my.data, aes(x, y)) +
  geom_point() +
  geom_smooth(method = "lm", formula = formula) +
  stat_poly_eq(aes(label = ..eq.label..),
               eq.with.lhs = "italic(hat(y))~`=`~",
               formula = formula, parse = TRUE)

## ------------------------------------------------------------------------
formula <- y ~ poly(x, 3, raw = TRUE)
ggplot(my.data, aes(x, y)) +
  geom_point() +
  geom_smooth(method = "lm", formula = formula) +
  labs(x = expression(italic(z)), y = expression(italic(h)) ) + 
  stat_poly_eq(aes(label = ..eq.label..),
               eq.with.lhs = "italic(h)~`=`~",
               eq.x.rhs = "~italic(z)",
               formula = formula, parse = TRUE)

## ------------------------------------------------------------------------
formula <- y ~ poly(x, 2, raw = TRUE)
ggplot(my.data, aes(x, log10(y + 1e6))) +
  geom_point() +
  geom_smooth(method = "lm", formula = formula) +
  stat_poly_eq(aes(label = ..eq.label..),
               eq.with.lhs = "plain(log)[10](italic(y)+10^6)~`=`~",
               formula = formula, parse = TRUE)

## ------------------------------------------------------------------------
formula <- y ~ poly(x, 5, raw = TRUE)
ggplot(my.data, aes(x, y)) +
  geom_point() +
  geom_smooth(method = "lm", formula = formula) +
  stat_poly_eq(aes(label = ..eq.label..), formula = formula, parse = TRUE)

## ------------------------------------------------------------------------
formula <- y ~ x + I(x^2) + I(x^3) - 1
ggplot(my.data, aes(x, y)) +
  geom_point() +
  geom_smooth(method = "lm", formula = formula) +
  stat_poly_eq(aes(label = ..eq.label..), formula = formula, 
               parse = TRUE)

## ------------------------------------------------------------------------
formula <- y ~ poly(x, 3, raw = TRUE)
ggplot(my.data, aes(x, y2)) +
  geom_point() +
  geom_smooth(method = "lm", formula = formula) +
  stat_poly_eq(aes(label = ..eq.label..), size = rel(3),
               formula = formula, parse = TRUE,
               label.x = 0, label.y = 2e6) +
  facet_wrap(~group)

## ------------------------------------------------------------------------
formula <- y ~ poly(x, 3, raw = TRUE)
ggplot(my.data, aes(x, y2)) +
  geom_point() +
  geom_smooth(method = "lm", formula = formula) +
  stat_poly_eq(aes(label = ..eq.label..), size = rel(3),
               formula = formula, parse = TRUE) +
  facet_wrap(~group, scales = "free_y")

## ------------------------------------------------------------------------
formula <- y ~ poly(x, 3, raw = TRUE)
ggplot(my.data, aes(x, y2, colour = group)) +
  geom_point() +
  geom_smooth(method = "lm", formula = formula) +
  stat_poly_eq(aes(label = ..eq.label..),
               formula = formula, parse = TRUE,
               label.x = 0, label.y = c(1.8e6, 2e6)) +
  theme_bw()

## ------------------------------------------------------------------------
formula <- y ~ poly(x, 3, raw = TRUE)
ggplot(my.data, aes(x, y2, colour = group)) +
  geom_point() +
  geom_smooth(method = "lm", formula = formula) +
  stat_poly_eq(aes(label = ..eq.label..),
               formula = formula, parse = TRUE,
               label.x = 0, label.y = 2e6,
               vjust = c(1.2, 0)) +
  theme_bw()

## ------------------------------------------------------------------------
formula <- y ~ poly(x, 3, raw = TRUE)
ggplot(my.data, aes(x, y2, colour = group, fill = block)) +
  geom_point(shape = 21, size = rel(3)) +
  geom_smooth(method = "lm", formula = formula) +
  stat_poly_eq(aes(label = ..rr.label..), size = rel(3),
               geom = "label", alpha = 0.2,
               formula = formula, parse = TRUE,
               label.x = 0, label.y = c(5e5, 5e5, 2e6, 2e6),
               vjust = c(1.2,0,1.2,0)) +
  facet_wrap(~group, scales = "free_y") +
  theme_bw()

## ------------------------------------------------------------------------
formula <- y ~ poly(x, 3, raw = TRUE)
ggplot(my.data, aes(x, y2, fill = block)) +
  geom_point(shape = 21, size = rel(3)) +
  geom_smooth(method = "lm", formula = formula) +
  stat_poly_eq(aes(label = ..rr.label..), size = rel(3),
               geom = "label", alpha = 0.33,
               formula = formula, parse = TRUE,
               label.x = 0,
               vjust = c(1.2,0,1.2,0)) +
  facet_wrap(~group, scales = "free_y") +
  theme_bw()

## ------------------------------------------------------------------------
ggplot(my.data, aes(x, y)) + stat_debug_group()

## ------------------------------------------------------------------------
ggplot(my.data, aes(x, y)) + geom_point() + stat_debug_group()

## ------------------------------------------------------------------------
ggplot(my.data, aes(x, y)) + geom_point() + stat_debug_panel()

## ------------------------------------------------------------------------
ggplot(my.data, aes(x, y, colour = group)) + geom_point() + 
  stat_debug_group()

## ------------------------------------------------------------------------
ggplot(my.data, aes(x, y, colour = group)) + geom_point() + 
  stat_debug_panel()

## ------------------------------------------------------------------------
ggplot(my.data, aes(x, y, shape = group)) + geom_point() + 
  stat_debug_group()

## ------------------------------------------------------------------------
ggplot(my.data, aes(x, y, shape = group)) + geom_point() + 
  stat_debug_group(geom = "label", vjust = c(-0.5,1.5))

## ------------------------------------------------------------------------
ggplot(my.data, aes(x, y)) + geom_point() + 
  stat_debug_group(summary.fun = summary)

## ------------------------------------------------------------------------
ggplot(my.data, aes(x, y)) + geom_point() + 
  stat_debug_group(summary.fun = head)

## ------------------------------------------------------------------------
ggplot(my.data, aes(x, y)) + geom_point() + 
  stat_debug_group(summary.fun = nrow)

## ------------------------------------------------------------------------
ggplot(my.data, aes(x, y)) + geom_point() + 
  stat_debug_group(summary.fun = dplyr::as_data_frame)

## ------------------------------------------------------------------------
ggplot(my.data, aes(x, y)) + geom_point() + 
  stat_debug_group(summary.fun = head, summary.fun.args = list(n = 3))

## ---- eval=FALSE---------------------------------------------------------
#  ggplot(my.data, aes(x, y)) + geom_point() +
#    stat_debug_group(summary.fun = function(x) {x})

## ------------------------------------------------------------------------
ggplot(my.data, aes(x, y, colour = group)) + geom_point() + 
  stat_debug_group(summary.fun = head, summary.fun.args = list(n = 3))

## ------------------------------------------------------------------------
ggplot(my.data, aes(x, y, colour = group)) + geom_point() + 
  stat_debug_group(summary.fun = nrow) +
  facet_wrap(~block)

## ------------------------------------------------------------------------
ggplot(my.data, aes(x, y, colour = group)) + geom_point() + 
  stat_debug_panel(summary.fun = nrow) +
  facet_wrap(~block)

## ------------------------------------------------------------------------
ggplot(my.data, aes(x, y, colour = group)) + geom_point() + 
  geom_debug(summary.fun = head)

## ------------------------------------------------------------------------
ggplot(my.data, aes(x, y, colour = group)) + geom_point() + 
  stat_peaks(span = NULL,
             geom = "debug", 
             summary.fun = function(x) {x}, 
             summary.fun.args = list())

## ------------------------------------------------------------------------
ggplot(my.data, aes(x, y, colour = group)) + geom_null()


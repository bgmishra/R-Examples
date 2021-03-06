library(robustbase)

if (FALSE) {
    
    ## artificial data example, also used in example(outlierStats):
    data <- expand.grid(grp1 = letters[1:5], grp2 = letters[1:5], rep=1:3)
    set.seed(101)
    data$y <- c(rt(nrow(data), 1))
    control <- lmrob.control(method = "SMDM",
                             compute.outlier.stats = c("S", "MM", "SMD", "SMDM"))
    set.seed(2)
    fit1 <- lmrob(y ~ grp1*grp2, data, control = control)
    fit2 <- lmrob(y ~ grp1*grp2, data, setting = "KS2014")
    
    fit1$ostats ## SMDM
    fit1$init$ostats ## SMD
    fit1$init$init$ostats ## SM
    fit1$init$init$init.S$ostats ## S
    
}


## real data example that is prone for local exact fit:
## NOxEmissions example
## use a subset:
selDays <- c(
    ## days ranked according to number of outliers
    ## (according to main effects model of the full data):
    "403", "407", "693", "405", "396", "453", "461",
    ## "476", "678", "730", "380", "406", "421", "441"
    ## ,"442", "454", "462", "472", "480", "488"
    ## some other days
    ## "712", "503", "666", "616", "591", "552",
    "624", "522", "509", "388", "606", "580",
    "573", "602", "686", "476", "708", "600", "567"
    )

opts <- options(warn=2)
## this happens for specific seeds only
set.seed(18)
res <- try(lmrob(LNOx ~ (LNOxEm + sqrtWS)*julday, NOxEmissions,
                 julday %in% selDays, setting='KS2011'))
## this should give a warning and suggest setting KS2014
options(opts)
stopifnot(is(res, "try-error"), grepl("setting", res))

if (FALSE) {

    ## some other datasets:
    ## ambienNOxCH
    data <- cbind(stack(ambientNOxCH[,-1]), day = factor(ambientNOxCH[, 1]))

    fit <- lmrob(values ~ ind + day, data, setting="KS2014", fast.s.large.n = Inf)
    summary(fit)
    
    ## CrohnD produces an error as well
    set.seed(11)
    fit <- lmrob(BMI ~ age*country*sex*treat, CrohnD)
    summary(fit)
    fit$ostats
    
    ## wagnerGrowth
    set.seed(4)
    fit <- lmrob(y ~ ., data=wagnerGrowth)
    fit$ostats
    fit <- lmrob(y ~ ., data=wagnerGrowth, setting="KS2014")

}

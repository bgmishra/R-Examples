# 2010-05-26  - added a spline to logitP
# 2014-09-01  CJS removed prompts; jags; engine revised
#
# This is a demonstration of how to call the Time Stratified Petersen with Diagonal Entries (TSPDE) program
# It is based on the analysis of California Junction City 2003 Chinook data and is the example used
# in the Trinity River Project. 
#
# In this model, a spline curve is fit to the logitP to capture some of the non-random trend over time
# this is present when a simple model is fit.
#
# In each julian week j, n1[j] are marked and released above the rotary screw trap.
# Of these, m2[j] are recaptured. All recaptures take place in the week of release, i.e. the matrix of
# releases and recoveries is diagonal.
# The n1[j] and m2[j] establish the capture efficiency of the trap.
#
# At the same time, u2[j] unmarked fish are captured at the screw trap.
# The simple stratified Petersen estimator would inflate the u2[j] buy 1/capture efficiency[j]
# giving U2[j] = total fish passing the trap in julian week [j] = u2[j] * n1[j]/ m2[j].
#
# The program assumes that the trap was operating all days of the week. The sampfrac[j] variable
# gives the proportion of days the trap was operating. For example, if the trap was operating for 3 of the
# 7 days in a week, then sampfrac[j]<- 3/7
#
#
# Notes:
#    - the number of recaptures in sample week 33 (julian week 41) is far too low. 
#      This leads to an estimate of almost 13 million fish from the simple stratified Petersen. 
#      Consequently, the recaptures for this
#      week are set to missing and the program will interpolate the number of fish for this week
#
#    - the number of days operating is 8 in sample weeks 2 (julian week 10) and 
#      6 in sample week 3 (julian week 11). The 8 days in sample week 2 is "real" as
#      the code used on the marked fish was used for 8 days. The program will automatically 
#      "reduce" the number of unmarked fish captured in this week to a "7" day week 
#      and will increase the number of unmarked fish captured in week 3 to "7" days as well. 
# 
#  The program tries to fit a single spline to the entire dataset. However, in julian weeks
#  23 and 40, hatchery released fish started to arrive at the trap resulting in sudden jump
#  in abundance. The jump.after vector gives the julian weeks just BEFORE the suddent jump,
#  i.e. the spline is allowed to jump AFTER the julian weeks in jump.after.
#
#  The vector bad.m2 indicates which julian weeks something went wrong. For example, the
#  number of recoveries in julian week 41 is far below expectations and leads to impossible
#  Petersen estimate for julian week 41.
# 
#  The prefix is used to identify the output files for this run.
#  The title  is used to title the output.

if(file.access("demo-TSPDE-spline-in-logitP")!=0){ 
   dir.create("demo-TSPDE-spline-in-logitP", showWarnings=TRUE)}  # Test and then create the directory
setwd("demo-TSPDE-spline-in-logitP")

library("BTSPAS")

# Get the data. In many cases, this is stored in a *.csv file and read into the program
# using a read.csv() call. In this demo, the raw data is assigned directly as a vector.
#

# Indicator for the week.
demo.jweek <- c(9,   10,   11,   12,   13,   14,   15,   16,   17,   18,
          19,   20,   21,   22,   23,   24,   25,   26,   27,   28, 
          29,   30,   31,   32,   33,   34,   35,   36,   37,   38,
          39,   40,   41,   42,   43,   44,   45,   46)

# Number of marked fish released in each week.
demo.n1 <- c(   0, 1465, 1106,  229,   20,  177,  702,  633, 1370,  283,
         647,  276,  277,  333, 3981, 3988, 2889, 3119, 2478, 1292,
        2326, 2528, 2338, 1012,  729,  333,  269,   77,   62,   26,
          20, 4757, 2876, 3989, 1755, 1527,  485,  115)

# Number of marked fish recaptured in the week of release. No marked fish
# are recaptured outside the week of release.
demo.m2 <- c(   0,   51,  121,   25,    0,   17,   74,   94,   62,   10,
          32,   11,   13,   15,  242,   55,  115,  198,   80,   71, 
         153,  156,  275,  101,   66,   44,   33,    7,    9,    3,
           1,  188,    8,   81,   27,   30,   14,    4)

# Number of unmarked fish captured at the trap in each week.
demo.u2 <- c(4135,10452, 2199,  655,  308,  719,  973,  972, 2386,  469,
         897,  426,  407,  526,39969,17580, 7928, 6918, 3578, 1713, 
        4212, 5037, 3315, 1300,  989,  444,  339,  107,   79,   41,
          23,35118,34534,14960, 3643, 1811,  679,  154)

# What fraction of the week was sampled?
demo.sampfrac<-c(3,   8,    6,    7,    7,    7,    7,    7,    7,    7,
            7,   7,    7,    7,    7,    7,    7,    7,    7,    7,
            6,   7,    7,    7,    7,    7,    7,    7,    7,    7,
            7,   7,    7,    7,    7,    7,    7,    5)/7

# After which weeks is the spline allowed to jump?
demo.jump.after <- c(22,39)  # julian weeks after which jump occurs

# Which julian weeks have "bad" recapture values. These will be set to missing and estimated.
demo.bad.m2     <- c(41)   # list julian week with bad m2 values

# The prefix for the output files:
demo.prefix <- "demo-JC-2003-CH-TSPDE-sp-logitP" 

# Title for the analysis
demo.title <- "Junction City 2003 Chinook - spline in logit P "

# Create a spline basis for the logitP effects
demo.cov <- bs(1:length(demo.n1), df=floor(length(demo.n1)/4), intercept=TRUE)


cat("*** Starting ",demo.title, "\n\n")

# Make the call to fit the model and generate the output files
demo.jc.2003.ch.tspde.sp.logitP <- TimeStratPetersenDiagError_fit(
                  title=demo.title,
                  prefix=demo.prefix,
                  time=demo.jweek,
                  n1=demo.n1, 
                  m2=demo.m2, 
                  u2=demo.u2,
                  logitP.cov=demo.cov,
                  sampfrac=demo.sampfrac,
                  jump.after=demo.jump.after,
                  bad.m2=demo.bad.m2,
		  #engine="openbugs",  # show how to call openbugs
                  debug=TRUE  # this generates only 10,000 iterations of the MCMC chain for checking.
                  )

# Rename files that were created.

file.copy("data.txt",       paste(demo.prefix,".data.txt",sep=""),      overwrite=TRUE)
file.copy("CODAindex.txt",  paste(demo.prefix,".CODAindex.txt",sep=""), overwrite=TRUE)
file.copy("CODAchain1.txt", paste(demo.prefix,".CODAchain1.txt",sep=""),overwrite=TRUE)
file.copy("CODAchain2.txt", paste(demo.prefix,".CODAchain2.txt",sep=""),overwrite=TRUE)
file.copy("CODAchain3.txt", paste(demo.prefix,".CODAchain3.txt",sep=""),overwrite=TRUE)
file.copy("inits1.txt",     paste(demo.prefix,".inits1.txt",sep=""),    overwrite=TRUE)
file.copy("inits2.txt",     paste(demo.prefix,".inits2.txt",sep=""),    overwrite=TRUE)
file.copy("inits3.txt",     paste(demo.prefix,".inits3.txt",sep=""),    overwrite=TRUE)

file.remove("data.txt"       )       
file.remove("CODAindex.txt"  )
file.remove("CODAchain1.txt" )
file.remove("CODAchain2.txt" )
file.remove("CODAchain3.txt" )
file.remove("inits1.txt"     )
file.remove("inits2.txt"     )
file.remove("inits3.txt"     )

demo.plot_logitP <- function(title, results){
# create a special plot of the spline for logitP and overlay with the actual logitP
   
   # compute the spline curve for logitP. Don't forget that last beta term is a dummy term
   spline.curve <- results$data$logitP.cov %*% results$mean$beta.logitP[1:ncol(results$data$logitP.cov)]

   min_logitP <- 100
   max_logitP <- -100

   Nstrata <- length(results$data$n1)
   raw_logitP <- logit((results$data$m2+1)/(results$data$n1+2))        # based on raw data
   raw_logitP[ results$data$n1 ==0] <- NA
   min_logitP <- min( c(min_logitP, raw_logitP), na.rm=TRUE)
   max_logitP <- max( c(max_logitP, raw_logitP), na.rm=TRUE)

   # which rows contain the logitP[xx] ?
   results.row.names <- rownames(results$summary)
   logitP.row.index    <- grep("^logitP", results.row.names)
   est_logitP<- results$summary[logitP.row.index,]
   min_logitP <- min( c(min_logitP, est_logitP[,"mean"]), spline.curve, na.rm=TRUE)
   max_logitP <- max( c(max_logitP, est_logitP[,"mean"]), spline.curve, na.rm=TRUE)
   min_logitP <- min( c(min_logitP, est_logitP[,"2.5%"]), na.rm=TRUE)
   max_logitP <- max( c(max_logitP, est_logitP[,"2.5%"]), na.rm=TRUE)
   min_logitP <- min( c(min_logitP, est_logitP[,"97.5%"]),na.rm=TRUE)
   max_logitP <- max( c(max_logitP, est_logitP[,"97.5%"]),na.rm=TRUE)

   main.title <- paste(title,"\nPlot of logit(p[i]) with 95% credible intervals")
   sub.title <- paste("Dashed line is fitted spline covariate")
   plot(results$data$time, raw_logitP, 
       main=main.title,
       sub=sub.title,
       ylab='logit(p[i])', xlab='Stratum', ylim=c(min_logitP,max_logitP))  # initial points on log scale.

   # plot the posterior mean of the logitP if there is only one column for a covariate
   points(results$data$time, est_logitP[,"mean"],type="p", pch=16) # the final estimates
   lines (results$data$time, est_logitP[,"mean"])  # join the mean of the fitted logitP
 
   # plot the 2.5 -> 97.5 posterior values
   segments(results$data$time, est_logitP[,"2.5%"], results$data$time, est_logitP[,"97.5%"])

   # add the spline curve for logitP
   lines(results$data$time, spline.curve,lty=2)  # plot the spline curve

}

pdf(file=paste(demo.prefix,"-logitP-spline.pdf",sep=""))
demo.plot_logitP(title=demo.title, results=demo.jc.2003.ch.tspde.sp.logitP)
dev.off()


 
# save the results in a data dump that can be read in later using the load() command.
# Contact Carl Schwarz (cschwarz@stat.sfu.ca) for details.
save(list=c("demo.jc.2003.ch.tspde.sp.logitP"), file="demo-jc-2003-ch-tspde-sp-logitP-saved.Rdata")  # save the results from this run

cat("\n\n\n ***** FILES and GRAPHS saved in \n    ", getwd(), "\n\n\n")
print(dir())

# move up the directory
setwd("..")

cat("\n\n\n ***** End of Demonstration *****\n\n\n")


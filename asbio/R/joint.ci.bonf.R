joint.ci.bonf<-function(model,conf=.95){
bk<-model$coefficients
p<-length(bk)
n<-length(model$residuals)
SE<-summary(model)$coefficients[,2]
B<-qt(1-((1-conf)/(2*p)),n-p)
margin<-B*SE
CI<-data.frame(lower=bk-margin,upper=bk+margin)
ends<-c((1-conf)/2,1-((1-conf)/2))*100
names(CI)<-c(paste(ends[1],"%"),paste(ends[2],"%"))
CI
}
exp_par_mult <-
function (table){
fit.glm<-glm(count~.^3, data=table, family=poisson)
mu_Y<-exp(fit.glm$coef[4] )
mu_XY<-exp(fit.glm$coef[6] )
mu_ZY<-exp(fit.glm$coef[7] )
mu_XZY<-exp(fit.glm$coef[8] )
a<-table$count[1]+table$count[5]
b<-table$count[2]+table$count[6]
c<-table$count[3]+table$count[7]
d<-table$count[4]+table$count[8]
tableXZ<-data.frame(expand.grid( 
X=factor(c("0","1"),levels=c("0","1")), 
 Z=factor(c("0","1"),levels=c("0","1"))), 
 count=c(a,b,c,d))
fit.glmXZ<-glm(count~.^2, data=tableXZ, family=poisson)
lmu_c_Z<-summary(fit.glmXZ)$coef[3,] 
mu_c_Z<-exp(summary(fit.glmXZ)$coef[3]) 
lmu_c_XZ<-summary(fit.glmXZ)$coef[4,] 
mu_c_XZ<-exp(summary(fit.glmXZ)$coef[4] )
e<-tableXZ$count[1]+tableXZ$count[3]
f<-tableXZ$count[2]+tableXZ$count[4]
tableX<-data.frame(expand.grid( 
interest=factor(c("0","1"),levels=c("0","1"))), 
 count=c(e,f))
fit.glmX<-glm(count~.^2, data=tableX, family=poisson)
lmu_c_X<-summary(fit.glmX)$coef[2,] 
mu_c_X<-exp(summary(fit.glmX)$coef[2] )
exponential<-rbind(mu_Y,mu_XY,mu_ZY, mu_XZY, mu_c_Z, mu_c_XZ,mu_c_X)
colnames(exponential)<-c("Estimate")
return(exponential)}

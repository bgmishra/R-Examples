simmix.delt<-function(n,M,sig,p,seed,dime=NULL){
#Simulates a mixture of l normal distributions in R^d,
#with diagonal cov matrices
#
#n is the sample size
#M is l*d-matrix, rows are the means
#sig is l*d-matrix, for l:th mixture d covariances
#p is l-vector, proportion for each mixture
#
#returns n*d-matrix
#
set.seed(seed) 

if (is.null(dime)){

if (dim(t(M))[1]==1) l<-1 else l<-length(M[,1])
d<-length(M[1,])
data<-matrix(rnorm(d*n),,d) #n*d matriisi, valkoista kohinaa 
for (i in 1:n){
   ehto<-runif(1)
   alku<-0
   loppu<-p[1]
   lippu<-0
   for (j in 1:(l-1)){
      if ((alku<=ehto) && (ehto<loppu)){
         data[i,]<-sig[j,]*data[i,]+M[j,]
         lippu<-1
      }
      alku<-alku+p[j]
      loppu<-loppu+p[j+1]
   }      
   if (lippu==0) data[i,]<-sig[l,]*data[i,]+M[l,]
}
}

if (!is.null(dime) && (dime==1)){
d<-1
l<-length(M)
data<-matrix(rnorm(d*n),,d) #n*d matriisi, valkoista kohinaa 
for (i in 1:n){
   ehto<-runif(1)
   alku<-0
   loppu<-p[1]
   lippu<-0
   for (j in 1:(l-1)){
      if ((alku<=ehto) && (ehto<loppu)){
         data[i]<-sig[j]*data[i]+M[j]
         lippu<-1
      }
      alku<-alku+p[j]
      loppu<-loppu+p[j+1]
   }      
   if (lippu==0) data[i]<-sig[l]*data[i]+M[l]
}
}

return(data)
}

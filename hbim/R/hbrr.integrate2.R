`hbrr.integrate2` <-
function(MU,V,A=c(1,1),...){
    hb.y<-function(y){
        ny<-length(y)
        outy<-rep(NA,ny)
        hb.xY<-function(x,Y){
            q<-matrix(c(x,rep(Y,length(x))),ncol=2)
            out<-(1/(1+10^(A[1]*x)))*(1/(1+10^(A[2]*Y)))*dmvnorm(q,mean=MU,sigma=V)
            return(out)
        }
        for (j in 1:ny){
            ### integrate over x keeping y fixed
            outy[j]<-integrate(hb.xY,-Inf,Inf,Y=y[j],...)$value
        }
        outy
   }
   ### integrate over y, on the function that already 
   ### integrated over x with fixed y
   out<-integrate(hb.y,-Inf,Inf,...)$value
   return(out)
}


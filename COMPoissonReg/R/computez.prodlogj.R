computez.prodlogj <- function(xmat,beta,nu,max){
# This code computes the (in)finite sum (from i=0 through to i=max) for the terms log(j!)*lambda^j/((j!)^nu)

# Compute lambda
   lambda <- exp(xmat %*% beta)

# Compute the terms used to sum for the (in)finite summation
   forans <- matrix(0,ncol=max+1,nrow=length(lambda))
   for (j in 1:max){
     temp <- matrix(0,ncol=j,nrow=length(lambda))
     temp2 <- log(1:j)
     logfactj <- sum(temp2)
     for (i in 1:j){temp[,i] <- lambda/(i^nu)}
     for (k in 1:length(lambda)){forans[k,j+1] <- logfactj*prod(temp[k,])}  
     }
   forans[,1] <- rep(0,length(lambda))

# Determine the (in)finite sum
   ans <- rowSums(forans)
return(ans)
}


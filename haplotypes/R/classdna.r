### class Dna, functions and methods
				



alltest<-function(x,char="-") all(x==char)



sic<-function(x)
{
	
	allindel<-apply(x,2,alltest,char=5)
	x[,allindel]<-0
	
	indelmatrix<-matrix(NA,0,3)
	
	for(i in 1:nrow(x))
	{
		indels<-which(x[i,]==5)
		if(length(indels)>0) 
		{
			if(length(indels)==1)
			{
				beg<-indels
				end<-indels
				indell<-1
			} else 
			{
				indelpoz<-c(2,indels[2:length(indels)]-indels[1:(length(indels)-1)])
				beg<-indels [which(indelpoz!=1)]
				end<-c(indels[which(indelpoz[-1]!=1)],indels[length(indels)])
				indell<-1+end-beg
			}
			
			indelmatrix<-rbind(indelmatrix,cbind(beg,end,indell))
			indelmatrix<-unique(indelmatrix)
			
		}
	}
	
	if(nrow(indelmatrix)==0) return(list(indels=indelmatrix,codematrix=matrix(NA,nrow(x),0)))

	indelmatrix<-indelmatrix[order(indelmatrix[,1],indelmatrix[,2]),,drop=FALSE]
	rownames(indelmatrix)<-1:nrow(indelmatrix)
	
	codematrix<-matrix(0,nrow(x),nrow(indelmatrix))
	element<-vector("list",nrow(indelmatrix))
	
	for(i in 1:ncol(codematrix))
	{
		beg<-indelmatrix[i,1]
		end<-indelmatrix[i,2]
		begother<-indelmatrix[-i,1,drop=TRUE]
		endother<-indelmatrix[-i,2,drop=TRUE]
		element[[i]]<-as.numeric(names(which(beg>=begother&end<=endother)))
		
	}	
	
	
	for(i in 1:ncol(codematrix))
	{
		beg<-indelmatrix[i,1]
		end<-indelmatrix[i,2]
		indelpart<-x[,beg:end]
		if(indelmatrix[i,3]==1) indelpart<-matrix(indelpart,,1)
		indels<- as.numeric(apply(indelpart,1,alltest,char=5))
		
		codematrix[,i]<-indels
		
		el<-element[[i]]
		if(length(el)>0)
		{
			for(j in el)
			{
				beg<-indelmatrix[j,1]
				end<-indelmatrix[j,2]
				indelpart<-x[,beg:end]
				if(indelmatrix[j,3]==1) indelpart<-matrix(indelpart,,1)
				longerindels<- apply(indelpart,1,alltest,char=5)
				codematrix[longerindels,i]<--1
			}
			
		}
		
	}
	
	return(list(indels=indelmatrix,codematrix=codematrix))
	
}

require(PET)
set.seed(1)
if(file.access(getwd(),2))
stop("You don't have a write permission in your working directory. Please choose the example 'pet_ex3.'")

# generation of the phantom
nP <- readline("Press 'Enter' to generate a Shepp-Logan head phantom ('nP=6'). Otherwise provide a number 'nP' between '1' and '6': ")
if(is.na(as.integer(nP))) nP <- 6 else nP <- as.integer(nP)
if(nP<1 || nP>6){
print("'nP' has to be between '1' and '6'. 'nP=6' is used. \n")
nP <- 6
}
design <- switch(nP, c(0.5, 0, 0, 0.4, 0.6),
       matrix( c(0.6, -0.35, 0, 0.4, 0.6, 0.3,  0.5,  0, 0.2, 0.35), nrow=2, byrow=TRUE),
       matrix( c(0.8, 0, 0, 0.6, 0.6, -0.4, 0, 0, 0.4, 0.2), nrow=2, byrow=TRUE),
       matrix( c(0.3, 0, -0.2, 0.5, 0.5, 0.6, 0,  0.2, 0.3, 0.5), nrow=2, byrow=TRUE),
        "B", "A")
phantomName <- paste("Phantom", nP, ".pet", sep="")
if(!(file.access(phantomName, 0))){
P <- readData(phantomName)$Signal
}else{
if(nP==6) P <- phantom(design=design,addIm="blurred1") else P <- phantom(design=design)
writeData(P, phantomName, DebugLevel="HardCore")
}
phantomName <- paste("Phantom", nP, sep="")
viewData(P,"Phantom with 257x257 samples")

# generation of the radon data
nS <- readline("Press 'Enter' to simulate Radon data with 'nS*100000' events, 'nS=10'. Otherwise provide a number 'nS' between '1' and '30': ")
if(is.na(as.integer(nS))) nS <- 10 else nS <- as.integer(nS)
if(nS>30){
print("nS larger than 30 takes to much time for a demo, nS=30 is used \n")
nS <- 30
}
namerP <- paste(phantomName, ".nS=", as.character(nS), ".pet", sep="")
nS <- nS*100000
if(!(file.access(namerP, 0))){
rP <- readData(namerP)$Signal
}else{
rP <- markPoisson(P,nSample=nS)
writeData(rP$rData, namerP, fileHeader=rP$Header, DebugLevel="HardCore")
rP <- rP$rData
}
viewData(rP,paste("Simulated PET data with", nS, "counts"))

readline("Press 'Enter' return for iradon (mode='FB'):")
irP.FB <- iradon(rP, 257, 257)
norm.FB <- norm(P,irP.FB$irData)
viewData(irP.FB$irData,"Reconstruction with iradon 'FB'")
readline("Press 'Enter' return for iradonIT (mode='EM', RadonKernel='RL'):")
irP.EM.20 <- iradonIT(rP, 257, 257, RadonKernel="RL", Iterations=20, ConstrainMin=0, ConstrainMax=500, SaveIterations=5, SaveIterationsName="PetExIteration", KernelFileSave=1, KernelFileName="PET.sif")$irData
irP.EM.5 <- readData("PetExIteration.5.pet")$Signal
irP.EM.10 <- readData("PetExIteration.10.pet")$Signal
irP.EM.15 <- readData("PetExIteration.15.pet")$Signal
viewData(list(irP.EM.5, irP.EM.10, irP.EM.15, irP.EM.20), list("Iterations=5", "Iterations=10", "Iterations=15", "Iterations=20"))
title(main="Reconstruction with iradonIT 'EM'", outer=TRUE)
norm.EM <- c(norm(P,irP.EM.5), norm(P,irP.EM.10), norm(P,irP.EM.15), norm(P,irP.EM.20))
rm(irP.EM.5,irP.EM.10,irP.EM.20)
readline("Press 'Enter' return for iradonIT  (mode='ART', RadonKernel='RL'):")
irP.ART.20 <- iradonIT(rP, 257, 257, mode="ART", Iterations=20, RadonKernel="RL", ConstrainMin=0, ConstrainMax=500, Alpha=0.1, Beta=0.7, SaveIterations=5, SaveIterationsName="PetExIteration", KernelFileSave=1, KernelFileName="PET.sif")$irData
irP.ART.5 <- readData("PetExIteration.5.pet")$Signal
irP.ART.10 <- readData("PetExIteration.10.pet")$Signal
irP.ART.15 <- readData("PetExIteration.15.pet")$Signal
viewData(list(irP.ART.5, irP.ART.10, irP.ART.15, irP.ART.20), list("Iterations=5", "Iterations=10", "Iterations=15", "Iterations=20"))
title(main="Reconstruction with iradonIT 'ART'", outer=TRUE)
norm.ART <- c(norm(P,irP.ART.5), norm(P,irP.ART.10), norm(P,irP.ART.15), norm(P,irP.ART.20))
rm(irP.ART.10,irP.ART.15,irP.ART.20)
readline("Press 'Enter' return for iradonIT 'CG':")
irP.CG.20 <- iradonIT(rP, 257, 257, mode="CG", Iterations=20, RadonKernel="RL", ConstrainMin=0, ConstrainMax=500, SaveIterations=5, SaveIterationsName="PetExIteration", KernelFileSave=1, KernelFileName="PET.sif")$irData
irP.CG.5 <- readData("PetExIteration.5.pet")$Signal
irP.CG.10 <- readData("PetExIteration.10.pet")$Signal
irP.CG.15 <- readData("PetExIteration.15.pet")$Signal
viewData(list(irP.CG.5, irP.CG.10, irP.CG.15, irP.CG.20), list("Iterations=5", "Iterations=10", "Iterations=15", "Iterations=20"))
title(main="Reconstruction with iradonIT 'CG'", outer=TRUE)
norm.CG <- c(norm(P,irP.CG.5), norm(P,irP.CG.10), norm(P,irP.CG.15), norm(P,irP.CG.20))
rm(irP.CG.10,irP.CG.15,irP.CG.20)
readline("Press 'Enter' to display the RMSE's:")
norm.all <- rbind(norm.EM, norm.ART, norm.CG)
colnames(norm.all) <- c("Iterations=5", "Iterations=10", "Iterations=15","Iterations=20")
rownames(norm.all) <- c("iradonIT: mode='EM'", "iradonIT: mode='ART'", "iradonIT: mode='CG'")
tmp.max <- max(c(norm.FB,norm.all))+0.05
tmp.min <- 0
tmp.col <- c("yellow","green","blue")
par(mfrow=c(1,1), las=1, oma = c(2,2,2,2)+0.1, mar=c(1,1,3,0.25), mgp=c(3,1,0)) 
barplot(norm.all, beside=TRUE, col=tmp.col, ylim=c(tmp.min,tmp.max), xpd=FALSE, main="Comparsion the RMSE of different rec. methods with 'iradon' and 'iradonIT'")
curve(0*x+norm.FB, from=0, to=16, add=TRUE)
text(0.3, norm.FB+0.01, labels="iradon: mode='FB'", pos = 4)
legend(10,tmp.max-0.05,rownames(norm.all),tmp.col)

readline("Press 'Enter' to smooth radon data (require 'adimpro' package):")
if(!("adimpro" %in% .packages(all.available=TRUE))){
rm(design,irP.ART.5,irP.CG.5,irP.EM.15,irP.FB,namerP,norm.all,norm.ART,norm.CG,norm.EM,norm.FB,nP,nS,P,phantomName,rP,tmp.col,tmp.max,tmp.min)
file.remove("PetExIteration.5.pet","PetExIteration.10.pet","PetExIteration.15.pet" )
stop("Package 'adimpro' doesn't exist")
}
require(adimpro)
degree <- readline("Press 'Enter' to smoothing the radon data using a lokal linear model ('degree=1'). Otherwise provide the number '2' using a lokal quadratic model: ")
if(is.na(as.integer(degree))) degree <- 1 else degree <- as.integer(degree)
if(!(degree %in% c(1,2))){
print("'degree' has to be '1' or '2'. 'degree=1' is used. \n")
nP <- 1
}
hmax <- readline("Press 'Enter' to smoothing the radon data using maximum bandwith 'hmax=9' when 'degree=1' and  'hmax=15' when 'degree=2'. Otherwise provide a number between '2' and '20': ")
if(is.na(as.double(hmax))) hmax <- switch(degree,9,15) else hmax <- as.double(hmax)
if(hmax<2 || hmax>20){
print("'hmax' has to be between '2' and '20'. 'hmax=9' when 'degree=1' and 'hmax=15' when 'degree=2' is used. \n")
nP <- switch(degree,9,15)
}
rP.part <- cutMatrix(rP)
tmp.smooth <- make.image(scaleImage(rP.part$A, mode="max"), gamma=TRUE, compress=FALSE)
tmp.smooth <- awspimage(tmp.smooth, hmax=hmax, degree=degree, varmodel="Linear", compress=FALSE, graph=TRUE)$img
rP.smooth <- matrix(0, nrow=rP.part$dimOrg[1], ncol=rP.part$dimOrg[2])
rP.smooth[, rP.part$pattern[1]:rP.part$pattern[2]] <- tmp.smooth
viewData(rP.smooth,paste("Smoothed sinogram with 'degree=",degree,"' and 'hmax=",hmax,"'.",sep=""))
rm(degree,hmax)

readline("Press 'Enter' return for iradon (mode='FB'):")
irP.AWS.FB <- iradon(rP.smooth, 257, 257)
norm.AWS.FB <- norm(P,irP.AWS.FB$irData)
viewData(irP.AWS.FB$irData,"Reconstruction of the smoothed sinogram with iradon 'FB'")
readline("Press 'Enter' return for iradonIT (mode='EM', RadonKernel='RL'):")
irP.AWS.EM.20 <- iradonIT(rP.smooth, 257, 257, RadonKernel="RL", Iterations=20, ConstrainMin=0, ConstrainMax=500, SaveIterations=5, SaveIterationsName="PetExIteration", KernelFileSave=1, KernelFileName="PET.sif")$irData
irP.AWS.EM.5 <- readData("PetExIteration.5.pet")$Signal
irP.AWS.EM.10 <- readData("PetExIteration.10.pet")$Signal
irP.AWS.EM.15 <- readData("PetExIteration.15.pet")$Signal
viewData(list(irP.AWS.EM.5, irP.AWS.EM.10, irP.AWS.EM.15, irP.AWS.EM.20), list("Iterations=5", "Iterations=10", "Iterations=15", "Iterations=20"))
title(main="Reconstruction of the smoothed sinogram with iradonIT 'EM'", outer=TRUE)
norm.AWS.EM <- c(norm(P,irP.AWS.EM.5), norm(P,irP.AWS.EM.10), norm(P,irP.AWS.EM.15), norm(P,irP.AWS.EM.20))
rm(irP.AWS.EM.5,irP.AWS.EM.10,irP.AWS.EM.15)
readline("Press 'Enter' return for iradonIT  (mode='ART', RadonKernel='RL'):")
irP.AWS.ART.20 <- iradonIT(rP.smooth, 257, 257, mode="ART", Iterations=20, RadonKernel="RL", ConstrainMin=0, ConstrainMax=500, Alpha=0.1, Beta=0.7, SaveIterations=5, SaveIterationsName="PetExIteration", KernelFileSave=1, KernelFileName="PET.sif")$irData
irP.AWS.ART.5 <- readData("PetExIteration.5.pet")$Signal
irP.AWS.ART.10 <- readData("PetExIteration.10.pet")$Signal
irP.AWS.ART.15 <- readData("PetExIteration.15.pet")$Signal
viewData(list(irP.AWS.ART.5, irP.AWS.ART.10, irP.AWS.ART.15, irP.AWS.ART.20), list("Iterations=5", "Iterations=10", "Iterations=15", "Iterations=20"))
title(main="Reconstruction of the smoothed sinogram with iradonIT 'ART'", outer=TRUE)
norm.AWS.ART <- c(norm(P,irP.AWS.ART.5), norm(P,irP.AWS.ART.10), norm(P,irP.AWS.ART.15), norm(P,irP.AWS.ART.20))
rm(irP.AWS.ART.5,irP.AWS.ART.15,irP.AWS.ART.20)
readline("Press 'Enter' return for iradonIT 'CG':")
irP.AWS.CG.20 <- iradonIT(rP.smooth, 257, 257, mode="CG", Iterations=20, RadonKernel="RL", ConstrainMin=0, ConstrainMax=500, SaveIterations=5, SaveIterationsName="PetExIteration", KernelFileSave=1, KernelFileName="PET.sif")$irData
irP.AWS.CG.5 <- readData("PetExIteration.5.pet")$Signal
irP.AWS.CG.10 <- readData("PetExIteration.10.pet")$Signal
irP.AWS.CG.15 <- readData("PetExIteration.15.pet")$Signal
viewData(list(irP.AWS.CG.5, irP.AWS.CG.10, irP.AWS.CG.15, irP.AWS.CG.20), list("Iterations=5", "Iterations=10", "Iterations=15", "Iterations=20"))
title(main="Reconstruction of the smoothed sinogram with iradonIT 'CG'", outer=TRUE)
norm.AWS.CG <- c(norm(P,irP.AWS.CG.5), norm(P,irP.AWS.CG.10), norm(P,irP.AWS.CG.15), norm(P,irP.AWS.CG.20))
rm(irP.AWS.CG.5,irP.AWS.CG.15,irP.AWS.CG.20)

readline("Press 'Enter' to display the RMSE's:")
norm.all <- rbind(norm.EM, norm.AWS.EM, norm.ART, norm.AWS.ART, norm.CG, norm.AWS.CG)
colnames(norm.all) <- c("Iterations=5", "Iterations=10", "Iterations=15","Iterations=20")
rownames(norm.all) <- c("iradonIT: mode='EM'", "AWS + 'EM'", "iradonIT: mode='ART'", "AWS + 'ART'", "iradonIT: mode='CG'", "AWS + 'CG'")
tmp.max <- max(c(norm.FB,norm.AWS.FB, norm.all))+0.05
tmp.min <- 0
tmp.col=c("yellow","lightyellow","green","lightgreen","blue","lightblue")
par(mfrow=c(1,1), las=1, oma = c(2,2,2,2)+0.1, mar=c(1,1,3,0.25), mgp=c(3,1,0))
barplot(norm.all, beside=TRUE, col=tmp.col, ylim=c(tmp.min,tmp.max), xpd=FALSE, main="Comparsion the RMSE of different rec. methods with 'iradon' and 'iradonIT'")
curve(0*x+norm.FB, from=0, to=28, add=TRUE)
curve(0*x+norm.AWS.FB, from=0, to=28, add=TRUE, lty=2)
text(0.3, norm.FB+0.01, labels="iradon: mode='FB'", pos = 4)
text(0.3, norm.AWS.FB+0.01, labels="AWS + 'FB'", pos = 4)
legend(17,tmp.max-0.05,rownames(norm.all),tmp.col)

readline("Press 'Enter' to display some results in a new window:")
viewData(list(irP.FB$irData, irP.EM.15, irP.ART.5, irP.CG.5, irP.AWS.FB$irData, irP.AWS.EM.20, irP.AWS.ART.10, irP.AWS.CG.10), list("mode='FB'", "mode='EM', Iterations=15", "mode='ART', Iterations=5", "mode='CG', Iterations=5", "AWS, mode='FB'", "AWS, mode='EM', Iterations=20", "AWS, mode='ART', Iterations=10", "AWS, mode='CG', Iterations=10"), curWindow=FALSE)
rm(design,irP.ART.5,irP.AWS.ART.10,irP.AWS.CG.10,irP.AWS.EM.20,irP.AWS.FB,irP.CG.5,irP.EM.15,irP.FB,namerP,norm.all,norm.ART,norm.AWS.ART,norm.AWS.CG,norm.AWS.EM,norm.AWS.FB,norm.CG,norm.EM,norm.FB,nP,nS,P,phantomName,rP,rP.part,rP.smooth,tmp.col,tmp.max,tmp.min,tmp.smooth)
file.remove("PetExIteration.5.pet","PetExIteration.10.pet","PetExIteration.15.pet" )


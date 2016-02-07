data <- read.csv(
	file="C:/Users/Eoin/Documents/GitHub/fourth-year-project/src/Analysis/exemplars_Feb-06-14-39-05_trainingError.csv",
	header=FALSE		
)

data2 <- read.csv(
	file="C:/Users/Eoin/Documents/GitHub/fourth-year-project/src/Analysis/exemplars_Feb-06-14-39-05_trainingError_ND.csv",
	header=FALSE		
)

data3 <- read.csv(
	file="C:/Users/Eoin/Documents/GitHub/fourth-year-project/src/Analysis/exemplars_Feb-06-14-39-05_trainingError_ND_HOOC.csv",
	header=FALSE		
)

par(mfrow = c(3,1))
#plot of the trainning errors for the exemplar file with duplicates
plot(data[,-1],data[,1], type="l",
	xlab="Iterations Over Exemplars with dublicates",ylab="Total Error",main="Total Error over training iterations")

#plot of the training errors for the exemplar file without duplicates
plot(data2[,-1],data2[,1], type="l",
	xlab="Iterations Over Exemplars Without Duplicates",ylab="Total Error",main="Total Error over training iterations")


plot(data3[,-1],data3[,1], type="l",
	xlab="Iterations Over Exemplars Without Duplicates",ylab="Total Error",main="Total Error over training iterations")


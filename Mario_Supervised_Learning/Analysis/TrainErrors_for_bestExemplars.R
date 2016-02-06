data <- read.csv(
	file="C:/Users/Eoin/Documents/GitHub/fourth-year-project/Mario_Supervised_Learning/Analysis/trainingError_100_it_no_d_no_m.csv",
	header=FALSE		
)

data2 <- read.csv(
	file="C:/Users/Eoin/Documents/GitHub/fourth-year-project/Mario_Supervised_Learning/Analysis/trainingError_100_iterations_no_minus.csv",
	header=FALSE		
)

data3 <- read.csv(
	file="C:/Users/Eoin/Documents/GitHub/fourth-year-project/Mario_Supervised_Learning/Analysis/trainingError_100_no_d_no_higest_out_chosen.csv",
	header=FALSE		
)

par(mfrow = c(3,1))
#plot of the trainning errors for the exemplar file with duplicates
plot(data2[,-1],data2[,1], type="l",
	xlab="Iterations Over Exemplars with dublicates",ylab="Total Error",main="Total Error over training iterations")

#plot of the training errors for the exemplar file without duplicates
plot(data[,-1],data[,1], type="l",
	xlab="Iterations Over Exemplars Without Duplicates",ylab="Total Error",main="Total Error over training iterations")


plot(data3[,-1],data3[,1], type="l",
	xlab="Iterations Over Exemplars Without Duplicates",ylab="Total Error",main="Total Error over training iterations")


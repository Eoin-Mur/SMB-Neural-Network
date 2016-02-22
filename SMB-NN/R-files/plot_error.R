exemplar <- "exemplars_7_full-level-Reduced-Inputs_2_10_trainingError.csv"

x <- paste("C:/Users/Eoin/Documents/GitHub/fourth-year-project/SMB-NN/Analysis/",exemplar,sep="")

#x <- paste("C:/Users/Eoin/Documents/GitHub/fourth-year-project/SMB-NN/Analysis/",exemplar,sep="")

data <- read.csv(
	file=x,
	header=FALSE		
)

plot(data[,-1],data[,1], type="l", xlab="Iterations",ylab="Total Error")

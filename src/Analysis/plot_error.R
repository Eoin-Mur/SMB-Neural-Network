exemplar <- "exemplars-best-file_ND_trainingError_200.csv"

x <- paste("C:/Users/Eoin/Documents/GitHub/fourth-year-project/src/Analysis/",exemplar,sep="")

data <- read.csv(
	file=x,
	header=FALSE		
)

plot(data[,-1],data[,1], type="l", xlab="Iterations",ylab="Total Error")

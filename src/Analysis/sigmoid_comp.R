#comparision of how the parameter in sigmoid effects the function(was curious)

x <- seq(-6,6,by=0.1)

y <- 1.0/(1+exp(-x))
y1 <- 1.0/(1+exp(-4.9*x))

plot(x,y,type="l",col="blue",
	xlab="",ylab="",main="comparison of the two sigmoid functions used")
lines(x,y1,col="red")
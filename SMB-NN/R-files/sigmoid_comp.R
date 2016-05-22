#comparision of how the parameter in sigmoid effects the function(was curious)

x <- seq(-6,6,by=0.1)

y <- 1.0/(1+exp(-x))
y1 <- 1.0/(1+exp(-4.9*x))

par(mfrow=c(2,1))
plot(x,y,type="l",
	xlab="",ylab="",main="1.0/1+exp(-x)")
plot(x,y1,type="l",
	xlab="",ylab="",main="1.0/1+exp(-w x) where w = 4.9")

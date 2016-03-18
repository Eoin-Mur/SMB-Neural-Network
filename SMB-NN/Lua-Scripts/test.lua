print("e("..(0.72975714961339 / 0.02)..") = "..math.exp(0.72975714961339 / 0.02) )

test = {
	0.72975714961339,
	0.45754189855936,
	0.56201934278064,
	0.68607171258998,
	0.60960038990662,
	0.45527039573424
}

ans = 0
print("sigma = ")
for i = 1, #test, 1 do
	print("e(".. (test[i] / 0.02) ..") = "..math.exp(test[i] / 0.02).."+")
	ans = ans + math.exp(test[i] / 0.02)
end
print(" = ".. ans)

print("\np(x|A) = "..math.exp(0.72975714961339 / 0.02) / ans)




print("-----------------")

qya = 0.5
qxa = 0.5
r = 1
dis = 0.6
rate = 0.5


ok = r + (dis * qya)
print("Ok = "..ok)

yk = qxa
yk = yk + rate * (ok - yk)

print("yK = "..yk)

print("yk - ok = "..yk - ok)


yk2 = qxa
yk2 = (1-rate)*yk2+dis*(ok)
print("yk2 = ".. yk2)

function randomFloat(lower, greater)
    return lower + math.random()  * (greater - lower);
end

print(randomFloat(0,0))


yk = yk + RATE * (ok - yk)
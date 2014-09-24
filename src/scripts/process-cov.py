#!/usr/bin/python

f = open("coverage.txt")
d = []
for line in f:
	d.append(int(line.strip().split(":")[1]))	
d.sort()
d.reverse()

dlen = len(d)
output=""

x_step = 1
i = 0

taken = 0
rejected = 0
zero = 0

treshold = 1

for elem in d:
	if (elem >= treshold):
		output = output + "(" + str(i) + "," + str(elem) + ")"
		i = i + x_step
		taken = taken + 1
	elif (elem > 0 and elem < treshold):
		rejected = rejected + 1
	elif (elem == 0):
		zero = zero + 1

print "********************************************************************"		
print "TOTAL RULES " + str(zero + taken + rejected)  
print "Rules called more than " + str(treshold) + " times: " + str(taken)  
print "Rules called less than " + str(treshold) + " times: " + str(rejected)  
print "Rules never called: " + str(zero)  
print "********************************************************************"		



#" --- non covered: " + str(rejected)




print output
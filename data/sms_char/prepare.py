import re 

inFp = open("sms.csv", 'r')
outFp = open("sms1k.csv", 'w')

line = inFp.readline()
outFp.write("%s"%line)

cnt = 0
while True:
    line = inFp.readline()
    if not line:
        break
    if cnt > 1000:
         break
    items = re.findall(".{1}", line)
    outFp.write("%s\n"%(' '.join(items)))
    cnt += 1
inFp.close()
outFp.close()

#
#Get TCKR Symbols 
#

f = open("Trading212CompaniesUnfiltered.txt", "r");
w = open("Ticker.txt", "w")
countryCodes = []
s = ""
tickerList = []
LdnCounter = 0
USCACounter = 0
DECounter = 0
FRCounter = 0
ESCounter = 0
NLCounter = 0
stockCounter = 0
IeCounter = 0
for x in f:
    counter = 0
    countryCode = ""
    newLine = 1
    ticker = ""
    for s in x:
        space = 0;
        if(s == "\t"):
            newLine = 0
            counter +=1
        if(newLine == 1):
            ticker  = ticker + s;

        if(counter==3):
            countryCode = countryCode + s

    stockCounter += 1;

    if(len(countryCode)>2):
        countryCode = countryCode[1] + countryCode[2]

    #.DE, .L, .MC, .PA, .ES, .AS, .TO, .SW, 
    newCode =0
    if(countryCode not in countryCodes):
        newCode = 1
    if(newCode==1):
        countryCodes.append(countryCode)
    
    if(countryCode == "IE"):
        IeCounter += 1;
    if(countryCode == "DE"):
        DECounter += 1;
        ticker = ticker + ".DE"
    if(countryCode == "GB"):
        LdnCounter += 1;
        ticker = ticker + ".L"
    if(countryCode == "US"):
        USCACounter += 1;
    if(countryCode == "NL"):
        NLCounter += 1;
        ticker = ticker + ".AS"
    if(countryCode == "ES"):
        ESCounter += 1;
        ticker = ticker + ".MC"
    if(countryCode == "FR"):
        FRCounter += 1;
        ticker = ticker + ".PA"
    
    if((len(ticker) > 0) and (len(ticker) < 6)):
        tickerList.append(ticker)
        print(tickerList[-1], "\t", countryCode)
        w.write(tickerList[-1])
        w.write("\n")
        
f.close()
w.close()

print("Total amount of stocks: ", stockCounter)
print("The total IE stock: ", IeCounter)
print("The total US stock: ", USCACounter)
print("The total GB stock: ", LdnCounter)
print("The total NL stock: ", NLCounter)
print("The total DE stock: ", DECounter)
print("The total ES stock: ", ESCounter)
print("The total FR stock: ", FRCounter)

totalCount = IeCounter + USCACounter + LdnCounter + NLCounter + DECounter + ESCounter + FRCounter


print("Other Stocks: ", (stockCounter-totalCount))

for i in range(len(countryCodes)):
    print(countryCodes[i])


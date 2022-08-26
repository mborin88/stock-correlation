#
#Covid stock crash
#
import pandas as pd
import datetime as dt
import pandas_datareader.data as web
from operator import itemgetter

GainArray = []
start2day = 15          #dates used
start2month = 7
start2year = 2020

start1day = 14
start1month = 2
start1year = 2020

end2day = 20         #dates used
end2month = 7
end2year = 2020

end1day = 28          #dates used
end1month = 2
end1year = 2020



def writeFile():
    w = open("Sorted_Stock_GainNew.txt", "w")       #Edit for new file each time
    w.write(str(dt.date.today()) + ": \t" + str(start2day) + "/" + str(start2month) + "/" + str(start2year))
    w.write(" ---  " + str(end2day) + "/" + str(end2month) + "/" + str(end2year)+ "\n")
    for i in range(len(GainArray)):
        w.write(str(i+1) + ")\t" + str(GainArray[i][0]) + "\t\t\t\t" + str(GainArray[i][1]) + "\n")

    w.close()

def SortData():
    GainArray.sort(key=itemgetter(1), reverse = True)

def getData(TCKR):
    start1 = dt.datetime(start1year, start1month, start1day)
    end1 = dt.datetime(end2year, end1month, end1day)
    start2 = dt.datetime(start2year, start2month, start2day)
    end2 = dt.datetime(end2year, end2month, end2day)
    openTotal = 0
    closeTotal = 0
    try:
        df1 = web.DataReader(TCKR, 'yahoo', start1, end1)
        df2 = web.DataReader(TCKR, 'yahoo', start2, end2)
        
        for i in range(len(df1)):
            openData = df1.iat[i, df1.columns.get_loc('Open')]
            closeData = df1.iat[i, df1.columns.get_loc('Close')]
            openTotal += openData
            closeTotal += closeData

        openMean = openTotal / len(df1)
        closeMean = closeTotal / len(df1)
        
        mean1 = (openMean + closeMean)/2
        #print("Open Mean: ", openMean)
        #print("Close Mean: ", closeMean)
        #print("Mean: ", mean1)
        #print(df1.head(10))

        #print("\n###################################\n")

        openTotal = 0
        closeTotal = 0

        for i in range(len(df2)):
            openData = df2.iat[i, df2.columns.get_loc('Open')]
            closeData = df2.iat[i, df2.columns.get_loc('Close')]
            openTotal += openData
            closeTotal += closeData

        openMean2 = openTotal / len(df2)
        closeMean2 = closeTotal / len(df2)

        mean2 = (openMean2 + closeMean2)/2
        #print("Open Mean: ", openMean)
        #print("Close Mean: ", closeMean)
        #print("Mean: ", mean2)
        #print(df2.head(10))

        percentageGain  = mean1/ mean2
        print(TCKR, "\t- Percentage Gain:\t", "{:.2f}".format(percentageGain*100), "%")
        roundedGain = "{:.2f}".format(percentageGain*100)
        GainArray.append([])
        GainArray[-1].append(TCKR)
        GainArray[-1].append(float(roundedGain))
              
    except:
        print(TCKR, " - Stock couldn't be found")
        
#######################################################################

f = open("Ticker.txt", "r")
for x in f:
    getData(x.strip())

f.close()
SortData()
writeFile()


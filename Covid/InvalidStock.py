#
#invalid Stocks
#
import pandas as pd
import datetime as dt
import pandas_datareader.data as web

counter = 0;
f = open("Ticker.txt", "r");
w = open("Invalid_Stocks.txt", "w")

start1 = dt.datetime(2020, 2, 14)
end1 = dt.datetime(2020, 2, 28)

for x in f:
    print(x.strip());
    try:
        df = web.DataReader(x.strip(), 'yahoo', start1, end1)
    except:
        print("Invalid Stock")
        counter += 1
        w.write(x.strip())
        w.write("\n")

print("Total invalid stocks: ", counter)
f.close()
w.close()

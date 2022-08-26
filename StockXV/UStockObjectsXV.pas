unit UStockObjectsXV;
{Comment code}
interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, VclTee.TeeGDIPlus, VCLTee.TeEngine,
  VCLTee.Series, Vcl.ExtCtrls, VCLTee.TeeProcs, VCLTee.Chart, Vcl.StdCtrls, Vcl.Menus,
  REST.Types, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf, Data.DB,
  Vcl.Grids, Vcl.DBGrids, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  REST.Response.Adapter, REST.Client, Data.Bind.Components, Data.Bind.ObjectScope,
  Xml.xmldom, Xml.XMLIntf, Vcl.DBCtrls, Xml.XMLDoc, Datasnap.DBClient,
  Datasnap.Provider, UStockXV;

type
  TStockProgram = class(TForm)
  procedure StockProgramCreate(Sender: TObject);
  private
    { Private declarations }
    IndexLabel, MaxQuantLabel, FileNameLabel, StartCorrLabel, EndCorrLabel, CorrIndex1Label,
    CorrIndex2Label, MaxPortLabel: TLabel;

    DisplayAllMemo, StockPulledMemo, IntroMemo, SuggestedPortMemo, BuySellMemo: TMemo;

    MainMenu2, New1, RetrieveData1, Graphing1, Display1, AI, Analysis, Exit1: TMenuItem;

    StockNameEdit, lineValueEdit, DayMovingValueEdit, MovingValue2Edit,
    QuantPullEdit, StockIndexEdit, StockCorr1Edit, StockCorr2Edit,
    DateCorrStartEdit, DateCorrEndEdit, MovAverageIndexEdit, MaxDataEdit,
    MaxPortEdit: TEdit;

    Graph: TChart;

    MainMenu1: TMainMenu;

    StockSeries1, MovingSeries, MovingSeries2: TFastLineSeries;

    CreateGraphBttn, DisplayLineBttn, DisplayBttn, MovingDayAverage1Bttn,
    MovingAverage2Bttn, PullDatBttn, DeleteDataBttn, ClearDataBttn,
    CorrelationBttn, MaxDataBttn, ClearGraphBttn, AICorrBttn, ShowAiBttn,
    UltimateMovAverageBttn, RestartBttn, ListAvgBttn: TButton;

    RadioGroup: TRadioGroup;

    RESTClient1: TRESTClient;
    RESTRequest1: TRESTRequest;
    RESTResponse1: TRESTResponse;
    RESTResponseDataSetAdapter1: TRESTResponseDataSetAdapter;
    FDMemTable1: TFDMemTable;
    DataSource1: TDataSource;

  public
    { Public declarations }
    procedure HideAll(Sender: TObject);
    procedure CreateGraphBttnClick(Sender: TObject);
    procedure PullDatBttnClick(Sender: TObject);
    procedure DisplayBttnClick(Sender: TObject);
    procedure DisplayLineBttnClick(Sender: TObject);
    procedure MovingDayAverage1BttnClick(Sender: TObject);
    procedure MovingAverage2BttnClick(Sender: TObject);
    procedure New1Click(Sender: TObject);
    procedure RetrieveData1Click(Sender: TObject);
    procedure DeleteDataBttnClick(Sender: TObject);
    procedure Graphing1Click(Sender: TObject);
    procedure Display1Click(Sender: TObject);
    procedure AIClick(Sender: TObject);
    procedure ClearDataBttnClick(Sender: TObject);
    procedure AnalysisClick(Sender: TObject);
    procedure CorrelationBttnClick(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure ClearGraphBttnClick(Sender: TObject);
    procedure AICorrBttnClick(Sender: TObject);
    procedure RestartBttnClick(Sender: TObject);
    procedure ShowAiBttnClick(Sender: TObject);
    procedure UltimateMovAverageBttnClick(Sender: TObject);
    procedure MaxDataBttnClick(Sender: TObject);
    procedure ListAvgBttnClick(Sender:TObject);
  end;

type
  TCorrStocks = record             //declare the all the initial variables, records types.
    Stock1, Stock2: integer;
    CorrValue: real;
    startDate, endDate: string;
  end;
  TFileNames = array of string;
  TPulledStocks = array of TStock;
  TArrayRecord = array of TCorrStocks;
  TStockAverage = array of array of array of real;

var
  StockProgram: TStockProgram;
  name: string;
  dataFile1: textfile;
  counter, MaxDataNum: integer;
  MyPulledStocks: TPulledStocks;
  MyFileNames: TFileNames;
  AllCorrStocks: TArrayRecord;
  MyStockAverage: TStockAverage;
  StockIndexValues: array of integer;

implementation

{$R *.dfm}

function FindLength(): integer;
var
  count: integer;
  hython: char;
begin
count:= 0;
while not eof(dataFile1) do
  begin
    read(dataFile1,hython);   //Find all hythons(2 hythons for every date)
    if hython = '-' then
      begin
      inc(count);
      end;
  end;
  count:=(count div 2); //Half hython to find out how many dates there are
  result:= count;
end;

function Mean(index, dateLine, higher: integer): real;
var         //Finds mean to work out covariance and standard deviation
  i: integer;
  total: real;
begin
  total:=0;
  for i := dateLine to (higher) do
    begin
      total:= total + MyPulledStocks[index].GetData(i).GetOpen;
    end;
  result:= total/(higher-dateLine);
end;

function CoVariance(index1, index2: integer; mean1, mean2: real; lineDiffer,
                     lower, higher: integer): real;
var
  i,x, timeDifference: integer;
  covTotal: real;
begin              //covarince calculaiton for correlation
covTotal:= 0;
timeDifference:= higher-lower;
  for i := lower to higher do
    begin
      x:= i + lineDiffer;     //to account for dates of between 2 arrays not being alligned
      covTotal:= (covTotal + (MyPulledStocks[index1].GetData(i).GetOpen-mean1)*
      (MyPulledStocks[index2].GetData(x).GetOpen-mean2));
    end;
result:= covTotal/(timeDifference);        //length of 2 lists should be identical
end;

function StandardDeviation(index: integer; mean: real; lower, higher: integer): real;
var
  i, timeDifference: integer;
  sigmatotal: real;
begin             //Standard Deviation
sigmatotal:=0;
timeDifference:= higher-lower;
for i := lower to (higher) do
  begin                         //Variance worked out
    sigmatotal:= sigmatotal + sqr(MyPulledStocks[index].GetData(i).GetOpen-mean);
  end;
result:= sqrt((sigmatotal/timeDifference));//Square rooting vairance gives standard deviation
end;

function DateIndexFind(date: string; index: integer): integer;
var
  i, holder: integer;//Find the index of where the same date is in another stock array
  x: string;
begin
  holder:= -10;
  for i := 0 to MyPulledStocks[index].GetSize-1 do
    begin
    x:= MyPulledStocks[index].GetData(i).GetDate;
    if x=date then
      holder:= i;
    end;
  result:= holder;
end;

function CheckPopStock(): integer; //Checks how much of the stock is actually populated
var
  i, popCounter, x: integer;
begin
  popCounter:=0;
  x:=0;
  for i := 0 to length(MyPulledStocks)-1 do
    begin
    if MyPulledStocks[i]<>nil then //if there is data for a stock here add the counter
      begin
        inc(popCounter);
        StockIndexValues[x]:= i;
        inc(x);
      end;
    end;
  result:= popCounter;
end;

function PascalsLength(numStocks: integer): integer;
var
  i, j, x, recordCounter: integer;
begin
  recordCounter:= 0;              //Find the number of different combinations there are for the stocks u have
  for i := 0 to numStocks-1 do
    begin
      x:= i+1;
      for j := x to numStocks-1 do
        begin
        inc(recordCounter);
        end;
    end;
  result:= recordCounter;
end;

procedure Merge(low, mid, high: integer); //Making the sorted list in merge sort.
var
  i,k,j,m: integer;
  temp: array of real;
  tempInt1, tempInt2: array of integer;
  tempDate1, tempDate2: array of string;
begin
  SetLength(temp, length(AllCorrStocks));      //Set length of all the temproary arrays.
  SetLength(tempInt1, length(AllCorrStocks));
  SetLength(tempInt2, length(AllCorrStocks));
  SetLength(tempDate1, length(AllCorrStocks));
  SetLength(tempDate2, length(AllCorrStocks));

  i:= 0;
  for j := low to mid do
    begin
    temp[i]:= AllCorrStocks[j].CorrValue;
    tempInt1[i]:= AllCorrStocks[j].Stock1;
    tempInt2[i]:= AllCorrStocks[j].Stock2;
    tempDate1[i]:= AllCorrStocks[j].startDate;
    tempDate2[i]:= AllCorrStocks[j].endDate;
    inc(i);
    end;

  i:=0;
  j:= mid+1;
  k:= low;

  while (k<j) and (j<=high) do
    begin
      if temp[i] < AllCorrStocks[j].CorrValue then
        begin
          AllCorrStocks[k].CorrValue:= temp[i];
          AllCorrStocks[k].Stock1:= tempInt1[i];
          AllCorrStocks[k].Stock2:= tempInt2[i];
          AllCorrStocks[k].startDate:= tempDate1[i];
          AllCorrStocks[k].endDate:= tempDate2[i];
          inc(i);
          inc(k);
        end
      else
        begin
          AllCorrStocks[k].CorrValue:= AllCorrStocks[j].CorrValue;
          AllCorrStocks[k].Stock1:= AllCorrStocks[j].Stock1;
          AllCorrStocks[k].Stock2:= AllCorrStocks[j].Stock2;
          AllCorrStocks[k].startDate:= AllCorrStocks[j].startDate;
          AllCorrStocks[k].endDate:= AllCorrStocks[j].endDate;
          inc(k);
          inc(j);
        end;
    end;

  for m := k to j-1 do
    begin
      AllCorrStocks[m].CorrValue:= temp[i];
      AllCorrStocks[m].Stock1:= tempInt1[i];
      AllCorrStocks[m].Stock2:= tempInt2[i];
      AllCorrStocks[m].startDate:= tempDate1[i];
      AllCorrStocks[m].endDate:= tempDate2[i];
      inc(i);
    end;
end;

procedure PerformMerge(low, high: integer); //spliiting up record to put back together
var
  mid: integer;
begin
  if low<high then                         //Recursive calls splitting up record.
    begin
      mid:= (low+high) div 2;
      PerformMerge(low, mid);
      PerformMerge((mid+1),high);
      Merge(low, mid, high);
    end;
end;

procedure MakeAverageList(period, AverageIndex, StockIndex, index: integer);
//Makes a list of the day averages and store it in a triple array to be used out of the stock
var
  n, i, lower, higher: integer;
  avg, total: real;
begin
  higher:= period;
  SetLength(MyStockAverage[AverageIndex][index], MyPulledStocks[StockIndex].GetSize-higher);
  lower:= 0;
  for n := 0 to ((MyPulledStocks[StockIndex].GetSize-higher)-1) do
    begin
      total:= 0;
      for i := lower to higher-1 do
        begin
        total:= total+ MyPulledStocks[StockIndex].GetData(i).GetOpen();
        end;
      avg:= total/period;
      MyStockAverage[AverageIndex][index][n]:= avg;  //Add all the averages to the corresponding place in the index
      inc(lower);
      if higher<(MyPulledStocks[StockIndex].GetSize-1) then
        inc(higher);                       //Stop incrementing when you get to the end of list
    end;
end;

function CorrelationDateLimit(index1, index2, j, x: integer; n: boolean;
                               out LHIndex: integer): integer;
var
  maxdate1, maxdate2: string;
  year1, year2, month1, month2, day1, day2: integer;
//Finds the common start date and there indexes in their corresponding stocks arrays
begin
  begin
    maxdate1:= MyPulledStocks[index1].GetData(j).GetDate;   //Get the comparison dates
    maxdate2:= MyPulledStocks[index2].GetData(x).GetDate;

    year1:= strtoint(maxdate1[1]+maxdate1[2]+maxdate1[3]+maxdate1[4]);    //Get the year + months and days as integer variables
    month1:= strtoint(maxdate1[6]+maxdate1[7]);
    day1:= strtoint(maxdate1[9]+maxdate1[10]);

    year2:= strtoint(maxdate2[1]+maxdate2[2]+maxdate2[3]+maxdate2[4]);
    month2:= strtoint(maxdate2[6]+maxdate2[7]);
    day2:= strtoint(maxdate2[9]+maxdate2[10]);

    if n=True then           //If you are working out the maximum date
      begin
        if year1>year2 then
          begin
            result:= DateIndexFind(maxDate2, index1);
            LHIndex:= index1;
          end
        else if year2>year1 then
          begin
            result:= DateIndexFind(maxDate1, index2);
            LHIndex:= index2;
          end
        else if year1=year2 then
          if month1>month2 then
            begin
              result:= DateIndexFind(maxDate2, index1);
              LHIndex:= index1;
            end
          else if month2>month1 then
            begin
              result:= DateIndexFind(maxdate1, index2);
              LHIndex:= index2;
            end
          else if month1=month2 then
            if day1>day2 then
              begin
                result:= DateIndexFind(maxdate2, index1);
                LHIndex:= index1;
              end
            else if day2>day1 then
              begin
                result:= DateIndexFind(maxdate1, index2);
                LHIndex:=index2;
              end
            else if day1=day2 then
              result:=(MyPulledStocks[index1].GetSize-1);    //no point so should be fine
      end
    else if n=False then              //If you are working out for the minimum date
      begin
        if year1<year2 then
          begin
            result:= DateIndexFind(maxDate2, index1);
            LHIndex:= index1;
          end
        else if year2<year1 then
          begin
            result:= DateIndexFind(maxDate1, index2);
            LHIndex:= index2;
          end
        else if year1=year2 then
          if month1<month2 then
            begin
              result:= DateIndexFind(maxDate2, index1);
              LHIndex:= index1;
            end
          else if month2<month1 then
            begin
              result:= DateIndexFind(maxdate1, index2);
              LHIndex:= index2;
            end
          else  if month1=month2 then
            if day1<day2 then
              begin
                result:= DateIndexFind(maxdate2, index1);
                LHindex:= index1;
              end
            else if day2<day1 then
              begin
                result:= DateIndexFind(maxdate1, index2);
                LHIndex:= index2;
              end
            else if day1=day2 then
              result:=0;    //no point so should be fine
      end;
  end
end;

function Correlation(index1, index2: integer; var dateLine1, dateLine2, dateLine3, dateLine4: integer): real;
type   //Finds the correlation between 2 stocks main algorithm that call the others
  TStockRecord = record
    index, low, high: integer;
    mean, sigma: real
  end;
var
  lowerlimit, higher, i, higherIndex, lowerIndex, lineDiffer: integer;
  cov: real;
  CorrStock1,CorrStock2: TStockRecord;
begin
  higherIndex:= -1;              //Initialse vairable sensibly so can be checked later
  lowerIndex:= -1;
  CorrStock1.index:=index1;
  CorrStock1.low:= dateLine1;
  CorrStock1.high:= dateLine3;
  CorrStock2.index:= index2;
  CorrStock2.low:= dateLine2;
  CorrStock2.high:= dateLine4;

  if dateLine1<dateLine2 then
    begin
      lowerlimit:=dateLine1;
      higher:= dateLine3;
    end
  else
    begin
      lowerlimit:= dateLine2;
      higher:= dateLine4;
    end;

  if (dateLine1=0) and (dateLine2=0) then  //Get the new dates if the arrays don't perfectly allign.
      lowerlimit:= CorrelationDateLimit(index1, index2, 0, 0, False, lowerIndex);

  if (dateLine3=(MyPulledStocks[index1].GetSize-1)) and
            (dateLine4=(MyPulledStocks[index2].GetSize-1)) then
    begin
      higher:= CorrelationDateLimit(index1, index2, MyPulledStocks[index1].GetSize-1,
                   MyPulledStocks[index2].GetSize-1, True, higherIndex); //e.g. x.n, 1.148 variable = in index(x) the max line is n  end;
    end;

  if (higher>=0) and (lowerlimit>=0) then   //check that the arrays do overlap
    begin
      if higherIndex=index1 then           //Reassign the new low and highs of the stocks.
        CorrStock1.high:= higher
      else if higherIndex=index2 then
        CorrStock2.high:= higher;

      if lowerIndex=index1 then
        CorrStock1.low:= lowerlimit
      else if lowerIndex=index2 then
        CorrStock2.low:= lowerlimit;

      lineDiffer:= CorrStock2.low-CorrStock1.low;  //Work out the line difference between stock

      dateLine1:= CorrStock1.low;          //Get all the new date lines for the stocks
      dateLine2:= CorrStock2.low;
      dateLine3:= CorrStock1.high;
      dateLine4:= CorrStock2.high;

      //Calculate the mean and standard deviation, and covariance.
      CorrStock1.mean:= Mean(CorrStock1.index, CorrStock1.low, CorrStock1.high);
      CorrStock2.mean:= Mean(CorrStock2.index, CorrStock2.low, CorrStock2.high);
      CorrStock1.sigma:= StandardDeviation(CorrStock1.index, CorrStock1.mean, CorrStock1.low, CorrStock1.high);
      CorrStock2.sigma:= StandardDeviation(CorrStock2.index, CorrStock2.mean, CorrStock2.low, CorrStock2.high);

      cov:= CoVariance(CorrStock1.index, CorrStock2.index, CorrStock1.mean, CorrStock2.mean, lineDiffer, CorrStock1.low,
                   CorrStock1.high);
      result:= cov/(CorrStock1.sigma*CorrStock2.sigma);
    end
  else
    result:= 2;     //If no correlation found set a clearly wrong date as the correlation coefficient
end;

{ TStockProgram }

procedure TStockProgram.AIClick(Sender: TObject);//Show the AI menu items
begin
  HideAll(Sender);

  SuggestedPortMemo.Visible:=True;
  SuggestedPortMemo.Clear;
  SuggestedPortMemo.Left:= 800;
  SuggestedPortMemo.Top:= 200;
  SuggestedPortMemo.Height:= 400;
  SuggestedPortMemo.Width:= 300;
  SuggestedPortMemo.ReadOnly:= True;
  MaxPortEdit.Text:= '2';

  DisplayAllMemo.Clear;
  DisplayAllMemo.Top:= 75;
  DisplayAllMemo.Left:= 100;
  DisplayAllMemo.Width:= 550;
  DisplayAllMemo.Height:= 200;
  DisplayAllMemo.ReadOnly:= True;

  MaxPortEdit.Left:= 175;
  MaxPortEdit.Top:= 390;
  MaxPortEdit.Width:= 130;

  MaxPortLabel.Caption:= 'No. Stocks Portfolio:';
  MaxPortLabel.Top:= MaxPortEdit.Top+5;
  MaxPortLabel.Left:= 10;

  ShowAiBttn.Width:= 130;
  ShowAiBttn.Height:= 60;
  ShowAiBttn.Caption:= 'AI Correlaition';
  ShowAiBttn.Left:= 125;
  ShowAiBttn.Top:= 300;

  MaxPortEdit.Visible:= True;
  MaxPortLabel.Visible:= True;
  DisplayAllMemo.Visible:= True;
  ShowAIBttn.Visible:=True;
end;

procedure TStockProgram.AICorrBttnClick(Sender: TObject);
//Never seen button, finds all posible correlation, and sorts them in the desired oreder
var
  i, j,s,k, numStocks, paslow, dateLine1, dateLine2,
               dateLine3, dateLine4, recordLength, n, InvalidCount: integer;
  corr: real;
begin
  n:=0;                                //Initialise variables
  InvalidCount:= 0;                            //Work out the amount of populated stocks and set array lengths based on this
  numStocks:= CheckPopStock();
  SetLength(StockIndexValues, numStocks);
  recordLength:= PascalsLength(numStocks);
  SetLength(AllCorrStocks, recordLength);

  for s := 0 to length(AllCorrStocks)-1 do      //Re-set all values in the array to default obscene values.
    begin
      AllCorrStocks[s].Stock1:= 0;
      AllCorrStocks[s].Stock2:= 0;
      AllCorrStocks[s].CorrValue:= 2;
      AllCorrStocks[s].startDate:= '';
      AllCorrStocks[s].endDate:= '';
    end;

  for i := 0 to numStocks-1 do         //Going through all the different versions of stock combination
    begin
      paslow:= i+1;                   //Ignores repeating stocks matching with itself
      for j := paslow to numStocks-1 do
        begin
          StockCorr1Edit.Text:= inttostr(StockIndexValues[i]);  //Do it for max time period dates betweens stocks
          StockCorr2Edit.Text:= inttostr(StockIndexValues[j]);
          dateLine1:=0;
          dateLine2:=0;
          dateLine3:= MyPulledStocks[StockIndexValues[i]].GetSize-1;
          dateLine4:= MyPulledStocks[StockIndexValues[j]].GetSize-1; //Call the correlation function
          corr:= Correlation(StockIndexValues[i],StockIndexValues[j],dateLine1,dateLine2, dateLine3, dateLine4);
          if (corr<=1) and (corr>=-1) then //if the correlation between the stocks is valid
            begin
              with AllCorrStocks[n] do
                begin
                  Stock1:= StockIndexValues[i];   //Set all the value in the records to the correct ones
                  Stock2:= StockIndexValues[j];
                  CorrValue:= corr;
                  startDate:= MyPulledStocks[StockIndexValues[i]].GetData(dateLine1).GetDate;
                  endDate:= MyPulledStocks[StockIndexValues[i]].GetData(dateLine3).GetDate;
                end;
            inc(n);
            end;
        end;
    end;

  for k := 0 to length(AllCorrStocks)-1 do
    begin
    if AllCorrStocks[k].CorrValue=2 then  //Get rid of the empty slots to maximis memory.
      inc(InvalidCount);
    end;

  SetLength(AllCorrStocks, length(AllCorrStocks)-InvalidCount);
  PerformMerge(0, recordLength-1);   //Sort the list
end;

procedure TStockProgram.AnalysisClick(Sender: TObject); //Show the Analysis Items
begin
  HideAll(Sender);

  DisplayAllMemo.Clear;
  DisplayAllMemo.Top:= 75;
  DisplayAllMemo.Left:= 100;
  DisplayAllMemo.Width:= 600;
  DisplayAllMemo.Height:= 200;
  DisplayAllMemo.ReadOnly:= True;

  CorrelationBttn.Top:= 300;
  CorrelationBttn.Left:= 75;
  CorrelationBttn.Width:= 100;
  CorrelationBttn.Height:= 44;
  CorrelationBttn.Caption:= 'Correlation';

  StockCorr1Edit.Top:= 350;
  StockCorr1Edit.Left:= 120;
  StockCorr1Edit.Width:= 25;
  CorrIndex1Label.Top:= StockCorr1Edit.Top;
  CorrIndex1Label.Left:= 10;
  CorrIndex1Label.Caption:= 'Corr. Index 1: ';

  StockCorr2Edit.Top:= 400;
  StockCorr2Edit.Left:= 120;
  StockCorr2Edit.Width:= 25;
  CorrIndex2Label.Top:= StockCorr2Edit.Top;
  CorrIndex2Label.Left:= 10;
  CorrIndex2Label.Caption:= 'Corr. Index 2: ';

  StartCorrLabel.Caption:= 'Start Date: ';
  StartCorrLabel.Left:= 195;
  StartCorrLabel.Top:= 310;

  EndCorrLabel.Caption:='End Date: ';
  EndCorrLabel.Left:= StartCorrLabel.Left+5;
  EndCorrLabel.Top:= 352;

  DateCorrEndEdit.Left:= EndCorrLabel.Left+100;
  DateCorrEndEdit.Top:= 350;
  DateCorrEndEdit.Width:= 100;
  DateCorrEndEdit.Text:= 'YYYYMMDD';

  DateCorrStartEdit.Left:=StartCorrLabel.Left+100;
  DateCorrStartEdit.Top:= 308;
  DateCorrStartEdit.Width:= 100;
  DateCorrStartEdit.Text:= 'YYYYMMDD';

  ClearDataBttn.Left:= DateCorrStartEdit.Left+160;
  ClearDataBttn.Width:= 130;
  ClearDataBttn.Height:= 60;
  ClearDataBttn.Caption:= 'Clear Data';
  ClearDataBttn.Top:= 300;

  CorrIndex1Label.Visible:=True;
  CorrIndex2Label.Visible:= True;
  DisplayAllMemo.Visible:= True;
  ClearDataBttn.Visible:= True;
  StartCorrLabel.Visible:=True;
  EndCorrLabel.Visible:=True;
  DateCorrEndEdit.Visible:=True;
  DateCorrStartEdit.Visible:=True;
  CorrelationBttn.Visible:= True;
  StockCorr1Edit.Visible:=True;
  StockCorr2Edit.Visible:= True;
end;

procedure TStockProgram.ClearDataBttnClick(Sender: TObject);
begin
  DisplayAllMemo.Lines.Clear;             //Clears display
end;

procedure TStockProgram.ClearGraphBttnClick(Sender: TObject);
begin                                  //Clears the graph of all its lines
  StockSeries1.Free;
  StockSeries1 := TFastLineSeries.Create( Self );
  StockSeries1.ParentChart := Graph;

  MovingSeries.Free;
  MovingSeries := TFastLineSeries.Create( Self );
  MovingSeries.ParentChart := Graph;

  MovingSeries2.Free;
  MovingSeries2 := TFastLineSeries.Create(Self);
  MovingSeries2.ParentChart := Graph;
end;

procedure TStockProgram.CorrelationBttnClick(Sender: TObject);
var
  index1, index2, dateline1, dateline2, dateLine3, dateLine4: integer;
  corr: real;
  date, endDate: string;
begin
{Gets the required info from the program and executes correlation algorithm
if possible if not handles errors, handles custom dates or max and min dates
Also displays correlation}
  try
    begin
      index1:= strtoint(StockCorr1Edit.Text);
      index2:= strtoint(StockCorr2Edit.Text);
      date:= DateCorrStartEdit.Text;
      endDate:= DateCorrEndEdit.Text;
    
      date:= date[1]+date[2]+date[3]+date[4]+'-'+date[5]+date[6]+'-'+date[7]+date[8];
      endDate:= endDate[1]+endDate[2]+endDate[3]+endDate[4]+'-'+endDate[5]+endDate[6]+'-'
        +endDate[7]+endDate[8];
    
      dateline1:= DateIndexFind(date, index1);
      dateline2:= DateIndexFind(date, index2);
      dateLine3:= DateIndexFind(endDate, index1);
      dateLine4:= DateIndexFind(endDate, index2);

      if date='YYYY-MM-DD' then
        begin
        dateLine1:=0;
        dateLine2:=0;
        end;

      if endDate='YYYY-MM-DD' then
        begin
          dateLine3:= MyPulledStocks[index1].GetSize-1;
          dateLine4:= MyPulledStocks[index2].GetSize-1;
        end;

      if (dateLine1>=0) and (dateLine2>=0) and (dateLine3>=0) and (dateLine4>=0) then
        begin
        corr:= Correlation(index1,index2,dateLine1,dateLine2, dateLine3, dateLine4);   //Correlation algorithm in here
        if (corr<=1) and (corr>=-1) then
          begin
          date:= MyPulledStocks[index1].GetData(dateLine1).GetDate;
          endDate:= MyPulledStocks[index1].GetData(dateLine3).GetDate;
          DisplayAllMemo.Lines.Add('Correlation Coefficient (' + MyFileNames[index1]
            + ' / ' + MyFileNames[index2] + ') from ('+ date +' - '+ endDate+
             '):     ' + floattostrF(corr, ffnumber, 4, 5));
          end
        else
          DisplayAllMemo.Lines.Add('No common date found in file');
            //Add dates as well
        end
      else if (dateLine1<0) or (dateLine2<0) or (dateLine3<0) or (dateLine4<0) then
        begin
        DisplayAllMemo.Lines.Add('Date no found in one or both files');
        DateCorrStartEdit.Text:= 'YYYY-MM-DD';
        end;
    end;
  except 
    on E: EConvertError do   //all string errors handles with the date input are covered with if's 
      begin
        ShowMessage('Datatypes required: Index1, Index2: integer; (Start/End)Date: string(8)');
      end;
  end;
end;

procedure TStockProgram.CreateGraphBttnClick(Sender: TObject);
var
  i, StockIndex: integer;     //Creates graph from the stock whicb was desired
begin
  try
    begin
      i:=0;
      StockSeries1.Clear;
      StockIndex:= strtoint(StockIndexEdit.Text);
      StockSeries1.LegendTitle:= MyFileNames[StockIndex];
      With StockSeries1 do
        begin
            for i := 0 to (MyPulledStocks[StockIndex].GetSize-1) do
              Add(MyPulledStocks[StockIndex].GetData(i).GetOpen,'',clRed);
        end;
    end;
  except 
    on E: Exception do
      begin
        ShowMessage('Enter (integer) index of Stock you want to plot');
      end;
  end;
end;

procedure TStockProgram.DeleteDataBttnClick(Sender: TObject);
var
  i: integer;               //Deletes undesired stock if possible
begin
  try
    begin
      MyPulledStocks[strtoint(QuantPullEdit.Text)]:= nil;
      MyFileNames[strtoint(QuantPullEdit.Text)]:= '';

      StockPulledMemo.Clear;
      StockPulledMemo.Lines.Add('Stocks Pulled: ');

      for i := 0 to length(MyFileNames)-1 do
        StockPulledMemo.Lines.Add(inttostr(i) +': '+ MyFileNames[i]);
    end;
  except
    on E: Exception do                              //Error handling
      ShowMessage('Enter a valid integer in Stock Index');
  end;

end;

procedure TStockProgram.Display1Click(Sender: TObject);
begin
  HideAll(Sender);      //Shows all the display objects when the display menu item is clicked

  DisplayAllMemo.Top:= 75;
  DisplayAllMemo.Left:= 100;
  DisplayAllMemo.Width:= 750;
  DisplayAllMemo.Height:= 200;
  DisplayAllMemo.ReadOnly:= True;

  lineValueEdit.Top:= 337;
  lineValueEdit.Left:= 20;

  DisplayBttn.Left:= lineValueEdit.Left+190;
  DisplayBttn.Top:= lineValueEdit.Top+70;
  DisplayBttn.Width:= 140;
  DisplayBttn.Height:= 60;
  DisplayBttn.Caption:= 'Display All Values';

  DisplayLineBttn.Left:= lineValueEdit.Left+190;
  DisplayLineBttn.Top:= lineValueEdit.Top;
  DisplayLineBttn.Width:= 140;
  DisplayLineBttn.Height:= 60;
  DisplayLineBttn.Caption:= 'Display Line';


  ClearDataBttn.Height:= 60;
  ClearDataBttn.Width:= 130;
  ClearDataBttn.Caption:= 'Clear Data';
  ClearDataBttn.Left:= DisplayLineBttn.Left+200;
  ClearDataBttn.Top:= 325;

  StockIndexEdit.Top:= DisplayBttn.Top+10;
  StockIndexEdit.Left:= 130;
  StockIndexEdit.Width:= 25;

  StockIndexEdit.Visible:= True;
  DisplayAllMemo.Visible:= True;
  DisplayBttn.Visible:= True;
  DisplayLineBttn.Visible:=True;
  lineValueEdit.Visible:=True;
  ClearDataBttn.Visible:= True;
end;

procedure TStockProgram.DisplayBttnClick(Sender: TObject);
var
  n, StockIndex: integer;
                         //Display all values of data from the stock.
begin
  try
    begin
      StockIndex:= strtoint(StockIndexEdit.Text);
      DisplayAllMemo.Lines.Add('Data Requested: ');
      for n := 0 to (MyPulledStocks[StockIndex].GetSize-1) do //Iteration length variable had to minus 1 as starts from 0.
        begin
          DisplayAllMemo.Lines.Add(inttostr(n)+ ': '+ MyPulledStocks[StockIndex].Display(n));
        end;
    end;
  except 
    on E: EConvertError do
      begin
        ShowMessage('Need an integer index');
      end;
  end;
end;

procedure TStockProgram.DisplayLineBttnClick(Sender: TObject);
var
  StockIndex: integer;      //Displays a line of data from a stock
begin
  try
    begin
      StockIndex:= strtoint(StockIndexEdit.Text);
      DisplayAllMemo.Lines.Add('Data Requested: ');
      DisplayAllMemo.Lines.Add(MyFileNames[StockIndex]+':   ' + MyPulledStocks[StockIndex].Display(strtoint(lineValueEdit.Text)));
      DisplayAllMemo.Lines.Add('');
    end;
  except
    on E: Exception do
      begin
        ShowMessage('Need an integer value');
      end;
  end;
end;

procedure TStockProgram.Exit1Click(Sender: TObject);
begin
  HideAll(Sender);
  StockProgram.Close;      //Exit the program
  end;

procedure TStockProgram.Graphing1Click(Sender: TObject);
begin                                //Shows the objects needed when graphing menu is clicked
  HideAll(Sender);
  StockIndexEdit.Left:= 20;
  StockIndexEdit.Top:= 400;

  ClearGraphBttn.Left:= StockIndexEdit.Left+400;
  ClearGraphBttn.Width:= 130;
  ClearGraphBttn.Height:= 60;
  ClearGraphBttn.Top:= StockIndexEdit.Top-10;
  ClearGraphBttn.Caption:= 'Clear Graph';

  DayMovingValueEdit.Left:=StockIndexEdit.Left;
  DayMovingValueEdit.Top:= StockIndexEdit.Top+60;
  MovingDayAverage1Bttn.Top:= DayMovingValueEdit.Top-4;
  MovingDayAverage1Bttn.Left:= DayMovingValueEdit.Left+220;
  MovingDayAverage1Bttn.Height:= 60;
  MovingDayAverage1Bttn.Width:= 140;
  MovingDayAverage1Bttn.Caption:= 'Plot Moving Day 1';

  MovingValue2Edit.Left:= StockIndexEdit.Left;
  MovingValue2Edit.Top:= DayMovingValueEdit.Top+70;
  MovingAverage2Bttn.Left:= MovingDayAverage1Bttn.Left;
  MovingAverage2Bttn.Top:= DayMovingValueEdit.Top+70;
  MovingAverage2Bttn.Width:= 140;
  MovingAverage2Bttn.Height:= 60;
  MovingAverage2Bttn.Caption:= 'Plot Moving Day 2';

  Graph.Left:= 20;
  Graph.Top:= 20;
  Graph.View3D:= False;
  Graph.Height:= 350;
  Graph.Width:= 1100;

  CreateGraphBttn.Left:= StockIndexEdit.Left+220;
  CreateGraphBttn.Top:= StockIndexEdit.Top-10;
  CreateGraphBttn.Width:= 140;
  CreateGraphBttn.Height:= 60;
  CreateGraphBttn.Caption:= 'Make Graph';

  UltimateMovAverageBttn.Left:= 600;
  UltimateMovAverageBttn.Top:= 600;
  UltimateMovAverageBttn.Height:= 80;
  UltimateMovAverageBttn.Width:= 160;
  UltimateMovAverageBttn.Caption:= 'Ult Mov Day Average';

  MovAverageIndexEdit.Left:= 600;
  MovAverageIndexEdit.Top:= 500;

  ListAvgBttn.Caption:= 'Pull Avgs';
  ListAvgBttn.Left:= MovingDayAverage1Bttn.Left+20;
  ListAvgBttn.Top:= DayMovingValueEdit.Top+150;

  BuySellMemo.Left:= 800;
  BuySellMemo.Top:= 400;
  BuySellMemo.Height:= 400;
  BuySellMemo.Width:= 300;
  BuySellMemo.ReadOnly:= True;

  BuySellMemo.Visible:= True;
  //UltimateMovAverageBttn.Visible:= True;
  //MovAverageIndexEdit.Visible:= True;
  ClearGraphBttn.Visible:= True;
  StockIndexEdit.Visible:= True;
  Graph.Visible:= True;
  CreateGraphBttn.Visible:= True;
  DayMovingValueEdit.Visible:= True;
  MovingDayAverage1Bttn.Visible:= True;
  MovingValue2Edit.Visible:= True;
  ListAvgBttn.Visible:= True;
  MovingAverage2Bttn.Visible:= True;
end;

procedure TStockProgram.HideAll(Sender: TObject);   //Hide all the objects if they are visible
begin
  if QuantPullEdit.Visible= True then QuantPullEdit.Visible:= False;
  if FileNameLabel.Visible= True then FileNameLabel.Visible:= False;
  if Graph.Visible=True then Graph.Visible:= False;
  if StockNameEdit.Visible=True then StockNameEdit.Visible:= False;
  if CreateGraphBttn.Visible=True then  CreateGraphBttn.Visible:= False;
  if PullDatBttn.Visible=True then PullDatBttn.Visible:= False;
  if DisplayBttn.Visible=True then DisplayBttn.Visible:= False;
  if DisplayLineBttn.Visible=True then DisplayLineBttn.Visible:= False;
  if DayMovingValueEdit.Visible=True then DayMovingValueEdit.Visible:= False;
  if MovingDayAverage1Bttn.Visible=True then MovingDayAverage1Bttn.Visible:= False;
  if DayMovingValueEdit.Visible=True then DayMovingValueEdit.Visible:= False;
  if MovingValue2Edit.Visible=True then MovingValue2Edit.Visible:= False;
  if MovingAverage2Bttn.Visible=True then MovingAverage2Bttn.Visible:= False;
  if lineValueEdit.Visible=True then lineValueEdit.Visible:= False;
  if IndexLabel.Visible=True then IndexLabel.Visible:= False;
  if MaxQuantLabel.Visible=True then MaxQuantLabel.Visible:= False;
  if StockPulledMemo.Visible=True then StockPulledMemo.Visible:= False;
  if DeleteDataBttn.Visible=True then DeleteDataBttn.Visible:=False;
  if IntroMemo.Visible=True then IntroMemo.Visible:=False;
  if DisplayAllMemo.Visible=True then DisplayAllMemo.Visible:= False;
  if ClearDataBttn.Visible=True then ClearDataBttn.Visible:= False;
  if StockIndexEdit.Visible= True then StockIndexEdit.Visible:= False;
  if CorrelationBttn.Visible=True then CorrelationBttn.Visible:= False;
  if StockCorr1Edit.Visible=True then StockCorr1Edit.Visible:= False;
  if StockCorr2Edit.Visible=True then StockCorr2Edit.Visible:= False;
  if DateCorrStartEdit.Visible=True then DateCorrStartEdit.Visible:=False;
  if DateCorrEndEdit.Visible=True then DateCorrEndEdit.Visible:= False;
  if StartCorrLabel.Visible=True then StartCorrLabel.Visible:= False;
  if EndCorrLabel.Visible=True then EndCorrLabel.Visible:= False;
  if MaxDataEdit.Visible=True then MaxDataEdit.Visible:= False;
  if MaxDataBttn.Visible=True then MaxDataBttn.Visible:= False;
  if ClearGraphBttn.Visible=True then ClearGraphBttn.Visible:= False;
  if AICorrBttn.Visible=True then AICorrBttn.Visible:= False;
  if RestartBttn.Visible=True then RestartBttn.Visible:= False;
  if ShowAiBttn.Visible=True then ShowAiBttn.Visible:= False;
  if UltimateMovAverageBttn.Visible=True then UltimateMovAverageBttn.Visible:= False;
  if MovAverageIndexEdit.Visible=True then MovAverageIndexEdit.Visible:= False;
  if RadioGroup.Visible=True then RadioGroup.Visible:= False;
  if SuggestedPortMemo.Visible=True then SuggestedPortMemo.Visible:=False;
  if ListAvgBttn.Visible=True then ListAvgBttn.Visible:= False;
  if BuySellMemo.Visible=True then BuySellMemo.Visible:= False;
  if MaxPortEdit.Visible=True then MaxPortEdit.Visible:= False;
  if CorrIndex1Label.Visible=True then CorrIndex1Label.Visible:= False;
  if CorrIndex2Label.Visible=True then CorrIndex2Label.Visible:= False;
  if MaxPortLabel.Visible=True then MaxPortLabel.Visible:=False;
  
end;

procedure TStockProgram.ListAvgBttnClick(Sender: TObject);
var
  popStocks, i, j, k, period1, period2, date1, date2: integer;
  UPorDown: array of array of boolean;
  test1, test2, periodCheck: boolean;
begin
{
Makes a list of all stocks high and low simple moving day arrays.
And displays the buy period on a memo if they occur for a long enough duration.
By checking if the smaller day average is pulling the longer day average up.
}
  BuySellMemo.Clear;
  periodCheck:=True;
  popStocks:= CheckPopStock();
  SetLength(MyStockAverage, popStocks);
  SetLength(UPorDown, popStocks);

  try
    begin
      period1:= strtoint(DayMovingValueEdit.Text);
      period2:= strtoint(MovingValue2Edit.Text);
    end;
  except
    on E:EConvertError do
      begin
        ShowMessage('Enter valid integers x>0 as the moving day values');
        periodCheck:= False;
      end;
  end;

  if (period1<1) or (period2<1) then
    periodCheck:= False;

  if periodCheck=True then
    begin
      for i := 0 to popStocks-1 do
        begin
          SetLength(MyStockAverage[i], 2);
        end;

      for i := 0 to popStocks-1 do
        begin
            MakeAverageList(period1, i, StockIndexValues[i], 0);
            MakeAverageList(period2, i, StockIndexValues[i], 1);
        end;

      k:= period2-period1;

      for i := 0 to popStocks-1 do
        begin
          SetLength(UporDown[i], (MyPulledStocks[StockIndexValues[i]].GetSize-1-period2));
          for j := 0 to length(UporDown[i])-1 do
            begin
              if MyStockAverage[i][0][j+k]>MyStockAverage[i][1][j] then
                UporDown[i][j]:= True
              else
                UporDown[i][j]:= False;
            end;
        end;

      BuySellMemo.Lines.Create.Add('Stocks Buy and Sell Times');
      for i := 0 to length(UporDown)-1 do
        begin
          BuySellMemo.Lines.Add(MyFileNames[StockIndexValues[i]]);
          test1:= False;
          test2:= False;
          for j := 0 to length(UporDown[i])-2 do
            begin
              if (UporDown[i][j]=False) and (UporDown[i][j+1]=True) then
                begin
                  date1:= j+1;
                  test1:= True;
                end;
              if (UporDown[i][0]=True)  and (UporDown[i][j+1]=True) and (j=0) then
                begin
                  date1:= j+1;
                  test1:= True;
                end;
              if (UporDown[i][j]=True) and (UporDown[i][j+1]=False) then
                begin
                  date2:= j;
                  test2:= True
                end;
              if (UporDown[i][j]=True) and (UporDown[i][j-1]) and (j=(length(UporDown[i])-2)) then
                begin
                  date2:= j;
                  test2:= True;
                end;
              if (test1=True) and (test2=True) then
                begin
                if (date2-date1)>5 then
                  begin
                    BuySellMemo.Lines.Add('Buy '+ MyPulledStocks[StockIndexValues[i]].GetData(date1).GetDate+
                    ' - '+ MyPulledStocks[StockIndexValues[i]].GetData(date2).GetDate);
                  end;
                test1:= False;
                test2:= False;
                end;
            end;
        end;
      {for i := 0 to length(UporDown[i]) do
        begin
          BuySellMemo.Lines.Add('Stock Currently bulling' + booltostr(UporDown[i][length(UpOrDown[i])-2]));
        end;  }
    end
  else
    begin
      ShowMessage('Enter valid integer for moving periods.')
    end;

end;

procedure TStockProgram.MaxDataBttnClick(Sender: TObject);
var
  i: integer;      //Set the max pulled data value and use it to set all the necessary arrays.
begin
  try
    begin
      if strtoint(MaxDataEdit.Text)>=5 then
        begin
          MaxDataNum:= strtoint(MaxDataEdit.Text);
          SetLength(MyFileNames, MaxDataNum);
          SetLength(MyPulledStocks, MaxDataNum);
          SetLength(MyStockAverage, MaxDataNum);
          SetLength(StockIndexValues, MaxDataNum);
          MaxDataEdit.Text:= 'Yes';
        end
      else
        MaxDataEdit.Text:= '5';

      for i := 0 to length(MyPulledStocks)-1 do
        begin
          MyPulledStocks[i]:= nil;
        end;
    end;
  except
    on E: EConvertError do
    ShowMessage('Enter an integer');
  end;
end;

procedure TStockProgram.MovingAverage2BttnClick(Sender: TObject);
var
  i, StockIndex, period: integer;       //Draws the 2nd Moving Average line, and calculates it
begin
  try
    begin
      if strtoint(MovingValue2Edit.Text)>0 then
        begin
          period:= (strtoint(MovingValue2Edit.Text));
          MovingSeries2.Free;
          MovingSeries2 := TFastLineSeries.Create( Self );
          MovingSeries2.ParentChart := Graph;
          MovingSeries2.Color:= clMaroon;
          MovingSeries2.LegendTitle:= inttostr(period)+ ' Moving Average';

          StockIndex:= strtoint(StockIndexEdit.Text);
          for i := 0 to length(MyStockAverage)-1 do
            begin
              SetLength(MyStockAverage[i], 2);
            end;
          MakeAverageList(period, StockIndex, StockIndex, 1);

          With MovingSeries2 do
            begin
              for i := 0 to length(MyStockAverage[StockIndex][1])-1 do
                begin
                  ADDXY(i+period-1, MyStockAverage[StockIndex][1][i], '', clMaroon);
                end;
            end;
        end
      else
        MovingValue2Edit.Text:= 'Value greater than 0';
    end;
  except 
    on E: EConvertError do
    begin
      ShowMessage('Need to an integer value');
    end;
  end;
end;

procedure TStockProgram.MovingDayAverage1BttnClick(Sender: TObject);
var
  i, period, StockIndex: integer;      //Draws the 1st moving value, and calulates the moving average
begin
  try
    begin
      if strtoint(DayMovingValueEdit.Text)>0 then
        begin
          period:= (strtoint(DayMovingValueEdit.Text));

          MovingSeries.Free;
          MovingSeries := TFastLineSeries.Create( Self );
          MovingSeries.ParentChart := Graph;
          MovingSeries.Color:= clGreen;
          MovingSeries.LegendTitle:= inttostr(period)+' Moving Average';

          StockIndex:= strtoint(StockIndexEdit.Text);
          for i := 0 to length(MyStockAverage)-1 do
            begin
              SetLength(MyStockAverage[i], 2);
            end;
          MakeAverageList(period, StockIndex, StockIndex, 0);

          With MovingSeries do
            begin
              for i := 0 to length(MyStockAverage[StockIndex][0])-1 do
                begin
                  ADDXY(i+period-1, MyStockAverage[StockIndex][0][i], '', clMaroon);
                end;
            end;
        end
      else
        DayMovingValueEdit.Text:= 'Value greater than 0';
    end;
  except 
    on E: EConvertError do
    begin
      ShowMessage('Need to an integer value');
    end;

  end;
end;

procedure TStockProgram.New1Click(Sender: TObject);
begin
  HideAll(Sender);      //Objects to be shown when the new menu is clicked and starting screen

  IntroMemo.Clear;
  IntroMemo.Left:= 200;
  IntroMemo.Top:= 50;
  IntroMemo.Height:= 150;
  IntroMemo.Width:= 500;
  IntroMemo.Font.Size:= 8;
  IntroMemo.Lines.Add('Intro');
  IntroMemo.Lines.Add('This is a program, that can be used to visualise, stocks and shares');
  IntroMemo.Lines.Add('To start get choose a max amount of data below min. 5.');
  IntroMemo.Lines.Add('Then locate your files from the retrieve data Tab');
  IntroMemo.Lines.Add('Then explore some of the menu function');
  IntroMemo.Visible:=True;

  MaxQuantLabel.Left:= 245;
  MaxQuantLabel.Top:= 218;
  MaxQuantLabel.Width:= 50;
  MaxQuantLabel.Caption:= 'Max. Data: ';
  MaxQuantLabel.Visible:= True;

  MaxDataEdit.Text:= '5';
  MaxDataEdit.Left:= 350;
  MaxDataEdit.Top:= 215;
  MaxDataEdit.Width:= 30;
  MaxDataEdit.Visible:= True;

  MaxDataBttn.Caption:= 'Set Max';
  MaxDataBttn.Left:= MaxDataEdit.Left+50;
  MaxDataBttn.Top:= 205;
  MaxDataBttn.Width:= 150;
  MaxDataBttn.Height:= 60;
  MaxDataBttn.Visible:= True;

  RestartBttn.Caption:= 'Restart';
  RestartBttn.Left:= MaxDataBttn.Left;
  RestartBttn.Top:= MaxDataBttn.Top+90;
  RestartBttn.Width:= MaxDataBttn.Width;
  RestartBttn.Height:= MaxDataBttn.Height;
  RestartBttn.Visible:= True;

end;

procedure TStockProgram.PullDatBttnClick(Sender: TObject);
type TRecord = record
  Date: string;
  Open, High, Low, Close: real;
  Vol, unAdjVol: integer;
  Change, changePerc, vwap: real;
  label1: string;
  ChangeOT: real;
end;

var
  temp, temp2, temp3: string;
  field1, field2, field3, field4, field5, field6, field7, field8, field9, field10,
  field11, field12:TField;
  i, ListArrayLength: integer;
  a: array of TRecord;
  b: array of string;
  success, APIPull: boolean;
begin  
  {
  The procedure which actually pulls and formats the data values from all the 
  data points of the source. Also handles errors.
  And assigns the formatted stock values to an array.
  }
  apiPull:= True;
  success:= False;
  StockPulledMemo.Clear;
  StockPulledMemo.Lines.Add('Stocks Pulled:');
  temp:= StockNameEdit.Text;
  try
      counter:= strtoint(QuantPullEdit.Text);
  except
    on E: EConvertError do
      ShowMessage('Enter an intger for the stock index value')
  end;

  if fileexists(StockNameEdit.Text)=True then
    begin
      assignfile(dataFile1, StockNameEdit.Text);
      reset(dataFile1);
      ListArrayLength:= FindLength();
      closefile(dataFile1);

      MyPulledStocks[counter]:= TStock.Create(StockNameEdit.Text, ListArrayLength);
      success:= True;
    end
  else
    begin
      temp2:= '6m';
      case RadioGroup.ItemIndex of
        0: temp2:= '5d';
        1: temp2:= '1m';
        2: temp2:= '3m';
        3: temp2:= '6m';
        4: temp2:= '1y';
        5: temp2:= '2y';
        6: temp2:= '5y';
      end;
      //StockNameEdit.Text:= 'Attempting Online Pull';
      RESTRequest1.Resource:= temp+'/chart/'+ temp2;
      try
        RESTRequest1.Execute;
      except 
        on E: Exception do
          begin
            ShowMessage('File Not Found on API');
            ApiPull:= False;
            success:= False;
          end;
      end;

      if APIPull= True then
        begin
          field1:= DataSource1.DataSet.FieldByName('date');
          field2:= DataSource1.DataSet.FieldByName('open');
          field3:= DataSource1.DataSet.FieldByName('high');
          field4:= DataSource1.DataSet.FieldByName('low');
          field5:= DataSource1.DataSet.FieldByName('close');
          field6:= DataSource1.DataSet.FieldByName('Volume');
          field7:= DataSource1.DataSet.FieldByName('unadjustedVolume');
          field8:= DataSource1.DataSet.FieldByName('change');
          field9:= DataSource1.DataSet.FieldByName('changePercent');
          field10:= DataSource1.DataSet.FieldByName('vwap');
          field11:= DataSource1.DataSet.FieldByName('label');
          field12:= DataSource1.DataSet.FieldByName('changeOverTime');
          i:= 0;

          DataSource1.DataSet.First;
          while not DataSource1.DataSet.Eof do
            begin
              inc(i);
              DataSource1.DataSet.Next;
            end;

          DataSource1.DataSet.First;
          SetLength(a, i);
          i:=0;
          while not DataSource1.DataSet.Eof do
            begin
              a[i].Date:= field1.Value;
              a[i].Open:= field2.Value;
              a[i].High:= field3.Value;
              a[i].Low:= field4.Value;
              a[i].Close:= field5.Value;
              a[i].Vol:= field6.Value;
              a[i].unAdjVol:= field7.Value;
              a[i].Change := field8.Value;
              a[i].changePerc:= field9.Value;
              a[i].vwap:= field10.Value;
              a[i].label1:= field11.Value;
              a[i].ChangeOT:= field12.Value;
              inc(i);
              DataSource1.DataSet.Next;
            end;
          SetLength(b, length(a));

          for i := 0 to length(b)-1 do
            begin
              temp3:= a[i].Date+',' + floattostr(a[i].Open)+','+floattostr(a[i].High)+ ','+
                floattostr(a[i].Low)+','+ floattostr(a[i].Close)+','+ floattostr(a[i].ChangeOT)+
                ','+ inttostr(a[i].Vol);
                b[i]:= temp3;
            end;

          MyPulledStocks[counter]:= TStock.Create(b);
          success:= True;
          temp:= temp+'_'+temp2;
        end;

    end;
    
  if success=True then
    begin
      MyFileNames[counter]:= temp;
      inc(counter);
      if counter>(MaxDataNum-1) then
        counter:=0;
      QuantPullEdit.Text:= inttostr(counter);
      StockNameEdit.Text:= 'Success';
    end;
    
  for i := 0 to length(MyFileNames)-1 do
    StockPulledMemo.Lines.Add(inttostr(i) +': '+ MyFileNames[i]); 
end;

procedure TStockProgram.RestartBttnClick(Sender: TObject);
var
  i: integer;
begin
{
  Re-sets all the values to the original default values.
}
  counter:= 0;
  QuantPullEdit.Text:= inttostr(counter);
  StockNameEdit.Text:= '(Example.txt/TCKR)';

  DisplayAllMemo.Clear;
  StockPulledMemo.Clear;

  StockSeries1.Free;
  StockSeries1 := TFastLineSeries.Create( Self );
  StockSeries1.ParentChart := Graph;

  MovingSeries.Free;
  MovingSeries := TFastLineSeries.Create( Self );
  MovingSeries.ParentChart := Graph;

  MovingSeries2.Free;
  MovingSeries2 := TFastLineSeries.Create(Self);
  MovingSeries2.ParentChart := Graph;

  SetLength(MyFileNames, MaxDataNum);
  SetLength(MyPulledStocks, MaxDataNum);
  SetLength(MyStockAverage, MaxDataNum);
  SetLength(StockIndexValues, MaxDataNum);

  for i := 0 to length(MyPulledStocks)-1 do
    begin
      MyPulledStocks[i]:= nil;
    end;

  for i := 0 to length(MyFileNames)-1 do
    begin
      MyFileNames[i]:= '';
    end;

  for i := 0 to length(StockIndexValues)-1 do
    begin
      StockIndexValues[i]:= 0;
    end;

  StockPulledMemo.Lines.Add('Stocks Pulled:');
  ShowMessage('Program Started');

  New1Click(Sender);
end;

procedure TStockProgram.RetrieveData1Click(Sender: TObject);
var
  n: integer;
begin          //Shows all the correct objects when the retrieve data menu is clicked.
  HideAll(Sender);
  n:= (MaxDataNum-1);
  IndexLabel.Caption:= 'Stock Index: ';
  FileNameLabel.Caption:= 'FileName';

  StockNameEdit.Left:= 300;
  StockNameEdit.Top:= 100;
  FileNameLabel.Top:= StockNameEdit.Top-20;
  FileNameLabel.Left:= StockNameEdit.Left;

  PullDatBttn.Width:= 150;
  PullDatBttn.Height:= 60;
  PullDatBttn.Left:= StockNameEdit.Left-30;
  PullDatBttn.Top:= 330;
  PullDatBttn.Caption:= 'Pull Data';

  DeleteDataBttn.Top:= PullDatBttn.Top;
  DeleteDataBttn.Left:= StockNameEdit.Left+130;
  DeleteDataBttn.Width:= PullDatBttn.Width;
  DeleteDataBttn.Height:= PullDatBttn.Height;
  DeleteDataBttn.Caption:= 'Delete Data';

  QuantPullEdit.Left:= 200;
  QuantPullEdit.Top:= 150;
  QuantPullEdit.Width:= 20;
  IndexLabel.Left:= 100;
  IndexLabel.Top:= 154;
  MaxQuantLabel.Left:= 100;
  MaxQuantLabel.Top:= 180;
  MaxQuantLabel.Caption:= 'Max Quantity of Stocks: ' + inttostr(n+1);

  StockPulledMemo.Left:= 600;
  StockPulledMemo.Height:= 200;
  StockPulledMemo.Top:= 150;
  StockPulledMemo.ReadOnly:= True;

  RadioGroup.Left:= StockPulledMemo.Left-300;
  RadioGroup.Top:= 145;
  RadioGroup.Height:= 170;
  RadioGroup.Caption:= 'Live Data: Time Options';

  RadioGroup.Visible:= True;
  FileNameLabel.Visible:= True;
  DeleteDataBttn.Visible:=True;
  StockPulledMemo.Visible:= True;
  StockNameEdit.Visible:= True;
  PullDatBttn.Visible:= True;
  IndexLabel.Visible:= True;
  QuantPullEdit.Visible:= True;
  MaxQuantLabel.Visible:= True;
end;

procedure TStockProgram.ShowAiBttnClick(Sender: TObject);
var
  i, suggestNum, j, x: integer;
  checkNum: array of integer;
  check1, check2: boolean;
begin
{
  This function shows the ordered stock correlation from high positive to high negative 
  and shows and calculates the suggested portfolio in the memo.
}
  SuggestedPortMemo.Clear;
  AICorrBttnClick(Sender);
  DisplayAllMemo.Lines.Add('Highest - Lowest Stock Correlation: ');
  for i := length(AllCorrStocks)-1 downTo 0 do
    begin
      DisplayAllMemo.Lines.Add(MyFileNames[AllCorrStocks[i].Stock1]+'-'+
       MyFileNames[AllCorrStocks[i].Stock2] + ' ('+ AllCorrStocks[i].startDate+' - '
       + AllCorrStocks[i].endDate+') ' + ': ' +
       floattostrF(AllCorrStocks[i].CorrValue, ffnumber, 4,5));
    end;

   SuggestedPortMemo.Lines.Add('Suggested Portfolio');
   //suggestNum:= length(AllCorrStocks) div 4;        //user choose
   try
      begin
      if strtoint(MaxPortEdit.Text)<length(MyPulledStocks) then
        suggestNum:= strtoint(MaxPortEdit.Text)
      else
        if length(MyPulledStocks)>1 then
          suggestNum:= 2
        else
          suggestNum:=1;
      end;
   except
    on E: Exception do
      ShowMessage('Enter a valid integer number');
   end;

   SetLength(checkNum, suggestNum);

   for i := 0 to length(checkNum)-1 do
     begin
       checkNum[i]:= -1;
     end;

   x:=0;
   for i := length(AllCorrStocks)-1 downto length(AllCorrStocks)-1-suggestNum do
     begin
      check1:= False;
      check2:= False;
       for j := 0 to length(checkNum)-1 do
        begin
          if (checkNum[j]=AllCorrStocks[i].Stock1) then check1:= True;
          if (checkNum[j]=AllCorrStocks[i].Stock2) then check2:= True;          
        end;
        
       if check1=False then
        begin
          checkNum[x]:= AllCorrStocks[i].Stock1;
          inc(x);
        end;
       if check2=False then
        begin
          checkNum[x]:= AllCorrStocks[i].Stock2;
          inc(x);
        end;
     end;

   for i := 0 to length(checkNum)-1 do
     begin
       SuggestedPortMemo.Lines.Add(MyFileNames[checkNum[i]]);
     end;
end;

procedure TStockProgram.StockProgramCreate;
//Dynamically creating all objects and items needed when the program starts
var
  i: integer;
begin
    Graph:= TChart.Create(Self);
    Graph.Parent:= Self;
    StockSeries1:= TFastLineSeries.Create(Self);
    StockSeries1.ParentChart:= Graph;
    MovingSeries:= TFastLineSeries.Create(Self);
    MovingSeries.ParentChart:= Graph;
    MovingSeries2:= TFastLineSeries.Create(Self);
    MovingSeries2.ParentChart:= Graph;

    MainMenu1:= TMainMenu.Create(Self);
    MainMenu2:= TMenuItem.Create(Self);
    MainMenu2.Caption:= 'Main Menu';
    New1:= TMenuItem.Create(MainMenu2);
    New1.Caption:= 'New';
    RetrieveData1:= TMenuItem.Create(MainMenu2);
    RetrieveData1.Caption:= 'Retrieve Data';
    Graphing1:= TMenuItem.Create(MainMenu2);
    Graphing1.Caption:= 'Graphing';
    Display1:= TMenuItem.Create(Self);
    Display1.Caption:= 'Display';
    AI:= TMenuItem.Create(Self);
    AI.Caption:= 'AI';
    Exit1:= TMenuItem.Create(Self);
    Exit1.Caption:= 'Exit';
    Analysis:= TMenuItem.Create(Self);
    Analysis.Caption:= 'Analysis';
    MainMenu1.Items.Add(MainMenu2);
    MainMenu2.Add(New1);
    MainMenu2.Add(RetrieveData1);
    MainMenu2.Add(Graphing1);
    MainMenu2.Add(Display1);
    MainMenu2.Add(Analysis);
    MainMenu2.Add(AI);
    MainMenu2.Add(Exit1);

    CreateGraphBttn:= TButton.Create(Self);
    CreateGraphBttn.Parent:= Self;
    PullDatBttn:= TButton.Create(Self);
    PullDatBttn.Parent:= Self;
    DisplayBttn:= TButton.Create(Self);
    DisplayBttn.Parent:= Self;
    DisplayLineBttn:= TButton.Create(Self);
    DisplayLineBttn.Parent:= Self;
    MovingDayAverage1Bttn:= TButton.Create(Self);
    MovingDayAverage1Bttn.Parent:= Self;
    MovingAverage2Bttn:= TButton.Create(Self);
    MovingAverage2Bttn.Parent:= Self;
    DeleteDataBttn:= TButton.Create(Self);
    DeleteDataBttn.Parent:= Self;
    ClearDataBttn:= TButton.Create(Self);
    ClearDataBttn.Parent:= Self;
    CorrelationBttn:= TButton.Create(Self);
    CorrelationBttn.Parent:= Self;
    MaxDataBttn:= TButton.Create(Self);
    MaxDataBttn.Parent:= Self;
    ClearGraphBttn:= TButton.Create(Self);
    ClearGraphBttn.Parent:= Self;
    AICorrBttn:= TButton.Create(Self);
    AICorrBttn.Parent:= Self;
    RestartBttn:= TButton.Create(Self);
    RestartBttn.Parent:= Self;
    ShowAiBttn:= TButton.Create(Self);
    ShowAiBttn.Parent:= Self;
    UltimateMovAverageBttn:= TButton.Create(Self);
    UltimateMovAverageBttn.Parent:= Self;
    ListAvgBttn:= TButton.Create(Self);
    ListAvgBttn.Parent:= Self;

    StockNameEdit:= TEdit.Create(Self);
    StockNameEdit.Parent:= Self;
    lineValueEdit:= TEdit.Create(Self);
    lineValueEdit.Parent:= Self;
    DayMovingValueEdit:= TEdit.Create(Self);
    DayMovingValueEdit.Parent:= Self;
    MovingValue2Edit:= TEdit.Create(Self);
    MovingValue2Edit.Parent:= Self;
    QuantPullEdit:= TEdit.Create(Self);
    QuantPullEdit.Parent:= Self;
    StockIndexEdit:= TEdit.Create(Self);
    StockIndexEdit.Parent:= Self;
    MovAverageIndexEdit:= TEdit.Create(Self);
    MovAverageIndexEdit.Parent:= Self;
    MaxDataEdit:= TEdit.Create(Self);
    MaxDataEdit.Parent:= Self;
    MaxPortEdit:= TEdit.Create(Self);
    MaxPortEdit.Parent:= Self;
    StockCorr1Edit:= TEdit.Create(Self);
    StockCOrr1Edit.Parent:= Self;
    StockCorr2Edit:= TEdit.Create(Self);
    StockCorr2Edit.Parent:= Self;
    DateCorrStartEdit:= TEdit.Create(Self);
    DateCorrStartEdit.Parent:= Self;
    DateCorrEndEdit:= TEdit.Create(Self);
    DateCorrEndEdit.Parent:= Self;

    DisplayAllMemo:= TMemo.Create(Self);
    DisplayAllMemo.Parent:= Self;
    StockPulledMemo:= TMemo.Create(Self);
    StockPulledMemo.Parent:= Self;
    IntroMemo:= TMemo.Create(Self);
    IntroMemo.Parent:= Self;
    SuggestedPortMemo:= TMemo.Create(Self);
    SuggestedPortMemo.Parent:= Self;
    BuySellMemo:= TMemo.Create(Self);
    BuySellMemo.Parent:= Self;

    IndexLabel:= TLabel.Create(Self);
    IndexLabel.Parent:= Self;
    MaxQuantLabel:= TLabel.Create(Self);
    MaxQuantLabel.Parent:= Self;
    FileNameLabel:= TLabel.Create(Self);
    FileNameLabel.Parent:= Self;
    CorrIndex1Label:= TLabel.Create(Self);
    CorrIndex1Label.Parent:= Self;
    CorrIndex2Label:= TLabel.Create(Self);
    CorrIndex2Label.Parent:= Self;
    StartCorrLabel:= TLabel.Create(Self);
    StartCorrLabel.Parent:= Self;
    EndCorrLabel:= TLabel.Create(Self);
    EndCorrLabel.Parent:= Self;
    MaxPortLabel:= TLabel.Create(Self);
    MaxPortLabel.Parent:= Self;


    RadioGroup:= TRadioGroup.Create(Self);
    RadioGroup.Parent:= Self;
    RadioGroup.Items.Add('5D');
    RadioGroup.Items.Add('1M');
    RadioGroup.Items.Add('3M');
    RadioGroup.Items.Add('6M');
    RadioGroup.Items.Add('1Y');
    RadioGroup.Items.Add('2Y');
    RadioGroup.Items.Add('5Y');

    RESTClient1:= TRESTClient.Create(Self);
    RESTRequest1:= TRESTRequest.Create(Self);
    RESTResponse1:= TRESTResponse.Create(Self);
    RESTResponseDataSetAdapter1:= TRESTResponseDataSetAdapter.Create(Self);
    FDMemTable1:= TFDMemTable.Create(Self);
    DataSource1:= TDataSource.Create(Self);

    RESTClient1.BaseURL:= 'https://api.iextrading.com/1.0/stock/';
    RESTRequest1.Resource:= 'GOOG/chart/6m';
    RESTRequest1.Response:= RESTResponse1;
    RESTRequest1.Client:= RESTClient1;
    RESTResponseDataSetAdapter1.Dataset:= FDMemTable1;
    RESTResponseDataSetAdapter1.Response:= RESTResponse1;
    DataSource1.DataSet:= FDMemTable1;

    StockProgram.Height:= 900;
    StockProgram.Width:= 1200;

    AI.OnClick:= AIClick;
    AICorrBttn.OnClick:= AICorrBttnClick;
    Analysis.OnClick:= AnalysisClick;
    ClearDataBttn.OnClick:= ClearDataBttnClick;
    ClearGraphBttn.OnClick:= ClearGraphBttnClick;
    CorrelationBttn.OnClick:= CorrelationBttnClick;
    CreateGraphBttn.OnClick:= CreateGraphBttnClick;
    DeleteDataBttn.OnClick:= DeleteDataBttnClick;
    Display1.OnClick:= Display1Click;
    DisplayBttn.OnClick:= DisplayBttnClick;
    DisplayLineBttn.OnClick:= DisplayLineBttnClick;
    Exit1.OnClick:= Exit1Click;
    Graphing1.OnClick:= Graphing1Click;
    MaxDataBttn.OnClick:= MaxDataBttnClick;
    MovingAverage2Bttn.OnClick:= MovingAverage2BttnClick;
    MovingDayAverage1Bttn.OnClick:= MovingDayAverage1BttnClick;
    New1.OnClick:= New1Click;
    PullDatBttn.OnClick:= PullDatBttnClick;
    RestartBttn.OnClick:= RestartBttnClick;
    RetrieveData1.OnClick:= RetrieveData1Click;
    ShowAiBttn.OnClick:= ShowAiBttnClick;
    UltimateMovAverageBttn.OnClick:= UltimateMovAverageBttnClick;
    ListAvgBttn.OnClick:= ListAvgBttnClick;

    MaxDataNum:= 5;
    SetLength(MyFileNames, MaxDataNum);
    SetLength(MyPulledStocks, MaxDataNum);
    SetLength(MyStockAverage, MaxDataNum);
    SetLength(StockIndexValues, MaxDataNum);

    RestartBttnClick(Sender);
end;

procedure TStockProgram.UltimateMovAverageBttnClick(Sender: TObject);
type
  TAFastL= array[0..1] of TFastLineSeries;
var
  MyAverageSeries: TAFastL;
  pointer: integer;
begin
{
  Unfinished simplifed moving day average algorith. 
  To stop repetition in the code.
}
  pointer:= strtoint(MovAverageIndexEdit.Text);
  MyAverageSeries[pointer] := TFastLineSeries.Create( Self );
  MyAverageSeries[pointer].ParentChart := Graph;
  MyAverageSeries[pointer].Color:= clMaroon;
end;

end.

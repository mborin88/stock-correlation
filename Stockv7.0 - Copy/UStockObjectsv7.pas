unit UStockObjectsv7;
{
Version 8 supports the newer UI which entales the new windows system.
Also accomodates new features such as pulling multiple stocks now which allows for data comparison
Has new feature for these new features such as deleting certain pieces of data
 }
//correlation finished !!! except dont know how it will fair for lists that don't overlap
interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, VclTee.TeeGDIPlus, VCLTee.TeEngine,
  VCLTee.Series, Vcl.ExtCtrls, VCLTee.TeeProcs, VCLTee.Chart, Vcl.StdCtrls, Vcl.Menus,
  Ustock7;

type
  TStockProgram = class(TForm)

        Graph: TChart;
    CreateGraphBttn: TButton;
    StockSeries1: TFastLineSeries;
    PullDatBttn: TButton;
    StockNameEdit: TEdit;
    DisplayBttn: TButton;
    DisplayAllMemo: TMemo;
    DisplayLineBttn: TButton;
    lineValueEdit: TEdit;
    MovingDayAverage1Bttn: TButton;
    DayMovingValueEdit: TEdit;
    MovingSeries: TFastLineSeries;
    MovingAverage2Bttn: TButton;
    MovingValue2Edit: TEdit;
    MovingSeries2: TFastLineSeries;
    MainMenu1: TMainMenu;
    MainMenu2: TMenuItem;
    New1: TMenuItem;
    RetrieveData1: TMenuItem;
    Graphing1: TMenuItem;
    Display1: TMenuItem;
    AI: TMenuItem;
    IndexLabel: TLabel;
    QuantPullEdit: TEdit;
    MaxQuantLabel: TLabel;
    StockPulledMemo: TMemo;
    DeleteDataBttn: TButton;
    FileNameLabel: TLabel;
    ClearDataBttn: TButton;
    StockIndexEdit: TEdit;
    Analysis: TMenuItem;
    CorrelationBttn: TButton;
    StockCorr1Edit: TEdit;
    StockCorr2Edit: TEdit;
    DateCorrStartEdit: TEdit;
    DateCorrEndEdit: TEdit;
    StartCorrLabel: TLabel;
    EndCorrLabel: TLabel;
    Exit1: TMenuItem;
    MaxDataBttn: TButton;
    ClearGraphBttn: TButton;
    AICorrBttn: TButton;
    ShowAiBttn: TButton;
    UltimateMovAverageBttn: TButton;
    MovAverageIndexEdit: TEdit;
    MaxDataEdit: TEdit;
    IntroMemo: TMemo;
    RestartBttn: TButton;
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
    procedure HideAll(Sender: TObject);
    procedure Display1Click(Sender: TObject);
    procedure AIClick(Sender: TObject);
    procedure ClearDataBttnClick(Sender: TObject);
    procedure AnalysisClick(Sender: TObject);
    procedure CorrelationBttnClick(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure MaxDataBttnClick(Sender: TObject);
    procedure ClearGraphBttnClick(Sender: TObject);
    procedure AICorrBttnClick(Sender: TObject);
    procedure RestartBttnClick(Sender: TObject);
    procedure ShowAiBttnClick(Sender: TObject);
    procedure UltimateMovAverageBttnClick(Sender: TObject);

  private
    { Private declarations }

  public
    { Public declarations }
  end;
type
  TCorrStocks = record
    Stock1, Stock2: integer;
    CorrValue: real;
    startDate, endDate: string;
  end;
  TFileNames = array of string;
  TArrayLengths = array of integer;
  TPulledStocks = array of TStock;
  TArrayRecord = array of TCorrStocks;
  TStockAverage = array of array of real;

var
  StockProgram: TStockProgram;
  name: string;
  dataFile1: textfile;
  counter, MaxDataNum: integer;
  ListArrayLengths: TArrayLengths;
  MyPulledStocks: TPulledStocks;
  MyFileNames: TFileNames;
  AllCorrStocks: TArrayRecord;
  MyStockAverage: TStockAverage;

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
var
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
                     lower, higher: integer): real;  //timedifference incorporated in function
var
  i,x, timeDifference: integer;
  covTotal: real;
begin
covTotal:= 0;
timeDifference:= higher-lower;
  for i := lower to higher do
    begin
      x:= i + lineDiffer;
      covTotal:= (covTotal + (MyPulledStocks[index1].GetData(i).GetOpen-mean1)*
      (MyPulledStocks[index2].GetData(x).GetOpen-mean2));
    end;
result:= covTotal/(timeDifference);        //length of 2 lists should be identical
end;

function StandardDeviation(index: integer; mean: real; lower, higher: integer): real;
var
  i, timeDifference: integer;
  sigmatotal: real;
begin
sigmatotal:=0;
timeDifference:= higher-lower;
for i := lower to (higher) do
  begin
    sigmatotal:= sigmatotal + sqr(MyPulledStocks[index].GetData(i).GetOpen-mean);
  end;
result:= sqrt((sigmatotal/timeDifference));
end;

function DateIndexFind(date: string; index: integer): integer;
var
  i, holder: integer;
  x: string;
begin
  holder:= -10;
  for i := 0 to ListArrayLengths[index]-1 do
    begin
    x:= MyPulledStocks[index].GetData(i).GetDate;
    if x=date then
      holder:= i;
    end;
  result:= holder;
end;

{function DateCheck(value1, value2, index1, index2: integer; var n :integer;
                            maxDate1, maxDate2: string): integer;
begin
if value1>value2 then
  result:= DateIndexFind(maxDate2, index1)
else if value2>value1 then
  result:= DateIndexFind(maxDate1, index2)
else if value1=value2 then

end; }  //Recursive algorithm for finding the greatest date

function CorrelationDateLimit(index1, index2, j, x: integer; n: boolean;
                               out LHIndex: integer): integer;
var
  maxdate1, maxdate2: string;
  year1, year2, month1, month2, day1, day2: integer;

begin
  begin
    //j:= ListArrayLengths[index1]-1;
    //x:= ListArrayLengths[index2]-1;
    maxdate1:= MyPulledStocks[index1].GetData(j).GetDate;
    maxdate2:= MyPulledStocks[index2].GetData(x).GetDate;

    year1:= strtoint(maxdate1[1]+maxdate1[2]+maxdate1[3]+maxdate1[4]);
    month1:= strtoint(maxdate1[6]+maxdate1[7]);
    day1:= strtoint(maxdate1[9]+maxdate1[10]);

    year2:= strtoint(maxdate2[1]+maxdate2[2]+maxdate2[3]+maxdate2[4]);
    month2:= strtoint(maxdate2[6]+maxdate2[7]);
    day2:= strtoint(maxdate2[9]+maxdate2[10]);

    if n=True then
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
    else if n=False then
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
type
  TStockRecord = record
    index, low, high: integer;
    mean, sigma: real
  end;
var
  lowerlimit, higher, i, higherIndex, lowerIndex, lineDiffer: integer;
  cov, sigma1, sigma2, mean1, mean2: real;
  CorrStock1,CorrStock2: TStockRecord;
begin
higherIndex:= -1;
lowerIndex:= -1;
lineDiffer:= dateLine1-dateLine2;
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

if (dateLine1=0) and (dateLine2=0) then
    lowerlimit:= CorrelationDateLimit(index1, index2, 0, 0, False, lowerIndex);   //Greater than signs in opposite direction

if (dateLine3=(MyPulledStocks[index1].GetSize-1)) and
          (dateLine4=(MyPulledStocks[index2].GetSize-1)) then
  begin
    higher:= CorrelationDateLimit(index1, index2, ListArrayLengths[index1]-1,
                 ListArrayLengths[index2]-1, True, higherIndex); //e.g. x.n, 1.148 variable = in index(x) the max line is n  end;
  end;

if (higher>=0) and (lowerlimit>=0) then   //check that they overlap
  begin
    if higherIndex=index1 then
      CorrStock1.high:= higher
    else if higherIndex=index2 then
      CorrStock2.high:= higher;

    if lowerIndex=index1 then
      CorrStock1.low:= lowerlimit
    else if lowerIndex=index2 then
      CorrStock2.low:= lowerlimit;

    lineDiffer:= CorrStock2.low-CorrStock1.low;

    dateLine1:= CorrStock1.low;
    dateLine2:= CorrStock2.low;
    dateLine3:= CorrStock1.high;
    dateLine4:= CorrStock2.high;

    CorrStock1.mean:= Mean(CorrStock1.index, CorrStock1.low, CorrStock1.high);
    CorrStock2.mean:= Mean(CorrStock2.index, CorrStock2.low, CorrStock2.high);
    CorrStock1.sigma:= StandardDeviation(CorrStock1.index, CorrStock1.mean, CorrStock1.low, CorrStock1.high);
    CorrStock2.sigma:= StandardDeviation(CorrStock2.index, CorrStock2.mean, CorrStock2.low, CorrStock2.high);

    cov:= CoVariance(CorrStock1.index, CorrStock2.index, CorrStock1.mean, CorrStock2.mean, lineDiffer, CorrStock1.low,
                 CorrStock1.high);
    result:= cov/(CorrStock1.sigma*CorrStock2.sigma);
  end
else
  result:= 2;

end;

function CheckPopStock(): integer;
var
  i, popCounter: integer;
begin
  popCounter:=0;
  for i := 0 to length(MyPulledStocks)-1 do
    begin
    if MyPulledStocks[i]<>nil then
      inc(popCounter);  
    end;
  result:= popCounter;
end;

function PascalsLength(numStocks: integer): integer;
var
  i, j, x, recordCounter: integer;
begin
  recordCounter:= 0;
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

procedure Merge(low, mid, high: integer);
var
  i,k,j,m: integer;
  temp: array of real;
begin
  SetLength(temp, length(AllCorrStocks));
  i:= 0;
  for j := low to mid do
    begin
    temp[i]:= AllCorrStocks[j].CorrValue;
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
          inc(i);
          inc(k);
        end
      else
        begin
          AllCorrStocks[k].CorrValue:= AllCorrStocks[j].CorrValue;
          inc(k);
          inc(j);
        end;
    end;

  for m := k to j-1 do
    begin
      AllCorrStocks[m].CorrValue:= temp[i];
      inc(i);
    end;
end;

procedure PerformMerge(low, high: integer);
var
  mid: integer;
begin
  if low<high then
    begin
      mid:= (low+high) div 2;
      PerformMerge(low, mid);
      PerformMerge((mid+1),high);
      Merge(low, mid, high);
    end;
end;

procedure MakeAverageList(period, AverageIndex, StockIndex: integer);
var
  n, i, lower, higher: integer;
  avg, total: real;
begin
  higher:= period;
  SetLength(MyStockAverage, 2);
  SetLength(MyStockAverage[AverageIndex], MyPulledStocks[StockIndex].GetSize-higher);
  lower:= 0;
  for n := 0 to ((MyPulledStocks[StockIndex].GetSize-higher)-1) do
    begin
      total:= 0;
      for i := lower to higher-1 do
        begin
        total:= total+ MyPulledStocks[StockIndex].GetData(i).GetOpen();
        end;
      avg:= total/period;
      MyStockAverage[AverageIndex][n]:= avg;
      inc(lower);
      if higher<(MyPulledStocks[StockIndex].GetSize-1) then
        inc(higher);
    end;
end;

procedure TStockProgram.DisplayLineBttnClick(Sender: TObject);
var
  StockIndex: integer;
begin
StockIndex:= strtoint(StockIndexEdit.Text);
DisplayAllMemo.Lines.Add('Data Requested: ');
DisplayAllMemo.Lines.Add(MyFileNames[StockIndex]+':   ' + MyPulledStocks[StockIndex].Display(strtoint(lineValueEdit.Text)));
DisplayAllMemo.Lines.Add('');
end;

procedure TStockProgram.Exit1Click(Sender: TObject);
begin
HideAll(Sender);
end;

procedure TStockProgram.AIClick(Sender: TObject);
begin
  HideAll(Sender);
  DisplayAllMemo.Clear;
  DisplayAllMemo.Top:= 75;
  DisplayAllMemo.Left:= 100;
  DisplayAllMemo.Width:= 550;
  DisplayAllMemo.Height:= 200;
  ShowAiBttn.Left:= 125;
  ShowAiBttn.Top:= 300;
  DisplayAllMemo.Visible:= True;
  ShowAIBttn.Visible:=True;
end;

procedure TStockProgram.Graphing1Click(Sender: TObject);
begin
  HideAll(Sender);
  StockIndexEdit.Left:= 75;
  StockIndexEdit.Top:= 290;
  ClearGraphBttn.Left:= 250;
  ClearGraphBttn.Top:= 280;

  DayMovingValueEdit.Left:=8;
  DayMovingValueEdit.Top:= 350;
  MovingDayAverage1Bttn.Top:= 346;
  MovingDayAVerage1Bttn.Left:= 140;

  MovingValue2Edit.Left:= 8;
  MovingValue2Edit.Top:= 390;
  MovingAverage2Bttn.Left:= 140;
  MovingAverage2Bttn.Top:= 390;

  Graph.Height:= 250;
  Graph.Width:= 800;

  UltimateMovAverageBttn.Left:= 500;
  UltimateMovAverageBttn.Top:= 350;

  MovAverageIndexEdit.Left:= 500;
  MovAverageIndexEdit.Top:= 300;

  UltimateMovAverageBttn.Visible:= True;
  MovAverageIndexEdit.Visible:= True;
  ClearGraphBttn.Visible:= True;
  StockIndexEdit.Visible:= True;
  Graph.Visible:= True;
  CreateGraphBttn.Visible:= True;
  DayMovingValueEdit.Visible:= True;
  MovingDayAverage1Bttn.Visible:= True;
  MovingValue2Edit.Visible:= True;
  MovingAverage2Bttn.Visible:= True;
end;

procedure TStockProgram.ShowAiBttnClick(Sender: TObject);
var
  i: integer;
begin
  AICorrBttnClick(Sender);
  DisplayAllMemo.Lines.Add('Highest - Lowest Stock Correlation: ');
  for i := length(AllCorrStocks)-1 downTo 0 do
    begin
      DisplayAllMemo.Lines.Add(MyFileNames[AllCorrStocks[i].Stock1]+'-'+
       MyFileNames[AllCorrStocks[i].Stock2] + ' ('+ AllCorrStocks[i].startDate+' - '
       + AllCorrStocks[i].endDate+') ' + ': ' +
       floattostrF(AllCorrStocks[i].CorrValue, ffnumber, 4,5));
    end;

end;

procedure TStockProgram.UltimateMovAverageBttnClick(Sender: TObject);
type
  TAFastL= array[0..1] of TFastLineSeries;
var
  MyAverageSeries: TAFastL;
  maxData, pointer: integer;
begin
  //maxDataNum:= 2;
  //SetLength(MyAverageSeries, maxDataNum);
  pointer:= strtoint(MovAverageIndexEdit.Text);
  MyAverageSeries[pointer] := TFastLineSeries.Create( Self );
  MyAverageSeries[pointer].ParentChart := Graph;
  MyAverageSeries[pointer].Color:= clMaroon;
end;

procedure TStockProgram.HideAll(Sender: TObject);
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

end;

procedure TStockProgram.MaxDataBttnClick(Sender: TObject);
var
  i: integer;
begin
if strtoint(MaxDataEdit.Text)>=5 then
  begin
  MaxDataNum:= strtoint(MaxDataEdit.Text);
  SetLength(ListArrayLengths, MaxDataNum);
  SetLength(MyFileNames, MaxDataNum);
  SetLength(MyPulledStocks, MaxDataNum);
  MaxDataEdit.Text:= 'Yes';
  end
else
  MaxDataEdit.Text:= '5';

  for i := 0 to length(MyPulledStocks)-1 do
    begin
      MyPulledStocks[i]:= nil;
    end;
end;

procedure TStockProgram.MovingAverage2BttnClick(Sender: TObject);
var
  i, StockIndex, period: integer;
begin
  if strtoint(MovingValue2Edit.Text)>0 then
    period:= (strtoint(MovingValue2Edit.Text))
  else
    MovingValue2Edit.Text:= 'Value greater than 0';

  StockIndex:= strtoint(StockIndexEdit.Text);
  MovingSeries2.Free;
  MovingSeries2 := TFastLineSeries.Create( Self );
  MovingSeries2.ParentChart := Graph;
  MovingSeries2.Color:= clMaroon;
  MovingSeries2.LegendTitle:= inttostr(period)+ ' Moving Average';

  StockIndex:= strtoint(StockIndexEdit.Text);
  MakeAverageList(period, 1, StockIndex);

  With MovingSeries2 do
    begin
      for i := 0 to length(MyStockAverage[1])-1 do
        begin
          ADDXY(i+period-1, MyStockAverage[1][i], '', clMaroon);
        end;
    end;
end;

procedure TStockProgram.MovingDayAverage1BttnClick(Sender: TObject);
var
  i, period, StockIndex: integer;
begin
  if strtoint(DayMovingValueEdit.Text)>0 then
    period:= (strtoint(DayMovingValueEdit.Text))
  else
    DayMovingValueEdit.Text:= 'Value greater than 0';

  MovingSeries.Free;
  MovingSeries := TFastLineSeries.Create( Self );
  MovingSeries.ParentChart := Graph;
  MovingSeries.Color:= clGreen;
  MovingSeries.LegendTitle:= inttostr(period)+' Moving Average';

  StockIndex:= strtoint(StockIndexEdit.Text);
  MakeAverageList(period, 0, StockIndex);

  With MovingSeries do
    begin
      for i := 0 to length(MyStockAverage[0])-1 do
        begin
          ADDXY(i+period-1, MyStockAverage[0][i], '', clGreen);
        end;
    end;
end;

procedure TStockProgram.New1Click(Sender: TObject);
//var
  //IntroMemo: TMemo;
  //MaxDataEdit: TEdit;
begin
  HideAll(Sender);

  //IntroMemo:= TMemo.Create(Self);
  //IntroMemo.Parent:= StockProgram;
  IntroMemo.Clear;
  IntroMemo.Left:= 200;
  IntroMemo.Top:= 75;
  IntroMemo.Height:= 80;
  IntroMemo.Width:= 400;
  IntroMemo.Lines.Add('Intro');
  IntroMemo.Lines.Add('This is a program, that can be used to visualise, stocks and shares');
  IntroMemo.Lines.Add('To start get choose a max amount of data below min. 5.');
  IntroMemo.Lines.Add('Then locate your files from the retrieve data Tab');
  IntroMemo.Lines.Add('Then explore some of the menu function');
  IntroMemo.Visible:=True;

  MaxQuantLabel.Left:= 245;
  MaxQuantLabel.Top:= 218;
  MaxQuantLabel.Caption:= 'Max. Data';
  MaxQuantLabel.Visible:= True;

  //MaxDataEdit.Create(Self);
  //MaxDataEdit.Parent:= StockProgram;
  MaxDataEdit.Left:= 300;
  MaxDataEdit.Top:= 215;
  MaxDataEdit.Visible:= True;

  MaxDataBttn.Left:= 355;
  MaxDataBttn.Top:= 215;
  MaxDataBttn.Visible:= True;

  RestartBttn.Left:= 351;
  RestartBttn.Top:= 250;
  RestartBttn.Visible:= True;

end;

procedure TStockProgram.AICorrBttnClick(Sender: TObject);
var
  i, j, numStocks, paslow, dateLine1, dateLine2,
               dateLine3, dateLine4, recordLength, n: integer;
  corr: real;

begin
  n:=0;
  numStocks:= CheckPopStock();
  recordLength:= PascalsLength(numStocks);
  SetLength(AllCorrStocks, recordLength);
  for i := 0 to numStocks-1 do
    begin
      paslow:= i+1;
      for j := paslow to numStocks-1 do
        begin
          StockCorr1Edit.Text:= inttostr(i);
          StockCorr2Edit.Text:= inttostr(j);
          dateLine1:=0;
          dateLine2:=0;
          dateLine3:= MyPulledStocks[i].GetSize-1;
          dateLine4:= MyPulledStocks[j].GetSize-1;
          corr:= Correlation(i,j,dateLine1,dateLine2, dateLine3, dateLine4);
          with AllCorrStocks[n] do
            begin
              Stock1:= i;
              Stock2:= j;
              CorrValue:= corr;
              startDate:= MyPulledStocks[i].GetData(dateLine1).GetDate;
              endDate:= MyPulledStocks[i].GetData(dateLine3).GetDate;
            end;

          inc(n);
        end;
    end;

  PerformMerge(0, recordLength-1);
end;

procedure TStockProgram.AnalysisClick(Sender: TObject);
begin
  HideAll(Sender);

  DisplayAllMemo.Clear;
  DisplayAllMemo.Top:= 75;
  DisplayAllMemo.Left:= 100;
  DisplayAllMemo.Width:= 550;
  DisplayAllMemo.Height:= 200;
  DisplayAllMemo.Visible:= True;

  CorrelationBttn.Top:= 300;
  CorrelationBttn.Left:= 100;

  StockCorr1Edit.Top:= 350;
  StockCorr1Edit.Left:= 100;
  StockCorr2Edit.Top:= 400;
  StockCorr2Edit.Left:= 100;

  DateCorrEndEdit.Left:= 250;
  DateCorrEndEdit.Top:= 338;
  EndCorrLabel.Left:= 200;
  EndCorrLabel.Top:= 340;

  DateCorrStartEdit.Left:=250;
  DateCorrStartEdit.Top:= 308;
  StartCorrLabel.Left:= 195;
  StartCorrLabel.Top:= 310;

  ClearDataBttn.Left:= 395;
  ClearDataBttn.Top:= 300;

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
  DisplayAllMemo.Lines.Clear;
end;

procedure TStockProgram.ClearGraphBttnClick(Sender: TObject);
begin
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
  index1:= strtoint(StockCorr1Edit.Text);
  index2:= strtoint(StockCorr2Edit.Text);
  date:= DateCorrStartEdit.Text;
  endDate:= DateCorrEndEdit.Text;

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

procedure TStockProgram.CreateGraphBttnClick(Sender: TObject);
var
i, StockIndex: integer;
begin
i:=0;
StockSeries1.Clear;
StockIndex:= strtoint(StockIndexEdit.Text);
StockSeries1.LegendTitle:= MyFileNames[StockIndex];
With StockSeries1 do
  begin
      for i := 0 to (ListArrayLengths[StockIndex]-1) do
        Add(MyPulledStocks[StockIndex].GetData(i).GetOpen,'',clRed);
  end;
end;

procedure TStockProgram.DeleteDataBttnClick(Sender: TObject);
var
  i: integer;
begin
MyPulledStocks[strtoint(QuantPullEdit.Text)]:= nil;
MyFileNames[strtoint(QuantPullEdit.Text)]:= '';

StockPulledMemo.Clear;
StockPulledMemo.Lines.Add('Stocks Pulled: ');

for i := 0 to length(MyFileNames)-1 do
  StockPulledMemo.Lines.Add(inttostr(i) +': '+ MyFileNames[i]);
end;

procedure TStockProgram.Display1Click(Sender: TObject);
begin
  HideAll(Sender);

  DisplayAllMemo.Top:= 75;
  DisplayAllMemo.Left:= 100;
  DisplayAllMemo.Width:= 550;
  DisplayAllMemo.Height:= 200;

  DisplayBttn.Top:= 375;
  DisplayLineBttn.Top:= 325;
  lineValueEdit.Top:= 337;
  ClearDataBttn.Left:= 140;
  ClearDataBttn.Top:= 425;

  StockIndexEdit.Top:= 384;
  StockIndexEdit.Left:= 90;
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

begin
  StockIndex:= strtoint(StockIndexEdit.Text);
  DisplayAllMemo.Lines.Add('Data Requested: ');
    for n := 0 to (ListArrayLengths[StockIndex]-1) do //Iteration length variable had to minus 1 as starts from 0.
      begin
        DisplayAllMemo.Lines.Add(inttostr(n)+ ': '+ MyPulledStocks[StockIndex].Display(n));
      end;
end;

procedure TStockProgram.PullDatBttnClick(Sender: TObject);
var
  temp: string;
  i: integer;
begin
  if fileexists(StockNameEdit.Text)=True then
    begin
      counter:= strtoint(QuantPullEdit.Text);

      StockPulledMemo.Clear;
      temp:= StockNameEdit.Text;
      MyFileNames[counter]:= temp;
      StockPulledMemo.Lines.Add('Stocks Pulled:');

      for i := 0 to length(MyFileNames)-1 do
        StockPulledMemo.Lines.Add(inttostr(i) +': '+ MyFileNames[i]);

      assignfile(dataFile1, StockNameEdit.Text);
      reset(dataFile1);
      ListArrayLengths[counter]:= FindLength();
      closefile(dataFile1);

      MyPulledStocks[counter]:= TStock.Create(StockNameEdit.Text, ListArrayLengths[counter]);
      inc(counter);

      if counter>(MaxDataNum-1) then
        counter:=0;

      QuantPullEdit.Text:= inttostr(counter);
      StockNameEdit.Text:= 'Success';
    end
  else
    begin
      StockNameEdit.Text:= 'No File Found';
    end;
end;

procedure TStockProgram.RestartBttnClick(Sender: TObject);
var
  i: integer;
begin

  counter:= 0;
  QuantPullEdit.Text:= inttostr(counter);
  StockNameEdit.Text:= 'Example.txt';

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

  SetLength(ListArrayLengths, MaxDataNum);
  SetLength(MyFileNames, MaxDataNum);
  SetLength(MyPulledStocks, MaxDataNum);

  for i := 0 to length(MyPulledStocks)-1 do
    begin
      MyPulledStocks[i]:= nil;
    end;

  StockPulledMemo.Lines.Add('Stocks Pulled:');
  ShowMessage('Program Started');
  New1Click(Sender);
end;

procedure TStockProgram.RetrieveData1Click(Sender: TObject);
var
  n:integer;

begin
  HideAll(Sender);
  n:= (MaxDataNum-1);
  FileNameLabel.Visible:= True;
  DeleteDataBttn.Visible:=True;
  StockPulledMemo.Visible:= True;
  StockNameEdit.Visible:= True;
  PullDatBttn.Visible:= True;
  IndexLabel.Visible:= True;
  QuantPullEdit.Visible:= True;
  MaxQuantLabel.Visible:= True;

  StockNameEdit.Left:= 280;
  StockNameEdit.Top:= 150;
  FileNameLabel.Top:= 130;
  FileNameLabel.Left:= 280;
  PullDatBttn.Left:= 220;
  PullDatBttn.Top:= 250;
  DeleteDataBttn.Top:= 250;
  DeleteDataBttn.Left:= 350;

  QuantPullEdit.Left:= 200;
  QuantPullEdit.Top:= 150;
  QuantPullEdit.Width:= 20;
  IndexLabel.Left:= 100;
  IndexLabel.Top:= 154;
  MaxQuantLabel.Left:= 100;
  MaxQuantLabel.Top:= 180;
  MaxQuantLabel.Caption:= 'Max Quantity of Stocks: ' + inttostr(n+1);
  StockPulledMemo.Left:= 480;
  StockPulledMemo.Height:= 150;
  StockPulledMemo.Top:= 150;
end;
end.

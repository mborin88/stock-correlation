unit UStockObjectsv6;
{
Version 6 supports the newer UI which entales the new windows system.
Also accomodates new features such as pulling multiple stocks now which allows for data comparison
Has new feature for these new features such as deleting certain pieces of data
 }
interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, VclTee.TeeGDIPlus, VCLTee.TeEngine,
  VCLTee.Series, Vcl.ExtCtrls, VCLTee.TeeProcs, VCLTee.Chart, Vcl.StdCtrls,
  UStock6, Vcl.Menus;

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
    Exit1: TMenuItem;
    IntroMemo: TMemo;
    IndexLabel: TLabel;
    QuantPullEdit: TEdit;
    MaxQuantLabel: TLabel;
    StockPulledMemo: TMemo;
    DeleteDataBttn: TButton;
    FileNameLabel: TLabel;
    ClearDataBttn: TButton;
    StockIndexEdit: TEdit;
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
    procedure Exit1Click(Sender: TObject);
    procedure ClearDataBttnClick(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;
type
  TFileNames = array of string;
  TArrayLengths = array of integer;
  TPulledStocks = array of TStock;

var
  StockProgram: TStockProgram;
  name: string;
  dataFile1: textfile;
  arrayLength, counter, MaxDataNum, StockIndex: integer;
  MyData: TData;
  ListArrayLengths: TArrayLengths;
  MyPulledStocks: TPulledStocks;
  MyFileNames: TFileNames;

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

procedure TStockProgram.DisplayLineBttnClick(Sender: TObject);
begin
StockIndex:= strtoint(StockIndexEdit.Text);
DisplayAllMemo.Lines.Add('Data Requested: ');
DisplayAllMemo.Lines.Add(MyFileNames[StockIndex]+':   '+MyPulledStocks[StockIndex].Display(strtoint(lineValueEdit.Text)));
DisplayAllMemo.Lines.Add('');
end;

procedure TStockProgram.Exit1Click(Sender: TObject);
begin
HideAll(Sender);
end;

procedure TStockProgram.Graphing1Click(Sender: TObject);
begin
HideAll(Sender);
StockIndexEdit.Left:= 75;
StockIndexEdit.Top:= 290;
StockIndexEdit.Visible:= True;
Graph.Visible:= True;
CreateGraphBttn.Visible:= True;
DayMovingValueEdit.Visible:= True;
MovingDayAverage1Bttn.Visible:= True;
MovingValue2Edit.Visible:= True;
MovingAverage2Bttn.Visible:= True;
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
end;

procedure TStockProgram.MovingAverage2BttnClick(Sender: TObject);
var
  avg, total: real;
  i,n, lower, higher: integer;
begin
  higher:= (strtoint(MovingValue2Edit.Text));
  lower:= 1;

  StockIndex:= strtoint(StockIndexEdit.Text);
  MovingSeries2.Free;
  MovingSeries2 := TFastLineSeries.Create( Self );
  MovingSeries2.ParentChart := Graph;
  MovingSeries2.Color:= clMaroon;

  With MovingSeries2 do
    begin
      for n := 0 to ((ListArrayLengths[StockIndex]-higher)-1) do
        begin
          total:= 0;
          for i := lower to higher do
            begin
            total:= total+ MyPulledStocks[StockIndex].GetData(i).GetOpen();
            end;
          avg:= total/strtoint(MovingValue2Edit.Text);
          if avg>0 then
            AddXY((n+strtoint(MovingValue2Edit.Text)), avg,'', clGreen);

          inc(lower);
          if higher<(ListArrayLengths[StockIndex]-1) then
            inc(higher);
        end;
    end;
end;

procedure TStockProgram.MovingDayAverage1BttnClick(Sender: TObject);
var
avg, total: real;
i,n, lower, higher: integer;
begin
higher:= (strtoint(DayMovingValueEdit.Text));
lower:= 1;

MovingSeries.Free;
MovingSeries := TFastLineSeries.Create( Self );
MovingSeries.ParentChart := Graph;
MovingSeries.Color:= clGreen;

StockIndex:= strtoint(StockIndexEdit.Text);

With MovingSeries do
  begin
    for n := 0 to ((ListArrayLengths[StockIndex]-higher)-1) do
      begin
        total:= 0;
        for i := lower to higher do
          begin
          total:= total+ MyPulledStocks[StockIndex].GetData(i).GetOpen();
          end;
        avg:= total/strtoint(DayMovingValueEdit.Text);
        if avg>0 then
          AddXY((n+strtoint(DayMovingValueEdit.Text)), avg,'',clGreen);
        inc(lower);
        if higher<(ListArrayLengths[StockIndex]-1) then
          inc(higher);
      end;
  end;
end;

procedure TStockProgram.New1Click(Sender: TObject);
var
  i: integer;
begin
  HideAll(Sender);

  IntroMemo.Visible:=True;
  IntroMemo.Left:= 280;
  IntroMemo.Top:= 75;
  IntroMemo.Height:= 80;
  IntroMemo.Lines.Add('This is a program, that can be used to visualise, stocks and shares');
  IntroMemo.Lines.Add('To start get click retrieve data, and locate the file');

  MaxDataNum:=5;      // MaxData of stocks stored change for greater storage of stocks.
  counter:= 0;
  QuantPullEdit.Text:= inttostr(counter);

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
end;

procedure TStockProgram.ClearDataBttnClick(Sender: TObject);
begin
DisplayAllMemo.Lines.Clear;
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
i:=0;
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
n: integer;
line:string;

begin
n:=0;
StockIndex:= strtoint(StockIndexEdit.Text);
DisplayAllMemo.Lines.Add('Data Requested: ');
  for n := 0 to (ListArrayLengths[StockIndex]-1) do//Iteration length variable had to minus 1 as starts from 0.
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
      i:=0;

      counter:= strtoint(QuantPullEdit.Text);

      StockPulledMemo.Clear;
      temp:= StockNameEdit.Text;
      //insert(temp, MyFileNames, counter);
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

      if counter>4 then
        counter:=0;

      QuantPullEdit.Text:= inttostr(counter);
      StockNameEdit.Text:= 'Success';
    end
  else
    begin
      StockNameEdit.Text:= 'No File Found';
    end;
end;

procedure TStockProgram.RetrieveData1Click(Sender: TObject);
var
  n:integer;

begin
  HideAll(Sender);
  n:= 4;
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
  MaxQuantLabel.Caption:= 'Max Quantity of Stocks: ' + inttostr(n);
  StockPulledMemo.Left:= 480;
  StockPulledMemo.Height:= 150;
  StockPulledMemo.Top:= 150;

end;
end.

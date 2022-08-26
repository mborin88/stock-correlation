unit UStockObjects;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, VclTee.TeeGDIPlus, VCLTee.TeEngine,
  VCLTee.Series, Vcl.ExtCtrls, VCLTee.TeeProcs, VCLTee.Chart, Vcl.StdCtrls,
  UStock5;

type
  TStockProgram = class(TForm)
    Graph: TChart;
    CreateGraph: TButton;
    Series1: TFastLineSeries;
    PullDatBttn: TButton;
    StockName: TEdit;
    DisplayBttn: TButton;
    Display: TMemo;
    DisplayLineBttn: TButton;
    lineValue: TEdit;
    MovingDayAverage1Bttn: TButton;
    DayMovingValue: TEdit;
    MovingSeries: TFastLineSeries;
    MovingAverage2Bttn: TButton;
    MovingValue2: TEdit;
    MovingSeries2: TFastLineSeries;
    procedure CreateGraphClick(Sender: TObject);
    procedure PullDatBttnClick(Sender: TObject);
    procedure DisplayBttnClick(Sender: TObject);
    procedure DisplayLineBttnClick(Sender: TObject);
    procedure MovingDayAverage1BttnClick(Sender: TObject);
    procedure MovingAverage2BttnClick(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;
type
  TFileNames = array of string;

var
  StockProgram: TStockProgram;
  name: string;
  dataFile1: textfile;
  arrayLength: integer;
  MyData: TData;
  MyStock: TStock;
  MyFileNames: TFileName;



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
Display.Lines.Add('Data Requested: ');
Display.Lines.Add(MyStock.Display(strtoint(lineValue.Text)));
Display.Lines.Add('');
end;

procedure TStockProgram.MovingAverage2BttnClick(Sender: TObject);
var
  avg, total: real;
  i,n, lower, higher: integer;
begin
  higher:= (strtoint(MovingValue2.Text));
  lower:= 1;


  MovingSeries2.Free;
  MovingSeries2 := TFastLineSeries.Create( Self );
  MovingSeries2.ParentChart := Graph;
  MovingSeries2.Color:= clMaroon;

  With MovingSeries2 do
    begin
      for n := 0 to ((arrayLength-higher)-1) do
        begin
          total:= 0;
          for i := lower to higher do
            begin
            total:= total+ MyStock.GetData(i).GetOpen();
            end;
          avg:= total/strtoint(MovingValue2.Text);
          //ShowMessage(avg);
          if avg>0 then
            //Add(avg,'',clBlue);
            AddXY((n+strtoint(MovingValue2.Text)), avg,'', clGreen);
          inc(lower);
          if higher<(arrayLength-1) then
            inc(higher);
        end;
    end;
end;

procedure TStockProgram.MovingDayAverage1BttnClick(Sender: TObject);
var
avg, total: real;
i,n, lower, higher: integer;
begin
higher:= (strtoint(DayMovingValue.Text));
lower:= 1;

MovingSeries.Free;
MovingSeries := TFastLineSeries.Create( Self );
MovingSeries.ParentChart := Graph;
MovingSeries.Color:= clBlue;

With MovingSeries do
  begin
    for n := 0 to ((arrayLength-higher)-1) do
      begin
        total:= 0;
        for i := lower to higher do
          begin
          total:= total+ MyStock.GetData(i).GetOpen();
          end;
        avg:= total/strtoint(DayMovingValue.Text);
        //ShowMessage(avg);
        if avg>0 then
          //Add(avg,'',clBlue);
          AddXY((n+strtoint(DayMovingValue.Text)), avg,'',clGreen);
        inc(lower);
        if higher<(arrayLength-1) then
          inc(higher);
      end;
  end;


end;

procedure TStockProgram.CreateGraphClick(Sender: TObject);
var
i: integer;
begin
i:=0;
With Series1 do
  begin
      for i := 0 to (arrayLength-1) do
        Add(MyStock.GetData(i).GetOpen,'',clRed);
  end;
end;

procedure TStockProgram.DisplayBttnClick(Sender: TObject);
var
n: integer;
line:string;

begin
n:=0;
Display.Lines.Add('Data Requested: ');
  for n := 0 to (arrayLength-1) do//Iteration length variable had to minus 1 as starts from 0.
    begin
      Display.Lines.Add(inttostr(n)+ ': '+ MyStock.Display(n));
    end;
end;


procedure TStockProgram.PullDatBttnClick(Sender: TObject);
begin
if fileexists(StockName.Text)=True then
  begin
    assignfile(dataFile1, StockName.Text);
    reset(dataFile1);
    arrayLength:= FindLength();

    MyStock:= TStock.Create(StockName.Text, arrayLength);
    //Display.Lines.Add(inttostr(MyStock.GetSize()));
    StockName.Text:= 'Success';
  end
else
  begin
    StockName.Text:= 'No File Found';
  end;
end;
end.

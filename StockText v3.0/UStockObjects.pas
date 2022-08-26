unit UStockObjects;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, VclTee.TeeGDIPlus, VCLTee.TeEngine,
  VCLTee.Series, Vcl.ExtCtrls, VCLTee.TeeProcs, VCLTee.Chart, Vcl.StdCtrls;

type
  TForm1 = class(TForm)
    Graph: TChart;
    CreateGraph: TButton;
    Series1: TFastLineSeries;
    PullDatBttn: TButton;
    StockName: TEdit;
    DisplayBttn: TButton;
    Display: TMemo;
    procedure CreateGraphClick(Sender: TObject);
    procedure PullDatBttnClick(Sender: TObject);
    procedure DisplayBttnClick(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

  TData= array of array of string;
var
  Form1: TForm1;
  name: string;
  dataFile1: textfile;
  arrayLength: integer;
  data: TData;


implementation

{$R *.dfm}

function FindLength(): integer;
var
count: integer;
hython: char;
begin
count:= 0;
while not eof (dataFile1) do
  begin
    read(dataFile1, hython);
    if hython = '-' then
      begin
        inc(count);
      end;
  end;
  count:=(count div 2);
  result:= count;
  //closefile(dataFile1);
end;

function MakeArray(length: integer): TData;
begin
SetLength(data, length, 7);
result:= data;
end;

procedure PullData();
var
  i, count,n,s: integer;
  line, chunk: string;
  first: boolean;
begin
    i:=0;
    chunk:= '';
    first:= True;
    while not eof(dataFile1) do
      begin
        readln(dataFile1, line);
        if length(line)>0 then
          begin
            n:=0;

            if first=True then
              count:=length(line);

            for s := 1 to count do
              begin
                if (line[s]=',') or (s=count) then
                  begin
                    data[i][n]:= chunk;
                    inc(n);
                    chunk:='';
                  end
                else
                  begin
                    chunk:= chunk+line[s];
                  end;
              end;
            inc(i);
          end;

      end;
    // line:=data[2555][34];
    closefile(dataFile1);
end;

procedure TForm1.CreateGraphClick(Sender: TObject);
var
i: integer;
begin
i:=0;
With Series1 do
  begin
      for i := 0 to 250 do
        Add(strtofloat(data[i][1]),'',clRed);
  end;
end;

procedure TForm1.DisplayBttnClick(Sender: TObject);
var
n,s: integer;
line:string;

begin
n:=0;
s:=0;
  for n := 0 to 10 do//Iteration length variable had to minus 1 as starts from 0.
    begin
      line:='';
      for s := 0 to 6 do
        begin
          //ShowMessage(data[n][s]);
          //Display.lines.Add(data[n][s]);
          line:=line+ data[n][s]+', ';
        end;
      Display.lines.Add(line);
      Display.Lines.Add(' ');
    end;
  //readln;
end;


procedure TForm1.PullDatBttnClick(Sender: TObject);
begin
if fileexists(StockName.Text)=True then
  begin
    assignfile(dataFile1, StockName.Text); //add a check for existing
    reset(dataFile1);

    arrayLength:= FindLength();
    reset(dataFile1);

    data:= MakeArray(arrayLength);
    PullData();
    StockName.Text:= 'Success';
  end
else
  begin
    StockName.Text:= 'No File Found!';
  end;

end;

end.

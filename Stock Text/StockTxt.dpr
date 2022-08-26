program StockTxt;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils;

type
  TData= array of array of string;
var
FileName: string;
myfile: textfile;
n, s, arrayLength: integer;
data: TData;
AVG: real;

function DayMovingAverage(days: integer; value: integer): real;
var
i: integer;
total: real;
begin
//Take an integer value from the user take the last days by using the i value of the
total:=0;
for i := 1 to days do
  begin
    total:=(total+strtoFloat(data[(length(data)-(i-1))][value]));
    //writeln(data[(length(data)-(i-1))][value]);
  end;

AVG:= total/days;
//writeln('total: ', FloattostrF(total,ffNumber, 8,5));
//writeln('Avg:', FloattostrF(AVG, ffNumber, 8, 5));
result := AVG;

end;

procedure PullData();
var
  i, count: integer;
  line, chunk: string;
  first: boolean;
begin
    i:=0;
    chunk:= '';
    first:= True;
    while not eof(myFile) do
      begin
        readln(myFile, line);
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
    closefile(myfile);
end;

procedure DisplayFile(iterationLength: integer);
begin
  for n := 0 to (iterationLength-1) do//Iteration length variable had to minus 1 as starts from 0.
    begin
      write(n,': ');
      for s := 0 to 6 do
        begin
          write(data[n][s]);
          write(',');
        end;
      readln;
      writeln;
    end;
  readln;
end;

function FindLength(): integer;
var
count: integer;
hython: char;
begin
count:= 0;
while not eof(myFile) do
  begin
    read(myFile,hython);   //Find all hythons(2 hythons for every date)
    if hython = '-' then
      begin
      inc(count);
      end;
  end;
  count:=(count div 2); //Half hython to find out how many dates there are
  result:= count;
end;

function MakeArray(length: integer): TData;
begin
SetLength(data, length, 7);
result:= data;
end;

begin
//Data, Open, High, Low, Close, Adj Close, Volume
writeln('Commence');
writeln('Enter name of the file you want to read');
readln(FileName);
assign(myFile, FileName);

reset(myfile);

arrayLength := FindLength();
reset(myFile);
data:= MakeArray(arrayLength);
PullData();
DisplayFile(arrayLength);
//AVG := DayMovingAverage(20, 2);
//writeln(floattostr(AVG));
readln;
end.

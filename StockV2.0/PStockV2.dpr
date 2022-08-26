program PStockV2;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  UStockv2 in 'UStockv2.pas';

var
  MyData: TData;
  MyStock: TStock;
  name: string;
  datavalue: integer;

begin
writeln('Commence program');
writeln('What is the name of the program');
readln(name);
writeln('The name of the file is ', name);
MyStock:= TStock.Create(name);
writeln('Success... i think');
readln;
writeln('What line do you want to read?');
readln(datavalue);
MyStock.Display(dataValue);;
readln;
end.

program StockV7;

uses
  Vcl.Forms,
  UStockObjectsv7 in '..\Stockv7.0 - Copy\UStockObjectsv7.pas' {StockProgram},
  UStock7 in '..\Stockv7.0 - Copy\UStock7.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TStockProgram, StockProgram);
  Application.Run;
end.

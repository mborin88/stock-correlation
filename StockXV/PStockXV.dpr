program PStockXV;

uses
  Vcl.Forms,
  UStockObjectsXV in 'UStockObjectsXV.pas' {StockProgram},
  UStockXV in 'UStockXV.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TStockProgram, StockProgram);
  Application.Run;
end.

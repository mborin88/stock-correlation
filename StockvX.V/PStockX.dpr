program PStockX;

uses
  Vcl.Forms,
  UStockObjectsvX in 'UStockObjectsvX.pas' {StockProgram},
  UStockX in 'UStockX.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TStockProgram, StockProgram);
  Application.Run;
end.

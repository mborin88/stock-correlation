unit UStockApi;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, REST.Types, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, Data.DB, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Grids, Vcl.DBGrids, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  REST.Response.Adapter, REST.Client, Data.Bind.Components,
  Data.Bind.ObjectScope, System.JSon;

type
  TForm1 = class(TForm)
    RESTClient1: TRESTClient;
    RESTRequest1: TRESTRequest;
    RESTResponse1: TRESTResponse;
    RESTResponseDataSetAdapter1: TRESTResponseDataSetAdapter;
    FDMemTable1: TFDMemTable;
    DataSource1: TDataSource;
    Panel1: TPanel;
    Edit1: TEdit;
    Button1: TButton;
    Memo1: TMemo;
    Memo2: TMemo;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  name1, name2, name3, name4: string;
  datafile: textfile;
  i, index: integer;
  check: boolean;
  temp, LJsonObj: TJsonObject;
  temp2:TJSonString;
  jval: TJSonValue;

implementation
{https://api.iextrading.com/1.0/stock/GOOG/chart/6m?format=csv}

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
//var
//  jValue: TJSONValue;
begin
    RESTClient1.BaseURL:= 'https://api.iextrading.com/1.0/stock/';
    RESTRequest1.Client:= RESTClient1;
    RESTRequest1.Response:= RESTResponse1;
    RESTRequest1.Resource:= 'GOOG/chart/5d';
    //RESTRequest1.AddParameter('StockID','GOOG');
    Memo1.Clear;

    //RESTRequest1.Params[0].Value:= Edit1.Text;
    RestRequest1.Execute;
    //Memo1.Lines.Add(RESTResponse1.JSONValue.ToString);
    //Memo1.Lines.Add(DataSource1.ToString);
    {name1:= RESTResponse1.JSONvalue.Format(4);
    name1:= RESTResponse1.JSONValue.ToString;
    //LJsonObj := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(name1), 0) as TJSONObject;
    temp2:= RESTResponse1.JSONValue.GetValue('open');
    temp2 := LJsonObj.GetValue('open') as TJSONString;
    Memo1.Lines.Add(temp2.Value);
    //dollar := blh.GetValue('dollar') as TJSONObject;
    }
    name3:= RESTResponse1.RootElement;
    Memo1.Lines.Add(name3);
    name2:= RESTResponse1.JSONValue.GetValue('open', RESTResponse1.JSONText);
    Memo1.Lines.Add(name1);
    Memo2.Lines.Add(name2);
end;

end.

unit UAPI;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, REST.Types, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, Data.DB, Vcl.StdCtrls, Vcl.Grids,
  Vcl.DBGrids, FireDAC.Comp.DataSet, FireDAC.Comp.Client, REST.Response.Adapter,
  REST.Client, Data.Bind.Components, Data.Bind.ObjectScope, Xml.xmldom,
  Xml.XMLIntf, Vcl.ExtCtrls, Vcl.DBCtrls, Xml.XMLDoc, Datasnap.DBClient,
  Datasnap.Provider, Vcl.Menus;

type
  TForm1 = class(TForm)
    RESTClient1: TRESTClient;
    RESTRequest1: TRESTRequest;
    RESTResponse1: TRESTResponse;
    RESTResponseDataSetAdapter1: TRESTResponseDataSetAdapter;
    FDMemTable1: TFDMemTable;
    DataSource1: TDataSource;
    DBGrid1: TDBGrid;
    Button1: TButton;
    Memo1: TMemo;
    Edit1: TEdit;
    Edit2: TEdit;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

type TRecord = record
  Date: string;
  Open, High, Low, Close: real;
  Vol, unAdjVol: integer;
  Change, changePerc, vwap: real;
  label1: string;
  ChangeOT: real;
end;

var
  Form1: TForm1;
  temp, temp2: string;
  field1, field2, field3, field4, field5, field6, field7, field8, field9,
    field10, field11, field12: TField;
  i: integer;
  a: array of TRecord;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
begin
RESTClient1.BaseURL:= 'https://api.iextrading.com/1.0/stock/';
RESTRequest1.Client:= RESTClient1;
RESTRequest1.Response:= RESTResponse1;
temp:= Edit1.Text;
temp2:= Edit2.Text;
RESTRequest1.Resource:= temp+'/chart/'+ temp2;
RestRequest1.Execute;

field1:= DataSource1.DataSet.FieldByName('date');
field2:= DataSource1.DataSet.FieldByName('open');
field3:= DataSource1.DataSet.FieldByName('high');
field4:= DataSource1.DataSet.FieldByName('low');
field5:= DataSource1.DataSet.FieldByName('close');
field6:= DataSource1.DataSet.FieldByName('Volume');
field7:= DataSource1.DataSet.FieldByName('unadjustedVolume');
field8:= DataSource1.DataSet.FieldByName('change');
field9:= DataSource1.DataSet.FieldByName('changePercent');
field10:= DataSource1.DataSet.FieldByName('vwap');
field11:= DataSource1.DataSet.FieldByName('label');
field12:= DataSource1.DataSet.FieldByName('changeOverTime');
i:= 0;

DataSource1.DataSet.First;
while not DataSource1.DataSet.Eof do
  begin
    inc(i);
    DataSource1.DataSet.Next;
  end;

DataSource1.DataSet.First;
SetLength(a, i);
i:=0;
while not DataSource1.DataSet.Eof do
  begin
    a[i].Date:= field1.Value;
    a[i].Open:= field2.Value;
    a[i].High:= field3.Value;
    a[i].Low:= field4.Value;
    a[i].Close:= field5.Value;
    a[i].Vol:= field6.Value;
    a[i].unAdjVol:= field7.Value;
    a[i].Change := field8.Value;
    a[i].changePerc:= field9.Value;
    a[i].vwap:= field10.Value;
    a[i].label1:= field11.Value;
    a[i].ChangeOT:= field12.Value;
    inc(i);
    DataSource1.DataSet.Next;
  end;
end;

end.

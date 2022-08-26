object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 503
  ClientWidth = 754
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object DBGrid1: TDBGrid
    Left = 8
    Top = 16
    Width = 369
    Height = 129
    DataSource = DataSource1
    TabOrder = 0
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
    Columns = <
      item
        Expanded = False
        FieldName = 'date'
        Width = 70
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'open'
        Width = 60
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'high'
        Width = 70
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'low'
        Width = 70
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'close'
        Width = 70
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'volume'
        Width = 70
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'unadjustedVolume'
        Width = 70
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'change'
        Width = 70
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'changePercent'
        Width = 70
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'vwap'
        Width = 70
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'label'
        Width = 70
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'changeOverTime'
        Width = 70
        Visible = True
      end>
  end
  object Button1: TButton
    Left = 488
    Top = 424
    Width = 75
    Height = 25
    Caption = 'Button1'
    TabOrder = 1
    OnClick = Button1Click
  end
  object Memo1: TMemo
    Left = 104
    Top = 384
    Width = 185
    Height = 89
    Lines.Strings = (
      'Memo1')
    TabOrder = 2
  end
  object Edit1: TEdit
    Left = 456
    Top = 328
    Width = 121
    Height = 21
    TabOrder = 3
  end
  object Edit2: TEdit
    Left = 456
    Top = 376
    Width = 121
    Height = 21
    TabOrder = 4
  end
  object RESTClient1: TRESTClient
    Accept = 'application/json, text/plain; q=0.9, text/html;q=0.8,'
    AcceptCharset = 'utf-8, *;q=0.8'
    BaseURL = 'https://api.iextrading.com/1.0/stock/GOOG/chart/5d'
    Params = <>
    Left = 96
    Top = 72
  end
  object RESTRequest1: TRESTRequest
    Client = RESTClient1
    Params = <>
    Response = RESTResponse1
    SynchronizedEvents = False
    Left = 216
    Top = 72
  end
  object RESTResponse1: TRESTResponse
    ContentType = 'application/json'
    Left = 336
    Top = 72
  end
  object RESTResponseDataSetAdapter1: TRESTResponseDataSetAdapter
    Active = True
    Dataset = FDMemTable1
    FieldDefs = <>
    Response = RESTResponse1
    Left = 336
    Top = 152
  end
  object FDMemTable1: TFDMemTable
    Active = True
    FieldDefs = <
      item
        Name = 'date'
        DataType = ftWideString
        Size = 255
      end
      item
        Name = 'open'
        DataType = ftWideString
        Size = 255
      end
      item
        Name = 'high'
        DataType = ftWideString
        Size = 255
      end
      item
        Name = 'low'
        DataType = ftWideString
        Size = 255
      end
      item
        Name = 'close'
        DataType = ftWideString
        Size = 255
      end
      item
        Name = 'volume'
        DataType = ftWideString
        Size = 255
      end
      item
        Name = 'unadjustedVolume'
        DataType = ftWideString
        Size = 255
      end
      item
        Name = 'change'
        DataType = ftWideString
        Size = 255
      end
      item
        Name = 'changePercent'
        DataType = ftWideString
        Size = 255
      end
      item
        Name = 'vwap'
        DataType = ftWideString
        Size = 255
      end
      item
        Name = 'label'
        DataType = ftWideString
        Size = 255
      end
      item
        Name = 'changeOverTime'
        DataType = ftWideString
        Size = 255
      end>
    IndexDefs = <>
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    StoreDefs = True
    Left = 336
    Top = 224
  end
  object DataSource1: TDataSource
    DataSet = FDMemTable1
    Left = 336
    Top = 304
  end
end

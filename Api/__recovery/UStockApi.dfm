object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 455
  ClientWidth = 757
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 757
    Height = 41
    Align = alTop
    Caption = 'Panel1'
    TabOrder = 0
    ExplicitWidth = 701
    object Edit1: TEdit
      Left = 288
      Top = 8
      Width = 121
      Height = 21
      TabOrder = 0
    end
    object Button1: TButton
      Left = 480
      Top = 6
      Width = 75
      Height = 25
      Caption = 'Button1'
      TabOrder = 1
      OnClick = Button1Click
    end
  end
  object Memo1: TMemo
    Left = 440
    Top = 71
    Width = 145
    Height = 170
    Lines.Strings = (
      'Memo1')
    TabOrder = 1
  end
  object Memo2: TMemo
    Left = 608
    Top = 71
    Width = 121
    Height = 162
    Lines.Strings = (
      'Memo2')
    TabOrder = 2
  end
  object DBGrid1: TDBGrid
    Left = 8
    Top = 56
    Width = 426
    Height = 153
    DataSource = DataSource1
    TabOrder = 3
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
    Columns = <
      item
        Expanded = False
        FieldName = 'id'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'title'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'id'
        Visible = True
      end
      item
        Expanded = False
        Visible = True
      end
      item
        Expanded = False
        Visible = True
      end
      item
        Expanded = False
        Visible = True
      end
      item
        Expanded = False
        Visible = True
      end
      item
        Expanded = False
        Visible = True
      end
      item
        Expanded = False
        Visible = True
      end
      item
        Expanded = False
        Visible = True
      end
      item
        Expanded = False
        Visible = True
      end
      item
        Expanded = False
        Visible = True
      end>
  end
  object RESTClient1: TRESTClient
    Accept = 'application/json, text/plain; q=0.9, text/html;q=0.8 '
    AcceptCharset = 'utf-8, *;q=0.8'
    Params = <>
    Left = 128
    Top = 104
  end
  object RESTRequest1: TRESTRequest
    Client = RESTClient1
    Params = <>
    Response = RESTResponse1
    SynchronizedEvents = False
    Left = 256
    Top = 104
  end
  object RESTResponse1: TRESTResponse
    ContentType = 'text/html'
    Left = 368
    Top = 104
  end
  object RESTResponseDataSetAdapter1: TRESTResponseDataSetAdapter
    Active = True
    Dataset = FDMemTable1
    FieldDefs = <>
    Response = RESTResponse1
    Left = 368
    Top = 192
  end
  object FDMemTable1: TFDMemTable
    Active = True
    FieldDefs = <
      item
        Name = 'id'
        DataType = ftWideString
        Size = 255
      end
      item
        Name = 'type'
        DataType = ftWideString
        Size = 255
      end
      item
        Name = 'title'
        DataType = ftWideString
        Size = 255
      end
      item
        Name = 'artist'
        DataType = ftWideString
        Size = 255
      end
      item
        Name = 'chordsPresent'
        DataType = ftWideString
        Size = 255
      end
      item
        Name = 'tabTypes'
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
    Left = 368
    Top = 264
  end
  object DataSource1: TDataSource
    DataSet = FDMemTable1
    Left = 368
    Top = 336
  end
end

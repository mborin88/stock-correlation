object StockProgram: TStockProgram
  Left = 0
  Top = 0
  ActiveControl = Graph
  Caption = 'Stock Program'
  ClientHeight = 657
  ClientWidth = 837
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object IndexLabel: TLabel
    Left = 48
    Top = 232
    Width = 80
    Height = 13
    Caption = 'Index Data Pull: '
  end
  object MaxQuantLabel: TLabel
    Left = 496
    Top = 224
    Width = 50
    Height = 13
    Caption = 'Max. Data'
  end
  object FileNameLabel: TLabel
    Left = 616
    Top = 392
    Width = 46
    Height = 13
    Caption = 'File Name'
  end
  object Graph: TChart
    Left = 8
    Top = 8
    Width = 718
    Height = 201
    Title.Text.Strings = (
      'Stocks')
    BottomAxis.Axis.Color = 1644167168
    BottomAxis.Axis.Width = 0
    View3D = False
    TabOrder = 0
    DefaultCanvas = 'TGDIPlusCanvas'
    PrintMargins = (
      15
      19
      15
      19)
    ColorPaletteIndex = 13
    object StockSeries1: TFastLineSeries
      LinePen.Color = 3513587
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
    end
    object MovingSeries: TFastLineSeries
      SeriesColor = clBlue
      LinePen.Color = clBlue
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
    end
    object MovingSeries2: TFastLineSeries
      SeriesColor = clMaroon
      Title = 'MovingSeries2'
      LinePen.Color = clMaroon
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
    end
  end
  object CreateGraphBttn: TButton
    Left = 135
    Top = 280
    Width = 97
    Height = 41
    Caption = 'Make graph'
    TabOrder = 1
    OnClick = CreateGraphBttnClick
  end
  object PullDatBttn: TButton
    Left = 135
    Top = 334
    Width = 97
    Height = 41
    Caption = 'Pull Data'
    TabOrder = 2
    OnClick = PullDatBttnClick
  end
  object StockNameEdit: TEdit
    Left = 8
    Top = 344
    Width = 121
    Height = 21
    TabOrder = 3
  end
  object DisplayBttn: TButton
    Left = 135
    Top = 381
    Width = 97
    Height = 44
    Caption = 'Display All Values'
    TabOrder = 4
    OnClick = DisplayBttnClick
  end
  object DisplayAllMemo: TMemo
    Left = 238
    Top = 280
    Width = 323
    Height = 145
    Lines.Strings = (
      'Display')
    TabOrder = 5
  end
  object DisplayLineBttn: TButton
    Left = 135
    Top = 424
    Width = 97
    Height = 39
    Caption = 'Display Line'
    TabOrder = 6
    OnClick = DisplayLineBttnClick
  end
  object lineValueEdit: TEdit
    Left = 8
    Top = 433
    Width = 121
    Height = 21
    TabOrder = 7
  end
  object MovingDayAverage1Bttn: TButton
    Left = 135
    Top = 462
    Width = 97
    Height = 35
    Caption = 'Plot Moving Day 1'
    TabOrder = 8
    OnClick = MovingDayAverage1BttnClick
  end
  object DayMovingValueEdit: TEdit
    Left = 8
    Top = 469
    Width = 121
    Height = 21
    TabOrder = 9
  end
  object MovingAverage2Bttn: TButton
    Left = 135
    Top = 503
    Width = 97
    Height = 34
    Caption = 'Plot Moving Day 2'
    TabOrder = 10
    OnClick = MovingAverage2BttnClick
  end
  object MovingValue2Edit: TEdit
    Left = 8
    Top = 509
    Width = 121
    Height = 21
    TabOrder = 11
  end
  object IntroMemo: TMemo
    Left = 512
    Top = 463
    Width = 185
    Height = 89
    Lines.Strings = (
      'Intro')
    TabOrder = 12
  end
  object QuantPullEdit: TEdit
    Left = 8
    Top = 251
    Width = 121
    Height = 21
    TabOrder = 13
    Text = '1'
  end
  object StockPulledMemo: TMemo
    Left = 280
    Top = 463
    Width = 185
    Height = 89
    Lines.Strings = (
      'StockPulledMemo')
    TabOrder = 14
  end
  object DeleteDataBttn: TButton
    Left = 608
    Top = 334
    Width = 97
    Height = 41
    Caption = 'Delete Data'
    TabOrder = 15
    OnClick = DeleteDataBttnClick
  end
  object ClearDataBttn: TButton
    Left = 608
    Top = 264
    Width = 89
    Height = 33
    Caption = 'Clear Data'
    TabOrder = 16
    OnClick = ClearDataBttnClick
  end
  object StockIndexEdit: TEdit
    Left = 352
    Top = 240
    Width = 25
    Height = 21
    TabOrder = 17
    Text = '0'
  end
  object MainMenu1: TMainMenu
    object MainMenu2: TMenuItem
      Caption = 'Main Menu'
      OnClick = HideAll
      object New1: TMenuItem
        Caption = 'New'
        OnClick = New1Click
      end
      object RetrieveData1: TMenuItem
        Caption = 'Retrieve Data'
        OnClick = RetrieveData1Click
      end
      object Graphing1: TMenuItem
        Caption = 'Graphing'
        OnClick = Graphing1Click
      end
      object Display1: TMenuItem
        Caption = 'Display'
        OnClick = Display1Click
      end
      object Exit1: TMenuItem
        Caption = 'Exit'
        OnClick = Exit1Click
      end
    end
  end
end

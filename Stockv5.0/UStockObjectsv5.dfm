object StockProgram: TStockProgram
  Left = 0
  Top = 0
  ActiveControl = Graph
  Caption = 'Stock Program'
  ClientHeight = 586
  ClientWidth = 739
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Graph: TChart
    Left = 8
    Top = 8
    Width = 718
    Height = 266
    Title.Text.Strings = (
      'Google')
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
    object Series1: TFastLineSeries
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
  object CreateGraph: TButton
    Left = 135
    Top = 280
    Width = 97
    Height = 41
    Caption = 'Make graph'
    TabOrder = 1
    OnClick = CreateGraphClick
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
  object StockName: TEdit
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
  object Display: TMemo
    Left = 238
    Top = 280
    Width = 488
    Height = 177
    Lines.Strings = (
      'Display')
    TabOrder = 5
  end
  object DisplayLineBttn: TButton
    Left = 135
    Top = 431
    Width = 97
    Height = 25
    Caption = 'Display Line'
    TabOrder = 6
    OnClick = DisplayLineBttnClick
  end
  object lineValue: TEdit
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
  object DayMovingValue: TEdit
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
  object MovingValue2: TEdit
    Left = 8
    Top = 509
    Width = 121
    Height = 21
    TabOrder = 11
  end
end

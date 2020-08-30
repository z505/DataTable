object frmMain: TfrmMain
  Left = 192
  Top = 114
  Caption = 'frmMain'
  ClientHeight = 641
  ClientWidth = 651
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PrintScale = poNone
  PixelsPerInch = 96
  TextHeight = 16
  object mStatus: TMemo
    Left = 10
    Top = 10
    Width = 531
    Height = 331
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Lines.Strings = (
      'Status:'
      '-----------')
    TabOrder = 0
  end
  object bAddItems: TButton
    Left = 544
    Top = 274
    Width = 94
    Height = 31
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'Add Items'
    TabOrder = 1
  end
  object bAccessData: TButton
    Left = 544
    Top = 349
    Width = 94
    Height = 31
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'Access Data'
    TabOrder = 2
  end
  object Button1: TButton
    Left = 544
    Top = 310
    Width = 94
    Height = 31
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'Button1'
    TabOrder = 3
  end
  object GroupBox1: TGroupBox
    Left = 15
    Top = 358
    Width = 481
    Height = 271
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'Table Experiment'
    TabOrder = 4
    object Label2: TLabel
      Left = 20
      Top = 20
      Width = 414
      Height = 32
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = 
        'This creates a table without SQL that is indexed by a key. It is' +
        ' like an associative array with multiple values insdead of just ' +
        'a key value pair'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -14
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsItalic]
      ParentFont = False
      WordWrap = True
    end
    object bAddRows: TButton
      Left = 40
      Top = 70
      Width = 121
      Height = 31
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = 'Add Rows'
      TabOrder = 0
      OnClick = bAddRowsClick
    end
    object bShowData: TButton
      Left = 40
      Top = 150
      Width = 121
      Height = 31
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = 'Show Row Data'
      TabOrder = 1
      OnClick = bShowDataClick
    end
    object bAddMoreRows: TButton
      Left = 40
      Top = 110
      Width = 121
      Height = 31
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = 'Add More Rows'
      TabOrder = 2
      OnClick = bAddMoreRowsClick
    end
    object bAdd10000: TButton
      Left = 260
      Top = 70
      Width = 111
      Height = 31
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = 'Add 10,000'
      TabOrder = 3
      OnClick = bAdd10000Click
    end
    object bAdd10000Data: TButton
      Left = 260
      Top = 122
      Width = 145
      Height = 25
      Caption = 'bAdd10000Data'
      TabOrder = 4
      OnClick = bAdd10000DataClick
    end
    object bShowPointerData: TButton
      Left = 40
      Top = 188
      Width = 135
      Height = 25
      Caption = 'bShowPointerData'
      TabOrder = 5
    end
  end
end

object frmMain: TfrmMain
  Left = 192
  Top = 114
  Width = 569
  Height = 640
  Caption = 'frmMain'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object mStatus: TMemo
    Left = 8
    Top = 8
    Width = 425
    Height = 265
    Lines.Strings = (
      'Status:'
      '-----------')
    TabOrder = 0
  end
  object bAddItems: TButton
    Left = 344
    Top = 280
    Width = 75
    Height = 25
    Caption = 'Add Items'
    TabOrder = 1
    OnClick = bAddItemsClick
  end
  object bAccessData: TButton
    Left = 328
    Top = 312
    Width = 75
    Height = 25
    Caption = 'Access Data'
    TabOrder = 2
    OnClick = bAccessDataClick
  end
  object Button1: TButton
    Left = 408
    Top = 312
    Width = 75
    Height = 25
    Caption = 'Button1'
    TabOrder = 3
    OnClick = Button1Click
  end
  object GroupBox1: TGroupBox
    Left = 40
    Top = 352
    Width = 385
    Height = 217
    Caption = 'Table Experiment'
    TabOrder = 4
    object Label2: TLabel
      Left = 16
      Top = 16
      Width = 333
      Height = 26
      Caption = 
        'This creates a table without SQL that is indexed by a key. It is' +
        ' like an associative array with multiple values insdead of just ' +
        'a key value pair'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsItalic]
      ParentFont = False
      WordWrap = True
    end
    object bAddRows: TButton
      Left = 32
      Top = 56
      Width = 97
      Height = 25
      Caption = 'Add Rows'
      TabOrder = 0
      OnClick = bAddRowsClick
    end
    object bShowData: TButton
      Left = 32
      Top = 120
      Width = 97
      Height = 25
      Caption = 'Show Data'
      TabOrder = 1
      OnClick = bShowDataClick
    end
    object bAddMoreRows: TButton
      Left = 32
      Top = 88
      Width = 97
      Height = 25
      Caption = 'Add More Rows'
      TabOrder = 2
      OnClick = bAddMoreRowsClick
    end
    object bAdd10000: TButton
      Left = 208
      Top = 56
      Width = 89
      Height = 25
      Caption = 'Add 10,000'
      TabOrder = 3
      OnClick = bAdd10000Click
    end
  end
end

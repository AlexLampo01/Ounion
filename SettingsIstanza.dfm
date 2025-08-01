object fSettingsIstanza: TfSettingsIstanza
  Left = 0
  Top = 0
  Caption = 'fSettingsIstanza'
  ClientHeight = 154
  ClientWidth = 614
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnShow = FormShow
  TextHeight = 15
  object lblUsername: TLabel
    Left = 308
    Top = 24
    Width = 59
    Height = 15
    Alignment = taCenter
    Caption = 'Username: '
  end
  object lblPassword: TLabel
    Left = 308
    Top = 56
    Width = 59
    Height = 15
    Alignment = taCenter
    Caption = 'Password: '
  end
  object lbServer: TListBox
    Left = 0
    Top = 0
    Width = 289
    Height = 154
    Align = alLeft
    ItemHeight = 15
    TabOrder = 0
    OnClick = lbServerClick
  end
  object btnConferma: TBitBtn
    Left = 531
    Top = 121
    Width = 75
    Height = 25
    Caption = 'Conferma'
    TabOrder = 1
    OnClick = btnConfermaClick
  end
  object edUsername: TEdit
    Left = 380
    Top = 21
    Width = 153
    Height = 19
    TabOrder = 2
  end
  object edPassword: TEdit
    Left = 380
    Top = 53
    Width = 153
    Height = 19
    TabOrder = 3
  end
end

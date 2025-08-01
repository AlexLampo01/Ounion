object fIstanza: TfIstanza
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'fIstanza'
  ClientHeight = 119
  ClientWidth = 319
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnClose = FormClose
  OnShow = FormShow
  TextHeight = 15
  object lblUsername: TLabel
    Left = 16
    Top = 16
    Width = 59
    Height = 15
    Caption = 'Username: '
  end
  object lblPassword: TLabel
    Left = 16
    Top = 53
    Width = 56
    Height = 15
    Caption = 'Password: '
  end
  object edUsername: TEdit
    Left = 92
    Top = 13
    Width = 121
    Height = 23
    TabOrder = 0
  end
  object edPassword: TEdit
    Left = 92
    Top = 50
    Width = 121
    Height = 23
    TabOrder = 1
  end
  object btnConferma: TButton
    Left = 220
    Top = 86
    Width = 75
    Height = 25
    Caption = 'Conferma'
    TabOrder = 2
    OnClick = btnConfermaClick
  end
end

object tQuestions: TtQuestions
  Left = 0
  Top = 0
  Caption = 'Domande sulle cipolle'
  ClientHeight = 442
  ClientWidth = 628
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnClose = FormClose
  OnCreate = FormCreate
  TextHeight = 15
  object pbLoading: TProgressBar
    Left = 0
    Top = 416
    Width = 628
    Height = 26
    Align = alBottom
    TabOrder = 0
  end
  object tTempoDomanda: TTimer
    OnTimer = tTempoDomandaTimer
    Left = 588
    Top = 332
  end
end

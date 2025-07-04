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
  object pUpper: TPanel
    Left = 0
    Top = 0
    Width = 628
    Height = 237
    Align = alTop
    TabOrder = 0
    object Image1: TImage
      Left = 1
      Top = 1
      Width = 626
      Height = 215
      Align = alClient
      ExplicitLeft = 240
      ExplicitTop = 128
      ExplicitWidth = 105
      ExplicitHeight = 105
    end
    object pbLoading: TProgressBar
      Left = 1
      Top = 216
      Width = 626
      Height = 20
      Align = alBottom
      TabOrder = 0
    end
  end
  object pnlRisposte: TPanel
    Left = 0
    Top = 237
    Width = 628
    Height = 205
    Align = alClient
    TabOrder = 1
    ExplicitLeft = 284
    ExplicitTop = 336
    ExplicitWidth = 185
    ExplicitHeight = 41
  end
  object tTempoDomanda: TTimer
    OnTimer = tTempoDomandaTimer
    Left = 608
  end
  object ILImmagini: TImageList
    Left = 604
    Top = 48
  end
end

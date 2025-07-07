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
    ExplicitWidth = 624
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
      ExplicitWidth = 622
    end
  end
  object pnlRisposte: TPanel
    Left = 0
    Top = 237
    Width = 628
    Height = 205
    Align = alClient
    TabOrder = 1
    ExplicitLeft = -1
    object lblQuestion: TLabel
      Left = 1
      Top = 1
      Width = 626
      Height = 21
      Align = alTop
      Alignment = taCenter
      Caption = 'Domanda'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      ExplicitWidth = 75
    end
    object btnRisposta1: TBitBtn
      Left = 8
      Top = 26
      Width = 213
      Height = 25
      Caption = 'Risposta'
      TabOrder = 0
    end
    object btnRisposta2: TBitBtn
      Left = 8
      Top = 72
      Width = 183
      Height = 25
      Caption = 'Risposta'
      TabOrder = 1
    end
    object btnRisposta3: TBitBtn
      Left = 8
      Top = 118
      Width = 213
      Height = 25
      Caption = 'Risposta'
      TabOrder = 2
    end
    object btnRisposta4: TBitBtn
      Left = 8
      Top = 164
      Width = 183
      Height = 25
      Caption = 'Risposta'
      TabOrder = 3
    end
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

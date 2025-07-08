object tQuestions: TtQuestions
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Domande sulle cipolle'
  ClientHeight = 442
  ClientWidth = 628
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
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
    object imgDomanda: TImage
      Left = 1
      Top = 1
      Width = 626
      Height = 215
      Align = alClient
      ExplicitLeft = 0
      ExplicitTop = 0
    end
    object pbLoading: TProgressBar
      Left = 1
      Top = 216
      Width = 626
      Height = 20
      Align = alBottom
      TabOrder = 0
      OnChange = pbLoadingChange
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
    ExplicitWidth = 624
    ExplicitHeight = 204
    object lblMaxPoint: TLabel
      Left = 584
      Top = 178
      Width = 34
      Height = 21
      Alignment = taCenter
      Caption = '/100'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      Visible = False
    end
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
      Visible = False
      ExplicitWidth = 75
    end
    object Label2: TLabel
      Left = 568
      Top = 178
      Width = 9
      Height = 21
      Alignment = taCenter
      Caption = '0'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      Visible = False
    end
    object btnRisposta1: TBitBtn
      Left = 8
      Top = 26
      Width = 213
      Height = 25
      Caption = 'Risposta'
      TabOrder = 0
      Visible = False
      OnClick = btnClick
    end
    object btnRisposta2: TBitBtn
      Left = 8
      Top = 72
      Width = 183
      Height = 25
      Caption = 'Risposta'
      TabOrder = 1
      Visible = False
      OnClick = btnClick
    end
    object btnRisposta3: TBitBtn
      Left = 8
      Top = 118
      Width = 213
      Height = 25
      Caption = 'Risposta'
      TabOrder = 2
      Visible = False
      OnClick = btnClick
    end
    object btnRisposta4: TBitBtn
      Left = 8
      Top = 164
      Width = 183
      Height = 25
      Caption = 'Risposta'
      TabOrder = 3
      Visible = False
      OnClick = btnClick
    end
  end
  object tTempoDomanda: TTimer
    Interval = 500
    OnTimer = tTempoDomandaTimer
    Left = 608
  end
  object tPoint: TTimer
    Interval = 10
    Left = 604
    Top = 96
  end
end

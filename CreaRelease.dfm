object fCreaRelease: TfCreaRelease
  Left = 0
  Top = 0
  Caption = 'fCreaRelease'
  ClientHeight = 504
  ClientWidth = 626
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  TextHeight = 15
  object pnlBottom: TPanel
    Left = 0
    Top = 472
    Width = 626
    Height = 32
    Align = alBottom
    TabOrder = 0
    ExplicitTop = 471
    ExplicitWidth = 622
    DesignSize = (
      626
      32)
    object btnConferma: TBitBtn
      Left = 536
      Top = 4
      Width = 75
      Height = 25
      Anchors = [akTop, akRight, akBottom]
      Caption = 'Conferma'
      TabOrder = 0
      OnClick = btnConfermaClick
      ExplicitLeft = 532
    end
    object btnSelezionaTutto: TBitBtn
      Left = 424
      Top = 4
      Width = 91
      Height = 25
      Anchors = [akTop, akRight, akBottom]
      Caption = 'Seleziona Tutto'
      Enabled = False
      TabOrder = 1
      OnClick = btnSelezionaTuttoClick
      ExplicitLeft = 420
    end
    object pbLoading: TProgressBar
      Left = 8
      Top = 4
      Width = 365
      Height = 25
      Anchors = [akLeft, akTop, akRight, akBottom]
      Max = 0
      Step = 1
      TabOrder = 2
      ExplicitWidth = 361
    end
  end
  object pnlCenter: TFlowPanel
    Left = 0
    Top = 0
    Width = 626
    Height = 472
    Align = alClient
    DoubleBuffered = True
    ParentDoubleBuffered = False
    TabOrder = 1
    ExplicitWidth = 622
    ExplicitHeight = 471
  end
end

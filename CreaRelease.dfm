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
    ExplicitWidth = 614
    DesignSize = (
      626
      32)
    object btnConferma: TBitBtn
      Left = 544
      Top = 4
      Width = 75
      Height = 25
      Anchors = [akTop, akRight, akBottom]
      Caption = 'Conferma'
      TabOrder = 0
      ExplicitLeft = 532
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
    ExplicitLeft = 256
    ExplicitTop = 160
    ExplicitWidth = 185
    ExplicitHeight = 41
  end
end

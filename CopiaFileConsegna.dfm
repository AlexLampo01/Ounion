object fCopiaFileConsegna: TfCopiaFileConsegna
  Left = 0
  Top = 0
  Caption = 'Copia File Consegna'
  ClientHeight = 442
  ClientWidth = 626
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  TextHeight = 15
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 626
    Height = 85
    Align = alTop
    TabOrder = 0
    ExplicitWidth = 628
    object pbLoading: TProgressBar
      Left = 1
      Top = 67
      Width = 624
      Height = 17
      Align = alBottom
      TabOrder = 0
      Visible = False
      ExplicitLeft = 0
      ExplicitTop = 55
      ExplicitWidth = 626
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 416
    Width = 626
    Height = 26
    Align = alBottom
    TabOrder = 1
    ExplicitWidth = 628
    object imgConfirm: TImage
      Left = 603
      Top = 3
      Width = 21
      Height = 19
      Picture.Data = {
        07544269746D617042010000424D420100000000000076000000280000001100
        0000110000000100040000000000CC0000000000000000000000100000001000
        0000000000000000BF0000BF000000BFBF00BF000000BF00BF00BFBF0000C0C0
        C000808080000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFF
        FF007777777777777777700000007777777777777777700000007777777774F7
        77777000000077777777444F77777000000077777774444F7777700000007000
        00444F44F7777000000070FFF444F0744F777000000070F8884FF0774F777000
        000070FFFFFFF07774F77000000070F88888F077774F7000000070FFFFFFF077
        7774F000000070F88777F07777774000000070FFFF00007777777000000070F8
        8707077777777000000070FFFF00777777777000000070000007777777777000
        0000777777777777777770000000}
      Transparent = True
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 85
    Width = 626
    Height = 331
    Align = alClient
    TabOrder = 2
    ExplicitLeft = 208
    ExplicitTop = 236
    ExplicitWidth = 185
    ExplicitHeight = 41
    object Panel4: TPanel
      Left = 1
      Top = 1
      Width = 624
      Height = 32
      Align = alTop
      TabOrder = 0
      ExplicitTop = -4
      object btnSelezionaTutto: TBitBtn
        Left = 313
        Top = 4
        Width = 41
        Height = 25
        Glyph.Data = {
          66010000424D6601000000000000760000002800000014000000140000000100
          040000000000F0000000204E0000204E00001000000000000000000000000000
          BF0000BF000000BFBF00BF000000BF00BF00BFBF0000C0C0C000808080000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00777777777777
          7777777700007777777777777777777700007777777777777777777700007777
          777777A77777777700007777777777AA7777777700007777777777AAA7777777
          00007777777777AAAA7777770000777AAAAAAAAAAAA777770000777AAAAAAAAA
          AAAA77770000777AAAAAAAAAAAAAA7770000777AAAAAAAAAAAAA27770000777A
          AAAAAAAAAAA2777700007772222222AAAA27777700007777777777AAA2777777
          00007777777777AA2777777700007777777777A2777777770000777777777727
          7777777700007777777777777777777700007777777777777777777700007777
          77777777777777770000}
        TabOrder = 0
      end
      object BitBtn1: TBitBtn
        Left = 270
        Top = 4
        Width = 41
        Height = 25
        Glyph.Data = {
          66010000424D6601000000000000760000002800000014000000140000000100
          040000000000F0000000204E0000204E00001000000000000000000000000000
          BF0000BF000000BFBF00BF000000BF00BF00BFBF0000C0C0C000808080000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00777777777777
          7777777700007777777777777777777700007777777777777777777700007777
          7777797777777777000077777777997777777777000077777779997777777777
          0000777777999977777777770000777779999999999997770000777799999999
          9999977700007779999999999999977700007771999999999999977700007777
          1999999999999777000077777199991111111777000077777719997777777777
          0000777777719977777777770000777777771977777777770000777777777177
          7777777700007777777777777777777700007777777777777777777700007777
          77777777777777770000}
        TabOrder = 1
      end
    end
    object Panel5: TPanel
      Left = 1
      Top = 33
      Width = 312
      Height = 297
      Align = alLeft
      TabOrder = 1
      object sgFile: TStringGrid
        Left = 1
        Top = 1
        Width = 310
        Height = 295
        Align = alClient
        ColCount = 1
        FixedCols = 0
        RowCount = 1
        FixedRows = 0
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goAlwaysShowEditor, goFixedRowDefAlign]
        TabOrder = 0
        Visible = False
        ExplicitLeft = -143
        ExplicitWidth = 455
      end
    end
    object Panel6: TPanel
      Left = 313
      Top = 33
      Width = 312
      Height = 297
      Align = alRight
      TabOrder = 2
      ExplicitLeft = 440
      object sgFileConfermati: TStringGrid
        Left = 1
        Top = 1
        Width = 310
        Height = 295
        Align = alClient
        ColCount = 1
        FixedCols = 0
        RowCount = 1
        FixedRows = 0
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goAlwaysShowEditor, goFixedRowDefAlign]
        TabOrder = 0
        Visible = False
        ExplicitLeft = 442
        ExplicitTop = 117
        ExplicitWidth = 455
        ExplicitHeight = 342
      end
    end
  end
end

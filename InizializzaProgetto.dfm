object fInizializzaProgetto: TfInizializzaProgetto
  Left = 0
  Top = 0
  Caption = 'Inizializza Progetto'
  ClientHeight = 504
  ClientWidth = 619
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
    Width = 225
    Height = 504
    Align = alLeft
    TabOrder = 0
    ExplicitHeight = 503
    object cbVersione: TComboBox
      Left = 40
      Top = 82
      Width = 145
      Height = 23
      TabOrder = 0
      Text = 'Versione OS1'
      OnEnter = cbVersioneEnter
    end
    object cbServer: TComboBox
      Left = 40
      Top = 160
      Width = 145
      Height = 23
      TabOrder = 1
      Text = 'Server'
      OnEnter = cbServerEnter
    end
    object cbDatabase: TComboBox
      Left = 40
      Top = 246
      Width = 145
      Height = 23
      TabOrder = 2
      Text = 'Database'
      OnChange = cbDatabaseChange
      OnEnter = cbDatabaseEnter
    end
    object cbDatabaseDitta: TComboBox
      Left = 40
      Top = 328
      Width = 145
      Height = 23
      TabOrder = 3
      Text = 'Database Ditta'
      OnEnter = cbDatabaseDittaEnter
    end
  end
  object Panel2: TPanel
    Left = 224
    Top = 0
    Width = 395
    Height = 41
    TabOrder = 1
    object btnCrea: TBitBtn
      Left = 334
      Top = 8
      Width = 49
      Height = 27
      Caption = 'Crea '
      Glyph.Data = {
        36030000424D3603000000000000360000002800000010000000100000000100
        1800000000000003000000000000000000000000000000000000202020404040
        4040404040404040404040404040404040404040404040404040404040404040
        404040404040402020207F7F7FC0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
        C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C04040407F7F7FC0C0C0
        C0C0C0C0C0C0909090808080B0B0B0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
        C0C0C0C0C0C0C04040407F7F7FC0C0C0C0C0C0309030008000608060808080B0
        B0B0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C04040407F7F7FC0C0C0
        30CF30008000008000008000608060808080B0B0B0C0C0C0C0C0C0C0C0C0C0C0
        C0C0C0C0C0C0C04040407F7F7FC0C0C000BF0000800000800000800000800060
        8060808080B0B0B0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C04040407F7F7FC0C0C0
        00BF00008000008000008000008000008000608060909090C0C0C0C0C0C0C0C0
        C0C0C0C0C0C0C04040407F7F7FC0C0C000BF0000800000800020DF20009F0000
        8000208020808080A0A0A0C0C0C0C0C0C0C0C0C0C0C0C04040407F7F7FC0C0C0
        90CF9000BF0000800080808030EF30009F00008000208020808080B0B0B0C0C0
        C0C0C0C0C0C0C04040407F7F7FC0C0C0C0C0C090CF9000DF00A0A0A0C0C0C030
        EF30009F00008000608060808080B0B0B0C0C0C0C0C0C04040407F7F7FC0C0C0
        C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C030EF30009F000080006080609090
        90C0C0C0C0C0C04040407F7F7FC0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
        C0C0C0C0C030EF30009F00208020808080A0A0A0C0C0C04040407F7F7FC0C0C0
        C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C030EF30009F002080
        20808080C0C0C04040407F7F7FC0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
        C0C0C0C0C0C0C0C0C0C0C030EF30009F00608060C0C0C04040407F7F7FC0C0C0
        C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C060DF
        6090B090C0C0C04040403F3F3F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F
        7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F202020}
      TabOrder = 0
      OnClick = btnCreaClick
    end
    object cbProgettoGiaEsistente: TCheckBox
      Left = 7
      Top = 13
      Width = 138
      Height = 17
      Caption = 'Progetto Gi'#224' Esistente'
      TabOrder = 1
    end
  end
  object dbDMIDatabasesMec: TXDatabase
    ConnectionName = 'Devart SQL Server'
    DriverName = 'DevartSQLServer'
    LoginPrompt = False
    Params.Strings = (
      'BlobSize=-1'
      'SchemaOverride=%.dbo'
      'HostName='
      'DataBase='
      'DriverName=DevartSQLServer'
      'User_Name='
      'Password='
      'LongStrings=True'
      'EnableBCD=True'
      'FetchAll=True'
      'UseUnicode=True'
      'IPVersion=IPv4')
    DatabaseName = 'MECToolsDatabaseDMI'
    TipoDataBase = tdbSconosciuto
    UsoMaiuscole = umNessuno
    Left = 71
    Top = 8
  end
  object qDatabase: TXQuery
    ReadOnly = True
    DatabaseName = 'MECToolsDatabaseDMI'
    SQL.Strings = (
      'SELECT name AS DatabaseName'
      'FROM sys.databases'
      'ORDER BY name;')
    Params = <>
    Esegui = True
    UsaDizionario = False
    XSQLIndex = 0
    Left = 19
    Top = 8
    object qDatabaseDatabaseName: TXStringField
      FieldName = 'DatabaseName'
      Size = 128
    end
  end
  object odSceltaProgettoEsistente: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <>
    Options = [fdoPickFolders]
    Left = 139
    Top = 8
  end
end

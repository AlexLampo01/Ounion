unit InizializzaProgetto;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Buttons,
  DBXDevartSQLServer, Data.DB, XTable, XDBClient, Data.SqlExpr;

type
  TfInizializzaProgetto = class(TForm)
    cbVersione: TComboBox;
    pnlCheckbox: TPanel;
    cbServer: TComboBox;
    cbDatabase: TComboBox;
    cbDatabaseDitta: TComboBox;
    dbDMIDatabasesMec: TXDatabase;
    qDatabase: TXQuery;
    qDatabaseDatabaseName: TXStringField;
    btnProgettoGiaEsistente: TBitBtn;
    odSceltaProgettoEsistente: TFileOpenDialog;
    lblUsername: TLabel;
    edUsername: TEdit;
    lblPassword: TLabel;
    edPassword: TEdit;
    cbRicordami: TCheckBox;
    btnConfermaUsername: TBitBtn;
    Panel3: TPanel;
    pnlUsernamePassword: TPanel;
    pnlRichiestaNome: TPanel;
    Label1: TLabel;
    edNomeProgetto: TEdit;
    cbVersioneAuto: TCheckBox;
    cbModificaDitta: TCheckBox;
    cbInizializzaGit: TCheckBox;
    btnConfermaNome: TBitBtn;
    lblVersioneOS1: TLabel;
    lblServer: TLabel;
    lblDatabase: TLabel;
    lblDatabaseDitta: TLabel;
    Panel1: TPanel;
    Label2: TLabel;
    Label3: TLabel;
    pnlModificaDitta: TPanel;
    btnModificaDitta: TBitBtn;
    edDitta: TEdit;
    lblDitta: TLabel;
    lblUtente: TLabel;
    edUtente: TEdit;
    Label4: TLabel;
    btnClose: TBitBtn;
    btnCloseNomeProgetto: TBitBtn;
    btnCloseModificaDitta: TBitBtn;
    Label5: TLabel;
    procedure cbVersioneEnter(Sender: TObject);
    procedure cbServerEnter(Sender: TObject);
    procedure cbDatabaseEnter(Sender: TObject);
    procedure cbDatabaseChange(Sender: TObject);
    procedure cbDatabaseDittaEnter(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnConfermaUsernameClick(Sender: TObject);
    procedure cbServerChange(Sender: TObject);
    procedure cbVersioneChange(Sender: TObject);
    procedure cbDatabaseDittaChange(Sender: TObject);
    procedure btnProgettoGiaEsistenteClick(Sender: TObject);
    procedure btnConfermaNomeClick(Sender: TObject);
    procedure btnModificaDittaClick(Sender: TObject);
    procedure edUtenteExit(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure btnCloseNomeProgettoClick(Sender: TObject);
  private
    procedure RiempiComboBox(Percorso : String);
    function GetServer: TStringList;
    procedure CreaCopiaProgetto(Percorso: String);
    procedure InizializzaDMI(Percorso: String);
    procedure CancellaDatabaseTemp(Codice: TStringList);
    procedure CancellaPathDizionario(Codice: TStringList);
    procedure SelezionaCartellaProgetto;
    procedure CreaConfig(Percorso: String);
    procedure SistemaRegSetUp;
    procedure InizializzaGit;
    procedure OpenRegSetUp;
    procedure OpenFork;
    function GetWindowsUsername: String;
    function CreaGitIgnore(Percorso: String): Boolean;
    procedure CreaFileIni;
    procedure ReadFileIni;
    procedure ControllaCheckBox;
    procedure SettaCheckBox;
  public
    Percorso, Server, Password, Username, NomeScelto, NumeroUtente, NomeDitta : String;
    ConfermataForm, StatoInizializzaGit, MostratiDatiUsernamePassword, StatoModificaDitta, StatoVersioneAutomatica, ProgettoEsistente : Boolean;
  end;

var
  fInizializzaProgetto: TfInizializzaProgetto;

implementation

uses
    System.IOUtils{, RichiestaNome, UsernamePassword}, IniFiles, System.Win.Registry, ShellApi;

{$R *.dfm}

procedure TfInizializzaProgetto.cbDatabaseChange(Sender: TObject);
begin
    lblDatabase.Visible := True;
    ControllaCheckBox;
end;

procedure TfInizializzaProgetto.cbDatabaseDittaChange(Sender: TObject);
begin
    lblDatabaseDitta.Visible := True;
    ControllaCheckBox;
end;

procedure TfInizializzaProgetto.cbDatabaseDittaEnter(Sender: TObject);
begin
    Server := cbServer.Text;
    if Server <> 'Server' then
    begin
        cbDatabase.Items.Clear;
        if dbDMIDatabasesMec.Connected = True then
            dbDMIDatabasesMec.Connected := False;
        dbDMIDatabasesMec.Params.Values['HostName'] := Server;
        dbDMIDatabasesMec.Connected := True;
        if qDatabase.Active then
            qDatabase.Close;
        qDatabase.Open;
        while not qDatabase.Eof do
        begin
            cbDatabaseDitta.Items.Add(qDatabase.FieldByName('DatabaseName').asString);
            qDatabase.Next;
        end;
    end
    else
        ShowMessage('Server non selezionato!');
end;

procedure TfInizializzaProgetto.cbDatabaseEnter(Sender: TObject);
var
    DatabaseOra : String;
    Visibile : Boolean;
begin
    Server := cbServer.Text;
    Visibile := False;
    if pnlUsernamePassword.Visible then
    begin
       ShowMessage('Inserisci Username e Password del server e conferma');
       Visibile := True;
    end;

    if (Server <> 'Server') and (not Visibile) then
    begin
        cbDatabase.Items.Clear;
        if dbDMIDatabasesMec.Connected = True then
            dbDMIDatabasesMec.Connected := False;
        dbDMIDatabasesMec.Params.Values['HostName'] := Server;
        dbDMIDatabasesMec.Connected := True;
        if qDatabase.Active then
            qDatabase.Close;
        qDatabase.Open;
        while not qDatabase.Eof do
        begin
            DatabaseOra := qDatabase.FieldByName('DatabaseName').asString;
            if Trim(LowerCase(DatabaseOra)).StartsWith('osilogon') then
            begin
                cbDatabase.Items.Add(DatabaseOra);
            end;
            qDatabase.Next;
        end;
    end;
end;
procedure TfInizializzaProgetto.cbServerChange(Sender: TObject);
begin
    MostratiDatiUsernamePassword    := True;
    pnlUsernamePassword.Align       := alTop;
    pnlUsernamePassword.Visible     := True;
    lblServer.Visible               := True;
    Server                          := cbServer.Text;
    ControllaCheckBox;
    ReadFileIni;
end;

procedure TfInizializzaProgetto.cbServerEnter(Sender: TObject);
var
    Server : TStringList;
begin
    Server := TStringList.Create;
    try
        Server := GetServer;
        cbServer.Items.Assign(Server);
    finally
        Server.Free;
    end;
end;

procedure TfInizializzaProgetto.cbVersioneChange(Sender: TObject);
begin
    lblVersioneOS1.Visible := True;
    ControllaCheckBox;
end;

procedure TfInizializzaProgetto.cbVersioneEnter(Sender: TObject);
begin
    Percorso := 'C:\OSItalia';
    RiempiComboBox(Percorso);
end;

procedure TfInizializzaProgetto.RiempiComboBox(Percorso: String);
var
  Cartella : String;
  Cartelle : TArray<String>;
  ListaCartelle : TStringList;
begin
  Cartelle := TDirectory.GetDirectories(Percorso);
  ListaCartelle := TStringList.Create;
  try
      for Cartella in Cartelle do
      begin
          if Trim(LowerCase(ExtractFileName(Cartella))).StartsWith('os1_') then
              ListaCartelle.Add(ExtractFileName(Cartella));
      end;

      cbVersione.Items.Assign(ListaCartelle);

  finally
      ListaCartelle.Free;
  end;
end;

function TfInizializzaProgetto.GetServer: TStringList;
var
    DocumentPath, Riga, RigaPresa : String;
    StringListCode, StringListServer, StringListTemp : TStringList;
    i : Integer;
begin
    DocumentPath := TPath.GetHomePath;
    DocumentPath := DocumentPath + '\Microsoft\SQL Server Management Studio\18.0\UserSettings.xml';
    StringListCode := TStringList.Create;
    StringListServer := TStringList.Create;
    StringListTemp := TStringList.Create;
    try
        StringListCode.LoadFromFile(DocumentPath);

        for i := 0 to StringListCode.Count - 1 do
        begin
            Riga := Trim(LowerCase(StringListCode[i]));
            if Riga.StartsWith('<instance>') then
            begin
                RigaPresa := Copy(Riga, Pos('>', Riga), Length(Riga));
                StringListServer.Add(Copy(RigaPresa, Pos('>', RigaPresa) + 1, Pos('<', RigaPresa) - Pos('>', RigaPresa) - 1));
            end;
        end;

        for i := 0 to StringListServer.Count - 1 do
        begin
            if StringListTemp.IndexOf(StringListServer[i]) = - 1 then
                StringListTemp.Add(StringListServer[i]);
        end;
    finally
        StringListCode.Free;
        StringListServer.Free;
    end;
    Result := StringListTemp;
end;

procedure TfInizializzaProgetto.CreaCopiaProgetto(Percorso: String);
var
    PercorsoCompleto, Base, Cartella, Errore : String;
    Cartelle : TArray<String>;
begin
    if cbVersione.Text <> 'Versione OS1' then
        PercorsoCompleto := Percorso + '\' + cbVersione.Text + '\Personalizzazioni'
    else
        Errore := Errore + 'Seleziona una versione di OS1, ';
    if cbServer.Text = 'Server' then
    begin
        Errore := Errore + 'Seleziona un Server, ';
    end;

    if cbDatabase.Text = 'Database' then
    begin
        Errore := Errore + 'Seleziona un Database, ';
    end;

    if Trim(Errore).EndsWith(',') then
        Errore := Copy(Errore, 1, Length(Errore) - 2);

    if not Errore.isEmpty then
        ShowMessage(Errore);

   if (PercorsoCompleto <> '') and (cbServer.Text <> 'Server') and (cbDatabase.Text <> 'Database') then
   begin
     Cartelle := TDirectory.GetDirectories(PercorsoCompleto);
     for Cartella in Cartelle do
      begin
          if Trim(LowerCase(ExtractFileName(Cartella))).StartsWith('_base') or Trim(LowerCase(ExtractFileName(Cartella))).StartsWith('base') then
            Base := ExtractFileName(Cartella);
      end;
      if Base <> '' then
      begin
          //TODO: Sistemare tutta la questione del file
          if NomeScelto <> '' then
          begin
              if ConfermataForm then
              begin
                TDirectory.Copy(PercorsoCompleto + '\' + Base, PercorsoCompleto + '\' + NomeScelto, True);
                InizializzaDMI(PercorsoCompleto + '\' + NomeScelto);
                Exit;
              end;
          end;
      end
      else
        ShowMessage('Versione base non trovata!');
   end;
end;

procedure TfInizializzaProgetto.InizializzaDMI(Percorso: String);
var
    Codice : TStringList;
    InObjectTemp, InObject, PathDizionarioSistemato, Database, HostName, UsernameBool, PasswordBool : Boolean;
    Riga, RigaSenzaApici, RigaDaRipartire, RigaModificata, PercorsoDatabaseTemp,
    PathDizionarioPercorso, PathDizionarioPercorsoBase, PathDizionarioPercorsoCompleto : String;
    i, j : integer;
begin
    Codice := TStringList.Create;
    InObject := False;
    InObjectTemp := False;
    HostName := False;
    Database := False;
    UserNameBool := False;
    PasswordBool := False;
    PathDizionarioSistemato := False;
    try
        Codice.LoadFromFile(Percorso + '\OS1Test\Src\DMI_Databases.dfm');
        CancellaPathDizionario(Codice);
        CancellaDatabaseTemp(Codice);
        for i := 0 to Codice.Count - 1 do
        begin
            Riga := Trim(LowerCase(Codice[i]));
            RigaSenzaApici := StringReplace(Riga,'''', '', [rfReplaceAll]);
            if Riga.StartsWith('object kdbbase') and not InObjectTemp and not InObject then
            begin
                InObject := True;
            end;
            if Riga.StartsWith('object kdbtemp') and not InObjectTemp and not InObject then
            begin
                InObjectTemp := True;
            end;
            if Riga.StartsWith('databasename =') then
            begin
               RigaDaRipartire := i.ToString;
               PathDizionarioSistemato := True;
            end;
            if RigaSenzaApici.StartsWith('hostname=') then
            begin
                HostName := True;
            end
            else if RigaSenzaApici.StartsWith('database=')  then
            begin
                Database := True;
            end
            else if RigaSenzaApici.StartsWith('user_name=')  then
            begin
                UserNameBool := True;
            end
            else if RigaSenzaApici.StartsWith('password=')  then
            begin
                PasswordBool := True;
            end;
            if InObject then
            begin
                if HostName then
                begin
                    RigaModificata := QuotedStr('HostName='+cbServer.Text);
                    HostName := False;
                    Codice[i] := '      '+ RigaModificata;
                end;
                if Database then
                begin
                    RigaModificata := QuotedStr('DataBase='+cbDatabaseDitta.Text);
                    Database := False;
                    Codice[i] := '      '+ RigaModificata;
                end;
                if UserNameBool then
                begin
                    RigaModificata := QuotedStr('User_Name=' + Username);
                    UserNameBool := False;
                    Codice[i] := '      '+ RigaModificata;
                end;
                if PasswordBool then
                begin
                    RigaModificata := QuotedStr('Password='+ Password);
                    PasswordBool := False;
                    Codice[i] := '      '+ RigaModificata;
                end;
                if Riga.StartsWith('end') then
                    InObject := False;
            end;
            if InObjectTemp then
            begin
                PercorsoDatabaseTemp := Percorso;
                for j := 1 to 3 do
                    PercorsoDatabaseTemp := ExtractFileDir(PercorsoDatabaseTemp);
                PercorsoDatabaseTemp := PercorsoDatabaseTemp+ '\' + cbVersione.Text +'\Personalizzazioni\' + NomeScelto + '\DBTemp\dbTemp.svi';
                if RigaSenzaApici.StartsWith('vendorlib=') then
                begin
                    PercorsoDatabaseTemp := '       ' + QuotedStr('Database='+ PercorsoDatabaseTemp);
                    Codice.Insert(i, PercorsoDatabaseTemp);
                    InObjectTemp := False;
                end;

            end;
            if PathDizionarioSistemato then
                begin
                    PathDizionarioPercorsoBase := Percorso + '\Dizionario\;';
                    PathDizionarioPercorso := Percorso + '\Custom\Dizionario\';

                    PathDizionarioPercorsoCompleto := 'PathDizionario = ' + QuotedStr(PathDizionarioPercorsoBase + PathDizionarioPercorso);
                    Codice.Insert(RigaDaRipartire.ToInteger + 1, '      '+PathDizionarioPercorsoCompleto);
                    PathDizionarioSistemato := False;
                end;
        end;
        Codice.SaveToFile(Percorso + '\OS1Test\Src\DMI_Databases.dfm');
    finally
        Codice.Free;
    end;
end;

procedure TfInizializzaProgetto.CancellaPathDizionario(Codice: TStringList);
var
    i: Integer;
    Riga : String;
    DaCancellare : Boolean;
begin
    DaCancellare := False;
    for i := Codice.Count - 1 downto 0 do
    begin
        Riga := Trim(LowerCase(Codice[i]));

        if Riga.StartsWith('tipodatabase =') then
        begin
            DaCancellare := True;
            Continue;
        end;
        if Riga.StartsWith('databasename =') then
        begin
            DaCancellare := False;
        end;
        if DaCancellare then
        begin
            Codice.Delete(i);
        end;
    end;
end;

procedure TfInizializzaProgetto.btnCloseClick(Sender: TObject);
begin
    Username                    := '';
    Password                    := '';
    cbServer.Text               := 'Server';
    lblServer.Visible           := False;
    pnlUsernamePassword.Visible := False;
    pnlUsernamePassword.Align   := alNone;
end;

procedure TfInizializzaProgetto.btnCloseNomeProgettoClick(Sender: TObject);
begin
    NomeScelto                  := '';
    Username                    := '';
    Password                    := '';
    cbVersione.Text             := 'Versione OS1';
    cbServer.Text               := 'Server';
    cbDatabase.Text             := 'Database';
    cbDatabaseDitta.Text        := 'Database Ditta';
    lblVersioneOS1.Visible      := False;
    lblServer.Visible           := False;
    lblDatabase.Visible         := False;
    lblDatabaseDitta.Visible    := False;
    pnlRichiestaNome.Visible    := False;
    pnlRichiestaNome.Align      := alNone;
end;

procedure TfInizializzaProgetto.btnConfermaNomeClick(Sender: TObject);
var
    Versione, PercorsoImpostazioni, Utente, Percorso : String;
    Ini : TIniFile;
begin
    if edNomeProgetto.Text <> '' then
    begin
        Versione := '';
        Percorso := 'C:\OSItalia';
        if cbVersioneAuto.Checked then
        begin
            Versione := cbVersione.Text;
            Versione := Copy(Versione, 4, Length(Versione));
        end;
        NomeScelto := Trim(edNomeProgetto.Text) + Versione;
        Utente := GetWindowsUsername;
        PercorsoImpostazioni := 'C:\Users\'+ Utente + '\AppData\Roaming\MECTools\MECToolsInizializzazione\Impostazioni.ini';
        Ini := TIniFile.Create(PercorsoImpostazioni);
        try
            Ini.WriteBool('Modifica Ditta', 'Attivo', cbModificaDitta.Checked);
            Ini.WriteBool('Versione Automatica', 'Attivo', cbVersioneAuto.Checked);
            Ini.WriteBool('Git Inizializzato', 'Attivo', cbInizializzaGit.Checked);
        finally
            Ini.Free;
        end;
        if cbModificaDitta.Checked then
        begin
            pnlModificaDitta.Align := alTop;
            pnlModificaDitta.Visible := True;

        end
        else
        begin
            ConfermataForm := True;
        end;
    end
    else
        ShowMessage('Scegli un nome!');
    if ConfermataForm then
    begin
        if cbServer.Text = 'Server' then
        begin
            ShowMessage('Seleziona un server');
        end
        else if (Username = '') or (Password = '') then
        begin
           //TfUsernamePassword.Create(nil);
        end
        else
        begin
            if not ProgettoEsistente then
                CreaCopiaProgetto(Percorso);
            if NomeScelto <> '' then
            begin
                CreaConfig(Percorso);
                SistemaRegSetUp;
                ShowMessage('Ricorda di mettere la password nel RegSetUp!');
                if StatoInizializzaGit then
                begin
                    InizializzaGit;
                end;
                OpenRegSetUp;
            end;
        end;

end;
end;

procedure TfInizializzaProgetto.btnConfermaUsernameClick(Sender: TObject);
var
    Errore : String;
begin
    if edUsername.Text <> '' then
        Username := edUsername.Text
    else
        Errore := Errore + 'Non hai inserito Username, ';
    if edPassword.Text <> '' then
        Password := edPassword.Text
    else
        Errore := Errore + 'Non hai inserito Password, ';

    if Errore <> '' then
    begin
        if Trim(Errore).EndsWith(',') then
            Errore := Copy(Errore, 1, Length(Errore) - 2);
        ShowMessage(Errore);
    end;

    if (edUsername.Text <> '') and (edPassword.Text <> '') then
    begin
        if cbRicordami.Checked then
        begin
            CreaFileIni;
        end;
    end;

    pnlUsernamePassword.Visible := False;
    pnlUsernamePassword.Align   := alNone;
end;

procedure TfInizializzaProgetto.btnModificaDittaClick(Sender: TObject);
var
    Errore : String;
    Valore : Integer;
begin
    if (edUtente.Text = '') or (not TryStrToInt(Trim(edUtente.Text), Valore)) then
        Errore := Errore + 'Inserisci un numero, ';
    if edDitta.Text = '' then
        Errore := Errore + 'Inserisci il nome della ditta, ';

    if Errore <> '' then
    begin
        Errore := Copy(Errore, 1, Length(Errore) - 2);
        ShowMessage(Errore);
    end;

    if Errore = '' then
    begin
        NomeDitta := edDitta.Text;
        NumeroUtente := IntToStr(Valore);
        ConfermataForm := True;
    end;

end;

procedure TfInizializzaProgetto.btnProgettoGiaEsistenteClick(Sender: TObject);
begin
    cbVersioneAuto.Checked   := False;
    cbVersioneAuto.Enabled   := False;
    cbInizializzaGit.Checked := False;
    cbInizializzaGit.Enabled := False;
    ProgettoEsistente        := True;
    SelezionaCartellaProgetto;
end;

procedure TfInizializzaProgetto.CancellaDatabaseTemp(Codice: TStringList);
var
    i, j, IndiceMassimo: Integer;
    Riga, RigaControllata, RigaSenzaApici : String;
    DaCancellare : Boolean;
begin
    DaCancellare := False;
    IndiceMassimo := 0;
    for i := Codice.Count - 1 downto 0 do
    begin
        Riga := Trim(LowerCase(Codice[i]));
        if Riga.StartsWith('object kdbtemp') then
        begin
            IndiceMassimo := i;
        end;

        if (IndiceMassimo > 0) then
        begin
            for j := Codice.Count - 1 downto 0 do
            begin
                RigaControllata := Trim(LowerCase(Codice[j]));
                RigaSenzaApici := StringReplace(RigaControllata,'''', '', [rfReplaceAll]);
                if RigaSenzaApici.StartsWith('user_name=') then
                begin
                    DaCancellare := True;
                    Continue;
                end;
                if RigaSenzaApici.StartsWith('vendorlib=') then
                begin
                    Continue;
                end;
                if RigaSenzaApici.StartsWith('libraryname=') then
                begin
                    DaCancellare := False;
                    Break;
                end;
                if DaCancellare then
                begin
                    Codice.Delete(j);
                end;
            end;
            IndiceMassimo := 0;
        end;
    end;
end;

procedure TfInizializzaProgetto.SelezionaCartellaProgetto;
var
    CartellaSelezionata, RicostruzioneNome : String;
    PrendoNome : Boolean;
    i : Integer;
begin
    RicostruzioneNome := '';
    PrendoNome := False;
    odSceltaProgettoEsistente.DefaultFolder := 'C:\OSItalia\'+ cbVersione.Text +'\Personalizzazioni';
   if odSceltaProgettoEsistente.Execute then
        CartellaSelezionata := odSceltaProgettoEsistente.FileName;
   if CartellaSelezionata.StartsWith('C:\OSItalia\'+ cbVersione.Text +'\Personalizzazioni\')  then
   begin
        for i := 1 to Length(CartellaSelezionata) do
        begin
            if CartellaSelezionata[i] = '\' then
            begin
                if not (LowerCase(RicostruzioneNome) = 'personalizzazioni') then
                    RicostruzioneNome := ''
                else
                begin
                    PrendoNome := True;
                    RicostruzioneNome := '';
                end;
            end
            else
            begin
                RicostruzioneNome := RicostruzioneNome + CartellaSelezionata[i];
            end;
            if PrendoNome and (i = Length(CartellaSelezionata)) then
            begin
                NomeScelto := RicostruzioneNome;
                StatoInizializzaGit := True;
                break;
            end;
        end;
        //InizializzaDMI(CartellaSelezionata);
        edNomeProgetto.Enabled := False;
        edNomeProgetto.Text := NomeScelto;
   end;
end;

procedure TfInizializzaProgetto.SettaCheckBox;
var
    Ini : TIniFile;
    Percorso, Utente : String;
begin
    Utente := GetWindowsUsername;
    Percorso := 'C:\Users\'+ Utente + '\AppData\Roaming\MECTools\MECToolsInizializzazione\Impostazioni.ini';
    Ini := TIniFile.Create(Percorso);
    try
       cbModificaDitta.Checked := Ini.ReadBool('Modifica Ditta', 'Attivo', True);
       cbVersioneAuto.Checked  := Ini.ReadBool('Versione Automatica', 'Attivo', True);
       cbInizializzaGit.Checked := Ini.ReadBool('Git Inizializzato', 'Attivo', True);
       StatoModificaDitta := Ini.ReadBool('Modifica Ditta', 'Attivo', True);
       StatoVersioneAutomatica := Ini.ReadBool('Versione Automatica', 'Attivo', True);
       StatoInizializzaGit := Ini.ReadBool('Git Inizializzato', 'Attivo', True);
    finally
        Ini.Free;
    end;
end;

procedure TfInizializzaProgetto.ControllaCheckBox;
begin
    if (cbVersione.Text <> 'Versione OS1') and (cbServer.Text <> 'Server') and (cbDatabase.Text <> 'Database') and (cbDatabaseDitta.Text <> 'Database Ditta')  then
    begin
        pnlRichiestaNome.Align   := alTop;
        pnlRichiestaNome.Visible := True;
        SettaCheckBox;
    end;
end;

procedure TfInizializzaProgetto.CreaConfig(Percorso : String);
var
    PercorsoCompleto, PercorsoCorto : String;
    PercorsoTrovato : Boolean;
    TStringContenutoFile : TStringList;
begin
    PercorsoTrovato := True;

    if NomeScelto <> '' then
    begin
        PercorsoCompleto := 'C:\OS1\OS1 LAUNCHER\Custom.Config\' + NomeScelto + '.config';
        PercorsoCorto := 'C:\OS1\OS1 LAUNCHER\Custom.Config';
    end;
    if not DirectoryExists(PercorsoCorto) then
    begin
        PercorsoCorto := 'C:\OS1\OS1LAUNCHER\Custom.Config' + NomeScelto + '.config';
        if not DirectoryExists(PercorsoCorto) then
        begin
            PercorsoCompleto := 'C:\OS1\OS1_LAUNCHER\Custom.Config' + NomeScelto + '.config';
        end;
        if not DirectoryExists(PercorsoCorto) then
        begin
            PercorsoTrovato := False;
        end;
    end;

    if (PercorsoCompleto <> '') and PercorsoTrovato then
    begin
        Percorso := Percorso + '\' + cbVersione.Text + '\Personalizzazioni\' + NomeScelto;
        if (NomeDitta = '') and (NumeroUtente = '') then
        begin
            NomeDitta := 'Base';
            NumeroUtente := '2';
        end;
        TStringContenutoFile := TStringList.Create;
        try
            TStringContenutoFile.Add('[Generale]');
            TStringContenutoFile.Add('Titolo=' + NomeScelto + ' su ' + '(' + cbServer.Text + ')');
            TStringContenutoFile.Add('PathBase=\\SRVXAPP\C\OS1\'+ cbVersione.Text + '\BIN');
            TStringContenutoFile.Add('');
            TStringContenutoFile.Add('[Programmi]');
            TStringContenutoFile.Add('OS1=OS1.exe');
            TStringContenutoFile.Add('OS1Config=OS1Config.exe');
            TStringContenutoFile.Add('XConfig=XConfig\XConfig.exe');
            TStringContenutoFile.Add('XSQLWin=Servizi\XSQLWin.exe');
            TStringContenutoFile.Add('');
            TStringContenutoFile.Add('[Path]');
            TStringContenutoFile.Add(';-- Se non specificate, le cartelle vengono impostate in modo relativo a PathBase --');
            TStringContenutoFile.Add(';Dizionario=');
            TStringContenutoFile.Add(';Modelli=');
            TStringContenutoFile.Add('Custom='+ Percorso + '\Custom');
            TStringContenutoFile.Add(';-- Se non specificata, la temporanea viene creata nella cartella del profilo dell''utente --');
            TStringContenutoFile.Add('Temporanea=C:\OS1\'+ cbVersione.Text +'\Temp');
            TStringContenutoFile.Add('');
            TStringContenutoFile.Add('[AltriParametri]');
            TStringContenutoFile.Add('Utente='+ NumeroUtente);
            TStringContenutoFile.Add('Ditta='+ NomeDitta);
            TStringContenutoFile.Add('');
            TStringContenutoFile.Add('[Database]');
            TStringContenutoFile.Add('Server=' + cbServer.Text);
            TStringContenutoFile.Add('Database='+ cbDatabase.Text);
            TStringContenutoFile.Add('UserName='+ Username);
            TStringContenutoFile.Add('Password='+ Password);

            TStringContenutoFile.SaveToFile(PercorsoCompleto);
        finally
            TStringContenutoFile.Free;
        end;
    end;
end;

procedure TfInizializzaProgetto.SistemaRegSetUp;
var
    RegLogin, RegPreferenze : TRegistry;
    Nome, VersioneConUnderscore, PathDizionario, PathCustom, PathLocale : String;
    PosUnderScore : Integer;
begin
    RegLogin := TRegistry.Create(KEY_WRITE);
    Nome := ExtractFileName(NomeScelto);
    try
        RegLogin.RootKey := HKEY_CURRENT_USER;

        if RegLogin.OpenKey('\Software\OSItalia\OS1\Configurazioni\'+ Nome + '\Login', True) then
        begin
            RegLogin.WriteString('Database', cbDatabase.Text);
            RegLogin.WriteString('Password', '');
            RegLogin.WriteString('Server', cbServer.Text);
            RegLogin.WriteString('TipoDB', '2');
            RegLogin.WriteString('Username', Username);
            RegLogin.CloseKey;
        end;
    finally
        RegLogin.Free;
    end;
    RegPreferenze := TRegistry.Create(KEY_WRITE);
    try
        RegPreferenze.RootKey := HKEY_CURRENT_USER;
        PosUnderScore := Pos('_', Nome);
        if PosUnderScore > 0 then
            VersioneConUnderscore := Copy(Trim(Nome), PosUnderScore, Length(Trim(Nome)));
       if VersioneConUnderScore <> '' then
       begin
           PathDizionario := 'C:\OSItalia\Os1'+ VersioneConUnderScore + '\Dizionario\';
           PathCustom := 'C:\OSItalia\Os1'+ VersioneConUnderScore + '\Personalizzazioni\' + NomeScelto + '\Custom\';
           PathLocale := 'C:\OSItalia\Os1'+ VersioneConUnderScore + '\Personalizzazioni\' + NomeScelto + '\DBTemp\';
           if RegPreferenze.OpenKey('\Software\OSItalia\OS1\Configurazioni\'+ Nome + '\Preferenze', True) then
           begin
               RegPreferenze.WriteString('Dizionario', PathDizionario);
               RegPreferenze.WriteString('PathCustom', PathCustom);
               RegPreferenze.WriteString('PathLocale', PathLocale);
               RegPreferenze.WriteString('PathModelli', '');
               RegPreferenze.CloseKey
           end;
       end;
    finally
       RegPreferenze.Free;
    end;
end;

procedure TfInizializzaProgetto.InizializzaGit;
var
  SecurityAttr: TSecurityAttributes;
  StdOutRead, StdOutWrite: THandle;
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
  Script, ScriptFile, CmdLine, Percorso: string;
  Buffer: array[0..1023] of AnsiChar;
  BytesRead: DWORD;
  Output: TStringList;
  ExitCode: DWORD;
begin
  Percorso := 'C:\OSItalia\' + cbVersione.Text + '\Personalizzazioni\' + NomeScelto;
  CreaGitIgnore(Percorso);
  Output := TStringList.Create;
  try
    // Script PowerShell
    Script :=
      'Set-Location -Path "' + Percorso + '"' + sLineBreak
      + 'git init' + sLineBreak
      + 'git add .' + sLineBreak
      + 'git commit -m "Primo Commit"' + sLineBreak
      ;

    ScriptFile := IncludeTrailingPathDelimiter(GetEnvironmentVariable('TEMP')) + 'InizializeGit.ps1';
    TFile.WriteAllText(ScriptFile, Script, TEncoding.UTF8);

    // Crea pipe per leggere stdout
    SecurityAttr.nLength := SizeOf(SecurityAttr);
    SecurityAttr.bInheritHandle := True;
    SecurityAttr.lpSecurityDescriptor := nil;

    CreatePipe(StdOutRead, StdOutWrite, @SecurityAttr, 0);
    SetHandleInformation(StdOutRead, HANDLE_FLAG_INHERIT, 0);

    ZeroMemory(@StartupInfo, SizeOf(StartupInfo));
    ZeroMemory(@ProcessInfo, SizeOf(ProcessInfo));

    StartupInfo.cb := SizeOf(StartupInfo);
    StartupInfo.hStdOutput := StdOutWrite;
    StartupInfo.hStdError := StdOutWrite;
    StartupInfo.dwFlags := STARTF_USESTDHANDLES or STARTF_USESHOWWINDOW;
    StartupInfo.wShowWindow := SW_HIDE;

    CmdLine := Format('powershell -ExecutionPolicy Bypass -File "%s"', [ScriptFile]);

    if CreateProcess(nil, PChar(CmdLine), nil, nil, True,
      CREATE_NO_WINDOW, nil, nil, StartupInfo, ProcessInfo) then
    begin
      CloseHandle(StdOutWrite);

      // Legge l'output
      repeat
        BytesRead := 0;
        ReadFile(StdOutRead, Buffer, SizeOf(Buffer) - 1, BytesRead, nil);
        if BytesRead > 0 then
        begin
          Buffer[BytesRead] := #0;
          Output.Text := Output.Text + string(AnsiString(Buffer));
        end;
      until BytesRead = 0;

      WaitForSingleObject(ProcessInfo.hProcess, INFINITE);
      GetExitCodeProcess(ProcessInfo.hProcess, ExitCode);

      CloseHandle(ProcessInfo.hProcess);
      CloseHandle(ProcessInfo.hThread);
      CloseHandle(StdOutRead);

      if ExitCode <> 0 then
        raise Exception.Create('Errore durante l''esecuzione dello script PowerShell:' + sLineBreak + Output.Text)
      else
        OpenFork;
    end
    else
      raise Exception.Create('Impossibile avviare PowerShell.');
  finally
    Output.Free;
  end;
end;

procedure TfInizializzaProgetto.OpenRegSetUp;
var
    PercorsoRegSetUp : String;
begin
    PercorsoRegSetUp := 'C:\OSItalia\'+ cbVersione.Text + '\OS1RegSetup.exe';
    Sleep(1000);
    ShellExecute (0, 'open', PChar(PercorsoRegSetUp), nil, nil, SW_SHOWNORMAL);
    Close;
end;

procedure TfInizializzaProgetto.OpenFork;
var
    Utente, PercorsoFork, Percorso : String;
begin
    Utente := GetWindowsUsername;
    Percorso := 'C:\OSItalia\' + cbVersione.Text + '\Personalizzazioni\' + NomeScelto;
    PercorsoFork := 'C:\Users\' + Utente + '\AppData\Local\Fork\current\Fork.exe';
    ShellExecute(0, 'open', PChar(PercorsoFork), PChar(Percorso), nil, SW_SHOWNORMAL);
end;

function TfInizializzaProgetto.GetWindowsUsername: String;
var
    Buffer: Array[0..255] of Char;
    Size: DWORD;
begin
    Size := Length(Buffer);
    if GetUserName(Buffer, Size) then
        Result := Buffer
    else
        Result := 'Errore nel recupero del nome utente';
end;

function TfInizializzaProgetto.CreaGitIgnore(Percorso: String) : Boolean;
const
    Contenuto: Array[0..23] of String = (
     '# File binari e compilati',
    '*.dcu',
    '*.exe',
    '*.tds',
    '*.map',
    '*.obj',
    '*.dcp',
    '*.bpi',
    '',
    '# File temporanei',
    '*.~*',
    '*.bak',
    '*.tmp',
    '*.log',
    '*.local',
    '*.identcache',
    '*.dsk',
    '*.tvsconfig',
    '__history/',
    '__recovery/',
    '',
    '# File specifici RAD Studio',
    '*.dproj.local',
    '*.cfg'
    );
var
    StringListGit : TStringList;
    i : Integer;
begin
    Percorso := IncludeTrailingPathDelimiter(Percorso) + '.gitignore';
    if not FileExists(Percorso) then
    begin
        StringListGit := TStringList.Create;
        try
            for i := 0 to Length(Contenuto) - 1 do
                StringListGit.Add(Contenuto[i]);
            StringListGit.SaveToFile(Percorso);
        finally
            StringListGit.Free;
        end;
    end;
    if FileExists(Percorso) then
        Result := True
    else
        Result := False;
end;

procedure TfInizializzaProgetto.edUtenteExit(Sender: TObject);
var
    Valore : Integer;
begin
    if not TryStrToInt(Trim(edUtente.Text), Valore) then
        ShowMessage('Scrivi un numero!');
end;

procedure TfInizializzaProgetto.FormCreate(Sender: TObject);
begin
    MostratiDatiUsernamePassword := False;
    ProgettoEsistente            := False;
end;

procedure TfInizializzaProgetto.CreaFileIni;
var
    Utente, Percorso, Cartella : String;
    Ini: TIniFile;
begin
    Utente := GetWindowsUsername;
    Cartella := 'C:\Users\'+ Utente + '\AppData\Roaming\MECTools\MECToolsInizializzazione\';
    Percorso := Cartella + 'Dati.ini';
    if not DirectoryExists(Cartella) then
        ForceDirectories(Cartella);
        Ini := TIniFile.Create(Percorso);
        try
            Ini.WriteString(Server, 'Username', edUsername.Text);
            Ini.WriteString(Server, 'Password', edPassword.Text);
        finally
            Ini.Free;
        end;
end;

procedure TfInizializzaProgetto.ReadFileIni;
var
    Ini: TIniFile;
    Utente, Username, Password, Percorso, Cartella : String;
    Section : TStringList;
    i: Integer;
    TrovataSezione : Boolean;
begin
    Utente := GetWindowsUsername;
    TrovataSezione := False;
    Cartella := 'C:\Users\'+ Utente + '\AppData\Roaming\MECTools\MECToolsInizializzazione\';
    Percorso := Cartella + 'Dati.ini';
    if FileExists(Percorso) then
    begin
        Ini := TIniFile.Create(Percorso);
        try
            Section := TStringList.Create;
            try
                Ini.ReadSections(Section);
                for i := 0 to Section.Count - 1 do
                begin
                    if Section[i] = Server then
                    begin
                        TrovataSezione := True;
                    end;
                end;
            finally
                Section.Free;
            end;
            if TrovataSezione then
            begin
                Username := Ini.ReadString(Server, 'Username', edUsername.Text);
                Password := Ini.ReadString(Server, 'Password', edPassword.Text);
            end
            else
            begin
                Username := '';
                Password := '';
            end;
        finally
            Ini.Free;
        end;
    end;
    edUsername.Text := Username;
    edPassword.Text := Password;
end;

end.

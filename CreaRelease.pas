unit CreaRelease;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls,
  Vcl.ComCtrls, System.Threading, System.SyncObjs, System.Generics.Collections,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.Phys.MSSQL, FireDAC.Phys.MSSQLDef, FireDAC.VCLUI.Wait,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.Phys.MySQL,
  FireDAC.Phys.MySQLDef;

type
    ThreadRicercaFile = Class(TThread)
        Private
            SorgenteThread, DestinazioneThread, FileEsaminato : String;
            FileEsaminati : TStringList;
            FFileCount: Integer;
        Protected
            procedure Execute; Override;
        Public
            constructor Create(PercorsoSorgente, PercorsoDestinazione : String);
            destructor  Destroy; Override;
    End;
    TCopyFileThread = class(TThread)
    private
        FFiles: TArray<string>;
        FSourceBase: string;     // ← la cartella "Bin"
        FDestFolder: string;     // ← es. "D:\Backup"
        procedure StepProgressBar;
    protected
        procedure Execute; override;
    public
        constructor Create(const Files: TArray<string>; const SourceBase, DestFolder: string);
  end;
  ThreadRicercaFileVers = Class(TThread)
        Private
            SorgenteThreadVer, DestinazioneThreadVer, FileEsaminatoVer : String;
            FileEsaminatiVer : TStringList;
            FFileCountVer: Integer;
            FPatchPathVers: String;
        Protected
            procedure Execute; Override;
        Public
            constructor Create(PercorsoSorgenteVer, PercorsoDestinazioneVer, Patch : String);
            destructor  Destroy; Override;
    End;
    TCopyFileThreadVers = class(TThread)
    private
        FFiles: TArray<string>;
        FSourceBase: string;
        FDestFolder: string;
        FPatchPath: string;
        procedure CopyPatchContents;
        procedure StepProgressBarVers;
    protected
        procedure Execute; override;
    public
        constructor Create(const Files: TArray<string>; const SourceBase, DestFolder, PatchPath: string);
    end;


  TfCreaRelease = class(TForm)
    btnConferma: TBitBtn;
    pnlBottom: TPanel;
    pnlCenter: TFlowPanel;
    pbLoading: TProgressBar;
    ConnServer: TFDConnection;
    qBackupRestore: TFDQuery;
    cbIstanza: TComboBox;
    TControllo: TTimer;
    pnlSettings: TPanel;
    btnSettings: TBitBtn;
    procedure FormCreate(Sender: TObject);
    procedure btnConfermaClick(Sender: TObject);
    procedure cbIstanzaEnter(Sender: TObject);
    procedure cbIstanzaChange(Sender: TObject);
    procedure TControlloTimer(Sender: TObject);
    procedure btnSettingsClick(Sender: TObject);
  private
    ListeTotaliReleases : TStringList;
    ValoreProgressBar, GiriTimer : Integer;
    procedure CercaVersioniBase(ListReleases : TStringList; Percorso : String);
    procedure CercaVersioniPatch(ListDa, ListA : TStringList);
    procedure TrasferisciInUnaStringList(ListDa, ListA : TStringList);
    procedure CreaCheckBox(ListDa : TStringList; APanel: TFlowPanel);
    procedure RiordinaStringList(ListDa : TStringList);
    function  AnalizzaCheckConStringList(ListDa : TStringList) : TStringList;
    procedure AnalizzaCheckCliente(CartelleComplete : TStringList);
    procedure AnalizzaECopiaDaServer(ListDa: TStringList);
    procedure ControllaReleaseEsistenti;
    procedure DisattivaAppenafatti;
    procedure CheckBoxClick(Sender: TObject);
    procedure ControllaVersCliente;
    procedure CopiaDatabase(CartelleVers : TStringList);
    procedure EseguiBackup(Versione : String);
    procedure ConnessioneServer(Server, UserName, Password, Database : String);
    procedure ImpostaQuery(Database : TStringList);
    procedure EseguiRestore(PercorsoServer : String; Database: TStringList);
    function  ControllaEsistenza(Database: TStringList) : TStringList;
    procedure CreaFileIni(Percorso : String);
    procedure ImpostaRestore(Database : TStringList);
    procedure EliminaFileDaServer(Database : TStringList);
    procedure ModificaOSILogon(Database : TStringList; Server, UserName, Password : String);
    procedure SalvaUltimaistanza;
    procedure LeggiIni;
    procedure CancellaCustom;
    procedure FiltraReleases(Releases : TStringList);
  public
    UserName, Password, GlobalPercorso, Server, PercorsoVersione : String;
    function GetServer: TStringList;
    function ReadFileIni : String;
    function GetWindowsUsername: String;
    function GetMachineName : String;
  end;

var
  fCreaRelease: TfCreaRelease;

implementation

uses
    System.IOUtils, System.Generics.Defaults, Math, System.RegularExpressions, IniFiles, CreaRelease_Istanza, SettingsIstanza, System.UITypes, System.StrUtils;

{$R *.dfm}

procedure TfCreaRelease.AnalizzaCheckCliente(CartelleComplete : TStringList);
var
    ClientList : TStringList;
    i,j : Integer;
    CheckBox : TCheckBox;
    Contenitore : TPanel;
    NomeCheckBox, Cartella : String;
    Cartelle,Files: TArray<String>;
    CartellaScelta : String;
begin
    ClientList := TStringList.Create;
    try
        for i := 0 to pnlCenter.ControlCount - 1 do
        begin
            if pnlCenter.Controls[i] is TPanel then
            begin
                Contenitore := TPanel(pnlCenter.Controls[i]);
                for j := 0 to Contenitore.ControlCount - 1  do
                begin
                    if Contenitore.Controls[j] is TCheckBox then
                    begin
                        CheckBox := TCheckBox(Contenitore.Controls[j]);
                        NomeCheckBox := CheckBox.Name;
                        if (NomeCheckBox.StartsWith('cbCliente_')) and (CheckBox.Checked) then
                        begin
                            NomeCheckBox := Copy(NomeCheckBox, 3, Length(NomeCheckBox));
                            ClientList.Add(NomeCheckBox);
                        end;
                    end;
                end;
            end;
        end;
        for i := 0 to ClientList.Count - 1 do
        begin
            Cartella := ClientList[i];
            Cartella := Copy(Cartella, Pos('_', Cartella) + 1, Length(Cartella));
            Cartelle := TDirectory.GetDirectories('\\srvxapp\C\OS1\' + Cartella);
            for CartellaScelta in Cartelle do
            begin
                if UpperCase(ExtractFileName(CartellaScelta)) = 'BIN' then
                begin
                    //Copia file da fare
                    Files := TDirectory.GetFiles('\\srvxapp\C\OS1\' + Cartella, '*.*', TSearchOption.soAllDirectories);
                    pbLoading.Max := Length(Files) + pbLoading.Max;
                    Files := nil;
                    ThreadRicercaFile.Create('\\srvxapp\C\OS1\' + Cartella, 'C:\OS1\' + Cartella);
                    ForceDirectories('C:\OS1\' + Cartella + '\TEMP');
                    if cbIstanza.Text <> '' then
                        CopiaDatabase(CartelleComplete);
                end;
            end;
        end;
    finally
        ClientList.Free;
    end;
end;

function TfCreaRelease.AnalizzaCheckConStringList(ListDa: TStringList) : TStringList;
var
    i, j, k, CountUnderscore : Integer;
    CheckBox : TCheckBox;
    Contenitore : TPanel;
    Release, Versione, TestoCheckBox, TestoCheckBoxScan, CartellaCompleta : String;
    ListInPanel, CartelleComplete : TStringList;
begin
    ListInPanel := TStringList.Create;
    CartelleComplete := TStringList.Create;
    //pbLoading.Max := 100;
    pbLoading.Position := 0;
    try
        pbLoading.Position := pbLoading.Position + 1;
        for i := 0 to pnlCenter.ControlCount - 1  do
        begin
            if pnlCenter.Controls[i] is TPanel then
            begin
                Contenitore := TPanel(pnlCenter.Controls[i]);
                for j := 0 to Contenitore.ControlCount - 1 do
                begin
                    if Contenitore.Controls[j] is TCheckBox then
                    begin
                        CheckBox := TCheckBox(Contenitore.Controls[j]);
                        if CheckBox.Checked = True then
                            ListInPanel.Add(CheckBox.Caption);
                    end;
                end;
            end;
        end;
        if ListInPanel.Count <> 0 then
        begin
            for j := 0 to ListInPanel.Count - 1 do
            begin
                TestoCheckBox := ListInPanel[j];
                CountUnderscore := 0;
                TestoCheckBoxScan := '';
                for k := 1 to Length(TestoCheckBox) do
                begin
                    if TestoCheckBox[k] = '_' then
                        CountUnderscore := CountUnderscore + 1;
                end;
                if CountUnderscore >= 2 then
                begin
                    TestoCheckBoxScan := Copy(TestoCheckBox, 5, Length(TestoCheckBox));
                end
                else
                    TestoCheckBoxScan := TestoCheckBox;

                for i := 0 to ListDa.Count - 1 do
                begin
                    Release := ListDa[i];
                    CartellaCompleta := '';
                    Versione := '';
                    if Release.Contains(';') then
                    begin
                        Versione := Copy(Release, Pos(';', Release) + 1, Length(Release));
                        CartellaCompleta := Copy(Release, 1, Pos(';', Release) - 1);
                    end
                    else
                        Versione := Release;
                    if Versione = TestoCheckBoxScan then
                        if CartellaCompleta.IsEmpty then
                            CartelleComplete.Add(Versione)
                        else
                            CartelleComplete.Add(CartellaCompleta);
                end;
            end;
            //pbLoading.Max := CartelleComplete.Count + 1;
           AnalizzaECopiaDaServer(CartelleComplete);

        end
        else
            MessageDlg('Nessuna Release selezionata!', mtError, [mbOk], 0);
         Result := CartelleComplete;
    finally
        ListInPanel.Free;
    end;
end;

procedure TfCreaRelease.AnalizzaECopiaDaServer(ListDa: TStringList);
var
    i, CountUnderscore, j: Integer;
    Cartella, Percorso, PrimaParteCartella, SecondaParteCartella, PercorsoDestinazione : String;
    Files: TArray<String>;
begin
    Cartella := '';
    for i := 0 to ListDa.Count - 1 do
    begin
        Cartella := ListDa[i];
        CountUnderScore := 0;
        PrimaParteCartella := '';
        SecondaParteCartella := '';
        pbLoading.Position := pbLoading.Position + 1;
        Application.ProcessMessages;
        for j := 1 to Length(Cartella) do
        begin
            if Cartella[j] = '_' then
            begin
                CountUnderscore := CountUnderscore + 1;
            end
            else if CountUnderscore < 1 then
                PrimaParteCartella := PrimaParteCartella + Cartella[j]
            else if CountUnderscore < 2 then
                SecondaParteCartella := SecondaParteCartella + Cartella[j]
            else
                Break;
        end;
        if CountUnderscore = 1 then
        begin
            Percorso := '\\srvdb\e\OS1\OS1Svi\' + Cartella + '\' + Cartella;
            Files := TDirectory.GetFiles(Percorso, '*.*', TSearchOption.soAllDirectories);
            pbLoading.Max := Length(Files) + pbLoading.Max;
            Files := nil;
            ThreadRicercaFileVers.Create(Percorso, 'C:\OSItalia\' + Cartella, '');
        end
        else if CountUnderscore > 1 then
        begin
            Percorso := '\\srvdb\e\OS1\OS1Svi\OS1_' + PrimaParteCartella + '\OS1_' + PrimaParteCartella;
            PercorsoDestinazione := 'C:\OSItalia\OS1_' + PrimaParteCartella + '_' + SecondaParteCartella;
            Files := TDirectory.GetFiles(Percorso, '*.*', TSearchOption.soAllDirectories);
            pbLoading.Max := Length(Files) + pbLoading.Max;
            Files := nil;
            Files := TDirectory.GetFiles('\\srvdb\e\OS1\OS1Svi\OS1_' + PrimaParteCartella + '\OS1_' + PrimaParteCartella  + '_Patch\' + Cartella, '*.*', TSearchOption.soAllDirectories);
            pbLoading.Max := Length(Files) + pbLoading.Max;
            Files := nil;
            ThreadRicercaFileVers.Create(Percorso, PercorsoDestinazione, IncludeTrailingPathDelimiter('\\srvdb\e\OS1\OS1Svi\OS1_' + PrimaParteCartella + '\OS1_' + PrimaParteCartella  + '_Patch\' + Cartella));
        end;
    end;
end;

procedure TfCreaRelease.btnSettingsClick(Sender: TObject);
begin
    pnlSettings.Height := 192;
    pnlSettings.Visible := True;
    pnlSettings.Top := 10;
    if not Assigned(SettingsIstanza.fSettingsIstanza) then
    begin
        SettingsIstanza.fSettingsIstanza := SettingsIstanza.TfSettingsIstanza.Create(Self);
        WindowState := wsMaximized;
    end;
    with SettingsIstanza.fSettingsIstanza do
    begin
        Parent := pnlSettings;
        BorderStyle := bsNone;
        Align := alClient;
        Visible := True;
        Show;
    end;
    if Assigned(CreaRelease_Istanza.fIstanza) then
    begin
        with CreaRelease_Istanza.fIstanza do
        begin
            Parent := pnlSettings;
            BorderStyle := bsNone;
            Align := alNone;
            Visible := False;
        end;
    end;
end;

procedure TfCreaRelease.CancellaCustom;
var
    PercorsoSistemato, FilePath, DirPath : String;
    CountFilesInDirectory : Integer;
begin
    PercorsoSistemato := PercorsoVersione;
    PercorsoSistemato := StringReplace(PercorsoSistemato, 'OSItalia', 'OS1', [rfReplaceAll]);
    PercorsoSistemato := PercorsoSistemato + 'BIN\Custom';
    if TDirectory.Exists(PercorsoSistemato) then
    begin
        CountFilesInDirectory := Length(TDirectory.GetFiles(PercorsoSistemato));
        CountFilesInDirectory := Length(TDirectory.GetDirectories(PercorsoSistemato)) + CountFilesInDirectory;
        if CountFilesInDirectory > 0 then
        begin
            for FilePath in TDirectory.GetFiles(PercorsoSistemato) do
                TFile.Delete(FilePath);
            for DirPath in TDirectory.GetDirectories(PercorsoSistemato) do
                TDirectory.Delete(DirPath, True);
        end;
    end;
end;

procedure TfCreaRelease.btnConfermaClick(Sender: TObject);
var
    CartelleComplete : TStringList;
begin
    CartelleComplete := TStringList.Create;
    try
        Screen.Cursor := crHourGlass;
        SalvaUltimaistanza;
        btnSettings.Enabled := False;
        CartelleComplete := AnalizzaCheckConStringList(ListeTotaliReleases);
        AnalizzaCheckCliente(CartelleComplete);
    finally
        ControllaReleaseEsistenti;
        ControllaVersCliente;
        DisattivaAppenafatti;
        CartelleComplete.Free;
        ListeTotaliReleases.Free;
        Screen.Cursor := crDefault;
        pbLoading.Position := 0;
    end;
end;

procedure TfCreaRelease.cbIstanzaChange(Sender: TObject);
begin
    Server := cbIstanza.Text;
    if Server <> '' then
        ReadFileIni;
end;

function TfCreaRelease.GetWindowsUsername: String;
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

function TfCreaRelease.ReadFileIni : String;
var
    Ini: TIniFile;
    Utente, Username, Password, Percorso, Cartella : String;
    Section : TStringList;
    i: Integer;
    TrovataSezione : Boolean;
begin
    Utente := GetWindowsUsername;
    TrovataSezione := False;
    Cartella := 'C:\Users\'+ Utente + '\AppData\Roaming\MECTools\MECToolsIstanze\';
    Percorso := Cartella + 'Istanze.ini';
    GlobalPercorso := Percorso;
    if FileExists(Percorso) then
    begin
        Ini := TIniFile.Create(Percorso);
        try
            Section := TStringList.Create;
            try
                Ini.ReadSections(Section);
                for i := 0 to Section.Count - 1 do
                begin
                    if Section[i] = cbIstanza.Text then
                    begin
                        TrovataSezione := True;
                        pnlSettings.Visible := False;
                    end;
                end;
            finally
                Section.Free;
            end;
            if TrovataSezione then
            begin
                Username := Ini.ReadString(cbIstanza.Text, 'Username', Username);
                Password := Ini.ReadString(cbIstanza.Text, 'Password', Password);
            end
            else
            begin
                if not Assigned(CreaRelease_Istanza.fIstanza) then
                begin
                    CreaRelease_Istanza.fIstanza := CreaRelease_Istanza.TfIstanza.Create(Self);
                end;
                pnlSettings.Visible := True;
                pnlSettings.Height := 157;
                pnlSettings.Top := 10;
                with CreaRelease_Istanza.fIstanza do
                begin
                    Parent := pnlSettings;
                    BorderStyle := bsNone;
                    Align := alClient;
                    Visible := True;
                    Show;
                end;

            end;
        finally
            Ini.Free;
        end;
    end
    else
        CreaFileIni(Percorso);
    Result := cbIstanza.Text + ';' + Username + ';' + Password;
end;

procedure TfCreaRelease.cbIstanzaEnter(Sender: TObject);
var
    Server : TStringList;
begin
    Server := TStringList.Create;
    try
        Server := GetServer;
        FiltraReleases(Server);
        cbIstanza.Items.Assign(Server);
    finally
        Server.Free;
    end;
end;

function TfCreaRelease.GetMachineName: String;
var
  Buffer: array[0..MAX_COMPUTERNAME_LENGTH + 1] of Char;
  Size: DWORD;
begin
  Size := Length(Buffer);
  if GetComputerName(Buffer, Size) then
    Result := Buffer
  else
    RaiseLastOSError;
end;

function TfCreaRelease.GetServer : TStringList;
var
    DocumentPath, Riga, RigaPresa, Versione, VersioneScelta : String;
    StringListCode, StringListServer, StringListTemp : TStringList;
    VersioniMicrosoftSql : TArray<String>;
    i : Integer;
    Reg : TRegEx;
begin
    DocumentPath := TPath.GetHomePath;
    VersioneScelta := '';
    DocumentPath := DocumentPath + '\Microsoft\SQL Server Management Studio';
    VersioniMicrosoftSql := TDirectory.GetDirectories(DocumentPath);
    Reg := TRegEx.Create('^\d{2}\.\d$');
    for Versione in VersioniMicrosoftSql do
    begin
        if Reg.IsMatch(ExtractFileName(Versione)) then
        begin
            if VersioneScelta = '' then
                VersioneScelta := ExtractFileName(Versione)
            else if Trim(VersioneScelta) < ExtractFileName(Versione) then
                VersioneScelta := ExtractFileName(Versione);
        end;
    end;
    StringListCode := TStringList.Create;
    StringListServer := TStringList.Create;
    StringListTemp := TStringList.Create;
    try
        StringListCode.LoadFromFile(DocumentPath + '\' + VersioneScelta + '\UserSettings.xml');

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

procedure TfCreaRelease.CercaVersioniBase(ListReleases: TStringList; Percorso : String);
var
    Releases : TArray<String>;
    Release : String;
begin
    Releases := TDirectory.GetDirectories(Percorso);
    for Release in Releases do
    begin
        if Trim(LowerCase(ExtractFileName(Release))).StartsWith('os1_') then
            ListReleases.Add(Release);
    end;
end;

procedure TfCreaRelease.CercaVersioniPatch(ListDa, ListA: TStringList);
var
    i, CountUnderscore, j : Integer;
    Percorso, ReleasePatch, Versione, ReleasePatchCorto, Controllo : String;
    ReleasesPatch: TArray<String>;
begin
    for i := 0 to ListDa.Count - 1 do
    begin
        Percorso := ListDa[i] + '\' + ExtractFileName(ListDa[i]) + '_Patch';
        if DirectoryExists(Percorso) then
        begin
            ReleasesPatch := TDirectory.GetDirectories(Percorso);
            for ReleasePatch in ReleasesPatch do
            begin
                CountUnderScore := 0;
                Versione := '';
                Controllo := '';
                ReleasePatchCorto := ExtractFileName(ReleasePatch);
                for j := 1 to Length(ReleasePatchCorto) do
                begin
                    if ReleasePatchCorto[j] = '_' then
                        CountUnderScore := CountUnderScore + 1;
                    if CountUnderScore >= 2 then
                    begin
                        Controllo := Controllo + ReleasePatchCorto[j]
                    end
                    else
                        Versione := Versione + ReleasePatchCorto[j];
                end;
                Controllo := Copy(Controllo, 2, Length(Controllo));
                if Controllo.StartsWith('0') then
                begin
                    Controllo := Copy(Controllo, Pos('_', Controllo) + 1, Length(Controllo));
                    if Controllo.StartsWith('A') then
                        ListA.Add(ReleasePatchCorto + ';' + Versione);
                end;
            end;
        end;
    end;





end;

procedure TfCreaRelease.ConnessioneServer(Server, UserName, Password, Database: String);
begin
    ConnServer.Close;
    ConnServer.Params.Clear;
    ConnServer.Params.Add('Server=' + Server);
    if Database <> '' then
        ConnServer.Params.Add('Database=' + Database);
    ConnServer.Params.Add('DriverID=MSSQL');
    ConnServer.Params.Add('User_Name=' + Username);
    ConnServer.Params.Add('Password=' + Password);
    ConnServer.LoginPrompt := False;
end;

function TfCreaRelease.ControllaEsistenza(Database: TStringList): TStringList;
var
    i,j: Integer;
    TestoQuery, FiltratoDatabase, Riga : String;
begin
    Result := TStringList.Create;
    try
        for i := 0 to Database.Count - 1 do
        begin
            Riga := Database[i];
            FiltratoDatabase := '';
            for j := 1 to Length(Riga) do
            begin
                if Riga[j] = ',' then
                begin
                    Break;
                end
                else
                    FiltratoDatabase := FiltratoDatabase + Riga[j]
            end;
            TestoQuery := 'SELECT 1 FROM sys.databases WHERE name = '+ QuotedStr(FiltratoDatabase);
            with qBackupRestore do
            begin
                if Active then
                    Close;
                SQL.Text := TestoQuery;
                Open;

                if isEmpty then
                    Result.Add(Database[i]);

            end;

        end;
    finally

    end;
end;

procedure TfCreaRelease.ControllaReleaseEsistenti;
var
    CheckBox : TCheckBox;
    Contenitore : TPanel;
    TStringListCheckBox, ReleasesLocale : TStringList;
    i,j,k : Integer;
    ReleaseLocale: String;
begin
    TStringListCheckBox := TStringList.Create;
    ReleasesLocale := TStringList.Create;
    try
        CercaVersioniBase(ReleasesLocale, 'C:\OSItalia');
        for i := 0 to ReleasesLocale.Count - 1 do
        begin
            ReleaseLocale := ExtractFileName(ReleasesLocale[i]);
            for j := 0 to pnlCenter.ControlCount - 1  do
            begin
                if pnlCenter.Controls[j] is TPanel then
                begin
                    Contenitore := TPanel(pnlCenter.Controls[j]);
                    if Contenitore.Name = 'pnl' + ReleaseLocale then
                        Contenitore.Enabled := False;
                    for k := 0 to Contenitore.ControlCount - 1 do
                    begin
                        if Contenitore.Controls[k] is TCheckBox then
                        begin
                           CheckBox := TCheckBox(Contenitore.Controls[k]);
                           if CheckBox.Caption = ReleaseLocale then
                            CheckBox.Enabled := False
                        end;
                    end;
                end;
            end;
        end;
    finally
        ReleasesLocale.Free;
        TStringListCheckBox.Free;
    end;
end;

procedure TfCreaRelease.ControllaVersCliente;
var
    Releases : TArray<String>;
    Release, NomeCheckBox : String;
    Contenitore : TPanel;
    CheckBox : TCheckBox;
  i,j: Integer;
begin
    for i := 0 to pnlCenter.ControlCount - 1 do
    begin
        if pnlCenter.Controls[i] is TPanel then
        begin
            Contenitore := TPanel(pnlCenter.Controls[i]);
            for j := 0 to Contenitore.ControlCount - 1 do
            begin
                if Contenitore.Controls[j] is TCheckBox then
                begin
                    CheckBox := TCheckBox(Contenitore.Controls[j]);
                    NomeCheckBox := CheckBox.Name;
                    if NomeCheckBox.StartsWith('cbCliente_') then
                    begin
                        NomeCheckBox := Copy(NomeCheckBox, Pos('_', NomeCheckBox) + 1, Length(NomeCheckBox));
                        Releases := TDirectory.GetDirectories('C:\OS1');
                        for Release in Releases do
                        begin
                            if Trim(LowerCase(ExtractFileName(Release))) = LowerCase(NomeCheckBox) then
                            begin
                                CheckBox.Enabled := False;
                            end;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

procedure TfCreaRelease.CopiaDatabase(CartelleVers: TStringList);
var
    i,j, CountUnderscore: Integer;
    Versione, Cartella : String;
begin
    for i := 0 to CartelleVers.Count - 1 do
    begin
        Cartella := CartelleVers[i];
        CountUnderscore := 0;
        Versione := '';
        for j := 1 to Length(Cartella) do
        begin
            if Cartella[j] = '_' then
                CountUnderScore := CountUnderScore + 1;
            if CountUnderScore <= 1 then
            begin
                Versione := Versione + Cartella[j];
            end
            else
                Break;
        end;
        EseguiBackup(Versione);
    end;
end;

procedure TfCreaRelease.CreaCheckBox(ListDa: TStringList; APanel: TFlowPanel);
const
    CheckBoxWidth     = 150;
    CheckBoxHeight    = 24;
    MargineInferiore  = 5;
    RientroFiglia     = 20;
    PannelloAltezza   = (CheckBoxHeight * 2) + MargineInferiore;
var
    i, j: Integer;
    Contenitore: TPanel;
    CheckBox1, CheckBox2: TCheckBox;
    Versione, VersionePerFiltraggio, NumVersionString : String;
    CountUnderscore, NumVersion, NumVersionControllo: Integer;
begin
    RiordinaStringList(ListDa);
    NumVersionString := '';
    NumVersionControllo := 0;
    for i := ListDa.Count - 1 downto 0 do
    begin
        if ListDa[i].Contains(';') then
            Versione := 'OS1_' + Copy(ListDa[i], Pos(';', ListDa[i]) + 1, Length(ListDa[i]))
        else
            Versione := ListDa[i];
        VersionePerFiltraggio := '';

        CountUnderScore := 0;
        for j := 1 to Length(Versione) do
        begin
            if Versione[j] = '_' then
            begin
                CountUnderScore := CountUnderScore + 1;
                Continue;
            end;
            if CountUnderScore = 1 then
                VersionePerFiltraggio := VersionePerFiltraggio + Versione[j]
            else if CountUnderScore > 1 then
                 Break;
        end;
        NumVersion := VersionePerFiltraggio.ToInteger;
        if NumVersionString = '' then
        begin
            VersionePerFiltraggio := (NumVersion - 200).ToString;
            for j := 1 to Length(VersionePerFiltraggio) do
            begin
                if j <= 2 then
                    NumVersionString := NumVersionString + VersionePerFiltraggio[j]
                else
                begin
                    NumVersionString := NumVersionString + '0';
                    Break;
                end;
            end;
            NumVersionControllo := NumVersionString.ToInteger;
        end;
        if NumVersion >= NumVersionControllo then
        begin
            // Pannello contenitore per la coppia
            Contenitore := TPanel.Create(APanel);
            Contenitore.Parent := APanel;
            Contenitore.Width := CheckBoxWidth + RientroFiglia;
            Contenitore.Height := PannelloAltezza;
            Contenitore.BevelOuter := bvNone;
            Contenitore.BorderStyle := bsSingle;
            Contenitore.AlignWithMargins := True;
            Contenitore.Margins.Bottom := MargineInferiore;
            Contenitore.Caption := ''; // no testo visivo
            Contenitore.Name := 'pnl' + Versione;

            // CheckBox principale
            CheckBox1 := TCheckBox.Create(Contenitore);
            CheckBox1.Parent := Contenitore;
            CheckBox1.Caption := Versione;
            CheckBox1.Left := 5;
            CheckBox1.Top := 0;
            CheckBox1.Width := CheckBoxWidth;
            CheckBox1.Height := CheckBoxHeight;
            CheckBox1.Name := 'cbVersione_' + Versione;
            CheckBox1.OnClick := CheckBoxClick;

            // CheckBox secondaria, rientrata
            CheckBox2 := TCheckBox.Create(Contenitore);
            CheckBox2.Parent := Contenitore;
            CheckBox2.Caption := 'Modifica Cliente';
            CheckBox2.Left := RientroFiglia;
            CheckBox2.Top := CheckBoxHeight;
            CheckBox2.Width := CheckBoxWidth;
            CheckBox2.Height := CheckBoxHeight;
            CheckBox2.Name := 'cbCliente_' + Versione;
        end;
    end;

end;

procedure TfCreaRelease.CreaFileIni(Percorso: String);
var
    Utente, Cartella : String;
    Ini: TIniFile;
begin
    Utente := GetWindowsUsername;
    Cartella := 'C:\Users\'+ Utente + '\AppData\Roaming\MECTools\MECToolsIstanze\';
    Percorso := Cartella + 'Istanze.ini';
    GlobalPercorso := Percorso;
    if not DirectoryExists(Cartella) then
        ForceDirectories(Cartella);
        Ini := TIniFile.Create(Percorso);
        try
            Ini.WriteString('Inizio', 'Username', Username);
            Ini.WriteString('Inizio', 'Password', Password);
        finally
            Ini.Free;
            ReadFileIni;
        end;
end;

procedure TfCreaRelease.DisattivaAppenafatti;
var
    j,i: Integer;
    CheckBox : TCheckBox;
    Contenitore : TPanel;
begin
    for j := 0 to pnlCenter.ControlCount - 1  do
    begin
        if pnlCenter.Controls[j] is TPanel then
        begin
            Contenitore := TPanel(pnlCenter.Controls[j]);
            for i := 0 to Contenitore.ControlCount - 1 do
            begin
                if Contenitore.Controls[i] is TCheckBox then
                begin
                    CheckBox := TCheckBox(Contenitore.Controls[i]);
                    if (not CheckBox.Enabled) and (CheckBox.Checked) then
                        CheckBox.Checked := False;
                end;
            end;
        end;

    end;
end;

procedure TfCreaRelease.EliminaFileDaServer(Database: TStringList);
const
    Server = 'srvdb01\assistenza';
    UserName = 'sa';
    Password = 'Grsys01*';
var
    i, j : Integer;
    Riga, Db, PercorsoDb, TestoQuery : String;
begin
    ConnessioneServer(Server, UserName, Password, '');
    for i := 0 to Database.Count - 1 do
    begin
        Riga := Database[i];
        Db := '';
        for j := 1 to Length(Riga) do
        begin
            if Riga[j] = ',' then
                Break
            else
                Db := Db + Riga[j];
        end;
        Db := 'Backup_'+ Db + '.bck';
        PercorsoDb := 'E:\BackupTemp\' + Db;
        TestoQuery :=
            'DECLARE @cmd NVARCHAR(4000) = ''DEL "' + PercorsoDb + '"''; ' +
            'EXEC xp_cmdshell @cmd;';
        with qBackupRestore do
        begin
            if Active then
                Close;
            SQL.Text := TestoQuery;
            ExecSQL;
        end;
    end;
end;

procedure TfCreaRelease.EseguiBackup(Versione: String);
const
    Server = 'srvdb01\assistenza';
    UserName = 'sa';
    Password = 'Grsys01*';
var
    Database : TStringList;
begin
    ConnessioneServer(Server, UserName, Password, '');
    try
        ConnServer.Open();
        Database := TStringList.Create;
        try
            Database.Add('OS1_BASE_' + Versione);
            Database.Add('OS1_DemoE_'+ Versione);
            Database.Add('OSILogon_' + Versione);
            ImpostaQuery(Database);
        finally
            Database.Free;
        end;
    except
        on E: Exception do
            ShowMessage('Errore connessione: ' + E.Message);
    end;
end;

procedure TfCreaRelease.EseguiRestore(PercorsoServer: String; Database : TStringList);
var
    Server, Username, Password, RisultatoIni : String;
    CountPuntoEVirgola,i : Integer;
    DatabaseNonEsistenti : TStringList;
begin
    DatabaseNonEsistenti := TStringList.Create;
    try
        RisultatoIni := ReadFileIni;
        CountPuntoEVirgola := 0;
        Server := '';
        Username := '';
        Password := '';
        for i := 1 to Length(RisultatoIni) do
        begin
            if RisultatoIni[i] = ';' then
            begin
                CountPuntoEVirgola := CountPuntoEVirgola + 1;
                Continue;
            end;
            if CountPuntoEVirgola < 1 then
                Server := Server + RisultatoIni[i]
            else if (CountPuntoEVirgola >= 1) and (CountPuntoEVirgola < 2) then
                Username := Username + RisultatoIni[i]
            else if (CountPuntoEVirgola >= 2) then
                 Password := Password + RisultatoIni[i];
        end;
        ConnessioneServer(Server, Username, Password, '');
        DatabaseNonEsistenti := ControllaEsistenza(Database);
        ImpostaRestore(DatabaseNonEsistenti);
        ModificaOSILogon(DatabaseNonEsistenti, Server, Username, Password);
        EliminaFileDaServer(DatabaseNonEsistenti);
    finally
        DatabaseNonEsistenti.Free;
    end;
end;

procedure TfCreaRelease.FiltraReleases(Releases: TStringList);
var
    i : Integer;
    NomeMacchina : String;
    ReleasesFiltrate : TStringList;
begin
    NomeMacchina := GetMachineName;
    ReleasesFiltrate := TStringList.Create;
    try
        for i := 0 to Releases.Count - 1  do
        begin
            if Releases[i].StartsWith(Lowercase(NomeMacchina)) then
            begin
                ReleasesFiltrate.Add(Releases[i]);
            end;
        end;
        Releases.Assign(ReleasesFiltrate);
    finally
        ReleasesFiltrate.Free;
    end;
end;

procedure TfCreaRelease.FormCreate(Sender: TObject);
var
    ListReleases, ListNameReleases : TStringList;
begin

    ListReleases := TStringList.Create;
    ListNameReleases := TStringList.Create;
    ListeTotaliReleases := TStringList.Create;
    try
        CercaVersioniBase(ListReleases, '\\srvdb\e\OS1\OS1Svi');
        TrasferisciInUnaStringList(ListReleases, ListNameReleases);
        CercaVersioniPatch(ListReleases, ListNameReleases);
        CreaCheckBox(ListNameReleases, pnlCenter);
        ListeTotaliReleases.Assign(ListNameReleases);
        ControllaReleaseEsistenti;
        ControllaVersCliente;
        LeggiIni;
        //Show;
    finally
        ListNameReleases.Free;
        ListReleases.Free;
    end;
end;

procedure TfCreaRelease.ImpostaQuery(Database: TStringList);
const
    PercorsoServer = 'E:\BackupTemp\';
var
    i : Integer;
    TestoQuery, Messaggio, LogicalDataFile, LogicalLogFile : String;
    DatabaseConFile : TStringList;
begin
    Messaggio := 'Backup Eseguiti: ';
    DatabaseConFile := TStringList.Create;
    try
        for i := 0 to Database.Count - 1 do
        begin
            TestoQuery := 'BACKUP DATABASE [' + Database[i] + '] ' +
            'TO DISK = N' + QuotedStr(PercorsoServer + 'Backup_' + Database[i] + '.bck') + ' WITH NOFORMAT, INIT, ' +
            'NAME = N' + QuotedStr(Database[i] + '-Completo Database Backup') + ', SKIP, NOREWIND, NOUNLOAD, STATS = 10';

            with qBackupRestore do
            begin
                if Active then
                    Close;
                SQL.Text := TestoQuery;
                ExecSQL;
            end;

            TestoQuery :=
            'declare @DBName  sysname' + #13#10 +
            ' ,@LogicalDataFile  sysname' + #13#10 +
            ' ,@LogicalLogFile  sysname' + #13#10 +
            ' ,@PhysicalDataFile  nvarchar(260)' + #13#10 +
            ' ,@PhysicalLogFile  nvarchar(260)' + #13#10 +
            ' set @DBName='+QuotedStr(Database[i]) + #13#10 +
            ' select @LogicalDataFile = name' + #13#10 +
            ' ,@PhysicalDataFile = physical_name' + #13#10 +
            ' from sys.master_files' + #13#10 +
            ' where database_id = db_id(@DBName)' + #13#10 +
            ' and type_desc = ' + QuotedStr('ROWS') + #13#10 +
            ' select @LogicalLogFile = name' + #13#10 +
            ' ,@PhysicalLogFile = physical_name' + #13#10 +
            ' from sys.master_files' + #13#10 +
            ' where database_id = db_id(@DBName)' + #13#10 +
            ' and type_desc = ' +QuotedStr('LOG') + #13#10 +
            ' select @LogicalDataFile as [LogicalDataFile]' + #13#10 +
            ' ,@LogicalLogFile as [LogicalLogFile]' + #13#10 +
            ' ,@PhysicalDataFile as [PhysicalDataFile]' + #13#10 +
            ' ,@PhysicalLogFile as [PhysicalLogFile]'
            ;
            with qBackupRestore do
            begin
                if Active then
                    Close;
                SQL.Text := TestoQuery;
                Open;
            end;
            if Messaggio = 'Backup Eseguiti: ' then
                Messaggio := Messaggio + Database[i] + ','
            else
                Messaggio := Messaggio + #13#10 + Database[i] + ',';
            LogicalDataFile := qBackupRestore.FieldByName('LogicalDataFile').AsString;
            LogicalLogFile  := qBackupRestore.FieldByName('LogicalLogFile').AsString;
            DatabaseConFile.Add(Database[i] + ',' + LogicalDataFile + ',' + LogicalLogFile + ';');
        end;
        Messaggio := Copy(Messaggio, 1, Length(Messaggio) - 1);
        EseguiRestore(PercorsoServer, DatabaseConFile);
    finally
        DatabaseConFile.Free;
    end;
end;

procedure TfCreaRelease.ImpostaRestore(Database: TStringList);
var
    i,j, CountVirgola, CountUnderscore: Integer;
    VersioneTrovata : Boolean;
    TestoQuery, PercorsoServer, Riga, Db, DataFile, LogFile, Versione, PercorsoData : String;
begin
    PercorsoServer := '\\srvdb01\E\BackupTemp\';
    VersioneTrovata := False;
    Versione := 'OS1';
    for i := 0 to Database.Count - 1 do
    begin
        db := '';
        DataFile := '';
        LogFile := '';
        CountVirgola := 0;
        Riga := Database[i];
        CountUnderscore := 0;
        PercorsoData := '';
        for j := 1 to Length(Riga) do
        begin
            if Riga[j] = ',' then
            begin
                CountVirgola := CountVirgola + 1;
                Continue;
            end;
            if CountVirgola < 1 then
            begin
                Db := Db + Riga[j];
                if Riga[j] = '_' then
                begin
                    CountUnderscore := CountUnderscore + 1;
                end;
                if (CountUnderscore >= 2) and (not VersioneTrovata) then
                begin
                    Versione := Versione + Riga[j];
                end;

            end
            else if (CountVirgola >= 1) and (CountVirgola < 2) then
            begin
                DataFile := DataFile + Riga[j];
            end
            else if (CountVirgola >= 2) and (Riga[j] <> ';') then
            begin
                LogFile := LogFile + Riga[j];
            end;
        end;
        if TRegEx.IsMatch(Versione, '^OS1_\d{3}_A\d{2}$') then
        begin
            VersioneTrovata := True;
        end;

        PercorsoData := 'C:\OS1\'+ Versione +'\DATA\';
        ForceDirectories(PercorsoData);
        TestoQuery :=
        'USE [master]' +
        ' RESTORE DATABASE ['+ Db + ']' +
        ' FROM DISK = N' + QuotedStr(PercorsoServer + 'Backup_' + Db + '.bck') +
        ' WITH FILE = 1,' +
        ' MOVE N' + QuotedStr(DataFile) + 'TO N' + QuotedStr(PercorsoData + DataFile + '.mdf') + ',' +
        ' MOVE N' + QuotedStr(LogFile) + 'TO N' + QuotedStr(PercorsoData + LogFile + '.ldf') + ',' +
        ' NOUNLOAD, REPLACE, STATS = 5'
        ;

       with qBackupRestore do
        begin
            if Active then
                Close;
            SQL.Text := TestoQuery;
            ExecSQL;
        end;
    end;
end;

procedure TfCreaRelease.LeggiIni;
var
    Ini: TIniFile;
    Utente, Istanza, Percorso, Cartella : String;
    Section : TStringList;
    i: Integer;
    TrovataSezione : Boolean;
begin
    Utente := GetWindowsUsername;
    TrovataSezione := False;
    Cartella := 'C:\Users\'+ Utente + '\AppData\Roaming\MECTools\MECToolsIstanze\';
    Percorso := Cartella + 'Istanze.ini';
    GlobalPercorso := Percorso;
    if FileExists(Percorso) then
    begin
        Ini := TIniFile.Create(Percorso);
        try
            Section := TStringList.Create;
            try
                Ini.ReadSections(Section);
                for i := 0 to Section.Count - 1 do
                begin
                    if Section[i] = 'UltimaIstanza' then
                    begin
                        TrovataSezione := True;
                    end;
                end;
            finally
                Section.Free;
            end;
            if TrovataSezione then
            begin
                Istanza := Ini.ReadString('UltimaIstanza', 'Nome', Server);
            end;
            cbIstanza.Text := Istanza;
        finally
            Ini.Free;
        end;
    end;
end;

procedure TfCreaRelease.ModificaOSILogon(Database: TStringList; Server, Username, Password : String);
var
    i,j: Integer;
    Db, Riga, TestoQuery : String;
begin
    for i := 0 to Database.Count - 1 do
    begin
        Riga := Database[i];
        Db := '';
        for j := 1 to Length(Riga) do
        begin
            if Riga[j] = ',' then
            begin
                Break;
            end
            else
            begin
                Db := Db + Riga[j];
            end;
        end;
        if Db.StartsWith('OSILogon_') then
        begin
            ConnessioneServer(Server, Username, Password, Db);
            TestoQuery :=
            'DELETE FROM dbo.Ditte'+
            ' Where IdDitta <> ' + QuotedStr('Base') + 'and IdDitta <> ' + QuotedStr('Demo');

            with qBackupRestore do
            begin
                if Active then
                    Close;
                SQL.Text := TestoQuery;
                ExecSQL;
            end;

            TestoQuery :=
            'UPDATE Ditte' +
            ' SET Params = REPLACE(REPLACE(Params,'+
                QuotedStr('srvdb01\assistenza') + ','
                + QuotedStr(Server) + '),' + QuotedStr('Grsys01*') + ',' + QuotedStr(Password) + ')'+
            'WHERE Params LIKE ' + QuotedStr('%srvdb01\assistenza%') + ' OR Params LIKE ' + QuotedStr('%Grsys01*%') + ';';

            with qBackupRestore do
            begin
                if Active then
                    Close;
                SQL.Text := TestoQuery;
                ExecSQL;
            end;

            TestoQuery :=
            'DELETE FROM dbo.UtentiDitte'+
            ' Where IdDitta <> ' + QuotedStr('Base') + ' and IdDitta <> ' + QuotedStr('Demo') + ' and IdDitta <> ''''';

            with qBackupRestore do
            begin
                if Active then
                    Close;
                SQL.Text := TestoQuery;
                ExecSQL;
            end;
        end;
    end;
end;

procedure TfCreaRelease.RiordinaStringList(ListDa: TStringList);
var
    Gruppi: TObjectDictionary<String, TStringList>;
    Chiavi: TList<Integer>;
    s, Chiave : String;
    NumChiave, i: Integer;
    Risultato: TStringList;
    Figli: TStringList;
begin
    Gruppi := TObjectDictionary<String, TStringList>.Create([doOwnsValues]);
    Chiavi := TList<Integer>.Create;
    Risultato := TStringList.Create;
    try
        for s in ListDa do
        begin
            if UpperCase(s).StartsWith('OS1_') then
            begin
                Chiave := Copy(s, 5, Pos('_', s + '_', 5) - 5);
                NumChiave := StrToIntDef(Chiave, - 1);
                if not Gruppi.ContainsKey(Chiave) then
                begin
                    Gruppi.Add(Chiave, TStringList.Create);
                    Chiavi.Add(NumChiave);
                end;

                Gruppi[Chiave].Insert(0, s);
            end
            else
            begin
                Chiave := Copy(s, 1, Pos('_', s) - 1);
                if not Gruppi.ContainsKey(Chiave) then
                begin
                    Gruppi.Add(Chiave, TStringList.Create);
                    Chiavi.Add(StrToIntDef(Chiave, - 1));
                end;

                Gruppi[Chiave].Add(s);
            end;
        end;

        Chiavi.Sort;

        for i in Chiavi do
        begin
            Chiave := i.ToString;
            if Gruppi.TryGetValue(Chiave, Figli) then
                Risultato.AddStrings(Figli);
        end;

        ListDa.Assign(Risultato);
    finally
        Gruppi.Free;
        Chiavi.Free;
        Risultato.Free;
    end;
end;

procedure TfCreaRelease.SalvaUltimaistanza;
var
    Ini: TIniFile;
begin
    Ini := TIniFile.Create(fCreaRelease.GlobalPercorso);
    try
        Ini.WriteString('UltimaIstanza', 'Nome', Server);
    finally
        Ini.Free;
    end;

end;

procedure TfCreaRelease.TControlloTimer(Sender: TObject);
var
    Terzo: Integer;
begin
    if GiriTimer = 2 then
    begin
        Terzo := pbLoading.Max div 3;
        pbLoading.Position := pbLoading.Position + Terzo;
        if pbLoading.Position = pbLoading.Max then
        begin
            TControllo.Enabled := False;
            btnSettings.Enabled := True;
            btnConferma.Enabled := True;
            CancellaCustom;
            ShowMessage('Completato!');
            pbLoading.Position := 0;
        end;
    end
    else if ValoreProgressBar < pbLoading.Position then
    begin
        ValoreProgressBar := pbLoading.Position;
    end
    else
    begin
        GiriTimer := GiriTimer + 1;
    end;




end;

procedure TfCreaRelease.TrasferisciInUnaStringList(ListDa, ListA: TStringList);
var
    i : Integer;
begin
    for i := 0 to ListDa.Count - 1 do
    begin
        ListA.Add(ExtractFileName(ListDa[i]));
    end;
end;

procedure TfCreaRelease.CheckBoxClick(Sender: TObject);
var
    CheckBox, CheckBoxContenitore : TCheckBox;
    Contenitore : TPanel;
    i : Integer;
    NomeCheckBox, NomeCheckBoxContenitore : String;
begin
    if Sender is TCheckBox then
    begin
        CheckBox := TCheckBox(Sender);
        NomeCheckBox := CheckBox.Name;
        NomeCheckBox := Copy(NomeCheckBox, Pos('_', NomeCheckBox) + 1, Length(NomeCheckBox));
        if CheckBox.Parent is TPanel then
        begin
            Contenitore := TPanel(CheckBox.Parent);
            for i := 0 to Contenitore.ControlCount - 1 do
            begin
                if Contenitore.Controls[i] is TCheckBox then
                begin
                    CheckBoxContenitore := TCheckBox(Contenitore.Controls[i]);
                    NomeCheckBoxContenitore := CheckBoxCOntenitore.Name;
                    if NomeCheckBoxContenitore = 'cbCliente_' + NomeCheckBox then
                    begin
                        CheckBoxContenitore.Checked := CheckBox.Checked;
                    end;
                end;
            end;
        end;
    end;
end;

{ ThreadRicercaFile }

constructor ThreadRicercaFile.Create(PercorsoSorgente, PercorsoDestinazione : String);
begin
    inherited Create(False);  //False parte subito
    FreeOnTerminate := True;  //Una volta finito libera la memoria
    fCreaRelease.btnConferma.Enabled := False;
    if not fCreaRelease.TControllo.Enabled then
        fCreaRelease.TControllo.Enabled := True;
    SorgenteThread := PercorsoSorgente;
    DestinazioneThread := PercorsoDestinazione;
    FileEsaminati := TStringList.Create;

end;

destructor ThreadRicercaFile.Destroy;
begin
  FileEsaminato := '';
  FileEsaminati.Free;
  inherited;
end;

procedure ThreadRicercaFile.Execute;
var
  AllFiles: TArray<string>;
  NumThreads, BlockSize, i, StartIdx, EndIdx: Integer;
  ThreadFiles: TArray<string>;
begin
      try
        AllFiles := TDirectory.GetFiles(SorgenteThread, '*.*', TSearchOption.soAllDirectories);
        FFileCount := Length(AllFiles);

        //TThread.Queue(nil, InitProgressBar);

        // Decidi quanti thread vuoi usare (es. 4)
        NumThreads := 2;
        //fCreaRelease.pbLoading.Max := fCreaRelease.pbLoading.Max + FFileCount;
        //fCreaRelease.pbLoading.Position := 0;
        BlockSize := FFileCount div NumThreads;

        for i := 0 to NumThreads - 1 do
        begin
          StartIdx := i * BlockSize;
          if i = NumThreads - 1 then
            EndIdx := FFileCount - StartIdx
          else
            EndIdx := BlockSize;

          SetLength(ThreadFiles, EndIdx - StartIdx + 1);
          ThreadFiles := Copy(AllFiles, StartIdx, EndIdx);
          //Move(AllFiles[StartIdx], ThreadFiles[0], (EndIdx - StartIdx + 1) * SizeOf(string));
          // Avvia thread di copia
          TCopyFileThread.Create(ThreadFiles, SorgenteThread, DestinazioneThread);
        end;

      except
        on E: Exception do
          TThread.Queue(nil,
            procedure
            begin
              ShowMessage('Errore: ' + E.Message);
            end);
      end;
end;

{ TCopyFileThread }

constructor TCopyFileThread.Create(const Files: TArray<string>; const SourceBase, DestFolder: string);
begin
  inherited Create(False);
  FreeOnTerminate := True;
  FFiles := Files;
  FSourceBase := IncludeTrailingPathDelimiter(SourceBase);   // deve finire con '\'
  FDestFolder := IncludeTrailingPathDelimiter(DestFolder);
end;

procedure TCopyFileThread.Execute;
var
  FileName, RelativePath, DestPath, DestFolder: string;
begin
      for FileName in FFiles do
      begin
        if Terminated then Exit;

        // Calcola il percorso relativo a partire da Bin
        RelativePath := StringReplace(FileName, FSourceBase, '', [rfIgnoreCase]);

        // Costruisce il percorso completo nella destinazione
        DestPath := FDestFolder + RelativePath;
        DestFolder := ExtractFilePath(DestPath);

        // Crea la cartella se non esiste
        if not DirectoryExists(DestFolder) then
          ForceDirectories(DestFolder);

        try
          TFile.Copy(FileName, DestPath, True);
        except
          on E: Exception do
          begin
            // gestisci errore, logga o ignora
          end;
        end;
        TThread.Queue(nil, StepProgressBar);
      end;
end;


procedure TCopyFileThread.StepProgressBar;
begin
    fCreaRelease.pbLoading.StepIt;
end;

{ TCopyFileThreadVers }

procedure TCopyFileThreadVers.CopyPatchContents;
var
  PatchFiles: TArray<string>;
  SrcFile, RelativePath, DestPath, DestFolder: string;
begin
  PatchFiles := TDirectory.GetFiles(FPatchPath, '*.*', TSearchOption.soAllDirectories);

  for SrcFile in PatchFiles do
  begin
    if Terminated then Exit;
    //fCreaRelease.pbLoading.Max := fCreaRelease.pbLoading.Max + TotFile;
    RelativePath := StringReplace(SrcFile, FPatchPath, '', [rfIgnoreCase]);
    DestPath := FDestFolder + RelativePath;
    DestFolder := ExtractFilePath(DestPath);

    if not DirectoryExists(DestFolder) then
      ForceDirectories(DestFolder);

    try
      TFile.Copy(SrcFile, DestPath, True); // forza sovrascrittura
    except
      // log se necessario
    end;

    TThread.Queue(nil, StepProgressBarVers); // opzionale
  end;
end;

constructor TCopyFileThreadVers.Create(const Files: TArray<string>; const SourceBase, DestFolder, PatchPath: string);
begin
  inherited Create(False);
  FreeOnTerminate := True;
  FFiles := Files;
  FSourceBase := IncludeTrailingPathDelimiter(SourceBase);
  FDestFolder := IncludeTrailingPathDelimiter(DestFolder);
  fCreaRelease.PercorsoVersione := FDestFolder;
  FPatchPath := IncludeTrailingPathDelimiter(PatchPath);
end;

procedure TCopyFileThreadVers.Execute;
var
  FileName, RelativePath, DestPath, DestFolder: string;
begin
  // Copia normale
      for FileName in FFiles do
      begin
        if Terminated then Exit;

        RelativePath := StringReplace(FileName, FSourceBase, '', [rfIgnoreCase]);
        DestPath := FDestFolder + RelativePath;
        DestFolder := ExtractFilePath(DestPath);

        if not DirectoryExists(DestFolder) then
          ForceDirectories(DestFolder);

        try
          TFile.Copy(FileName, DestPath, True);
        except
          // gestisci errore se vuoi
        end;

        TThread.Queue(nil, StepProgressBarVers);
      end;

      // Se presente, copia la patch
      if DirectoryExists(FPatchPath) then
        CopyPatchContents;
end;

procedure TCopyFileThreadVers.StepProgressBarVers;
begin
    fCreaRelease.pbLoading.StepIt;
end;

{ ThreadRicercaFileVers }

constructor ThreadRicercaFileVers.Create(PercorsoSorgenteVer,
  PercorsoDestinazioneVer, Patch: String);
begin
    inherited Create(False);  //False parte subito
    FreeOnTerminate := True;  //Una volta finito libera la memoria
    fCreaRelease.btnConferma.Enabled := False;
    if not fCreaRelease.TControllo.Enabled then
        fCreaRelease.TControllo.Enabled := True;
    SorgenteThreadVer := PercorsoSorgenteVer;
    DestinazioneThreadVer := PercorsoDestinazioneVer;
    FileEsaminatiVer := TStringList.Create;
    FPatchPathVers := Patch;
    //InitProgressBar;
end;

destructor ThreadRicercaFileVers.Destroy;
begin
  FileEsaminatoVer := '';
  FileEsaminatiVer.Free;

  inherited;
end;

procedure ThreadRicercaFileVers.Execute;
var
  AllFiles: TArray<string>;
  NumThreads, BlockSize, i, StartIdx, EndIdx: Integer;
  ThreadFiles: TArray<string>;
begin
      try
        AllFiles := TDirectory.GetFiles(SorgenteThreadVer, '*.*', TSearchOption.soAllDirectories);
        FFileCountVer := Length(AllFiles);

        //TThread.Queue(nil, InitProgressBar);
        //fCreaRelease.pbLoading.Max := fCreaRelease.pbLoading.Max + FFileCountVer;
        // Decidi quanti thread vuoi usare (es. 4)
        NumThreads := 2;
        BlockSize := FFileCountVer div NumThreads;

        for i := 0 to NumThreads - 1 do
        begin
          StartIdx := i * BlockSize;
          if i = NumThreads - 1 then
            EndIdx := FFileCountVer - StartIdx
          else
            EndIdx := BlockSize;

          SetLength(ThreadFiles, EndIdx - StartIdx + 1);
          ThreadFiles := Copy(AllFiles, StartIdx, EndIdx);
          //Move(AllFiles[StartIdx], ThreadFiles[0], (EndIdx - StartIdx + 1) * SizeOf(string));

          // Avvia thread di copia
          TCopyFileThreadVers.Create(ThreadFiles, SorgenteThreadVer, DestinazioneThreadVer, FPatchPathVers);


        end;

      except
        on E: Exception do
          TThread.Queue(nil,
            procedure
            begin
              ShowMessage('Errore: ' + E.Message);
            end);
      end;
end;

end.

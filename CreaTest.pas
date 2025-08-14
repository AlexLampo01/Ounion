unit CreaTest;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Buttons,
  Vcl.ComCtrls, Vcl.Menus, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.UI.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Phys, FireDAC.Phys.MSSQL,
  FireDAC.Phys.MSSQLDef, FireDAC.VCLUI.Wait, Data.DB, FireDAC.Comp.Client,
  FireDAC.Comp.DataSet;

type
    TVersione = record
        Versione, PercorsoConfig, NomeProgetto : String;
    end;


  TfCreaTest = class(TForm)
    cbDb: TComboBox;
    pnlTop: TPanel;
    btnSelezionaProgetto: TBitBtn;
    Label1: TLabel;
    btnDatabase: TBitBtn;
    pnlSelezionaCartella: TPanel;
    Label2: TLabel;
    edCartella: TEdit;
    opCartelle: TFileOpenDialog;
    lblNomeCartella: TLabel;
    lbContenutoCustom: TListBox;
    TVCartelle: TTreeView;
    btnContinua: TBitBtn;
    pnlSceltaDb: TPanel;
    btnBack: TBitBtn;
    btnConfermaDb: TBitBtn;
    lbDb: TListBox;
    popMlbDb: TPopupMenu;
    DeselezionaTutto1: TMenuItem;
    SelezionaTutto1: TMenuItem;
    qScripts: TFDQuery;
    ConnScripts: TFDConnection;
    cbDatabase: TComboBox;
    qDatabase: TFDQuery;
    ConnDatabase: TFDConnection;
    cbIstanze: TComboBox;
    qBackupRestore: TFDQuery;
    ConnBackupRestore: TFDConnection;
    lblScripts: TLabel;
    Label4: TLabel;
    lblIstanza: TLabel;
    lblDb: TLabel;
    procedure edCartellaDblClick(Sender: TObject);
    procedure TVCartelleChange(Sender: TObject; Node: TTreeNode);
    procedure btnContinuaClick(Sender: TObject);
    procedure btnBackClick(Sender: TObject);
    procedure btnConfermaDbClick(Sender: TObject);
    procedure cbDbChange(Sender: TObject);
    procedure lbDbMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure DeselezionaTutto1Click(Sender: TObject);
    procedure SelezionaTutto1Click(Sender: TObject);
    procedure cbDatabaseEnter(Sender: TObject);
    procedure cbIstanzeEnter(Sender: TObject);
    procedure cbIstanzeExit(Sender: TObject);
  private
    procedure RiempiTreeView(PercorsoCustom : String; ParentNode: TTreeNode = nil);
    procedure CopiaCartelle;
    procedure ControllaSelezione;
    procedure ModificaConfig(SceltaDb : String);
    procedure RecuperaDatabase(ListaDb : TStringList);
    procedure RecuperaDatabaseAssistenza(ListaDb : TStringList);
    function  EseguiBackup : String;
    procedure EseguiRestore(NomeLogicalDataLogFile : String);
    function AnalizzaStringPerDemo(Versione: String) : String;
    function GetServer : TStringList;
    function GetMachineName : String;
    function ElaboraPassword(Istanza: String) : String;
    function CalcolaVersione : TVersione;
  public
    CartellaSelezionata, CartellaFiltrata : String;
  end;

var
  fCreaTest: TfCreaTest;

implementation

uses
    System.IOUtils, Registry, System.RegularExpressions, System.Character, System.Types, System.UITypes;

{$R *.dfm}

function TfCreaTest.AnalizzaStringPerDemo(Versione: String) : String;
var
    PrimaParte, SecondaParte : String;
    i, CountUnderscore: Integer;
begin
    CountUnderscore := 0;
    PrimaParte := '';
    SecondaParte := '';
    for i := 1 to Length(Versione) do
    begin
        if Versione[i] = '_' then
            CountUnderscore := CountUnderscore + 1;
        if CountUnderscore < 1 then
            PrimaParte := PrimaParte + Versione[i];
        if CountUnderscore >= 1 then
            SecondaParte := SecondaParte + Versione[i];
    end;
    Result := PrimaParte + ';' + SecondaParte;
end;

procedure TfCreaTest.btnBackClick(Sender: TObject);
begin
    pnlSelezionaCartella.Height := 84;
    TVCartelle.Visible := False;
    lbContenutoCustom.Visible := False;
    btnContinua.Visible := False;
    btnBack.Visible := False;
    TVCartelle.Items.Clear;
    lbContenutoCustom.Items.Clear;
    edCartella.Text := '';
end;

procedure TfCreaTest.btnConfermaDbClick(Sender: TObject);
var
    SceltaDb, Db, NomeLogicalDataLogFile : String;
    ListaDb : TStringList;
    i : Integer;
begin
    SceltaDb := cbDb.Text;
    if SceltaDb = '1. Non serve un database particolare, usano la demo' then
    begin
        ModificaConfig(SceltaDb);
    end
    else if SceltaDb = '2. Usano il db sul pc dello sviluppatore' then
    begin
        if cbDatabase.Text <> '' then
            ModificaConfig(SceltaDb)
        else
            MessageDlg('Nessun database selezionato!', mtError, [mbOk], 0);
    end
    else if SceltaDb = '3. Hanno già il db su SRVDB01\ASSISTENZA' then
    begin
        if cbDatabase.Text <> '' then
        begin
            ControllaSelezione;
            ModificaConfig(SceltaDb);
        end
        else
            MessageDlg('Nessun database selezionato!', mtError, [mbOk], 0);
    end
    else if SceltaDb = '4. Va copiato il db su SRVDB01\ASSISTENZA' then
    begin
        if cbDatabase.Text <> '' then
        begin
            ListaDb := TStringList.Create;
            try
                RecuperaDatabaseAssistenza(ListaDb);
                for i := 0 to ListaDb.Count - 1 do
                begin
                    Db := ListaDb[i];
                    if Db = cbDatabase.Text then
                    begin
                        Break;
                    end
                    else
                    begin
                        Db := '';
                    end;
                end;
                if Db = '' then
                begin
                    ConnBackupRestore.Params.Values['Server'] := cbIstanze.Text;
                    ConnBackupRestore.Params.Values['User_Name'] := 'sa';
                    ConnBackupRestore.Params.Values['Password'] := ElaboraPassword(cbIstanze.Text);
                    ConnBackupRestore.Params.Values['Database'] := cbDatabase.Text;
                    NomeLogicalDataLogFile := EseguiBackup;
                    EseguiRestore(NomeLogicalDataLogFile);
                end;

            finally
                ListaDb.Free;
            end;
            ModificaConfig(SceltaDb)
        end
        else
            MessageDlg('Nessun database selezionato!', mtError, [mbOk], 0);
    end;

end;

procedure TfCreaTest.btnContinuaClick(Sender: TObject);
begin
    pnlSelezionaCartella.Visible := False;
    pnlSceltaDb.Visible := True;
    btnSelezionaProgetto.Enabled := False;
    btnDatabase.Enabled := True;
    CopiaCartelle;
end;

function TfCreaTest.CalcolaVersione: TVersione;
var
    Percorso: String;
    i : Integer;
begin
    Percorso := edCartella.Text;
    if ExtractFileName(Percorso) = 'Custom' then
    begin
        Percorso := ExtractFileDir(Percorso);
    end;
    Result.NomeProgetto := ExtractFileName(Percorso);
    Result.PercorsoConfig := '\\srvxapp\OS1Launcher\CUSTOM.Config\' + Result.NomeProgetto + '.config';
    Result.Versione := Percorso;
    for i := 1 to 2 do
    begin
        Result.Versione := ExtractFileDir(Result.Versione);
    end;
    Result.Versione := ExtractFileName(Result.Versione);
end;

procedure TfCreaTest.cbDatabaseEnter(Sender: TObject);
var
    NomiDatabase : TStringList;
begin
    cbDatabase.Items.Clear;
    NomiDatabase := TStringList.Create;
    try
        RecuperaDatabase(NomiDatabase);
        cbDatabase.Items.Assign(NomiDatabase);
    finally
        NomiDatabase.Free;
    end;
end;

procedure TfCreaTest.cbDbChange(Sender: TObject);
var
    FileName, Percorso : String;
begin
    if (cbDb.Text = '1. Non serve un database particolare, usano la demo') then
    begin
        cbDatabase.Top := 101;
        cbDatabase.Visible := False;
        lbDb.Visible    := False;
        cbIstanze.Visible := False;
        pnlSceltadb.Height := 52;
        btnConfermaDb.Left := 336;
        btnConfermaDb.Top  := 18;
        lblDb.Top          := 86;
        lblIstanza.Visible := False;
        lblDb.Visible      := False;
        lblScripts.Visible := False;
    end;
    if (cbDb.Text = '2. Usano il db sul pc dello sviluppatore') then
    begin
        cbDatabase.Top := 101;
        cbDatabase.Visible := True;
        lbDb.Visible    := False;
        cbIstanze.Visible := True;
        pnlSceltadb.Height := 164;
        btnConfermaDb.Left := 255;
        btnConfermaDb.Top  := 134;
        lblDb.Top          := 86;
        lblIstanza.Visible := True;
        lblDb.Visible      := True;
        lblScripts.Visible := False;
    end;
    if cbDb.Text = '3. Hanno già il db su SRVDB01\ASSISTENZA' then
    begin
        cbDatabase.Top := 59;
        lblDb.Top := 45;
        cbDatabase.Visible := True;
        lbDb.Visible    := True;
        cbIstanze.Visible := False;
        pnlSceltadb.Height := 164;
        btnConfermaDb.Left := 255;
        btnConfermaDb.Top  := 86;
        lblIstanza.Visible := False;
        lblDb.Visible      := True;
        lblScripts.Visible := True;
        lbDb.Items.BeginUpdate;
        try
            lbDb.Items.Clear;
            Percorso := edCartella.Text;
            if ExtractFileName(Percorso) = 'Custom' then
                Percorso := Percorso + '\Scripts'
            else
                Percorso := Percorso + '\Custom\Scripts';
            if TDirectory.Exists(Percorso) then
            begin
                for FileName in TDirectory.GetFiles(Percorso) do
                begin
                    lbDb.Items.Add(TPath.GetFileName(FileName));
                end;
            end;
        finally
            lbDb.Items.EndUpdate;
        end;
    end;
    if cbDb.Text = '4. Va copiato il db su SRVDB01\ASSISTENZA' then
    begin
        cbDatabase.Top := 101;
        cbDatabase.Visible := True;
        lbDb.Visible    := False;
        cbIstanze.Visible := True;
        pnlSceltadb.Height := 164;
        btnConfermaDb.Left := 255;
        btnConfermaDb.Top  := 134;
        lblDb.Top          := 86;
        lblIstanza.Visible := True;
        lblDb.Visible      := True;
        lblScripts.Visible := False;
    end;

end;

procedure TfCreaTest.cbIstanzeEnter(Sender: TObject);
var
    Server : TStringList;
    Username : String;
    i: Integer;
begin
    Server := TStringList.Create;
    try
        Server := GetServer;
        Username := GetMachineName;
        for i := Server.Count - 1 downto 0 do
        begin
            if not LowerCase(Server[i]).StartsWith(LowerCase(Username)) then
            begin
                Server.Delete(i);
            end;
        end;
        cbIstanze.Items.Assign(Server);
    finally
        Server.Free;
    end;
end;

procedure TfCreaTest.cbIstanzeExit(Sender: TObject);
begin
    if cbIstanze.Text <> '' then
        ConnDatabase.Params.Values['Server'] := cbIstanze.Text;
end;

procedure TfCreaTest.ControllaSelezione;
var
    i,j : Integer;
    ListScript, SQLScript : TStringList;
    Percorso : String;
begin
    ConnScripts.Params.Values['Database'] := cbDatabase.Text;
    ListScript := TStringList.Create;
    SQLScript  := TStringList.Create;
    try
        for i := 0 to lbDb.Items.Count - 1 do
        begin
            if (lbDb.Selected[i] = True) and (lbDb.Items[i] <> '') then
            begin
                ListScript.Add(lbDb.Items[I]);
            end;
        end;
        for i := 0 to ListScript.Count - 1 do
        begin
            Percorso := edCartella.Text;
            if ExtractFileName(Percorso) = 'Custom' then
                Percorso := Percorso + '\Scripts'
            else
                Percorso := Percorso + '\Custom\Scripts';
            if TDirectory.Exists(Percorso) then
            begin
                Percorso := Percorso + '\' + ListScript[i];

                SQLScript.LoadFromFile(Percorso);
                for j := 0 to SQLScript.Count - 1 do
                begin
                    if SQLScript[j] = 'GO' then
                        SQLScript[j] := '';
                end;
                qScripts.SQL.Text := SQLScript.Text;
                qScripts.ExecSQL;
            end;
        end;
    finally
        SQLScript.Free;
        ListScript.Free;
    end;
end;

procedure TfCreaTest.CopiaCartelle;
var
    CartellaSelezionata, NomeCartellaServer, PercorsoDestinazione : String;
begin
    CartellaSelezionata := edCartella.Text;
    if ExtractFileName(CartellaSelezionata) = 'Custom' then
    begin
        NomeCartellaServer := ExtractFileDir(CartellaSelezionata);
        NomeCartellaServer := ExtractFileName(NomeCartellaServer);
        PercorsoDestinazione := '\\srvxapp\CustomClienti\' + NomeCartellaServer + '\Custom';
        ForceDirectories(PercorsoDestinazione);
        TDirectory.Copy(CartellaSelezionata, PercorsoDestinazione, True);
    end
    else
    begin
        NomeCartellaServer := ExtractFileName(CartellaSelezionata);
        CartellaSelezionata := CartellaSelezionata + '\Custom';
        PercorsoDestinazione := '\\srvxapp\CustomClienti\' + NomeCartellaServer + '\Custom';
        ForceDirectories(PercorsoDestinazione);
        TDirectory.Copy(CartellaSelezionata, PercorsoDestinazione, True);
    end;
end;

procedure TfCreaTest.DeselezionaTutto1Click(Sender: TObject);
var
    i : Integer;
begin
    for i := 0 to lbDb.Items.Count - 1 do
    begin
        lbDb.Selected[i] := False;
    end;
end;

procedure TfCreaTest.edCartellaDblClick(Sender: TObject);
begin
    opCartelle.DefaultFolder := 'C:\OSItalia\';
    if opCartelle.Execute then
        CartellaSelezionata := opCartelle.FileName;
    if ExtractFileName(CartellaSelezionata) = 'Custom' then
    begin
        edCartella.Text := CartellaSelezionata;
        pnlSelezionaCartella.Height := 260;
        lbContenutoCustom.Visible := True;
        TVCartelle.Visible := True;
        btnContinua.Visible := True;
        btnBack.Visible := True;
        CartellaFiltrata := CartellaSelezionata;
        CartellaFiltrata := ExtractFileDir(CartellaFiltrata);
        lblNomeCartella.Caption := ExtractFileName(CartellaFiltrata);
        TVCartelle.Items.Clear;
        RiempiTreeView(CartellaFiltrata);
    end
    else if (TDirectory.Exists(CartellaSelezionata + '\Custom')) and (CartellaSelezionata.Contains('Personalizzazioni')) then
    begin
        edCartella.Text := CartellaSelezionata;
        pnlSelezionaCartella.Height := 260;
        lbContenutoCustom.Visible := True;
        TVCartelle.Visible := True;
        btnContinua.Visible := True;
        RiempiTreeView(CartellaSelezionata);
    end
    else
    begin
        MessageDlg('Non hai selezionato una cartella che contiene una custom pers!', mtError, [mbOk], 0);
    end;

end;

function TfCreaTest.ElaboraPassword(Istanza: String): String;
var
    IstanzaDaElaborare, Numero, Caratteri : String;
    i: Integer;
begin
    Result := 'Grsys01*';
    Numero := '';
    Caratteri := '';
    IstanzaDaElaborare := Istanza;
    for i := 1 to Length(IstanzaDaElaborare) do
    begin
        if IstanzaDaElaborare[i].IsDigit then
            Numero := Numero + IstanzaDaElaborare[i]
        else
            Caratteri := Caratteri + IstanzaDaElaborare[i];
    end;
    if Numero <> '' then
    begin
        Result := 'Grsys' + Numero + '*';
    end;
end;

function TfCreaTest.EseguiBackup: String;
var
    TestoQuery : String;
begin
    if not DirectoryExists('C:\Temp\BackupXAssistenza') then
    begin
        ForceDirectories('C:\Temp\BackupXAssistenza');
    end;

    TestoQuery := 'BACKUP DATABASE [' + cbDatabase.Text + '] ' +
            'TO DISK = N' + QuotedStr('C:\BackupXAssistenza\' + 'Backup_' + cbDatabase.Text + '.bck') + ' WITH NOFORMAT, INIT, ' +
            'NAME = N' + QuotedStr(cbDatabase.Text + '-Completo Database Backup') + ', SKIP, NOREWIND, NOUNLOAD, STATS = 10';

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
            ' set @DBName='+QuotedStr(cbDatabase.Text) + #13#10 +
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
    Result := qBackupRestore.FieldByName('LogicalDataFile').AsString + ';' + qBackupRestore.FieldByName('LogicalLogFile').AsString;
    qBackupRestore.Close;
end;

procedure TfCreaTest.EseguiRestore(NomeLogicalDataLogFile : String);
var
    TestoQuery, PercorsoData, LogicalDataFile, LogicalLogFile : String;
    ResultVersione : TVersione;
begin
    ResultVersione := CalcolaVersione;
    //\\srvdb01\E\BackupTemp\Backup_
    TFile.Copy('C:\BackupXAssistenza\' + 'Backup_' + cbDatabase.Text + '.bck','\\srvdb01\DbBackup\Backup_' + cbDatabase.Text + '.bck', True);
    PercorsoData := 'E:\OS1_DB_Assistenza\' + ResultVersione.Versione + '\';
    ConnBackupRestore.Close;
    ConnBackupRestore.Params.Clear;
    ConnBackupRestore.Params.Values['Server'] := 'srvdb01\assistenza';
    ConnBackupRestore.Params.Values['User_Name'] := 'sa';
    ConnBackupRestore.Params.Values['Password'] := 'Grsys01*';
    ConnBackupRestore.Params.Add('DriverID=MSSQL');
    LogicalDataFile := Copy(NomeLogicalDataLogFile, 1, Pos(';', NomeLogicalDataLogFile) - 1);
    LogicalLogFile  := Copy(NomeLogicalDataLogFile, Pos(';', NomeLogicalDataLogFile) + 1, Length(NomeLogicalDataLogFile));
    TestoQuery :=
        ' USE [master]' +
        ' RESTORE DATABASE ['+ cbDatabase.Text + ']' +
        ' FROM DISK = N' + QuotedStr('E:\DbBackup\Backup_' + cbDatabase.Text + '.bck') +
        ' WITH FILE = 1,' +
        ' MOVE N' + QuotedStr(LogicalDataFile) + 'TO N' + QuotedStr(PercorsoData + LogicalDataFile + '.mdf') + ',' +
        ' MOVE N' + QuotedStr(LogicalLogFile) + 'TO N' + QuotedStr(PercorsoData + LogicalLogFile + '.ldf') + ',' +
        ' NOUNLOAD, REPLACE, STATS = 5'
        ;

       with qBackupRestore do
        begin
            if Active then
                Close;
            SQL.Text := TestoQuery;
            ExecSQL;
        end;
    MessageDlg('Ricordati di modificare xconfig del server', mtWarning, [mbOk], 0);
    MessageDlg('Completato!', mtInformation, [mbOk], 0);
end;

function TfCreaTest.GetServer: TStringList;
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

function TfCreaTest.GetMachineName: String;
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
procedure TfCreaTest.lbDbMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
    Indice: Integer;
begin
    if Button = mbRight then
    begin
        Indice := lbDb.ItemAtPos(Point(X,Y), True);
        if Indice >= 0 then
        begin
            lbDb.ItemIndex := Indice;
            popMlbDb.Popup(Mouse.CursorPos.X, Mouse.CursorPos.Y);
        end;
    end;
end;

procedure TfCreaTest.ModificaConfig(SceltaDb: String);
var
    Versione, Percorso, VersioneSeparata,
    DbDemo, Database, NomeProgetto,
    Username, Password, Server,
    PercorsoConfig, Riga, RigaTrimmata,
    ContenutoParentesi, ContenutoSlash, Contenuto,
    DatabaseOsiLogon, s: String;
    i,j, CountSlash: Integer;
    ContenutoConfig : TStringList;
    ResultVersione : TVersione;
begin
    ResultVersione := CalcolaVersione;
    Versione := ResultVersione.Versione;
    PercorsoConfig := ResultVersione.PercorsoConfig;
    NomeProgetto := ResultVersione.NomeProgetto;
    VersioneSeparata := AnalizzaStringPerDemo(Versione);
    if SceltaDb.StartsWith('1') then
    begin
        DbDemo := Copy(VersioneSeparata, 1, Pos(';', VersioneSeparata) - 1);
        DbDemo := DbDemo + '_DemoE' + Copy(VersioneSeparata, Pos(';', VersioneSeparata) + 1, Length(VersioneSeparata));
        Database := DbDemo;
        Server := 'srvdb01\assistenza';
        Username := 'sa';
        Password := 'Grsys01*';
    end;
    if SceltaDb.StartsWith('2') then
    begin
        Server := cbIstanze.Text;
        Database := cbDatabase.Text;
        Username := ConnDatabase.Params.Values['User_Name'];
        Password := ConnDatabase.Params.Values['Password'];
    end;
    if SceltaDb.StartsWith('3') or SceltaDb.StartsWith('4')  then
    begin
        Server := 'srvdb01\assistenza';
        Database := cbDatabase.Text;
        Username := 'sa';
        Password := 'Grsys01*';
    end;
    if not FileExists(PercorsoConfig) then
    begin
        ContenutoConfig := TStringList.Create;
        try
            ContenutoConfig.Add('[Generale]');
            ContenutoConfig.Add('Titolo=' + NomeProgetto + ' su ('+ Server +')');
            ContenutoConfig.Add('PathBase=\\SRVXAPP\C\OS1\' + Versione + '\BIN');
            ContenutoConfig.Add('');
            ContenutoConfig.Add('[Programmi]');
            ContenutoConfig.Add('OS1=OS1.exe');
            ContenutoConfig.Add('OS1Config=OS1Config.exe');
            ContenutoConfig.Add('XConfig=XConfig\XConfig.exe');
            ContenutoConfig.Add('XSQLWin=Servizi\XSQLWin.exe');
            ContenutoConfig.Add('');
            ContenutoConfig.Add('[Path]');
            ContenutoConfig.Add(';-- Se non specificate, le cartelle vengono impostate in modo relativo a PathBase --');
            ContenutoConfig.Add(';Dizionario=');
            ContenutoConfig.Add(';Modelli=');
            ContenutoConfig.Add('Custom=\\srvxapp\customclienti\' + NomeProgetto + '\Custom');
            ContenutoConfig.Add(';-- Se non specificata, la temporanea viene creata nella cartella del profilo dell''utente --');
            ContenutoConfig.Add('Temporanea=\\srvxapp\C\OS1\' + Versione + '\Temp');
            ContenutoConfig.Add('');
            ContenutoConfig.Add('[AltriParametri]');
            ContenutoConfig.Add('Utente=2');
            ContenutoConfig.Add('Ditta=Base');
            ContenutoConfig.Add('');
            ContenutoConfig.Add('[Database]');
            ContenutoConfig.Add('Server='+Server);
            ContenutoConfig.Add('Database=OSILogon'+ Copy(VersioneSeparata, Pos(';', VersioneSeparata) + 1, Length(VersioneSeparata)));
            ContenutoConfig.Add('Username=' + Username);
            ContenutoConfig.Add('Password=' + Password);

            ContenutoConfig.SaveToFile(PercorsoConfig);
        finally
            ContenutoConfig.Free;
        end;
    end
    else
    begin
        ContenutoConfig := TStringList.Create;
        try
            ContenutoConfig.LoadFromFile(PercorsoConfig);
            for i := 0 to ContenutoConfig.Count - 1 do
            begin
                Riga := ContenutoConfig[i];
                RigaTrimmata := Trim(LowerCase(Riga));
                CountSlash := 0;
                ContenutoParentesi := '';
                ContenutoSlash := '';
                Contenuto := '';
                if RigaTrimmata.Contains(' su (') then
                begin
                    ContenutoParentesi := Copy(Riga, Pos('(', Riga) + 1, Pos(')', Riga) - Pos('(', Riga) - 1 );
                    ContenutoConfig[i] := StringReplace(ContenutoConfig[i], ContenutoParentesi, Server, [rfIgnoreCase, rfReplaceAll]);
                end;
                if RigaTrimmata.EndsWith('\bin') and RigaTrimmata.StartsWith('pathbase=') then
                begin
                    for j := Length(RigaTrimmata) downto 1 do
                    begin
                        if RigaTrimmata[j] = '\' then
                        begin
                            CountSlash := CountSlash + 1;
                            Continue;
                        end;
                        if CountSlash = 1 then
                            ContenutoSlash := RigaTrimmata[j] + ContenutoSlash;
                        if CountSlash > 1 then
                            Break;
                    end;
                    ContenutoConfig[i] := StringReplace(ContenutoConfig[i], ContenutoSlash, Versione, [rfIgnoreCase, rfReplaceAll]);

                end;
                if RigaTrimmata.StartsWith('custom=') and RigaTrimmata.EndsWith('\custom') then
                begin
                    for j := Length(RigaTrimmata) downto 1 do
                    begin
                        if RigaTrimmata[j] = '\' then
                        begin
                            CountSlash := CountSlash + 1;
                            Continue;
                        end;
                        if CountSlash = 1 then
                            ContenutoSlash := RigaTrimmata[j] + ContenutoSlash;
                        if CountSlash > 1 then
                            Break;
                    end;
                    ContenutoConfig[i] := StringReplace(ContenutoConfig[i], ContenutoSlash, NomeProgetto, [rfIgnoreCase, rfReplaceAll]);
                end;
                if RigaTrimmata.StartsWith('temporanea=') and RigaTrimmata.EndsWith('\temp') then
                begin
                    for j := Length(RigaTrimmata) downto 1 do
                    begin
                        if RigaTrimmata[j] = '\' then
                        begin
                            CountSlash := CountSlash + 1;
                            Continue;
                        end;
                        if CountSlash = 1 then
                            ContenutoSlash := RigaTrimmata[j] + ContenutoSlash;
                        if CountSlash > 1 then
                            Break;
                    end;
                    ContenutoConfig[i] := StringReplace(ContenutoConfig[i], ContenutoSlash, Versione, [rfIgnoreCase, rfReplaceAll]);
                end;
                if RigaTrimmata.StartsWith('server=') then
                begin
                    Contenuto := Copy(RigaTrimmata, Pos('=', RigaTrimmata) + 1, Length(RigaTrimmata));
                    ContenutoConfig[i] := StringReplace(ContenutoConfig[i], Contenuto, Server, [rfReplaceAll]);
                end;
                if RigaTrimmata.StartsWith('database=osilogon') then
                begin
                    Contenuto := Copy(RigaTrimmata, Pos('=', RigaTrimmata) + 1, Length(RigaTrimmata));
                    DatabaseOsiLogon := 'OSILogon'+ Copy(VersioneSeparata, Pos(';', VersioneSeparata) + 1, Length(VersioneSeparata));
                    ContenutoConfig[i] := StringReplace(ContenutoConfig[i], Contenuto, DatabaseOsiLogon, [rfIgnoreCase, rfReplaceAll]);
                end;
                if RigaTrimmata.StartsWith('username=') then
                begin
                    Contenuto := Copy(RigaTrimmata, Pos('=', RigaTrimmata) + 1, Length(RigaTrimmata));
                    ContenutoConfig[i] := StringReplace(ContenutoConfig[i], Contenuto, Username, [rfIgnoreCase, rfReplaceAll]);
                end;
                if RigaTrimmata.StartsWith('password=') then
                begin
                    Contenuto := Copy(RigaTrimmata, Pos('=', RigaTrimmata) + 1, Length(RigaTrimmata));
                    ContenutoConfig[i] := StringReplace(ContenutoConfig[i], Contenuto, Password, [rfIgnoreCase, rfReplaceAll]);
                end;
            end;
            ContenutoConfig.SaveToFile(PercorsoConfig);
        finally
            ContenutoConfig.Free;
        end;
    end;
end;

procedure TfCreaTest.RecuperaDatabase(ListaDb: TStringList);
var
    Istanza, Username, Password, TestoQuery : String;
begin
    if not cbIstanze.Visible then
    begin
        Istanza := ConnScripts.Params.Values['Server'];
        Username := ConnScripts.Params.Values['User_Name'];
        Password := ConnScripts.Params.Values['Password'];
    end
    else
    begin
        Istanza := cbIstanze.Text;
        Username := 'sa';
        Password := ElaboraPassword(Istanza);
    end;
    if Istanza <> '' then
    begin
        TestoQuery := 'SELECT name AS DatabaseName' + #13#10 +
                      'FROM sys.databases' + #13#10 +
                      'WHERE name NOT IN (' + QuotedStr('master') + ',' + QuotedStr('tempdb') + ',' +QuotedStr('model') + ',' +QuotedStr('msdb') + ')' +
                      'ORDER BY name';
        ConnDatabase.Params.Values['Server'] := Istanza;
        ConnDatabase.Params.Values['User_Name'] := Username;
        ConnDatabase.Params.Values['Password'] := Password;
        ConnDatabase.Connected := True;
        With qDatabase do
        begin
            if Active then
                Close;
            SQL.Text := TestoQuery;
            Open;

            while not Eof do
            begin
                ListaDb.Add(FieldByName('DatabaseName').AsString);
                Next;
            end;
        end;
    end;
end;

procedure TfCreaTest.RecuperaDatabaseAssistenza(ListaDb: TStringList);
var
    Istanza, Username, Password, TestoQuery : String;
begin
    Istanza := 'srvdb01\assistenza';
    Username := 'sa';
    Password := 'Grsys01*';
    if Istanza <> '' then
    begin
        TestoQuery := 'SELECT name AS DatabaseName' + #13#10 +
                      'FROM sys.databases' + #13#10 +
                      'WHERE name NOT IN (' + QuotedStr('master') + ',' + QuotedStr('tempdb') + ',' +QuotedStr('model') + ',' +QuotedStr('msdb') + ')' +
                      'ORDER BY name';
        ConnDatabase.Params.Values['Server'] := Istanza;
        ConnDatabase.Params.Values['User_Name'] := Username;
        ConnDatabase.Params.Values['Password'] := Password;
        ConnDatabase.Connected := True;
        With qDatabase do
        begin
            if Active then
                Close;
            SQL.Text := TestoQuery;
            Open;

            while not Eof do
            begin
                ListaDb.Add(FieldByName('DatabaseName').AsString);
                Next;
            end;
        end;
    end;
end;

procedure TfCreaTest.RiempiTreeView(PercorsoCustom: String; ParentNode: TTreeNode = nil);
var
    Sr: TSearchRec;
    Node: TTreeNode;
    Percorso : String;
begin
    Percorso := PercorsoCustom + '\Custom\';
    if FindFirst(Percorso + '*', faDirectory, Sr) = 0 then
    begin
        repeat
            if (Sr.Attr and faDirectory = faDirectory) and (Sr.Name <> '.') and (Sr.Name <> '..') then
            begin
                Node := TVCartelle.Items.AddChild(ParentNode, Sr.Name);
                Node.Data := Pointer(StrNew(PChar(Percorso + Sr.Name + '\')));
                RiempiTreeView(Percorso + Sr.Name + '\', Node);
            end;
        until FindNext(Sr) <> 0 ;
        FindClose(Sr);
    end;

    if FindFirst(Percorso + '*.*', faAnyFile, Sr) = 0 then
    begin
        repeat
            if (Sr.Attr and faDirectory) = 0 then
            begin
                Node := TVCartelle.Items.AddChild(ParentNode, Sr.Name);
                Node.Data := Pointer(StrNew(PChar(Percorso + Sr.Name)));
            end;
        until FindNext(Sr) <> 0 ;
        FindClose(Sr);
    end;
end;

procedure TfCreaTest.SelezionaTutto1Click(Sender: TObject);
var
    i : Integer;
begin
    for i := 0 to lbDb.Items.Count - 1 do
    begin
        lbDb.Selected[i] := True;
    end;
end;

procedure TfCreaTest.TVCartelleChange(Sender: TObject; Node: TTreeNode);
var
  Path: string;
  Sr: TSearchRec;
begin
  lbContenutoCustom.Items.Clear;
  if Assigned(Node.Data) then
  begin
    Path := string(PChar(Node.Data));
    if FindFirst(Path + '*.*', faAnyFile, Sr) = 0 then
    begin
      repeat
        if (Sr.Attr and faDirectory) = 0 then // Solo file
          lbContenutoCustom.Items.Add(Sr.Name);
      until FindNext(Sr) <> 0;
      FindClose(Sr);
    end;
  end;
end;

end.

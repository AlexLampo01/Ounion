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
    procedure ModificaRegSetup(SceltaDb : String);
    function AnalizzaStringPerDemo(Versione: String) : String;
    function GetServer : TStringList;
    function GetMachineName : String;
  public
    CartellaSelezionata, CartellaFiltrata : String;
  end;

var
  fCreaTest: TfCreaTest;

implementation

uses
    System.IOUtils, Registry, System.RegularExpressions;

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
    SceltaDb : String;
begin
    SceltaDb := cbDb.Text;
    if SceltaDb = '1. Non serve un database particolare, usano la demo' then
    begin
        ModificaRegSetup(SceltaDb);
    end
    else if SceltaDb = '2. Usano il db sul pc dello sviluppatore' then
    begin
        ModificaRegSetup(SceltaDb);
    end
    else if SceltaDb = '3. Hanno già il db su SRVDB01\ASSISTENZA' then
    begin
        if cbDatabase.Text <> '' then
            ControllaSelezione
        else
            MessageDlg('Nessun database selezionato!', mtError, [mbOk], 0);
    end
    else if SceltaDb = '4. Va copiato il db su SRVDB01\ASSISTENZA' then
    begin

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

procedure TfCreaTest.cbDatabaseEnter(Sender: TObject);
var
    Istanza, TestoQuery : String;
    NomiDatabase : TStringList;
begin
    cbDatabase.Items.Clear;
    NomiDatabase := TStringList.Create;
    try
        if not cbIstanze.Visible then
            Istanza := ConnScripts.Params.Values['Server']
        else
            Istanza := cbIstanze.Text;
        if Istanza <> '' then
        begin
            TestoQuery := 'SELECT name AS DatabaseName' + #13#10 +
                          'FROM sys.databases' + #13#10 +
                          'WHERE name NOT IN (' + QuotedStr('master') + ',' + QuotedStr('tempdb') + ',' +QuotedStr('model') + ',' +QuotedStr('msdb') + ')' +
                          'ORDER BY name';
            ConnDatabase.Params.Values['Server'] := Istanza;
            ConnDatabase.Params.Values['User_Name'] := 'sa';
            ConnDatabase.Params.Values['Password'] := 'Grsys2022*';
            ConnDatabase.Connected := True;
            With qDatabase do
            begin
                if Active then
                    Close;
                SQL.Text := TestoQuery;
                Open;

                while not Eof do
                begin
                    NomiDatabase.Add(FieldByName('DatabaseName').AsString);
                    Next;
                end;
            end;
            cbDatabase.Items.Assign(NomiDatabase);
        end;
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
        cbDatabase.Visible := False;
        lbDb.Visible    := False;
        cbIstanze.Visible := False;
    end;
    if (cbDb.Text = '2. Usano il db sul pc dello sviluppatore') then
    begin
        cbDatabase.Visible := True;
        lbDb.Visible    := False;
        cbIstanze.Visible := True;
    end;
    if cbDb.Text = '3. Hanno già il db su SRVDB01\ASSISTENZA' then
    begin
        cbDatabase.Visible := True;
        pnlSceltadb.Height := 116;
        lbDb.Visible    := True;
        cbIstanze.Visible := False;
        lbDb.Items.BeginUpdate;
        try
            lbDb.Items.Clear;
            Percorso := edCartella.Text;
            if ExtractFileName(Percorso) = 'Custom' then
                Percorso := Percorso + '\Scripts'
            else
                Percorso := Percorso + '\Custom\Scripts';
            for FileName in TDirectory.GetFiles(Percorso) do
            begin
                lbDb.Items.Add(TPath.GetFileName(FileName));
            end;
        finally
            lbDb.Items.EndUpdate;
        end;
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
        PercorsoDestinazione := 'C:\TEMP\' + NomeCartellaServer + '\Custom';
        ForceDirectories(PercorsoDestinazione);
        TDirectory.Copy(CartellaSelezionata, PercorsoDestinazione, True);
    end
    else
    begin
        NomeCartellaServer := ExtractFileName(CartellaSelezionata);
        CartellaSelezionata := CartellaSelezionata + '\Custom';
        PercorsoDestinazione := 'C:\TEMP\' + NomeCartellaServer + '\Custom';
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
var
    i : Integer;
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

procedure TfCreaTest.ModificaRegSetup(SceltaDb: String);
var
    Versione, Percorso, VersioneSeparata, DbDemo, Database, NomeProgetto, Username, Password, Server : String;
    i: Integer;
    ContenutoConfig : TStringList;
begin
    Percorso := edCartella.Text;
    if ExtractFileName(Percorso) = 'Custom' then
    begin
        Percorso := ExtractFileDir(Percorso);
    end;
    NomeProgetto := ExtractFileName(Percorso);
    Versione := Percorso;
    for i := 1 to 2 do
    begin
        Versione := ExtractFileDir(Versione);
    end;
    Versione := ExtractFileName(Versione);
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
    end;
    if not FileExists('C:\OS1\OS1 LAUNCHER\Custom.Config\' + NomeProgetto + '.config') then
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

            ContenutoConfig.SaveToFile('C:\OS1\OS1 LAUNCHER\Custom.Config\' + NomeProgetto + '.config');
        finally
            ContenutoConfig.Free;
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

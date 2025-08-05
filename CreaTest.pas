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
  private
    procedure RiempiTreeView(PercorsoCustom : String; ParentNode: TTreeNode = nil);
    procedure CopiaCartelle;
    procedure ControllaSelezione;
  public
    CartellaSelezionata, CartellaFiltrata : String;
  end;

var
  fCreaTest: TfCreaTest;

implementation

uses
    System.IOUtils;

{$R *.dfm}

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

    end
    else if SceltaDb = '2. Usano il db sul pc dello sviluppatore' then
    begin

    end
    else if SceltaDb = '3. Hanno già il db su SRVDB01\ASSISTENZA' then
    begin
        ControllaSelezione;
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

procedure TfCreaTest.cbDbChange(Sender: TObject);
var
    FileName, Percorso : String;
begin
    if cbDb.Text = '3. Hanno già il db su SRVDB01\ASSISTENZA' then
    begin
        pnlSceltadb.Height := 116;
        lbDb.Visible    := True;
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

procedure TfCreaTest.ControllaSelezione;
var
    i,j : Integer;
    ListScript, SQLScript : TStringList;
    Percorso : String;
begin
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
            ShowMessage(SQLScript.Text);
            //qScripts.ExecSQL;
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

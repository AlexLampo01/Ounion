unit CreaTest;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Buttons,
  Vcl.ComCtrls;

type
  TfCreaTest = class(TForm)
    ComboBox1: TComboBox;
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
    procedure edCartellaDblClick(Sender: TObject);
    procedure TVCartelleChange(Sender: TObject; Node: TTreeNode);
    procedure btnContinuaClick(Sender: TObject);
  private
    procedure RiempiTreeView(PercorsoCustom : String; ParentNode: TTreeNode = nil);
  public
    CartellaSelezionata, CartellaFiltrata : String;
  end;

var
  fCreaTest: TfCreaTest;

implementation

uses
    System.IOUtils;

{$R *.dfm}

procedure TfCreaTest.btnContinuaClick(Sender: TObject);
begin
    pnlSelezionaCartella.Visible := False;
    pnlSceltaDb.Visible := True;
    btnSelezionaProgetto.Enabled := False;
    btnDatabase.Enabled := True;
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

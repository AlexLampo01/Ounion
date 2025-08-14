unit SchermataIniziale;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Buttons,
  System.ImageList, Vcl.ImgList, Vcl.VirtualImageList, Vcl.BaseImageCollection,
  Vcl.ImageCollection;

type
  TfScegliCosaFare = class(TForm)
    Panel1: TPanel;
    pnlCentrale: TPanel;
    btnInizializzaProgetto: TBitBtn;
    btnSpostaCartella: TBitBtn;
    btnInformazioniSu: TBitBtn;
    btnCreaRelease: TBitBtn;
    btnCreaTest: TBitBtn;
    ImageCollection1: TImageCollection;
    VirtualImageList1: TVirtualImageList;
    procedure btnInizializzaProgettoClick(Sender: TObject);
    procedure btnSpostaCartellaClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnInizializzaProgettoEnter(Sender: TObject);
    procedure btnSpostaCartellaEnter(Sender: TObject);
    procedure btnInformazioniSuClick(Sender: TObject);
    procedure btnCreaReleaseClick(Sender: TObject);
    procedure btnCreaReleaseEnter(Sender: TObject);
    procedure btnCreaTestClick(Sender: TObject);
  private
    procedure SistemaGrafica;
  public
    LabelInizialize, LabelConsegna, LabelCreaRelease, LabelCreaTest : TLabel;
  end;

var
  fScegliCosaFare: TfScegliCosaFare;

implementation

uses
    InizializzaProgetto, CopiaFileConsegna, About, CreaRelease, CreaTest;

{$R *.dfm}

//TODO Creare un modo per generare la custom per l'assistenza
procedure TfScegliCosaFare.btnCreaReleaseClick(Sender: TObject);
begin
   if not Assigned(CreaRelease.fCreaRelease) then
   begin
        CreaRelease.fCreaRelease := CreaRelease.TfCreaRelease.Create(Self);
        WindowState := wsMaximized;
   end;
    with CreaRelease.fCreaRelease do
    begin
        Parent := pnlCentrale;
        BorderStyle := bsNone;
        Align := alClient;
        Visible := True;
        Show;
    end;
    if Assigned(CopiaFileConsegna.fCopiaFileConsegna) then
    begin
        with CopiaFileConsegna.fCopiaFileConsegna do
        begin
            Parent := pnlCentrale;
            BorderStyle := bsNone;
            Align := alNone;
            Visible := False;
        end;
    end;
    if Assigned(About.fInformazioniSu) then
    with About.fInformazioniSu do
    begin
        Parent := pnlCentrale;
        BorderStyle := bsNone;
        Align := alNone;
        Visible := False;
    end;
    if Assigned(InizializzaProgetto.fInizializzaProgetto) then
    begin
        with InizializzaProgetto.fInizializzaProgetto do
        begin
            Parent := pnlCentrale;
            BorderStyle := bsNone;
            Align := alNone;
            Visible := False;
        end;
    end;
    if Assigned(CreaTest.fCreaTest) then
    with CreaTest.fCreaTest do
    begin
        Parent := pnlCentrale;
        BorderStyle := bsNone;
        Align := alNone;
        Visible := False;
    end;
end;

procedure TfScegliCosaFare.btnCreaReleaseEnter(Sender: TObject);
begin
    btnCreaRelease.ShowHint := True;
end;

procedure TfScegliCosaFare.btnCreaTestClick(Sender: TObject);
begin
    if not Assigned(CreaTest.fCreaTest) then
        CreaTest.fCreaTest := CreaTest.TfCreaTest.Create(Self);
    with CreaTest.fCreaTest do
    begin
        Parent := pnlCentrale;
        BorderStyle := bsNone;
        Align := alClient;
        Visible := True;
    end;
    if Assigned(CopiaFileConsegna.fCopiaFileConsegna) then
    begin
        with CopiaFileConsegna.fCopiaFileConsegna do
        begin
            Parent := pnlCentrale;
            BorderStyle := bsNone;
            Align := alNone;
            Visible := False;
        end;
    end;
    if Assigned(InizializzaProgetto.fInizializzaProgetto) then
    begin
        with InizializzaProgetto.fInizializzaProgetto do
        begin
            Parent := pnlCentrale;
            BorderStyle := bsNone;
            Align := alNone;
            Visible := False;
        end;
    end;
    if Assigned(CreaRelease.fCreaRelease) then
    with CreaRelease.fCreaRelease do
    begin
        Parent := pnlCentrale;
        BorderStyle := bsNone;
        Align := alNone;
        Visible := False;
    end;
    if Assigned(About.fInformazioniSu) then
    with About.fInformazioniSu do
    begin
        Parent := pnlCentrale;
        BorderStyle := bsNone;
        Align := alNone;
        Visible := False;
    end;
end;

procedure TfScegliCosaFare.btnInformazioniSuClick(Sender: TObject);
begin
   if not Assigned(About.fInformazioniSu) then
        About.fInformazioniSu := About.TfInformazioniSu.Create(Self);
    with About.fInformazioniSu do
    begin
        Parent := pnlCentrale;
        BorderStyle := bsNone;
        Align := alClient;
        Visible := True;
    end;
    if Assigned(CopiaFileConsegna.fCopiaFileConsegna) then
    begin
        with CopiaFileConsegna.fCopiaFileConsegna do
        begin
            Parent := pnlCentrale;
            BorderStyle := bsNone;
            Align := alNone;
            Visible := False;
        end;
    end;
    if Assigned(InizializzaProgetto.fInizializzaProgetto) then
    begin
        with InizializzaProgetto.fInizializzaProgetto do
        begin
            Parent := pnlCentrale;
            BorderStyle := bsNone;
            Align := alNone;
            Visible := False;
        end;
    end;
    if Assigned(CreaRelease.fCreaRelease) then
    with CreaRelease.fCreaRelease do
    begin
        Parent := pnlCentrale;
        BorderStyle := bsNone;
        Align := alNone;
        Visible := False;
    end;
    if Assigned(CreaTest.fCreaTest) then
    with CreaTest.fCreaTest do
    begin
        Parent := pnlCentrale;
        BorderStyle := bsNone;
        Align := alNone;
        Visible := False;
    end;
end;

procedure TfScegliCosaFare.btnInizializzaProgettoClick(Sender: TObject);
begin
    if not Assigned(InizializzaProgetto.fInizializzaProgetto) then
        InizializzaProgetto.fInizializzaProgetto := InizializzaProgetto.TfInizializzaProgetto.Create(Self);
    with InizializzaProgetto.fInizializzaProgetto do
    begin
        Parent := pnlCentrale;
        BorderStyle := bsNone;
        Align := alClient;
        Visible := True;
    end;
    if Assigned(CopiaFileConsegna.fCopiaFileConsegna) then
    begin
        with CopiaFileConsegna.fCopiaFileConsegna do
        begin
            Parent := pnlCentrale;
            BorderStyle := bsNone;
            Align := alNone;
            Visible := False;
        end;
    end;
    if Assigned(About.fInformazioniSu) then
    with About.fInformazioniSu do
    begin
        Parent := pnlCentrale;
        BorderStyle := bsNone;
        Align := alNone;
        Visible := False;
    end;
    if Assigned(CreaRelease.fCreaRelease) then
    with CreaRelease.fCreaRelease do
    begin
        Parent := pnlCentrale;
        BorderStyle := bsNone;
        Align := alNone;
        Visible := False;
    end;
    if Assigned(CreaTest.fCreaTest) then
    with CreaTest.fCreaTest do
    begin
        Parent := pnlCentrale;
        BorderStyle := bsNone;
        Align := alNone;
        Visible := False;
    end;
end;

procedure TfScegliCosaFare.btnInizializzaProgettoEnter(Sender: TObject);
begin
    btnInizializzaProgetto.ShowHint := True;
end;

procedure TfScegliCosaFare.btnSpostaCartellaClick(Sender: TObject);
begin
    if not Assigned(CopiaFileConsegna.fCopiaFileConsegna) then
        CopiaFileConsegna.fCopiaFileConsegna := CopiaFileConsegna.TfCopiaFileConsegna.Create(Self);
    with CopiaFileConsegna.fCopiaFileConsegna do
    begin
        Parent := pnlCentrale;
        BorderStyle := bsNone;
        Align := alClient;
        Visible := True;
    end;
    if Assigned(InizializzaProgetto.fInizializzaProgetto) then
    begin
        with InizializzaProgetto.fInizializzaProgetto do
        begin
            Parent := pnlCentrale;
            BorderStyle := bsNone;
            Align := alNone;
            Visible := False;
        end;
    end;
    if Assigned(About.fInformazioniSu) then
    with About.fInformazioniSu do
    begin
        Parent := pnlCentrale;
        BorderStyle := bsNone;
        Align := alNone;
        Visible := False;
    end;
    if Assigned(CreaRelease.fCreaRelease) then
    with CreaRelease.fCreaRelease do
    begin
        Parent := pnlCentrale;
        BorderStyle := bsNone;
        Align := alNone;
        Visible := False;
    end;
    if Assigned(CreaTest.fCreaTest) then
    with CreaTest.fCreaTest do
    begin
        Parent := pnlCentrale;
        BorderStyle := bsNone;
        Align := alNone;
        Visible := False;
    end;
end;

procedure TfScegliCosaFare.btnSpostaCartellaEnter(Sender: TObject);
begin
    btnSpostaCartella.ShowHint := True;
end;

procedure TfScegliCosaFare.FormCreate(Sender: TObject);
begin
    Self.ShowHint := True;

    LabelInizialize          := TLabel.Create(Self);
    LabelInizialize.Parent   := Panel1;
    LabelInizialize.Caption  := 'Inizializza Progetto';
    LabelInizialize.Left     := 40;
    LabelInizialize.Height   := 15;
    LabelInizialize.Top      := 256;
    LabelInizialize.Width    := 134;

    LabelConsegna            := TLabel.Create(Self);
    LabelConsegna.Parent     := Panel1;
    LabelConsegna.Caption    := 'Prepara Consegna';
    LabelConsegna.Left       := 420;
    LabelConsegna.Height     := 15;
    LabelConsegna.Top        := 256;
    LabelConsegna.Width      := 134;

    LabelCreaRelease         := TLabel.Create(Self);
    LabelCreaRelease.Parent  := Panel1;
    LabelCreaRelease.Caption := 'Crea Release';
    LabelCreaRelease.Left    := 40;
    LabelCreaRelease.Height  := 15;
    LabelCreaRelease.Top     := 499;
    LabelCreaRelease.Width   := 134;

    LabelCreaTest            := TLabel.Create(Self);
    LabelCreaTest.Parent     := Panel1;
    LabelCreaTest.Caption    := 'Crea Test';
    LabelCreaTest.Left       := 420;
    LabelCreaTest.Height     := 15;
    LabelCreaTest.Top        := 499;
    LabelCreaTest.Width      := 134;
end;

procedure TfScegliCosaFare.SistemaGrafica;
begin
    FreeAndNil(LabelCreaTest);
    FreeAndNil(LabelCreaRelease);
    FreeAndNil(LabelConsegna);
    FreeAndNil(LabelInizialize);
    VirtualImageList1.Height       := 52;
    VirtualImageList1.Width        := 52;
    Panel1.Align                   := alTop;
    Panel1.Height                  := 53;
    Panel1.Width                   := 598;
    pnlCentrale.Align := alClient;
    btnInizializzaProgetto.Height  := 45;
    btnSpostaCartella.Height       := 45;
    btnCreaRelease.Height          := 45;
    btnCreaTest.Height             := 45;
    btnInizializzaProgetto.Left    := 16;
    btnSpostaCartella.Left         := 77;
    btnCreaRelease.Left            := 138;
    btnCreaTest.Left               := 215;
    btnInizializzaProgetto.Width   := 45;
    btnSpostaCartella.Width        := 45;
    btnCreaRelease.Width           := 45;
    btnCreaTest.Width              := 45;
    btnInizializzaProgetto.Top     := 3;
    btnSpostaCartella.Top          := 3;
    btnCreaRelease.Top             := 3;
    btnCreaTest.Top                := 3;

end;

end.

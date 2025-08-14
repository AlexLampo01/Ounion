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
    procedure SistemaGrafica(ElementoSelezionato : String);
  public
    LabelInizialize, LabelConsegna, LabelCreaRelease, LabelCreaTest : TLabel;
    btnModalitaAttuale : TBitBtn;
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
        SistemaGrafica('Crea Release');
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
    begin
        SistemaGrafica('Crea Test');
        CreaTest.fCreaTest := CreaTest.TfCreaTest.Create(Self);
    end;
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
   begin
        SistemaGrafica('Informazioni Su');
        About.fInformazioniSu := About.TfInformazioniSu.Create(Self);
   end;
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
    begin
        SistemaGrafica('Inzializza Progetto');
        InizializzaProgetto.fInizializzaProgetto := InizializzaProgetto.TfInizializzaProgetto.Create(Self);
    end;
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
    begin
        SistemaGrafica('Copia File Consegna');
        CopiaFileConsegna.fCopiaFileConsegna := CopiaFileConsegna.TfCopiaFileConsegna.Create(Self);
    end;
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

    LabelInizialize            := TLabel.Create(Self);
    LabelInizialize.Parent     := Panel1;
    LabelInizialize.Caption    := 'Inizializza Progetto';
    LabelInizialize.Left       := 40;
    LabelInizialize.Height     := 15;
    LabelInizialize.Top        := 256;
    LabelInizialize.Width      := 134;
    LabelInizialize.Alignment  := taCenter;

    LabelConsegna              := TLabel.Create(Self);
    LabelConsegna.Parent       := Panel1;
    LabelConsegna.Caption      := 'Prepara Consegna';
    LabelConsegna.Left         := 420;
    LabelConsegna.Height       := 15;
    LabelConsegna.Top          := 256;
    LabelConsegna.Width        := 134;
    LabelConsegna.Alignment    := taCenter;

    LabelCreaRelease           := TLabel.Create(Self);
    LabelCreaRelease.Parent    := Panel1;
    LabelCreaRelease.Caption   := 'Crea Release';
    LabelCreaRelease.Left      := 40;
    LabelCreaRelease.Height    := 15;
    LabelCreaRelease.Top       := 499;
    LabelCreaRelease.Width     := 134;
    LabelCreaRelease.Alignment := taCenter;

    LabelCreaTest              := TLabel.Create(Self);
    LabelCreaTest.Parent       := Panel1;
    LabelCreaTest.Caption      := 'Crea Test';
    LabelCreaTest.Left         := 420;
    LabelCreaTest.Height       := 15;
    LabelCreaTest.Top          := 499;
    LabelCreaTest.Width        := 134;
    LabelCreaTest.Alignment    := taCenter;
end;

procedure TfScegliCosaFare.SistemaGrafica(ElementoSelezionato : String);
begin
    FreeAndNil(LabelCreaTest);
    FreeAndNil(LabelCreaRelease);
    FreeAndNil(LabelConsegna);
    FreeAndNil(LabelInizialize);
    VirtualImageList1.Height        := 52;
    VirtualImageList1.Width         := 52;
    Panel1.Align                    := alTop;
    Panel1.Height                   := 53;
    Panel1.Width                    := 598;
    pnlCentrale.Align := alClient;
    btnModalitaAttuale              := tBitBtn.Create(Self);
    btnModalitaAttuale.Parent       := Panel1;
    btnModalitaAttuale.Visible      := True;
    btnModalitaAttuale.Height       := 45;
    btnModalitaAttuale.Left         := 16;
    btnModalitaAttuale.Width        := 45;
    btnModalitaAttuale.Top          := 3;
    btnModalitaAttuale.Images       := VirtualImageList1;

    btnInizializzaProgetto.Visible  := False;
    btnSpostaCartella.Visible       := False;
    btnCreaRelease.Visible          := False;
    btnCreaTest.Visible             := False;

    if ElementoSelezionato = 'Inzializza Progetto' then
    begin
        btnModalitaAttuale.ImageIndex := 4;
        btnModalitaAttuale.Hint := 'Inzializza Progetto';
    end
    else if ElementoSelezionato = 'Copia File Consegna' then
    begin
        btnModalitaAttuale.ImageIndex := 5;
        btnModalitaAttuale.Hint := 'Copia File Consegna';
    end
    else if ElementoSelezionato = 'Crea Release' then
    begin
        btnModalitaAttuale.ImageIndex := 6;
        btnModalitaAttuale.Hint := 'Crea Release';
    end
    else if ElementoSelezionato = 'Crea Test' then
    begin
        btnModalitaAttuale.ImageIndex := 7;
        btnModalitaAttuale.Hint := 'Crea Test';
    end
end;

end.

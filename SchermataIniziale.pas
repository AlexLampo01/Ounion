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
    procedure SistemaGraficaGrande;
    procedure btnModalitaAttualeClick(Sender: TObject);
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

procedure TfScegliCosaFare.btnCreaReleaseClick(Sender: TObject);
begin
   if not Assigned(CreaRelease.fCreaRelease) then
   begin
        SistemaGrafica('Crea Release');
        CreaRelease.fCreaRelease := CreaRelease.TfCreaRelease.Create(nil);
        WindowState := wsMaximized;
        with CreaRelease.fCreaRelease do
        begin
            Parent := pnlCentrale;
            BorderStyle := bsNone;
            Align := alClient;
            Visible := True;
        end;
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
        CreaTest.fCreaTest := CreaTest.TfCreaTest.Create(nil);
        with CreaTest.fCreaTest do
        begin
            Parent := pnlCentrale;
            BorderStyle := bsNone;
            Align := alClient;
            Visible := True;
        end;
    end;
end;

procedure TfScegliCosaFare.btnInformazioniSuClick(Sender: TObject);
begin
   if not Assigned(About.fInformazioniSu) then
   begin
        SistemaGrafica('Informazioni Su');
        About.fInformazioniSu := About.TfInformazioniSu.Create(nil);
        with About.fInformazioniSu do
        begin
            Parent := pnlCentrale;
            BorderStyle := bsNone;
            Align := alClient;
            Visible := True;
        end;
   end;
end;

procedure TfScegliCosaFare.btnInizializzaProgettoClick(Sender: TObject);
begin
    if not Assigned(InizializzaProgetto.fInizializzaProgetto) then
    begin
        SistemaGrafica('Inzializza Progetto');
        InizializzaProgetto.fInizializzaProgetto := InizializzaProgetto.TfInizializzaProgetto.Create(nil);
        with InizializzaProgetto.fInizializzaProgetto do
        begin
            Parent := pnlCentrale;
            BorderStyle := bsNone;
            Align := alClient;
            Visible := True;
        end;
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
        CopiaFileConsegna.fCopiaFileConsegna := CopiaFileConsegna.TfCopiaFileConsegna.Create(nil);
        with CopiaFileConsegna.fCopiaFileConsegna do
        begin
            Parent := pnlCentrale;
            BorderStyle := bsNone;
            Align := alClient;
            Visible := True;
        end;
    end;
end;

procedure TfScegliCosaFare.btnSpostaCartellaEnter(Sender: TObject);
begin
    btnSpostaCartella.ShowHint := True;
end;

procedure TfScegliCosaFare.FormCreate(Sender: TObject);
begin
    Self.ShowHint := True;
    SistemaGraficaGrande;
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
    btnModalitaAttuale.OnClick      := btnModalitaAttualeClick;

    btnInizializzaProgetto.Visible  := False;
    btnSpostaCartella.Visible       := False;
    btnCreaRelease.Visible          := False;
    btnCreaTest.Visible             := False;

    if ElementoSelezionato = 'Inzializza Progetto' then
    begin
        btnModalitaAttuale.ImageIndex := 8;
        btnModalitaAttuale.Hint := 'Torna Indietro';
    end
    else if ElementoSelezionato = 'Copia File Consegna' then
    begin
        btnModalitaAttuale.ImageIndex := 8;
        btnModalitaAttuale.Hint := 'Torna Indietro';
    end
    else if ElementoSelezionato = 'Crea Release' then
    begin
        btnModalitaAttuale.ImageIndex := 8;
        btnModalitaAttuale.Hint := 'Torna Indietro';
    end
    else if ElementoSelezionato = 'Crea Test' then
    begin
        btnModalitaAttuale.ImageIndex := 8;
        btnModalitaAttuale.Hint := 'Torna Indietro';
    end
    else if ElementoSelezionato = 'Informazioni Su' then
    begin
        btnModalitaAttuale.ImageIndex := 8;
        btnModalitaAttuale.Hint := 'Torna Indietro';
    end;
end;

procedure TfScegliCosaFare.SistemaGraficaGrande;
begin
    LabelInizialize            := TLabel.Create(Self);
    LabelInizialize.Parent     := Panel1;
    LabelInizialize.Caption    := 'Inizializza Progetto';
    LabelInizialize.Left       := 420;
    LabelInizialize.Height     := 15;
    LabelInizialize.Top        := 256;
    LabelInizialize.Width      := 134;
    LabelInizialize.Alignment  := taCenter;

    LabelConsegna              := TLabel.Create(Self);
    LabelConsegna.Parent       := Panel1;
    LabelConsegna.Caption      := 'Prepara Consegna';
    LabelConsegna.Left         := 420;
    LabelConsegna.Height       := 15;
    LabelConsegna.Top          := 499;
    LabelConsegna.Width        := 134;
    LabelConsegna.Alignment    := taCenter;

    LabelCreaRelease           := TLabel.Create(Self);
    LabelCreaRelease.Parent    := Panel1;
    LabelCreaRelease.Caption   := 'Crea Release';
    LabelCreaRelease.Left      := 40;
    LabelCreaRelease.Height    := 15;
    LabelCreaRelease.Top       := 256;
    LabelCreaRelease.Width     := 134;
    LabelCreaRelease.Alignment := taCenter;

    LabelCreaTest              := TLabel.Create(Self);
    LabelCreaTest.Parent       := Panel1;
    LabelCreaTest.Caption      := 'Crea Test';
    LabelCreaTest.Left         := 40;
    LabelCreaTest.Height       := 15;
    LabelCreaTest.Top          := 499;
    LabelCreaTest.Width        := 134;
    LabelCreaTest.Alignment    := taCenter;
end;

procedure TfScegliCosaFare.btnModalitaAttualeClick(Sender: TObject);
begin
    if Assigned(CopiaFileConsegna.fCopiaFileConsegna) then
    begin
        FreeAndNil(CopiaFileConsegna.fCopiaFileConsegna)
    end;
    if Assigned(InizializzaProgetto.fInizializzaProgetto) then
    begin
        FreeAndNil(InizializzaProgetto.fInizializzaProgetto)
    end;
    if Assigned(About.fInformazioniSu) then
    begin
        FreeAndNil(About.fInformazioniSu)
    end;
    if Assigned(CreaTest.fCreaTest) then
    begin
        FreeAndNil(CreaTest.fCreaTest)
    end;
    if Assigned(CreaRelease.fCreaRelease) then
    begin
        FreeAndNil(CreaRelease.fCreaRelease);
        fScegliCosaFare.Height := 621;
        fScegliCosaFare.Width  := 606;
    end;
    SistemaGraficaGrande;
    btnModalitaAttuale.Visible      := False;
    VirtualImageList1.Height        := 128;
    VirtualImageList1.Width         := 128;
    pnlCentrale.Align               := alNone;
    pnlCentrale.Height              := 0;
    Panel1.Align                    := alClient;
    Panel1.Width                    := 590;
    Panel1.Height                   := 582;

    btnInizializzaProgetto.Visible  := True;
    btnSpostaCartella.Visible       := True;
    btnCreaRelease.Visible          := True;
    btnCreaTest.Visible             := True;

end;

end.

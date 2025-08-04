unit SchermataIniziale;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Buttons;

type
  TfScegliCosaFare = class(TForm)
    Panel1: TPanel;
    pnlCentrale: TPanel;
    btnInizializzaProgetto: TBitBtn;
    btnSpostaCartella: TBitBtn;
    btnInformazioniSu: TBitBtn;
    btnCreaRelease: TBitBtn;
    btnCreaTest: TBitBtn;
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
    { Private declarations }
  public
    { Public declarations }
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
end;

end.

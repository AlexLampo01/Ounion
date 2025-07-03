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
    procedure btnInizializzaProgettoClick(Sender: TObject);
    procedure btnSpostaCartellaClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fScegliCosaFare: TfScegliCosaFare;

implementation

uses
    InizializzaProgetto, CopiaFileConsegna;

{$R *.dfm}

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
end;

end.

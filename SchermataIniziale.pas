unit SchermataIniziale;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls;

type
  TfScegliCosaFare = class(TForm)
    Panel1: TPanel;
    imgInizializzaProgetto: TImage;
    Image2: TImage;
    Image3: TImage;
    pnlCentrale: TPanel;
    procedure imgInizializzaProgettoClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fScegliCosaFare: TfScegliCosaFare;

implementation

uses
    InizializzaProgetto;

{$R *.dfm}

procedure TfScegliCosaFare.imgInizializzaProgettoClick(Sender: TObject);
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
end;

end.

program MECToolsUnioneProgetti;

uses
  Vcl.Forms,
  SchermataIniziale in 'SchermataIniziale.pas' {fScegliCosaFare},
  InizializzaProgetto in 'InizializzaProgetto.pas' {fInizializzaProgetto},
  CopiaFileConsegna in 'CopiaFileConsegna.pas' {fCopiaFileConsegna};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfScegliCosaFare, fScegliCosaFare);
  Application.Run;
end.

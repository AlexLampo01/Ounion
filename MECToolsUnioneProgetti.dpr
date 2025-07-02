program MECToolsUnioneProgetti;

uses
  Vcl.Forms,
  SchermataIniziale in 'SchermataIniziale.pas' {fScegliCosaFare};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfScegliCosaFare, fScegliCosaFare);
  Application.Run;
end.

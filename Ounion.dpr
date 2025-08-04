program Ounion;

uses
  Vcl.Forms,
  SchermataIniziale in 'SchermataIniziale.pas' {fScegliCosaFare},
  InizializzaProgetto in 'InizializzaProgetto.pas' {fInizializzaProgetto},
  CopiaFileConsegna in 'CopiaFileConsegna.pas' {fCopiaFileConsegna},
  About in 'About.pas' {fInformazioniSu},
  Questions in 'Questions.pas' {tQuestions},
  Podio in 'Podio.pas' {fPodio},
  CreaRelease in 'CreaRelease.pas' {fCreaRelease},
  CreaRelease_Istanza in 'CreaRelease_Istanza.pas' {fIstanza},
  SettingsIstanza in 'SettingsIstanza.pas' {fSettingsIstanza},
  CreaTest in 'CreaTest.pas' {fCreaTest};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfScegliCosaFare, fScegliCosaFare);
  Application.Run;
end.

unit Questions;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.ExtCtrls,
  System.ImageList, Vcl.ImgList, Vcl.StdCtrls, Vcl.Buttons, System.StrUtils,System.Types, System.Generics.Collections;

type
  TtQuestions = class(TForm)
    pbLoading: TProgressBar;
    tTempoDomanda: TTimer;
    pUpper: TPanel;
    Image1: TImage;
    ILImmagini: TImageList;
    pnlRisposte: TPanel;
    lblQuestion: TLabel;
    btnRisposta1: TBitBtn;
    btnRisposta2: TBitBtn;
    btnRisposta3: TBitBtn;
    btnRisposta4: TBitBtn;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure tTempoDomandaTimer(Sender: TObject);
  private
    DomandeUscite, DomandaConRispostaUscita : TStringList;
    function RegolaBarra : Boolean;
    function ScegliUnaDomanda(DomandeERisposte : TStringList) : TStringList;
    procedure StrutturaDomande(DomandeERisposte : TStringList);
    procedure RiempiButtons(DomandaERisposte : TStringList);
    procedure RegolaBottoni(var ListaBottoni: TObjectList<TBitBtn>; const Risposte: TStringList);

  public
    { Public declarations }
  end;

var
  tQuestions: TtQuestions;

implementation


{$R *.dfm}

procedure TtQuestions.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    Free;
end;

procedure TtQuestions.FormCreate(Sender: TObject);
var
    DomandeERisposte : TStringList;
begin
    Show;
    Sleep(1000);
    pbLoading.Position := 0;
    tTempoDomanda.Enabled := True;
    DomandeERisposte := TStringList.Create;
    DomandeUscite := TStringList.Create;
    DomandaConRispostaUscita := TStringList.Create;
    try
        StrutturaDomande(DomandeERisposte);
        DomandaConRispostaUscita := ScegliUnaDomanda(DomandeERisposte);
    finally
        DomandeERisposte.Free;
    end;

end;

function TtQuestions.RegolaBarra : Boolean;
begin
    Result := False;
    pbLoading.Position := pbLoading.Position + 1;
    Application.ProcessMessages;
    if pbLoading.Position = pbLoading.Max then
        Result := True;
end;

procedure TtQuestions.RegolaBottoni(var ListaBottoni: TObjectList<TBitBtn>;
  const Risposte: TStringList);
var
  i: Integer;
  MaxWidth, TextWidth: Integer;
  Button: TBitBtn;
  OldWidth: Integer;
  Canvas: TControlCanvas;
begin
  if (ListaBottoni.Count = 0) or (Risposte.Count < 4) then
    Exit;

  Canvas := TControlCanvas.Create;
  try
    Canvas.Control := ListaBottoni[0]; // Associa al primo bottone per accedere al font
    Canvas.Font := ListaBottoni[0].Font;

    MaxWidth := 0;

    for i := 1 to 4 do // Risposte dalla posizione 1 a 4 (0 è la domanda)
    begin
      TextWidth := Canvas.TextWidth(Risposte[i]);
      if TextWidth > MaxWidth then
        MaxWidth := TextWidth;
    end;

    MaxWidth := MaxWidth + 20; // margine interno

    for i := 0 to ListaBottoni.Count - 1 do
    begin
      Button := ListaBottoni[i];
      OldWidth := Button.Width;

      // Assegna la risposta
      Button.Caption := Risposte[i + 1]; // +1 perché [0] è la domanda

      // Imposta nuova larghezza
      Button.Width := MaxWidth;

      // Se è sulla destra, spostalo a sinistra della differenza
      if Button.Left > (Button.Parent.Width div 2) then
        Button.Left := Button.Left - (MaxWidth - OldWidth);
    end;

  finally
    Canvas.Free;
  end;
end;

procedure TtQuestions.RiempiButtons(DomandaERisposte: TStringList);
var
  i, BottoneCasuale: Integer;
  ListaBottoni: TObjectList<TBitBtn>;
  Ctrl: TControl;
  RisposteUsate: TList<Integer>;
begin
  Randomize;

  lblQuestion.Caption := DomandaERisposte[0];

  ListaBottoni := TObjectList<TBitBtn>.Create(False);
  RisposteUsate := TList<Integer>.Create;
  try
    // Raccogli i bottoni
    for i := 0 to pnlRisposte.ControlCount - 1 do
    begin
      Ctrl := pnlRisposte.Controls[i];
      if Ctrl is TBitBtn then
        ListaBottoni.Add(TBitBtn(Ctrl));
    end;

    // Associa risposte in modo casuale
    for i := 1 to 4 do
    begin
      repeat
        BottoneCasuale := Random(4);
      until ListaBottoni[BottoneCasuale].Caption = 'Risposta';

      ListaBottoni[BottoneCasuale].Caption := DomandaERisposte[i];
      with ListaBottoni[BottoneCasuale] do
      begin
        Width := Canvas.TextWidth(Caption) + 20;
      end;
    end;

  finally
    ListaBottoni.Free;
    RisposteUsate.Free;
  end;
end;

function TtQuestions.ScegliUnaDomanda(DomandeERisposte: TStringList) : TStringList;
var
    RandomQuestion : Integer;
    DomandaInserita : Boolean;
    DomandaScelta : String;
    DomandaSeparata : TArray<String>;
    DomandeConRisposteSeparate : TStringList;
    i: Integer;
begin
    Randomize;
    DomandaInserita := False;
    DomandeConRisposteSeparate := TStringList.Create;
    try
        repeat
            RandomQuestion := Random(11);
            if DomandeUscite.IndexOf(RandomQuestion.ToString) = - 1 then
            begin
                DomandeUscite.Add(RandomQuestion.ToString);
                DomandaInserita := True;
            end;
        until DomandaInserita;
        DomandaScelta := DomandeERisposte[RandomQuestion];
        DomandaSeparata := SplitString(DomandaScelta, ';');
        for i := Low(DomandaSeparata) to High(DomandaSeparata) do
        begin
            DomandeConRisposteSeparate.Add(DomandaSeparata[i]);
        end;
        RiempiButtons(DomandeConRisposteSeparate);
    finally
        DomandeConRisposteSeparate.Free;
    end;
end;

procedure TtQuestions.StrutturaDomande(DomandeERisposte : TStringList);
begin
    DomandeERisposte.Add('Che cos''''è una cipolla?;E'''' un ortaggio bulboso appartenente alla famiglia delle Amaryllidaceae.;E'''' un frutto simile al mango.;E''''un''''erba aromatica che cresce in acqua.;E'''' un tubero della famiglia delle solanaceae.');
    DomandeERisposte.Add('Quali sono le varietà più comuni di cipolla?;Bianca,Rossa,Dorata,Tropea,Giarratana.;Mela,Pera,Pesca,Albicocca.;Solo la cipolla rossa è commestibile;Solo la cipolla dorata è naturale, le altre sono OGM.');
    DomandeERisposte.Add('Come cresce la cipolla?;Sviluppa un bulbo sotterraneo e foglie fuori terra.;Galleggia sull''acqua come le ninfee.;Cresce completamente fuori dal terreno, come il mais.;Cresce su rami come un frutto.');
    DomandeERisposte.Add('Qual è la differenza tra cipolla e scalogno?;Lo scalogno è più piccolo e ha un sapore più delicato.;Lo scalogno è il seme della cipolla.;Sono identici ma hanno colore diverso.;Lo scalogno è una varità di cipolla rossa.');
    DomandeERisposte.Add('Le cipolle fioriscono?;Sì,producono un fiore sferico se non raccolte.;No,le cipolle sono piante artificiali.;Fioriscono solo se coltivate in serra.;Solo le cipolle bianche possono fiorire.');
    DomandeERisposte.Add('Come si può cucinare la cipolla?;Cruda,Fritta,Stufata,Caramellata,Grigliata.;Solo bollita in acqua dolce.;Solo fritta, altrimenti è tossica.;Solo cruda o stufata.');
    DomandeERisposte.Add('Qual è la cipolla migliore da mangiare cruda?;Quella rossa di Tropea, dolce e delicata.;Quella marcia o germogliata.;Quella bianca, purchè molto cotta.;Quella dorata, ma solo se sbucciata sott''acqua.');
    DomandeERisposte.Add('Perchè la cipolla fa piangere?;Rilascia un gas che diventa acido solforico negli occhi.;Perchè è emozionata.;Perchè contiene aceto concentrato.;Perchè emete vapore acido solo quando è vecchia.');
    DomandeERisposte.Add('Come si può ridurre il bruciore agli occhi tagliando le cipolle?;Raffreddandola prima, tagliandola sott''acqua o con coltello affilato.;Indossando guanti da forno.;Immergendola nel caffè.;Tagliandola solo al buio.');
    DomandeERisposte.Add('Quanto tempo si può conservare una cipola tagliata?; 2-3 giorni in frigo in un contenitore ermatico.;Fino a 30 giorni fuori dal frigo.;Solo 6 ore, poi diventa velenosa.;Fino a una settimana anche se lasciata scoperta.');
end;

procedure TtQuestions.tTempoDomandaTimer(Sender: TObject);
begin
    if RegolaBarra() then
    begin

    end;
end;

end.

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
    imgDomanda: TImage;
    pnlRisposte: TPanel;
    lblMaxPoint: TLabel;
    btnRisposta1: TBitBtn;
    btnRisposta2: TBitBtn;
    btnRisposta3: TBitBtn;
    btnRisposta4: TBitBtn;
    lblQuestion: TLabel;
    Label2: TLabel;
    tPoint: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure tTempoDomandaTimer(Sender: TObject);
    procedure pbLoadingChange(Sender: TObject);
    procedure btnClick(Sender: TObject);
  private
    DomandeUscite, PercorsoImmagini, DomandeFatte, DomandeERisposte, DomandaInCorso : TStringList;
    NumeroDomandeFatte, Punteggio : Integer;
    DomandaConRispostaUscita : String;
    function RegolaBarra : Boolean;
    function ScegliUnaDomanda(DomandeERisposte : TStringList) : String;
    procedure StrutturaDomande(DomandeERisposte : TStringList);
    procedure RiempiButtons(DomandaERisposte : TStringList);
    procedure RegolaBottoni(var ListaBottoni: TObjectList<TBitBtn>; const Risposte: TStringList);
    procedure RiempiConPercorsi;

  public
    { Public declarations }
  end;

var
  tQuestions: TtQuestions;

implementation


{$R *.dfm}

procedure TtQuestions.btnClick(Sender: TObject);
var
    RispostaScelta : String;
    Btn : TBitBtn;
begin
    Btn := TBitBtn(Sender);
    RispostaScelta := Btn.Caption;
    pbLoading.Position := 0;
    tTempoDomanda.Enabled := False;
    if DomandaInCorso[1] = RispostaScelta then
    begin
        Punteggio := Punteggio + 20;
    end
    else if DomandaInCorso[2] = RispostaScelta then
    begin
        Punteggio := Punteggio - 5;
    end
    else if DomandaInCorso[3] = RispostaScelta then
    begin
        Punteggio := Punteggio - 2;
    end
    else if DomandaInCorso[4] = RispostaScelta then
    begin
        Punteggio := Punteggio + 5;
    end
    else if RispostaScelta = '' then
    begin
        Punteggio := Punteggio + 0;
    end;
    if NumeroDomandeFatte < 5 then
    begin
        pbLoading.Position := 0;
        NumeroDomandeFatte := NumeroDomandeFatte + 1;
        tTempoDomanda.Enabled := True;
        ScegliUnaDomanda(DomandeERisposte);
    end
    else if NumeroDomandeFatte = 5 then
    begin
        tTempoDomanda.Enabled := False;
    end;


end;

procedure TtQuestions.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    DomandeUscite.Free;
    PercorsoImmagini.Free;
    DomandeFatte.Free;
    DomandeERisposte.Free;
    DomandaInCorso.Free;
    Free;
end;

procedure TtQuestions.FormCreate(Sender: TObject);
begin
    Show;
    Sleep(1000);
    pbLoading.Position := 0;
    tTempoDomanda.Enabled := True;
    DomandeERisposte := TStringList.Create;
    DomandeUscite := TStringList.Create;
    DomandeFatte := TStringList.Create;
    DomandaConRispostaUscita := '';
    PercorsoImmagini := TStringList.Create;
    DomandaInCorso  := TStringList.Create;
    NumeroDomandeFatte := 0;
    Punteggio := 0;
    try
        StrutturaDomande(DomandeERisposte);
        DomandaConRispostaUscita := ScegliUnaDomanda(DomandeERisposte);
        DomandeFatte.Add(DomandaConRispostaUscita);
    finally
    end;

end;

procedure TtQuestions.pbLoadingChange(Sender: TObject);
begin
    if pbLoading.Position = pbLoading.Max then
    begin
        if NumeroDomandeFatte < 5 then
        begin
            pbLoading.Position := 0;
            NumeroDomandeFatte := NumeroDomandeFatte + 1;
            ScegliUnaDomanda(DomandeERisposte);
        end
        else if NumeroDomandeFatte = 5 then
        begin
            tTempoDomanda.Enabled := False;
        end;
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
  i, BottoneCasuale, ImmagineCasuale: Integer;
  ListaBottoni: TObjectList<TBitBtn>;
  Ctrl: TControl;
  RisposteUsate: TList<Integer>;
begin
  Randomize;

  lblQuestion.Caption := DomandaERisposte[0];
  ImmagineCasuale   := Random(3);
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

    for i := 0 to ListaBottoni.Count - 1 do
        ListaBottoni[i].Caption := 'Risposta';
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
    lblQuestion.Visible := True;
    btnRisposta1.Visible := True;
    btnRisposta2.Visible := True;
    imgDomanda.Picture.LoadFromFile(PercorsoImmagini[ImmagineCasuale]);
    btnRisposta3.Visible := True;
    btnRisposta4.Visible := True;

  finally
    ListaBottoni.Free;
    RisposteUsate.Free;
  end;
end;

procedure TtQuestions.RiempiConPercorsi;
begin
    PercorsoImmagini.Add('C:\MecTools Functions\MecTools - Unione Progetti\Repositories\Cipolle\Cipolla1.bmp');
    PercorsoImmagini.Add('C:\MecTools Functions\MecTools - Unione Progetti\Repositories\Cipolle\Cipolla2.bmp');
    PercorsoImmagini.Add('C:\MecTools Functions\MecTools - Unione Progetti\Repositories\Cipolle\Cipolla3.bmp');
    PercorsoImmagini.Add('C:\MecTools Functions\MecTools - Unione Progetti\Repositories\Cipolle\Cipolla4.bmp');
    PercorsoImmagini.Add('C:\MecTools Functions\MecTools - Unione Progetti\Repositories\Cipolle\Cipolla5.bmp');
    PercorsoImmagini.Add('C:\MecTools Functions\MecTools - Unione Progetti\Repositories\Cipolle\Cipolla6.bmp');
    PercorsoImmagini.Add('C:\MecTools Functions\MecTools - Unione Progetti\Repositories\Cipolle\Cipolla7.bmp');
    PercorsoImmagini.Add('C:\MecTools Functions\MecTools - Unione Progetti\Repositories\Cipolle\Cipolla8.bmp');
    PercorsoImmagini.Add('C:\MecTools Functions\MecTools - Unione Progetti\Repositories\Cipolle\Cipolla9.bmp');
    PercorsoImmagini.Add('C:\MecTools Functions\MecTools - Unione Progetti\Repositories\Cipolle\Cipolla10.bmp');
    PercorsoImmagini.Add('C:\MecTools Functions\MecTools - Unione Progetti\Repositories\Cipolle\Cipolla11.bmp');
    PercorsoImmagini.Add('C:\MecTools Functions\MecTools - Unione Progetti\Repositories\Cipolle\Cipolla12.bmp');
    PercorsoImmagini.Add('C:\MecTools Functions\MecTools - Unione Progetti\Repositories\Cipolle\Cipolla13.bmp');
    PercorsoImmagini.Add('C:\MecTools Functions\MecTools - Unione Progetti\Repositories\Cipolle\Cipolla14.bmp');
    PercorsoImmagini.Add('C:\MecTools Functions\MecTools - Unione Progetti\Repositories\Cipolle\Cipolla15.bmp');
end;

function TtQuestions.ScegliUnaDomanda(DomandeERisposte: TStringList) : String;
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
    RiempiConPercorsi;
    DomandaInCorso.Clear;
    DomandeConRisposteSeparate := TStringList.Create;
    try
        repeat
            RandomQuestion := Random(21);
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
        Result := DomandeConRisposteSeparate[0];
        DomandaInCorso.Assign(DomandeConRisposteSeparate);
        RiempiButtons(DomandeConRisposteSeparate);
    finally
        DomandeConRisposteSeparate.Free;
    end;
end;

procedure TtQuestions.StrutturaDomande(DomandeERisposte : TStringList);
begin
    DomandeERisposte.Add('Che cos''è una cipolla?;E'' un ortaggio bulboso appartenente alla famiglia delle Amaryllidaceae.;E'' un frutto simile al mango.;E''''un''''erba aromatica che cresce in acqua.;E'''' un tubero della famiglia delle solanaceae.');
    DomandeERisposte.Add('Quali sono le varietà più comuni di cipolla?;Bianca,Rossa,Dorata,Tropea,Giarratana.;Mela,Pera,Pesca,Albicocca.;Solo la cipolla rossa è commestibile;Solo la cipolla dorata è naturale, le altre sono OGM.');
    DomandeERisposte.Add('Come cresce la cipolla?;Sviluppa un bulbo sotterraneo e foglie fuori terra.;Galleggia sull''acqua come le ninfee.;Cresce completamente fuori dal terreno, come il mais.;Cresce su rami come un frutto.');
    DomandeERisposte.Add('Qual è la differenza tra cipolla e scalogno?;Lo scalogno è più piccolo e ha un sapore più delicato.;Lo scalogno è il seme della cipolla.;Sono identici ma hanno colore diverso.;Lo scalogno è una varità di cipolla rossa.');
    DomandeERisposte.Add('Le cipolle fioriscono?;Sì,producono un fiore sferico se non raccolte.;No,le cipolle sono piante artificiali.;Fioriscono solo se coltivate in serra.;Solo le cipolle bianche possono fiorire.');
    DomandeERisposte.Add('Come si può cucinare la cipolla?;Cruda,Fritta,Stufata,Caramellata,Grigliata.;Solo bollita in acqua dolce.;Solo fritta, altrimenti è tossica.;Solo cruda o stufata.');
    DomandeERisposte.Add('Qual è la cipolla migliore da mangiare cruda?;Quella rossa di Tropea, dolce e delicata.;Quella marcia o germogliata.;Quella bianca, purchè molto cotta.;Quella dorata, ma solo se sbucciata sott''acqua.');
    DomandeERisposte.Add('Perchè la cipolla fa piangere?;Rilascia un gas che diventa acido solforico negli occhi.;Perchè è emozionata.;Perchè contiene aceto concentrato.;Perchè emete vapore acido solo quando è vecchia.');
    DomandeERisposte.Add('Come si può ridurre il bruciore agli occhi tagliando le cipolle?;Raffreddandola prima, tagliandola sott''acqua o con coltello affilato.;Indossando guanti da forno.;Immergendola nel caffè.;Tagliandola solo al buio.');
    DomandeERisposte.Add('Quanto tempo si può conservare una cipola tagliata?; 2-3 giorni in frigo in un contenitore ermatico.;Fino a 30 giorni fuori dal frigo.;Solo 6 ore, poi diventa velenosa.;Fino a una settimana anche se lasciata scoperta.');
    DomandeERisposte.Add('La cipolla fa bene alla salute?;Sì, è ricca di antiossidanti e ha proprietà antinfiammatorie.;No, è tossica per l''uomo.;Fa solo ingrassare.;Sì, ma solo se mangiata fritta.');
    DomandeERisposte.Add('Le cipolle aiutano contro il raffreddore?;Possono aiutare grazie alla loro proprietà antimicrobiche.;Provocano raffreddore e febbre alta.;Solo se mangiate crude a digiuno per 7 giorni.;Funzionano come antibiotici naturali sempre.');
    DomandeERisposte.Add('Le cipolle fanno male a chi ha problemi gastrointestinali?;Possono causare gonfiore o fastidi a chi soffre di colon irritabile.;Sono l''alimento perfetto per lo stomaco.;Fanno male solo se crude.;Fanno sempre bene all''intestino in ogni caso.');
    DomandeERisposte.Add('Le cipolle hanno calorie?;Sì, circa 40 cal per 100 grammi;No,sono calorie negative come l''acqua;Ne hanno oltre 500 per 100 grammi;Sì, ma solo se sono rosse.');
    DomandeERisposte.Add('Si possono mangiare le cipolle durante la gravidanza?;Sì, salvo casi particolari da valutare con il medico.;No,è vietato in ogni trimestre.;Solo se cotte in microonde.;Sì, ma solo cipolle bianche biologiche.');
    DomandeERisposte.Add('Da dove proviene la cipolla?;Probabilmente dall''Asia centrale.;E'' stata creata in laboratorio in Europa.;Nasce spontaneamente nei deserti del Nord America.;E'' originaria dell''India e del Sudafrica.');
    DomandeERisposte.Add('Qual è la cipolla più dolce al mondo?;La cipolla di Tropea e la Vidalia (USA).;La cipolla verde acerba.;Solo la cipolla in scatola.;La cipolla caramellata fatta in casa.');
    DomandeERisposte.Add('Cosa significa sognare una cipolla?;Simboleggia lacrime, verità nascoste, strati da scoprire.;Che riceverai tanti soldi.;Indica una dieta sbagliata.;Significa che ami cucinare.');
    DomandeERisposte.Add('Le cipolle sono velenose per gli animali?;Sì, sono tossiche per cani e gatti.;No, fanno bene anche ai cuccioli.;Solo crude sono pericolose, cotte sono un toccasana.;Solo le cipolle rosse sono tossiche.');
    DomandeERisposte.Add('Si può coltivare la cipolla in vaso?;Sì, in vaso profondo con terra drenata e sole.;No, serve una serra con irrigazione automatica.; Solo se coltivata in acqua come le alghe.; Sì, ma solo nei mesi estivi al chiuso.');
end;

procedure TtQuestions.tTempoDomandaTimer(Sender: TObject);
begin
    if RegolaBarra() then
    begin

    end;
end;

end.

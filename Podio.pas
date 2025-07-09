unit Podio;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, IniFiles;

type
  TfPodio = class(TForm)
    Image1: TImage;
    lblPrimo: TLabel;
    lblSecondo: TLabel;
    lblTerzo: TLabel;
    lblNome: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    Procedure ControllaPunteggi;
  public
    { Public declarations }
  end;

var
  fPodio: TfPodio;

implementation

{$R *.dfm}

procedure TfPodio.ControllaPunteggi;
var
  Ini: TIniFile;
  Sezioni, GiocatoreEPunteggio, AggiornatoPodio: TStringList;
  Giocatore, Punteggio, Riga: string;
  i, Punti, MaxCount: Integer;
begin
  if FileExists('\\srvsviluppo22\Common\PodioCipolla\Podio.ini') then
  begin
    Sezioni := TStringList.Create;
    GiocatoreEPunteggio := TStringList.Create;
    AggiornatoPodio := TStringList.Create;
    Ini := TIniFile.Create('\\srvsviluppo22\Common\PodioCipolla\Podio.ini');
    try
      Ini.ReadSections(Sezioni);
      for i := 0 to Sezioni.Count - 1 do
      begin
        Giocatore := Sezioni[i];
        Punteggio := Ini.ReadString(Giocatore, 'Miglior Punteggio', '0');
        Punti := StrToIntDef(Punteggio, 0);
        // Inseriamo il punteggio in formato fisso per ordinamento decrescente
        // es: 0000120|Mario
        Riga := Format('%.8d|%s', [99999999 - Punti, Giocatore]);
        GiocatoreEPunteggio.Add(Riga);
      end;

      GiocatoreEPunteggio.Sort;

      // Estrai i primi 3 (e inverti punteggio)
        if GiocatoreEPunteggio.Count > 3 then
            MaxCount := 3
        else
            MaxCount := GiocatoreEPunteggio.Count;

        for i := 0 to MaxCount - 1 do
        begin
          Riga := GiocatoreEPunteggio[i];
          Giocatore := Copy(Riga, Pos('|', Riga) + 1, MaxInt);
          Punti := 99999999 - StrToIntDef(Copy(Riga, 1, Pos('|', Riga) - 1), 0);
          AggiornatoPodio.Add(Giocatore + ',' + IntToStr(Punti));
        end;

      // Mostra il podio
      for i := 0 to AggiornatoPodio.Count - 1 do
      begin
        //ShowMessage(Format('Posizione %d: %s', [i + 1, AggiornatoPodio[i]]));
        if i = 0 then
        begin
            lblNome.Caption := Copy(AggiornatoPodio[i], 1, Pos(',', AggiornatoPodio[i]) - 1);
            lblPrimo.Caption := Copy(AggiornatoPodio[i], Pos(',', AggiornatoPodio[i]) + 1, Length(AggiornatoPodio[i]));
        end
        else if i = 1 then
        begin
            lblSecondo.Caption := Copy(AggiornatoPodio[i], Pos(',', AggiornatoPodio[i]) + 1, Length(AggiornatoPodio[i]));
        end
        else if i = 2 then
        begin
            lblTerzo.Caption := Copy(AggiornatoPodio[i], Pos(',', AggiornatoPodio[i]) + 1, Length(AggiornatoPodio[i]));
        end;
      end;

    finally
      GiocatoreEPunteggio.Free;
      AggiornatoPodio.Free;
      Sezioni.Free;
      Ini.Free;
    end;
  end;
end;

procedure TfPodio.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    Free;
end;

procedure TfPodio.FormCreate(Sender: TObject);
begin
    With lblPrimo do
    begin
        Top := 348;
        Width := 137;
        Left := 244;
        Height := 15;
    end;
    With lblSecondo do
    begin
        Top := 348;
        Width := 121;
        Left := 124;
        Height := 21;
    end;
    With lblTerzo do
    begin
        Top := 348;
        Width := 114;
        Left := 387;
        Height := 21;
    end;
    With lblNome do
    begin
        Top := 326;
        Width := 137;
        Left := 244;
        Height := 15;
    end;
    ControllaPunteggi;
    Show;
end;

end.

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
    Ini : TIniFile;
    Sezioni, GiocatoreEPunteggio : TStringList;
    Giocatore, Punteggio : String;
    i : Integer;
begin
    if FileExists('\\srvsviluppo22\Common\PodioCipolla\Podio.ini') then
    begin
        Sezioni := TStringList.Create;
        GiocatoreEPunteggio := TStringList.Create;
        Ini := TIniFile.Create('\\srvsviluppo22\Common\PodioCipolla\Podio.ini');
           try
            Ini.ReadSections(Sezioni);
            for i := 0 to Sezioni.Count - 1 do
            begin
                Giocatore := Sezioni[i];
                Punteggio := Ini.ReadString(Giocatore, 'Miglior Punteggio', '0');
                GiocatoreEPunteggio.Add(Giocatore + ',' + Punteggio);
            end;
            //lblPrimo.Caption := GiocatoreEPunteggio[0];
           finally
            GiocatoreEPunteggio.Free;
            Sezioni.Free;
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
        Height := 21;
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
    ControllaPunteggi;
    Show;
end;

end.

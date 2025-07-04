unit Questions;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.ExtCtrls,
  System.ImageList, Vcl.ImgList;

type
  TtQuestions = class(TForm)
    pbLoading: TProgressBar;
    tTempoDomanda: TTimer;
    pUpper: TPanel;
    Image1: TImage;
    ILImmagini: TImageList;
    pnlRisposte: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure tTempoDomandaTimer(Sender: TObject);
  private
    function RegolaBarra : Boolean;
    procedure StrutturaDomande;
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
begin
    Show;
    Sleep(1000);
    pbLoading.Position := 0;
    tTempoDomanda.Enabled := True;
    StrutturaDomande;
end;

function TtQuestions.RegolaBarra : Boolean;
begin
    Result := False;
    pbLoading.Position := pbLoading.Position + 1;
    Application.ProcessMessages;
    if pbLoading.Position = pbLoading.Max then
        Result := True;
end;

procedure TtQuestions.StrutturaDomande;
var
    DomandeERisposte : TStringList;
begin
    DomandeERisposte := TStringList.Create;
    try
        DomandeERisposte.Add('Che cos''''è una cipolla?,E'''' un ortaggio bulboso appartenente alla famiglia delle Amaryllidaceae.,E'''' un frutto simile al mango.,E''''un''''erba aromatica che cresce in acqua.,E'''' un tubero della famiglia delle solanaceae.');
        DomandeERisposte.Add('Quali sono le varietà più comuni di cipolla?,Bianca;Rossa;Dorata;Tropea;Giarratana,Mela;Pera;Pesca;Albicocca,Solo la cipolla rossa è commestibile,Solo la cipolla dorata è naturale, le altre sono OGM.');

    finally
        DomandeERisposte.Free;
    end;
end;

procedure TtQuestions.tTempoDomandaTimer(Sender: TObject);
begin
    if RegolaBarra() then
    begin

    end;
end;

end.

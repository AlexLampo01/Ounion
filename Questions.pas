unit Questions;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.ExtCtrls;

type
  TtQuestions = class(TForm)
    pbLoading: TProgressBar;
    tTempoDomanda: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure tTempoDomandaTimer(Sender: TObject);
  private
    procedure RegolaBarra;
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
end;

procedure TtQuestions.RegolaBarra;
begin
    pbLoading.Position := pbLoading.Position + 1;
    Application.ProcessMessages;
    if pbLoading.Position = pbLoading.Max then
        tTempoDomanda.Enabled := False;
end;

procedure TtQuestions.tTempoDomandaTimer(Sender: TObject);
begin
    RegolaBarra();
end;

end.

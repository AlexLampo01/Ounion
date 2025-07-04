unit About;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls;

type
  TfInformazioniSu = class(TForm)
    imgIcona: TImage;
    procedure imgIconaClick(Sender: TObject);
  private
    NumerodiClick : Integer;
  public
    { Public declarations }
  end;

var
  fInformazioniSu: TfInformazioniSu;

implementation

uses
    Questions;

{$R *.dfm}

procedure TfInformazioniSu.imgIconaClick(Sender: TObject);
begin
    if(GetAsyncKeyState(VK_CONTROL) < 0) and (GetAsyncKeyState(VK_MENU) < 0) then
    begin
        TtQuestions.Create(Self);
    end;

end;

end.

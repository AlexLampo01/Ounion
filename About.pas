unit About;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls;

type
  TfInformazioniSu = class(TForm)
    imgIcona: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Panel1: TPanel;
    Panel2: TPanel;
    Image1: TImage;
    procedure imgIconaClick(Sender: TObject);
  private
  public
    { Public declarations }
  end;

var
  fInformazioniSu: TfInformazioniSu;

implementation

uses
    Questions, Podio;

{$R *.dfm}

procedure TfInformazioniSu.imgIconaClick(Sender: TObject);
begin
    if(GetAsyncKeyState(VK_CONTROL) < 0) and (GetAsyncKeyState(VK_MENU) < 0) then
    begin
        TtQuestions.Create(Self);
    end;
    if(GetAsyncKeyState(VK_CONTROL) < 0) and (GetAsyncKeyState(VK_SHIFT) < 0) then
    begin
        TfPodio.Create(Self);
    end;

end;

end.

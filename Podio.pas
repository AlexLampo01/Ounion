unit Podio;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

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
begin
//
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

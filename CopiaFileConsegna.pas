unit CopiaFileConsegna;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls,
  Vcl.Buttons, Vcl.Grids;

type
  TfCopiaFileConsegna = class(TForm)
    Panel1: TPanel;
    pbLoading: TProgressBar;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    sgFile: TStringGrid;
    sgFileConfermati: TStringGrid;
    imgConfirm: TImage;
    btnSelezionaTutto: TBitBtn;
    BitBtn1: TBitBtn;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fCopiaFileConsegna: TfCopiaFileConsegna;

implementation

{$R *.dfm}

end.

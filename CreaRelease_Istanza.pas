unit CreaRelease_Istanza;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TfIstanza = class(TForm)
    lblUsername: TLabel;
    lblPassword: TLabel;
    edUsername: TEdit;
    edPassword: TEdit;
    btnConferma: TButton;
    procedure btnConfermaClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    procedure ScriviIni;
  public
    { Public declarations }
  end;

var
  fIstanza: TfIstanza;

implementation

uses
    IniFiles, CreaRelease;

{$R *.dfm}

procedure TfIstanza.btnConfermaClick(Sender: TObject);
begin
    if (edUserName.Text <> '') and (edPassword.Text <> '') then
    begin
        ScriviIni;
        Close;
    end
    else
        ShowMessage('Campi non completi');
end;

procedure TfIstanza.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    fCreaRelease.pnlSettings.Visible := False;
end;

procedure TfIstanza.FormShow(Sender: TObject);
begin
    fIstanza.Caption := fCreaRelease.Server;
end;

procedure TfIstanza.ScriviIni;
var
    Ini: TIniFile;
    Keys : TStringList;
begin
    Ini := TIniFile.Create(fCreaRelease.GlobalPercorso);
    Keys := TStringList.Create;
    try
        Ini.ReadSection('Inizio', Keys);
        if Keys.Count > 0 then
        begin
            Ini.EraseSection('Inizio');
        end
        else
            Ini.EraseSection('Inizio')
    finally
        Keys.Free;
        Ini.Free;
    end;
    Ini := TIniFile.Create(fCreaRelease.GlobalPercorso);
    try
        Ini.WriteString(fCreaRelease.Server, 'Username', edUsername.Text);
        Ini.WriteString(fCreaRelease.Server, 'Password', edPassword.Text);
    finally
        Ini.Free;
    end;

end;

end.

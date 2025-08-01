unit SettingsIstanza;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons;

type
  TfSettingsIstanza = class(TForm)
    lbServer: TListBox;
    lblUsername: TLabel;
    lblPassword: TLabel;
    btnConferma: TBitBtn;
    edUsername: TEdit;
    edPassword: TEdit;
    procedure lbServerClick(Sender: TObject);
    procedure btnConfermaClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    procedure RiempiListBox;
    procedure ScriviIni;
    procedure ReadFileIni(Istanza : String);
  public
    IstanzaGlobal, GlobalPercorso : String;
  end;

var
  fSettingsIstanza: TfSettingsIstanza;

implementation

uses
    CreaRelease, IniFiles;

{$R *.dfm}

{ TForm1 }

procedure TfSettingsIstanza.btnConfermaClick(Sender: TObject);
begin
    ScriviIni;
end;

procedure TfSettingsIstanza.FormShow(Sender: TObject);
begin
    RiempiListBox;
end;

procedure TfSettingsIstanza.lbServerClick(Sender: TObject);

begin
    if lbServer.ItemIndex <> - 1 then
    begin
        ReadFileIni(lbServer.Items[lbServer.ItemIndex]);
    end;
end;

procedure TfSettingsIstanza.ReadFileIni(Istanza: String);
var
    Ini: TIniFile;
    Utente, Username, Password, Percorso, Cartella : String;
    Section : TStringList;
    i: Integer;
    TrovataSezione : Boolean;
begin
    Utente := fCreaRelease.GetWindowsUsername;
    TrovataSezione := False;
    Cartella := 'C:\Users\'+ Utente + '\AppData\Roaming\MECTools\MECToolsIstanze\';
    Percorso := Cartella + 'Istanze.ini';
    GlobalPercorso := Percorso;
    if FileExists(Percorso) then
    begin
        Ini := TIniFile.Create(Percorso);
        try
            Section := TStringList.Create;
            try
                Ini.ReadSections(Section);
                for i := 0 to Section.Count - 1 do
                begin
                    if Section[i] = Istanza then
                    begin
                        TrovataSezione := True;
                    end;
                end;
            finally
                Section.Free;
            end;
            if TrovataSezione then
            begin
                Username := Ini.ReadString(Istanza, 'Username', Username);
                Password := Ini.ReadString(Istanza, 'Password', Password);
            end;
            edUsername.Text := Username;
            edPassword.Text := Password;
            IstanzaGlobal := Istanza;
        finally
            Ini.Free;
        end;
    end;
end;

procedure TfSettingsIstanza.RiempiListBox;
var
    Server : TStringList;
begin
    Server := TStringList.Create;
    try
        Server := fCreaRelease.GetServer;
        lbServer.Items.Assign(Server);
    finally
        Server.Free;
    end;
end;

procedure TfSettingsIstanza.ScriviIni;
var
    Ini: TIniFile;
    Keys : TStringList;
begin
    Ini := TIniFile.Create(GlobalPercorso);
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
    Ini := TIniFile.Create(GlobalPercorso);
    try
        Ini.WriteString(IstanzaGlobal, 'Username', edUsername.Text);
        Ini.WriteString(IstanzaGlobal, 'Password', edPassword.Text);
    finally
        Ini.Free;
    end;

end;
end.

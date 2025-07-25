unit CreaRelease;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls;

type
  TfCreaRelease = class(TForm)
    btnConferma: TBitBtn;
    pnlBottom: TPanel;
    pnlCenter: TFlowPanel;
    btnSelezionaTutto: TBitBtn;
    procedure FormCreate(Sender: TObject);
  private
    procedure CercaVersioniBase(ListReleases : TStringList; Percorso : String);
    procedure CercaVersioniPatch(ListDa, ListA : TStringList);
    procedure TrasferisciInUnaStringList(ListDa, ListA : TStringList);
    procedure CreaCheckBox(ListDa : TStringList; APanel: TFlowPanel);
    procedure RiordinaStringList(ListDa : TStringList);
  public
    { Public declarations }
  end;

var
  fCreaRelease: TfCreaRelease;

implementation

uses
    System.IOUtils, System.Generics.Collections, System.Generics.Defaults, Math;

{$R *.dfm}

procedure TfCreaRelease.CercaVersioniBase(ListReleases: TStringList; Percorso : String);
var
    Releases : TArray<String>;
    Release : String;
begin
    Releases := TDirectory.GetDirectories(Percorso);
    for Release in Releases do
    begin
        if Trim(LowerCase(ExtractFileName(Release))).StartsWith('os1_') then
            ListReleases.Add(Release);
    end;
end;

procedure TfCreaRelease.CercaVersioniPatch(ListDa, ListA: TStringList);
var
    i, CountUnderscore, j : Integer;
    Percorso, ReleasePatch, Versione, ReleasePatchCorto, Controllo : String;
    ReleasesPatch: TArray<String>;
begin
    for i := 0 to ListDa.Count - 1 do
    begin
        Percorso := ListDa[i] + '\' + ExtractFileName(ListDa[i]) + '_Patch';
        if DirectoryExists(Percorso) then
        begin
            ReleasesPatch := TDirectory.GetDirectories(Percorso);
            for ReleasePatch in ReleasesPatch do
            begin
                CountUnderScore := 0;
                Versione := '';
                Controllo := '';
                ReleasePatchCorto := ExtractFileName(ReleasePatch);
                for j := 1 to Length(ReleasePatchCorto) do
                begin
                    if ReleasePatchCorto[j] = '_' then
                        CountUnderScore := CountUnderScore + 1;
                    if CountUnderScore >= 2 then
                    begin
                        Controllo := Controllo + ReleasePatchCorto[j]
                    end
                    else
                        Versione := Versione + ReleasePatchCorto[j];
                end;
                Controllo := Copy(Controllo, 2, Length(Controllo));
                if Controllo.StartsWith('0') then
                begin
                    Controllo := Copy(Controllo, Pos('_', Controllo) + 1, Length(Controllo));
                    if Controllo.StartsWith('A') then
                        ListA.Add(ReleasePatchCorto + ';' + Versione);
                end;
            end;
        end;
    end;
end;

procedure TfCreaRelease.CreaCheckBox(ListDa: TStringList; APanel: TFlowPanel);
const
    Margine = 3;                  // margine interno e tra elementi
    CheckBoxWidth = 150;
    CheckBoxHeight = 24;
var
    i: Integer;
    CheckBox: TCheckBox;
    Versione : String;
begin
    RiordinaStringList(ListDa);
    for i := 0 to ListDa.Count - 1 do
    begin
        if ListDa[i].Contains(';') then
            Versione := 'OS1_' + Copy(ListDa[i], Pos(';', ListDa[i]) + 1, Length(ListDa[i]))
        else
            Versione := ListDa[i];
        CheckBox := TCheckBox.Create(APanel);
        CheckBox.Parent := APanel;
        CheckBox.Caption := Versione;
        CheckBox.Width := CheckBoxWidth;
        CheckBox.Height := CheckBoxHeight;
        CheckBox.Margins.Bottom := Margine;
        CheckBox.AlignWithMargins := true;
    end;
end;

procedure TfCreaRelease.FormCreate(Sender: TObject);
var
    ListReleases, ListNameReleases : TStringList;
begin

    ListReleases := TStringList.Create;
    ListNameReleases := TStringList.Create;
    try
        CercaVersioniBase(ListReleases, '\\srvdb\e\OS1\OS1Svi');
        TrasferisciInUnaStringList(ListReleases, ListNameReleases);
        CercaVersioniPatch(ListReleases, ListNameReleases);
        CreaCheckBox(ListNameReleases, pnlCenter);
        Show;
    finally
        ListNameReleases.Free;
        ListReleases.Free;
    end;
end;

procedure TfCreaRelease.RiordinaStringList(ListDa: TStringList);
var
    Gruppi: TObjectDictionary<String, TStringList>;
    Chiavi: TList<Integer>;
    s, Chiave : String;
    NumChiave, i: Integer;
    Risultato: TStringList;
    Figli: TStringList;
begin
    Gruppi := TObjectDictionary<String, TStringList>.Create([doOwnsValues]);
    Chiavi := TList<Integer>.Create;
    Risultato := TStringList.Create;
    try
        for s in ListDa do
        begin
            if UpperCase(s).StartsWith('OS1_') then
            begin
                Chiave := Copy(s, 5, Pos('_', s + '_', 5) - 5);
                NumChiave := StrToIntDef(Chiave, - 1);
                if not Gruppi.ContainsKey(Chiave) then
                begin
                    Gruppi.Add(Chiave, TStringList.Create);
                    Chiavi.Add(NumChiave);
                end;

                Gruppi[Chiave].Insert(0, s);
            end
            else
            begin
                Chiave := Copy(s, 1, Pos('_', s) - 1);
                if not Gruppi.ContainsKey(Chiave) then
                begin
                    Gruppi.Add(Chiave, TStringList.Create);
                    Chiavi.Add(StrToIntDef(Chiave, - 1));
                end;

                Gruppi[Chiave].Add(s);
            end;
        end;

        Chiavi.Sort;

        for i in Chiavi do
        begin
            Chiave := i.ToString;
            if Gruppi.TryGetValue(Chiave, Figli) then
                Risultato.AddStrings(Figli);
        end;

        ListDa.Assign(Risultato);
    finally
        Gruppi.Free;
        Chiavi.Free;
        Risultato.Free;
    end;
end;

procedure TfCreaRelease.TrasferisciInUnaStringList(ListDa, ListA: TStringList);
var
    i : Integer;
begin
    for i := 0 to ListDa.Count - 1 do
    begin
        ListA.Add(ExtractFileName(ListDa[i]));
    end;
end;

end.

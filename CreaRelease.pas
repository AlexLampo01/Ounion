unit CreaRelease;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls,
  Vcl.ComCtrls;

type
  TfCreaRelease = class(TForm)
    btnConferma: TBitBtn;
    pnlBottom: TPanel;
    pnlCenter: TFlowPanel;
    btnSelezionaTutto: TBitBtn;
    pbLoading: TProgressBar;
    procedure FormCreate(Sender: TObject);
    procedure btnSelezionaTuttoClick(Sender: TObject);
    procedure btnConfermaClick(Sender: TObject);
  private
    ListeTotaliReleases : TStringList;
    procedure CercaVersioniBase(ListReleases : TStringList; Percorso : String);
    procedure CercaVersioniPatch(ListDa, ListA : TStringList);
    procedure TrasferisciInUnaStringList(ListDa, ListA : TStringList);
    procedure CreaCheckBox(ListDa : TStringList; APanel: TFlowPanel);
    procedure RiordinaStringList(ListDa : TStringList);
    procedure AnalizzaCheckConStringList(ListDa : TStringList);
    procedure AnalizzaECopiaDaServer(ListDa: TStringList);
    procedure ControllaReleaseEsistenti;
    procedure DisattivaAppenafatti;
  public
    { Public declarations }
  end;

var
  fCreaRelease: TfCreaRelease;

implementation

uses
    System.IOUtils, System.Generics.Collections, System.Generics.Defaults, Math;

{$R *.dfm}

procedure TfCreaRelease.AnalizzaCheckConStringList(ListDa: TStringList);
var
    i, j, k, CountUnderscore : Integer;
    CheckBox : TCheckBox;
    Release, Versione, TestoCheckBox, TestoCheckBoxScan, CartellaCompleta : String;
    ListInPanel, CartelleComplete : TStringList;
begin
    ListInPanel := TStringList.Create;
    CartelleComplete := TStringList.Create;
    pbLoading.Max := 100;
    pbLoading.Position := 0;
    try
        pbLoading.Position := pbLoading.Position + 1;
        for i := 0 to pnlCenter.ControlCount - 1  do
        begin
            if pnlCenter.Controls[i] is TCheckBox then
            begin
               CheckBox := TCheckBox(pnlCenter.Controls[i]);
               if CheckBox.Checked = True then
                ListInPanel.Add(CheckBox.Caption);
            end;
        end;
        if ListInPanel.Count <> 0 then
        begin
            for j := 0 to ListInPanel.Count - 1 do
            begin
                TestoCheckBox := ListInPanel[j];
                CountUnderscore := 0;
                TestoCheckBoxScan := '';
                for k := 1 to Length(TestoCheckBox) do
                begin
                    if TestoCheckBox[k] = '_' then
                        CountUnderscore := CountUnderscore + 1;
                end;
                if CountUnderscore >= 2 then
                begin
                    TestoCheckBoxScan := Copy(TestoCheckBox, 5, Length(TestoCheckBox));
                end
                else
                    TestoCheckBoxScan := TestoCheckBox;

                for i := 0 to ListDa.Count - 1 do
                begin
                    Release := ListDa[i];
                    CartellaCompleta := '';
                    Versione := '';
                    if Release.Contains(';') then
                    begin
                        Versione := Copy(Release, Pos(';', Release) + 1, Length(Release));
                        CartellaCompleta := Copy(Release, 1, Pos(';', Release) - 1);
                    end
                    else
                        Versione := Release;
                    if Versione = TestoCheckBoxScan then
                        if CartellaCompleta.IsEmpty then
                            CartelleComplete.Add(Versione)
                        else
                            CartelleComplete.Add(CartellaCompleta);
                end;
            end;
            pbLoading.Max := CartelleComplete.Count + 1;
            AnalizzaECopiaDaServer(CartelleComplete);
        end
        else
            MessageDlg('Nessuna Release selezionata!', mtError, [mbOk], 0);
    finally
        CartelleComplete.Free;
        ListInPanel.Free;
    end;
end;

procedure TfCreaRelease.AnalizzaECopiaDaServer(ListDa: TStringList);
var
    i, CountUnderscore, j: Integer;
    Cartella, Percorso, PrimaParteCartella, SecondaParteCartella, PercorsoDestinazione : String;
begin
    Cartella := '';
    for i := 0 to ListDa.Count - 1 do
    begin
        Cartella := ListDa[i];
        CountUnderScore := 0;
        PrimaParteCartella := '';
        SecondaParteCartella := '';
        pbLoading.Position := pbLoading.Position + 1;
        Application.ProcessMessages;
        for j := 1 to Length(Cartella) do
        begin
            if Cartella[j] = '_' then
            begin
                CountUnderscore := CountUnderscore + 1;
            end
            else if CountUnderscore < 1 then
                PrimaParteCartella := PrimaParteCartella + Cartella[j]
            else if CountUnderscore < 2 then
                SecondaParteCartella := SecondaParteCartella + Cartella[j]
            else
                Break;
        end;
        if CountUnderscore = 1 then
        begin
            Percorso := '\\srvdb\e\OS1\OS1Svi\' + Cartella + '\' + Cartella;
            TDirectory.Copy(Percorso, 'C:\OSItalia\' + Cartella);
        end
        else if CountUnderscore > 1 then
        begin
            Percorso := '\\srvdb\e\OS1\OS1Svi\OS1_' + PrimaParteCartella + '\OS1_' + PrimaParteCartella;
            PercorsoDestinazione := 'C:\OSItalia\OS1_' + PrimaParteCartella + '_' + SecondaParteCartella;
            TDirectory.Copy(Percorso, PercorsoDestinazione);
            pbLoading.Max := pbLoading.Max + 1;
            pbLoading.Position := pbLoading.Position + 1;
            Application.ProcessMessages;
            Percorso := '\\srvdb\e\OS1\OS1Svi\OS1_' + PrimaParteCartella + '\OS1_' + PrimaParteCartella  + '_Patch\' + Cartella;
            TDirectory.Copy(Percorso, PercorsoDestinazione, True);
            pbLoading.Max := pbLoading.Max + 1;
            pbLoading.Position := pbLoading.Position + 1;
            Application.ProcessMessages;
        end;
    end;
end;

procedure TfCreaRelease.btnConfermaClick(Sender: TObject);
begin
    try
        Screen.Cursor := crHourGlass;
        AnalizzaCheckConStringList(ListeTotaliReleases);
    finally
        ControllaReleaseEsistenti;
        DisattivaAppenafatti;
        ListeTotaliReleases.Free;
        Screen.Cursor := crDefault;
    end;
end;

procedure TfCreaRelease.btnSelezionaTuttoClick(Sender: TObject);
var
    i: Integer;
    CheckBox : TCheckBox;
begin
    if btnSelezionaTutto.Caption = 'Seleziona Tutto' then
    begin
        for i := 0 to pnlCenter.ControlCount - 1  do
        begin
            if pnlCenter.Controls[i] is TCheckBox then
            begin
               CheckBox := TCheckBox(pnlCenter.Controls[i]);
               if (CheckBox.Checked = False) and (CheckBox.Enabled = True) then
                CheckBox.Checked := True;
            end;
        end;
        btnSelezionaTutto.Caption := 'Deseleziona Tutto';
        btnSelezionaTutto.Width := btnSelezionaTutto.Width + 10;
    end
    else if btnSelezionaTutto.Caption = 'Deseleziona Tutto' then
    begin
        for i := 0 to pnlCenter.ControlCount - 1  do
        begin
            if pnlCenter.Controls[i] is TCheckBox then
            begin
               CheckBox := TCheckBox(pnlCenter.Controls[i]);
               if (CheckBox.Checked = True) and (CheckBox.Enabled = True) then
                CheckBox.Checked := False;
            end;
        end;
        btnSelezionaTutto.Caption := 'Seleziona Tutto';
        btnSelezionaTutto.Width := btnSelezionaTutto.Width - 10;
    end;
end;

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

procedure TfCreaRelease.ControllaReleaseEsistenti;
var
    CheckBox : TCheckBox;
    TStringListCheckBox, ReleasesLocale : TStringList;
    i,j : Integer;
    ReleaseLocale : String;
begin
    TStringListCheckBox := TStringList.Create;
    ReleasesLocale := TStringList.Create;
    try
        CercaVersioniBase(ReleasesLocale, 'C:\OSItalia');
        for i := 0 to ReleasesLocale.Count - 1 do
        begin
            ReleaseLocale := ExtractFileName(ReleasesLocale[i]);
            for j := 0 to pnlCenter.ControlCount - 1  do
            begin
                if pnlCenter.Controls[j] is TCheckBox then
                begin
                   CheckBox := TCheckBox(pnlCenter.Controls[j]);
                   if CheckBox.Caption = ReleaseLocale then
                    CheckBox.Enabled := False;
                end;
            end;
        end;
    finally
        ReleasesLocale.Free;
        TStringListCheckBox.Free;
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

procedure TfCreaRelease.DisattivaAppenafatti;
var
    j: Integer;
    CheckBox : TCheckBox;
begin
    for j := 0 to pnlCenter.ControlCount - 1  do
    begin
        if pnlCenter.Controls[j] is TCheckBox then
        begin
            CheckBox := TCheckBox(pnlCenter.Controls[j]);
            if (not CheckBox.Enabled) and (CheckBox.Checked) then
                CheckBox.Checked := False;
        end;
    end;
end;

procedure TfCreaRelease.FormCreate(Sender: TObject);
var
    ListReleases, ListNameReleases : TStringList;
begin

    ListReleases := TStringList.Create;
    ListNameReleases := TStringList.Create;
    ListeTotaliReleases := TStringList.Create;
    try
        CercaVersioniBase(ListReleases, '\\srvdb\e\OS1\OS1Svi');
        TrasferisciInUnaStringList(ListReleases, ListNameReleases);
        CercaVersioniPatch(ListReleases, ListNameReleases);
        CreaCheckBox(ListNameReleases, pnlCenter);
        ListeTotaliReleases.Assign(ListNameReleases);
        ControllaReleaseEsistenti;
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

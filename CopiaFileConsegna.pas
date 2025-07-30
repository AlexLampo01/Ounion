unit CopiaFileConsegna;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls,
  Vcl.Buttons, Vcl.Grids, System.ImageList, Vcl.ImgList, System.IOUtils,
  Vcl.Menus;

type
  PListBoxItemData = ^TListBoxItemData;
  TListBoxItemData = record
    LeftIconIndex: Integer;
    RightIconIndex: Integer;
  end;

type
  TfCopiaFileConsegna = class(TForm)
    Panel1: TPanel;
    pbLoading: TProgressBar;
    pnlConferma: TPanel;
    Panel3: TPanel;
    pnlSelezionaTutto: TPanel;
    pnlDeselezionaTutto: TPanel;
    btnConferma: TBitBtn;
    pPercorso: TPanel;
    lblPercorso: TLabel;
    btnEsploraRisorse: TBitBtn;
    fodEsploraRisorse: TFileOpenDialog;
    cbBranch: TComboBox;
    btnAnalizzatore: TBitBtn;
    btnRestart: TBitBtn;
    Panel2: TPanel;
    btnDeselezionaTutto: TBitBtn;
    pnlButtons: TPanel;
    btnSelezionaTutto: TBitBtn;
    Splitter1: TSplitter;
    lbFile: TListBox;
    lbFileConfermati: TListBox;
    imgListStatoFile: TImageList;
    pbFile: TProgressBar;
    imgListSpostabileAuto: TImageList;
    popMDoppioClick: TPopupMenu;
    SpostaiSelezionati: TMenuItem;
    procedure btnEsploraRisorseClick(Sender: TObject);
    procedure cbBranchEnter(Sender: TObject);
    procedure btnAnalizzatoreClick(Sender: TObject);
    procedure btnSelezionaTuttoClick(Sender: TObject);
    procedure btnDeselezionaTuttoClick(Sender: TObject);
    procedure btnConfermaClick(Sender: TObject);
    procedure btnRestartClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnEsploraRisorseEnter(Sender: TObject);
    procedure btnAnalizzatoreEnter(Sender: TObject);
    procedure btnDeselezionaTuttoEnter(Sender: TObject);
    procedure btnRestartEnter(Sender: TObject);
    procedure btnConfermaEnter(Sender: TObject);
    procedure lbFileDrawItem(Control: TWinControl; Index: Integer; Rect: TRect;
      State: TOwnerDrawState);
    procedure pnlSelezionaTuttoResize(Sender: TObject);
    procedure pnlSelezionaTuttoCanResize(Sender: TObject; var NewWidth,
      NewHeight: Integer; var Resize: Boolean);
    procedure lbFileConfermatiDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure pbFileChange(Sender: TObject);
    procedure lbFileDblClick(Sender: TObject);
    procedure lbFileConfermatiDblClick(Sender: TObject);
    procedure lbMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure popMDoppioClickPopup(Sender: TObject);
    procedure SpostaiSelezionatiClick(Sender: TObject);
    procedure lbFileConfermatiKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure lbFileKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    function RecuperaRemote(Percorso: String): TStringList;
    function RecuperaBranch(Percorso: String): TStringList;
    function AnalizzaBranch: TStringList;
    procedure RiempiDatiInsgFile(FileDaSpostare: TStringList);
    procedure CercaFileRicorsivo(const Percorso, FileDaCercare: String;
      var Trovato: String);
    procedure SpostaElementiListBox(ListBoxOrigine, ListBoxDestinazione : TListBox; FileDaSpostare, FileDaNonSpostare : TStringList);
    procedure ControllaSelezionati(ListBox: TListBox);
    function MaxValuePixel(AListBox : TListBox) : Integer;

  public
    Completato : Boolean;
    CartellaScelta : String;
    procedure ProgressBarAnimation;
  end;

var
  fCopiaFileConsegna: TfCopiaFileConsegna;

implementation

{$R *.dfm}

procedure TfCopiaFileConsegna.btnAnalizzatoreClick(Sender: TObject);
var
    FileListTemp, FileList : TStringList;
    i: Integer;
begin
   pbLoading.Visible := True;
   pbLoading.Position := 0;
   FileListTemp := TStringList.Create;
   FileList := TStringList.Create;
   try
    FileListTemp := AnalizzaBranch;
    for i := 0 to FileListTemp.Count - 1 do
    begin
        if FileList.IndexOf(FileListTemp[i]) = - 1 then
            FileList.Add(FileListTemp[i]);
    end;
    RiempiDatiInsgFile(FileList);
   finally
    FileList.Free;
    FileListTemp.Free;
   end;
end;

procedure TfCopiaFileConsegna.btnAnalizzatoreEnter(Sender: TObject);
begin
    btnAnalizzatore.ShowHint := True;
end;

procedure TfCopiaFileConsegna.btnConfermaClick(Sender: TObject);
var
    CartellaSalvataggio, PercorsoRicerca, Risultato, FileDaCercare  : String;

    TStringPercorsoCompleto : TStringList;
    i, j, PosNomeFile, NumBackSlash: Integer;
    CartelleDaAggiungere, CartelleDefinitive : String;
    InizioCartelle : Boolean;
begin
    if fodEsploraRisorse.Execute then
      CartellaSalvataggio := fodEsploraRisorse.FileName;
    if CartellaSalvataggio <> '' then
    begin
        TStringPercorsoCompleto := TStringList.Create;
        try
            PercorsoRicerca := IncludeTrailingPathDelimiter(lblPercorso.Caption);
            for i := 0 to lbFileConfermati.Count - 1 do
            begin
                FileDaCercare:= lbFileConfermati.Items[i];
                CercaFileRicorsivo(PercorsoRicerca, FileDaCercare, Risultato);
                if Risultato <> '' then
                    TStringPercorsoCompleto.Add(Risultato);
            end;

            for i := 0 to TStringPercorsoCompleto.Count - 1 do
            begin
                var PercorsoSorgente := TStringPercorsoCompleto[i];
                if TFile.Exists(PercorsoSorgente) then
                begin
                    var NomeFile := ExtractFileName(PercorsoSorgente);
                    CartelleDaAggiungere := '';
                    InizioCartelle := False;
                    NumBackSlash := 0;
                    CartelleDefinitive := '';
                    PosNomeFile := Pos(NomeFile, PercorsoSorgente);
                    if PosNomeFile > 0 then
                    begin
                        CartelleDaAggiungere := Copy(PercorsoSorgente, 1, PosNomeFile - 1);
                    end;
                    if CartelleDaAggiungere <> '' then
                    begin
                        for j := 1 to Length(CartelleDaAggiungere) do
                        begin
                            if (CartelleDaAggiungere[j] = '\') and not InizioCartelle then
                            begin
                                NumBackSlash := NumBackSlash + 1;
                            end;
                            if NumBackSlash = 5 then
                            begin
                                CartelleDefinitive := CartelleDefinitive + CartelleDaAggiungere[j];
                                InizioCartelle := True;
                            end;
                        end;
                        if not DirectoryExists(CartellaSalvataggio + CartelleDefinitive) then
                            ForceDirectories(CartellaSalvataggio + CartelleDefinitive);
                    end;

                    var PercorsoDestinazione := CartellaSalvataggio + CartelleDefinitive + NomeFile;

                    TFile.Copy(PercorsoSorgente, PercorsoDestinazione, True);
                end
            end;
            ShowMessage('Copia del file completata con successo!');
        finally
            TStringPercorsoCompleto.Free;
        end;
    end
    else
        ShowMessage('Seleziona una cartella!');
end;

procedure TfCopiaFileConsegna.btnConfermaEnter(Sender: TObject);
begin
    btnConferma.ShowHint := True;
end;

procedure TfCopiaFileConsegna.btnDeselezionaTuttoClick(Sender: TObject);
var
    i: Integer;
    FileConEliminazione, FileDaNonSpostare: TStringList;
begin
    FileConEliminazione := TStringList.Create;
    FileDaNonSpostare := TStringList.Create;
    try
        for i := 0 to lbFileConfermati.Count - 1 do
        begin
            FileConEliminazione.Add(lbFileConfermati.Items[i])
        end;
        SpostaElementiListBox(lbFileConfermati ,lbFile, FileConEliminazione, FileDaNonSpostare);
        btnDeselezionaTutto.Enabled := False;
        btnSelezionaTutto.Enabled   := True;
    finally
     FileConEliminazione.Free;
     FileDaNonSpostare.Free;
    end;
end;

procedure TfCopiaFileConsegna.btnDeselezionaTuttoEnter(Sender: TObject);
begin
    btnDeselezionaTutto.ShowHint := True;
end;

procedure TfCopiaFileConsegna.btnEsploraRisorseClick(Sender: TObject);
var
    CartellaConGit : String;
    PresenteGit : Boolean;
begin
    Completato := False;
    CartellaScelta := '';
    if fodEsploraRisorse.Execute then
      CartellaScelta := fodEsploraRisorse.FileName;
    if CartellaScelta <> '' then
    begin
        if not btnAnalizzatore.Visible then
        begin
            lblPercorso.Caption := CartellaScelta;
            CartellaConGit := CartellaScelta + '\.git';
            if DirectoryExists(CartellaConGit) then
                PresenteGit := True
            else
                PresenteGit := False;
            if PresenteGit then
            begin
                ProgressBarAnimation;
                if Completato then
                begin
                    pbLoading.Visible       := False;
                    btnAnalizzatore.Visible := True;
                    cbBranch.Visible        := True;
                end;
            end
            else
                ShowMessage('La cartella selezionata non è una repository git!');
        end;
    end;
end;

procedure TfCopiaFileConsegna.btnEsploraRisorseEnter(Sender: TObject);
begin
    btnEsploraRisorse.ShowHint := True;
end;

procedure TfCopiaFileConsegna.btnRestartClick(Sender: TObject);
begin
    cbBranch.Visible := False;
    cbBranch.Enabled := True;
    pnlDeselezionaTutto.Visible := False;
    pnlSelezionaTutto.Visible := False;
    btnSelezionaTutto.Enabled := False;
    cbbranch.Text := '';
    btnAnalizzatore.Enabled := True;
    btnAnalizzatore.Visible := False;
    btnEsploraRisorse.Visible := True;
    lbFile.Clear;
    lbFileConfermati.Clear;
    pnlButtons.Visible := False;
    pnlConferma.Visible := False;
    btnEsploraRisorse.Enabled := True;
    lblPercorso.Caption := '';
    cbBranch.Items.Clear;
end;

procedure TfCopiaFileConsegna.btnRestartEnter(Sender: TObject);
begin
    btnRestart.Hint := 'Restart';
    btnRestart.ShowHint := True;
end;

procedure TfCopiaFileConsegna.btnSelezionaTuttoClick(Sender: TObject);
var
    i : Integer;
    FileConEliminazione, FileDaNonSpostare: TStringList;
    Estensione : String;
begin
    FileConEliminazione := TStringList.Create;
    FileDaNonSpostare := TStringList.Create;
    try
        for i := 0 to lbFile.Count - 1 do
        begin
            Estensione := lbFile.Items[i];
            if not SameText(ExtractFileExt(Trim(Estensione)), '.pas')
            and not SameText(ExtractFileExt(Trim(Estensione)), '.dfm')
            and not SameText(ExtractFileExt(Trim(Estensione)), '.dpr')
            and not SameText(ExtractFileExt(Trim(Estensione)), '.dpk')
            and not SameText(ExtractFileExt(Trim(Estensione)), '.dproj')
            and not SameText(ExtractFileExt(Trim(Estensione)), '.gitignore')
            and not SameText(ExtractFileExt(Trim(Estensione)), '.stat')
            and not Trim(LowerCase(Estensione)).StartsWith('os1test')
            and not SameText(Estensione, '')
            then
                FileConEliminazione.Add( lbFile.Items[i])
            else
                FileDaNonSpostare.Add( lbFile.Items[i])
        end;
        SpostaElementiListBox(lbFile,lbFileConfermati, FileConEliminazione, FileDaNonSpostare);
        btnDeselezionaTutto.Enabled := True;
        btnSelezionaTutto.Enabled   := False;
    finally
     FileConEliminazione.Free;
    end;
end;

procedure TfCopiaFileConsegna.cbBranchEnter(Sender: TObject);
var
    TStringRemote, TStringBranch, TStringDef : TStringList;
begin
    TStringRemote := TStringList.Create;
    TStringBranch := TStringList.Create;
    TStringDef    := TStringList.Create;
    try
        TStringRemote := RecuperaRemote(CartellaScelta);
        TStringBranch := RecuperaBranch(CartellaScelta);
        TStringDef.AddStrings(TStringBranch);
        TStringDef.AddStrings(TStringRemote);
        cbBranch.Items := TStringDef;
    finally
        TStringDef.Free;
        TStringBranch.Free;
        TStringRemote.Free;
    end;

end;

procedure TfCopiaFileConsegna.ProgressBarAnimation;
var
    i: Integer;
begin
    pbLoading.Visible := True;
    pbLoading.Min := 0;
    pbLoading.Max := 100;
    pbLoading.Position := 0;

    for i := 1 to 100 do
    begin
        pbLoading.Position := i;
        Sleep(25);
        Application.ProcessMessages;
        if pbLoading.Position = 100 then
        begin
            Completato := True;
            Exit;
        end;
    end;
end;

function TfCopiaFileConsegna.RecuperaRemote(Percorso: String): TStringList;
var
    SA: TSecurityAttributes;
    ReadPipe, WritePipe: THandle;
    SI: TStartupInfo;
    PI: TProcessInformation;
    Buffer: array[0..2047] of AnsiChar;
    BytesRead: DWORD;
    Output: TStringStream;
    BranchList: TStringList;
    CommandLine, Line: String;
    i: Integer;
begin
    BranchList := TStringList.Create;
    OutPut := TStringStream.Create('');
    try
        SA.nLength := SizeOf(SA);
        SA.bInheritHandle := True;
        SA.lpSecurityDescriptor := nil;

        if not CreatePipe(ReadPipe, WritePipe, @SA, 0) then
            RaiseLastOSError;

        try
            ZeroMemory(@SI, SizeOf(SI));
            SI.cb := SizeOf(SI);
            SI.hStdOutput := WritePipe;
            SI.hStdError := WritePipe;
            SI.dwFlags := STARTF_USESTDHANDLES;

            ZeroMemory(@PI, SizeOf(PI));

            CommandLine := 'git branch -r"';

            if not CreateProcess(nil, PChar('cmd.exe /C ' + CommandLine), nil, nil, True, CREATE_NO_WINDOW, nil, PChar(Percorso), SI, PI) then
                RaiseLastOSError;

            CloseHandle(WritePipe);

            repeat
                BytesRead := 0;
                if ReadFile(ReadPipe, Buffer, SizeOf(Buffer), BytesRead, nil) and (BytesRead > 0) then
                    Output.Write(Buffer, BytesRead);
            until BytesRead = 0 ;

            WaitForSingleObject(PI.hProcess, INFINITE);
            CloseHandle(PI.hProcess);
            CloseHandle(PI.hThread);
        finally
            CloseHandle(ReadPipe);
        end;

        Output.Position := 0;
        BranchList.Text := Output.DataString;
        for i := BranchList.Count - 1 downto 0 do
        begin
            Line := Trim(BranchList[i]);
            if (Line = '') or (Line.StartsWith('origin/HEAD')) then
                BranchList.Delete(i)
            else
                BranchList[i] := Line;
        end;

        Result := BranchList;
    finally
        Output.Free;
    end;
end;

function TfCopiaFileConsegna.RecuperaBranch(Percorso: String): TStringList;
var
    SA: TSecurityAttributes;
    ReadPipe, WritePipe: THandle;
    SI: TStartupInfo;
    PI: TProcessInformation;
    Buffer: array[0..2047] of AnsiChar;
    BytesRead: DWORD;
    Output: TStringStream;
    BranchList: TStringList;
    CommandLine, Line: String;
    i: Integer;
begin
    BranchList := TStringList.Create;
    OutPut := TStringStream.Create('');
    try
        SA.nLength := SizeOf(SA);
        SA.bInheritHandle := True;
        SA.lpSecurityDescriptor := nil;

        if not CreatePipe(ReadPipe, WritePipe, @SA, 0) then
            RaiseLastOSError;

        try
            ZeroMemory(@SI, SizeOf(SI));
            SI.cb := SizeOf(SI);
            SI.hStdOutput := WritePipe;
            SI.hStdError := WritePipe;
            SI.dwFlags := STARTF_USESTDHANDLES;

            ZeroMemory(@PI, SizeOf(PI));

            CommandLine := 'git branch --format="%(refname:short)"';

            if not CreateProcess(nil, PChar('cmd.exe /C ' + CommandLine), nil, nil, True, CREATE_NO_WINDOW, nil, PChar(Percorso), SI, PI) then
                RaiseLastOSError;

            CloseHandle(WritePipe);

            repeat
                BytesRead := 0;
                if ReadFile(ReadPipe, Buffer, SizeOf(Buffer), BytesRead, nil) and (BytesRead > 0) then
                    Output.Write(Buffer, BytesRead);
            until BytesRead = 0 ;

            WaitForSingleObject(PI.hProcess, INFINITE);
            CloseHandle(PI.hProcess);
            CloseHandle(PI.hThread);
        finally
            CloseHandle(ReadPipe);
        end;

        Output.Position := 0;
        BranchList.Text := Output.DataString;
        for i := BranchList.Count - 1 downto 0 do
        begin
            Line := Trim(BranchList[i]);
            if Line = '' then
                BranchList.Delete(i)
            else
                BranchList[i] := Line;
        end;

        Result := BranchList;
    finally
        Output.Free;
    end;
end;

function TfCopiaFileConsegna.AnalizzaBranch : TStringList;
var
  CommitList, FileList: TStringList;
  SA: TSecurityAttributes;
  ReadPipe, WritePipe: THandle;
  SI: TStartupInfo;
  PI: TProcessInformation;
  Buffer: array[0..2047] of AnsiChar;
  BytesRead: DWORD;
  Stream: TStringStream;
  I: Integer;
  Command, Percorso, Commit: string;

  function RunGitCommand(const GitArgs: string): string;
  var
    LocalStream: TStringStream;
  begin
    LocalStream := TStringStream.Create('');
    Percorso := CartellaScelta;
    try
      if not CreatePipe(ReadPipe, WritePipe, @SA, 0) then
        RaiseLastOSError;

      try
        ZeroMemory(@SI, SizeOf(SI));
        SI.cb := SizeOf(SI);
        SI.dwFlags := STARTF_USESTDHANDLES;
        SI.hStdOutput := WritePipe;
        SI.hStdError := WritePipe;

        ZeroMemory(@PI, SizeOf(PI));

        if not CreateProcess(nil, PChar('cmd.exe /C git ' + GitArgs),
            nil, nil, True, CREATE_NO_WINDOW, nil, PChar(Percorso), SI, PI) then
          RaiseLastOSError;

        CloseHandle(WritePipe);

        repeat
          BytesRead := 0;
          if ReadFile(ReadPipe, Buffer, SizeOf(Buffer), BytesRead, nil) and (BytesRead > 0) then
            LocalStream.Write(Buffer, BytesRead);
        until BytesRead = 0;

        WaitForSingleObject(PI.hProcess, INFINITE);
        CloseHandle(PI.hProcess);
        CloseHandle(PI.hThread);
      finally
        CloseHandle(ReadPipe);
      end;

      LocalStream.Position := 0;
      Result := LocalStream.DataString;
    finally
      LocalStream.Free;
    end;
  end;

begin
  CommitList := TStringList.Create;
  FileList := TStringList.Create;
  Stream := TStringStream.Create('');
  try
    // Setup sicurezza pipe
    SA.nLength := SizeOf(SA);
    SA.bInheritHandle := True;
    SA.lpSecurityDescriptor := nil;

    // Ottieni lista commit del branch

    CommitList.Text   := RunGitCommand('log ' + cbBranch.Text + ' ^^master --pretty=format:"%H"');
    pbLoading.Max := CommitList.Count;
    // Per ogni commit, estrai i file modificati
    for I := 0 to CommitList.Count - 1 do
    begin
      Sleep(25);

      Command := Format('diff-tree --no-commit-id --name-status --diff-filter=AM -r %s', [CommitList[I]]);
      FileList.Text := FileList.Text + RunGitCommand(Command);
      Application.ProcessMessages;
      pbLoading.Position := pbLoading.Position + i;
    end;

    // Rimuove righe vuote e normalizza
    for I := FileList.Count - 1 downto 0 do
      if Trim(FileList[I]) = '' then
        FileList.Delete(I)
      else
        FileList[I] := Trim(FileList[I]);
    pbLoading.Visible := False;
    pnlButtons.Visible := True;
    pnlConferma.Visible := True;
    pnlSelezionaTutto.Visible := True;
    pnlDeselezionaTutto.Visible := True;
    btnConferma.Visible := True;
    btnAnalizzatore.Enabled := False;
    cbBranch.Enabled := False;
    btnEsploraRisorse.Enabled := False;
    btnDeselezionaTutto.Enabled := False;
    btnRestart.Visible := True;
    Result := FileList;
  finally
    Stream.Free;
    CommitList.Free;
    // non liberare FileList, viene restituita come Result
  end;
end;

procedure TfCopiaFileConsegna.RiempiDatiInsgFile(FileDaSpostare: TStringList);
var
    i: Integer;
    Immagini: PListBoxItemData;
begin
    pbFile.Visible := True;
    pbFile.Position := 0;
    pbFile.Max := FileDaSpostare.Count;

    for i := 0 to FileDaSpostare.Count - 1 do
    begin
        New(Immagini);
        if Trim(LowerCase(FileDaSpostare[i])).StartsWith('m') then
        begin
            Immagini^.LeftIconIndex := 0;
        end
        else if Trim(LowerCase(FileDaSpostare[i])).StartsWith('a') then
        begin
            Immagini^.LeftIconIndex := 1;

        end;
        if (ExtractFileExt(FileDaSpostare[i]) = '.pas')
        or (ExtractFileExt(FileDaSpostare[i]) = '.dfm')
        or (ExtractFileExt(FileDaSpostare[i]) = '.dpr')
        or (ExtractFileExt(FileDaSpostare[i]) = '.dpk')
        or (ExtractFileExt(FileDaSpostare[i]) = '.gitignore')
        or (ExtractFileExt(FileDaSpostare[i]) = '.dproj')
        or (ExtractFileExt(FileDaSpostare[i]) = '.stat')
        or (Copy(Trim(LowerCase(FileDaSpostare[i])), 3, Length(Trim(LowerCase(FileDaSpostare[i]))))).StartsWith('os1test') then
        begin
           Immagini^.RightIconIndex := 0;
        end
        else
        begin
           Immagini^.RightIconIndex := 1;
        end;

        lbFile.Items.AddObject(Copy(FileDaSpostare[i], 2, Length(FileDaSpostare[i])), TObject(Immagini));
        pbFile.Position := pbFile.Position + 1;
        Application.ProcessMessages;
        Sleep(300);
        if pbFile.Position = pbFile.Max then
        begin
            pbFile.Position := 0;
            pbFile.Visible := False;
        end;
    end;
end;

procedure TfCopiaFileConsegna.SpostaElementiListBox(ListBoxOrigine,
  ListBoxDestinazione: TListBox ; FileDaSpostare, FileDaNonSpostare : TStringList);
var
    ImmaginiSrc, ImmaginiDst: PListBoxItemData;
    i,j, Indice : Integer;
    NomeFile : String;
    Vuoto : Boolean;
begin
    Vuoto := True;
    for i := 0 to ListBoxOrigine.Items.Count - 1 do
    begin
        for j := 0 to FileDaNonSpostare.Count - 1 do
        begin
            if Trim(FileDaNonSpostare[j]) <> '' then
                Vuoto := False;
        end;
        for j := 0 to FileDaSpostare.Count - 1 do
        begin
            if Vuoto or (Not FileDaSpostare[j].StartsWith('#')) then
                NomeFile := FileDaSpostare[j]
            else
                NomeFile := Copy(FileDaSpostare[j], 2, Length(FileDaSpostare[j]));
            Indice := ListBoxOrigine.Items.IndexOf(FileDaSpostare[j]);
            if Indice <> - 1 then
            begin
                if FileDaNonSpostare.IndexOf(FileDaSpostare[j]) = - 1 then
                begin
                    ImmaginiSrc := PListBoxItemData(ListBoxOrigine.Items.Objects[Indice]);

                    New(ImmaginiDst);
                    ImmaginiDst^.LeftIconIndex := ImmaginiSrc^.LeftIconIndex;
                    ImmaginiDst^.RightIconIndex := ImmaginiSrc^.RightIconIndex;
                    if ListBoxDestinazione.Count = 0 then
                    begin
                        ListBoxDestinazione.Items.InsertObject(0, NomeFile, TObject(ImmaginiDst));
                    end
                    else
                    begin
                        if not (ListBoxDestinazione.Items[0] = NomeFile) then
                                ListBoxDestinazione.Items.InsertObject(0, NomeFile, TObject(ImmaginiDst))
                    end;

                    ListBoxOrigine.Items.Objects[Indice] := nil;
                    ListBoxOrigine.Items.Delete(Indice);
                end;
            end;
        end;
    end;
end;

procedure TfCopiaFileConsegna.SpostaiSelezionatiClick(Sender: TObject);
var
    ListBox,ListBoxDestinazione : TListBox;
    ElementiMultipliSelect, ElementiMultipliNonSelect : TStringList;
    i : Integer;
begin
    ElementiMultipliSelect := TStringList.Create;
    ElementiMultipliNonSelect := TStringList.Create;
    try
        ListBox := nil;
        ListBoxDestinazione := nil;
        if (popMDoppioClick.PopupComponent is TListBox) then
        begin
            ListBox := TListBox(popMDoppioClick.PopupComponent);
            for i := 0 to ListBox.Items.Count - 1 do
            begin
                if ListBox.Selected[i] then
                    ElementiMultipliSelect.Add(ListBox.Items[i])
                else
                    ElementiMultipliNonSelect.Add(ListBox.Items[i])
            end;
        end;
        if ListBox.Name = 'lbFile' then
        begin
            ListBoxDestinazione := lbFileConfermati;
        end
        else if ListBox.Name = 'lbFileConfermati' then
        begin
            ListBoxDestinazione := lbFile;
        end;
        if ElementiMultipliSelect.Count <> 0 then
            SpostaElementiListBox(ListBox, ListBoxDestinazione, ElementiMultipliSelect, ElementiMultipliNonSelect);
    finally
        ElementiMultipliNonSelect.Free;
        ElementiMultipliSelect.Free;
    end;
end;

procedure TfCopiaFileConsegna.CercaFileRicorsivo(const Percorso, FileDaCercare : String; var Trovato: String);
var
    CostruzionePercorso: String;
begin
    CostruzionePercorso := IncludeTrailingPathDelimiter(Trim(Percorso)) + Trim(FileDaCercare);
    CostruzionePercorso := StringReplace(CostruzionePercorso, '/', '\', [rfReplaceAll]);
    Trovato := CostruzionePercorso;
end;

procedure TfCopiaFileConsegna.ControllaSelezionati(ListBox: TListBox);
var
   ElementiMultipliSelect, ElementiMultipliNonSelect : TStringList;
   ListBoxDestinazione : TListBox;
   i: Integer;
begin
    ElementiMultipliSelect := TStringList.Create;
    ElementiMultipliNonSelect := TStringList.Create;
    try
        ListBoxDestinazione := nil;
        for i := 0 to ListBox.Items.Count - 1 do
        begin
            if ListBox.Selected[i] then
                ElementiMultipliSelect.Add(ListBox.Items[i])
            else
                ElementiMultipliNonSelect.Add(ListBox.Items[i])
        end;

        if ListBox.Name = 'lbFile' then
        begin
            ListBoxDestinazione := lbFileConfermati;
        end
        else if ListBox.Name = 'lbFileConfermati' then
        begin
            ListBoxDestinazione := lbFile;
        end;
        if ElementiMultipliSelect.Count <> 0 then
            SpostaElementiListBox(ListBox, ListBoxDestinazione, ElementiMultipliSelect, ElementiMultipliNonSelect);
    finally
        ElementiMultipliNonSelect.Free;
        ElementiMultipliSelect.Free;
    end;
end;

procedure TfCopiaFileConsegna.FormCreate(Sender: TObject);
begin
    ShowHint := True;
end;

procedure TfCopiaFileConsegna.lbFileConfermatiDblClick(Sender: TObject);
var
    Indice, i : Integer;
    FileDaSpostare, FileDaNonSpostare : TStringList;
begin
    FileDaSpostare := TStringList.Create;
    FileDaNonSpostare := TStringList.Create;
    try
        Indice := lbFileConfermati.ItemIndex;
        if Indice >= 0 then
        begin
            for i := 0 to lbFileConfermati.Count - 1 do
            begin
                if i = Indice then
                begin
                    FileDaSpostare.Add(lbFileConfermati.Items[Indice]);
                end
                else if i <> Indice then
                begin
                    FileDaNonSpostare.Add(lbFileConfermati.Items[i]);
                end;
            end;
        end;
        SpostaElementiListBox(lbFileConfermati, lbFile, FileDaSpostare, FileDaNonSpostare );
    finally
        FileDaNonSpostare.Free;
        FileDaSpostare.Free;
    end;
end;

procedure TfCopiaFileConsegna.lbFileConfermatiDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  IconTopLeft, IconTopRight: Integer;
  TextLeft: Integer;
  Immagini : PListBoxItemData;
  S: string;
begin
  with lbFileConfermati do
  begin
    Canvas.FillRect(Rect);
    Immagini := PListBoxItemData(lbFileConfermati.Items.Objects[Index]);

    IconTopLeft := Rect.Top + (Rect.Height - ImgListStatoFile.Height) div 2;
    IconTopRight := Rect.Top + (Rect.Height - imgListSpostabileAuto.Height) div 2;
    if Assigned(Immagini) and (Immagini^.LeftIconIndex >= 0) then
    begin
        ImgListStatoFile.Draw(Canvas, Rect.Left + 4, IconTopLeft, Immagini^.LeftIconIndex);
        TextLeft := Rect.Left + ImgListStatoFile.Width + 8;
    end
    else
        TextLeft := Rect.Left + 4;
    // Scrive il testo accanto all'icona
    S := lbFileConfermati.Items[Index];
    Canvas.TextOut(TextLeft, Rect.Top, S);


    if Assigned(Immagini) and (Immagini^.RightIconIndex >= 0) then
    begin
        imgListSpostabileAuto.Draw(Canvas, Rect.Right - imgListSpostabileAuto.Width, IconTopRight, Immagini^.RightIconIndex);
    end;
  end;
end;

procedure TfCopiaFileConsegna.lbFileConfermatiKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
    if (ssCtrl in Shift) then
    begin
        case Key of
            VK_LEFT: ControllaSelezionati(lbFileConfermati);
        end;
    end;
end;

procedure TfCopiaFileConsegna.lbMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
    ListBox : TListBox;
begin
    if Button = mbRight then
    begin
        if Sender is TListBox then
        begin
            ListBox := TListBox(Sender);
            ListBox.PopupMenu := popMDoppioClick;
            popMDoppioClick.PopupComponent := TListBox(Sender);
            popMDoppioClick.Popup(Mouse.CursorPos.X, Mouse.CursorPos.Y);
        end;
    end;
end;

procedure TfCopiaFileConsegna.lbFileDblClick(Sender: TObject);
var
    Indice, i : Integer;
    FileDaSpostare, FileDaNonSpostare : TStringList;
begin
    FileDaSpostare := TStringList.Create;
    FileDaNonSpostare := TStringList.Create;
    try
        Indice := lbFile.ItemIndex;
        if Indice >= 0 then
        begin
            for i := 0 to lbFile.Count - 1 do
            begin
                if i = Indice then
                begin
                    FileDaSpostare.Add(lbFile.Items[Indice]);
                end
                else if i <> Indice then
                begin
                    FileDaNonSpostare.Add(lbFile.Items[i]);
                end;
            end;
        end;
        SpostaElementiListBox(lbFile, lbFileConfermati, FileDaSpostare, FileDaNonSpostare );
    finally
        FileDaNonSpostare.Free;
        FileDaSpostare.Free;
    end;
end;

procedure TfCopiaFileConsegna.lbFileDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  IconTopLeft, IconTopRight: Integer;
  TextLeft: Integer;
  Immagini : PListBoxItemData;
  S: string;
begin
  with lbFile do
  begin
    Canvas.FillRect(Rect);
    Immagini := PListBoxItemData(lbFile.Items.Objects[Index]);

    IconTopLeft := Rect.Top + (Rect.Height - ImgListStatoFile.Height) div 2;
    IconTopRight := Rect.Top + (Rect.Height - imgListSpostabileAuto.Height) div 2;
    if Assigned(Immagini) and (Immagini^.LeftIconIndex >= 0) then
    begin
        ImgListStatoFile.Draw(Canvas, Rect.Left + 4, IconTopLeft, Immagini^.LeftIconIndex);
        TextLeft := Rect.Left + ImgListStatoFile.Width + 8;
    end
    else
        TextLeft := Rect.Left + 4;
    // Scrive il testo accanto all'icona
    S := lbFile.Items[Index];
    Canvas.TextOut(TextLeft, Rect.Top, S);


    if Assigned(Immagini) and (Immagini^.RightIconIndex >= 0) then
    begin
        imgListSpostabileAuto.Draw(Canvas, Rect.Right - imgListSpostabileAuto.Width, IconTopRight, Immagini^.RightIconIndex);
    end;
  end;
end;

procedure TfCopiaFileConsegna.lbFileKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
    if (ssCtrl in Shift) then
    begin
        case Key of
            VK_RIGHT: ControllaSelezionati(lbFile);
        end;
    end;
end;

function TfCopiaFileConsegna.MaxValuePixel(AListBox: TListBox): Integer;
var
    i, ItemWidth: Integer;
begin
    Result := 0;
    for i := 0 to AListBox.Items.Count - 1 do
    begin
        ItemWidth := AListBox.Canvas.TextWidth(AListBox.Items[i]);
        if ItemWidth > Result then
            Result := ItemWidth;
    end;
end;

procedure TfCopiaFileConsegna.pbFileChange(Sender: TObject);
begin
    if pbFile.Position = pbFile.Max then
    begin
        btnSelezionaTutto.Enabled := True;
    end;
end;

procedure TfCopiaFileConsegna.pnlSelezionaTuttoCanResize(Sender: TObject;
  var NewWidth, NewHeight: Integer; var Resize: Boolean);
var
    MinWidth: Integer;
begin
    MinWidth := MaxValuePixel(lbFile) + 40;

    if NewWidth < MinWidth then
    begin
        NewWidth := MinWidth;
        Resize := False;
    end;
end;

procedure TfCopiaFileConsegna.pnlSelezionaTuttoResize(Sender: TObject);
begin
    lbFile.Invalidate;
end;

procedure TfCopiaFileConsegna.popMDoppioClickPopup(Sender: TObject);
var
    ListBox, ListBoxDestinazione : TListBox;
    i,CounterElementi : Integer;
begin
    {
    var
        i: Integer;
    begin
      for i := 0 to ListBox1.Items.Count - 1 do
      begin
        if ListBox1.Selected[i] then
          ShowMessage('Selezionato: ' + ListBox1.Items[i]);
      end;
    end;
    }
    ListBox := nil;
    ListBoxDestinazione := nil;
    CounterElementi := 0;
    if (popMDoppioClick.PopupComponent is TListBox) then
    begin
        ListBox := TListBox(popMDoppioClick.PopupComponent);
        for i := 0 to ListBox.Items.Count - 1 do
        begin
            if ListBox.Selected[i] then
                CounterElementi := CounterElementi + 1;
        end;
    end;
    if CounterElementi = 0 then
        SpostaiSelezionati.Enabled := False
    else if CounterElementi > 0 then
        SpostaiSelezionati.Enabled := True;


end;

end.

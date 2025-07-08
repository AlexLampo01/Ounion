unit CopiaFileConsegna;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls,
  Vcl.Buttons, Vcl.Grids, System.ImageList, Vcl.ImgList, System.IOUtils;

type
  TfCopiaFileConsegna = class(TForm)
    Panel1: TPanel;
    pbLoading: TProgressBar;
    pnlConferma: TPanel;
    Panel3: TPanel;
    pnlButtons: TPanel;
    pnlSelezionaTutto: TPanel;
    pnlDeselezionaTutto: TPanel;
    sgFile: TStringGrid;
    sgFileConfermati: TStringGrid;
    btnSelezionaTutto: TBitBtn;
    btnDeselezionaTutto: TBitBtn;
    btnConferma: TBitBtn;
    pPercorso: TPanel;
    lblPercorso: TLabel;
    btnEsploraRisorse: TBitBtn;
    fodEsploraRisorse: TFileOpenDialog;
    cbBranch: TComboBox;
    btnAnalizzatore: TBitBtn;
    btnRestart: TBitBtn;
    procedure btnEsploraRisorseClick(Sender: TObject);
    procedure cbBranchEnter(Sender: TObject);
    procedure btnAnalizzatoreClick(Sender: TObject);
    procedure btnSelezionaTuttoClick(Sender: TObject);
    procedure btnDeselezionaTuttoClick(Sender: TObject);
    procedure sgFileDblClick(Sender: TObject);
    procedure sgFileConfermatiDblClick(Sender: TObject);
    procedure btnConfermaClick(Sender: TObject);
    procedure btnRestartClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnEsploraRisorseEnter(Sender: TObject);
    procedure btnAnalizzatoreEnter(Sender: TObject);
    procedure btnSelezionaTuttoEnter(Sender: TObject);
    procedure btnDeselezionaTuttoEnter(Sender: TObject);
    procedure btnRestartEnter(Sender: TObject);
    procedure btnConfermaEnter(Sender: TObject);
  private
    function RecuperaRemote(Percorso: String): TStringList;
    function RecuperaBranch(Percorso: String): TStringList;
    function AnalizzaBranch: TStringList;
    procedure RiempiDatiInsgFile(FileDaSpostare: TStringList);
    procedure RiadattaLarghezzaRighe(TStringGridUsata: TStringGrid);
    procedure CercaFileRicorsivo(const Percorso, FileDaCercare: String;
      var Trovato: String);

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
    //btnAnalizzatore.Hint := 'Seleziona Branch';
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
    if sgFileConfermati.Cells[0,0] <> '' then
    begin
        if fodEsploraRisorse.Execute then
          CartellaSalvataggio := fodEsploraRisorse.FileName;
        if CartellaSalvataggio <> '' then
        begin
            TStringPercorsoCompleto := TStringList.Create;
            try
                PercorsoRicerca := IncludeTrailingPathDelimiter(lblPercorso.Caption);
                for i := 0 to sgFileConfermati.RowCount do
                begin
                    FileDaCercare:= sgFileConfermati.Cells[0,i];
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
                //imgRestart.OnClick(imgRestart);
            finally
                TStringPercorsoCompleto.Free;
            end;
        end
        else
            ShowMessage('Seleziona una cartella!');
    end;
end;

procedure TfCopiaFileConsegna.btnConfermaEnter(Sender: TObject);
begin
    //btnConferma.Hint := 'Copia';
    btnConferma.ShowHint := True;
end;

procedure TfCopiaFileConsegna.btnDeselezionaTuttoClick(Sender: TObject);
var
    i, j, UltimaRiga: Integer;
    FileConEliminazione: TStringList;
begin
    FileConEliminazione := TStringList.Create;
    try
        UltimaRiga := sgFile.RowCount;
        for i := 0 to sgFileConfermati.RowCount - 1 do
        begin
            FileConEliminazione.Add(sgFileConfermati.Cells[0, i]);
        end;
        for i := 0 to sgFileConfermati.RowCount - 1 do
            for j := 0 to sgFileConfermati.ColCount - 1 do
                sgFileConfermati.Cells[j, i] := '';
        sgFileConfermati.RowCount := 0;


        for i := 0 to FileConEliminazione.Count - 1  do
        begin
            if FileConEliminazione[i] <> '' then
            begin
                sgFile.RowCount := UltimaRiga + 1;
                sgFile.Cells[0, UltimaRiga] := FileConEliminazione[i];
                UltimaRiga := UltimaRiga + 1;
            end;
        end;
        RiadattaLarghezzaRighe(sgFile);
        btnSelezionaTutto.Enabled := True;
        btnDeselezionaTutto.Enabled := False;
    finally
     FileConEliminazione.Free;
    end;
end;

procedure TfCopiaFileConsegna.btnDeselezionaTuttoEnter(Sender: TObject);
begin
    //btnDeselezionaTutto.Hint := 'Deseleziona Tutto';
    btnDeselezionaTutto.ShowHint := True;
end;

procedure TfCopiaFileConsegna.btnEsploraRisorseClick(Sender: TObject);
var
    CartellaConGit : String;
    PresenteGit : Boolean;
begin
    Completato := False;
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
    //btnEsploraRisorse.Hint := 'Scegli La Cartella Del Progetto';
    btnEsploraRisorse.ShowHint := True;
end;

procedure TfCopiaFileConsegna.btnRestartClick(Sender: TObject);
var
    i: integer;
begin
    cbBranch.Visible := False;
    btnAnalizzatore.Visible := False;
    btnEsploraRisorse.Visible := True;
    for i := 0 to sgFile.RowCount - 1 do
        sgFile.Cells[0, i] := '';
    for i := 0 to sgFileConfermati.RowCount - 1 do
        sgFileConfermati.Cells[0,i] := '';
    sgFile.RowCount := 0;
    sgFileConfermati.RowCount := 0;
    pnlButtons.Visible := False;
    pnlSelezionaTutto.Visible := False;
    pnlDeselezionaTutto.Visible := False;
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
    i, j, UltimaRiga: Integer;
    FileConEliminazione, FileDaNonSpostare: TStringList;
    Estensione : String;
begin
    FileConEliminazione := TStringList.Create;
    FileDaNonSpostare := TStringList.Create;
    try
        UltimaRiga := sgFileConfermati.RowCount - 1;
        for i := 0 to sgFile.RowCount - 1 do
        begin
            Estensione := sgFile.Cells[0,i];
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
                FileConEliminazione.Add( sgFile.Cells[0, i])
            else
                FileDaNonSpostare.Add( sgFile.Cells[0, i])
        end;
        for i := 0 to sgFile.RowCount - 1 do
            for j := 0 to sgFile.ColCount - 1 do
            begin
                sgFile.Cells[j, i] := '';
            end;
        sgFile.RowCount := 0;

        sgFile.RowCount := FileDaNonSpostare.Count;
        for i := 0 to FileDaNonSpostare.Count - 1 do
        begin
            sgFile.Cells[0,i] := FileDaNonSpostare[i];
        end;
        RiadattaLarghezzaRighe(sgFile);
        for i := 0 to FileConEliminazione.Count - 1  do
        begin
            if Trim(FileConEliminazione[i]) <> '' then
            begin
                if (sgFileConfermati.RowCount = 1) and (sgFileConfermati.Cells[0, 0] = '') then
                    sgFileConfermati.Cells[0, 0] := FileConEliminazione[i]
                else
                begin
                    UltimaRiga := UltimaRiga + 1;
                    sgFileConfermati.RowCount := FileConEliminazione.Count + UltimaRiga;
                    sgFileConfermati.Cells[0, UltimaRiga] := FileConEliminazione[i];
                end;
            end;
        end;
        RiadattaLarghezzaRighe(sgFileConfermati);
        btnSelezionaTutto.Enabled := False;
        btnDeselezionaTutto.Enabled := True;
    finally
     FileConEliminazione.Free;
    end;
end;

procedure TfCopiaFileConsegna.btnSelezionaTuttoEnter(Sender: TObject);
begin
    //btnSelezionaTutto.Hint := 'Seleziona Tutto';
    btnSelezionaTutto.ShowHint := True;
end;

procedure TfCopiaFileConsegna.cbBranchEnter(Sender: TObject);
var
    TStringRemote, TStringBranch, TStringDef : TStringList;
begin
    //cbBranch.Items := RecuperaBranch(CartellaScelta);
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
        Sleep(100);
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
  Command, Percorso: string;

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
  //FileList.Sorted := True;
  //FileList.Duplicates := dupIgnore;
  Stream := TStringStream.Create('');
  try
    // Setup sicurezza pipe
    SA.nLength := SizeOf(SA);
    SA.bInheritHandle := True;
    SA.lpSecurityDescriptor := nil;

    // Ottieni lista commit del branch
    CommitList.Text := RunGitCommand(Format('log --pretty=format:%%H %s', [cbBranch.Text]));
    pbLoading.Max := CommitList.Count;
    // Per ogni commit, estrai i file modificati
    for I := 0 to CommitList.Count - 1 do
    begin
      Sleep(250);
      Command := Format('diff-tree --no-commit-id --name-status -r %s', [CommitList[I]]);
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
    sgFile.Visible := True;
    pnlButtons.Visible := True;
    pnlConferma.Visible := True;
    pnlSelezionaTutto.Visible := True;
    pnlDeselezionaTutto.Visible := True;
    sgFileConfermati.RowCount := 0;
    btnSelezionatutto.Visible := True;
    btnConferma.Visible := True;
    btnAnalizzatore.Enabled := False;
    cbBranch.Enabled := False;
    btnEsploraRisorse.Enabled := False;
    btnDeselezionaTutto.Enabled := False;
    btnRestart.Visible := True;
    //btnDeselezionaTutto.Dis
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
begin
    sgFile.RowCount := FileDaSpostare.Count;

    for i := 0 to FileDaSpostare.Count - 1 do
    begin
        sgFile.Cells[0, i] := Copy(FileDaSpostare[i], 2, Length(FileDaSpostare[i]));
    end;

    RiadattaLarghezzaRighe(sgFile);

//////////////////////////Seconda Griglia///////////////////////////////////////
   RiadattaLarghezzaRighe(sgFileConfermati);
end;

procedure TfCopiaFileConsegna.sgFileConfermatiDblClick(Sender: TObject);
var
    i, j, RigaDaEliminare, NuovaRiga : Integer;
    FileConEliminazione : TStringList;
    RigaDaSpostare : String;
begin
    RigaDaSpostare := sgFileConfermati.Cells[0, sgFileConfermati.Row];
    RigaDaEliminare := sgFileConfermati.Row;
    FileConEliminazione := TStringList.Create;
    try
        for i := 0 to sgFileConfermati.RowCount - 1 do
            if i <> RigaDaEliminare then
            begin
              FileConEliminazione.Add( sgFileConfermati.Cells[0, i]);
            end
            else
                Continue;
        for i := 0 to sgFileConfermati.RowCount - 1 do
            for j := 0 to sgFileConfermati.ColCount - 1 do
                sgFileConfermati.Cells[j, i] := '';
        sgFileConfermati.RowCount := 0;
         for i := 0 to FileConEliminazione.Count - 1 do
         begin
            sgFileConfermati.Cells[0, i] := Copy(FileConEliminazione[i], 1, Length(FileConEliminazione[i]));
         end;
        sgFileConfermati.RowCount := FileConEliminazione.Count;
    finally
     FileConEliminazione.Free;
    //Inserisce l'elemento nella seconda TStringGrid
     NuovaRiga := sgFile.RowCount;

     if (NuovaRiga = 1) and (sgFile.Cells[0, 0] = '') then
        sgFile.Cells[0, 0] := RigaDaSpostare
     else
     begin
         sgFile.RowCount := NuovaRiga + 1;
         sgFile.Cells[0, NuovaRiga] := RigaDaSpostare;
     end;
     RiadattaLarghezzaRighe(sgFile);
    end;
end;

procedure TfCopiaFileConsegna.sgFileDblClick(Sender: TObject);
var
    i, j, RigaDaEliminare, NuovaRiga : Integer;
    FileConEliminazione : TStringList;
    RigaDaSpostare : String;
begin
    RigaDaSpostare := sgFile.Cells[0, sgFile.Row];
    RigaDaEliminare := sgFile.Row;
    FileConEliminazione := TStringList.Create;
    try
        for i := 0 to sgFile.RowCount - 1 do
            if i <> RigaDaEliminare then
            begin
              FileConEliminazione.Add( sgFile.Cells[0, i]);
            end
            else
                Continue;
        for i := 0 to sgFile.RowCount - 1 do
            for j := 0 to sgFile.ColCount - 1 do
                sgFile.Cells[j, i] := '';
        sgFile.RowCount := 0;
         for i := 0 to FileConEliminazione.Count - 1 do
         begin
            sgFile.Cells[0, i] := Copy(FileConEliminazione[i], 1, Length(FileConEliminazione[i]));
         end;
        sgFile.RowCount := FileConEliminazione.Count;
    finally
     FileConEliminazione.Free;
    //Inserisce l'elemento nella seconda TStringGrid
     NuovaRiga := sgFileConfermati.RowCount;

     if (NuovaRiga = 1) and (sgFileConfermati.Cells[0, 0] = '') then
        sgFileConfermati.Cells[0, 0] := RigaDaSpostare
     else
     begin
         sgFileConfermati.RowCount := NuovaRiga + 1;
         sgFileConfermati.Cells[0, NuovaRiga] := RigaDaSpostare;
     end;
     RiadattaLarghezzaRighe(sgFileConfermati);
    end;
end;

procedure TfCopiaFileConsegna.RiadattaLarghezzaRighe(
  TStringGridUsata: TStringGrid);
var
    ColIndex, RowIndex, MaxWidth, RowWidth : Integer;
    S : String;
begin
    MaxWidth := 0;
    ColIndex := 0;
    TStringGridUsata.Canvas.Font := TStringGridUsata.Font;

    for RowIndex := 0 to TStringGridUsata.RowCount - 1 do
    begin
        S := TStringGridUsata.Cells[ColIndex, RowIndex];
        RowWidth := TStringGridUsata.Canvas.TextWidth(S);
        if RowWidth > MaxWidth then
          MaxWidth := RowWidth;
    end;

  // Aggiungi un po' di margine per padding
  TStringGridUsata.ColWidths[ColIndex] := MaxWidth + 12;
end;
procedure TfCopiaFileConsegna.CercaFileRicorsivo(const Percorso, FileDaCercare : String; var Trovato: String);
var
    CostruzionePercorso: String;
begin
    CostruzionePercorso := IncludeTrailingPathDelimiter(Trim(Percorso)) + Trim(FileDaCercare);
    CostruzionePercorso := StringReplace(CostruzionePercorso, '/', '\', [rfReplaceAll]);
    Trovato := CostruzionePercorso;
end;

procedure TfCopiaFileConsegna.FormCreate(Sender: TObject);
begin
    Self.ShowHint := True;
end;

end.

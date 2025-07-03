unit CopiaFileConsegna;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls,
  Vcl.Buttons, Vcl.Grids, System.ImageList, Vcl.ImgList;

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
    Icons: TImageList;
    procedure btnEsploraRisorseClick(Sender: TObject);
    procedure cbBranchEnter(Sender: TObject);
    procedure btnAnalizzatoreClick(Sender: TObject);
  private
    function RecuperaRemote(Percorso: String): TStringList;
    function RecuperaBranch(Percorso: String): TStringList;
    function AnalizzaBranch: TStringList;
    procedure RiempiDatiInsgFile(FileDaSpostare: TStringList);
    procedure RiadattaLarghezzaRighe(TStringGridUsata: TStringGrid);

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

procedure TfCopiaFileConsegna.cbBranchEnter(Sender: TObject);
var
    TStringRemote, TStringBranch, TStringDef : TStringList;
    i : Integer;
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

end.

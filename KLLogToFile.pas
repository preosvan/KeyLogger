unit KLLogToFile;

interface

type
  TKLLog = class
  private
    FPathToLog: string;
    FTextFile: TextFile;
    FAppName: string;
    procedure CreateLog;
    procedure SetAppName(const Value: string);
  public
    constructor Create(APathToLog: string = '');
    procedure WriteKey(const AAppName, AKey: string);
    procedure WriteMsg(const AMsg: string);
    property CurrAppName: string read FAppName write SetAppName;
    property PathToLog: string read FPathToLog;
  end;

implementation

uses
  System.SysUtils, Winapi.Windows, KLConst, KLUtils, System.Classes;

{ TKLLog }

constructor TKLLog.Create(APathToLog: string);
begin
  FPathToLog := Trim(APathToLog);
  if FPathToLog = EmptyStr then
    FPathToLog := GetPathToTempDirectory + KL_LOG_NAME + '.log';
  if not FileExists(FPathToLog) then
    CreateLog;
end;

procedure TKLLog.CreateLog;
begin
  ForceDirectories(ExtractFileDir(FPathToLog));
  AssignFile(FTextFile, FPathToLog);
  try
    Rewrite(FTextFile);
    WriteLn(FTextFile, Concat('===================== Лог создан [', DateTimeToStr(Now), ']'));
  finally
    CloseFile(FTextFile);
  end;
end;

procedure TKLLog.SetAppName(const Value: string);
begin
  if Trim(CurrAppName) <> Trim(Value) then
  begin
    AssignFile(FTextFile, FPathToLog);
    try
      Append (FTextFile);
      WriteLn(FTextFile, '');
      if CurrAppName <> EmptyStr then
        WriteLn(FTextFile, '---------------------------------------');
      WriteLn(FTextFile, Value);
    finally
      CloseFile(FTextFile);
    end;
    FAppName := Value;
  end;
end;

procedure TKLLog.WriteKey(const AAppName, AKey: string);
begin
  CurrAppName := AAppName;
  AssignFile(FTextFile, FPathToLog);
  try
    Append(FTextFile);
    Write(FTextFile, AKey);
  finally
    CloseFile(FTextFile);
  end;
end;

procedure TKLLog.WriteMsg(const AMsg: string);
begin
  AssignFile(FTextFile, FPathToLog);
  try
    Append(FTextFile);
    WriteLn(FTextFile, '');
    WriteLn(FTextFile, AMsg);
  finally
    CloseFile(FTextFile);
  end;
end;

end.

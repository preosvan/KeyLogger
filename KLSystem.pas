unit KLSystem;

interface

function InitMutex(AMutexId: string): Boolean;

implementation

uses Windows;

var
  Mutex: THandle;

function MutexId(AStr: string): string;
var
  f: Integer;
begin
  Result := AStr;
  for f := 1 to Length(AStr) do
    if Result[f] = '\' then
      Result[f] := '_';
end;

function InitMutex(AMutexId: string): Boolean;
begin
  Mutex := CreateMutex(nil, False, PChar(MutexId(AMutexId)));
  Result := not ((Mutex = 0) or (GetLastError = ERROR_ALREADY_EXISTS));
end;

initialization
  Mutex := 0;

finalization
  if Mutex <> 0 then
    CloseHandle(Mutex);
end.


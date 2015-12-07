program KLSvc;

uses
  Vcl.SvcMgr,
  KLServiceUnit in 'KLServiceUnit.pas' {KLService: TService},
  KLConst in 'KLConst.pas',
  KLLogToFile in 'KLLogToFile.pas';

{$R *.RES}

begin
  if not Application.DelayInitialize or Application.Installing then
    Application.Initialize;
  Application.CreateForm(TKLService, KLService);
  Application.Run;
end.

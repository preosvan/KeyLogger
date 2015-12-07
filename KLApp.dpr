program KLApp;

uses
  Vcl.Forms,
  MainFrm in 'MainFrm.pas' {MainForm},
  KLConst in 'KLConst.pas',
  KLUtils in 'KLUtils.pas',
  KLSystem in 'KLSystem.pas';

{$R *.res}

begin
  if not InitMutex(Application.ExeName) then
    Exit;
{$IFDEF RELEASE}
  Application.ShowMainForm := False;
{$ENDIF}
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.

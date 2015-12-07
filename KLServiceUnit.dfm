object KLService: TKLService
  OldCreateOrder = False
  DisplayName = 'KLService'
  Interactive = True
  OnContinue = ServiceContinue
  OnPause = ServicePause
  OnStart = ServiceStart
  OnStop = ServiceStop
  Height = 150
  Width = 215
end

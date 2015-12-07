object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'MainForm'
  ClientHeight = 105
  ClientWidth = 409
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object btnHook: TButton
    Left = 8
    Top = 8
    Width = 161
    Height = 25
    Caption = 'Start'
    TabOrder = 0
    OnClick = btnHookClick
  end
  object btnUnhook: TButton
    Left = 8
    Top = 39
    Width = 161
    Height = 25
    Caption = 'Stop'
    TabOrder = 1
    OnClick = btnUnhookClick
  end
  object Edit1: TEdit
    Left = 8
    Top = 70
    Width = 393
    Height = 21
    TabOrder = 2
    Text = 'Edit1'
  end
  object Button1: TButton
    Left = 192
    Top = 8
    Width = 145
    Height = 25
    Caption = 'Upload to FTP'
    TabOrder = 3
    OnClick = Button1Click
  end
  object Timer: TTimer
    OnTimer = TimerTimer
    Left = 360
    Top = 8
  end
end

object Frm_About: TFrm_About
  Left = 0
  Top = 0
  BorderIcons = []
  BorderStyle = bsDialog
  Caption = 'About...'
  ClientHeight = 314
  ClientWidth = 355
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Btn_Close: TButton
    Left = 136
    Top = 282
    Width = 75
    Height = 25
    Caption = 'Close'
    TabOrder = 0
    OnClick = Btn_CloseClick
  end
  object Red_About: TRichEdit
    Left = 8
    Top = 8
    Width = 337
    Height = 267
    Alignment = taCenter
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    Zoom = 100
  end
end

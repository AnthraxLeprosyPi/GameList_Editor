program GameListEditor;

uses
  Vcl.Forms,
  F_Main in 'F_Main.pas' {Frm_Editor},
  Vcl.Themes,
  Vcl.Styles,
  F_MoreInfos in 'F_MoreInfos.pas' {Frm_MoreInfos},
  F_About in 'F_About.pas' {Frm_About},
  F_Help in 'F_Help.pas' {Frm_Help},
  F_ConfigureSSH in 'F_ConfigureSSH.pas' {Frm_ConfigureSSH},
  U_gnugettext in 'U_gnugettext.pas',
  U_Resources in 'U_Resources.pas',
  U_Game in 'U_Game.pas',
  F_Scraper in 'F_Scraper.pas' {Frm_Scraper};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Charcoal Dark Slate');
  Application.CreateForm(TFrm_Editor, Frm_Editor);
  Application.CreateForm(TFrm_Scraper, Frm_Scraper);
  Application.Run;
end.

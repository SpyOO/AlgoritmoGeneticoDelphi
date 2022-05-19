program Travel;

uses
  System.StartUpCopy,
  FMX.Forms,
  uMain in 'uMain.pas' {FAG},
  uTSP in 'uTSP.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFAG, FAG);
  Application.Run;
end.

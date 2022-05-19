program AG;
{$APPTYPE CONSOLE}
uses
  buscaPalabras in 'buscaPalabras.pas',
  system.SysUtils;

{$R *.res}
var
 A:TBuscaPalabra;
begin
 A:=TBuscaPalabra.Create(10000,'hola mundo loco');

 A.Encuentralo(10000000);
 Sleep(5000);


end.

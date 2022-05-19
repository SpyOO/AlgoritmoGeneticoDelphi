unit uMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,BuscaPalabras, FMX.Controls.Presentation, FMX.StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  A:TBuscaPalabra;
implementation

{$R *.fmx}

procedure TForm1.Button1Click(Sender: TObject);
begin
 A:=TBuscaPalabra.Create(1000,'hola');
end;

end.

unit uMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,system.Math,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects, FMX.Layouts, FMX.Memo.Types,
  FMX.ScrollBox, FMX.Memo,uTSP, FMX.Edit, FMX.EditBox, FMX.NumberBox, FMX.SpinBox;

type


  TFAG = class(TForm)
    lay_controls: TLayout;
    lay_image: TLayout;
    Img_board: TImage;
    Rectangle1: TRectangle;
    BtnClean: TButton;
    BtnGenerar: TButton;
    GrpConfig: TGroupBox;
    edtPoblacion: TSpinBox;
    Label1: TLabel;
    Label2: TLabel;
    edtMutacion: TSpinBox;
    btnIniciar: TButton;
    txt_ciudad: TText;
    Txt_distancia: TText;
    TxtGeneracion: TText;
    procedure FormCreate(Sender: TObject);
    procedure Img_boardMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure BtnCleanClick(Sender: TObject);
    procedure BtnGenerarClick(Sender: TObject);
    procedure ClearImage;
    procedure btnIniciarClick(Sender: TObject);

  private
    { Private declarations }

  public
    { Public declarations }
  end;

var
  FAG: TFAG;
  T:TTSP;
  Ciudades:TCities;
implementation

{$R *.fmx}

{ TForm1 }



procedure TFAG.BtnCleanClick(Sender: TObject);
begin
  clearImage;
  Btniniciar.Enabled:=false;
  txt_ciudad.Text:= length(Ciudades).ToString + ' ciudades';
  Txt_distancia.Text:= '0 Km';
  TxtGeneracion.Text:='0 generaciones'
end;

procedure TFAG.btnIniciarClick(Sender: TObject);
begin
 if btnIniciar.TagString = 'INI' then
  begin
   T.Terminate;
   btnClean.Enabled:=true;
   btnGenerar.Enabled:=true;
   btnIniciar.TagString:='DET';
   btnIniciar.Text:='Iniciar';
  end
 else
 begin
   T.Start;
   btnClean.Enabled:=false;
   btnGenerar.Enabled:=false;
   btnIniciar.TagString:='INI';
   btnIniciar.Text:='Detener';
 end;
end;

procedure TFAG.BtnGenerarClick(Sender: TObject);
var
 vPoblacion:Integer;
 vMutacion:integer;
begin
 if Length(ciudades) > 0  then
  begin
   vPoblacion:=edtPoblacion.Text.ToInteger;
   vMutacion:=edtMutacion.Text.ToInteger;
   T:=TTSP.Create(vMutacion,Ciudades,vPoblacion);
   T.Imagen:=Img_board;
   T.DistanciaLabel:=txt_distancia;
   T.GenLabel:=TxtGeneracion;
   T.ShowRutas;
   Btniniciar.Enabled:=True;
  end;
end;
//------------------------------------------------------------------------
procedure TFAG.ClearImage;
begin
// sets the size of the TBitmap
  setlength(Ciudades,0);
  Img_board.Bitmap.SetSize(Round(Img_board.Width*2), Round(Img_board.Height*2));
  Img_board.Bitmap.Clear(TAlphaColors.Lemonchiffon);
end;

procedure TFAG.FormCreate(Sender: TObject);
begin
  // sets the size of the TBitmap
  Img_board.Bitmap.SetSize(Round(Img_board.Width*2), Round(Img_board.Height*2));
  Img_board.Bitmap.Clear(TAlphaColors.Lemonchiffon);

end;

//------------------------------------------------------------------------------

procedure TFAG.Img_boardMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  MyRect: TRectF;
  Point:TPointF;
  ix:integer;
begin
   // sets the circumscribed rectangle of the ellipse
  Caption := X.ToString + ',' + Y.ToString;
  Point := TPointF.Create(X, Y);
  MyRect := TRectF.Create(Point, 5, 5);

  // draws the ellipse on the canvas
  Img_board.Bitmap.Canvas.BeginScene;
  Img_board.Bitmap.Canvas.DrawEllipse(MyRect, 20);
  Img_board.Bitmap.Canvas.EndScene;

  //add a city to arra
   ix:=Length(Ciudades) + 1;
   SetLength(Ciudades,ix);
   Ciudades[ix - 1].Point:=Point;
   txt_ciudad.Text:= length(Ciudades).ToString + ' ciudades';

end;

end.

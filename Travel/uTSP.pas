unit uTSP;

interface

uses
  System.Classes,Fmx.Objects, system.Types,system.Math,system.Generics.Collections,
  System.Generics.Defaults,system.UITypes,system.SysUtils;

type

  TCity = record
   Point:TPointF;
  end;
  TCities = array of TCity;

  TRutas = Array of integer;

  TIndividuo = record
    comosoma:TRutas;
    fitness:real;
  end;
  TIndividuos = Array of TIndividuo;


  TTSP = class(TThread)

  private
    { Private declarations }

     FCiudades:TCities;
     FRutasOrder:TRutas;
     FIndividuos:TIndividuos;
     FHijos:TIndividuos;
     FPoblacion:integer;
     FTasaMutacion:integer;
     FImage:TImage;
     FDistanciaLabel:TText;
     FGeneracion:TText;
     FCountGen:integer;
     function CalcularDistancia(Individuo:TIndividuo):real;
     function CalcularDistanEntreGenes(Gen1,Gen2:integer):real;
     procedure InicializaPoblacion;
     procedure OrdenarPoblacion;
     procedure DrawRutas;
     function  PARTIAL_MAPPED_CROSSOVER(p_ix:integer):TIndividuo;
     function  ObtenerMejorGen(GenActual,GenPadreA,GenPadreB:integer):integer;
     function CambiamosGenesRepetidos(p_padre,p_individuo:TIndividuo):TIndividuo;
     function GetNuevoGen(p_padre,p_individuo:TIndividuo):integer;
     procedure DeleteRepetidos;
     procedure ShiftArrayLeft(var p_individuo:TIndividuo);
    procedure DesordenarPoblacion;
  public
    procedure ShowRutas;
    constructor Create(ATasaMutacion:integer;ACiudades:TCities;APoblacion:integer);
    destructor  Destroy; Override;
  published
    property Imagen:TImage read FImage write FImage;
    property DistanciaLabel:TText read FDistanciaLabel write FDistanciaLabel;
    Property GenLabel:TText read FGeneracion write FGeneracion;

  protected
    procedure Execute; override;

  end;

implementation


{ TSP }

function TTSP.CalcularDistancia(Individuo: TIndividuo): real;
var
  i: Integer;
  vIx1,vIx2:integer;
  vDistancia:real;

begin
  vDistancia:=0;
  for i := Low(Individuo.comosoma) to High(Individuo.comosoma) do
   begin
     {Comparamos los genes del cromosoma con su siguiente en la lista
      en caso de que sea el último lo comparamos con el primero}
     if i <> high(Individuo.comosoma) then
       vIx2:=Individuo.comosoma[i + 1]
     else
       vIx2:=0;

     {Cargamos los valores e indicies en variables para facilitar el cálculo}
     vIx1:=Individuo.comosoma[i];



     {Cáclulo de la distancia entre dos puntos geométricos}
     vDistancia:=vDistancia + CalcularDistanEntreGenes(vIx1,vIx2); //Abs(SQRT( power(x2 - x1, 2) + power(y2 - y1 , 2) ));
   end;

  result:=vDistancia;
end;
//----------------------------------------------------------------------------------------
function TTSP.CalcularDistanEntreGenes(Gen1, Gen2: integer): real;
var
  x1,x2:single;
  y1,y2:single;
  vDistancia:real;
begin
  x1:=FCiudades[Gen1].Point.x;
  x2:=FCiudades[Gen2].Point.x;
  y1:=FCiudades[Gen1].Point.y;
  y2:=FCiudades[Gen2].Point.y;

  {Cáclulo de la distancia entre dos puntos geométricos}
  vDistancia:= Abs(SQRT( power(x2 - x1, 2) + power(y2 - y1 , 2) ));

  result:=vDistancia;

end;
//------------------------------------------------------------------------------------
function TTSP.CambiamosGenesRepetidos(p_padre,p_individuo: TIndividuo): TIndividuo;
var
 i,j:integer;

begin
 for i := Low(p_individuo.comosoma) to High(p_individuo.comosoma) do
  for j := Low(p_individuo.comosoma)  to High(p_individuo.comosoma)  do
   if (p_individuo.comosoma[i]=p_individuo.comosoma[j]) and (i <> j) then
    begin
       p_individuo.comosoma[j]:=GetNuevoGen(p_padre,p_individuo);

    end;

   result:=p_individuo;
end;

//-----------------------------------------------------------------------------------------
constructor TTSP.Create(ATasaMutacion: integer; ACiudades: TCities;APoblacion:integer);
begin
  inherited Create(true);
  FCiudades:=ACiudades;
  FPoblacion:=APoblacion;
  FTasaMutacion:=ATasaMutacion;
  FCountGen:=0;
  SetLength(FrutasOrder, Length(ACiudades));
  SetLength(FIndividuos, APoblacion);
  Randomize;
  InicializaPoblacion;
  ordenarPoblacion;

  Randomize;
end;
//-------------------------------------------------------------------------------------------

function TTSP.PARTIAL_MAPPED_CROSSOVER(p_ix: integer): TIndividuo;
var
 vHijoA,vHijoB:TIndividuo;
 vMin,vMax,vEnd,vStart:Integer;
 Crom1,Crom2:TRutas;
 CromS1,CromS2:TRutas;
 CromE1,CromE2:Trutas;
 vAux:integer;
begin
  vStart:=1;
  vEnd:=Length(FIndividuos[p_ix].comosoma);
  vMin:= trunc((vEnd) / 3) + 1;
  vmax:= vEnd  - vMin +1;
  Crom1:= copy(FIndividuos[p_ix].comosoma,vMin-1,vMax-vMin +1);
  CromS1:=copy(FIndividuos[p_ix].comosoma,vStart-1,vMin - 1);
  CromE1:=copy(FIndividuos[p_ix].comosoma,vMax );
  if p_ix = high(FIndividuos) then
    begin
     CromS2:=copy(FIndividuos[p_ix].comosoma,vMin-1,vMax-vMin +1);
     CromE2:=copy(FIndividuos[p_ix].comosoma,vStart-1,vMin -1);
     Crom2:=copy(FIndividuos[p_ix].comosoma,vMax );
    end
  else
    begin
     Crom2:=copy(FIndividuos[p_ix  + 1].comosoma,vMin-1,vMax-vMin +1);
     CromS2:=copy(FIndividuos[p_ix + 1].comosoma,vStart-1,vMin - 1);
     CromE2:=copy(FIndividuos[p_ix + 1].comosoma,vMax);
    end;


    vHijoA.comosoma:=Concat(CromS1,Crom2,CromE1);
    vHijoB.comosoma:=Concat(CromS2,Crom1,CromE2);



  CambiamosGenesRepetidos(FIndividuos[p_ix],vHijoA);
  CambiamosGenesRepetidos(FIndividuos[p_ix],vHijoB);
  vAux:=Length(FHijos);
  setLength(FHijos, vAux +2);
  FHijos[vAux ].comosoma:=VHijoA.comosoma;
  FHijos[vAux + 1 ].comosoma:=VHijoB.comosoma;
  ShiftArrayLeft(FIndividuos[p_ix]);






end;

procedure TTSP.DeleteRepetidos;
var
  i,j: Integer;
begin
 for i := Low(Findividuos) to High(Findividuos) do
  for j := Low(Findividuos) to High(Findividuos) do
    if (Findividuos[i].fitness = Findividuos[j].fitness ) and (i <> j) then
     begin
        Findividuos[j].fitness:=999999999.99;
     end;



end;

destructor TTSP.Destroy;
begin

  inherited;
end;

procedure TTSP.DrawRutas;
var
  i: Integer;
  vC1,vC2:integer;
begin
 if Length(FIndividuos) > 0 then
  begin
    FImage.Bitmap.Canvas.BeginScene;
   // FImage.Bitmap.SetSize(Round(FImage.Width*2), Round(FImage.Height*2));
    FImage.Bitmap.Clear(TAlphaColors.Lemonchiffon);
    try
     {Dibuja las Ciudades}
    for i := Low(FCiudades) to High(FCiudades) do
     begin
      Fimage.Bitmap.Canvas.DrawEllipse(TRectF.Create(FCiudades[i].Point,5,5), 20);
     end;
      
    {Dibuja las lineas}
    for i := Low(FIndividuos[0].comosoma) to High(FIndividuos[0].comosoma) do
      begin

        vC1:=FIndividuos[0].comosoma[i];
        if i = High(FIndividuos[0].comosoma) then
         vC2:=FIndividuos[0].comosoma[0]
        else
         vC2:=FIndividuos[0].comosoma[i + 1];

        FImage.Bitmap.Canvas.DrawLine(FCiudades[vC1].Point,FCiudades[vC2].Point,1);
      end;


    finally
     FImage.Bitmap.Canvas.EndScene;

     FDistanciaLabel.Text:=floatTostr( RoundTo(FIndividuos[0].fitness,-2)) + ' Km';
     //Mostramos la generación
     FGeneracion.Text:= FCountGen.tostring + ' generaciones';
   end;
  end;

end;
//-------------------------------------------------------------------------------------
procedure TTSP.Execute;
var
  i,j,vAux: Integer;
  vElite,vNewIndividuo:TIndividuo;

  vGeneracion:integer;
begin
  { Place thread code here }
 while not terminated do
  begin
    i:=0;
    setLength(FHijos,0);

    {Copiamos el mejor individuo hasta el momento}
      if  High(FIndividuos) > 0 then
        begin
          vElite.comosoma:=FIndividuos[0].comosoma;
          vElite.fitness:=FIndividuos[0].fitness;
        end;

   // DesordenarPoblacion;
    while i <= High(FIndividuos) do
     begin


        {Relizamos el cruce}
        PARTIAL_MAPPED_CROSSOVER(i);


       inc(i,2);
     end;

     {Añadimos al hijo élite}
       j:=length(FHijos);
       setLength(FHijos,j + 1);
       FHijos[i].comosoma:=vElite.comosoma;

       inc(vGeneracion);
       inc(FCountGen);
      {Añadimos mutantes}
      (*if vGeneracion = FTasaMutacion then
       begin
         vGeneracion:=0;
         ShiftArrayLeft(vElite);

       {Añadimos al hijo Mutante}
          i:=length(FHijos);
          setLength(FHijos,i + 1);
          FHijos[i].comosoma:=vElite.comosoma
       end;
            *)

      {Añadimos los hijos a la población}
     for i := Low(FHijos) to High(FHijos) do
       begin
         j:= length(FIndividuos);
         setLength(FIndividuos, j + 1);

         FIndividuos[j].comosoma:=FHijos[i].comosoma;
         FIndividuos[j].fitness:=CalcularDistancia(FHijos[i]);

       end;

      {Quitar cromozomas repetidos}
      DeleteRepetidos;

      {Ordenamos la población}
      ordenarPoblacion;

      {Mueren los menos adaptados}

      setLength(FIndividuos,FPoblacion);

   //   sleep(100);


      {Dibujamos en el mapa}

         DrawRutas;


  end;


end;
//-----------------------------------------------------------------------------------------------
function TTSP.GetNuevoGen(p_padre,p_individuo:TIndividuo):integer;
var
 i,j:integer;
 vExiste:Boolean;
begin
  for i := Low(p_padre.comosoma) to High(p_padre.comosoma) do
   begin
    vExiste:=false;
    for j := Low(p_individuo.comosoma) to High(p_individuo.comosoma) do
     if p_padre.comosoma[i] = p_individuo.comosoma[j] then
        vExiste:=true;

    if not vExiste then
     begin
      result:=p_padre.comosoma[i];
      break
     end;

   end;




end;

//----------------------------------------------------------------------------------------------
procedure TTSP.InicializaPoblacion;
var
  i,j,vAux,vIx: Integer;
begin

 for i := Low(FIndividuos) to High(FIndividuos) do
  begin
   setLength(FIndividuos[i].comosoma,length(FCiudades));
   {rellenamos el cromosoma con valores secuenciales}
   for j := Low(FIndividuos[i].comosoma) to High(FIndividuos[i].comosoma) do
    FIndividuos[i].comosoma[j]:=j;

    {Shuffle de las rutas al azar}
   for j := Low(FIndividuos[i].comosoma) to High(FIndividuos[i].comosoma) do
    begin
      vIx:=1 + random (high(FRutasOrder));
      vAux:= FIndividuos[i].comosoma[j];
      FIndividuos[i].comosoma[j]:= FIndividuos[i].comosoma[vIx];
      FIndividuos[i].comosoma[vIx]:= vAux;
     end;

    FIndividuos[i].fitness:=CalcularDistancia(FIndividuos[i]);
  end;


 end;

//---------------------------------------------------------------------------------------------
function TTSP.ObtenerMejorGen(GenActual, GenPadreA, GenPadreB: integer): integer;
var
 vDist1,vDist2:real;
 vGenSelected:integer;
begin
  vDist1:=CalcularDistanEntreGenes(GenActual,GenPadreA);
  vDist2:=CalcularDistanEntreGenes(GenActual,GenPadreB);
  vGenSelected:=-1;

  if vDist1 = 0 then
   vGenSelected:=GenPadreB;

  if vDist2 = 0 then
    vGenSelected:=GenPadreA;

   if vGenSelected = -1 then
     if vDist1 > vDist2 then
       vGenSelected:=GenPadreB
     else
       vGenSelected:=GenPadreA;



  result:=vGenSelected;
end;
//----------------------------------------------------------------------------------------------
procedure TTSP.OrdenarPoblacion;
var
 comp:IComparer<TIndividuo>;
begin
     //Aramos el sort de comapración
      comp:=TComparer<TIndividuo>.construct( function (const l,r:TIndividuo):integer
        begin
            result:=CompareValue(l.fitness,R.fitness );
        end);

        //Ordenamos
        TArray.Sort<TIndividuo>(FIndividuos,comp);
end;
//----------------------------------------------------------------------------------------------
procedure TTSP.DesordenarPoblacion;
var
 i:integer;
 posTo:integer;
 vTemp:TIndividuo;
begin
    for i := Low(FIndividuos) to High(FIndividuos) do
     begin
        vTemp.comosoma:=FIndividuos[i].comosoma;
        vTemp.fitness:=FIndividuos[i].fitness;
        posTo:=RandomRange(0,High(FIndividuos));
        FIndividuos[i].comosoma:=FIndividuos[posTo].comosoma;
        FIndividuos[i].fitness:=FIndividuos[posTo].fitness;
        FIndividuos[posTo].comosoma:=vTemp.comosoma;
        FIndividuos[posTo].fitness:=vTemp.fitness;
     end;

end;
//----------------------------------------------------------------------------------------------
procedure TTSP.ShiftArrayLeft(var p_individuo: TIndividuo);
var
  i: Integer;
  vH: Integer;
  cromo:Trutas;
  vCut:integer;
begin
  if Length(p_individuo.comosoma) < 2 then
    exit;

  setLength(Cromo,Length(p_individuo.comosoma));
  for i := Low(cromo) to High(cromo) do
  Cromo[i]:=p_individuo.comosoma[i];

  vCut:=Trunc(Length(Cromo) / 3);
  vH:=high(Cromo);
  if vH > vCut then
  begin
    //for i := High(Cromo) downto High(Cromo) - vCut do
    //  p_individuo.comosoma[vH - i]:=Cromo[i];


   for i := Low(Cromo) to vCut - 1 do
     p_individuo.comosoma[vH - vCut + 1 + i]:=Cromo[i];

   for i := vCut to VH  do
     p_individuo.comosoma[i -vCut]:=Cromo[i];
  end;





end;
//-----------------------------------------------------
procedure TTSP.ShowRutas;
begin
   Synchronize(DrawRutas);
end;

end.

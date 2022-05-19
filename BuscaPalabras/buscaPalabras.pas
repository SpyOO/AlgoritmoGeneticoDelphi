unit buscaPalabras;

interface
uses system.Math,system.SysUtils;
 const
  cLetras = 'abcdefghijklmnopqrstuvwxyz *';

 type
 TIndividuo = record
   texto:string;
   score:integer;
 end;

 TBuscaPalabra = class
  FPoblacion:Array of TIndividuo;
  FPalabraBuscada:string;
 public
  procedure Encuentralo(AcantCiclos:integer);
 private
  procedure InicializarPoblacion;
  function  GeneraPalabras:string;
  function  GetIndexRandom(APalabra:string):integer;
  function LevenshteinDistance(Str1, Str2: String): Integer;
  procedure Mutar(AIndividuo:integer);
 published
  property    PalabraBuscada:string read fPalabraBuscada;
  constructor Create(APoblacion: integer;APalabraBuscada:string);
  destructor  Destroy; override;
 end;
implementation

{ TBuscaPalabra }

function TBuscaPalabra.LevenshteinDistance(Str1, Str2: String): Integer;
var
  d : array of array of Integer;
  Len1, Len2 : Integer;
  i,j,cost:Integer;
begin
  Len1:=Length(Str1);
  Len2:=Length(Str2);
  SetLength(d,Len1+1);
  for i := Low(d) to High(d) do
    SetLength(d[i],Len2+1);

  for i := 0 to Len1 do
    d[i,0]:=i;

  for j := 0 to Len2 do
    d[0,j]:=j;

  for i:= 1 to Len1 do
    for j:= 1 to Len2 do
    begin
      if Str1[i]=Str2[j] then
        cost:=0
      else
        cost:=1;
      d[i,j]:= Min(d[i-1, j] + 1,     // deletion,
                   Min(d[i, j-1] + 1, // insertion
                       d[i-1, j-1] + cost)   // substitution
                            );
    end;
  Result:=d[Len1,Len2];
end;

procedure TBuscaPalabra.Mutar(AIndividuo: integer);
var
 vLC:integer; //letra a cambiar
 vLE:integer; //letra escogida
begin
  vLC:=GetIndexRandom(FPoblacion[AIndividuo].texto);
  vLE:=GetIndexRandom(cLetras);
  FPoblacion[Aindividuo].texto[vLC]:=Cletras[vLE];
end;

constructor TBuscaPalabra.Create(APoblacion: integer;APalabraBuscada:string);
begin
  {Definimos el tamaño de la población}
   SetLength(FPoblacion, APoblacion);

  {Inicializamos el generador de números random}
   Randomize;

  {Inicializar población}
   FPalabraBuscada:=APalabraBuscada;
   InicializarPoblacion;
end;

destructor TBuscaPalabra.Destroy;
begin
  setLength(FPoblacion,0);
  inherited;
end;

procedure TBuscaPalabra.Encuentralo(AcantCiclos: integer);
var
  i,j: Integer;
  ix1,ix2:integer;
  ixWin:integer;

begin
 for i := 1 to ACantCiclos do
  begin
    {Obtenemos dos individuos al azar de la población}
    ix1:=System.Math.RandomRange(0, Length(Fpoblacion) -1);
    ix2:=System.Math.RandomRange(0, Length(Fpoblacion) -1);

    {Seleccionamos el indviduo que mejor scoring tenga}
   if FPoblacion[ix1].score <>  FPoblacion[ix2].score then
    begin
      if  FPoblacion[ix1].score <  FPoblacion[ix2].score then
        begin
          FPoblacion[ix2].texto:=FPoblacion[ix1].texto;
          Mutar(Ix2);
          FPoblacion[ix2].score:=LevenshteinDistance(FPoblacion[Ix2].texto,FPalabraBuscada);
        end
      else
        begin
          FPoblacion[ix1].texto:=FPoblacion[ix2].texto;
          Mutar(Ix1);
          FPoblacion[ix1].score:=LevenshteinDistance(FPoblacion[Ix1].texto,FPalabraBuscada);
        end;

      ixWin:=0;
      {Buscamos el indivuo mejor adaptado}
      for j := Low(FPoblacion) to High(FPoblacion) do
       begin
          if FPoblacion[j].score < FPoblacion[ixWin].score then
            ixWin:=j;
       end;

       {Imprimos el ganador}
        writeln( FPoblacion[ixWin].texto + '->' + FPoblacion[ixWin].score.ToString);
    end;
  end;


end;

function TBuscaPalabra.GeneraPalabras: string;

var
 i:integer;
 vPalabra:string;
begin
   for i := 0 to length(fPalabraBuscada) -1 do
    begin
      vPalabra:= vpalabra + cLetras[GetIndexRandom(cLetras)];
    end;
   result:=vPalabra;
end;

function TBuscaPalabra.GetIndexRandom(APalabra:string): integer;
var
 l:integer;
begin
 l:=System.Math.RandomRange(1, Length(APalabra));
 result:=l;
end;

procedure TBuscaPalabra.InicializarPoblacion;
var
  i: Integer;
begin
 for i := Low(FPoblacion) to High(FPoblacion) do
  begin
    FPoblacion[i].texto:=GeneraPalabras;
    FPoblacion[i].score:=LevenshteinDistance(FPoblacion[i].texto,FPalabraBuscada);
  end;
end;

end.

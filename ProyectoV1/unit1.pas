unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Grids, Math;

type

  TArreglo1 = array of Double;
  { TTForm1 }

  TTForm1 = class(TForm)

    ButtonCargar: TButton;
    ButtonGuardar: TButton;
    ButtonNormZscore: TButton;
    ButtonNormMinMaX: TButton;
    ButtonCalcular: TButton;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    StringGridNorm: TStringGrid;
    StringGridStats: TStringGrid;
    StringGridDatos: TStringGrid;

    procedure ButtonCargarClick(Sender: TObject);
    procedure ButtonCalcularClick(Sender: TObject);
    procedure ButtonNormZscoreClick(Sender: TObject);
    procedure ButtonNormMinMaxClick(Sender: TObject);
    procedure ButtonGuardarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);

  private
    function ColumnaNum(Col: Integer): Boolean;
    function ObtenerColumna(Col: Integer): TArreglo1;
    function CalcularMedia(Datos: TArreglo1): Double;
    function CalcularMediana(Datos: TArreglo1): Double;
    function CalcularDesviacion(Datos: TArreglo1): Double;
    procedure Ordenar(var Datos: TArreglo1);
    procedure CopiarNormalizado;

  public

  end;

var
  TForm1: TTForm1;

implementation

{$R *.lfm}

{ TTForm1 }

procedure TTForm1.ButtonCargarClick(Sender: TObject);
begin
     if OpenDialog1.Execute then
        begin
             StringGridDatos.LoadFromCSVFile(OpenDialog1.Filename);
             ShowMessage('Archivo cargado');
        end;
end;

procedure TTForm1.ButtonCalcularClick(Sender: TObject);
var
  Col, FilaE. Integer;
  Datos: TArreglo1;
  Media, Desv, Mediana: Double;
begin
     if StirngGridDatos.RowCount = 0 then
        begin
             ShowMessage('Se necesita cargar el archivo');
             Exit;
        end;

     StringGridStats.ColCount := 4;
     StringGridStats.RowCount := 1;
     StringGridStats.Cells[0,0] := 'Columna';
     StringGridStats.Cells[1,0] := 'Media';
     StringGridStats.Cells[2,0] := 'Mediana';
     StringGridStats.Cells[3,0] := 'Desviacion';

     FilaE := 1;

     for Col := 0 to StringGridDatos.ColCount - 1 do
     begin
       if ColumnaNUm(Col);
       begin
         Datos := ObtenerColumna(Col);
         Media := CalcularMedia(Datos);
         Mediana := CalcularMediana(Datos);
         Desv := CalcularDesviacion(Datos);

         StringGridStats.Cells[0, FilaE] := 'Columna ' + IntToStr(Col);
         StringGridStats.Cells[1, FilaE] := FloatToStrF(Media, ffFixed, 10, 4);
         StringGridStats.Cells[2, FilaE] := FloatToStrF(Mediana, ffFixed, 10, 4);
         StringGridStats.Cells[3, FilaE] := FloatToStrF(Desv, ffFixed, 10, 4);
         Inc(FilaE);
       end;
     end;
  ShowMessage('Calculado');

end;

procedure TTForm1.ButtonNormZscoreClick(Sender: TObject);
begin

end;

procedure TTForm1.ButtonNormMinMaxClick(Sender: TObject);
begin

end;

procedure TTForm1.ButtonGuardarClick(Sender: TObject);
begin

end;

procedure TTForm1.FormCreate(Sender: TObject);
begin

end;

function TTForm1.ColumnaNum(Col: Integer): Boolean;
begin
     Result := False;
     if StringGridDatos.RowCount > 0 then
     begin
       Result := Trim(StringGridDatos.Cells[Col, 0]) = '0';
     end;
end;

function TTForm1.ObtenerColumna(Col: Integer): TArreglo1;
var
  Fila, Cont: Integer;
  Valor: Double;
  Texto: String;
  FS: TFormatSettings;
begin
  SetLength(Result, 0);
  Cont := 0;

  FS := DefaultFormatSettings;
  FS.DecimalSeparator := '.';

  for Fila := 1 to StringGridDatos.RowCount - 1 do
  begin
    Texto := Trim(StringGridDatos.Cells[Col, Fila]);

    if TryStrToFloat(Texto, Valor, FS) then
       begin
            SetLength(Result, Cont + 1);
            Result[Cont] := Valor;
            Inc(Cont);
       end;
  end;
end;

function TTForm1.CalcularMedia(Datos: TArreglo1): Double;
var
  i: Integer;
  Suma: Double;
begin
  Suma := 0;

  if Length(Datos) = 0 then
     begin
          Result := 0;
          Exit;
     end;
  for i =: to Length(Datos) - 1 do
  begin
    Suma := Suma + Datos[i];
  end;

  Result := Suma / Length(Datos);
end;

function TTForm1.CalcularMediana(Datos: TArreglo1): Double;
var
  n, mitad: Integer;
begin
  n := Length(Datos);

  if n = 0 then
     begin
          Result := 0;
          Exit;
     end;
  Ordenar(Datos);
  mitad := n div 2;

  if n mod 2 = 1 then
     begin
          Result := Datos[Mitad];
     end;
  else
     begin
       Result := (Datos[Mitad-1] + Datos[Mitad]) / 2;
     end;
end;

function TTForm1.CalcularDesviacion(Datos: TArreglo1): Double;
var
  i: Integer;
  Media, Suma: Double;

begin
  if Length(Datos) <= 1 then
     begin
          Result := 0;
          Exit,
     end;
  Media := CalcularMedia(Datos);
  Suma := 0;

  for i := 0 to Length(Datos) - 1 do
  begin
    Suma := Suma + Sqr(Datos[i] - Media);
  end;
  Result := Sqrt(Suma / (Length(Datos) - 1));
end;

procedure TTForm1.Ordenar(var Datos: TArreglo1);
var
  i, j: Integer;
  aux: Double;
begin
  for i := 0 to Length(Datos) - 2 do
  begin
    for j :=i + 1 to Length(Datos) - 1 do
    begin
      if Datos[i] > Datos[j] then
         begin
              aux := Datos[i];
              Datos[i] := Datos[j];
              Datos[j] := aux;
         end;
    end;
  end;
end;

procedure TTForm1.CopiarNormalizado;
begin

end;

end.

unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Grids, Math;

type

  TArreglo1 = array of Double;
  { TTForm1 }

  TTForm1 = class(TForm)
    ButtonNormEscala: TButton;

    ButtonCargar: TButton;
    ButtonGuardar: TButton;
    ButtonNormZscore: TButton;
    ButtonNormMinMaX: TButton;
    ButtonCalcular: TButton;
    ButtonNormEscala: TButton;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    StringGridNorm: TStringGrid;
    StringGridStats: TStringGrid;
    StringGridDatos: TStringGrid;


    procedure ButtonCargarClick(Sender: TObject);
    procedure ButtonCalcularClick(Sender: TObject);
    procedure ButtonNormZscoreClick(Sender: TObject);
    procedure ButtonNormMinMaxClick(Sender: TObject);
    procedure ButtonNormEscalaClick(Sender: TObject);
    procedure ButtonGuardarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);

  private
    ArchivoCargado: Boolean;
    function ColumnaNum(Col: Integer): Boolean;
    function ObtenerColumna(Col: Integer): TArreglo1;
    function CalcularMedia(Datos: TArreglo1): Double;
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

             StringGridNorm.Clear;
             StringGridNorm.RowCount := 0;
             StringGridNorm.ColCount := 0;

             ArchivoCargado := True;
             ShowMessage('Archivo cargado');
        end;
end;

procedure TTForm1.ButtonNormEscalaClick(Sender: TObject);
var
  col, fila, i: integer;
  datos: TArreglo;
    max, divi, valor, norm: Double;
begin
     if ArchivoCargado = False then
        begin
             ShowMessage('Primero se debe de cargar el archivo');
             Exit;
        end;

end;

procedure TTForm1.ButtonCalcularClick(Sender: TObject);
var
  Col, FilaE: Integer;
  Datos: TArreglo1;
  Media, Desv: Double;
begin
  if ArchivoCargado = False then
  begin
    ShowMessage('Primero se debe de cargar el archivo');
    Exit;
  end;

  StringGridStats.Clear;

  StringGridStats.ColCount := 3;
  StringGridStats.RowCount := 1;

  StringGridStats.Cells[0,0] := 'Columna';
  StringGridStats.Cells[1,0] := 'Media';
  StringGridStats.Cells[2,0] := 'Desviacion';

  FilaE := 1;

  for Col := 0 to StringGridDatos.ColCount - 2 do
  begin
    if ColumnaNum(Col) then
    begin
      Datos := ObtenerColumna(Col);

      if Length(Datos) > 0 then
      begin
        Media := CalcularMedia(Datos);
        Desv := CalcularDesviacion(Datos);

        StringGridStats.RowCount := FilaE + 1;

        StringGridStats.Cells[0, FilaE] := 'Col ' + IntToStr(Col+1);
        StringGridStats.Cells[1, FilaE] := FloatToStrF(Media, ffFixed, 10, 4);
        StringGridStats.Cells[2, FilaE] := FloatToStrF(Desv, ffFixed, 10, 4);

        Inc(FilaE);
      end;
    end;
  end;

end;

procedure TTForm1.ButtonNormZscoreClick(Sender: TObject);
var
  col, fila: Integer;
  datos: TArreglo1;
  media, desv, valor, norm: Double;
  FS: TFormatSettings;
begin
  if ArchivoCargado = False then
     begin
          ShowMessage('Primero se debe de cargar el archivo');
          Exit;
     end;
  FS := DefaultFormatSettings;
  FS.DecimalSeparator := '.';

  CopiarNormalizado;
  for col := 0 to StringGridDatos.ColCount - 1 do
  begin
    if ColumnaNum(col) then
       begin
            datos := ObtenerColumna(col);
            media := CalcularMedia(datos);
            desv := CalcularDesviacion(datos);

            for fila := 1 to StringGridDatos.RowCount - 1 do
            begin
              if TryStrToFloat(Trim(StringGridDatos.Cells[Col, Fila]), valor, FS) then
                 begin
                      if desv = 0 then
                         norm := 0
                      else
                         norm := (valor - media) / desv;
                      StringGridNorm.Cells[Col,Fila] := FloatToStrF(norm, ffFixed, 10, 4);
                 end;
            end;
       end;
  end;
  ShowMessage('Normalizacion con Z-Score Realizado');
end;

procedure TTForm1.ButtonNormMinMaxClick(Sender: TObject);
var
  col, fila, i: Integer;
  datos: TArreglo1;
  min, max, val, norm: double;
  FS: TFormatSettings;
begin
  if ArchivoCargado = False then
  begin
    ShowMessage('Primero se debe de cargar el archivo');
    Exit;
  end;

  FS := DefaultFormatSettings;
  FS.DecimalSeparator := '.';

  CopiarNormalizado;

  for col := 0 to StringGridDatos.ColCount - 2 do
  begin
    if ColumnaNum(col) then
    begin
      datos := ObtenerColumna(col);

      if Length(datos) = 0 then
        Continue;

      min := datos[0];
      max := datos[0];

      for i := 0 to Length(datos) - 1 do
      begin
        if datos[i] < min then
          min := datos[i];

        if datos[i] > max then
          max := datos[i];
      end;

      for fila := 1 to StringGridDatos.RowCount - 1 do
      begin
        if TryStrToFloat(Trim(StringGridDatos.Cells[col, fila]), val, FS) then
        begin
          if max - min = 0 then
            norm := 0
          else
            norm := (val - min) / (max - min);

          StringGridNorm.Cells[col, fila] := FloatToStrF(norm, ffFixed, 10, 4);
        end;
      end;
    end;
  end;
  ShowMessage('Normalizacion Min-Max realizada');
end;
procedure TTForm1.ButtonGuardarClick(Sender: TObject);
begin

  if StringGridNorm.RowCount <= 1 then
  begin
    ShowMessage('No hay datos normalizados para guardar');
    Exit;
  end;

  if SaveDialog1.Execute then
  begin
    StringGridNorm.SaveToCSVFile(SaveDialog1.FileName);
    ShowMessage('Archivo normalizado guardado');
  end;
end;

procedure TTForm1.FormCreate(Sender: TObject);
begin

  ArchivoCargado := False;

  ButtonCalcular.OnClick := @ButtonCalcularClick;
  ButtonGuardar.OnClick := @ButtonGuardarClick;
  ButtonNormMinMax.OnClick := @ButtonNormMinMaxClick;
  ButtonNormZscore.OnClick := @ButtonNormZscoreClick;
  ButtonNormEscala.OnClick := @ButtonNormEscala;

  StringGridDatos.FixedRows := 0;
  StringGridStats.FixedRows := 0;
  StringGridNorm.FixedRows := 0;

  StringGridStats.ColCount := 3;
  StringGridStats.RowCount := 1;

  StringGridStats.Cells[0, 0] := 'Columna';
  StringGridStats.Cells[1, 0] := 'Media';
  StringGridStats.Cells[2, 0] := 'Desviacion';
end;

function TTForm1.ColumnaNum(Col: Integer): Boolean;
begin
  Result := False;

  if StringGridDatos.RowCount > 0 then
  begin
    Result := (Trim(StringGridDatos.Cells[Col, 0]) = '0') and
              (Col < StringGridDatos.ColCount - 1);
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
  for i := 0 to Length(Datos) - 1 do
  begin
    Suma := Suma + Datos[i];
  end;

  Result := Suma / Length(Datos);
end;

function TTForm1.CalcularDesviacion(Datos: TArreglo1): Double;
var
  i: Integer;
  Media, Suma: Double;

begin
  if Length(Datos) <= 1 then
     begin
          Result := 0;
          Exit;
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
var
  col, fila: Integer;
begin
  StringGridNorm.ColCount := StringGridDatos.ColCount;
  StringGridNorm.RowCount := StringGridDatos.RowCount;

  for col := 0 to StringGridDatos.ColCount - 1 do
  begin
    for fila := 0 to StringGridDatos.RowCount - 1 do
    begin
      StringGridNorm.Cells[col, fila] := StringGridDatos.Cells[col,fila];
    end;
  end;
end;

end.

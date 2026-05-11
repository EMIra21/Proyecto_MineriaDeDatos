unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Grids, Spin,
  Menus, ComCtrls, TAGraph, Math, TASeries, TATypes;

type

  TArreglo1 = array of Double;
  { TTForm1 }

  TTForm1 = class(TForm)
    ButtonBarras: TButton;
    ButtonBoxPlot: TButton;
    ButtonCalcular: TButton;
    ButtonCargar: TButton;
    ButtonDispersion: TButton;
    ButtonGuardar: TButton;
    ButtonNormEscala: TButton;
    ButtonNormMinMaX: TButton;
    ButtonNormZscore: TButton;
    ChartBarras: TChart;
    ChartBoxPlot: TChart;
    ChartDispersion: TChart;
    FloatSpinMax: TFloatSpinEdit;

    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    OpenDialog1: TOpenDialog;
    PageControl1: TPageControl;
    Selector: TPageControl;
    SaveDialog1: TSaveDialog;
    Archivo: TTabSheet;
    Grafica: TTabSheet;
    SpinEdit1: TSpinEdit;
    SpinEdit2: TSpinEdit;
    SpinEdit3: TSpinEdit;
    StaticText1: TStaticText;
    StringGridDatos: TStringGrid;
    StringGridNorm: TStringGrid;
    StringGridStats: TStringGrid;


    procedure ButtonBarrasClick(Sender: TObject);
    procedure ButtonBoxPlotClick(Sender: TObject);
    procedure ButtonCargarClick(Sender: TObject);
    procedure ButtonCalcularClick(Sender: TObject);
    procedure ButtonDispersionClick(Sender: TObject);
    procedure ButtonNormZscoreClick(Sender: TObject);
    procedure ButtonNormMinMaxClick(Sender: TObject);
    procedure ButtonNormEscalaClick(Sender: TObject);
    procedure ButtonGuardarClick(Sender: TObject);
    procedure ButtonChartBoxPlotClick(Sender: TObject);
    procedure ButtonChartDispersionClick(Sender: TObject);
    procedure ButtonChartBarrasClick(Sender: TObject);
    procedure FloatSpinMaxChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure SelectorChange(Sender: TObject);

  private
    ArchivoCargado: Boolean;
    function ColumnaNum(Col: Integer): Boolean;
    function ObtenerColumna(Col: Integer): TArreglo1;
    function CalcularMedia(Datos: TArreglo1): Double;
    function CalcularDesviacion(Datos: TArreglo1): Double;
    function Percentil(Datos: TArreglo1; p: Double): Double;
    procedure Ordenar(var Datos: TArreglo1);
    procedure CopiarNormalizado;
    procedure GraficarBarras;
    procedure GraficarDispersion(x, y: Integer);
    procedure GraficarBoxPlot(col: Integer);
    procedure AgregarLinea(Chart: Tchart; x1, y1, x2, y2: Double);



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

procedure TTForm1.ButtonBoxPlotClick(Sender: TObject);
begin
  GraficarBoxPlot(SpinEdit3.Value - 1);
end;

procedure TTForm1.ButtonBarrasClick(Sender: TObject);
begin
  GraficarBarras;
end;

procedure TTForm1.ButtonNormEscalaClick(Sender: TObject);
var
  col, fila, i: integer;
  datos: TArreglo1;
  max, divi, valor, norm: Double;
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
               max := Abs(datos[0]);
               for i := 0 to Length(datos) -1 do
               begin
                 if Abs(datos[i]) > max then max := Abs(datos[i]);
               end;

               divi := 1;

               while max / divi >= 1 do
               begin
                 divi := divi * 10
               end;

               for fila := 1 to StringGridDatos.RowCount - 1 do
               begin
                 if TryStrToFloat(Trim(StringGridDatos.Cells[col, fila]), valor, FS) then
                    begin
                         norm := valor / divi;
                         StringGridNorm.Cells[col, fila] := FloatToStrF(norm, ffFixed , 10, 4);
                    end;
               end;

          end;
     end;
     ShowMessage('Normalizacion por escalamiento decimal realizada');

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

procedure TTForm1.ButtonDispersionClick(Sender: TObject);
begin
  GraficarDispersion(SpinEdit1.Value - 1, SpinEdit2.Value - 1);
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
  maxMod: double;
begin
  if ArchivoCargado = False then
  begin
    ShowMessage('Primero se debe de cargar el archivo');
    Exit;
  end;

  maxMod := FloatSpinMax.Value;

  if maxMod <= 0 then
  begin
    ShowMessage('Valor invalido');
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
            norm := (val - min) / (max - min) * maxMod;

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

procedure TTForm1.ButtonChartBoxPlotClick(Sender: TObject);
begin

end;

procedure TTForm1.ButtonChartDispersionClick(Sender: TObject);
begin

end;

procedure TTForm1.ButtonChartBarrasClick(Sender: TObject);
begin

end;

procedure TTForm1.FloatSpinMaxChange(Sender: TObject);
begin

end;

procedure TTForm1.FormCreate(Sender: TObject);
begin

  ArchivoCargado := False;

  ButtonCalcular.OnClick := @ButtonCalcularClick;
  ButtonGuardar.OnClick := @ButtonGuardarClick;
  ButtonNormMinMax.OnClick := @ButtonNormMinMaxClick;
  ButtonNormZscore.OnClick := @ButtonNormZscoreClick;
  ButtonNormEscala.OnClick := @ButtonNormEscalaClick;
  ButtonBoxPlot.OnClick := @ButtonBoxPlotClick;
  ButtonDispersion.OnClick := @ButtonDispersionClick;
  ButtonBarras.OnClick := @ButtonBarrasClick;

  FloatSpinMax.Value := 1;

  StringGridDatos.FixedRows := 0;
  StringGridStats.FixedRows := 0;
  StringGridNorm.FixedRows := 0;

  StringGridStats.ColCount := 3;
  StringGridStats.RowCount := 1;

  SpinEdit1.Value := 1;
  SpinEdit2.Value := 2;
  SpinEdit3.Value := 1;

  StringGridStats.Cells[0, 0] := 'Columna';
  StringGridStats.Cells[1, 0] := 'Media';
  StringGridStats.Cells[2, 0] := 'Desviacion';
end;

procedure TTForm1.MenuItem1Click(Sender: TObject);
begin

end;

procedure TTForm1.PageControl1Change(Sender: TObject);
begin

end;

procedure TTForm1.SelectorChange(Sender: TObject);
begin

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

function TTForm1.Percentil(Datos: TArreglo1; p: Double): Double;
var
  posReal: Double;
  posInf, posUp: Integer;
begin
  if Length(Datos) = 0 then
     begin
          Result := 0;
          Exit;
     end;

     PosReal := (p / 100) * (Length(Datos) - 1);
     posInf := Floor(PosReal);
     posUp := Ceil(PosReal);
      if posInf = posUp then
          Result := Datos[posInf]
      else
          Result := Datos[posInf] + (Datos[posUp] - Datos[posInf]) * (PosReal - posInf);
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

procedure TTForm1.GraficarBarras;
var
  serie: TBarSeries;
  conteo: array of integer;
  fila, clase, numClases, colClases, i: Integer;
begin
  if ArchivoCargado = False then
    begin
      ShowMessage('Primero se debe cargar el archivo');
      Exit
    end;
  colClases := StringGridDatos.ColCount - 1;
  numClases := StrToIntDef(Trim(StringGridDatos.Cells[colClases, 0]), 0);
  if numClases <= 0 then
    begin
      ShowMessage('No se puede obtener el numero de clases');
      Exit;
    end;
  SetLength(conteo, numClases);
  for i := 0 to numClases - 1 do
    conteo[i] := 0;
  for fila := 1 to StringGridDatos.RowCount - 1 do
  begin
    clase := StrToIntDef(Trim(StringGridDatos.Cells[colClases, fila]), -1);
    if (clase >= 0) and (clase < numClases) then
      Inc(conteo[clase]);
  end;
  ChartBarras.ClearSeries;
  serie := TBarSeries.Create(ChartBarras);
  ChartBarras.AddSeries(serie);
  for i := 0 to numClases - 1 do
  begin
    Serie.Add(conteo[i], 'Clase' + IntToStr(i));
  end;
  ChartBarras.Title.Text.Clear;
  ChartBarras.Title.Text.Add('Distribucion de clases');
  ChartBarras.BottomAxis.Title.Caption := 'Clase';
  ChartBarras.LeftAxis.Title.Caption := 'Cantidad';

end;

procedure TTForm1.GraficarDispersion(x, y: Integer);
var
  serie: TLineSeries;
  fila: Integer;
  valorX, valorY: Double;
  FS: TFormatSettings;
begin
  if ArchivoCargado = False then
  begin
    ShowMessage('Primero se debe cargar el archivo');
    Exit;
  end;

  if (x < 0) or (y < 0) or
     (x >= StringGridDatos.ColCount - 1) or
     (y >= StringGridDatos.ColCount - 1) then
  begin
    ShowMessage('Columnas fuera de rango');
    Exit;
  end;

  if (not ColumnaNum(x)) or (not ColumnaNum(y)) then
  begin
    ShowMessage('Ambas columnas deben ser numericas');
    Exit;
  end;

  FS := DefaultFormatSettings;
  FS.DecimalSeparator := '.';

  chartDispersion.ClearSeries;

  serie := TLineSeries.Create(chartDispersion);
  serie.LinePen.Style := psClear;
  serie.Pointer.Visible := True;
  serie.Pointer.Style := psCircle;
  serie.Pointer.HorizSize := 4;
  serie.Pointer.VertSize := 4;

  chartDispersion.AddSeries(serie);

  for Fila := 1 to StringGridDatos.RowCount - 1 do
  begin
    if TryStrToFloat(Trim(StringGridDatos.Cells[x, Fila]), valorX, FS) and TryStrToFloat(Trim(StringGridDatos.Cells[y, Fila]), valorY, FS) then
    begin
      serie.AddXY(valorX, valorY);
    end;
  end;

  chartDispersion.Title.Text.Clear;
  chartDispersion.Title.Text.Add('Grafica de dispersion');

  chartDispersion.BottomAxis.Title.Caption := 'Columna ' + IntToStr(x + 1);
  chartDispersion.LeftAxis.Title.Caption := 'Columna ' + IntToStr(y + 1);
end;

procedure TTForm1.GraficarBoxPlot(col: Integer);
var
  datos: TArreglo1;
  minimo, q1, mediana, q3, maximo: Double;
  x: Double;
begin
  if ArchivoCargado = False then
    begin
        ShowMessage('Primero se debe cargar el archivo');
        Exit;
    end;
  if (col < 0) or (col >= StringGridDatos.ColCount) then
    begin
      ShowMessage('Columna inválida');
      Exit;
    end;
  if not ColumnaNum(col) then
    begin
      ShowMessage('La columna seleccionada no es numérica');
      Exit;
    end;
  datos := ObtenerColumna(col);

  minimo := Datos[0];
  maximo := Datos[Length(Datos) - 1];
  mediana := Percentil(Datos, 50);
  q1 := Percentil(Datos, 25);
  q3 := Percentil(Datos, 75);

  chartBoxPlot.ClearSeries;
  x := 1;

  AgregarLinea(ChartBoxPlot, x - 0.3, q1, x + 0.3, q1);
  AgregarLinea(ChartBoxPlot, x + 0.3, q1, x + 0.3, q3);
  AgregarLinea(ChartBoxPlot, x + 0.3, q3, x - 0.3, q3);
  AgregarLinea(ChartBoxPlot, x - 0.3, q3, x - 0.3, q1);
  AgregarLinea(ChartBoxPlot, x - 0.3, mediana, x + 0.3, mediana);
  AgregarLinea(ChartBoxPlot, x, minimo, x, q1);
  AgregarLinea(ChartBoxPlot, x, q3, x, maximo);
  AgregarLinea(ChartBoxPlot, x - 0.2, minimo, x + 0.2, minimo);
  AgregarLinea(ChartBoxPlot, x - 0.2, maximo, x + 0.2, maximo);

  chartBoxPlot.Title.Text.Clear;
  chartBoxPlot.Title.Text.Add('Box Plot Columna ' + IntToStr(col + 1));
  chartBoxPlot.BottomAxis.Title.Caption := 'Atributo';
  chartBoxPlot.LeftAxis.Title.Caption := 'Valor';

end;

procedure TTForm1.AgregarLinea(Chart: Tchart; x1, y1, x2, y2: Double);
var
  serie: TLineSeries;
begin
  Serie := TLineSeries.Create(Chart);
  Serie.Pointer.Visible := False;
  Serie.AddXY(x1, y1);
  Serie.AddXY(x2, y2);
  Chart.AddSeries(Serie);
end;

end.


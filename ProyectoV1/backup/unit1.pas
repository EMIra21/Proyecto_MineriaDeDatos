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
begin

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
begin

end;

function TTForm1.CalcularMediana(Datos: TArreglo1): Double;
begin

end;

function TTForm1.CalcularDesviacion(Datos: TArreglo1): Double;
begin

end;

procedure TTForm1.Ordenar(var Datos: TArreglo1);
begin

end;

procedure TTForm1.CopiarNormalizado;
begin

end;

end.

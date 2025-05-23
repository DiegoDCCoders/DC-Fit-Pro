unit Frame.Exercicio;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Controls.Presentation;

type
  TFrameExercicio = class(TFrame)
    rectSugestao: TRectangle;
    lblTitulo: TLabel;
    ImgOpcoes: TImage;
    lblSubTitulo: TLabel;
    ImgExcluir: TImage;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.fmx}

end.

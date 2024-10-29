unit Frame.FichaExercicio;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Controls.Presentation;

type
  TFrameFichaExercicio = class(TFrame)
    rectSugestao: TRectangle;
    lblSubTitulo: TLabel;
    Image4: TImage;
    lblTitulo: TLabel;
    Rectangle1: TRectangle;
    chkConcluido: TCheckBox;
    procedure chkConcluidoChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.fmx}

uses DataModule.Global, UnitTreinoCad;

procedure TFrameFichaExercicio.chkConcluidoChange(Sender: TObject);
begin
    DmGlobal.MarcarExercicioConcluido(chkConcluido.tag, chkConcluido.IsChecked);

    // Calcular Progresso...
    FrmTreinoCad.CalcularProgresso;
end;

end.

unit unitCloneTreino;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects, FMX.Layouts, uFancyDialog;

type
  TExecuteOnClose = procedure of Object;

  TfrmCloneTreino = class(TForm)
    lblTitulo: TLabel;
    imgFechar: TImage;
    imgSalvar: TImage;
    C: TLayout;
    Label7: TLabel;
    rectSugestao: TRectangle;
    lblAluno: TLabel;
    imgSugestao: TImage;
    procedure rectSugestaoClick(Sender: TObject);
    procedure imgFecharClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure imgSalvarClick(Sender: TObject);
  private
    { Private declarations }
    fancy : TFancyDialog;
    FExecuteOnClose: TExecuteOnClose;
    procedure ClonarTreino(Sender: TObject);
  public
    { Public declarations }
    property ExecuteOnClose : TExecuteOnClose read FExecuteOnClose write FExecuteOnClose;
  end;

var
  frmCloneTreino: TfrmCloneTreino;

implementation

{$R *.fmx}

uses UnitListaAlunos, uSession, DataModule.Global;

procedure TfrmCloneTreino.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := TCloseAction.cafree;
  frmCloneTreino := nil;
end;

procedure TfrmCloneTreino.FormCreate(Sender: TObject);
begin
  fancy := TFancyDialog.Create(frmCloneTreino);
end;

procedure TfrmCloneTreino.FormDestroy(Sender: TObject);
begin
  fancy.DisposeOf;
end;

procedure TfrmCloneTreino.imgFecharClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmCloneTreino.imgSalvarClick(Sender: TObject);
begin
  if TSession.ID_ALUNO_CLONE <1 then
  begin
    fancy.Show(TIconDialog.Warning, 'Aviso','Necessário pesquisar o aluno.', 'OK');
    exit;
  end;

  fancy.Show(TIconDialog.Question, 'Aviso','Deseja efetivar a clonagem?', 'Sim', ClonarTreino, 'Não');
end;

procedure TfrmCloneTreino.ClonarTreino(Sender: TObject);
begin
  try
    DmGlobal.ExcluirTodosTreinosOnline(TSession.ID_ALUNO_CLONE);

    DmGlobal.ClonarTreinoOnline(TSession.ID_ALUNO, TSession.ID_ALUNO_CLONE, TSession.ID_USUARIO);

    if Assigned(ExecuteOnClose) then
     ExecuteOnClose;

     close;

  except on ex:exception do
    fancy.Show(TIconDialog.Error, 'Aviso', ex.Message, 'OK');

  end;
end;

procedure TfrmCloneTreino.rectSugestaoClick(Sender: TObject);
begin
  if NOT Assigned(frmListaAlunos) then
        Application.CreateForm(TfrmListaAlunos, frmListaAlunos);

  frmListaAlunos.clone := True;

  frmListaAlunos.ShowModal(procedure(ModalResult: TModalResult)
  begin
    lblAluno.Text := TSession.ALUNO_CLONE;
  end);
end;

end.

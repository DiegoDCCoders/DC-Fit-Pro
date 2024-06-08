unit UnitCadastraTreino;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.ListBox, FMX.Objects, FMX.Controls.Presentation, FMX.StdCtrls, uFancyDialog,
  FMX.Advertising;

type
  TfrmCadastraTreino = class(TForm)
    Layout1: TLayout;
    Label7: TLabel;
    rectSugestao: TRectangle;
    lblAluno: TLabel;
    imgSugestao: TImage;
    lbTreinos: TListBox;
    lytToolbar: TLayout;
    lblTitulo: TLabel;
    imgFechar: TImage;
    rectBtnLogin: TRectangle;
    btnIncluir: TSpeedButton;
    recClonar: TRectangle;
    btnClonar: TSpeedButton;
    procedure rectSugestaoClick(Sender: TObject);
    procedure imgFecharClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure lbTreinosItemClick(const Sender: TCustomListBox;
      const Item: TListBoxItem);
    procedure btnIncluirClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnClonarClick(Sender: TObject);
  private
    fancy : TFancyDialog;
    Fid_aluno: integer;
    FnomeAluno: String;
    procedure AddTreino(id_treino: integer; titulo, subtitulo: string);
    procedure CarregarExercicios;
    procedure ThreadExerciciosTerminate(Sender: TObject);
    { Private declarations }
  public
    { Public declarations }
    property id_aluno: integer read Fid_aluno write Fid_aluno;
    property nomeAluno: String read FnomeAluno write FnomeAluno;
  end;

var
  frmCadastraTreino: TfrmCadastraTreino;

implementation

{$R *.fmx}

uses Frame.Treino, uLoading, uSession, DataModule.Global,
  UnitCadastraTreinoAluno, UnitListaAlunos, unitCloneTreino;

procedure TfrmCadastraTreino.btnClonarClick(Sender: TObject);
begin
  if TSession.ID_ALUNO <1 then
  begin
    fancy.Show(TIconDialog.Warning, 'Aviso','Necessário pesquisar o aluno.', 'OK');
    exit;
  end;

  if NOT Assigned(FrmCloneTreino) then
        Application.CreateForm(TFrmCloneTreino, FrmCloneTreino);

  FrmCloneTreino.ShowModal(procedure(ModalResult: TModalResult)
  begin
    CarregarExercicios;
  end);
end;

procedure TfrmCadastraTreino.btnIncluirClick(Sender: TObject);
begin
  if TSession.ID_ALUNO <1 then
  begin
    fancy.Show(TIconDialog.Warning, 'Aviso','Necessário pesquisar o aluno.', 'OK');
    exit;
  end;

  if NOT Assigned(FrmCadastraTreinoAluno) then
        Application.CreateForm(TFrmCadastraTreinoAluno, FrmCadastraTreinoAluno);

    FrmCadastraTreinoAluno.id_treino := 0;
    FrmCadastraTreinoAluno.id_aluno  := TSession.ID_ALUNO; //TSession.ID_ALUNO;
    FrmCadastraTreinoAluno.Alteracao := False;
    //DmGlobal.ExcluirTreinoExercicio;

     FrmCadastraTreinoAluno.ShowModal(procedure(ModalResult: TModalResult)
    begin
      CarregarExercicios;
    end);
end;

procedure TfrmCadastraTreino.CarregarExercicios;
var
    t: TThread;
begin
  lbTreinos.Items.Clear;

  TLoading.Show(frmCadastraTreino, '');

  t := TThread.CreateAnonymousThread(procedure
  begin
      lblAluno.Text := TSession.ALUNO;
      DmGlobal.ListarTreinoUsuarioOnline(TSession.ID_ALUNO); //(TSession.ID_ALUNO);

  end);

  t.OnTerminate := ThreadExerciciosTerminate;
  t.Start;

end;

procedure TfrmCadastraTreino.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := TCloseAction.cafree;
  frmCadastraTreino := nil;
end;

procedure TfrmCadastraTreino.FormCreate(Sender: TObject);
begin
  //BannerBooton.AdUnitID := 'ca-app-pub-2114109645415332/5959506676';
  fancy := TFancyDialog.Create(frmCadastraTreino);
end;

procedure TfrmCadastraTreino.FormDestroy(Sender: TObject);
begin
  fancy.DisposeOf;
end;

procedure TfrmCadastraTreino.FormShow(Sender: TObject);
begin
  //BannerBooton.LoadAd;
end;

procedure TfrmCadastraTreino.imgFecharClick(Sender: TObject);
begin
  close;
end;

procedure TfrmCadastraTreino.lbTreinosItemClick(const Sender: TCustomListBox;
  const Item: TListBoxItem);
begin
  if NOT Assigned(FrmCadastraTreinoAluno) then
        Application.CreateForm(TFrmCadastraTreinoAluno, FrmCadastraTreinoAluno);

    FrmCadastraTreinoAluno.id_treino := Item.Tag;
    FrmCadastraTreinoAluno.id_aluno  := TSession.ID_ALUNO; //TSession.ID_ALUNO;
    FrmCadastraTreinoAluno.Alteracao := True;

    FrmCadastraTreinoAluno.ShowModal(procedure(ModalResult: TModalResult)
    begin
      CarregarExercicios;
    end);
end;

procedure TfrmCadastraTreino.rectSugestaoClick(Sender: TObject);
begin
  if NOT Assigned(frmListaAlunos) then
        Application.CreateForm(TfrmListaAlunos, frmListaAlunos);

  frmListaAlunos.ShowModal(procedure(ModalResult: TModalResult)
  begin
    try
      CarregarExercicios;
    except
      CarregarExercicios;
  end;
  end);


end;

procedure TfrmCadastraTreino.ThreadExerciciosTerminate(Sender: TObject);
begin
  with DmGlobal.tabTreinos do
  begin
      if recordcount = 0 then
      begin
        TLoading.Hide;
        exit;
      end;


      while NOT EOF do
      begin
        AddTreino(fieldbyname('id_treino').asinteger,
                  fieldbyname('treino').asstring,
                  fieldbyname('descr_treino').asstring);

        Next;
      end;
  end;

  TLoading.Hide;

end;

procedure TfrmCadastraTreino.AddTreino(id_treino: integer;
                                  titulo, subtitulo: string);
var
    item: TListBoxItem;
    frame: TFrameTreino;
begin

    item := TListBoxItem.Create(lbTreinos);
    item.Selectable := false;
    item.Text := '';
    item.Height := 90;
    item.Tag := id_treino;
    item.tagstring := titulo;

    // Frame...
    frame := TFrameTreino.Create(item);
    frame.lblTitulo.Text := titulo;
    frame.lblSubtitulo.Text := subtitulo;

    item.AddObject(frame);

    lbTreinos.AddObject(item);
end;

end.

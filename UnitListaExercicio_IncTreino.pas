unit UnitListaExercicio_IncTreino;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, FMX.Edit, FMX.ListBox,
  FMX.Advertising, uFancyDialog;

type
  TfrmListaExercicio_IncTreino = class(TForm)
    lytToolbar: TLayout;
    lblTitulo: TLabel;
    imgFechar: TImage;
    RecPesquisar: TRectangle;
    recBusca: TRectangle;
    Label1: TLabel;
    edtBusca: TEdit;
    lbExercicios: TListBox;
    recDuracao: TRectangle;
    EdtDuracao: TEdit;
    imgOk: TImage;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure imgFecharClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure recBuscaClick(Sender: TObject);
    procedure lbExerciciosItemClick(const Sender: TCustomListBox;
      const Item: TListBoxItem);
    procedure imgOkClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    fancy : TFancyDialog;
    Fdescricao: String;
    Fid_treino: integer;
    Fdia_semana: integer;
    Fnome: String;
    Fid_aluno: integer;
    Fid_exercicio: integer;
    Fexercicio: String;
    { Private declarations }
    procedure CarregarExercicios;
    procedure AddExercicio(id_exercicio: integer; titulo, subtitulo: string);
    procedure ThreadExerciciosTerminate(Sender: TObject);
  public
    { Public declarations }
    property id_treino: integer read Fid_treino write Fid_treino;
    property id_exercicio: integer read Fid_exercicio write Fid_exercicio;
    property id_aluno: integer read Fid_aluno write Fid_aluno;
    property nome: String read Fnome write Fnome;
    property exercicio: String read Fexercicio write Fexercicio;
    property descricao: String read Fdescricao write Fdescricao;
    property dia_semana: integer read Fdia_semana write Fdia_semana;
  end;

var
  frmListaExercicio_IncTreino: TfrmListaExercicio_IncTreino;

implementation

{$R *.fmx}

uses Frame.Exercicio, uLoading, DataModule.Global, UnitExercicio;

{ TfrmListaExercicio_IncTreino }

procedure TfrmListaExercicio_IncTreino.AddExercicio(id_exercicio: integer; titulo,
  subtitulo: string);
var
    item: TListBoxItem;
    frame: TFrameExercicio;
begin
    item := TListBoxItem.Create(lbExercicios);
    item.Selectable := false;
    item.Text := '';
    item.Height := 180;
    item.Tag := id_exercicio;
    item.tagstring := titulo;

    // Frame...
    frame := TFrameExercicio.Create(item);
    frame.lblTitulo.Text := titulo;
    frame.lblSubtitulo.Text := subtitulo;

    item.AddObject(frame);

    lbExercicios.AddObject(item);
end;

procedure TfrmListaExercicio_IncTreino.CarregarExercicios;
var
    t: TThread;
begin

  TLoading.Show(frmListaExercicio_IncTreino, '');

  t := TThread.CreateAnonymousThread(procedure
  begin
      DmGlobal.ExercicioOnline(edtBusca.Text);

  end);

  t.OnTerminate := ThreadExerciciosTerminate;
  t.Start;

end;

procedure TfrmListaExercicio_IncTreino.ThreadExerciciosTerminate(Sender: TObject);
begin
  with DmGlobal.tabExercicios do
    begin
        if recordcount = 0 then
        begin
           TLoading.Hide;
           exit;
        end;

        while NOT EOF do
        begin
          //sleep(300);

          AddExercicio(fieldbyname('id_exercicio').asinteger,
                       fieldbyname('nome').asstring,
                       fieldbyname('descricao').asstring);

          Next;
        end;
    end;
  TLoading.Hide;

end;

procedure TfrmListaExercicio_IncTreino.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := TCloseAction.caFree;
  frmListaExercicio_IncTreino := nil;
end;

procedure TfrmListaExercicio_IncTreino.FormCreate(Sender: TObject);
begin
  //BannerBooton.AdUnitID := 'ca-app-pub-2114109645415332/3113905384';
  RecDuracao.Visible := False;

  fancy := TFancyDialog.Create(frmListaExercicio_IncTreino);
end;

procedure TfrmListaExercicio_IncTreino.FormDestroy(Sender: TObject);
begin
  fancy.DisposeOf;
end;

procedure TfrmListaExercicio_IncTreino.FormShow(Sender: TObject);
begin
  //BannerBooton.LoadAd;
  CarregarExercicios;
end;

procedure TfrmListaExercicio_IncTreino.imgFecharClick(Sender: TObject);
begin
  close;
end;

procedure TfrmListaExercicio_IncTreino.imgOkClick(Sender: TObject);
begin
  {if trim(EdtDuracao.Text) = '' then
  begin
    fancy.Show(TIconDialog.Warning, 'Aviso','Informe a duração do treino.', 'OK');
    exit;
  end; }

  if id_exercicio <= 0 then
    exit;

   DmGlobal.InserirTreinoExercicio(id_treino,
                                  nome,
                                  descricao,
                                  dia_semana,
                                  id_exercicio,
                                  exercicio,
                                  '',
                                  edtDuracao.Text,
                                  '',
                                  True);
   RecDuracao.Visible   := False;
   RecPesquisar.Visible := True;
   close;
end;

procedure TfrmListaExercicio_IncTreino.lbExerciciosItemClick(
  const Sender: TCustomListBox; const Item: TListBoxItem);
begin
  id_exercicio := Item.Tag;
  exercicio    := Item.tagstring;

  RecDuracao.Visible   := True;
  RecPesquisar.Visible := False;
end;

procedure TfrmListaExercicio_IncTreino.recBuscaClick(Sender: TObject);
begin
  lbExercicios.Items.Clear;
  CarregarExercicios;
end;

end.

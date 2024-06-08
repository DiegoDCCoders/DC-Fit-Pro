unit UnitCadastraTreinoAluno;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, uCombobox, FMX.ListBox,
  uFancyDialog, FMX.Advertising;

type
  TExecuteOnClose = procedure of Object;

  TFrmCadastraTreinoAluno = class(TForm)
    lblTitulo: TLabel;
    imgSalvar: TImage;
    imgFechar: TImage;
    Layout1: TLayout;
    lblExib1: TLabel;
    lblDescricao: TLabel;
    Label1: TLabel;
    lblDiaSemana: TLabel;
    Layout3: TLayout;
    Layout4: TLayout;
    lbExercicios: TListBox;
    imgAdicionar: TImage;
    Layout2: TLayout;
    imgExcluirTreino: TImage;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure lblDescricaoClick(Sender: TObject);
    procedure lblDiaSemanaClick(Sender: TObject);
    procedure imgFecharClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure imgAdicionarClick(Sender: TObject);
    procedure imgSalvarClick(Sender: TObject);
    procedure lbExerciciosItemClick(const Sender: TCustomListBox;
      const Item: TListBoxItem);
    procedure imgExcluirTreinoClick(Sender: TObject);
  private
    { Private declarations }
    fancy : TFancyDialog;
    combo : TCustomCombo;
    Fdescricao: String;
    Fid_treino: integer;
    Fdia_semana: integer;
    Fnome: String;
    Falteracao: boolean;
    Fexcluir: Boolean;
    Fid_aluno: integer;
    FExecuteOnClose: TExecuteOnClose;
    Fid_exercicio: integer;
    procedure IncluirTreinoOnline( id_usuario, dia_semana:Integer;  nome, descricao: string);
    procedure AlterarTreinoOnline(id_treino, id_usuario, dia_semana:Integer;  nome, descricao: string);
    procedure EnviarDadosTreinoExercicio;
    procedure ExcluirExercicio(Sender: TObject);
    procedure ExcluirTreino(Sender: TObject);
    procedure ThreadCarregarExerciciosTerminate(Sender: TObject);
    function VerificaInformacoes: Boolean;

    property excluir: Boolean read Fexcluir write Fexcluir;

    {$IFDEF MSWINDOWS}
    procedure onComboClick(Sender: TObject);
    {$ELSE}
    procedure onComboClick(Sender: TObject; CONST Point: TPointF);
    {$ENDIF}
    procedure CarregarExercicios;
    procedure AddExercicio(id_exercicio: integer; titulo, subtitulo: string);
    procedure BuscaExerciciosAparelho(Excluir : Boolean);
    procedure AlimentaCampos;


  public
    { Public declarations }
    property id_treino: integer read Fid_treino write Fid_treino;
    property id_exercicio: integer read Fid_exercicio write Fid_exercicio;
    property id_aluno: integer read Fid_aluno write Fid_aluno;
    property nome: String read Fnome write Fnome;
    property descricao: String read Fdescricao write Fdescricao;
    property dia_semana: integer read Fdia_semana write Fdia_semana;
    property Alteracao: boolean read Falteracao write Falteracao;
    property ExecuteOnClose : TExecuteOnClose read FExecuteOnClose write FExecuteOnClose;
  end;

var
  FrmCadastraTreinoAluno: TFrmCadastraTreinoAluno;

implementation

{$R *.fmx}

uses unEdicao, DataModule.Global, Frame.Treino, uSession,
  UnitListaExercicio_IncTreino, uLoading;

procedure TFrmCadastraTreinoAluno.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := TCloseAction.caFree;
  FrmCadastraTreinoAluno := nil;
end;

{$IFDEF MSWINDOWS}
procedure TFrmCadastraTreinoAluno.onComboClick(Sender: TObject);
begin
  combo.HideMenu;
  dia_semana := combo.CodItem.ToInteger;
  nome       := combo.DescrItem;

  lblDiaSemana.text := nome;
end;
{$ELSE}
procedure TFrmCadastraTreinoAluno.onComboClick(Sender: TObject; CONST Point: TPointF);
begin
  combo.HideMenu;
  dia_semana := combo.CodItem.ToInteger;
  nome       := combo.DescrItem;

  lblDiaSemana.text := nome;
end;

{$ENDIF}

procedure TFrmCadastraTreinoAluno.FormCreate(Sender: TObject);
begin
  //BannerBooton.AdUnitID := 'ca-app-pub-2114109645415332/5505153052';

  fancy := TFancyDialog.Create(FrmCadastraTreinoAluno);
  combo     := TCustomCombo.Create(FrmCadastraTreinoAluno);

  //listagem
  combo.TitleMenuText := 'Treino';
  combo.TitleFontSize := 16;
  combo.TitleFontColor := $FFA3A3A3;

  combo.SubTitleMenuText := 'Escolha um treino';
  combo.SubTitleFontSize := 15;
  combo.SubTitleFontColor := $FFA3A3A3;

  combo.BackgroundColor  := $FF0E1118;

  combo.ItemFontSize := 15;
  combo.ItemFontColor := $FFFFBD59;
  combo.ItemBackgroundColor := $FF0E1118;

  combo.AddItem('1', 'Treino 1');
  combo.AddItem('2', 'Treino 2');
  combo.AddItem('3', 'Treino 3');
  combo.AddItem('4', 'Treino 4');
  combo.AddItem('5', 'Treino 5');
  combo.AddItem('6', 'Treino 6');
  combo.AddItem('7', 'Treino 7');
  combo.AddItem('8', 'Treino 8');
  combo.AddItem('9', 'Treino 9');
  combo.AddItem('10', 'Treino 10');

  combo.OnClick := onComboClick;

  excluir := True;
end;

procedure TFrmCadastraTreinoAluno.FormDestroy(Sender: TObject);
begin
  if Assigned(combo) then
    combo.DisposeOf;

  fancy.DisposeOf;
end;

procedure TFrmCadastraTreinoAluno.FormShow(Sender: TObject);
begin
  //BannerBooton.LoadAd;

  BuscaExerciciosAparelho(excluir);
  sleep(300);
  CarregarExercicios;

  //AlimentaCampos;

end;

procedure TFrmCadastraTreinoAluno.AlimentaCampos;
var dia : Integer ;
begin
  if DmGlobal.qryConsExercicio.RecordCount > 0 then
  begin
    if DmGlobal.qryConsExercicio.FieldByName('descr_treino').AsString <> '' then
      lblDescricao.Text := DmGlobal.qryConsExercicio.FieldByName('descr_treino').AsString;
    dia := DmGlobal.qryConsExercicio.FieldByName('dia_semana').Value;

    if dia = 1 Then
      lblDiaSemana.Text := 'Treino 1'
    else if dia = 2 then
    lblDiaSemana.Text := 'Treino 2'
    else if dia = 3 then
    lblDiaSemana.Text := 'Treino 3'
    else if dia = 4 then
    lblDiaSemana.Text := 'Treino 4 '
    else if dia = 5 then
    lblDiaSemana.Text := 'Treino 5'
    else if dia = 6 then
    lblDiaSemana.Text := 'Treino 6'
    else if dia = 7 then
    lblDiaSemana.Text := 'Treino 7 '
    else if dia = 8 then
    lblDiaSemana.Text := 'Treino 8 '
    else if dia = 9 then
    lblDiaSemana.Text := 'Treino 9 '
    else if dia = 10 then
    lblDiaSemana.Text := 'Treino 10 ';

    descricao  := DmGlobal.qryConsExercicio.FieldByName('descr_treino').AsString;
    nome       := DmGlobal.qryConsExercicio.FieldByName('treino').AsString;
    Dia_Semana := dia;
  end;
end;

procedure TFrmCadastraTreinoAluno.imgFecharClick(Sender: TObject);
begin
  close;
end;

procedure TFrmCadastraTreinoAluno.imgSalvarClick(Sender: TObject);
begin
  if not VerificaInformacoes then
    abort;

  if not Alteracao then
    IncluirTreinoOnline(id_aluno, dia_semana,  nome, lblDescricao.text)
  else
    AlterarTreinoOnline(id_treino, id_aluno, dia_semana,  nome, lblDescricao.text);

  EnviarDadosTreinoExercicio;

  close;
end;

function TFrmCadastraTreinoAluno.VerificaInformacoes : Boolean;
begin
  if nome = '' then
  begin
    fancy.Show(TIconDialog.Warning, 'Aviso', 'Informe o treino.', 'OK');
    exit;
  end;

  if (lblDescricao.text = '') or (lblDescricao.text = 'Descrição do Treino') then
  begin
    fancy.Show(TIconDialog.Warning, 'Aviso', 'Informe a descrição do treino.', 'OK');
    exit;
  end;
end;

procedure TFrmCadastraTreinoAluno.EnviarDadosTreinoExercicio;
begin
  with DmGlobal.qryConsExercicio do
    begin
        first;
        while NOT EOF do
        begin
            if fieldbyname('inclusao').asinteger = 1 then
            begin
              DmGlobal.IncluirTreinoExercicioOnline(id_treino, fieldbyname('id_exercicio').asinteger,TSession.ID_USUARIO,  fieldbyname('duracao').asstring);
            end;
            Next;
        end;
    end;
end;

procedure TFrmCadastraTreinoAluno.imgAdicionarClick(Sender: TObject);
begin
  descricao := lblDescricao.Text;

  if NOT Assigned(FrmListaExercicio_IncTreino) then
        Application.CreateForm(TFrmListaExercicio_IncTreino, FrmListaExercicio_IncTreino);

  FrmListaExercicio_IncTreino.id_treino  := id_treino;
  FrmListaExercicio_IncTreino.id_aluno   := id_aluno;
  FrmListaExercicio_IncTreino.nome       := nome;
  FrmListaExercicio_IncTreino.descricao  := descricao;
  FrmListaExercicio_IncTreino.dia_semana := dia_semana;

  FrmListaExercicio_IncTreino.ShowModal(procedure(ModalResult: TModalResult)
  begin
    excluir := False;
    CarregarExercicios;
    //AlimentaCampos;
  end);
end;

procedure TFrmCadastraTreinoAluno.imgExcluirTreinoClick(Sender: TObject);
begin
  fancy.Show(TIconDialog.Question, 'Aviso','Deseja excluir o treino?', 'Sim', ExcluirTreino, 'Não');
end;

procedure TFrmCadastraTreinoAluno.IncluirTreinoOnline( id_usuario, dia_semana:Integer;  nome, descricao: string );
begin
  DmGlobal.IncluirTreinoOnline(id_aluno, dia_semana,  nome, descricao ); //TSession.ID_ALUNO)

  id_treino := DmGlobal.tabIncTreino.FieldByName('id_treino').Value;
end;

procedure TFrmCadastraTreinoAluno.AlterarTreinoOnline(id_treino, id_usuario, dia_semana:Integer;  nome, descricao: string);
begin
  DmGlobal.AlterarTreinoOnline(id_treino, id_aluno, dia_semana,  nome, descricao ); //TSession.ID_ALUNO)
end;

procedure TFrmCadastraTreinoAluno.CarregarExercicios;
var
    t: TThread;
begin
  lbExercicios.Items.Clear;

  TLoading.Show(FrmCadastraTreinoAluno, '');

  t := TThread.CreateAnonymousThread(procedure
  begin
       DmGlobal.ListarExercicios(id_treino); //(TSession.ID_ALUNO);

  end);

  //sleep(300);

  t.OnTerminate := ThreadCarregarExerciciosTerminate;
  t.Start;


end;

procedure TFrmCadastraTreinoAluno.ThreadCarregarExerciciosTerminate(Sender: TObject);
begin
  with DmGlobal.qryConsExercicio do
  begin
      while NOT EOF do
      begin
          //sleep(300);
          AddExercicio(fieldbyname('id_exercicio').asinteger,
                       fieldbyname('exercicio').asstring,
                       fieldbyname('duracao').asstring);

          Next;
      end;

      AlimentaCampos;
  end;
  TLoading.Hide;
end;

procedure TFrmCadastraTreinoAluno.BuscaExerciciosAparelho(Excluir : Boolean);
begin
  with DmGlobal.TabTreino do
  begin
    if Excluir then
    begin
      DmGlobal.ListarTreinoExercicioOnline(id_aluno); //TSession.ID_ALUNO);

      DmGlobal.ExcluirTreinoExercicio;


      while NOT EOF do
      begin
          DmGlobal.InserirTreinoExercicio(FieldByName('id_treino').AsInteger,
                                          FieldByName('treino').AsString,
                                          FieldByName('descr_treino').AsString,
                                          FieldByName('dia_semana').AsInteger,
                                          FieldByName('id_exercicio').AsInteger,
                                          FieldByName('exercicio').AsString,
                                          FieldByName('descr_exercicio').AsString,
                                          FieldByName('duracao').AsString,
                                          FieldByName('url_video').AsString,
                                          False );

          Next;
      end;
    end;

  end;
end;

procedure TFrmCadastraTreinoAluno.AddExercicio(id_exercicio: integer;
                                         titulo, subtitulo: string);
var
    item: TListBoxItem;
    frame: TFrameTreino;
begin
    item := TListBoxItem.Create(lbExercicios);
    item.Selectable := false;
    item.Text := '';
    item.Height := 90;
    item.Tag := id_exercicio;

    // Frame...
    frame := TFrameTreino.Create(item);
    frame.lblTitulo.Text := titulo;
    frame.lblSubtitulo.Text := subtitulo;
    frame.imgOpcoes.Visible := False;
    frame.imgExcluir.Visible:= True;

    item.AddObject(frame);

    lbExercicios.AddObject(item);
end;

procedure TFrmCadastraTreinoAluno.lblDiaSemanaClick(Sender: TObject);
begin
  combo.ShowMenu;
end;

procedure TFrmCadastraTreinoAluno.lbExerciciosItemClick(
  const Sender: TCustomListBox; const Item: TListBoxItem);
begin
  id_exercicio := item.Tag;
  fancy.Show(TIconDialog.Question, 'Aviso','Deseja excluir o exercício?', 'Sim', ExcluirExercicio, 'Não');

end;

procedure TFrmCadastraTreinoAluno.lblDescricaoClick(Sender: TObject);
begin
  if lblDescricao.Text = 'Descrição do Treino' then
    lblDescricao.Text := '';

  frmEdicao.Editar(lblDescricao,
                   TTipoCampo.Edit,
                   'Treino',
                   'Informe a descrição',
                   lblDescricao.text,
                   True,
                   100,
                   nil);

  descricao := lblDescricao.Text;
end;

procedure TFrmCadastraTreinoAluno.ExcluirExercicio(Sender: TObject);
begin
  try
    DmGlobal.ExcluirTreinoExercicioOnline(id_treino, id_exercicio);
    excluir := False;
    CarregarExercicios;
    if Assigned(ExecuteOnClose) then
     ExecuteOnClose;

  except on ex:exception do
    fancy.Show(TIconDialog.Error, 'Aviso', ex.Message, 'OK');

  end;

end;

procedure TFrmCadastraTreinoAluno.ExcluirTreino(Sender: TObject);
begin
  try
    DmGlobal.ExcluirTreinoOnline(id_treino);
    excluir := False;
    if Assigned(ExecuteOnClose) then
     ExecuteOnClose;

     close;

  except on ex:exception do
    fancy.Show(TIconDialog.Error, 'Aviso', ex.Message, 'OK');

  end;

end;

end.

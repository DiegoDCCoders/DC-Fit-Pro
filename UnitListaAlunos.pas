unit UnitListaAlunos;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, FMX.Edit, FMX.ListBox,
  FMX.Advertising;

type
  TfrmListaAlunos = class(TForm)
    lytToolbar: TLayout;
    lblTitulo: TLabel;
    imgFechar: TImage;
    Rectangle6: TRectangle;
    recBusca: TRectangle;
    Label1: TLabel;
    edtBusca: TEdit;
    lbAlunos: TListBox;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure imgFecharClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure recBuscaClick(Sender: TObject);
    procedure lbAlunosItemClick(const Sender: TCustomListBox;
      const Item: TListBoxItem);
    procedure imgPerfilClick(Sender: TObject);
  private
    Fclone: boolean;
    { Private declarations }
    procedure CarregarAlunos;
    procedure AddAluno(id_usuario: integer; titulo,
  subtitulo: string);
    procedure ThreadAlunosTerminate(Sender: TObject);
  public
    { Public declarations }
    property clone: boolean read Fclone write Fclone;
  end;

var
  frmListaAlunos: TfrmListaAlunos;

implementation

{$R *.fmx}

uses Frame.Treino, uLoading, DataModule.Global, UnitCadastraTreino, uSession;

{ TfrmListaAlunos }

procedure TfrmListaAlunos.AddAluno(id_usuario: integer; titulo,
  subtitulo: string);
var
    item: TListBoxItem;
    frame: TFrameTreino;
begin
    item := TListBoxItem.Create(lbAlunos);
    item.Selectable := false;
    item.Text := '';
    item.Height := 100;
    item.Tag := id_usuario;
    item.TagString :=  titulo;

    // Frame...
    frame := TFrameTreino.Create(item);
    frame.lblTitulo.Text := titulo;
    frame.lblSubtitulo.Text := subtitulo;

    item.AddObject(frame);

    lbAlunos.AddObject(item);
end;

procedure TfrmListaAlunos.CarregarAlunos;
var
    t: TThread;
begin

  TLoading.Show(frmListaAlunos, '');

  t := TThread.CreateAnonymousThread(procedure
  begin
      DmGlobal.UsuarioOnline(edtBusca.Text);

      //sleep(300);
  end);

  t.OnTerminate := ThreadAlunosTerminate;
  t.Start;

end;

procedure TfrmListaAlunos.ThreadAlunosTerminate(Sender: TObject);
begin
  with DmGlobal.tabUsuarios do
    begin
        if recordcount = 0 then
        begin
           TLoading.Hide;
           exit;
        end;

        while NOT EOF do
        begin
          AddAluno(fieldbyname('id_usuario').asinteger,
                   fieldbyname('nome').asstring,
                   fieldbyname('email').asstring);

          Next;
        end;
    end;

  TLoading.Hide;

end;

procedure TfrmListaAlunos.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := TCloseAction.caFree;
  frmListaAlunos := nil;
end;

procedure TfrmListaAlunos.FormCreate(Sender: TObject);
begin
  //BannerBooton.AdUnitID := 'ca-app-pub-2114109645415332/5740068721';
end;

procedure TfrmListaAlunos.FormShow(Sender: TObject);
begin
  //BannerBooton.LoadAd;

  Try
    CarregarAlunos;
  except
    CarregarAlunos;
  End;
end;

procedure TfrmListaAlunos.imgFecharClick(Sender: TObject);
begin
  close;
end;

procedure TfrmListaAlunos.imgPerfilClick(Sender: TObject);
begin
  {if NOT Assigned(FrmExercicio) then
        Application.CreateForm(TFrmExercicio, FrmExercicio);

    FrmExercicio.id_usuario := 0;
    FrmExercicio.Alteracao    := False;
    //FrmExercicio.show;

    FrmExercicio.ShowModal(procedure(ModalResult: TModalResult)
  begin
    lbExercicios.Items.Clear;
    CarregarExercicios;
  end);   }
end;

procedure TfrmListaAlunos.lbAlunosItemClick(const Sender: TCustomListBox;
  const Item: TListBoxItem);
begin
  if not clone then
  begin
    TSession.ID_ALUNO  := Item.Tag;
    TSession.ALUNO     := Item.TagString;
  end
  else
  begin
    TSession.ID_ALUNO_CLONE  := Item.Tag;
    TSession.ALUNO_CLONE     := Item.TagString;
  end;
  close;
end;

procedure TfrmListaAlunos.recBuscaClick(Sender: TObject);
begin
  lbAlunos.Items.Clear;
  CarregarAlunos;
end;

end.

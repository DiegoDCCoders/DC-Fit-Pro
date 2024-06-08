unit UnitPrincipal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects, FMX.ListBox, uLoading,
  uSession, System.DateUtils, FMX.Advertising;

type
  TFrmPrincipal = class(TForm)
    Layout1: TLayout;
    imgPerfil: TImage;
    lbTreinos: TListBox;
    imgRefresh: TImage;
    Layout2: TLayout;
    Label1: TLabel;
    lblNome: TLabel;
    rectPerfil: TRectangle;
    Label2: TLabel;
    Image4: TImage;
    Image1: TImage;
    Rectangle1: TRectangle;
    Label3: TLabel;
    Image2: TImage;
    Image3: TImage;
    procedure FormShow(Sender: TObject);
    procedure lbTreinosItemClick(const Sender: TCustomListBox;
      const Item: TListBoxItem);
    procedure imgPerfilClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure rectPerfilClick(Sender: TObject);
    procedure Rectangle1Click(Sender: TObject);
  private
    procedure CarregarTreinos;
    procedure AddTreino(id_treino: integer; titulo, subtitulo: string);
    procedure SincronizarTreinos;
    procedure ThreadSincronizarTerminate(Sender: TObject);
    procedure ThreadDashboardTerminate(Sender: TObject);
    procedure DetalhesTreino(id_treino: integer; treino: string);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmPrincipal: TFrmPrincipal;

implementation

{$R *.fmx}

uses Frame.Treino, UnitTreinoDetalhe, UnitPerfil, DataModule.Global,
  UnitListaExercicio, UnitCadastraTreino;

procedure TFrmPrincipal.AddTreino(id_treino: integer;
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

procedure TFrmPrincipal.CarregarTreinos;
begin
    lbTreinos.Items.Clear;
    Dmglobal.ListarTreinos;

    with DmGlobal.qryConsTreino do
    begin
        while NOT EOF do
        begin
            AddTreino(fieldbyname('id_treino').asinteger,
                      fieldbyname('treino').asstring,
                      fieldbyname('descr_treino').asstring);

            Next;
        end;
    end;
end;


procedure TFrmPrincipal.DetalhesTreino(id_treino: integer; treino: string);
begin
    if NOT Assigned(FrmTreinoDetalhe) then
        Application.CreateForm(TFrmTreinoDetalhe, FrmTreinoDetalhe);

    FrmTreinoDetalhe.id_treino := id_treino;
    FrmTreinoDetalhe.treino := treino;
    FrmTreinoDetalhe.Show;
end;

procedure TFrmPrincipal.ThreadDashboardTerminate(Sender: TObject);
begin
    TLoading.Hide;
    CarregarTreinos;
end;

procedure TFrmPrincipal.ThreadSincronizarTerminate(Sender: TObject);
begin
    TLoading.Hide;

end;

procedure TFrmPrincipal.SincronizarTreinos;
var
    t: TThread;
begin
    TLoading.Show(FrmPrincipal, '');

    t := TThread.CreateAnonymousThread(procedure
    begin
        DmGlobal.ListarTreinoExercicioOnline(TSession.ID_USUARIO);

        with DmGlobal.TabTreino do
        begin
            if recordcount > 0 then
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
                                                FieldByName('url_video').AsString);

                Next;
            end;
        end;
    end);

    t.OnTerminate := ThreadSincronizarTerminate;
    t.Start;
end;
procedure TFrmPrincipal.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    Action := TCloseAction.cafree;
    FrmPrincipal := nil;
end;

procedure TFrmPrincipal.FormCreate(Sender: TObject);
begin
  //BannerBooton.AdUnitID := 'ca-app-pub-2114109645415332/1618230585';
end;

procedure TFrmPrincipal.FormShow(Sender: TObject);
begin
  //BannerBooton.LoadAd;

  lblNome.Text := TSession.NOME;
  //SincronizarTreinos;


end;

procedure TFrmPrincipal.imgPerfilClick(Sender: TObject);
begin
    if NOT Assigned(FrmPerfil) then
        Application.CreateForm(TFrmPerfil, FrmPerfil);

    FrmPerfil.Show;
end;

procedure TFrmPrincipal.lbTreinosItemClick(const Sender: TCustomListBox;
  const Item: TListBoxItem);
begin
    DetalhesTreino(Item.tag, Item.tagstring);
end;

procedure TFrmPrincipal.Rectangle1Click(Sender: TObject);
begin  if NOT Assigned(frmCadastraTreino) then
        Application.CreateForm(TfrmCadastraTreino, frmCadastraTreino);

    frmCadastraTreino.Show;
end;

procedure TFrmPrincipal.rectPerfilClick(Sender: TObject);
begin
  if NOT Assigned(frmListaExercicio) then
        Application.CreateForm(TfrmListaExercicio, frmListaExercicio);

    frmListaExercicio.Show;
end;

end.

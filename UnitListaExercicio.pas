unit UnitListaExercicio;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, FMX.Edit, FMX.ListBox,
  FMX.Advertising;

type
  TfrmListaExercicio = class(TForm)
    lytToolbar: TLayout;
    lblTitulo: TLabel;
    imgFechar: TImage;
    imgPerfil: TImage;
    Rectangle6: TRectangle;
    recBusca: TRectangle;
    Label1: TLabel;
    edtBusca: TEdit;
    lbExercicios: TListBox;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure imgFecharClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure recBuscaClick(Sender: TObject);
    procedure lbExerciciosItemClick(const Sender: TCustomListBox;
      const Item: TListBoxItem);
    procedure imgPerfilClick(Sender: TObject);
  private
    { Private declarations }
    procedure CarregarExercicios;
    procedure AddExercicio(id_exercicio: integer; titulo, subtitulo: string);
    procedure ThreadExerciciosTerminate(Sender: TObject);
  public
    { Public declarations }
  end;

var
  frmListaExercicio: TfrmListaExercicio;

implementation

{$R *.fmx}

uses Frame.Exercicio, uLoading, DataModule.Global, UnitExercicio;

{ TfrmListaExercicio }

procedure TfrmListaExercicio.AddExercicio(id_exercicio: integer; titulo,
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

    // Frame...
    frame := TFrameExercicio.Create(item);
    frame.lblTitulo.Text := titulo;
    frame.lblSubtitulo.Text := subtitulo;

    item.AddObject(frame);

    lbExercicios.AddObject(item);
end;

procedure TfrmListaExercicio.CarregarExercicios;
var
    t: TThread;
begin

  TLoading.Show(frmListaExercicio, '');

  t := TThread.CreateAnonymousThread(procedure
  begin
      DmGlobal.ExercicioOnline(edtBusca.Text);

      //sleep(300);
  end);

  t.OnTerminate := ThreadExerciciosTerminate;
  t.Start;

end;

procedure TfrmListaExercicio.ThreadExerciciosTerminate(Sender: TObject);
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
          AddExercicio(fieldbyname('id_exercicio').asinteger,
                       fieldbyname('nome').asstring,
                       fieldbyname('descricao').asstring);

          Next;
        end;
    end;

  TLoading.Hide;

end;

procedure TfrmListaExercicio.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := TCloseAction.caFree;
  frmListaExercicio := nil;
end;

procedure TfrmListaExercicio.FormCreate(Sender: TObject);
begin
  //BannerBooton.AdUnitID := 'ca-app-pub-2114109645415332/3113905384';
end;

procedure TfrmListaExercicio.FormShow(Sender: TObject);
begin
  //BannerBooton.LoadAd;

  Try
    CarregarExercicios;
  except
    CarregarExercicios;
  End;
end;

procedure TfrmListaExercicio.imgFecharClick(Sender: TObject);
begin
  close;
end;

procedure TfrmListaExercicio.imgPerfilClick(Sender: TObject);
begin
  if NOT Assigned(FrmExercicio) then
        Application.CreateForm(TFrmExercicio, FrmExercicio);

    FrmExercicio.id_exercicio := 0;
    FrmExercicio.Alteracao    := False;
    //FrmExercicio.show;

    FrmExercicio.ShowModal(procedure(ModalResult: TModalResult)
  begin
    lbExercicios.Items.Clear;
    CarregarExercicios;
  end);
end;

procedure TfrmListaExercicio.lbExerciciosItemClick(const Sender: TCustomListBox;
  const Item: TListBoxItem);
begin
  if NOT Assigned(FrmExercicio) then
        Application.CreateForm(TFrmExercicio, FrmExercicio);

    FrmExercicio.id_exercicio := Item.Tag;
    FrmExercicio.Alteracao    := True;
    //FrmExercicio.show;

  FrmExercicio.ShowModal(procedure(ModalResult: TModalResult)
  begin
    lbExercicios.Items.Clear;
    CarregarExercicios;
  end);

end;

procedure TfrmListaExercicio.recBuscaClick(Sender: TObject);
begin
  lbExercicios.Items.Clear;
  CarregarExercicios;
end;

end.

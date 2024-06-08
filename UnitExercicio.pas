unit UnitExercicio;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.WebBrowser,
  FMX.Objects, FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, FMX.Edit,
  uFancyDialog, FMX.Advertising;

type
  TFrmExercicio = class(TForm)
    lytToolbar: TLayout;
    lblTitulo: TLabel;
    imgFechar: TImage;
    imgGravar: TImage;
    lblExib1: TLabel;
    lblExib2: TLabel;
    lblExib3: TLabel;
    lblExercicio: TLabel;
    lblLink: TLabel;
    lblDescricao: TLabel;
    procedure imgFecharClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormResize(Sender: TObject);
    procedure lblDescricaoClick(Sender: TObject);
    procedure lblLinkClick(Sender: TObject);
    procedure lblExercicioClick(Sender: TObject);
    procedure imgGravarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    fancy : TFancyDialog;
    Fid_exercicio: integer;
    Falteracao: boolean;
    Fdescricao: string;
    Furl_video: string;
    Fnome: string;
    procedure AjustarTamanhoVideo(browser: TWebBrowser);
    procedure LoadVideoYoutube(browser: TWebBrowser; video: string);
    procedure DadosExercicio;
    function VerificaParametros: Boolean;
    { Private declarations }
  public
    property id_exercicio: integer read Fid_exercicio write Fid_exercicio;
    property url_video: string read Furl_video write Furl_video;
    property nome: string read Fnome write Fnome;
    property descricao: string read Fdescricao write Fdescricao;
    property Alteracao: boolean read Falteracao write Falteracao;
  end;

var
  FrmExercicio: TFrmExercicio;

const
  PROPORCAO = 0.5625;  // 1920x1080  (1080 dividido por 1920)


implementation

{$R *.fmx}

uses DataModule.Global, unEdicao;

procedure TFrmExercicio.AjustarTamanhoVideo(browser: TWebBrowser);
var
    w, h: integer;
begin
    w := Trunc(browser.width - 30);
    h := Trunc(w * PROPORCAO) + 10;

    browser.Height := h;
end;

procedure TFrmExercicio.LoadVideoYoutube(browser: TWebBrowser; video: string);
var
    html: string;
begin
    html := '<!DOCTYPE html>' +
      '<html>' +
      '<head>' +
      '<style>' +
      '.container {position: relative; overflow: hidden; width: 100%; padding-top: 56.25%;} ' +
      '.responsive-iframe {position: absolute; top: 0; left: 0; bottom: 0; right: 0; width: 100%; height: 100%;} ' +
      '</style>' +
      '<meta http-equiv="X-UA-Compatible" content="IE=edge"></meta>' + // compatibility mode
      '</head>' +
      '<body style="margin:0;height: 100%; overflow: hidden">' +
      //'<iframe width="' + inttostr(w) + '" height="' + inttostr(h) + '" ' +
      '<iframe class="responsive-iframe"  ' +
      'src="' + video +
      '?controls=0' +
      ' frameborder="0" ' +
      ' autoplay=1&rel=0&controls=0&showinfo=0" ' + // autoplay, no related videos, no info nor controls
      ' allow="autoplay" frameborder="0">' + // allow autoplay, no border
      '</iframe>' +
       '</body>' +
      '</html>';

    AjustarTamanhoVideo(browser);
    browser.LoadFromStrings(html, '');
end;

procedure TFrmExercicio.DadosExercicio;
begin
    DmGlobal.DetalheExercicio(id_exercicio);

    if DmGlobal.tabExercicios.FieldByName('nome').AsString <> '' then
    begin
      lblLink.Text      := DmGlobal.tabExercicios.FieldByName('url_video').AsString;
      lblExercicio.Text := DmGlobal.tabExercicios.FieldByName('nome').AsString;
      lblDescricao.Text := DmGlobal.tabExercicios.FieldByName('descricao').AsString;
    end
    else
    begin
      lblLink.Text      := 'Informe o link';
      lblExercicio.Text := 'Informe o exercício';
      lblDescricao.Text := 'Informe a descrição';
    end;
end;


procedure TFrmExercicio.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  DmGlobal.tabExercicios.Filtered := False;
  DmGlobal.tabExercicios.Filter   := '';

    Action := TCloseAction.caFree;
    FrmExercicio := nil;
end;

procedure TFrmExercicio.FormCreate(Sender: TObject);
begin
  //BannerBooton.AdUnitID := 'ca-app-pub-2114109645415332/8873888165';
  fancy := TFancyDialog.Create(FrmExercicio);
end;

procedure TFrmExercicio.FormDestroy(Sender: TObject);
begin
  fancy.DisposeOf;
end;

procedure TFrmExercicio.FormResize(Sender: TObject);
begin
    //AjustarTamanhoVideo(WebBrowser1);
end;

procedure TFrmExercicio.FormShow(Sender: TObject);
begin
  //BannerBooton.LoadAd;

  DadosExercicio;
end;

procedure TFrmExercicio.imgFecharClick(Sender: TObject);
begin
  close;
end;

procedure TFrmExercicio.imgGravarClick(Sender: TObject);
begin
  if VerificaParametros then
  begin
    if Alteracao then
      DmGlobal.AlterarExercicioOnline(id_exercicio, lblExercicio.Text, lblDescricao.Text,lblLink.Text )
    else
      DmGlobal.IncluirExercicioOnline(lblExercicio.Text, lblDescricao.Text,lblLink.Text );
    close;
  end;
end;

function TFrmExercicio.VerificaParametros: Boolean;
begin
  Result := True;

  if trim(lblExercicio.Text) = '' then
  begin
    fancy.Show(TIconDialog.Warning, 'Aviso','Informe o exercício.', 'OK');
    Result := False;
    Exit;
  end;
end;

procedure TFrmExercicio.lblDescricaoClick(Sender: TObject);
begin
  if lblDescricao.Text = 'Informe a descrição' then
    lblDescricao.Text := '';

  frmEdicao.Editar(lblDescricao,
                   TTipoCampo.Memo,
                   'Descrição',
                   'Informe a descrição',
                   lblDescricao.text,
                   false,
                   1000,
                   nil);

end;

procedure TFrmExercicio.lblExercicioClick(Sender: TObject);
begin
  if lblExercicio.Text = 'Informe o exercício' then
    lblExercicio.Text := '';

  frmEdicao.Editar(lblExercicio,
                   TTipoCampo.Edit,
                   'Exercício',
                   'Informe o exercício',
                   lblExercicio.text,
                   True,
                   100,
                   nil);
end;

procedure TFrmExercicio.lblLinkClick(Sender: TObject);
begin
  if lblLink.Text = 'Informe o link' then
    lblLink.Text := '';


  frmEdicao.Editar(lblLink,
                   TTipoCampo.Memo,
                   'Link Vídeo',
                   'Informe o link',
                   lblLink.text,
                   false,
                   1000,
                   nil);
end;

end.

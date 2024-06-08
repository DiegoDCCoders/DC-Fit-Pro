unit UnitPerfil;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, FMX.Advertising;

type
  TFrmPerfil = class(TForm)
    lytToolbar: TLayout;
    lblTitulo: TLabel;
    rectPerfil: TRectangle;
    Label1: TLabel;
    Image4: TImage;
    Image1: TImage;
    rectSenha: TRectangle;
    Label3: TLabel;
    Image5: TImage;
    Image6: TImage;
    rectDesconectar: TRectangle;
    Label2: TLabel;
    Image2: TImage;
    Image3: TImage;
    Label4: TLabel;
    imgFechar: TImage;
    procedure rectPerfilClick(Sender: TObject);
    procedure rectSenhaClick(Sender: TObject);
    procedure imgFecharClick(Sender: TObject);
    procedure rectDesconectarClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmPerfil: TFrmPerfil;

implementation

{$R *.fmx}

uses UnitPerfilCad, UnitPerfilSenha, DataModule.Global, UnitPrincipal,
  UnitLogin;

procedure TFrmPerfil.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    Action := TCloseAction.cafree;
    FrmPerfil := nil;
end;

procedure TFrmPerfil.FormCreate(Sender: TObject);
begin
  //BannerBooton.AdUnitID := 'ca-app-pub-2114109645415332/8707949786';
end;

procedure TFrmPerfil.FormShow(Sender: TObject);
begin
  //BannerBooton.LoadAd;
end;

procedure TFrmPerfil.imgFecharClick(Sender: TObject);
begin
    close;
end;

procedure TFrmPerfil.rectDesconectarClick(Sender: TObject);
begin
    try
        DmGlobal.Logout;

    if NOT Assigned(FrmLogin) then
        Application.CreateForm(TFrmLogin, FrmLogin);

    Application.MainForm := FrmLogin;
    FrmLogin.show;

    FrmPrincipal.close;
    FrmPerfil.close;

    except on ex:exception do
        showmessage('Erro ao desconectar: ' + ex.Message);
    end;
end;

procedure TFrmPerfil.rectPerfilClick(Sender: TObject);
begin
    if NOT Assigned(FrmPerfilCad) then
        Application.CreateForm(tFrmPerfilCad, FrmPerfilCad);

    FrmPerfilCad.Show;
end;

procedure TFrmPerfil.rectSenhaClick(Sender: TObject);
begin
    if NOT Assigned(FrmPerfilSenha) then
        Application.CreateForm(TFrmPerfilSenha, FrmPerfilSenha);

    FrmPerfilSenha.Show;
end;

end.

unit UnitPerfilCad;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, FMX.Edit, uSession;

type
  TFrmPerfilCad = class(TForm)
    lytToolbar: TLayout;
    lblTitulo: TLabel;
    Rectangle1: TRectangle;
    edtNome: TEdit;
    edtEmail: TEdit;
    rectBtnLogin: TRectangle;
    btnSalvar: TSpeedButton;
    imgFechar: TImage;
    procedure imgFecharClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmPerfilCad: TFrmPerfilCad;

implementation

{$R *.fmx}

uses DataModule.Global, UnitPrincipal;

procedure TFrmPerfilCad.btnSalvarClick(Sender: TObject);
begin
    try
        DmGlobal.EditarUsuarioOnline(TSession.ID_USUARIO, edtNome.Text, edtEmail.Text);
        DmGlobal.EditarUsuario(edtNome.Text, edtEmail.Text);

        TSession.NOME := edtNome.Text;
        TSession.EMAIL := edtEmail.Text;

        FrmPrincipal.lblNome.text := edtNome.Text;

        close;
    except on ex:exception do
        showmessage('Erro ao salvar dados do usuário: ' + ex.Message);
    end;
end;

procedure TFrmPerfilCad.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    Action := TCloseAction.cafree;
    FrmPerfilCad := nil;
end;

procedure TFrmPerfilCad.FormShow(Sender: TObject);
begin
    try
        DmGlobal.ListarUsuario;

        edtNome.Text := DmGlobal.qryUsuario.fieldbyname('nome').asstring;
        edtEmail.Text := DmGlobal.qryUsuario.fieldbyname('email').asstring;

    except on ex:exception do
        showmessage('Erro ao carregar dados do usuário: ' + ex.Message);
    end;
end;

procedure TFrmPerfilCad.imgFecharClick(Sender: TObject);
begin
    close;
end;

end.

unit UnitPerfilSenha;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Edit, FMX.Objects, FMX.Controls.Presentation, FMX.Layouts, uSession;

type
  TFrmPerfilSenha = class(TForm)
    lytToolbar: TLayout;
    lblTitulo: TLabel;
    Rectangle1: TRectangle;
    edtSenha: TEdit;
    edtSenha2: TEdit;
    rectBtnLogin: TRectangle;
    btnSalvar: TSpeedButton;
    imgFechar: TImage;
    procedure imgFecharClick(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmPerfilSenha: TFrmPerfilSenha;

implementation

{$R *.fmx}

uses DataModule.Global;

procedure TFrmPerfilSenha.btnSalvarClick(Sender: TObject);
begin
    if (edtSenha.Text <> edtSenha2.Text) then
    begin
        showmessage('As senhas não conferem. Digite novamente.');
        exit;
    end;

    try
        DmGlobal.EditarSenhaOnline(TSession.ID_USUARIO, edtSenha.Text);

        close;
    except on ex:exception do
        showmessage('Erro ao alterar senha: ' + ex.Message);
    end;

end;

procedure TFrmPerfilSenha.imgFecharClick(Sender: TObject);
begin
    close;
end;

end.

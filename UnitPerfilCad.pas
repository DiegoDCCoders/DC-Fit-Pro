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
    rectBtnLogin: TRectangle;
    btnSalvar: TSpeedButton;
    imgFechar: TImage;
    procedure imgFecharClick(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    procedure ThreadLoginTerminate(Sender: TObject);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmPerfilCad: TFrmPerfilCad;

implementation

{$R *.fmx}

uses DataModule.Global, UnitPrincipal, uLoading;

procedure TFrmPerfilCad.btnSalvarClick(Sender: TObject);
var
    t: TThread;
begin
    TLoading.Show(FrmPerfilCad, '');

    t := TThread.CreateAnonymousThread(procedure
    begin
        DmGlobal.CriarContaOnline(edtNome.text, edtNome.Text, '12345');

    end);

    t.OnTerminate := ThreadLoginTerminate;
    t.Start;
end;

procedure TFrmPerfilCad.ThreadLoginTerminate(Sender: TObject);
begin
    TLoading.Hide;

    if Sender is TThread then
        if Assigned(TThread(Sender).FatalException) then
        begin
            showmessage(Exception(TThread(sender).FatalException).Message);
            exit;
        end;

    close;
end;

procedure TFrmPerfilCad.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    Action := TCloseAction.cafree;
    FrmPerfilCad := nil;
end;

procedure TFrmPerfilCad.imgFecharClick(Sender: TObject);
begin
    close;
end;

end.

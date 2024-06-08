unit unEdicao;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.StdCtrls, FMX.Controls.Presentation, FMX.Edit, FMX.Calendar,
  FMX.Memo.Types, FMX.ScrollBox, FMX.Memo, FMX.Layouts, uFancyDialog,
  FMX.ListBox;

type
  TTipoCampo = (Edit, Data, Senha, Memo, Valor, Inteiro, Opcao );

  TExecuteOnClose = procedure(sender: Tobject) of Object;

  TfrmEdicao = class(TForm)
    Rectangle2: TRectangle;
    lblTitulo: TLabel;
    btnVoltar: TSpeedButton;
    Image2: TImage;
    btnAddProduto: TSpeedButton;
    Image1: TImage;
    edtTexto: TEdit;
    edtSenha: TEdit;
    Calendar: TCalendar;
    Memo: TMemo;
    StyleBook1: TStyleBook;
    lytValor: TLayout;
    lblValor: TLabel;
    Layout2: TLayout;
    Label2: TLabel;
    Layout3: TLayout;
    Label3: TLabel;
    Layout4: TLayout;
    Label4: TLabel;
    Layout5: TLayout;
    Label5: TLabel;
    Layout6: TLayout;
    Label6: TLabel;
    Layout7: TLayout;
    Label7: TLabel;
    Layout8: TLayout;
    Label8: TLabel;
    Layout9: TLayout;
    Label9: TLabel;
    Layout10: TLayout;
    Label10: TLabel;
    Layout11: TLayout;
    Label11: TLabel;
    Layout12: TLayout;
    Label12: TLabel;
    Layout13: TLayout;
    Image3: TImage;
    cmbOpcao: TComboBox;
    Switch: TSwitch;

    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnVoltarClick(Sender: TObject);
    procedure btnAddProdutoClick(Sender: TObject);
    procedure Label2Click(Sender: TObject);
    procedure Image3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    fancy : TFancyDialog;
    objeto: Tobject;
    ProcExecuteOnClose : TExecuteOnClose;
    obrigatorio : Boolean;
    tipo : TTipoCampo;
    procedure TeclaNumero(lbl: TLabel);
    procedure TeclaBackspace;
    { Private declarations }

  public
    { Public declarations }
    procedure Editar(obj: TObject; tipo_campo: TTipoCampo; titulo, textprompt,
      texto_padrao: string; ind_obrigatorio: boolean; tam_maximo: integer;
      ExecuteOnClose: TExecuteOnClose = nil);
  end;

var
  frmEdicao: TfrmEdicao;

implementation

{$R *.fmx}

procedure TfrmEdicao.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  //Action := TCloseAction.caFree;
  //frmEdicao := nil;
end;

procedure TfrmEdicao.FormCreate(Sender: TObject);
begin
  fancy := TFancyDialog.Create(frmEdicao);
end;

procedure TfrmEdicao.FormDestroy(Sender: TObject);
begin
  fancy.DisposeOf;
end;

procedure TfrmEdicao.Image3Click(Sender: TObject);
begin
  TeclaBackspace;
end;

procedure TfrmEdicao.TeclaNumero(lbl: TLabel);
var
  Valor : String;
begin
  valor := lblValor.Text;
  valor := valor.Replace('.', '');
  valor := valor.Replace(',', '');

  valor := valor + lbl.text;

  if tipo = TTipoCampo.Valor then
    lblValor.Text := FormatFloat('#,##.00,', valor.ToDouble / 100)
  else
    lblValor.Text := FormatFloat('#,##.00,', valor.ToDouble);
end;

procedure TfrmEdicao.TeclaBackspace;
var
  Valor : String;
begin
  valor := lblValor.Text;
  valor := valor.Replace('.', '');
  valor := valor.Replace(',', '');

  if Length(valor) > 1  then
    valor := copy(valor, 1, Length(valor) - 1)
  else
    valor := '0';

  if tipo = TTipoCampo.Valor then
    lblValor.Text := FormatFloat('#,##.00,', valor.ToDouble / 100)
  else
    lblValor.Text := FormatFloat('#,##.00,', valor.ToDouble);
end;

procedure TfrmEdicao.Label2Click(Sender: TObject);
begin
   TeclaNumero(TLabel(Sender));
end;

procedure TfrmEdicao.btnAddProdutoClick(Sender: TObject);
var ret : string;
begin
  if edtTexto.Visible then
    ret := edtTexto.Text
  else if edtSenha.Visible then
    ret := edtSenha.Text
  else if Calendar.Visible then
    ret := FormatDateTime('dd/mm/yyyy', Calendar.Date)
  else if Memo.Visible then
    ret := Memo.Text
   else if lytValor.Visible then
    ret := lblValor.Text
   else if Switch.Visible then
   begin
      //if cmbOpcao.ItemIndex = 0 then
      if Switch.IsChecked then
        ret := 'Sim'
      else
        ret := 'Não';
   end;


  if (obrigatorio) and (ret = '') then
  begin
    //ShowMessage('Esse campo é obrigatório.');
    fancy.Show(TIconDialog.Warning, 'Aviso','Esse campo é obrigatório', 'OK');
    exit;
  end;

  if objeto is Tlabel then
    TLabel(objeto).Text := ret;

  if Assigned(ProcExecuteOnClose) then
    ProcExecuteOnClose(objeto);

  close;
end;

procedure TfrmEdicao.btnVoltarClick(Sender: TObject);
begin
  close;
end;

procedure TfrmEdicao.Editar(obj: TObject; tipo_campo: TTipoCampo; titulo, textprompt,
      texto_padrao: string; ind_obrigatorio: boolean; tam_maximo: integer;
      ExecuteOnClose: TExecuteOnClose = nil);
var dia, mes, ano : integer;
begin
  lblTitulo.Text     :=  titulo;
  objeto             := obj;
  ProcExecuteOnClose := ExecuteOnClose;
  obrigatorio        := ind_obrigatorio;
  tipo               := tipo_campo;

  edtTexto.Visible := tipo_campo = TTipoCampo.Edit;
  edtSenha.Visible := tipo_campo = TTipoCampo.Senha;
  calendar.Visible := tipo_campo = TTipoCampo.Data;
  Memo.Visible     := tipo_campo = TTipoCampo.Memo;
  lytValor.Visible := (tipo_campo = TTipoCampo.Valor) or (tipo_campo = TTipoCampo.Inteiro);
  //cmbOpcao.Visible := tipo_campo = TTipoCampo.Opcao;
  Switch.Visible := tipo_campo = TTipoCampo.Opcao;

  if tipo_campo = TTipoCampo.Edit then
  begin
    edtTexto.Text      := texto_padrao;
    edtTexto.MaxLength := tam_maximo;
    edtTexto.TextPrompt:= textprompt;
  end;

  if tipo_campo = TTipoCampo.Senha then
  begin
    edtSenha.Text      := texto_padrao;
    edtSenha.MaxLength := tam_maximo;
    edtSenha.TextPrompt:= textprompt;
  end;

  if tipo_campo = TTipoCampo.Data then
  begin
    if texto_padrao <> '' then
    begin
      dia := copy(texto_padrao, 1,2).ToInteger;
      mes := copy(texto_padrao, 4,2).ToInteger;
      ano := copy(texto_padrao, 7,4).ToInteger;

      Calendar.Date := EncodeDate(ano,mes,dia);
    end
    else
    begin
      Calendar.Date := Date;
    end;
  end;

  if tipo_campo = TTipoCampo.Memo then
  begin
    Memo.Text      := texto_padrao;
    Memo.MaxLength := tam_maximo;
  end;

  if tipo_campo = TTipoCampo.Valor then
  begin
    lblValor.Text := texto_padrao;
  end;

  if tipo_campo = TTipoCampo.Inteiro then
  begin
    lblValor.Text := texto_padrao;
  end;

  if tipo_campo = TTipoCampo.Opcao then
  begin
    if texto_padrao = 'Sim' then
      Switch.IsChecked := True
    else
      Switch.IsChecked := False;
  end;

  frmEdicao.Show;

end;

end.

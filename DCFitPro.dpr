program DCFitPro;

uses
  System.StartUpCopy,
  FMX.Forms,
  UnitLogin in 'UnitLogin.pas' {FrmLogin},
  UnitPrincipal in 'UnitPrincipal.pas' {FrmPrincipal},
  Frame.Treino in 'Frames\Frame.Treino.pas' {FrameTreino: TFrame},
  UnitTreinoDetalhe in 'UnitTreinoDetalhe.pas' {FrmTreinoDetalhe},
  UnitTreinoCad in 'UnitTreinoCad.pas' {FrmTreinoCad},
  Frame.FichaExercicio in 'Frames\Frame.FichaExercicio.pas' {FrameFichaExercicio: TFrame},
  UnitExercicio in 'UnitExercicio.pas' {FrmExercicio},
  UnitPerfil in 'UnitPerfil.pas' {FrmPerfil},
  UnitPerfilCad in 'UnitPerfilCad.pas' {FrmPerfilCad},
  UnitPerfilSenha in 'UnitPerfilSenha.pas' {FrmPerfilSenha},
  DataModule.Global in 'DataModules\DataModule.Global.pas' {DmGlobal: TDataModule},
  uLoading in 'Units\uLoading.pas',
  uSession in 'Units\uSession.pas',
  UnitListaExercicio in 'UnitListaExercicio.pas' {frmlistaExercicio},
  Frame.Exercicio in 'Frames\Frame.Exercicio.pas' {FrameExercicio: TFrame},
  unEdicao in 'unEdicao.pas' {frmEdicao},
  uFancyDialog in 'Units\uFancyDialog.pas',
  UnitCadastraTreino in 'UnitCadastraTreino.pas' {frmCadastraTreino},
  UnitCadastraTreinoAluno in 'UnitCadastraTreinoAluno.pas' {FrmCadastraTreinoAluno},
  uCombobox in 'Units\uCombobox.pas',
  UnitListaExercicio_IncTreino in 'UnitListaExercicio_IncTreino.pas' {frmListaExercicio_IncTreino},
  UnitListaAlunos in 'UnitListaAlunos.pas' {frmListaAlunos},
  unitCloneTreino in 'unitCloneTreino.pas' {frmCloneTreino};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TDmGlobal, DmGlobal);
  Application.CreateForm(TFrmLogin, FrmLogin);
  Application.CreateForm(TfrmEdicao, frmEdicao);
  Application.Run;
end.

unit uSession;

interface

type
  TSession = class
  private
    class var FID_USUARIO: integer;
    class var FEMAIL: string;
    class var FNOME: string;
    class var FID_ALUNO: integer;
    class var FALUNO: string;
    class var FID_ALUNO_CLONE: integer;
    class var FALUNO_CLONE: string;

  public
    class property ID_USUARIO: integer read FID_USUARIO write FID_USUARIO;
    class property ID_ALUNO: integer read FID_ALUNO write FID_ALUNO;
    class property ALUNO_CLONE: string read FALUNO_CLONE  write FALUNO_CLONE;
    class property ID_ALUNO_CLONE: integer read FID_ALUNO_CLONE write FID_ALUNO_CLONE;
    class property ALUNO: string read FALUNO  write FALUNO;
    class property NOME: string read FNOME write FNOME;
    class property EMAIL: string read FEMAIL write FEMAIL;
  end;

implementation

end.

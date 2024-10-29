unit DataModule.Global;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteWrapper.Stat, FireDAC.FMXUI.Wait, Data.DB,
  FireDAC.Comp.Client,

  DataSet.Serialize.Config,
  System.IOUtils,
  System.DateUtils,
  RESTRequest4D,
  System.JSON, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf,
  FireDAC.Comp.DataSet, FireDAC.DApt;

type
  TDmGlobal = class(TDataModule)
    Conn: TFDConnection;
    TabUsuario: TFDMemTable;
    qryUsuario: TFDQuery;
    TabTreino: TFDMemTable;
    qryTreinoExercicio: TFDQuery;
    qryConsEstatistica: TFDQuery;
    qryConsTreino: TFDQuery;
    qryConsExercicio: TFDQuery;
    qryAtividade: TFDQuery;
    qryGeral: TFDQuery;
    tabExercicios: TFDMemTable;
    tabTreinos: TFDMemTable;
    tabIncTreino: TFDMemTable;
    qryExcluirTreinoExercicio: TFDQuery;
    tabDeleteTreinoExercicio: TFDMemTable;
    tabUsuarios: TFDMemTable;
    tabCloneTreino: TFDMemTable;
    procedure DataModuleCreate(Sender: TObject);
    procedure ConnBeforeConnect(Sender: TObject);
    procedure ConnAfterConnect(Sender: TObject);
  private

    { Private declarations }
  public
    procedure LoginOnline(email, senha: string);
    procedure ExercicioOnline(busca: string);
    procedure CriarContaOnline(nome, email, senha: string);
    procedure InserirUsuario(id_usuario: integer;
                                   nome, email, senha: string);
    procedure ListarTreinoExercicioOnline(id_usuario: integer);
    procedure ExcluirTreinoExercicio;
    procedure InserirTreinoExercicio(id_treino: integer;
                                           treino, descr_treino: string;
                                           dia_semana, id_exercicio: integer;
                                           exercicio, descr_exercicio, duracao, url_video: string;
                                           inclusao : Boolean = False);
    function Pontuacao: integer;
    function TreinosMes(dt: TDateTime): integer;
    procedure TreinoSugerido(dt: TDateTime);
    procedure ListarTreinos;
    procedure ListarExercicios(id_treino: integer);
    procedure DetalheExercicio(id_exercicio: integer);
    procedure IniciarTreino(id_treino: integer);
    procedure ListarExerciciosAtividade;
    procedure FinalizarTreino(id_treino: integer);
    procedure MarcarExercicioConcluido(id_exercicio: integer;
                                       ind_concluido: boolean);
    procedure ListarUsuario;
    procedure EditarUsuario(nome, email: string);
    procedure EditarUsuarioOnline(id_usuario: integer; nome, email: string);
    procedure EditarSenhaOnline(id_usuario: integer; senha: string);
    procedure Logout;
    procedure AlterarExercicioOnline(id_exercicio: integer; nome, descricao, url: string);
    procedure IncluirExercicioOnline(nome, descricao, url: string);
    procedure IncluirTreinoOnline(id_usuario, dia_semana:Integer;  nome, descricao: string);
    procedure ListarTreinoUsuarioOnline(id_usuario: integer);
    procedure AlterarTreinoOnline(id_treino, id_usuario, dia_semana:Integer;  nome, descricao: string);
    procedure IncluirTreinoExercicioOnline(id_treino, id_exercicio, id_professor: Integer; duracao: string);
    procedure ExcluirTreinoExercicioOnline(id_treino,id_exercicio: Integer);
    procedure ExcluirTreinoOnline(id_treino: Integer);
    procedure UsuarioOnline(busca: string);
    procedure ClonarTreinoOnline(id_usuario_origem, id_usuario_destino, id_professor: Integer);
  end;

var
  DmGlobal: TDmGlobal;

Const
  BASE_URL = 'http://api.dccoders.com.br:3000';
  //BASE_URL = 'http://localhost:3000';
  //BASE_URL = 'http://192.168.0.135:3000';
  //BASE_URL = 'http://23.22.2.201:3000';

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

procedure TDmGlobal.ConnAfterConnect(Sender: TObject);
begin
    // Dados do usuario...
    Conn.ExecSQL('CREATE TABLE IF NOT EXISTS TAB_USUARIO ( ' +
                            'ID_USUARIO     INTEGER NOT NULL PRIMARY KEY, ' +
                            'NOME           VARCHAR (100), ' +
                            'EMAIL          VARCHAR (100), ' +
                            'PONTOS         INTEGER,       ' +
                            'SENHA          VARCHAR (100));'
                );

    // Todos os treinos e exercicios recebidos do server...
    Conn.ExecSQL('CREATE TABLE IF NOT EXISTS TAB_TREINO_EXERCICIO ( ' +
                            'ID_TREINO_EXERCICIO  INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, ' +
                            'ID_TREINO            INTEGER,' +
                            'TREINO               VARCHAR(100),' +
                            'DESCR_TREINO         VARCHAR(100),' +
                            'DIA_SEMANA           INTEGER,' +
                            'ID_EXERCICIO         INTEGER,' +
                            'EXERCICIO            VARCHAR(100),' +
                            'DESCR_EXERCICIO      VARCHAR(1000),' +
                            'DURACAO              VARCHAR(100),' +
                            'URL_VIDEO            VARCHAR(1000), ' +
                            'INCLUSAO             SMALLINT);'
                );

    // Treinos finalizados via mobile...
    Conn.ExecSQL('CREATE TABLE IF NOT EXISTS TAB_ATIVIDADE_HISTORICO ( ' +
                            'ID_HISTORICO   INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, ' +
                            'ID_TREINO      INTEGER, ' +
                            'DT_ATIVIDADE   DATETIME);'
                );

    // Treino em andamento via mobile...
    Conn.ExecSQL('CREATE TABLE IF NOT EXISTS TAB_ATIVIDADE ( ' +
                            'ID_ATIVIDADE   INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, ' +
                            'ID_TREINO      INTEGER, ' +
                            'ID_EXERCICIO   INTEGER, ' +
                            'EXERCICIO      VARCHAR(100),' +
                            'DURACAO        VARCHAR(100),' +
                            'IND_CONCLUIDO  CHAR(1));'
                );
end;

procedure TDmGlobal.ConnBeforeConnect(Sender: TObject);
begin
    Conn.DriverName := 'SQLite';

    {$IFDEF MSWINDOWS}
    Conn.Params.Values['Database'] := System.SysUtils.GetCurrentDir + '\banco.db';
    {$ELSE}
    Conn.Params.Values['Database'] := TPath.Combine(TPath.GetDocumentsPath, 'banco.db');
    {$ENDIF}
end;

procedure TDmGlobal.DataModuleCreate(Sender: TObject);
begin
    TDataSetSerializeConfig.GetInstance.CaseNameDefinition := cndLower;
    TDataSetSerializeConfig.GetInstance.Import.DecimalSeparator := '.';

    Conn.Connected := true;
end;

procedure TDmGlobal.LoginOnline(email, senha: string);
var
    resp: IResponse;
    json: TJSONObject;
begin
    TabUsuario.FieldDefs.Clear;

    try
        json := TJSONObject.Create;
        json.AddPair('email', email);
        json.AddPair('senha', senha);

        resp := TRequest.New.BaseURL(BASE_URL)
                .Resource('usuarios/loginpro')
                .AddBody(json.ToJSON)
                .BasicAuthentication('DCCoders', 'TheoBia1420')
                .Accept('application/json')
                .DataSetAdapter(TabUsuario)
                .Post;

        if resp.StatusCode <> 200 then
            raise Exception.Create(resp.Content);

    finally
        json.DisposeOf;
    end;
end;

procedure TDmGlobal.AlterarExercicioOnline(id_exercicio: integer;  nome, descricao, url: string);
var
    resp: IResponse;
    json: TJSONObject;
begin
    tabExercicios.FieldDefs.Clear;

    if nome = 'Informe o exercício' then
      nome := '';

    if descricao = 'Informe a descrição' then
      descricao := nome;

    if url = 'Informe o link' then
      url := '';


    try
        json := TJSONObject.Create;
        json.AddPair('id_exercicio', id_exercicio);
        json.AddPair('nome', nome);
        json.AddPair('descricao', descricao);
        json.AddPair('url', url);

        resp := TRequest.New.BaseURL(BASE_URL)
                .Resource('exercicios/alterar')
                .AddBody(json.ToJSON)
                .BasicAuthentication('DCCoders', 'TheoBia1420')
                .Accept('application/json')
                .DataSetAdapter(tabExercicios)
                .Post;

        if resp.StatusCode <> 200 then
            raise Exception.Create(resp.Content);

    finally
        json.DisposeOf;
    end;
end;

procedure TDmGlobal.IncluirExercicioOnline(nome, descricao, url: string);
var
    resp: IResponse;
    json: TJSONObject;
begin
    tabExercicios.FieldDefs.Clear;

    try
        if nome = 'Informe o exercício' then
          nome := '';

        if (descricao = 'Informe a descrição') or (trim(descricao) = '') then
          descricao := nome;

        if url = 'Informe o link' then
          url := '';

        json := TJSONObject.Create;
        json.AddPair('descricao', descricao);
        json.AddPair('nome', nome);
        json.AddPair('url', url);

        resp := TRequest.New.BaseURL(BASE_URL)
                .Resource('exercicios/incluir')
                .AddBody(json.ToJSON)
                .BasicAuthentication('DCCoders', 'TheoBia1420')
                .Accept('application/json')
                .DataSetAdapter(tabExercicios)
                .Post;

        if resp.StatusCode <> 201 then
            raise Exception.Create(resp.Content);

    finally
        json.DisposeOf;
    end;
end;

procedure TDmGlobal.IncluirTreinoExercicioOnline(id_treino, id_exercicio, id_professor: Integer; duracao: string);
var
    resp: IResponse;
    json: TJSONObject;
begin
    tabIncTreino.FieldDefs.Clear;

    try
        json := TJSONObject.Create;
        json.AddPair('id_treino', id_treino);
        json.AddPair('id_exercicio', id_exercicio);
        json.AddPair('id_professor', id_professor);
        json.AddPair('duracao', duracao);

        resp := TRequest.New.BaseURL(BASE_URL)
                .Resource('treinos/exercicios/incluir')
                .AddBody(json.ToJSON)
                .BasicAuthentication('DCCoders', 'TheoBia1420')
                .Accept('application/json')
                .DataSetAdapter(tabIncTreino)
                .Post;

        if resp.StatusCode <> 201 then
            raise Exception.Create(resp.Content);

    finally
        json.DisposeOf;
    end;

end;

procedure TDmGlobal.IncluirTreinoOnline(id_usuario, dia_semana:Integer;  nome, descricao: string);
var
    resp: IResponse;
    json: TJSONObject;
begin
    tabIncTreino.FieldDefs.Clear;

    try
        json := TJSONObject.Create;
        json.AddPair('id_usuario', id_usuario);
        json.AddPair('nome', nome);
        json.AddPair('descricao', descricao);
        json.AddPair('dia_semana', dia_semana);

        resp := TRequest.New.BaseURL(BASE_URL)
                .Resource('treinos/incluir')
                .AddBody(json.ToJSON)
                .BasicAuthentication('DCCoders', 'TheoBia1420')
                .Accept('application/json')
                .DataSetAdapter(tabIncTreino)
                .Post;

        if resp.StatusCode <> 201 then
            raise Exception.Create(resp.Content);

    finally
        json.DisposeOf;
    end;

end;

procedure TDmGlobal.ClonarTreinoOnline(id_usuario_origem, id_usuario_destino, id_professor: Integer);
var
    resp: IResponse;
    json: TJSONObject;
begin
    tabCloneTreino.FieldDefs.Clear;

    try
        json := TJSONObject.Create;
        json.AddPair('id_usuario_origem', id_usuario_origem);
        json.AddPair('id_usuario_destino', id_usuario_destino);
        json.AddPair('id_professor', id_professor);

        resp := TRequest.New.BaseURL(BASE_URL)
                .Resource('treinos/clonar')
                .AddBody(json.ToJSON)
                .BasicAuthentication('DCCoders', 'TheoBia1420')
                .Accept('application/json')
                .DataSetAdapter(tabCloneTreino)
                .Post;

        if resp.StatusCode <> 201 then
            raise Exception.Create(resp.Content);

    finally
        json.DisposeOf;
    end;

end;

procedure TDmGlobal.AlterarTreinoOnline(id_treino, id_usuario, dia_semana:Integer;  nome, descricao: string);
var
    resp: IResponse;
    json: TJSONObject;
begin
    tabIncTreino.FieldDefs.Clear;

    try
        json := TJSONObject.Create;
        json.AddPair('id_treino',  id_treino);
        json.AddPair('id_usuario', id_usuario);
        json.AddPair('nome', nome);
        json.AddPair('descricao', descricao);
        json.AddPair('dia_semana', dia_semana);

        resp := TRequest.New.BaseURL(BASE_URL)
                .Resource('treinos/alterar')
                .AddBody(json.ToJSON)
                .BasicAuthentication('DCCoders', 'TheoBia1420')
                .Accept('application/json')
                .DataSetAdapter(tabIncTreino)
                .Post;

        if resp.StatusCode <> 200 then
            raise Exception.Create(resp.Content);

    finally
        json.DisposeOf;
    end;

end;

procedure TDmGlobal.CriarContaOnline(nome, email, senha: string);
var
    resp: IResponse;
    json: TJSONObject;
begin
    TabUsuario.FieldDefs.Clear;

    try
        json := TJSONObject.Create;
        json.AddPair('nome', nome);
        json.AddPair('email', email);
        json.AddPair('senha', senha);

        resp := TRequest.New.BaseURL(BASE_URL)
                .Resource('usuarios/registro')
                .AddBody(json.ToJSON)
                .BasicAuthentication('DCCoders', 'TheoBia1420')
                .Accept('application/json')
                .DataSetAdapter(TabUsuario)
                .Post;

        if resp.StatusCode <> 201 then
            raise Exception.Create(resp.Content);

    finally
        json.DisposeOf;
    end;
end;

procedure TDmGlobal.InserirUsuario(id_usuario: integer;
                                   nome, email, senha: string);
begin
    with qryUsuario do
    begin
        Active := false;
        SQL.Clear;
        SQL.Add('delete from tab_usuario where id_usuario <> :id_usuario');
        ParamByName('id_usuario').Value := id_usuario;
        ExecSQL;

        Active := false;
        SQL.Clear;
        SQL.Add('select * from tab_usuario');
        Active := true;

        if RecordCount = 0 then
        begin
            Active := false;
            SQL.Clear;
            SQL.Add('insert into tab_usuario(id_usuario, nome, email, pontos, senha)');
            SQL.Add('values(:id_usuario, :nome, :email, 0, :senha)');

            ParamByName('id_usuario').Value := id_usuario;
            ParamByName('nome').Value  := nome;
            ParamByName('email').Value := email;
            ParamByName('senha').Value := senha;

            ExecSQL;
        end
        else
        begin
            Active := false;
            SQL.Clear;
            SQL.Add('update tab_usuario set nome=:nome, email=:email');
            ParamByName('nome').Value := nome;
            ParamByName('email').Value := email;

            ExecSQL;
        end;
    end;
end;

procedure TDmGlobal.ListarUsuario;
begin
    with qryUsuario do
    begin
        Active := false;
        SQL.Clear;
        SQL.Add('select * from tab_usuario');
        Active := true;
    end;
end;

procedure TDmGlobal.EditarUsuario(nome, email: string);
begin
    with qryUsuario do
    begin
        Active := false;
        SQL.Clear;
        SQL.Add('update tab_usuario set nome=:nome, email=:email');
        ParamByName('nome').Value := nome;
        ParamByName('email').Value := email;
        ExecSQL;
    end;
end;

procedure TDmGlobal.EditarUsuarioOnline(id_usuario: integer;
                                        nome, email: string);
var
    resp: IResponse;
    json: TJSONObject;
begin
    try
        json := TJSONObject.Create;
        json.AddPair('id_usuario', TJSONNumber.Create(id_usuario));
        json.AddPair('nome', nome);
        json.AddPair('email', email);

        resp := TRequest.New.BaseURL(BASE_URL)
                .Resource('usuarios')
                .AddBody(json.ToJSON)
                .BasicAuthentication('DCCoders', 'TheoBia1420')
                .Accept('application/json')
                .Put;

        if resp.StatusCode <> 200 then
            raise Exception.Create(resp.Content);

    finally
        json.DisposeOf;
    end;
end;

procedure TDmGlobal.EditarSenhaOnline(id_usuario: integer;
                                      senha: string);
var
    resp: IResponse;
    json: TJSONObject;
begin
    try
        json := TJSONObject.Create;
        json.AddPair('id_usuario', TJSONNumber.Create(id_usuario));
        json.AddPair('senha', senha);

        resp := TRequest.New.BaseURL(BASE_URL)
                .Resource('usuarios/senha')
                .AddBody(json.ToJSON)
                .BasicAuthentication('DCCoders', 'TheoBia1420')
                .Accept('application/json')
                .Put;

        if resp.StatusCode <> 200 then
            raise Exception.Create(resp.Content);

    finally
        json.DisposeOf;
    end;
end;

procedure TDmGlobal.ListarTreinoExercicioOnline(id_usuario: integer);
var
    resp: IResponse;
begin
    tabTreino.FieldDefs.Clear;

    // http://localhost:3000/treinos?id_usuario=1

    resp := TRequest.New.BaseURL(BASE_URL)
            .Resource('treinos')
            .AddParam('id_usuario', id_usuario.ToString)
            .BasicAuthentication('DCCoders', 'TheoBia1420')
            .Accept('application/json')
            .DataSetAdapter(tabTreino
            )
            .Get;

    if resp.StatusCode <> 200 then
        raise Exception.Create(resp.Content);
end;

procedure TDmGlobal.ListarTreinoUsuarioOnline(id_usuario: integer);
var
    resp: IResponse;
begin
    tabTreinos.FieldDefs.Clear;

    // http://localhost:3000/treinos?id_usuario=1

    resp := TRequest.New.BaseURL(BASE_URL)
            .Resource('treinos/usuario')
            .AddParam('id_usuario', id_usuario.ToString)
            .BasicAuthentication('DCCoders', 'TheoBia1420')
            .Accept('application/json')
            .DataSetAdapter(tabTreinos)
            .Get;

    if resp.StatusCode <> 200 then
        raise Exception.Create(resp.Content);
end;


procedure TDmGlobal.ExcluirTreinoExercicio;
begin
    Conn.ExecSQL('delete from tab_treino_exercicio');
end;

procedure TDmGlobal.ExcluirTreinoExercicioOnline(id_treino,id_exercicio: Integer);
  var
    resp: IResponse;
    json: TJSONObject;
begin
    tabDeleteTreinoExercicio.FieldDefs.Clear;

    try
        json := TJSONObject.Create;
        //json.AddPair('id_treino', id_treino);
        //json.AddPair('id_exercicio', id_exercicio);

        resp := TRequest.New.BaseURL(BASE_URL + '/'+ 'treinos/exercicios/excluir/'+ id_treino.ToString + '/' + id_exercicio.ToString)
                //.Resource('treinos/exercicios/excluir/'+ id_treino.ToString + '/' + id_exercicio.ToString)
                .BasicAuthentication('DCCoders', 'TheoBia1420')
                .Accept('application/json')
                //.DataSetAdapter(tabDeleteTreinoExercicio)
                .Delete;

        if resp.StatusCode <> 204 then
            raise Exception.Create(resp.Content)
        else
        begin
          with qryTreinoExercicio do
          begin
              Active := false;
              SQL.Clear;
              SQL.Add('delete from TAB_TREINO_EXERCICIO       ');
              SQL.Add(' where ID_TREINO = :ID_TREINO          ');
              SQL.Add('   and ID_EXERCICIO = :ID_EXERCICIO    ');

              ParamByName('id_treino').Value       := id_treino;
              ParamByName('ID_EXERCICIO').Value    := id_exercicio;

              ExecSql;
          end;
        end;

    finally
        json.DisposeOf;
    end;
end;

procedure TDmGlobal.ExcluirTreinoOnline(id_treino: Integer);
  var
    resp: IResponse;
    json: TJSONObject;
begin
    tabDeleteTreinoExercicio.FieldDefs.Clear;

    try
        json := TJSONObject.Create;
        //json.AddPair('id_treino', id_treino);
        //json.AddPair('id_exercicio', id_exercicio);

        resp := TRequest.New.BaseURL(BASE_URL + '/'+ 'treinos/exercicios/excluircompleto/'+ id_treino.ToString)
                //.Resource('treinos/exercicios/excluir/'+ id_treino.ToString + '/' + id_exercicio.ToString)
                .BasicAuthentication('DCCoders', 'TheoBia1420')
                .Accept('application/json')
                //.DataSetAdapter(tabDeleteTreinoExercicio)
                .Delete;

        if resp.StatusCode <> 204 then
            raise Exception.Create(resp.Content)
        else
        begin
          with qryTreinoExercicio do
          begin
              Active := false;
              SQL.Clear;
              SQL.Add('delete from TAB_TREINO_EXERCICIO       ');
              SQL.Add(' where ID_TREINO = :ID_TREINO          ');

              ParamByName('id_treino').Value       := id_treino;

              ExecSql;
          end;
        end;

    finally
        json.DisposeOf;
    end;
end;

procedure TDmGlobal.ExercicioOnline(busca: string);
var
    resp: IResponse;
begin
  tabExercicios.FieldDefs.Clear;

  resp := TRequest.New.BaseURL(BASE_URL)
            .Resource('exercicios')
            .AddParam('busca', busca)
            .BasicAuthentication('DCCoders', 'TheoBia1420')
            .Accept('application/json')
            .DataSetAdapter(tabExercicios)
            .Get;

    if resp.StatusCode <> 200 then
        raise Exception.Create(resp.Content);
end;

procedure TDmGlobal.UsuarioOnline(busca: string);
var
    resp: IResponse;
begin
  tabUsuarios.FieldDefs.Clear;

  resp := TRequest.New.BaseURL(BASE_URL)
            .Resource('usuarios')
            .AddParam('busca', busca)
            .BasicAuthentication('DCCoders', 'TheoBia1420')
            .Accept('application/json')
            .DataSetAdapter(tabUsuarios)
            .Get;

    if resp.StatusCode <> 200 then
        raise Exception.Create(resp.Content);
end;

procedure TDmGlobal.InserirTreinoExercicio(id_treino: integer;
                                           treino, descr_treino: string;
                                           dia_semana, id_exercicio: integer;
                                           exercicio, descr_exercicio, duracao, url_video: string;
                                           inclusao : Boolean = False);
begin
    with qryTreinoExercicio do
    begin
        Active := false;
        SQL.Clear;
        SQL.Add('insert into tab_treino_exercicio(id_treino, treino, descr_treino,');
        SQL.Add('dia_semana, id_exercicio, exercicio, descr_exercicio, duracao, url_video, inclusao)');
        SQL.Add('values(:id_treino, :treino, :descr_treino,');
        SQL.Add(':dia_semana, :id_exercicio, :exercicio, :descr_exercicio, :duracao, :url_video, :inclusao)');

        ParamByName('id_treino').Value := id_treino;
        ParamByName('treino').Value := treino;
        ParamByName('descr_treino').Value := descr_treino;
        ParamByName('dia_semana').Value := dia_semana;
        ParamByName('id_exercicio').Value := id_exercicio;
        ParamByName('exercicio').Value := exercicio;
        ParamByName('descr_exercicio').Value := descr_exercicio;
        ParamByName('duracao').Value := duracao;
        ParamByName('url_video').Value := url_video;

        if inclusao then
          ParamByName('inclusao').Value := 1
        else
          ParamByName('inclusao').Value := 0;

        ExecSQL;
    end;
end;

function TDmGlobal.TreinosMes(dt: TDateTime): integer;
begin
    with qryConsEstatistica do
    begin
        Active := false;
        SQL.Clear;
        SQL.Add('select id_historico from tab_atividade_historico');
        SQL.Add('where dt_atividade >= :dt1');
        SQL.Add('and dt_atividade <= :dt2');

        ParamByName('dt1').Value := FormatDateTime('yyyy-mm-dd', StartOfTheMonth(dt)); // System.DateUtils
        ParamByName('dt2').Value := FormatDateTime('yyyy-mm-dd', EndOfTheMonth(dt));

        Active := true;

        Result := RecordCount;
    end;
end;

function TDmGlobal.Pontuacao(): integer;
begin
    with qryConsEstatistica do
    begin
        Active := false;
        SQL.Clear;
        SQL.Add('select ifnull(pontos, 0) as pontos from tab_usuario');
        Active := true;

        Result := fieldbyname('pontos').AsInteger;
    end;
end;

procedure TDmGlobal.TreinoSugerido(dt: TDateTime);
begin
    with qryConsEstatistica do
    begin
        Active := false;
        SQL.Clear;
        SQL.Add('select * from tab_treino_exercicio');
        SQL.Add('where dia_semana = :dia_semana');


        ParamByName('dia_semana').Value := DayOfWeek(dt);

        Active := true;
    end;
end;

procedure TDmGlobal.ListarTreinos;
begin
    with qryConsTreino do
    begin
        Active := false;
        SQL.Clear;
        SQL.Add('select distinct id_treino, treino, descr_treino');
        SQL.Add('from tab_treino_exercicio');
        SQL.Add('order by dia_semana');
        Active := true;
    end;
end;

procedure TDmGlobal.ListarExercicios(id_treino: integer);
begin
    with qryConsExercicio do
    begin
        Active := false;
        SQL.Clear;
        SQL.Add('select * from tab_treino_exercicio');
        SQL.Add('where id_treino = :id_treino');
        SQL.Add('order by ID_TREINO_EXERCICIO');

        ParamByName('id_treino').Value := id_treino;

        Active := true;
    end;
end;

procedure TDmGlobal.DetalheExercicio(id_exercicio: integer);
begin
    with tabExercicios do
    begin
        Filtered := False;
        filter   := 'id_exercicio  = ' + id_exercicio.ToString;
        Filtered := True;
    end;
end;

procedure TDmGlobal.IniciarTreino(id_treino: integer);
begin
    with qryAtividade do
    begin
        Active := false;
        SQL.Clear;
        SQL.Add('delete from tab_atividade');
        ExecSQL;


        Active := false;
        SQL.Clear;
        SQL.Add('insert into tab_atividade(id_treino, id_exercicio, exercicio, duracao, ind_concluido)');
        SQL.Add('select id_treino, id_exercicio, exercicio, duracao, ''N''  ');
        SQL.Add('  from tab_treino_exercicio');
        SQL.Add(' where id_treino = :id_treino');
         SQL.Add('order by id_exercicio ');

        ParamByName('id_treino').Value := id_treino;

        ExecSQL;
    end;
end;

procedure TDmGlobal.ListarExerciciosAtividade;
begin
    with qryConsExercicio do
    begin
        Active := false;
        SQL.Clear;
        SQL.Add('select * from tab_atividade');
        SQL.Add('order by exercicio');
        Active := true;
    end;
end;

procedure TDmGlobal.FinalizarTreino(id_treino: integer);
begin
    with qryGeral do
    begin
        Active := false;
        SQL.Clear;
        SQL.Add('insert into tab_atividade_historico(id_treino, dt_atividade)');
        SQL.Add('values(:id_treino, :dt_atividade)');
        ParamByName('id_treino').Value := id_treino;
        ParamByName('dt_atividade').Value := FormatDateTime('yyyy-mm-dd', now);;
        ExecSQL;

        Active := false;
        SQL.Clear;
        SQL.Add('delete from tab_atividade');
        ExecSQL;

        Active := false;
        SQL.Clear;
        SQL.Add('update tab_usuario set pontos = ifnull(pontos, 0) + 10');
        ExecSQL;
    end;
end;

procedure TDmGlobal.MarcarExercicioConcluido(id_exercicio: integer;
                                             ind_concluido: boolean);
begin
    with qryGeral do
    begin
        Active := false;
        SQL.Clear;
        SQL.Add('update tab_atividade set ind_concluido = :ind_concluido');
        SQL.Add('where id_exercicio = :id_exercicio');

        ParamByName('id_exercicio').Value := id_exercicio;

        if ind_concluido then
            ParamByName('ind_concluido').Value := 'S'
        else
            ParamByName('ind_concluido').Value := 'N';

        ExecSQL;
    end;
end;

procedure TDmGlobal.Logout;
begin
    Conn.ExecSQL('delete from tab_atividade_historico');
    Conn.ExecSQL('delete from tab_treino_exercicio');
    Conn.ExecSQL('delete from tab_atividade');
    Conn.ExecSQL('delete from tab_usuario');
end;

end.

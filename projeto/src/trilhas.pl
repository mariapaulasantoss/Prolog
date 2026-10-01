:- encoding(utf8).

% =====================================================================
% Camada 3 - Fecho transitivo e geracao de trilhas
% Depende de: curriculum.pl (fatos) e elegibilidade.pl (aluno_valido/1)
% =====================================================================

% ---------------------------------------------------------------------
% Parametros do curso
% ---------------------------------------------------------------------

% Rede de seguranca: nenhuma trilha simula mais que 12 semestres.
max_semestres(12).

% Regra de formatura: todas as obrigatorias + 90 horas de eletivas.
% Cada credito equivale a 1 aula semanal num semestre de 15 semanas,
% ou seja, 15 horas. 90 horas = 6 creditos de eletivas.
horas_por_credito(15).
horas_eletivas_minimas(90).

creditos_eletivas_minimos(Creditos) :-
    horas_eletivas_minimas(Horas),
    horas_por_credito(HorasPorCredito),
    Creditos is Horas // HorasPorCredito.

% ---------------------------------------------------------------------
% Fecho transitivo
% ---------------------------------------------------------------------

% prerequisito_transitivo(Disciplina, Ancestral)
% Ancestral e pre-requisito direto ou indireto de Disciplina.
% A lista de visitados impede que um ciclo na base vire loop infinito:
% a recursao nunca expande duas vezes a mesma disciplina no mesmo caminho.
prerequisito_transitivo(Disciplina, Ancestral) :-
    prerequisito_transitivo(Disciplina, Ancestral, [Disciplina]).

% Caso base: pre-requisito direto.
prerequisito_transitivo(Disciplina, Ancestral, _) :-
    prerequisito(Disciplina, Ancestral).
% Caso recursivo: pre-requisito de um pre-requisito ainda nao visitado.
prerequisito_transitivo(Disciplina, Ancestral, Visitados) :-
    prerequisito(Disciplina, Intermediaria),
    \+ memberchk(Intermediaria, Visitados),
    prerequisito_transitivo(Intermediaria, Ancestral, [Intermediaria|Visitados]).

% Todos os ancestrais de uma disciplina, sem repeticao e ordenados.
% setof (e nao findall) porque dois caminhos diferentes podem levar ao
% mesmo ancestral; o "-> ; L = []" trata o caso de nao haver nenhum,
% em que setof falharia.
ancestrais(Disciplina, Lista) :-
    disciplina(Disciplina, _, _, _),
    (   setof(A, prerequisito_transitivo(Disciplina, A), Lista)
    ->  true
    ;   Lista = []
    ).

% ---------------------------------------------------------------------
% Deteccao de ciclos
% ---------------------------------------------------------------------

% existe_ciclo(Disciplina): a disciplina e pre-requisito de si mesma.
% Funciona com Disciplina livre (enumera as que estao em ciclo) ou
% instanciada. once/1 evita respostas repetidas quando ha mais de um
% caminho de volta.
existe_ciclo(Disciplina) :-
    setof(D, P^prerequisito(D, P), ComPrerequisito),
    member(Disciplina, ComPrerequisito),
    once(prerequisito_transitivo(Disciplina, Disciplina)).

base_sem_ciclos :-
    \+ existe_ciclo(_).

% ---------------------------------------------------------------------
% Geracao de trilhas
% ---------------------------------------------------------------------

% trilha_valida(Aluno, MaxCreditosPorSemestre, Trilha)
% Trilha e uma lista de semestres; cada semestre e uma lista de
% disciplinas. O historico simulado e passado como argumento (lista),
% sem assert/retract, para o backtracking desfazer tudo sozinho.
trilha_valida(Aluno, MaxCreditos, Trilha) :-
    entrada_trilha_ok(Aluno, MaxCreditos),
    findall(D, cursou(Aluno, D), Historico),
    max_semestres(Limite),
    planejar(Historico, MaxCreditos, Limite, Trilha).

% Ate N trilhas diferentes para o mesmo aluno. Pedir "todas" nao e
% viavel (o numero cresce de forma combinatoria), entao o numero e
% sempre limitado. findnsols/4 e nativo do SWI-Prolog.
trilhas_validas(Aluno, MaxCreditos, N, Trilhas) :-
    integer(N), N > 0,
    findnsols(N, T, trilha_valida(Aluno, MaxCreditos, T), Trilhas),
    !.

% Validacoes de entrada: falham com uma mensagem clara, sem excecao.
entrada_trilha_ok(Aluno, MaxCreditos) :-
    (   var(Aluno)
    ->  aviso('informe o aluno (um atomo), nao uma variavel', []), fail
    ;   \+ aluno_valido(Aluno)
    ->  aviso('aluno ~w nao esta cadastrado', [Aluno]), fail
    ;   \+ (integer(MaxCreditos), MaxCreditos > 0)
    ->  aviso('o limite de creditos deve ser um inteiro positivo (recebido: ~w)', [MaxCreditos]), fail
    ;   existe_ciclo(D)
    ->  aviso('a base tem ciclo de pre-requisitos (ex.: ~w); trilha cancelada', [D]), fail
    ;   disciplina(D, obrigatoria, C, _), \+ cursou(Aluno, D), C > MaxCreditos
    ->  aviso('~w tem ~w creditos, acima do limite de ~w por semestre', [D, C, MaxCreditos]), fail
    ;   true
    ).

aviso(Formato, Args) :-
    format('[trilha] '),
    format(Formato, Args),
    nl.

% planejar(Historico, MaxCreditos, SemestresRestantes, Trilha)
% Caso base: o aluno ja cumpre a regra de formatura -> trilha termina.
% O cut impede que se continue adicionando semestres depois de formado.
planejar(Historico, _, _, []) :-
    formado(Historico),
    !.
% Caso recursivo: monta mais um semestre e segue com o historico ampliado.
planejar(Historico, MaxCreditos, Restantes, [Semestre|Trilha]) :-
    Restantes > 0,
    ainda_viavel(Historico, MaxCreditos, Restantes),
    candidatas(Historico, Candidatas),
    falta_eletivas(Historico, FaltaEletivas),
    escolher(Candidatas, MaxCreditos, FaltaEletivas, Semestre),
    Semestre \== [],
    append(Historico, Semestre, NovoHistorico),
    Restantes1 is Restantes - 1,
    planejar(NovoHistorico, MaxCreditos, Restantes1, Trilha).

% Regra de formatura.
formado(Historico) :-
    forall(disciplina(D, obrigatoria, _, _), memberchk(D, Historico)),
    creditos_eletivas(Historico, Eletivas),
    creditos_eletivas_minimos(Minimo),
    Eletivas >= Minimo.

creditos_eletivas(Historico, Total) :-
    findall(C, (member(D, Historico), disciplina(D, eletiva, C, _)), Cs),
    sum_list(Cs, Total).

% ---------------------------------------------------------------------
% Poda: corta cedo os ramos que nao tem como chegar a formatura
% ---------------------------------------------------------------------

% 1) Creditos: o que falta nao cabe nos semestres que sobram.
% 2) Profundidade: alguma obrigatoria pendente esta no fim de uma cadeia
%    com mais elos pendentes do que semestres restantes.
ainda_viavel(Historico, MaxCreditos, Restantes) :-
    creditos_faltando(Historico, Falta),
    Falta =< MaxCreditos * Restantes,
    forall(
        ( disciplina(D, obrigatoria, _, _), \+ memberchk(D, Historico) ),
        ( profundidade_pendente(D, Historico, P), P =< Restantes )
    ).

creditos_faltando(Historico, Falta) :-
    findall(C,
            ( disciplina(D, obrigatoria, C, _), \+ memberchk(D, Historico) ),
            Cs),
    sum_list(Cs, Obrigatorias),
    falta_eletivas(Historico, FaltaEletivas),
    Falta is Obrigatorias + FaltaEletivas.

% Quantos semestres, no minimo, ainda sao necessarios para cursar D.
profundidade_pendente(D, Historico, 0) :-
    memberchk(D, Historico),
    !.
profundidade_pendente(D, Historico, P) :-
    findall(PP,
            ( prerequisito(D, Pre), profundidade_pendente(Pre, Historico, PP) ),
            Ps),
    max_list([0|Ps], Maior),
    P is Maior + 1.

% ---------------------------------------------------------------------
% Escolha das disciplinas de um semestre
% ---------------------------------------------------------------------

% Disciplinas que podem entrar no proximo semestre, em ordem de
% prioridade: obrigatorias antes de eletivas; dentro delas, as que
% "seguram" cadeias mais longas primeiro; depois o semestre sugerido.
% Eletivas so entram enquanto a carga minima de eletivas nao foi atingida.
candidatas(Historico, Ordenadas) :-
    findall(Chave-D,
            ( disciplina(D, Tipo, _, Sugerido),
              \+ memberchk(D, Historico),
              liberada(D, Historico),
              tipo_aceito(Tipo, Historico),
              prioridade(D, Tipo, Sugerido, Chave) ),
            Pares),
    keysort(Pares, ParesOrdenados),
    pairs_values(ParesOrdenados, Ordenadas).

% Pre-requisitos diretos ja estao no historico simulado. Como o
% historico so cresce com disciplinas liberadas, os indiretos tambem estao.
liberada(D, Historico) :-
    forall(prerequisito(D, Pre), memberchk(Pre, Historico)).

tipo_aceito(obrigatoria, _).
tipo_aceito(eletiva, Historico) :-
    creditos_eletivas(Historico, Feitas),
    creditos_eletivas_minimos(Minimo),
    Feitas < Minimo.

prioridade(D, Tipo, Sugerido, p(OrdemTipo, AlturaNeg, Sugerido)) :-
    ( Tipo == obrigatoria -> OrdemTipo = 0 ; OrdemTipo = 1 ),
    altura(D, Altura),
    AlturaNeg is -Altura.

% Altura = tamanho da maior cadeia de disciplinas que dependem de D.
% So e chamada depois de entrada_trilha_ok/2 garantir que nao ha ciclo.
altura(D, Altura) :-
    findall(A1,
            ( prerequisito(Dependente, D), altura(Dependente, A0), A1 is A0 + 1 ),
            As),
    max_list([0|As], Altura).

% escolher(Candidatas, CreditosLivres, FaltaEletivas, Semestre)
% Para cada candidata: primeiro tenta incluir (se couber), depois pular.
% A primeira resposta e "gulosa" (enche o semestre por prioridade); as
% demais, por backtracking, geram as trilhas alternativas.
% FaltaEletivas impede de colocar no semestre mais eletivas do que o
% necessario para fechar a carga minima.
escolher([], _, _, []).
escolher([D|Ds], Livres, FaltaEletivas, [D|Semestre]) :-
    disciplina(D, Tipo, C, _),
    C =< Livres,
    eletiva_permitida(Tipo, C, FaltaEletivas, FaltaEletivas1),
    Livres1 is Livres - C,
    escolher(Ds, Livres1, FaltaEletivas1, Semestre).
escolher([_|Ds], Livres, FaltaEletivas, Semestre) :-
    escolher(Ds, Livres, FaltaEletivas, Semestre).

eletiva_permitida(obrigatoria, _, Falta, Falta).
eletiva_permitida(eletiva, C, Falta, Falta1) :-
    Falta > 0,
    Falta1 is max(0, Falta - C).

falta_eletivas(Historico, Falta) :-
    creditos_eletivas(Historico, Feitas),
    creditos_eletivas_minimos(Minimo),
    Falta is max(0, Minimo - Feitas).

% ---------------------------------------------------------------------
% Conferencia e exibicao
% ---------------------------------------------------------------------

% Confere uma trilha pronta usando o fecho transitivo: toda disciplina
% vem depois de TODOS os seus pre-requisitos (diretos e indiretos).
trilha_respeita_prerequisitos(Aluno, Trilha) :-
    findall(D, cursou(Aluno, D), Historico),
    respeita(Trilha, Historico).

respeita([], _).
respeita([Semestre|Resto], Historico) :-
    forall(
        ( member(D, Semestre), prerequisito_transitivo(D, A) ),
        memberchk(A, Historico)
    ),
    append(Historico, Semestre, NovoHistorico),
    respeita(Resto, NovoHistorico).

creditos_semestre(Semestre, Total) :-
    findall(C, (member(D, Semestre), disciplina(D, _, C, _)), Cs),
    sum_list(Cs, Total).

mostrar_trilha(Trilha) :-
    mostrar_trilha(Trilha, 1).

mostrar_trilha([], _).
mostrar_trilha([Semestre|Resto], N) :-
    creditos_semestre(Semestre, C),
    format('  Semestre ~w (~w creditos): ~w~n', [N, C, Semestre]),
    N1 is N + 1,
    mostrar_trilha(Resto, N1).

:- encoding(utf8).

% =====================================================================
% Arquivo principal - carrega as tres camadas e oferece demo/0
% Uso:  swipl projeto/src/main.pl   e depois   ?- demo.
% =====================================================================

:- ensure_loaded(curriculum).     % Camada 1: fatos
:- ensure_loaded(elegibilidade).  % Camada 2: regras de elegibilidade
:- ensure_loaded(trilhas).        % Camada 3: fecho transitivo e trilhas

% Limite de creditos por semestre usado nas demonstracoes.
limite_demo(28).

demo :-
    demo_camada1,
    demo_camada2,
    demo_camada3.

titulo(Texto) :-
    format('~n===== ~w =====~n', [Texto]).

% ---------------------------------------------------------------------
demo_camada1 :-
    titulo('Camada 1 - Fatos'),
    findall(D, disciplina(D, _, _, 4), Quarto),
    format('Disciplinas do 4o semestre sugerido: ~w~n', [Quarto]),
    findall(D, disciplina(D, eletiva, _, _), Eletivas),
    format('Eletivas: ~w~n', [Eletivas]).

% ---------------------------------------------------------------------
demo_camada2 :-
    titulo('Camada 2 - Elegibilidade'),
    forall(member(A, [sophia, pedro, vitor, lucas]), resumo_aluno(A)),
    format('~nNegacao por falha decidindo o resultado (programacao_web):~n'),
    ( pode_cursar(vitor, programacao_web) -> R1 = sim ; R1 = nao ),
    ( pode_cursar(pedro, programacao_web) -> R2 = sim ; R2 = nao ),
    format('  vitor (nao cursou) pode cursar? ~w~n', [R1]),
    format('  pedro (ja cursou)  pode cursar? ~w~n', [R2]).

resumo_aluno(A) :-
    creditos_cursados(A, C),
    disciplinas_liberadas(A, L),
    disciplinas_pendentes(A, P),
    length(P, NP),
    format('~n~w: ~w creditos cursados, ~w obrigatorias pendentes~n', [A, C, NP]),
    format('  liberadas: ~w~n', [L]).

% ---------------------------------------------------------------------
demo_camada3 :-
    titulo('Camada 3 - Fecho transitivo e trilhas'),
    ancestrais(processamento_linguagem_natural, Anc),
    format('Pre-requisitos (diretos e indiretos) de processamento_linguagem_natural:~n  ~w~n', [Anc]),
    ( existe_ciclo(_) -> format('ATENCAO: a base tem ciclos!~n')
    ; format('Nenhum ciclo na base de pre-requisitos.~n') ),
    limite_demo(Max),
    demo_trilha(lucas, Max),
    demo_trilha(vitor, Max),
    format('~nTres trilhas alternativas para pedro (limite ~w):~n', [Max]),
    trilhas_validas(pedro, Max, 3, Trilhas),
    forall(nth1(I, Trilhas, T),
           ( format('~n Opcao ~w:~n', [I]), mostrar_trilha(T) )).

demo_trilha(Aluno, Max) :-
    format('~nTrilha de ~w ate a formatura (limite ~w creditos/semestre):~n', [Aluno, Max]),
    (   trilha_valida(Aluno, Max, T)
    ->  length(T, N),
        mostrar_trilha(T),
        format('  => formatura em ~w semestre(s)~n', [N])
    ;   format('  nenhuma trilha encontrada dentro do limite de semestres~n')
    ).

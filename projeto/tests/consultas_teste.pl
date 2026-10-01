:- encoding(utf8).

% Testes: cada caso/2 deve ser verdadeiro. Rodar com ?- rodar_testes.

:- ensure_loaded('../src/main').

% Camada 1
caso('C1: disciplinas do 1o semestre sugerido',
     ( findall(D, disciplina(D, _, _, 1), L),
       L == [fundamentos_de_sistemas_ciberfisicos, resolucao_problemas_com_log_matematica,
             filosofia, ex_criativa_navegando_computacao, raciocinio_algoritmo] )).

caso('C1: requisitos minimos (20+ disciplinas, 6+ semestres, 3+ eletivas)',
     ( aggregate_all(count, disciplina(_, _, _, _), N), N >= 20,
       setof(S, D^T^C^disciplina(D, T, C, S), Sems), length(Sems, NS), NS >= 6,
       aggregate_all(count, disciplina(_, eletiva, _, _), NE), NE >= 3 )).

% Camada 2
caso('C2: sophia (adiantada) ja pode cursar inteligencia_artificial',
     pode_cursar(sophia, inteligencia_artificial)).

caso('C2: pedro nao pode cursar inteligencia_artificial (falta complexidade)',
     \+ pode_cursar(pedro, inteligencia_artificial)).

caso('C2: liberadas de sophia e pedro sao diferentes',
     ( disciplinas_liberadas(sophia, L1), disciplinas_liberadas(pedro, L2),
       L1 \== L2,
       memberchk(complexidade_de_algoritmos, L2),
       \+ memberchk(complexidade_de_algoritmos, L1) )).

caso('C2: pendentes - sophia 21, pedro 23, vitor 25',
     ( disciplinas_pendentes(sophia, P1), length(P1, 21),
       disciplinas_pendentes(pedro, P2),  length(P2, 23),
       disciplinas_pendentes(vitor, P3),  length(P3, 25) )).

caso('C2: negacao por falha - vitor nao cursou programacao_web, entao pode',
     pode_cursar(vitor, programacao_web)).
caso('C2: negacao por falha - pedro ja cursou programacao_web, entao nao pode',
     \+ pode_cursar(pedro, programacao_web)).

caso('C2: creditos cursados (sophia 108, pedro 100, vitor 94)',
     ( creditos_cursados(sophia, 108),
       creditos_cursados(pedro, 100),
       creditos_cursados(vitor, 94) )).

caso('C2: disciplina com varios pre-requisitos cumpridos parcialmente nao libera',
     \+ pode_cursar(vitor, inteligencia_artificial)).

caso('Borda: aluno sem historico (lucas) tem 0 creditos e 1o semestre liberado',
     ( creditos_cursados(lucas, 0),
       disciplinas_liberadas(lucas, L),
       memberchk(programacao_imperativa, L),
       \+ memberchk(poo, L) )).
caso('Borda: aluno inexistente falha sem excecao',
     \+ disciplinas_liberadas(fulano, _)).
caso('Borda: disciplina inexistente falha sem excecao',
     ( \+ pode_cursar(sophia, disciplina_que_nao_existe),
       \+ prerequisitos_ok(sophia, disciplina_que_nao_existe) )).

% Camada 3
caso('C3: fecho transitivo na cadeia de profundidade 5 (PLN)',
     ( ancestrais(processamento_linguagem_natural, L),
       L == [aprendizagem_maquina, complexidade_de_algoritmos,
             inteligencia_artificial, poo, programacao_imperativa] )).

caso('C3: ancestral indireto (3 niveis acima) e encontrado',
     prerequisito_transitivo(inteligencia_artificial, programacao_imperativa)).

caso('C3: disciplina sem pre-requisitos nao tem ancestrais',
     ancestrais(filosofia, [])).

caso('C3: base real nao tem ciclos',
     \+ existe_ciclo(_)).

caso('C3: trilha completa do zero (lucas) ate a formatura, limite 28',
     ( trilha_valida(lucas, 28, T),
       length(T, N), N =< 12,
       trilha_respeita_prerequisitos(lucas, T),
       forall(member(S, T), (creditos_semestre(S, C), C =< 28)),
       findall(D, cursou(lucas, D), H0), append(T, Ds), append(H0, Ds, H),
       formado(H) )).

caso('C3: trilha de vitor (atrasado) respeita limite de 20 creditos',
     ( trilha_valida(vitor, 20, T),
       trilha_respeita_prerequisitos(vitor, T),
       forall(member(S, T), (creditos_semestre(S, C), C =< 20)) )).

caso('C3: enumera multiplas trilhas diferentes para o mesmo aluno',
     ( trilhas_validas(pedro, 28, 5, Ts),
       length(Ts, 5),
       sort(Ts, Distintas), length(Distintas, 5) )).

caso('C3: findall enumera TODAS as trilhas de beatriz em 1 semestre (4 trilhas)',
     ( findall(T, trilha_valida(beatriz, 28, 1, T), Ts),
       length(Ts, 4),
       sort(Ts, Distintas), length(Distintas, 4) )).

caso('C3: limite apertado demais falha rapido (nao trava)',
     \+ trilha_valida(lucas, 12, _)).

caso('C3: disciplina maior que o limite e avisada e falha',
     \+ trilha_valida(lucas, 4, _)).

caso('C3: aluno inexistente na trilha falha com mensagem',
     \+ trilha_valida(fulano, 28, _)).

% Executor
rodar_testes :-
    findall(Nome-Objetivo, caso(Nome, Objetivo), Casos),
    length(Casos, Total),
    format('~nRodando ~w testes...~n~n', [Total]),
    findall(ok, ( member(Nome-Objetivo, Casos), executar(Nome, Objetivo) ), Oks),
    length(Oks, Passaram),
    Falharam is Total - Passaram,
    format('~nResultado: ~w passaram, ~w falharam.~n', [Passaram, Falharam]).

executar(Nome, Objetivo) :-
    (   catch(once(Objetivo), Erro, (format('  ERRO  ~w: ~w~n', [Nome, Erro]), fail))
    ->  format('  ok    ~w~n', [Nome])
    ;   format('  FALHOU ~w~n', [Nome]), fail
    ).

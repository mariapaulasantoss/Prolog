:- encoding(utf8).

% =====================================================================
% Teste de deteccao de ciclo - base PROPOSITALMENTE malformada
% Uso:  swipl projeto/tests/teste_ciclo.pl   e depois   ?- rodar_teste_ciclo.
%
% Este arquivo NAO carrega curriculum.pl: tem sua propria base pequena,
% com um ciclo a -> c -> b -> a, e reaproveita as regras das camadas 2 e 3.
% =====================================================================

:- ensure_loaded('../src/elegibilidade').
:- ensure_loaded('../src/trilhas').

disciplina(algoritmos,  obrigatoria, 4, 1).
disciplina(estruturas,  obrigatoria, 4, 2).
disciplina(compiladores, obrigatoria, 4, 3).
disciplina(isolada,     obrigatoria, 4, 1).
disciplina(optativa,    eletiva,     6, 2).

prerequisito(estruturas, algoritmos).
prerequisito(compiladores, estruturas).
prerequisito(algoritmos, compiladores).   % <- ciclo inserido de proposito

aluno(ana).
cursou(ana, isolada).

rodar_teste_ciclo :-
    format('~nDisciplinas em ciclo: '),
    findall(D, existe_ciclo(D), EmCiclo),
    format('~w~n', [EmCiclo]),
    format('existe_ciclo(isolada)? '),
    ( existe_ciclo(isolada) -> writeln(sim) ; writeln(nao) ),
    format('Ancestrais de compiladores (termina mesmo com ciclo): '),
    findall(A, prerequisito_transitivo(compiladores, A), As),
    writeln(As),
    format('Tentando gerar trilha para ana:~n'),
    ( trilha_valida(ana, 12, T) -> writeln(T) ; writeln('  trilha recusada, sem travar') ).

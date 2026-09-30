% Camada 2
% Aluno existe e se possui algum histórico
aluno_valido(Aluno) :-
    cursou(Aluno, _),
    !.

% Todos os pré-requisitos diretos já foram cursados
prerequisitos_ok(Aluno, Disciplina) :-
    aluno_valido(Aluno),
    forall(
        prerequisito(Disciplina, P),
        cursou(Aluno, P)
    ).

% A disciplina pode ser cursada se:
% 1. o aluno existe
% 2. a disciplina existe
% 3. ainda não foi cursada
% 4. todos os pré-requisitos foram cumpridos

pode_cursar(Aluno, Disciplina) :-
    aluno_valido(Aluno),
    disciplina(Disciplina, _, _, _),
    \+ cursou(Aluno, Disciplina),
    prerequisitos_ok(Aluno, Disciplina).

% Lista de disciplinas que o aluno já pode cursar
disciplinas_liberadas(Aluno, Lista) :-
    aluno_valido(Aluno),
    findall(
        D,
        pode_cursar(Aluno, D),
        Lista
    ).

% Lista de disciplinas obrigatórias ainda não cursadas
disciplinas_pendentes(Aluno, Lista) :-
    aluno_valido(Aluno),
    findall(
        D,
        (
            disciplina(D, obrigatoria, _, _),
            \+ cursou(Aluno, D)
        ),
        Lista
    ).

% Calcula o total de créditos já cursados
creditos_cursados(Aluno, Total) :-
    aluno_valido(Aluno),
    findall(
        C,
        (
            cursou(Aluno, D),
            disciplina(D, _, C, _)
        ),
        Cs
    ),
    soma_lista(Cs, Total).

% Soma os elementos de uma lista
soma_lista([], 0).
soma_lista([H|T], Soma) :-
    soma_lista(T, SomaT),
    Soma is H + SomaT.

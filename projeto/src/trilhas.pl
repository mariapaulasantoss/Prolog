:- encoding(utf8).

% Camada 3

% Limite de semestres simulados
max_semestres(12).

% Formatura: todas as obrigatórias + 90h de eletivas (1 crédito = 15h)
horas_por_credito(15).
horas_eletivas_minimas(90).

creditos_eletivas_minimos(Creditos) :-
    horas_eletivas_minimas(Horas),
    horas_por_credito(HorasPorCredito),
    Creditos is Horas // HorasPorCredito.

% Pré-requisitos diretos e indiretos (Visitados evita loop em caso de ciclo)
prerequisito_transitivo(Disciplina, Ancestral) :-
    prerequisito_transitivo(Disciplina, Ancestral, [Disciplina]).

prerequisito_transitivo(Disciplina, Ancestral, _) :-
    prerequisito(Disciplina, Ancestral).
prerequisito_transitivo(Disciplina, Ancestral, Visitados) :-
    prerequisito(Disciplina, Intermediaria),
    \+ memberchk(Intermediaria, Visitados),
    prerequisito_transitivo(Intermediaria, Ancestral, [Intermediaria|Visitados]).

% setof porque o mesmo ancestral pode aparecer por caminhos diferentes
ancestrais(Disciplina, Lista) :-
    disciplina(Disciplina, _, _, _),
    (   setof(A, prerequisito_transitivo(Disciplina, A), Lista)
    ->  true
    ;   Lista = []
    ).

% Disciplina que é pré-requisito dela mesma
existe_ciclo(Disciplina) :-
    setof(D, P^prerequisito(D, P), ComPrerequisito),
    member(Disciplina, ComPrerequisito),
    once(prerequisito_transitivo(Disciplina, Disciplina)).

base_sem_ciclos :-
    \+ existe_ciclo(_).

% Histórico simulado vai como lista (sem assert/retract)
trilha_valida(Aluno, MaxCreditos, Trilha) :-
    max_semestres(Limite),
    trilha_valida(Aluno, MaxCreditos, Limite, Trilha).

% Versão com menos semestres, para usar findall em casos pequenos
trilha_valida(Aluno, MaxCreditos, MaxSemestres, Trilha) :-
    entrada_trilha_ok(Aluno, MaxCreditos),
    max_semestres(Teto),
    integer(MaxSemestres), MaxSemestres >= 0,
    Limite is min(MaxSemestres, Teto),
    findall(D, cursou(Aluno, D), Historico),
    planejar(Historico, MaxCreditos, Limite, Trilha).

% As N primeiras trilhas
trilhas_validas(Aluno, MaxCreditos, N, Trilhas) :-
    integer(N), N > 0,
    findnsols(N, T, trilha_valida(Aluno, MaxCreditos, T), Trilhas),
    !.

% Falha com mensagem em vez de lançar erro
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

% Caso base: já formado
planejar(Historico, _, _, []) :-
    formado(Historico),
    !.
% Monta mais um semestre e continua
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

formado(Historico) :-
    forall(disciplina(D, obrigatoria, _, _), memberchk(D, Historico)),
    creditos_eletivas(Historico, Eletivas),
    creditos_eletivas_minimos(Minimo),
    Eletivas >= Minimo.

creditos_eletivas(Historico, Total) :-
    findall(C, (member(D, Historico), disciplina(D, eletiva, C, _)), Cs),
    sum_list(Cs, Total).

% Poda: os créditos e as cadeias pendentes cabem nos semestres que sobram
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

% Mínimo de semestres para conseguir cursar D
profundidade_pendente(D, Historico, 0) :-
    memberchk(D, Historico),
    !.
profundidade_pendente(D, Historico, P) :-
    findall(PP,
            ( prerequisito(D, Pre), profundidade_pendente(Pre, Historico, PP) ),
            Ps),
    max_list([0|Ps], Maior),
    P is Maior + 1.

% Disciplinas liberadas, obrigatórias primeiro
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

% Maior cadeia de disciplinas que dependem de D
altura(D, Altura) :-
    findall(A1,
            ( prerequisito(Dependente, D), altura(Dependente, A0), A1 is A0 + 1 ),
            As),
    max_list([0|As], Altura).

% Para cada disciplina: tenta incluir, depois pular (backtracking)
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

% Confere uma trilha pronta usando o fecho transitivo
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

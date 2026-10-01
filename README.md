# Prolog — Curriculum Advisor (PjBL1)

Trabalho de Programação Lógica e Funcional. A grade curricular de BCC está representada como uma base de conhecimento em Prolog. A partir dela, o sistema responde:

- quais disciplinas o aluno já pode cursar;
- quais obrigatórias ainda faltam;
- quais são todos os pré-requisitos (diretos e indiretos) de uma disciplina;
- qual é um caminho válido, semestre a semestre, até a formatura.

## Estrutura

```
projeto/
├── src/
│   ├── curriculum.pl      Camada 1: fatos (disciplinas, pré-requisitos, alunos, históricos)
│   ├── elegibilidade.pl   Camada 2: regras (pode_cursar, liberadas, pendentes, créditos)
│   ├── trilhas.pl         Camada 3: fecho transitivo, ciclos e geração de trilhas
│   └── main.pl            carrega tudo e define demo/0
├── tests/
│   ├── consultas_teste.pl bateria de testes com resultado esperado (rodar_testes/0)
│   └── teste_ciclo.pl     base com ciclo proposital (rodar_teste_ciclo/0)
└── docs/
    └── decisoes.md        decisões de modelagem e limitações
```

## Como rodar (SWI-Prolog)

Rode os comandos a partir da raiz do repositório.

```
swipl projeto/src/main.pl
?- demo.
```

```
swipl projeto/tests/consultas_teste.pl
?- rodar_testes.
```

```
swipl projeto/tests/teste_ciclo.pl
?- rodar_teste_ciclo.
```

## Consultas de exemplo

```prolog
?- disciplina(D, _, _, 3).                       % disciplinas do 3º semestre sugerido
?- pode_cursar(vitor, programacao_web).          % true
?- disciplinas_liberadas(pedro, L).
?- disciplinas_pendentes(vitor, L).
?- creditos_cursados(sophia, C).                 % C = 108
?- prerequisito_transitivo(processamento_linguagem_natural, A).
?- ancestrais(visao_computacional, L).
?- existe_ciclo(D).                              % false na base real
?- trilha_valida(lucas, 28, T), mostrar_trilha(T).
?- trilhas_validas(pedro, 28, 3, Ts).            % 3 trilhas diferentes
```

## Regra de formatura

O aluno precisa cursar todas as obrigatórias e mais 90 horas de eletivas. Como 1 crédito equivale a 15 horas, isso dá 6 créditos de eletivas. Toda trilha tem no máximo 12 semestres simulados. Mais detalhes em `projeto/docs/decisoes.md`.

## Alunos de teste

| Aluno  | Perfil                                       |
|--------|----------------------------------------------|
| sophia | adiantada (já cursando o 5º período)         |
| pedro  | ritmo normal (terminou o 4º período)         |
| vitor  | atrasado (pendências do 2º e 3º períodos)    |
| lucas  | calouro, sem histórico                       |

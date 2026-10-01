# Decisões de modelagem e limitações

## Camada 1 (fatos)

- Usamos a grade real de BCC da PUCPR: 47 obrigatórias, do 1º ao 8º período, e 5 eletivas.
- Cada pré-requisito é um fato `prerequisito/2` separado. Não colocamos listas dentro dos fatos porque assim fica mais fácil fazer a recursão.
- Os nomes das disciplinas são átomos, com letras minúsculas e `_`. Não usamos aspas duplas.
- Criamos o fato `aluno/1`. No começo, o aluno só existia se tivesse algum `cursou/2`, e por isso um calouro aparecia como aluno inexistente.
- Alunos de teste:
  - sophia (adiantada);
  - pedro (no ritmo normal);
  - vitor (atrasado);
  - lucas (calouro, sem histórico);
  - beatriz (formanda, só falta o 8º período).
- A cadeia de pré-requisitos mais longa tem 5 níveis: PLN → aprendizagem de máquina → IA → complexidade → POO → programação imperativa.

## Camada 2 (regras)

- No `pode_cursar/2`, primeiro descobrimos quem é o aluno e qual é a disciplina, e só depois usamos `\+ cursou(...)`. Fizemos assim porque o `\+` não funciona direito com variável livre.
- No `prerequisitos_ok/2`, verificamos se a disciplina existe. Sem isso, o `forall` dava verdadeiro para uma disciplina inventada, porque ela não tem nenhum pré-requisito cadastrado.
- Usamos `findall` nas listas, e não `setof`, por dois motivos:
  - cada disciplina aparece uma vez só na base, então não tem repetição para tirar;
  - o `findall` devolve lista vazia quando não acha nada, enquanto o `setof` (e o `bagof`) falham.
- No `ancestrais/2`, da Camada 3, usamos `setof`, porque ali a mesma disciplina pode aparecer por dois caminhos diferentes.

## Camada 3 (fecho transitivo e trilhas)

- O `prerequisito_transitivo/2` tem dois casos:
  - caso base: o pré-requisito é direto;
  - caso recursivo: é pré-requisito de um pré-requisito.

  Ele guarda uma lista das disciplinas já visitadas para não entrar em loop se a base tiver ciclo.
- O `existe_ciclo/1` testa se uma disciplina é pré-requisito dela mesma. O teste fica em `tests/teste_ciclo.pl`, que tem uma base pequena com um ciclo colocado de propósito.
- Regra de formatura: cursar todas as obrigatórias e 90 horas de eletivas. Como cada crédito vale 15 horas, isso dá 6 créditos de eletiva.
- Não usamos `assert/retract`. O histórico da simulação é uma lista passada como parâmetro. Assim, quando o Prolog faz backtracking, a lista volta sozinha ao estado anterior.
- A trilha tem no máximo 12 semestres (`max_semestres/1`).
- Para a busca não demorar, ela abandona um caminho quando:
  - os créditos que faltam não cabem nos semestres que sobram; ou
  - alguma disciplina tem mais pré-requisitos pendentes em sequência do que semestres sobrando.
- Na hora de montar o semestre, colocamos primeiro as obrigatórias que têm mais disciplinas dependendo delas, e depois as eletivas. Só colocamos eletivas até completar os 6 créditos. Semestre vazio não é permitido.
- Para listar várias trilhas:
  - `trilhas_validas/4` pega as N primeiras com `findnsols`, que já vem no SWI-Prolog;
  - `trilha_valida/4` deixa escolher menos semestres, para o `findall` conseguir pegar todas. Por exemplo, a beatriz tem exatamente 4 trilhas de 1 semestre.

  Pedir todas as trilhas de 12 semestres com `findall` não dá: só para a beatriz são mais de 180 mil.

## Onde usamos cut

- `planejar/4`: quando o aluno já se formou, a trilha termina ali.
- `profundidade_pendente/3`: se a disciplina já foi cursada, a conta para.
- `trilhas_validas/4`: para pegar só o primeiro grupo de respostas.

## Limitações

- A primeira trilha encontrada é válida, mas nem sempre é a mais curta possível.
- As trilhas alternativas costumam mudar só nos últimos semestres, porque é o último ponto de escolha que o backtracking desfaz primeiro.
- O sistema não considera horários, oferta das disciplinas nem co-requisitos.
- Não tratamos equivalência entre currículos antigos e novos.
- Se um pré-requisito citar uma disciplina que não foi cadastrada, o sistema não avisa.

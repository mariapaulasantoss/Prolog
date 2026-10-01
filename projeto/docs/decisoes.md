# Decisões de modelagem e limitações conhecidas

## Camada 1 — Fatos

- **Grade real do curso de BCC (PUCPR).** São 47 obrigatórias, distribuídas do 1º ao 8º período, e 5 eletivas.
- **Um fato `prerequisito/2` por par**, e nunca uma lista dentro de um fato. Assim a recursão e o `forall/2` trabalham direto sobre os fatos.
- **Átomos, e não strings.** Todos os nomes são átomos em minúsculas com `_`. Não usamos texto entre aspas duplas.
- **`aluno/1` separado de `cursou/2`.** Antes, o aluno só era considerado válido se tivesse pelo menos um `cursou/2`. Com isso, um calouro sem histórico era tratado como inexistente. Agora `aluno/1` diz quem existe e `cursou/2` diz o que cada um fez. O aluno `lucas` é o calouro usado nos testes de "aluno sem histórico".
- **Perfis de teste:**
  - `sophia`: adiantada, já cursou disciplinas do 5º período.
  - `pedro`: ritmo normal, terminou o 4º período.
  - `vitor`: atrasado, tem pendências do 2º e do 3º períodos.
  - `lucas`: calouro, sem histórico.
- **Cadeias de pré-requisito longas.** A mais longa tem profundidade 5: `processamento_linguagem_natural → aprendizagem_maquina → inteligencia_artificial → complexidade_de_algoritmos → poo → programacao_imperativa`. Há outras com profundidade 3 ou 4, como os Experienciais e a cadeia SO/distribuída.

## Camada 2 — Elegibilidade

- **`\+` só com argumentos instanciados.** Em `pode_cursar/2`, o aluno e a disciplina já estão ligados (por `aluno_valido/1` e `disciplina/4`) antes do `\+ cursou(...)`. Isso evita a armadilha da negação por falha com variável livre.
- **`prerequisitos_ok/2` confere se a disciplina existe.** Sem essa checagem, o `forall/2` seria verdadeiro "por vacuidade" para uma disciplina inexistente, já que ela não tem nenhum pré-requisito cadastrado.
- **`findall/3` em vez de `setof/3` nas listas da Camada 2.** Cada disciplina aparece uma única vez em `disciplina/4`, então não há duplicatas para remover. Além disso, `findall` devolve `[]` quando não há resultado, e é isso que queremos (por exemplo, um aluno sem nenhuma disciplina liberada). Já `setof` falharia nesse caso. A ordem da lista segue a ordem da grade.
- **`setof/3` em `ancestrais/2` (Camada 3).** Ali pode haver duplicata, porque dois caminhos diferentes podem levar ao mesmo ancestral. Por isso usamos `setof`, junto com um `-> ; L = []` para tratar o caso vazio.

## Camada 3 — Fecho transitivo e trilhas

- **`prerequisito_transitivo/2`** tem caso base (pré-requisito direto) e caso recursivo. A recursão carrega uma lista de visitados, então uma base com ciclo não vira loop infinito: cada caminho tem tamanho finito.
- **`existe_ciclo/1`** testa `prerequisito_transitivo(D, D)`. O `once/1` evita repetir a mesma resposta. O arquivo `tests/teste_ciclo.pl` usa uma base própria com um ciclo inserido de propósito.
- **Regra de formatura** (definida pelo grupo): cursar todas as obrigatórias e mais **90 horas de eletivas**. Como 1 crédito equivale a 15 horas (1 aula por semana em 15 semanas), 90 horas correspondem a **6 créditos de eletivas**. Os parâmetros ficam em `horas_por_credito/1` e `horas_eletivas_minimas/1` e podem ser alterados.
- **Sem `assert/retract`.** O histórico simulado é uma lista passada como argumento. Quando o Prolog volta no backtracking, a lista volta junto, sem nenhum efeito colateral para desfazer.
- **Limite de 12 semestres** (`max_semestres/1`). O contador decrementa a cada semestre simulado e a busca para em 0, mesmo com a base correta.
- **Poda.** Sem poda, a busca testaria todos os subconjuntos de disciplinas em cada semestre, o que explode. Antes de montar cada semestre, verificamos duas coisas:
  1. se os créditos que faltam cabem em `limite × semestres restantes`;
  2. se nenhuma obrigatória pendente está no fim de uma cadeia com mais elos pendentes do que os semestres restantes.

  Com isso, um limite impossível (por exemplo, 12 créditos para o calouro) falha em milissegundos, em vez de travar.
- **Ordem de escolha.** Obrigatórias vêm antes de eletivas. Entre elas, têm prioridade as que "seguram" cadeias mais longas (maior `altura`) e depois as de semestre sugerido menor. A primeira trilha encontrada é gulosa: enche cada semestre por prioridade.
- **Eletivas.** Só entram no semestre enquanto faltam créditos de eletiva. Assim a trilha não acumula eletivas além do necessário.
- **Semestre vazio é proibido.** Ele nunca ajuda a formar e aumentaria a busca à toa.
- **Múltiplas trilhas.** `trilhas_validas(Aluno, Max, N, Lista)` usa `findnsols/4`, que é nativo do SWI-Prolog, para pegar as N primeiras. O número de trilhas possíveis é enorme, então pedir "todas" com `findall` não é viável. Por isso N é sempre limitado.
- **Conferência independente.** `trilha_respeita_prerequisitos/2` revalida uma trilha pronta usando o fecho transitivo. Ela confere se todos os pré-requisitos, diretos e indiretos, de cada disciplina já estavam cursados antes daquele semestre.

## Uso de cut

- **`planejar/4`, no caso base.** Quando o aluno já está formado, a trilha termina e não se tenta adicionar mais semestres.
- **`profundidade_pendente/3`.** Disciplina já cursada tem profundidade 0, e não se calcula mais nada.
- **`trilhas_validas/4`.** Pega só o primeiro bloco de N soluções do `findnsols/4`.

## Limitações conhecidas

- A poda é heurística. Para limites "no fio da navalha", em que a trilha mal cabe nos 12 semestres, a busca pode demorar mais antes de responder. Nos limites testados (de 4 a 28 créditos), todas as respostas saíram em menos de 0,1 s.
- As trilhas alternativas aparecem primeiro com variações nos **últimos** semestres, porque é ali que fica o ponto de escolha mais recente do backtracking. Trilhas muito diferentes no início só aparecem depois de muitas alternativas.
- A trilha não considera horários, oferta da disciplina em cada semestre nem co-requisitos.
- A prioridade gulosa não garante o **menor** número de semestres possível. Ela só garante uma trilha válida dentro dos limites.
- Não há equivalência entre currículos antigos e novos.
- `existe_ciclo/1` só olha `prerequisito/2`. Uma disciplina citada como pré-requisito, mas não cadastrada em `disciplina/4`, não é detectada como erro de base.

:- encoding(utf8).

% Camada 1

% Definindo disciplinas com base na grade de BCC

% Primeiro Período
disciplina(fundamentos_de_sistemas_ciberfisicos, obrigatoria, 4, 1).
disciplina(resolucao_problemas_com_log_matematica, obrigatoria, 4, 1).
disciplina(filosofia, obrigatoria, 4, 1).
disciplina(ex_criativa_navegando_computacao, obrigatoria,6, 1).
disciplina(raciocinio_algoritmo, obrigatoria, 6, 1).
% Segundo Período
disciplina(resolucao_problemas_de_natureza_discreta, obrigatoria, 4, 2).
disciplina(arq_banco_dados, obrigatoria, 6, 2).
disciplina(programacao_imperativa, obrigatoria, 4, 2).
disciplina(programacao_web, obrigatoria, 4, 2).
disciplina(conect_sistemas_ciber, obrigatoria, 4, 2).
disciplina(etica, obrigatoria, 2, 2).
% Terceiro Período
disciplina(modelagem_fenomenos_fisicos, obrigatoria, 4, 3).
disciplina(ex_criando_solucoes_comp, obrigatoria, 6, 3).
disciplina(poo, obrigatoria, 6, 3).
disciplina(seguranca_da_informacao, obrigatoria, 4, 3).
disciplina(performance_sistema_ciber, obrigatoria, 4, 3).
disciplina(clinica_tic, obrigatoria, 2, 3).
% Quarto Período
disciplina(teologia_sociedade, obrigatoria, 2, 4).
disciplina(resolucao_problemas_estruturado_computacao, obrigatoria, 4, 4).
disciplina(big_data, obrigatoria, 4, 4).
disciplina(programacao_logica_funcional, obrigatoria, 4, 4).
disciplina(sistemas_operacionais_ciber, obrigatoria, 4, 4).
disciplina(redes_convergentes, obrigatoria, 4, 4).
disciplina(modelagem_sistemas_computacionais, obrigatoria, 4, 4).
% Quinto Período
disciplina(complexidade_de_algoritmos, obrigatoria, 4, 5).
disciplina(metodos_quantitativos, obrigatoria, 4, 5).
disciplina(resolucao_problemas_com_grafos, obrigatoria, 6, 5).
disciplina(metodo_pesquisa_cientifica, obrigatoria, 4, 5).
disciplina(ex_inovando_colaborativamente, obrigatoria, 6, 5).
% Sexto Período
disciplina(aprendizagem_maquina, obrigatoria, 4, 6).
disciplina(inteligencia_artificial, obrigatoria, 4, 6).
disciplina(programacao_distribuida, obrigatoria, 4, 6).
disciplina(gestao_projetos_metodos_ageis, obrigatoria, 6, 6).
disciplina(pesquisa_aplicada, obrigatoria, 4, 6).
disciplina(engenharia_software, obrigatoria,4, 6).
% Sétimo Período
disciplina(construcao_interpretadores, obrigatoria, 4,7).
disciplina(data_science, obrigatoria, 6, 7).
disciplina(construcao_software_grafico_3d, obrigatoria, 4, 7).
disciplina(cloud_computing, obrigatoria, 4, 7).
disciplina(arq_software, obrigatoria, 4, 7).
disciplina(ex_projeto_transformador1, obrigatoria, 4, 7).
% Oitavo Período
disciplina(processamento_linguagem_natural, obrigatoria, 4, 8).
disciplina(devops, obrigatoria, 4, 8).
disciplina(avaliacao_desempenho_sistemas, obrigatoria, 4, 8).
disciplina(ex_projeto_transformador2, obrigatoria, 4, 8).
disciplina(mundos_virtuais_realidade_misturada, obrigatoria, 4, 8).
disciplina(visao_computacional, obrigatoria, 4, 8).

%Eletivas
disciplina(algoritmos_probabilistico, eletiva, 2, 4).
disciplina(sistemas_embarcados, eletiva, 4, 6).
disciplina(computacao_quantica, eletiva, 4, 5).
disciplina(robotica, eletiva, 4, 2).
disciplina(computacao_forense, eletiva, 4, 5).

% Pré-Requisitos
prerequisito(poo, programacao_imperativa).
prerequisito(complexidade_de_algoritmos, poo).
prerequisito(inteligencia_artificial, complexidade_de_algoritmos).

prerequisito(big_data, arq_banco_dados).
prerequisito(data_science, big_data).

prerequisito(performance_sistema_ciber, fundamentos_de_sistemas_ciberfisicos).
prerequisito(sistemas_operacionais_ciber, performance_sistema_ciber).
prerequisito(programacao_distribuida, sistemas_operacionais_ciber).

prerequisito(redes_convergentes, conect_sistemas_ciber).
prerequisito(cloud_computing, redes_convergentes).

prerequisito(seguranca_da_informacao, conect_sistemas_ciber).
prerequisito(computacao_forense, seguranca_da_informacao).

prerequisito(engenharia_software, ex_criando_solucoes_comp).
prerequisito(arq_software, engenharia_software).
prerequisito(devops, arq_software).

prerequisito(aprendizagem_maquina, inteligencia_artificial).
prerequisito(processamento_linguagem_natural, aprendizagem_maquina).
prerequisito(visao_computacional, aprendizagem_maquina).

prerequisito(ex_criando_solucoes_comp, ex_criativa_navegando_computacao).
prerequisito(ex_inovando_colaborativamente, ex_criando_solucoes_comp).
prerequisito(ex_projeto_transformador1, ex_inovando_colaborativamente).
prerequisito(ex_projeto_transformador2, ex_projeto_transformador1).


% Alunos cadastrados
% aluno/1 separa "aluno existe" de "aluno tem historico": assim um calouro
% sem nenhuma disciplina cursada continua sendo um aluno valido.
aluno(sophia).
aluno(pedro).
aluno(vitor).
aluno(lucas).   % calouro: cadastrado, mas sem nenhum cursou/2
aluno(beatriz). % formanda: so falta o ultimo periodo

% Historicos
% Sophia - Adiantado - 4° Semestre e cursando disciplinas do 5°
%1
cursou(sophia, fundamentos_de_sistemas_ciberfisicos).
cursou(sophia, resolucao_problemas_com_log_matematica).
cursou(sophia, filosofia).
cursou(sophia, ex_criativa_navegando_computacao).
cursou(sophia, raciocinio_algoritmo).
%2
cursou(sophia, resolucao_problemas_de_natureza_discreta).
cursou(sophia, arq_banco_dados).
cursou(sophia, programacao_imperativa).
cursou(sophia, programacao_web).
cursou(sophia, conect_sistemas_ciber).
cursou(sophia, etica).
%3
cursou(sophia, modelagem_fenomenos_fisicos).
cursou(sophia, ex_criando_solucoes_comp).
cursou(sophia, poo).
cursou(sophia, seguranca_da_informacao).
cursou(sophia, performance_sistema_ciber).
cursou(sophia, clinica_tic).
%4
cursou(sophia, teologia_sociedade).
cursou(sophia, resolucao_problemas_estruturado_computacao).
cursou(sophia, big_data).
cursou(sophia, programacao_logica_funcional).
cursou(sophia, sistemas_operacionais_ciber).
cursou(sophia, redes_convergentes).
cursou(sophia, modelagem_sistemas_computacionais).
%5
cursou(sophia, complexidade_de_algoritmos).
cursou(sophia, metodos_quantitativos).

% Pedro - ritmo Normal - 4° semestre
% 1
cursou(pedro, fundamentos_de_sistemas_ciberfisicos).
cursou(pedro, resolucao_problemas_com_log_matematica).
cursou(pedro, filosofia).
cursou(pedro, ex_criativa_navegando_computacao).
cursou(pedro, raciocinio_algoritmo).
%2
cursou(pedro, resolucao_problemas_de_natureza_discreta).
cursou(pedro, arq_banco_dados).
cursou(pedro, programacao_imperativa).
cursou(pedro, programacao_web).
cursou(pedro, conect_sistemas_ciber).
cursou(pedro, etica).
%3
cursou(pedro, modelagem_fenomenos_fisicos).
cursou(pedro, ex_criando_solucoes_comp).
cursou(pedro, poo).
cursou(pedro, seguranca_da_informacao).
cursou(pedro, performance_sistema_ciber).
cursou(pedro, clinica_tic).
%4
cursou(pedro, teologia_sociedade).
cursou(pedro, resolucao_problemas_estruturado_computacao).
cursou(pedro, big_data).
cursou(pedro, programacao_logica_funcional).
cursou(pedro, sistemas_operacionais_ciber).
cursou(pedro, redes_convergentes).
cursou(pedro, modelagem_sistemas_computacionais).

% Vitor - Atrasado - 4° Semestre com algumas do 2° e 3° Pendentes
% 1
cursou(vitor, fundamentos_de_sistemas_ciberfisicos).
cursou(vitor, resolucao_problemas_com_log_matematica).
cursou(vitor, filosofia).
cursou(vitor, ex_criativa_navegando_computacao).
cursou(vitor, raciocinio_algoritmo).
%2
cursou(vitor, resolucao_problemas_de_natureza_discreta).
cursou(vitor, arq_banco_dados).
cursou(vitor, programacao_imperativa).
cursou(vitor, conect_sistemas_ciber).
cursou(vitor, etica).
%3
cursou(vitor, modelagem_fenomenos_fisicos).
cursou(vitor, ex_criando_solucoes_comp).
cursou(vitor, poo).
cursou(vitor, seguranca_da_informacao).
cursou(vitor, performance_sistema_ciber).
%4
cursou(vitor, teologia_sociedade).
cursou(vitor, resolucao_problemas_estruturado_computacao).
cursou(vitor, big_data).
cursou(vitor, programacao_logica_funcional).
cursou(vitor, sistemas_operacionais_ciber).
cursou(vitor, redes_convergentes).
cursou(vitor, modelagem_sistemas_computacionais).

% Beatriz - Formanda - cursou do 1o ao 7o periodo e uma eletiva de 2 creditos;
% faltam o 8o periodo e 4 creditos de eletiva
cursou(beatriz, fundamentos_de_sistemas_ciberfisicos).
cursou(beatriz, resolucao_problemas_com_log_matematica).
cursou(beatriz, filosofia).
cursou(beatriz, ex_criativa_navegando_computacao).
cursou(beatriz, raciocinio_algoritmo).
cursou(beatriz, resolucao_problemas_de_natureza_discreta).
cursou(beatriz, arq_banco_dados).
cursou(beatriz, programacao_imperativa).
cursou(beatriz, programacao_web).
cursou(beatriz, conect_sistemas_ciber).
cursou(beatriz, etica).
cursou(beatriz, modelagem_fenomenos_fisicos).
cursou(beatriz, ex_criando_solucoes_comp).
cursou(beatriz, poo).
cursou(beatriz, seguranca_da_informacao).
cursou(beatriz, performance_sistema_ciber).
cursou(beatriz, clinica_tic).
cursou(beatriz, teologia_sociedade).
cursou(beatriz, resolucao_problemas_estruturado_computacao).
cursou(beatriz, big_data).
cursou(beatriz, programacao_logica_funcional).
cursou(beatriz, sistemas_operacionais_ciber).
cursou(beatriz, redes_convergentes).
cursou(beatriz, modelagem_sistemas_computacionais).
cursou(beatriz, complexidade_de_algoritmos).
cursou(beatriz, metodos_quantitativos).
cursou(beatriz, resolucao_problemas_com_grafos).
cursou(beatriz, metodo_pesquisa_cientifica).
cursou(beatriz, ex_inovando_colaborativamente).
cursou(beatriz, aprendizagem_maquina).
cursou(beatriz, inteligencia_artificial).
cursou(beatriz, programacao_distribuida).
cursou(beatriz, gestao_projetos_metodos_ageis).
cursou(beatriz, pesquisa_aplicada).
cursou(beatriz, engenharia_software).
cursou(beatriz, construcao_interpretadores).
cursou(beatriz, data_science).
cursou(beatriz, construcao_software_grafico_3d).
cursou(beatriz, cloud_computing).
cursou(beatriz, arq_software).
cursou(beatriz, ex_projeto_transformador1).
cursou(beatriz, algoritmos_probabilistico).

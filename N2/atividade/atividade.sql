-- -------------------------------------------------------------------
-- ----------------------- ATIVIDADE ---------------------------------
-- -------------------------------------------------------------------

-- Preparação:

-- - execute o script "sala-ddl.sql"
-- - após o banco criado, execute o script "sala-dml.sql"

-- Responda as questões abaixo, quando for discursiva, escreva em comentários

-- 1) O que você achou da forma como o banco foi populado (arquivo sala-dml.sql)?
--      Há formas melhores de ter feito esse preenchimento? Como?
--      Como melhorar esse script usando comandos TCL?
--      Obs.: Essa questão é discursiva, não envie códigos nela.



-- 2) É mais comum buscar pessoas por documentos, crie um índice para CPF na tabela de Pessoa. (código de criação do índice)



-- 3) Em Avaliacao, há um campo TEXT, o campo ocorrencia, que contém ocorrências ocorridas durante as avaliações
-- a)   crie um FULLTEXT INDEX para esse campo, inclua o tipo_prova no índice


-- b)   faça uma busca por suspeitas de cola na P3 utilizando apenas o índice



-- 4) Quais os benefícios e cuidados com a criação desses índices?



-- 5) Crie uma VIEW que gere uma tabela virtual com os estudantes que estão regularmente matriculados e que não estão sob medidas disciplinares formais,
--  mas possuem registros de ocorrências durante avaliações.



-- 6) Crie duas VIEWs, uma para apresentar os dados do professor (tabelas Professor e Pessoa) e outra para apresentar os dados dos alunos (tabelas Pessoa e Aluno).



-- 7) Crie uma ROLE Secretaria, que terá permissão de acesso a todo o banco, mas não poderá excluir nenhum dado.



-- 8) Crie um usuário Maria, Maria é secretária acadêmica, atribua os acesso de Secretaria a Maria.



-- 9) Crie uma TRIGGER que zere a nota de uma avaliação caso seja inserida com uma ocorrência que justifique isso.



-- 10) Crie uma TRIGGER que zere a nota de uma avaliação caso seja atualizada adicionando uma ocorrência que justifique isso.



-- 11) Crie uma (ou mais) FUNCTION que calcule a nota final por disciplina e aluno.



-- 12) Crie uma PROCEDURE que, caso o aluno tenha 3 ou mais ocorrências, deverá ser suspenso, caso esteja suspenso e tenha 9 ou mais ocorrências, expulso.



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

-- RESPOSTA: Acho que é uma forma bem simples, ela funciona mas também vejo alguns problemas, a minha máquina por exemplo é muito boa, e ainda sim teve uma lentidão
-- por conta da quantidade de inserts que existe no arquivo, então uma boa forma de ter feito isso melhor, seria agrupando os inserts, que já diminuiria significativanente o tamanho.
-- Colocando todo o codigo dentro de uma transação, já resolveria tudo, pois se alguma coisa falhasse, não iria gerar lixo no banco pois era só dar um 
-- hollbakc e já falharia tudo que foi criado sem inserir nenhum dado.



-- 2) É mais comum buscar pessoas por documentos, crie um índice para CPF na tabela de Pessoa. (código de criação do índice)
CREATE INDEX idx_pessoa_cpf ON Pessoa(CPF);



-- 3) Em Avaliacao, há um campo TEXT, o campo ocorrencia, que contém ocorrências ocorridas durante as avaliações
-- a)   crie um FULLTEXT INDEX para esse campo, inclua o tipo_prova no índice
CREATE FULLTEXT INDEX idx_ft_ocorrencia_tipo
ON Avaliacao(ocorrencia, tipo_prova);

-- b)   faça uma busca por suspeitas de cola na P3 utilizando apenas o índice
MATCH(ocorrencia, tipo_prova) 
AGAINST('suspeitas de cola P3' IN NATURAL LANGUAGE MODE) AS relevancia
FROM Avaliacao
WHERE 
MATCH(ocorrencia, tipo_prova) 
AGAINST('suspeitas de cola P3' IN NATURAL LANGUAGE MODE);

-- 4) Quais os benefícios e cuidados com a criação desses índices?
-- RESPOSTA: O beneficio seria a velocidade que seria bem mais rápido, swm o indice o banco teria que ler varios arquivos, com o indice 
-- já chega filtrado e assim aumenta a velocidade de leitura.


-- 5) Crie uma VIEW que gere uma tabela virtual com os estudantes que estão regularmente matriculados e que não estão sob medidas disciplinares formais,
--  mas possuem registros de ocorrências durante avaliações.
CREATE VIEW vw_alunos_ativos_com_ocorrencias AS
SELECT DISTINCT A.matricula, P.nome, P.CPF
FROM
Aluno AS A
JOIN
Pessoa AS P ON A.pessoa_id = P.ID
JOIN
Aluno_Turma AS AT ON A.matricula = AT.aluno_mat
JOIN
Avaliacao AS AV ON AT.ID = AV.aluno_turma_id
WHERE
A.status = 'ativo'
AND AV.ocorrencia IS NOT NULL;


-- 6) Crie duas VIEWs, uma para apresentar os dados do professor (tabelas Professor e Pessoa) e outra para apresentar os dados dos alunos (tabelas Pessoa e Aluno).
CREATE VIEW vw_dados_professor AS
SELECT PR.matricula, PR.ativo, P.ID AS pessoa_id,
P.nome,
P.CPF,
P.data_nascimento,
P.end_logradouro,
P.end_numero,
P.end_complemento,
P.end_bairro,
P.end_cidade,
P.end_uf_sigla
FROM
Professor AS PR
JOIN
Pessoa AS P ON PR.pessoa_id = P.ID;

-- Agora a do aluno
CREATE VIEW vw_dados_aluno AS
SELECT A.matricula, A.status, A.dt_matricula,
P.ID AS pessoa_id,
P.nome,
P.CPF,
P.data_nascimento,
P.end_logradouro,
P.end_numero,
P.end_complemento,
P.end_bairro,
P.end_cidade,
P.end_uf_sigla
FROM
Aluno AS A
JOIN
Pessoa AS P ON A.pessoa_id = P.ID;


-- 7) Crie uma ROLE Secretaria, que terá permissão de acesso a todo o banco, mas não poderá excluir nenhum dado.
CREATE ROLE 'Secretaria';
-- 2. Concede as permissões para essa ROLE no banco de dados 'SalaDeAula'
-- Dei a oção de ler (SELECT), inserir (INSERT) e também de atualizar (UPDATE) mas não deixo ele deletar pois n coloquei o (delete).
-- A permissão é válida para TODAS as tabelas do banco (SalaDeAula.*)
GRANT SELECT, INSERT, UPDATE ON SalaDeAula.* TO 'Secretaria';


-- 8) Crie um usuário Maria, Maria é secretária acadêmica, atribua os acesso de Secretaria a Maria.
CREATE USER 'Maria'@'localhost' IDENTIFIED BY 'Maria123#';
GRANT 'Secretaria' TO 'Maria'@'localhost';
FLUSH PRIVILEGES; -- Atualiza para funcionar as atribuições.

-- 9) Crie uma TRIGGER que zere a nota de uma avaliação caso seja inserida com uma ocorrência que justifique isso.
-- Remove o delimitador padrão (;)
DELIMITER $$


CREATE TRIGGER trg_zerar_nota
BEFORE INSERT ON Avaliacao
FOR EACH ROW
BEGIN
    IF (
        NEW.ocorrencia LIKE '%cola%' OR
        NEW.ocorrencia LIKE '%fraude%' OR
        NEW.ocorrencia LIKE '%plágio%'
    ) THEN
        SET NEW.nota = 0.0;
    END IF;
END$$
DELIMITER ;

-- 10) Crie uma TRIGGER que zere a nota de uma avaliação caso seja atualizada adicionando uma ocorrência que justifique isso.
-- Remove o delimitador padrão (;)
DELIMITER $$

CREATE TRIGGER trg_zerar_nota_update
BEFORE UPDATE ON Avaliacao
FOR EACH ROW
BEGIN
    IF NOT (NEW.ocorrencia <=> OLD.ocorrencia) AND NEW.ocorrencia IS NOT NULL THEN
        IF (
            NEW.ocorrencia LIKE '%cola%' OR
            NEW.ocorrencia LIKE '%fraude%' OR
            NEW.ocorrencia LIKE '%plágio%'
        ) THEN
            SET NEW.nota = 0.0;
        END IF;
    END IF;
END$$
DELIMITER ;


-- 11) Crie uma (ou mais) FUNCTION que calcule a nota final por disciplina e aluno.
-- Muda o delimitador padrão (;) para ($$)
-- Isso é necessário para que o MySQL entenda a FUNCTION inteira como um único bloco
DELIMITER $$
CREATE FUNCTION fn_calcula_media_aluno_turma(
    p_aluno_mat VARCHAR(10),
    p_turma_cod VARCHAR(12) 
)
RETURNS DECIMAL(3,1)
READS SQL DATA
BEGIN
    DECLARE v_media DECIMAL(3,1);
    DECLARE v_aluno_turma_id INT;
    SELECT ID
    INTO v_aluno_turma_id
    FROM Aluno_Turma
    WHERE
        aluno_mat = p_aluno_mat
        AND turma_cod = p_turma_cod;

    SELECT AVG(nota)
    INTO v_media
    FROM Avaliacao
    WHERE
        aluno_turma_id = v_aluno_turma_id
        AND tipo_prova <> 'Rec';
    RETURN v_media;
END$$
DELIMITER ;


-- 12) Crie uma PROCEDURE que, caso o aluno tenha 3 ou mais ocorrências, deverá ser suspenso, caso esteja suspenso e tenha 9 ou mais ocorrências, expulso.
DELIMITER $$
CREATE PROCEDURE sp_avalia_disciplina_aluno(
    IN p_aluno_mat VARCHAR(10)
)
BEGIN
    DECLARE v_total_ocorrencias INT DEFAULT 0;
    DECLARE v_status_atual VARCHAR(30);

    SELECT COUNT(AV.ID)
    INTO v_total_ocorrencias
    FROM Aluno_Turma AS AT
    JOIN Avaliacao AS AV ON AT.ID = AV.aluno_turma_id
    WHERE
        AT.aluno_mat = p_aluno_mat
        AND AV.ocorrencia IS NOT NULL;

    SELECT status
    INTO v_status_atual
    FROM Aluno
    WHERE matricula = p_aluno_mat;

    IF (v_total_ocorrencias >= 9 AND v_status_atual = 'suspenso') THEN
        UPDATE Aluno
        SET status = 'expulso'
        WHERE matricula = p_aluno_mat;

    ELSEIF (v_total_ocorrencias >= 3 AND v_status_atual = 'ativo') THEN
        UPDATE Aluno
        SET status = 'suspenso'
        WHERE matricula = p_aluno_mat;
END$$
DELIMITER ;

-- Verificando =
CALL sp_avalia_disciplina_aluno('MATR001');

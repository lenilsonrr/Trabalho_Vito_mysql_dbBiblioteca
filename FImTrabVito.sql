CREATE DATABASE biblioteca;

USE biblioteca;

CREATE TABLE Livros (
    id INT AUTO_INCREMENT NOT NULL,
    titulo VARCHAR(50) NOT NULL UNIQUE,
    autor VARCHAR(50) NOT NULL,
    copias INT NOT NULL,
    qtdEmprestimo INT ,
    ativo TINYINT,
    PRIMARY KEY (id)
);

CREATE TABLE Curso (
	id INT AUTO_INCREMENT NOT NULL ,
	nome VARCHAR(155) NOT NULL,
    PRIMARY KEY (id)
    );

CREATE TABLE Alunos (
    id INT AUTO_INCREMENT NOT NULL,
    nome VARCHAR(30) NOT NULL,
    matricula VARCHAR(255) NOT NULL,
    total_livros_pegos INT,
    id_curso INT NOT NULL,
    ativo tinyint,
    PRIMARY KEY (id),
    FOREIGN KEY (id_curso) REFERENCES Curso (id)
    );
    
CREATE TABLE Emprestimo (
    id INT AUTO_INCREMENT NOT NULL,
    aluno_id INT,
    livro_id INT,
    dataRetirada DATE,
    dataPrevistaDeEntrega DATE,
    dataDevolucao DATE,
    multa FLOAT,
    ativo tinyint,
    PRIMARY KEY (id),
    FOREIGN KEY (aluno_id) REFERENCES Alunos(id),
    FOREIGN KEY (livro_id) REFERENCES Livros(id)
);

DELIMITER //
CREATE FUNCTION calCMulta(dias INT, valorMulta DECIMAL(10,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
  DECLARE totalMulta DECIMAL(10,2);
  SET totalMulta = dias * valorMulta;
  RETURN totalMulta;
END//
DELIMITER ;


DELIMITER //
CREATE TRIGGER UpdateQtdEmprestimoOnReturn
AFTER UPDATE ON Emprestimo
FOR EACH ROW
BEGIN
    IF NEW.dataDevolucao IS NOT NULL AND OLD.dataDevolucao IS NULL THEN
        UPDATE Livros
        SET qtdEmprestimo = qtdEmprestimo - 1
        WHERE id = OLD.livro_id;
        UPDATE Livros
        SET copias = copias + 1
        WHERE id = OLD.livro_id;
        UPDATE Alunos
        SET total_livros_pegos = total_livros_pegos - 1
        WHERE id = OLD.aluno_id;
    END IF;
END;
//
DELIMITER ;


DELIMITER //
CREATE TRIGGER UpdateMultaOnReturn
BEFORE UPDATE ON Emprestimo
FOR EACH ROW
BEGIN
    DECLARE dias_em_atraso INT;
    DECLARE multa DECIMAL(10,2);

    IF NEW.dataDevolucao IS NOT NULL AND OLD.dataDevolucao IS NULL THEN
      
        SELECT DATEDIFF(
            COALESCE(NEW.dataDevolucao, CURDATE()), 
            COALESCE(NEW.dataPrevistaDeEntrega, CURDATE())
        ) INTO dias_em_atraso;

	
        IF dias_em_atraso > 0 THEN
            SET multa = calCMulta(dias_em_atraso, 2.0);
        ELSE
            SET multa = 0.0;
        END IF;

        SET NEW.multa = multa;
    END IF;
END;
//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE RealizarEmprestimo(
    IN p_aluno_id INT,
    IN p_livro_id INT,
    IN p_dataret DATE
)
BEGIN
    DECLARE v_total_copias INT;
    DECLARE v_emprestimos INT;
    DECLARE v_total_livros_pegos INT;
    DECLARE v_ativo TINYINT;

    SELECT copias, qtdEmprestimo
    INTO v_total_copias, v_emprestimos
    FROM Livros
    WHERE id = p_livro_id;

    SELECT total_livros_pegos, ativo 
    INTO v_total_livros_pegos, v_ativo
    FROM Alunos
    WHERE id = p_aluno_id;

    IF v_ativo = 1 THEN
        IF EXISTS (
            SELECT 1
            FROM Emprestimo
            WHERE aluno_id = p_aluno_id AND dataDevolucao IS NULL AND dataPrevistaDeEntrega < CURRENT_DATE
        ) THEN
            SELECT 'O aluno tem empréstimos em atraso. Não é possível realizar um novo empréstimo' AS Error;
        ELSE
            IF (SELECT COUNT(DISTINCT livro_id) FROM Emprestimo WHERE aluno_id = p_aluno_id AND dataDevolucao IS NULL) >= 10 THEN
                SELECT 'O aluno já atingiu o limite de 10 livros diferentes emprestados' AS Error;
            ELSE
                IF EXISTS (SELECT 1 FROM Emprestimo WHERE aluno_id = p_aluno_id AND livro_id = p_livro_id AND dataRetirada = p_dataret AND dataDevolucao IS NULL) THEN
                    SELECT 'Este aluno já tem o livro em mãos nesta data' AS Error;
                ELSE
                    IF v_total_livros_pegos < 10 THEN
                        IF v_total_copias > 0 THEN
                            INSERT INTO Emprestimo (aluno_id, livro_id, dataRetirada, dataPrevistaDeEntrega, dataDevolucao, multa, ativo)
                            VALUES (p_aluno_id, p_livro_id, p_dataret, DATE_ADD(p_dataret, INTERVAL 21 DAY), NULL, 0, 1);

                            UPDATE Livros
                            SET qtdEmprestimo = qtdEmprestimo + 1,
                                copias = copias - 1
                            WHERE id = p_livro_id;

                            UPDATE Alunos
                            SET total_livros_pegos = total_livros_pegos + 1
                            WHERE id = p_aluno_id;

                            SELECT 'Empréstimo realizado com sucesso' AS Success;
                        ELSE
                            SELECT 'Não há cópias disponíveis deste livro' AS Error;
                        END IF;
                    ELSE
                        SELECT 'O aluno já atingiu o limite de 10 livros emprestados' AS Error;
                    END IF;
                END IF;
            END IF;
        END IF;
    ELSE
        SELECT 'Aluno está inativo' AS Error;
    END IF;
END //
DELIMITER ;


DELIMITER //
CREATE PROCEDURE DevolucaoEmprestimo(
    IN p_id INT
)
BEGIN
UPDATE Emprestimo SET dataDevolucao  = curdate()
WHERE id = p_id;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE BuscarLivrosPorTituloOuAutor(
    IN p_termo_busca VARCHAR(255)
)
BEGIN
    SELECT *
    FROM Livros
    WHERE titulo LIKE CONCAT('%', p_termo_busca, '%')
       OR autor LIKE CONCAT('%', p_termo_busca, '%');
END //
DELIMITER ;



CREATE VIEW LivrosNaoDevolvidosView AS
SELECT
    e.id AS emprestimo_id,
    l.titulo AS livro_titulo,
    a.nome AS aluno_nome,
    e.dataRetirada,
    e.dataPrevistaDeEntrega
FROM
    Emprestimo e
JOIN Livros l ON e.livro_id = l.id
JOIN Alunos a ON e.aluno_id = a.id
WHERE
    e.dataDevolucao IS NULL AND e.dataPrevistaDeEntrega < CURRENT_DATE;


DELIMITER //
CREATE PROCEDURE MostrarMultaPorNomeAluno(
    IN p_nome_aluno VARCHAR(255)
)
BEGIN
    SELECT e.multa, e.dataRetirada, e.dataPrevistaDeEntrega, e.dataDevolucao
    FROM Emprestimo e
    INNER JOIN Alunos a ON e.aluno_id = a.id
    WHERE a.nome = p_nome_aluno
    ORDER BY e.id;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE AlunosAtrasadosNaDevolucao(
    IN p_data_pesquisa DATE
)
BEGIN
    SELECT
        a.id,
        a.nome,
        e.dataRetirada,
        e.dataPrevistaDeEntrega,
        e.dataDevolucao
    FROM
        Alunos a
    JOIN Emprestimo e ON a.id = e.aluno_id
    WHERE
        e.dataDevolucao IS NULL
        AND e.dataPrevistaDeEntrega < p_data_pesquisa;
END //
DELIMITER ;


INSERT INTO Livros (titulo, autor, copias, qtdEmprestimo, ativo)
VALUES ('Introdução à Programação', 'Autor 11', 25, 0, 1);

INSERT INTO Livros (titulo, autor, copias, qtdEmprestimo, ativo)
VALUES ('Redes e Protocolos', 'Autor 12', 15, 0, 1);

INSERT INTO Livros (titulo, autor, copias, qtdEmprestimo, ativo)
VALUES ('Segurança Cibernética', 'Autor 13', 30, 0, 1);

INSERT INTO Livros (titulo, autor, copias, qtdEmprestimo, ativo)
VALUES ('Desenvolvimento Web Moderno', 'Autor 14', 20, 0, 1);

INSERT INTO Livros (titulo, autor, copias, qtdEmprestimo, ativo)
VALUES ('Machine Learning Avançado', 'Autor 15', 18, 0, 1);

INSERT INTO Livros (titulo, autor, copias, qtdEmprestimo, ativo)
VALUES ('Inteligência Artificial e Robótica', 'Autor 16', 10, 0, 1);

INSERT INTO Livros (titulo, autor, copias, qtdEmprestimo, ativo)
VALUES ('Bancos de Dados NoSQL', 'Autor 17', 12, 0, 1);

INSERT INTO Livros (titulo, autor, copias, qtdEmprestimo, ativo)
VALUES ('Desenvolvimento de Aplicativos Móveis', 'Autor 18', 22, 0, 1);

INSERT INTO Livros (titulo, autor, copias, qtdEmprestimo, ativo)
VALUES ('Arquitetura de Microserviços', 'Autor 19', 17, 0, 1);

INSERT INTO Livros (titulo, autor, copias, qtdEmprestimo, ativo)
VALUES ('Cloud Computing e Virtualização Avançada', 'Autor 20', 28, 0, 1);
INSERT INTO Livros (titulo, autor, copias, qtdEmprestimo, ativo)
VALUES ('IOT-Internet da coisas', 'Autor 30', 2, 0, 1);

INSERT INTO Curso (nome) VALUES ('Back-End');
INSERT INTO Curso (nome) VALUES ('Data Science');
INSERT INTO Curso (nome) VALUES ('Web Development');
INSERT INTO Curso (nome) VALUES ('Information Security');
INSERT INTO Curso (nome) VALUES ('Network Administration');
INSERT INTO Curso (nome) VALUES ('Database Management');
INSERT INTO Curso (nome) VALUES ('Software Engineering');
INSERT INTO Curso (nome) VALUES ('Artificial Intelligence');
INSERT INTO Curso (nome) VALUES ('Cybersecurity');
INSERT INTO Curso (nome) VALUES ('Front-End');
INSERT INTO Curso (nome) VALUES ('IOT');


INSERT INTO Alunos (nome, matricula,total_livros_pegos, id_curso, ativo) VALUES ('Student 1', 'M1001',0, 1, 1);
INSERT INTO Alunos (nome, matricula,total_livros_pegos, id_curso, ativo) VALUES ('Student 2', 'M1002',0, 2, 1);
INSERT INTO Alunos (nome, matricula,total_livros_pegos, id_curso, ativo) VALUES ('Student 3', 'M1003',0, 3, 0);
INSERT INTO Alunos (nome, matricula,total_livros_pegos, id_curso, ativo) VALUES ('Student 4', 'M1004', 0, 4, 1);
INSERT INTO Alunos (nome, matricula,total_livros_pegos, id_curso, ativo) VALUES ('Student 5', 'M1005', 0, 5, 1);
INSERT INTO Alunos (nome, matricula,total_livros_pegos, id_curso, ativo) VALUES ('Student 6', 'M1006', 0, 6, 1);
INSERT INTO Alunos (nome, matricula,total_livros_pegos, id_curso, ativo) VALUES ('Student 7', 'M1007', 0, 7, 1);
INSERT INTO Alunos (nome, matricula,total_livros_pegos, id_curso, ativo) VALUES ('Student 8', 'M1008', 0, 8, 1);
INSERT INTO Alunos (nome, matricula,total_livros_pegos, id_curso, ativo) VALUES ('Student 9', 'M1009', 0, 9, 0);
INSERT INTO Alunos (nome, matricula,total_livros_pegos, id_curso, ativo) VALUES ('Student 10', 'M1010', 0, 10, 1);


CALL RealizarEmprestimo(3, 3, '2023-10-27');
CALL RealizarEmprestimo(4, 1, '2023-10-28');
CALL RealizarEmprestimo(5, 11, '2023-11-23');
CALL RealizarEmprestimo(6,11, '2023-11-20');
CALL RealizarEmprestimo(7, 11, '2023-10-31');
CALL RealizarEmprestimo(8, 8, '2023-10-01');
CALL RealizarEmprestimo(9, 9, '2023-11-02');
CALL RealizarEmprestimo(10, 10, '2023-11-03');
CALL RealizarEmprestimo(1, 2, '2023-11-04');
CALL RealizarEmprestimo(2, 3, '2023-11-05');
CALL RealizarEmprestimo(3, 4, '2023-11-06');
CALL RealizarEmprestimo(4, 5, '2023-11-07');
CALL RealizarEmprestimo(5, 6, '2023-11-08');
CALL RealizarEmprestimo(6, 7, '2023-11-09');
CALL RealizarEmprestimo(7, 8, '2023-11-10');
CALL RealizarEmprestimo(8, 9, '2023-11-11');
CALL RealizarEmprestimo(9, 10, '2023-11-12');
CALL RealizarEmprestimo(10, 1, '2023-11-13');
CALL RealizarEmprestimo(1, 3, '2023-11-14');
CALL RealizarEmprestimo(2, 5, '2023-11-15');

CALL RealizarEmprestimo(1, 6, '2023-10-15');


SELECT * FROM Emprestimo;
-- Busca o livro pelo titulo ou pelo nome do ou dos autores
CALL BuscarLivrosPorTituloOuAutor('Autor 12');

-- Procedure que realiza a devolusao do livro
CALL DevolucaoEmprestimo(2);

-- View para livros que visualiza todos os livros emprestados e que não foram devolvidos até a data da busca
SELECT * FROM LivrosNaoDevolvidosView;

-- Mostra  o valor da multa pelo atraso na devolução de um ou mais livros de um determinado aluno
CALL MostrarMultaPorNomeAluno('Student 1');

-- Stored procedure que seleciona os alunos que estão atrasados na devolução dos livros na data da pesquisa
CALL AlunosAtrasadosNaDevolucao('2023-11-22');


-- Dados inteiramente ficticios, apenas para demonstrar o funcionamento.
-- Execute depois de 01_criar_esquema.sql, somente uma vez.
SET search_path TO oficina;
BEGIN;

INSERT INTO cliente (nome, cpf, telefone, email) VALUES
('Ana Souza', '11122233344', '(45) 99911-1111', 'ana.exemplo@email.test'),
('Carlos Lima', '22233344455', '(45) 99922-2222', 'carlos.exemplo@email.test'),
('Mariana Costa', '33344455566', '(45) 99933-3333', 'mariana.exemplo@email.test'),
('Rafael Pereira', '44455566677', '(45) 99944-4444', 'rafael.exemplo@email.test'),
('Julia Ribeiro', '55566677788', '(45) 99955-5555', 'julia.exemplo@email.test');

INSERT INTO veiculo (id_cliente, placa, marca, modelo, ano) VALUES
(1, 'ABC1D23', 'Chevrolet', 'Onix', 2020),
(2, 'EFG4H56', 'Honda', 'Civic', 2019),
(3, 'IJK7L89', 'Volkswagen', 'Gol', 2017),
(1, 'MNO2P34', 'Fiat', 'Argo', 2022),
(4, 'QRS5T67', 'Toyota', 'Corolla', 2021),
(5, 'UVW8X90', 'Renault', 'Sandero', 2018);

INSERT INTO mecanico (nome, especialidade, telefone) VALUES
('Joao Oliveira', 'Motor', '(45) 98811-1111'),
('Pedro Santos', 'Freios', '(45) 98822-2222'),
('Maria Fernandes', 'Eletrica', '(45) 98833-3333'),
('Juliana Rocha', 'Suspensao', '(45) 98844-4444'),
('Bruno Alves', 'Diagnostico', '(45) 98855-5555');

INSERT INTO equipe (nome) VALUES
('Equipe Motor'),
('Equipe Eletrica'),
('Equipe Revisao');

INSERT INTO equipe_mecanico (id_equipe, id_mecanico) VALUES
(1,1), (1,2),
(2,3), (2,5),
(3,2), (3,4), (3,5);

INSERT INTO servico (descricao, valor_referencia) VALUES
('Troca de oleo', 85.00),
('Revisao dos freios', 120.00),
('Diagnostico eletrico', 95.00),
('Alinhamento', 100.00),
('Troca de correia', 230.00);

INSERT INTO peca (nome, preco_atual, quantidade_estoque) VALUES
('Oleo do motor 1L', 50.00, 30),
('Filtro de oleo', 35.00, 12),
('Pastilha de freio', 175.00, 8),
('Bateria 60Ah', 390.00, 3),
('Kit correia dentada', 220.00, 4),
('Fusivel automotivo', 12.00, 50);

INSERT INTO ordem_servico
(id_veiculo, id_equipe, data_emissao, data_conclusao, status, observacao) VALUES
(1, 1, '2026-10-03', '2026-10-05', 'CONCLUIDA', 'Revisao periodica e troca de oleo'),
(2, 3, '2026-10-11', NULL, 'EM_ANDAMENTO', 'Verificar barulho ao frear'),
(3, 2, '2026-10-14', NULL, 'ABERTA', 'Falha na partida'),
(4, 3, '2026-10-19', '2026-10-20', 'CONCLUIDA', 'Alinhamento e revisao'),
(5, 1, '2026-11-04', NULL, 'EM_ANDAMENTO', 'Manutencao preventiva do motor'),
(6, 2, '2026-11-08', NULL, 'ORCAMENTO', 'Diagnostico de luz no painel');

INSERT INTO item_servico (id_os, id_servico, quantidade, valor_unitario) VALUES
(1,1,1,85.00),
(2,2,1,120.00),
(3,3,1,95.00),
(4,4,1,100.00),
(4,2,1,120.00),
(5,5,1,230.00),
(6,3,1,95.00);

INSERT INTO item_peca (id_os, id_peca, quantidade, valor_unitario) VALUES
(1,1,4,50.00),
(1,2,1,35.00),
(2,3,1,175.00),
(3,4,1,390.00),
(3,6,2,12.00),
(5,5,1,220.00),
(6,6,1,12.00);

COMMIT;

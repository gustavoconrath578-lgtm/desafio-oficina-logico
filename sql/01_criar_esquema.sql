-- DESAFIO: MODELO LOGICO DE UMA OFICINA MECANICA
-- PostgreSQL | Execute primeiro, em um banco de testes.
-- ATENCAO: apaga o esquema oficina se ele ja existir.

DROP SCHEMA IF EXISTS oficina CASCADE;
CREATE SCHEMA oficina;
SET search_path TO oficina;

-- 1. Clientes podem possuir varios veiculos.
CREATE TABLE cliente (
    id_cliente SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(11) NOT NULL UNIQUE,
    telefone VARCHAR(20),
    email VARCHAR(120),
    CONSTRAINT chk_cliente_cpf CHECK (cpf ~ '^[0-9]{11}$')
);

-- 2. Cada veiculo pertence a um cliente.
CREATE TABLE veiculo (
    id_veiculo SERIAL PRIMARY KEY,
    id_cliente INTEGER NOT NULL,
    placa VARCHAR(7) NOT NULL UNIQUE,
    marca VARCHAR(50) NOT NULL,
    modelo VARCHAR(70) NOT NULL,
    ano SMALLINT NOT NULL,
    CONSTRAINT fk_veiculo_cliente FOREIGN KEY (id_cliente)
        REFERENCES cliente(id_cliente),
    CONSTRAINT chk_veiculo_ano CHECK (ano BETWEEN 1900 AND 2100),
    CONSTRAINT chk_veiculo_placa CHECK (placa ~ '^[A-Z]{3}[0-9][A-Z0-9][0-9]{2}$')
);

-- 3. Funcionarios mecanicos e suas especialidades.
CREATE TABLE mecanico (
    id_mecanico SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    especialidade VARCHAR(80) NOT NULL,
    telefone VARCHAR(20)
);

-- 4. Uma equipe realiza varias ordens de servico.
CREATE TABLE equipe (
    id_equipe SERIAL PRIMARY KEY,
    nome VARCHAR(80) NOT NULL UNIQUE
);

-- 5. Relacao N:N entre equipes e mecanicos.
CREATE TABLE equipe_mecanico (
    id_equipe INTEGER NOT NULL,
    id_mecanico INTEGER NOT NULL,
    PRIMARY KEY (id_equipe, id_mecanico),
    CONSTRAINT fk_em_equipe FOREIGN KEY (id_equipe) REFERENCES equipe(id_equipe),
    CONSTRAINT fk_em_mecanico FOREIGN KEY (id_mecanico) REFERENCES mecanico(id_mecanico)
);

-- 6. Catalogo de servicos e valores de referencia.
CREATE TABLE servico (
    id_servico SERIAL PRIMARY KEY,
    descricao VARCHAR(120) NOT NULL UNIQUE,
    valor_referencia NUMERIC(10,2) NOT NULL,
    CONSTRAINT chk_servico_valor CHECK (valor_referencia >= 0)
);

-- 7. Pecas disponiveis na oficina.
CREATE TABLE peca (
    id_peca SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL UNIQUE,
    preco_atual NUMERIC(10,2) NOT NULL,
    quantidade_estoque INTEGER NOT NULL DEFAULT 0,
    CONSTRAINT chk_peca_preco CHECK (preco_atual >= 0),
    CONSTRAINT chk_peca_estoque CHECK (quantidade_estoque >= 0)
);

-- 8. OS liga o veiculo atendido a equipe responsavel.
-- O cliente e obtido por veiculo.id_cliente; nao e duplicado na OS.
CREATE TABLE ordem_servico (
    id_os SERIAL PRIMARY KEY,
    id_veiculo INTEGER NOT NULL,
    id_equipe INTEGER NOT NULL,
    data_emissao DATE NOT NULL DEFAULT CURRENT_DATE,
    data_conclusao DATE,
    status VARCHAR(20) NOT NULL DEFAULT 'ABERTA',
    observacao TEXT,
    CONSTRAINT fk_os_veiculo FOREIGN KEY (id_veiculo) REFERENCES veiculo(id_veiculo),
    CONSTRAINT fk_os_equipe FOREIGN KEY (id_equipe) REFERENCES equipe(id_equipe),
    CONSTRAINT chk_os_status CHECK (
        status IN ('ORCAMENTO', 'ABERTA', 'EM_ANDAMENTO', 'CONCLUIDA', 'CANCELADA')
    ),
    CONSTRAINT chk_os_datas CHECK (
        data_conclusao IS NULL OR data_conclusao >= data_emissao
    ),
    CONSTRAINT chk_os_conclusao CHECK (
        (status = 'CONCLUIDA' AND data_conclusao IS NOT NULL)
        OR (status <> 'CONCLUIDA' AND data_conclusao IS NULL)
    )
);

-- 9. Servicos incluidos na OS (relacao N:N).
-- O valor cobrado e registrado no momento da OS, sem depender de alteracoes futuras no catalogo.
CREATE TABLE item_servico (
    id_os INTEGER NOT NULL,
    id_servico INTEGER NOT NULL,
    quantidade INTEGER NOT NULL DEFAULT 1,
    valor_unitario NUMERIC(10,2) NOT NULL,
    PRIMARY KEY (id_os, id_servico),
    CONSTRAINT fk_is_os FOREIGN KEY (id_os) REFERENCES ordem_servico(id_os),
    CONSTRAINT fk_is_servico FOREIGN KEY (id_servico) REFERENCES servico(id_servico),
    CONSTRAINT chk_is_qtd CHECK (quantidade > 0),
    CONSTRAINT chk_is_valor CHECK (valor_unitario >= 0)
);

-- 10. Pecas utilizadas na OS (relacao N:N).
-- A quantidade em estoque e um cadastro demonstrativo; sem baixa automatica.
CREATE TABLE item_peca (
    id_os INTEGER NOT NULL,
    id_peca INTEGER NOT NULL,
    quantidade INTEGER NOT NULL,
    valor_unitario NUMERIC(10,2) NOT NULL,
    PRIMARY KEY (id_os, id_peca),
    CONSTRAINT fk_ip_os FOREIGN KEY (id_os) REFERENCES ordem_servico(id_os),
    CONSTRAINT fk_ip_peca FOREIGN KEY (id_peca) REFERENCES peca(id_peca),
    CONSTRAINT chk_ip_qtd CHECK (quantidade > 0),
    CONSTRAINT chk_ip_valor CHECK (valor_unitario >= 0)
);

-- Indices auxiliares para consultas por relacionamentos.
CREATE INDEX idx_veiculo_cliente ON veiculo(id_cliente);
CREATE INDEX idx_os_veiculo ON ordem_servico(id_veiculo);
CREATE INDEX idx_os_equipe ON ordem_servico(id_equipe);
CREATE INDEX idx_os_status ON ordem_servico(status);
CREATE INDEX idx_em_mecanico ON equipe_mecanico(id_mecanico);
CREATE INDEX idx_is_servico ON item_servico(id_servico);
CREATE INDEX idx_ip_peca ON item_peca(id_peca);

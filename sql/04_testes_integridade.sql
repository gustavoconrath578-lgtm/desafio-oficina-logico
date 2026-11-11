-- Verificacoes que nao alteram os dados nem causam falhas intencionais.
SET search_path TO oficina;

-- 1. Contagem das tabelas principais.
SELECT 'clientes' AS tabela, COUNT(*) AS registros FROM cliente
UNION ALL SELECT 'veiculos', COUNT(*) FROM veiculo
UNION ALL SELECT 'mecanicos', COUNT(*) FROM mecanico
UNION ALL SELECT 'equipes', COUNT(*) FROM equipe
UNION ALL SELECT 'ordens', COUNT(*) FROM ordem_servico
UNION ALL SELECT 'servicos', COUNT(*) FROM servico
UNION ALL SELECT 'pecas', COUNT(*) FROM peca;

-- 2. Todas as OS devem estar associadas a um veiculo e a uma equipe existentes.
SELECT COUNT(*) AS ordens_com_relacao_invalida
FROM ordem_servico os
LEFT JOIN veiculo v ON v.id_veiculo = os.id_veiculo
LEFT JOIN equipe e ON e.id_equipe = os.id_equipe
WHERE v.id_veiculo IS NULL OR e.id_equipe IS NULL;

-- 3. Nenhum registro deve ter preco negativo ou estoque negativo.
SELECT
    (SELECT COUNT(*) FROM peca WHERE preco_atual < 0 OR quantidade_estoque < 0)
    + (SELECT COUNT(*) FROM servico WHERE valor_referencia < 0)
    + (SELECT COUNT(*) FROM item_peca WHERE valor_unitario < 0 OR quantidade <= 0)
    + (SELECT COUNT(*) FROM item_servico WHERE valor_unitario < 0 OR quantidade <= 0)
    AS registros_com_valores_invalidos;

-- EXEMPLOS PARA TESTAR AS CONSTRAINTS (mantidos comentados para nao interromper a execucao):
-- INSERT INTO veiculo (id_cliente, placa, marca, modelo, ano)
-- VALUES (999, 'AAA1B23', 'Marca', 'Modelo', 2020); -- FK inexistente
-- INSERT INTO peca (nome, preco_atual, quantidade_estoque)
-- VALUES ('Peca invalida', -5, 1); -- CHECK de preco
-- INSERT INTO ordem_servico (id_veiculo, id_equipe, status)
-- VALUES (1, 1, 'DESCONHECIDO'); -- CHECK de status

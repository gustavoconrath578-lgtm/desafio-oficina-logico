-- Consultas para responder perguntas sobre a oficina.
-- Execute depois de criar as tabelas e inserir os dados.
SET search_path TO oficina;

-- 01. Quais clientes estao cadastrados? (SELECT e ORDER BY)
SELECT id_cliente, nome, telefone FROM cliente ORDER BY nome;

-- 02. Quais veiculos sao de 2020 em diante? (WHERE)
SELECT placa, marca, modelo, ano FROM veiculo
WHERE ano >= 2020 ORDER BY ano DESC, modelo;

-- 03. Quais ordens estao abertas ou em andamento? (WHERE, IN)
SELECT id_os, data_emissao, status, observacao FROM ordem_servico
WHERE status IN ('ABERTA', 'EM_ANDAMENTO')
ORDER BY data_emissao DESC;

-- 04. Quais veiculos pertencem a cada cliente? (JOIN)
SELECT c.nome AS cliente, v.placa, v.marca, v.modelo
FROM cliente c
JOIN veiculo v ON v.id_cliente = c.id_cliente
ORDER BY c.nome, v.modelo;

-- 05. Quantas ordens de servico cada cliente possui, incluindo quem nao possui? (LEFT JOIN, COUNT)
SELECT c.nome AS cliente, COUNT(os.id_os) AS quantidade_ordens
FROM cliente c
LEFT JOIN veiculo v ON v.id_cliente = c.id_cliente
LEFT JOIN ordem_servico os ON os.id_veiculo = v.id_veiculo
GROUP BY c.id_cliente, c.nome
ORDER BY quantidade_ordens DESC, c.nome;

-- 06. Quais mecanicos trabalham em cada equipe? (JOIN N:N)
SELECT e.nome AS equipe, m.nome AS mecanico, m.especialidade
FROM equipe e
JOIN equipe_mecanico em ON em.id_equipe = e.id_equipe
JOIN mecanico m ON m.id_mecanico = em.id_mecanico
ORDER BY e.nome, m.nome;

-- 07. Quais equipes tem pelo menos 2 mecanicos? (GROUP BY, HAVING)
SELECT e.nome AS equipe, COUNT(em.id_mecanico) AS total_mecanicos
FROM equipe e
JOIN equipe_mecanico em ON em.id_equipe = e.id_equipe
GROUP BY e.id_equipe, e.nome
HAVING COUNT(em.id_mecanico) >= 2
ORDER BY total_mecanicos DESC, e.nome;

-- 08. Qual e o custo de mao de obra por ordem? (atributo derivado)
SELECT os.id_os, COALESCE(SUM(it.quantidade * it.valor_unitario), 0) AS total_servicos
FROM ordem_servico os
LEFT JOIN item_servico it ON it.id_os = os.id_os
GROUP BY os.id_os ORDER BY os.id_os;

-- 09. Qual e o custo de pecas por ordem? (atributo derivado)
SELECT os.id_os, COALESCE(SUM(ip.quantidade * ip.valor_unitario), 0) AS total_pecas
FROM ordem_servico os
LEFT JOIN item_peca ip ON ip.id_os = os.id_os
GROUP BY os.id_os ORDER BY os.id_os;

-- 10. Qual e o valor completo da OS (servicos + pecas)?
-- Agregamos cada tipo em separado para NAO multiplicar valores por joins 1:N simultaneos.
WITH valor_servicos AS (
    SELECT id_os, SUM(quantidade * valor_unitario) AS total_servicos
    FROM item_servico GROUP BY id_os
), valor_pecas AS (
    SELECT id_os, SUM(quantidade * valor_unitario) AS total_pecas
    FROM item_peca GROUP BY id_os
)
SELECT os.id_os, c.nome AS cliente, v.placa, os.status,
       COALESCE(vs.total_servicos, 0) AS total_servicos,
       COALESCE(vp.total_pecas, 0) AS total_pecas,
       COALESCE(vs.total_servicos, 0) + COALESCE(vp.total_pecas, 0) AS total_geral
FROM ordem_servico os
JOIN veiculo v ON v.id_veiculo = os.id_veiculo
JOIN cliente c ON c.id_cliente = v.id_cliente
LEFT JOIN valor_servicos vs ON vs.id_os = os.id_os
LEFT JOIN valor_pecas vp ON vp.id_os = os.id_os
ORDER BY total_geral DESC, os.id_os;

-- 11. Quais servicos aparecem em mais de uma ordem? (HAVING)
SELECT s.descricao, COUNT(it.id_os) AS ordens_com_servico
FROM servico s
JOIN item_servico it ON it.id_servico = s.id_servico
GROUP BY s.id_servico, s.descricao
HAVING COUNT(it.id_os) > 1
ORDER BY ordens_com_servico DESC, s.descricao;

-- 12. Quais pecas estao com estoque abaixo de 10 unidades? (WHERE, ORDER BY)
SELECT nome, quantidade_estoque, preco_atual
FROM peca WHERE quantidade_estoque < 10
ORDER BY quantidade_estoque ASC, nome;

-- 13. Qual e a quantidade de OS por status? (GROUP BY)
SELECT status, COUNT(*) AS quantidade
FROM ordem_servico GROUP BY status ORDER BY quantidade DESC, status;

-- 14. Quais OS contem mais de 2 unidades de pecas? (HAVING, SUM)
SELECT os.id_os, SUM(ip.quantidade) AS total_unidades
FROM ordem_servico os
JOIN item_peca ip ON ip.id_os = os.id_os
GROUP BY os.id_os HAVING SUM(ip.quantidade) > 2
ORDER BY total_unidades DESC, os.id_os;

-- 15. Quais equipes atenderam cada veiculo? (multiplos JOIN)
SELECT os.id_os, c.nome AS cliente, v.placa, e.nome AS equipe, os.status
FROM ordem_servico os
JOIN veiculo v ON v.id_veiculo = os.id_veiculo
JOIN cliente c ON c.id_cliente = v.id_cliente
JOIN equipe e ON e.id_equipe = os.id_equipe
ORDER BY os.id_os;

-- 16. Quais ordens tem total superior a R$ 300? (CTE, WHERE, ORDER BY)
WITH servicos AS (
    SELECT id_os, SUM(quantidade * valor_unitario) AS total
    FROM item_servico GROUP BY id_os
), pecas AS (
    SELECT id_os, SUM(quantidade * valor_unitario) AS total
    FROM item_peca GROUP BY id_os
)
SELECT os.id_os, os.status,
       COALESCE(s.total,0) + COALESCE(p.total,0) AS valor_total
FROM ordem_servico os
LEFT JOIN servicos s ON s.id_os = os.id_os
LEFT JOIN pecas p ON p.id_os = os.id_os
WHERE COALESCE(s.total,0) + COALESCE(p.total,0) > 300
ORDER BY valor_total DESC;

-- 17. Quais OS foram concluidas e quantos dias demoraram? (atributo derivado)
SELECT os.id_os, c.nome AS cliente, os.data_emissao, os.data_conclusao,
       (os.data_conclusao - os.data_emissao) AS dias_execucao
FROM ordem_servico os
JOIN veiculo v ON v.id_veiculo = os.id_veiculo
JOIN cliente c ON c.id_cliente = v.id_cliente
WHERE os.status = 'CONCLUIDA'
ORDER BY dias_execucao DESC;

-- 18. Quanto ja foi faturado pelas ordens concluidas? (JOINs e agregacao)
WITH totais AS (
    SELECT id_os, SUM(valor) AS valor_total
    FROM (
        SELECT id_os, quantidade * valor_unitario AS valor FROM item_servico
        UNION ALL
        SELECT id_os, quantidade * valor_unitario AS valor FROM item_peca
    ) movimentos
    GROUP BY id_os
)
SELECT COUNT(*) AS ordens_concluidas, COALESCE(SUM(t.valor_total), 0) AS faturamento
FROM ordem_servico os
LEFT JOIN totais t ON t.id_os = os.id_os
WHERE os.status = 'CONCLUIDA';

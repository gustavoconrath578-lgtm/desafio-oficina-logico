# Banco de Dados — Oficina Mecânica

## Sobre o projeto

Neste desafio, montei o modelo lógico de um banco de dados para uma oficina mecânica e criei os scripts SQL para colocar esse modelo em prática.

A ideia é organizar os clientes e seus veículos, os mecânicos que trabalham nas equipes e as ordens de serviço da oficina. Cada ordem registra o veículo atendido, a equipe responsável, os serviços realizados e as peças utilizadas.

## O que foi feito

- Criação de **10 tabelas** com chaves primárias e estrangeiras, além de regras para evitar dados inválidos.
- Relacionamento entre **clientes e veículos** e entre **veículos e ordens de serviço**.
- Relacionamento de **muitos para muitos** entre mecânicos e equipes, e entre ordens de serviço, peças e serviços.
- Cadastro de dados fictícios para testar o banco.
- **18 consultas SQL** com `SELECT`, `WHERE`, `ORDER BY`, `GROUP BY`, `HAVING`, `JOIN` e cálculos.

O valor total de cada ordem é calculado a partir dos serviços e das peças, sem precisar guardar um total duplicado na tabela.

## Modelo lógico

![Modelo lógico da oficina](diagramas/modelo_logico.png)

## Perguntas respondidas pelas consultas

Algumas perguntas que busquei responder foram: quais veículos pertencem a cada cliente? Quantas ordens de serviço cada cliente possui? Quais mecânicos trabalham em cada equipe? Qual o custo de uma ordem de serviço? Quais peças estão com estoque baixo? E quais serviços foram feitos mais de uma vez?

As perguntas estão comentadas no arquivo de consultas, junto com cada comando SQL.

## Arquivos do projeto

- `sql/01_criar_esquema.sql` — cria o esquema e as tabelas.
- `sql/02_inserir_dados.sql` — insere dados de exemplo.
- `sql/03_consultas.sql` — contém as 18 consultas do desafio.
- `sql/04_testes_integridade.sql` — verifica alguns relacionamentos e restrições.
- `diagramas/modelo_logico.png` — imagem do modelo lógico.
- `diagramas/modelo_logico.svg` — versão do desenho para ampliar sem perder qualidade.
- `diagramas/modelo_logico.dot` — arquivo editável do diagrama (Graphviz).

## Como executar

Usei **PostgreSQL** como banco de dados. No **pgAdmin 4**, crie ou abra um banco de testes e execute os arquivos na seguinte ordem:

1. `01_criar_esquema.sql`
2. `02_inserir_dados.sql`
3. `03_consultas.sql`
4. `04_testes_integridade.sql` (opcional)

**Atenção:** o primeiro script apaga e recria o esquema `oficina`. Por isso, não execute em um banco com dados importantes nesse esquema.

## Observação

Como o modelo conceitual original da oficina não estava anexado, utilizei um cenário comum de oficina mecânica como base. Assim, o modelo pode ser ajustado caso o desenho apresentado pelo professor tenha entidades ou relacionamentos diferentes.

O controle de estoque é ilustrativo: o banco guarda quantidades disponíveis e peças utilizadas nas ordens, mas não realiza baixa automática de estoque. Os valores de cada item ficam registrados na própria ordem para preservar o preço cobrado na época.

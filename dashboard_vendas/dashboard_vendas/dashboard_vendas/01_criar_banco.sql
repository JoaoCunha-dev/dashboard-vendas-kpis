-- ============================================================
--  SISTEMA DE VENDAS – Dashboard de KPIs
--  Trabalho Avaliativo – 3ª Avaliação
-- ============================================================

-- ──────────────────────────────────────────────
--  1. CRIAÇÃO DAS TABELAS
-- ──────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS clientes (
    id_cliente   SERIAL PRIMARY KEY,
    nome         VARCHAR(100) NOT NULL,
    cidade       VARCHAR(80),
    estado       CHAR(2),
    email        VARCHAR(120),
    data_cadastro DATE DEFAULT CURRENT_DATE
);

CREATE TABLE IF NOT EXISTS categorias (
    id_categoria SERIAL PRIMARY KEY,
    nome         VARCHAR(60) NOT NULL
);

CREATE TABLE IF NOT EXISTS produtos (
    id_produto   SERIAL PRIMARY KEY,
    nome         VARCHAR(120) NOT NULL,
    id_categoria INT REFERENCES categorias(id_categoria),
    preco_unit   NUMERIC(10,2) NOT NULL,
    estoque      INT DEFAULT 0
);

CREATE TABLE IF NOT EXISTS vendas (
    id_venda     SERIAL PRIMARY KEY,
    id_cliente   INT REFERENCES clientes(id_cliente),
    data_venda   DATE NOT NULL,
    status       VARCHAR(30) DEFAULT 'Concluída'   -- Concluída / Cancelada / Pendente
);

CREATE TABLE IF NOT EXISTS itens_venda (
    id_item      SERIAL PRIMARY KEY,
    id_venda     INT REFERENCES vendas(id_venda),
    id_produto   INT REFERENCES produtos(id_produto),
    quantidade   INT NOT NULL,
    preco_unit   NUMERIC(10,2) NOT NULL            -- preço na época da venda
);


-- ──────────────────────────────────────────────
--  2. DADOS DE CATEGORIAS
-- ──────────────────────────────────────────────
INSERT INTO categorias (nome) VALUES
    ('Eletrônicos'),
    ('Roupas'),
    ('Alimentos'),
    ('Livros'),
    ('Esportes');


-- ──────────────────────────────────────────────
--  3. DADOS DE PRODUTOS
-- ──────────────────────────────────────────────
INSERT INTO produtos (nome, id_categoria, preco_unit, estoque) VALUES
    ('Smartphone Samsung Galaxy A54', 1, 1299.90, 50),
    ('Notebook Dell Inspiron 15',     1, 3499.00, 20),
    ('Fone de Ouvido JBL Tune 510',   1,  199.90, 80),
    ('Smart TV LG 50"',               1, 2199.00, 15),
    ('Tablet Lenovo M10',             1,  899.00, 30),
    ('Camiseta Polo Masculina',       2,   79.90, 200),
    ('Calça Jeans Skinny',            2,  129.90, 150),
    ('Tênis Nike Air Max',            2,  449.90, 60),
    ('Vestido Floral Feminino',       2,   99.90, 100),
    ('Jaqueta Corta-vento',           2,  189.90, 70),
    ('Arroz Branco 5kg',              3,   22.50, 500),
    ('Azeite Extra Virgem 500ml',     3,   34.90, 300),
    ('Café Pilão 500g',               3,   18.90, 400),
    ('Whey Protein 1kg',              3,  119.90, 120),
    ('Biscoito Integral Caixa',       3,   12.50, 600),
    ('O Senhor dos Anéis',            4,   59.90,  80),
    ('Clean Code – Robert Martin',    4,   89.90,  50),
    ('Sapiens – Yuval Harari',        4,   49.90,  90),
    ('O Poder do Hábito',             4,   44.90,  70),
    ('Python Fluente',                4,   94.90,  40),
    ('Bicicleta Speed Caloi 10',      5, 1899.00,  10),
    ('Tênis de Corrida Mizuno',       5,  359.90,  45),
    ('Luva de Academia',              5,   39.90, 120),
    ('Garrafa Squeeze 750ml',         5,   29.90, 200),
    ('Mochila de Trilha 30L',         5,  249.90,  35);


-- ──────────────────────────────────────────────
--  4. DADOS DE CLIENTES (30 clientes)
-- ──────────────────────────────────────────────
INSERT INTO clientes (nome, cidade, estado, email, data_cadastro) VALUES
    ('Ana Souza',          'São Paulo',      'SP', 'ana.souza@email.com',        '2023-01-10'),
    ('Bruno Lima',         'Rio de Janeiro', 'RJ', 'bruno.lima@email.com',       '2023-02-14'),
    ('Carla Mendes',       'Belo Horizonte', 'MG', 'carla.mendes@email.com',     '2023-03-05'),
    ('Diego Ferreira',     'Curitiba',       'PR', 'diego.ferreira@email.com',   '2023-03-20'),
    ('Eduarda Costa',      'Porto Alegre',   'RS', 'eduarda.costa@email.com',    '2023-04-01'),
    ('Felipe Rodrigues',   'Salvador',       'BA', 'felipe.rodrigues@email.com', '2023-04-15'),
    ('Gabriela Oliveira',  'Fortaleza',      'CE', 'gabriela.oliveira@email.com','2023-05-02'),
    ('Henrique Martins',   'Recife',         'PE', 'henrique.martins@email.com', '2023-05-18'),
    ('Isabela Alves',      'Manaus',         'AM', 'isabela.alves@email.com',    '2023-06-07'),
    ('João Pedro Silva',   'Brasília',       'DF', 'joao.silva@email.com',       '2023-06-22'),
    ('Karen Nascimento',   'Teresina',       'PI', 'karen.nascimento@email.com', '2023-07-10'),
    ('Lucas Barbosa',      'Goiânia',        'GO', 'lucas.barbosa@email.com',    '2023-07-25'),
    ('Marina Torres',      'Maceió',         'AL', 'marina.torres@email.com',    '2023-08-08'),
    ('Nicolas Pereira',    'Campo Grande',   'MS', 'nicolas.pereira@email.com',  '2023-08-19'),
    ('Olivia Carvalho',    'João Pessoa',    'PB', 'olivia.carvalho@email.com',  '2023-09-03'),
    ('Paulo Gomes',        'Natal',          'RN', 'paulo.gomes@email.com',      '2023-09-14'),
    ('Quésia Monteiro',    'Aracaju',        'SE', 'quesia.monteiro@email.com',  '2023-10-01'),
    ('Rafael Sousa',       'Belém',          'PA', 'rafael.sousa@email.com',     '2023-10-20'),
    ('Sabrina Ribeiro',    'São Luís',       'MA', 'sabrina.ribeiro@email.com',  '2023-11-05'),
    ('Thiago Araujo',      'Florianópolis',  'SC', 'thiago.araujo@email.com',    '2023-11-22'),
    ('Ursula Freitas',     'Vitória',        'ES', 'ursula.freitas@email.com',   '2023-12-10'),
    ('Victor Azevedo',     'Porto Velho',    'RO', 'victor.azevedo@email.com',   '2024-01-05'),
    ('Wanderson Nunes',    'Cuiabá',         'MT', 'wanderson.nunes@email.com',  '2024-01-18'),
    ('Xenia Cavalcanti',   'Macapá',         'AP', 'xenia.cavalcanti@email.com', '2024-02-02'),
    ('Yasmin Lopes',       'Boa Vista',      'RR', 'yasmin.lopes@email.com',     '2024-02-20'),
    ('Zeca Pinheiro',      'Rio Branco',     'AC', 'zeca.pinheiro@email.com',    '2024-03-01'),
    ('Alice Duarte',       'São Paulo',      'SP', 'alice.duarte@email.com',     '2024-03-15'),
    ('Bernardo Castro',    'Rio de Janeiro', 'RJ', 'bernardo.castro@email.com',  '2024-04-02'),
    ('Cecília Moraes',     'Curitiba',       'PR', 'cecilia.moraes@email.com',   '2024-04-18'),
    ('Daniel Farias',      'Salvador',       'BA', 'daniel.farias@email.com',    '2024-05-01');


-- ──────────────────────────────────────────────
--  5. DADOS DE VENDAS (60 vendas ao longo de 2024)
-- ──────────────────────────────────────────────
INSERT INTO vendas (id_cliente, data_venda, status) VALUES
-- Janeiro
(1,  '2024-01-05', 'Concluída'),
(3,  '2024-01-12', 'Concluída'),
(7,  '2024-01-18', 'Concluída'),
(10, '2024-01-22', 'Cancelada'),
(15, '2024-01-28', 'Concluída'),
-- Fevereiro
(2,  '2024-02-03', 'Concluída'),
(5,  '2024-02-10', 'Concluída'),
(8,  '2024-02-14', 'Concluída'),
(12, '2024-02-20', 'Pendente'),
(18, '2024-02-25', 'Concluída'),
-- Março
(4,  '2024-03-02', 'Concluída'),
(6,  '2024-03-08', 'Concluída'),
(9,  '2024-03-15', 'Concluída'),
(11, '2024-03-20', 'Concluída'),
(20, '2024-03-27', 'Cancelada'),
-- Abril
(1,  '2024-04-04', 'Concluída'),
(13, '2024-04-10', 'Concluída'),
(16, '2024-04-17', 'Concluída'),
(22, '2024-04-23', 'Concluída'),
(25, '2024-04-29', 'Concluída'),
-- Maio
(3,  '2024-05-06', 'Concluída'),
(7,  '2024-05-12', 'Concluída'),
(14, '2024-05-18', 'Concluída'),
(19, '2024-05-24', 'Pendente'),
(27, '2024-05-30', 'Concluída'),
-- Junho
(2,  '2024-06-05', 'Concluída'),
(5,  '2024-06-11', 'Concluída'),
(10, '2024-06-16', 'Concluída'),
(21, '2024-06-22', 'Concluída'),
(28, '2024-06-28', 'Concluída'),
-- Julho
(4,  '2024-07-03', 'Concluída'),
(8,  '2024-07-09', 'Concluída'),
(15, '2024-07-15', 'Cancelada'),
(23, '2024-07-21', 'Concluída'),
(29, '2024-07-27', 'Concluída'),
-- Agosto
(6,  '2024-08-02', 'Concluída'),
(11, '2024-08-08', 'Concluída'),
(17, '2024-08-14', 'Concluída'),
(24, '2024-08-20', 'Concluída'),
(30, '2024-08-26', 'Concluída'),
-- Setembro
(1,  '2024-09-03', 'Concluída'),
(9,  '2024-09-09', 'Concluída'),
(13, '2024-09-15', 'Pendente'),
(20, '2024-09-21', 'Concluída'),
(26, '2024-09-27', 'Concluída'),
-- Outubro
(3,  '2024-10-04', 'Concluída'),
(7,  '2024-10-10', 'Concluída'),
(16, '2024-10-16', 'Concluída'),
(22, '2024-10-22', 'Concluída'),
(28, '2024-10-28', 'Cancelada'),
-- Novembro
(2,  '2024-11-05', 'Concluída'),
(10, '2024-11-11', 'Concluída'),
(18, '2024-11-18', 'Concluída'),
(25, '2024-11-24', 'Concluída'),
(30, '2024-11-29', 'Concluída'),
-- Dezembro
(5,  '2024-12-03', 'Concluída'),
(12, '2024-12-09', 'Concluída'),
(19, '2024-12-15', 'Concluída'),
(27, '2024-12-21', 'Concluída'),
(29, '2024-12-28', 'Concluída');


-- ──────────────────────────────────────────────
--  6. ITENS DE VENDA
-- ──────────────────────────────────────────────
INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unit) VALUES
-- Venda 1
(1,  1,  1, 1299.90), (1,  6,  2,   79.90),
-- Venda 2
(2,  2,  1, 3499.00),
-- Venda 3
(3,  3,  1,  199.90), (3, 11,  3,   22.50),
-- Venda 4 (Cancelada)
(4,  4,  1, 2199.00),
-- Venda 5
(5,  5,  1,  899.00), (5, 16,  1,   59.90),
-- Venda 6
(6,  7,  2,  129.90), (6, 17,  1,   89.90),
-- Venda 7
(7,  8,  1,  449.90), (7, 22,  1,  359.90),
-- Venda 8
(8,  9,  1,   99.90), (8, 10,  1,  189.90),
-- Venda 9 (Pendente)
(9,  1,  1, 1299.90),
-- Venda 10
(10, 3,  2,  199.90), (10, 18, 1,   49.90),
-- Venda 11
(11, 2,  1, 3499.00), (11, 20, 1,   94.90),
-- Venda 12
(12, 13, 2,   18.90), (12, 14, 1,  119.90),
-- Venda 13
(13, 21, 1, 1899.00),
-- Venda 14
(14, 6,  3,   79.90), (14, 7, 2, 129.90),
-- Venda 15 (Cancelada)
(15, 4,  1, 2199.00),
-- Venda 16
(16, 1,  1, 1299.90), (16, 3, 1, 199.90),
-- Venda 17
(17, 23, 2,   39.90), (17, 24, 1,   29.90),
-- Venda 18
(18, 5,  1,  899.00), (18, 19, 1,   44.90),
-- Venda 19
(19, 8,  1,  449.90),
-- Venda 20
(20, 2,  1, 3499.00),
-- Venda 21
(21, 17, 2,   89.90), (21, 16, 1,   59.90),
-- Venda 22
(22, 6,  4,   79.90), (22, 9, 2,   99.90),
-- Venda 23
(23, 10, 1,  189.90), (23, 22, 1,  359.90),
-- Venda 24 (Pendente)
(24, 14, 2,  119.90),
-- Venda 25
(25, 1,  2, 1299.90),
-- Venda 26
(26, 4,  1, 2199.00), (26, 3, 1, 199.90),
-- Venda 27
(27, 25, 1,  249.90), (27, 23, 2,   39.90),
-- Venda 28
(28, 7,  3,  129.90), (28, 18, 1,   49.90),
-- Venda 29
(29, 2,  1, 3499.00),
-- Venda 30
(30, 20, 1,   94.90), (30, 19, 1,   44.90),
-- Venda 31
(31, 8,  2,  449.90),
-- Venda 32
(32, 5,  1,  899.00), (32, 13, 3,   18.90),
-- Venda 33 (Cancelada)
(33, 1,  1, 1299.90),
-- Venda 34
(34, 6,  2,   79.90), (34, 24, 3,   29.90),
-- Venda 35
(35, 21, 1, 1899.00), (35, 23, 1,   39.90),
-- Venda 36
(36, 3,  3,  199.90),
-- Venda 37
(37, 17, 1,   89.90), (37, 16, 2,   59.90),
-- Venda 38
(38, 9,  2,   99.90), (38, 10, 1,  189.90),
-- Venda 39
(39, 2,  1, 3499.00),
-- Venda 40
(40, 14, 1,  119.90), (40, 11, 5,   22.50),
-- Venda 41
(41, 1,  1, 1299.90), (41, 20, 1,   94.90),
-- Venda 42
(42, 7,  2,  129.90), (42, 8, 1, 449.90),
-- Venda 43 (Pendente)
(43, 4,  1, 2199.00),
-- Venda 44
(44, 25, 2,  249.90), (44, 22, 1,  359.90),
-- Venda 45
(45, 3,  1,  199.90), (45, 18, 1,   49.90),
-- Venda 46
(46, 5,  1,  899.00),
-- Venda 47
(47, 6,  3,   79.90), (47, 13, 2,   18.90),
-- Venda 48
(48, 2,  1, 3499.00), (48, 17, 1,   89.90),
-- Venda 49
(49, 9,  1,   99.90), (49, 19, 2,   44.90),
-- Venda 50 (Cancelada)
(50, 1,  1, 1299.90),
-- Venda 51
(51, 3,  2,  199.90), (51, 23, 2,   39.90),
-- Venda 52
(52, 7,  1,  129.90), (52, 24, 4,   29.90),
-- Venda 53
(53, 10, 1,  189.90), (53, 16, 1,   59.90),
-- Venda 54
(54, 21, 1, 1899.00),
-- Venda 55
(55, 14, 3,  119.90), (55, 11, 4,   22.50),
-- Venda 56
(56, 8,  1,  449.90), (56, 25, 1,  249.90),
-- Venda 57
(57, 2,  1, 3499.00),
-- Venda 58
(58, 6,  2,   79.90), (58, 20, 1,   94.90),
-- Venda 59
(59, 5,  1,  899.00), (59, 17, 1,   89.90),
-- Venda 60
(60, 1,  2, 1299.90), (60, 3, 1, 199.90);

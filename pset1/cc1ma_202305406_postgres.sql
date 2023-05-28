
psql -U postgres
computacao@raiz

-- Excluir o esquema "lojas" se ele existir
DROP SCHEMA IF EXISTS lojas;

-- Excluir o banco de dados "uvv" se ele existir
DROP DATABASE IF EXISTS uvv;

-- Excluir o usuário "marcos" se ele existir
DROP USER IF EXISTS marcos;

-- Criar um novo usuário chamado "marcos" com privilégios específicos e senha criptografada
CREATE USER marcos WITH
SUPERUSER -- Conceder privilégios de superusuário
CREATEDB -- Permitir criação de bancos de dados
CREATEROLE -- Permitir criação de papéis (usuários)
LOGIN -- Permitir fazer login
ENCRYPTED PASSWORD 'pokemon1234'; -- Definir a senha criptografada como 'pokemon1234'


-- Criar um novo banco de dados chamado "uvv" com configurações específicas e de propriedade do usuário "marcos"
CREATE DATABASE uvv WITH
OWNER = marcos
TEMPLATE = template0
ENCODING = 'UTF8'
LC_COLLATE = 'pt_BR.UTF-8'
LC_CTYPE = 'pt_BR.UTF-8'
ALLOW_CONNECTIONS = true;

-- Definir o usuário atual como "marcos"
SET role marcos;

-- Conectar ao banco de dados "uvv" como usuário "marcos" com a senha "pokemon1234"
-- Essa informação de login eu consegui com meu mano Matheus Endlich do CC1MA
\c "host=localhost dbname=uvv user=marcos password=pokemon1234";

-- Criar o esquema "lojas" com o proprietário definido como "marcos"
CREATE SCHEMA lojas AUTHORIZATION marcos;

-- Mostrar o caminho de pesquisa atual
SHOW SEARCH_PATH;
-- Selecionar o esquema atual
SELECT CURRENT_SCHEMA();
-- Definir o caminho de pesquisa para "lojas", o esquema do usuário atual e o esquema público
SET SEARCH_PATH TO lojas, "$user", public;
-- Alterar o caminho de pesquisa do usuário "marcos" para "lojas", o esquema do usuário atual e o esquema público
ALTER USER marcos SET SEARCH_PATH TO lojas, "$user", public;


CREATE TABLE lojas (
                loja_id NUMERIC(38) NOT NULL,
                nome VARCHAR(255) NOT NULL,
                endereco_web VARCHAR(100),
                endereco_fisico VARCHAR(512),
                latitude NUMERIC,
                longitude NUMERIC,
                logo BOOLEAN,
                logo_mime_type VARCHAR(512),
                logo_arquivo VARCHAR(512),
                logo_charset VARCHAR(512),
                logo_ultima_atualizacao DATE,
                CONSTRAINT loja_pk PRIMARY KEY (loja_id)
);
COMMENT ON TABLE lojas IS 'Tabela da loja com suas informações';
COMMENT ON COLUMN lojas.loja_id IS 'Id de identificação na loja';
COMMENT ON COLUMN lojas.nome IS 'Nome da loja designada na tabela';
COMMENT ON COLUMN lojas.endereco_web IS 'Endereço Web da loja designada';
COMMENT ON COLUMN lojas.endereco_fisico IS 'Endereco Fisico da loja designada';
COMMENT ON COLUMN lojas.latitude IS 'Latitude de onde a loja está no maps';
COMMENT ON COLUMN lojas.longitude IS 'Longitude de onde a loja está no maps';
COMMENT ON COLUMN lojas.logo IS 'Armazenamento da url ou carregamento de fixeiro da logo da loja';
COMMENT ON COLUMN lojas.logo_mime_type IS 'Tipo de informação da logo';
COMMENT ON COLUMN lojas.logo_arquivo IS 'Arquivo designado a logo da loja';
COMMENT ON COLUMN lojas.logo_charset IS 'Charset da logo definida na loja';
COMMENT ON COLUMN lojas.logo_ultima_atualizacao IS 'A ultima atualização feita no sistema da loja';

-- Adiciona uma restrição à tabela lojas para verificar a validade dos endereços
ALTER TABLE lojas ADD CONSTRAINT endereco_check 
CHECK (
    (endereco_web IS NULL OR endereco_fisico IS NOT NULL) OR -- Verifica se o endereço web é nulo e o endereço físico não é nulo
    (endereco_web IS NOT NULL OR endereco_fisico IS NULL) -- Verifica se o endereço web não é nulo e o endereço físico é nulo
);

-- Adiciona restrições à tabela "lojas" para verificar a validade das coordenadas de latitude e longitude

ALTER TABLE lojas
ADD CONSTRAINT latitude_check
CHECK (latitude >= -90 AND latitude <= 90), -- Verifica se a latitude está dentro do intervalo válido (-90 a 90)
ADD CONSTRAINT longitude_check
CHECK (longitude >= -180 AND longitude <= 180); -- Verifica se a longitude está dentro do intervalo válido (-180 a 180)



CREATE TABLE produtos (
    produto_id NUMERIC(38) NOT NULL, -- Id de indentificação do produto
    nome VARCHAR(255) NOT NULL, -- Nome do produto designado no sistema
    preco_unitario NUMERIC(10,2) CHECK (preco_unitario >= 0), -- Preço unitário do produto
    detalhes BYTEA, -- Detalhes e as informações do produto
    imagem BYTEA, -- Imagem designada do produto e seu endereço na tabela
    imagem_mime_type VARCHAR(512), -- Tipo de item da imagem relacionada no produto
    imagem_arquivo VARCHAR(512), -- Arquivo da imagem
    imagem_charset VARCHAR(512), -- Charset da imagem do produto
    imagem_ultima_atualizacao DATE NOT NULL, -- Data da última atualização do produto
    CONSTRAINT produto_pk PRIMARY KEY (produto_id)
);

-- Comentário da tabela produtos
COMMENT ON TABLE produtos IS 'tabela de produtos da loja, que estará alocada ao estoque';
COMMENT ON COLUMN produtos.produto_id IS 'Id de indentificação do produto';
COMMENT ON COLUMN produtos.nome IS 'Nome do produto designado no sistema';
COMMENT ON COLUMN produtos.preco_unitario IS 'Preço unitário do produto';
COMMENT ON COLUMN produtos.detalhes IS 'Detalhes e as informações do produto';
COMMENT ON COLUMN produtos.imagem IS 'Imagem designada do produto e seu endereço na tabela';
COMMENT ON COLUMN produtos.imagem_mime_type IS 'Tipo de item da imagem relacionada no produto';
COMMENT ON COLUMN produtos.imagem_arquivo IS 'Arquivo da imagem';
COMMENT ON COLUMN produtos.imagem_charset IS 'Charset da imagem do produto';
COMMENT ON COLUMN produtos.imagem_ultima_atualizacao IS 'Data da última atualização do produto';


CREATE TABLE estoques (
    estoque_id NUMERIC(38) NOT NULL, -- ID de indentificação do estoque que será usado para relacionar as lojas e os produtos
    loja_id NUMERIC(38) NOT NULL, -- ID de identificação na loja
    produto_id NUMERIC(38) NOT NULL, -- ID de indentificação do produto
    quantidade NUMERIC(38) NOT NULL, -- Quantidade de produtos que terá no estoque
    CONSTRAINT estoque_pk PRIMARY KEY (estoque_id)
);

-- Comentário da tabela estoques
COMMENT ON TABLE estoques IS 'Estoque, terá e conterá todos os produtos que estarão relacionados à loja e sua quantidade';
COMMENT ON COLUMN estoques.estoque_id IS 'ID de indentificação do estoque que será usado para relacionar as lojas e os produtos';
COMMENT ON COLUMN estoques.loja_id IS 'ID de identificação na loja';
COMMENT ON COLUMN estoques.produto_id IS 'ID de indentificação do produto';
COMMENT ON COLUMN estoques.quantidade IS 'Quantidade de produtos que terá no estoque';


CREATE TABLE clientes (
    cliente_Id NUMERIC(38) NOT NULL, -- ID do Cliente para sua identificação no banco
    email VARCHAR(255) NOT NULL, -- Email da tabela cliente
    nome VARCHAR(255) NOT NULL, -- Nome da tabela cliente
    telefone1 VARCHAR(20), -- Número de telefone 1 do cliente
    telefone2 VARCHAR(20), -- Número de telefone 2 do cliente
    telefone3 VARCHAR(20), -- Número de telefone 3 do cliente
    CONSTRAINT clientes_pk PRIMARY KEY (cliente_Id)
);

-- Comentário da tabela clientes
COMMENT ON TABLE clientes IS 'Essa é a tabela de clientes que possui as suas informações';
COMMENT ON COLUMN clientes.cliente_Id IS 'Esse é o ID do Cliente para sua identificação no banco';
COMMENT ON COLUMN clientes.email IS 'Esse é o email da tabela cliente';
COMMENT ON COLUMN clientes.nome IS 'Esse é o nome da tabela cliente';
COMMENT ON COLUMN clientes.telefone1 IS 'Esse é o número de telefone 1 do cliente';
COMMENT ON COLUMN clientes.telefone2 IS 'Esse é o número de telefone 2 do cliente';
COMMENT ON COLUMN clientes.telefone3 IS 'Esse é o número de telefone 3 do cliente';


CREATE TABLE pedidos (
    pedido_id NUMERIC(38) NOT NULL, -- ID de de identificação dos pedidos
    data_hora TIMESTAMP NOT NULL, -- Data e hora de lançamento dos pedidos
    cliente_Id NUMERIC(38) NOT NULL, -- ID do Cliente para sua identificação no banco
    -- Juntamente com um Check para o seu Status
    status VARCHAR(15) NOT NULL CHECK (status IN ('CANCELADO', 'COMPLETO', 'ABERTO', 'PAGO', 'REEMBOLSADO', 'ENVIADO')), -- Status do pedido e seu encaminhamento
    loja_id NUMERIC(38) NOT NULL, -- ID de identificação na loja
    CONSTRAINT pedido_pk PRIMARY KEY (pedido_id)
);
-- Comentários das colunas da tabela pedidos
COMMENT ON COLUMN pedidos.pedido_id IS 'ID de de identificação dos pedidos';
COMMENT ON COLUMN pedidos.data_hora IS 'Data e hora de lançamento dos pedidos';
COMMENT ON COLUMN pedidos.cliente_Id IS 'Esse é o ID do Cliente para sua identificação no banco';
COMMENT ON COLUMN pedidos.status IS 'Status do pedido e seu encaminhamento';
COMMENT ON COLUMN pedidos.loja_id IS 'ID de identificação na loja';


CREATE TABLE envios (
    envio_id NUMERIC(38) NOT NULL, -- ID de identificação da tabela envios
    loja_id NUMERIC(38) NOT NULL, -- ID de identificação na loja
    cliente_Id NUMERIC(38) NOT NULL, -- ID do Cliente para sua identificação no banco
    endereco_entrega VARCHAR(512) NOT NULL, -- Endereço de entrega do sistema da tabela de Envios
    status VARCHAR(15) NOT NULL, -- Status do envio
    CONSTRAINT envios_pk PRIMARY KEY (envio_id)
);
-- Comentário da tabela envios
COMMENT ON TABLE envios IS 'Essa é uma tabela onde conterá todos os envios dos produtos aos clientes';
COMMENT ON COLUMN envios.envio_id IS 'Esse é o ID de identificação da tabela envios';
COMMENT ON COLUMN envios.loja_id IS 'ID de identificação na loja';
COMMENT ON COLUMN envios.cliente_Id IS 'Esse é o ID do Cliente para sua identificação no banco';
COMMENT ON COLUMN envios.endereco_entrega IS 'Esse é o endereço de entrega do sistema da tabela de Envios';
COMMENT ON COLUMN envios.status IS 'Status do envio';


-- Possui 2 Checks de quantidade para "quantidade" e "preco_unitario"
CREATE TABLE pedidos_itens (
    pedido_id NUMERIC(38) NOT NULL, -- ID de de identificação dos pedidos
    produto_id NUMERIC(38) NOT NULL, -- ID de indentificação do produto
    numero_da_linha NUMERIC(38) NOT NULL, -- Numero da linha que o produto foi designado
    preco_unitario NUMERIC(10,2) NOT NULL CHECK (preco_unitario >= 0), -- Preco unitario para o item que será encaminhado
    quantidade NUMERIC NOT NULL CHECK (quantidade >= 0), -- Define a quantidade do produto que estará sendo encaminhado ao cliente
    envio_id NUMERIC(38), -- ID de identificação da tabela envios
    CONSTRAINT pedidos_itens_pk PRIMARY KEY (pedido_id, produto_id)
);

-- Comentário da tabela pedidos_itens
COMMENT ON TABLE pedidos_itens IS 'Itens pedidos, conterá qual produto será enviado';
COMMENT ON COLUMN pedidos_itens.pedido_id IS 'ID de de identificação dos pedidos';
COMMENT ON COLUMN pedidos_itens.produto_id IS 'ID de indentificação do produto';
COMMENT ON COLUMN pedidos_itens.numero_da_linha IS 'Numero da linha que o produto foi designado';
COMMENT ON COLUMN pedidos_itens.preco_unitario IS 'Preco unitario para o item que será encaminhado';
COMMENT ON COLUMN pedidos_itens.quantidade IS 'Define a quantidade do produto que estará sendo encaminhado ao cliente';
COMMENT ON COLUMN pedidos_itens.envio_id IS 'Esse é o ID de identificação da tabela envios';

-- Definindo a restrição de chave estrangeira (FK) "produtos_estoques_fk" na tabela "estoques" para referenciar a chave primária (PK) "produto_id" da tabela "produtos".
ALTER TABLE estoques ADD CONSTRAINT produtos_estoques_fk
FOREIGN KEY (produto_id)
REFERENCES produtos (produto_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

-- Definindo a restrição de chave estrangeira (FK) "produtos_pedidos_itens_fk" na tabela "pedidos_itens" para referenciar a chave primária (PK) "produto_id" da tabela "produtos".
ALTER TABLE pedidos_itens ADD CONSTRAINT produtos_pedidos_itens_fk
FOREIGN KEY (produto_id)
REFERENCES produtos (produto_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

-- Definindo a restrição de chave estrangeira (FK) "lojas_envios_fk" na tabela "envios" para referenciar a chave primária (PK) "loja_id" da tabela "lojas".
ALTER TABLE envios ADD CONSTRAINT lojas_envios_fk
FOREIGN KEY (loja_id)
REFERENCES lojas (loja_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

-- Definindo a restrição de chave estrangeira (FK) "lojas_estoques_fk" na tabela "estoques" para referenciar a chave primária (PK) "loja_id" da tabela "lojas".
ALTER TABLE estoques ADD CONSTRAINT lojas_estoques_fk
FOREIGN KEY (loja_id)
REFERENCES lojas (loja_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

-- Definindo a restrição de chave estrangeira (FK) "lojas_pedidos_fk" na tabela "pedidos" para referenciar a chave primária (PK) "loja_id" da tabela "lojas".
ALTER TABLE pedidos ADD CONSTRAINT lojas_pedidos_fk
FOREIGN KEY (loja_id)
REFERENCES lojas (loja_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

-- Definindo a restrição de chave estrangeira (FK) "clientes_envios_fk" na tabela "envios" para referenciar a chave primária (PK) "cliente_Id" da tabela "clientes".
ALTER TABLE envios ADD CONSTRAINT clientes_envios_fk
FOREIGN KEY (cliente_Id)
REFERENCES clientes (cliente_Id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

-- Definindo a restrição de chave estrangeira (FK) "clientes_pedidos_fk" na tabela "pedidos" para referenciar a chave primária (PK) "cliente_Id" da tabela "clientes".
ALTER TABLE pedidos ADD CONSTRAINT clientes_pedidos_fk
FOREIGN KEY (cliente_Id)
REFERENCES clientes (cliente_Id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

-- Definindo a restrição de chave estrangeira (FK) "pedidos_pedidos_itens_fk" na tabela "pedidos_itens" para referenciar a chave primária (PK) "pedido_id" da tabela "pedidos".
ALTER TABLE pedidos_itens ADD CONSTRAINT pedidos_pedidos_itens_fk
FOREIGN KEY (pedido_id)
REFERENCES pedidos (pedido_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

-- Definindo a restrição de chave estrangeira (FK) "envios_pedidos_itens_fk" na tabela "pedidos_itens" para referenciar a chave primária (PK) "envio_id" da tabela "envios".
ALTER TABLE pedidos_itens ADD CONSTRAINT envios_pedidos_itens_fk
FOREIGN KEY (envio_id)
REFERENCES envios (envio_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;
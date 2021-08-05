begin
    for r in (select 'drop table ' || table_name || ' cascade constraints' cmd from user_tables order by table_name)
        loop
            execute immediate (r.cmd);
        end loop;
end;
/

CREATE TABLE cliente
(
    id       int
        constraint pkCliente primary key,
    nome     varchar(20)        not null,
    telefone varchar(20),
    morada   varchar(200),
    estado   varchar(10)        not null
        constraint ckEstado check (estado LIKE 'activo' OR estado LIKE 'suspenso'),
    nif      varchar(12) unique not null
);

CREATE TABLE produto
(
    id               int
        constraint pkProduto primary key,
    nome             varchar(200)   not null,
    notas            varchar(200),
    preco_referencia decimal(15, 3) not null,
    iva              decimal(15, 3) not null,
    tipo             varchar(10)    not null
        constraint ckTipo check (tipo LIKE 'entrada' OR tipo LIKE 'sopa' OR tipo LIKE 'prato' OR tipo LIKE 'bebida' OR
                                 tipo LIKE 'sobremesa')
);

CREATE TABLE encomenda
(
    dia             date           not null,
    contador_diario int            not null,
    id_cliente      int,
    hora_encomenda  timestamp      not null,
    hora_entrega    timestamp,
    custo_total     decimal(15, 3),
    iva_total       decimal(15, 3),
    constraint ck_horas check (hora_entrega > hora_encomenda),
    constraint pkEncomenda primary key (dia, contador_diario)
);

CREATE TABLE menu_do_dia
(
    dia                  date not null,
    id_produto           int,
    unidades_disponiveis int  not null,
    constraint pkMenu_do_dia primary key (dia, id_produto)
);

CREATE TABLE ingrediente
(
    id      int
        constraint pkIngrediente primary key,
    nome    varchar(200) not null,
    unidade varchar(10)  not null,
    constraint ckUnidade check (unidade LIKE 'kg' OR unidade LIKE 'g' OR unidade LIKE 'unidade' OR
                                unidade LIKE 'litro')
);

CREATE TABLE ingrediente_de_prato
(
    id_produto     int,
    id_ingrediente int,
    quantidade     decimal(15, 3) not null,
    notas          varchar(200),
    constraint pkIngrediente_de_prato primary key (id_produto, id_ingrediente)
);


CREATE TABLE linha_encomenda
(
    dia_encomenda             date           not null,
    contador_diario_encomenda int            not null,
    id_produto                int,
    quantidade                int            not null,
    preco                     decimal(15, 3) not null,
    iva                       decimal(15, 3) not null,
    constraint pkLinha_encomenda primary key (dia_encomenda, contador_diario_encomenda, id_produto)
);

CREATE TABLE tipo_imagem
(
    id       varchar(5)
        constraint pkTipo_imagem primary key,
    descicao varchar(300),
    notas    varchar(200)
);

CREATE TABLE foto
(
    id             int
        constraint pkFoto primary key,
    id_produto     int,
    id_tipo_imagem varchar(5),
    path           varchar(300),
    notas          varchar(200)
);



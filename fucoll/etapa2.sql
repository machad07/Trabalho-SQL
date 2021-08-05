-- 1. clientes
insert into cliente(id,nome,telefone,morada,estado,nif) values(1,'Rui Silva','251231452', 'Av. de Madrid Lote 45, 3ºB','activo','123456789102');
insert into cliente(id,nome,morada,estado,nif) values(2,'Joana Sousa','R Camões 19','activo','232140023243');
insert into cliente(id,nome,estado,nif) values(3,'Marcos Jevees','activo','436652475234');
insert into cliente(id,nome,telefone,estado,nif) values(4,'Antonio Barbosa','229550069','activo','110513278000');
insert into cliente(id,nome,telefone,morada,estado,nif) values(5,'Mariana Santos','284433583  ', 'Praceta Maria Lamas 83','activo','656703635752');
insert into cliente(id,nome,telefone,morada,estado,nif) values(6,'Matilde Costa','245771016  ', 'R Doutor Manuel Faria 81','activo','023096558899');
insert into cliente(id,nome,estado,nif) values(7,'João Passos','activo','778851432708');
insert into cliente(id,nome,telefone,morada,estado,nif) values(8,'Margarida Leme','299789766 ', 'R Gago Coutinho 31','activo','049124883602');
insert into cliente(id,nome,telefone,morada,estado,nif) values(9,'Fernando Viana','213987356 ', 'Av. de Madrid Lote 45, 4ºB','activo','685076626054');
insert into cliente(id,nome,telefone,morada,estado,nif) values(10,'Leonor Ramos','291742711 ', 'Av. de Madrid Lote 45, 1ºB','activo','844143286880');

-- 2. produtos
insert into produto(id,nome,preco_referencia,iva,tipo) values (1,'pão',2,0.46,'entrada');
insert into produto(id,nome,preco_referencia,iva,tipo) values (2,'rissois',2.5,0.575,'entrada');
insert into produto(id,nome,preco_referencia,iva,tipo) values (3,'sopa de legumes',2.5,0.575,'sopa');
insert into produto(id,nome,preco_referencia,iva,tipo) values (4,'sopa de cenoura',2.5,0.575,'sopa');
insert into produto(id,nome,preco_referencia,iva,tipo) values (5,'Francesinha',10,2.3,'prato');
insert into produto(id,nome,notas,preco_referencia,iva,tipo) values (6,'Bifes de seitan','Opção vegetariana',9.5,2.185,'prato');
insert into produto(id,nome,notas,preco_referencia,iva,tipo) values (7,'Mula velha Reserva','Vinho tinto - Reserva 2018',2.5,0.575,'bebida');
insert into produto(id,nome,notas,preco_referencia,iva,tipo) values (8,'Fino','Super Bock',1.25,0.287,'bebida');
insert into produto(id,nome,notas,preco_referencia,iva,tipo) values (9,'Mousse de manga','Gluten free',2.5,0.575,'sobremesa');
insert into produto(id,nome,notas,preco_referencia,iva,tipo) values (10,'Cheesecake','Gluten free',2.5,0.575,'sobremesa');


-- 3. ingredientes
insert into ingrediente(id,nome,unidade) values (1,'Cenoura','unidade');
insert into ingrediente(id,nome,unidade) values (2,'Bife de vitela','g');
insert into ingrediente(id,nome,unidade) values (3,'Pão','unidade');
insert into ingrediente(id,nome,unidade) values (4,'Seitan','g');
insert into ingrediente(id,nome,unidade) values (5,'Cogumelos','g');
insert into ingrediente(id,nome,unidade) values (6,'Polpa de manga','litro');
insert into ingrediente(id,nome,unidade) values (7,'Gelatina','unidade');
insert into ingrediente(id,nome,unidade) values (8,'Legumes','kg');
insert into ingrediente(id,nome,unidade) values (9,'Manteiga','kg');
insert into ingrediente(id,nome,unidade) values (10,'Leite','litro');


-- 4. tipos de imagens
insert into tipo_imagem(id,descicao) values (1,'jpeg');
insert into tipo_imagem(id,descicao,notas) values (2,'png','Portable Network Graphics');
insert into tipo_imagem(id,descicao,notas) values (3,'bmp','Formato de imagem em mapa de bits');
insert into tipo_imagem(id,descicao) values (4,'gif');

-- 5. cosulta das tabelas anteriores
select * from cliente;
select * from produto;
select * from ingrediente;
select * from tipo_imagem;


-- 6. nifs repetidos
select * from cliente where nif in (
    select nif from cliente
    group by nif having count(*) > 1
)
/


-- 7. alterar morada
declare
  v_label varchar(50) := '%Av. de Madrid Lote 45%';
begin
  for r in (select id from cliente a where morada LIKE v_label) loop
      update cliente set morada = replace(morada,' Lote 45', ', nº14') where id = r.ID;
    end loop;
end;
/
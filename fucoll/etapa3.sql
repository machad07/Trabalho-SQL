-- 8. alterar tabelas para adicionar relações
alter table encomenda
    add constraint fkEncomenda_ID_Cliente foreign key (id_cliente) references cliente (id);
--alter table encomenda add constraint fkEncomenda_Dia foreign key(dia,null) references menu_do_dia(dia,id_produto);

alter table linha_encomenda
    add constraint fkLinha_encomenda foreign key (dia_encomenda, contador_diario_encomenda) references encomenda (dia, contador_diario);
alter table linha_encomenda
    add constraint fkLinha_encomenda_Menu foreign key (dia_encomenda, id_produto) references menu_do_dia (dia, id_produto);
alter table linha_encomenda
    add constraint fkID_produto_Produto foreign key (id_produto) references produto (id);

alter table menu_do_dia
    add constraint fkID_produto_Menu_do_Dia foreign key (id_produto) references produto (id);

alter table ingrediente_de_prato
    add constraint fkID_produto_Ingrediente_Prato foreign key (id_produto) references produto (id);
alter table ingrediente_de_prato
    add constraint fkIngrediente foreign key (id_ingrediente) references ingrediente (id);

alter table foto
    add constraint fkID_produto_Foto foreign key (id_produto) references produto (id);
alter table foto
    add constraint fktipo_imagem foreign key (id_tipo_imagem) references tipo_imagem (id);

-- 9. menus do dia
insert into menu_do_dia(dia, id_produto, unidades_disponiveis)
values (to_date('19/07', 'DD/MM'), 1, 3);
insert into menu_do_dia(dia, id_produto, unidades_disponiveis)
values (to_date('19/07', 'DD/MM'), 5, 10);
insert into menu_do_dia(dia, id_produto, unidades_disponiveis)
values (to_date('19/07', 'DD/MM'), 7, 14);
insert into menu_do_dia(dia, id_produto, unidades_disponiveis)
values (to_date('19/07', 'DD/MM'), 9, 7);

insert into menu_do_dia(dia, id_produto, unidades_disponiveis)
values (to_date('20/07', 'DD/MM'), 2, 3);
insert into menu_do_dia(dia, id_produto, unidades_disponiveis)
values (to_date('20/07', 'DD/MM'), 6, 10);
insert into menu_do_dia(dia, id_produto, unidades_disponiveis)
values (to_date('20/07', 'DD/MM'), 8, 14);
insert into menu_do_dia(dia, id_produto, unidades_disponiveis)
values (to_date('20/07', 'DD/MM'), 10, 7);

-- 10. encomendas

create or replace procedure prcEncomendar(cliente_id in int, data in date, produto1_id in int, p1_quantidade in int,
                                          produto2_id in int, p2_quantidade in int)
    is
    iva_linha_encomenda   decimal(15, 3);
    v_iva_total           decimal(15, 3);
    preco_linha_encomenda decimal(15, 3);
    v_preco_total         decimal(15, 3);
    valor_count_diario    int;
    v_data_encomenda      date;
    v_hora_encomenda      date;
    verifica_1            int;
    verifica_2            int;
    ex_encomenda exception;

begin
    v_data_encomenda := data;
    v_hora_encomenda := CURRENT_TIMESTAMP;
    select unidades_disponiveis into verifica_1 from menu_do_dia where id_produto = produto1_id and dia = data;
    select unidades_disponiveis into verifica_2 from menu_do_dia where id_produto = produto2_id and dia = data;

    if verifica_1 >= p1_quantidade AND verifica_2 >= p2_quantidade then

        select max(contador_diario) into valor_count_diario from encomenda where dia = data;
        if valor_count_diario is null then
            valor_count_diario := 1;
        else
            valor_count_diario := valor_count_diario + 1;
        end if;
        select preco_referencia into preco_linha_encomenda from produto where id = produto1_id;
        select iva into iva_linha_encomenda from produto where id = produto1_id;

        preco_linha_encomenda := preco_linha_encomenda * p1_quantidade;
        iva_linha_encomenda := iva_linha_encomenda * p1_quantidade;

        insert into encomenda(dia, contador_diario, id_cliente, hora_encomenda)
        values (v_data_encomenda, valor_count_diario, cliente_id, v_hora_encomenda);

        --dbms_output.put_line('encomenda: ' || v_data_encomenda || ' c:' || valor_count_diario|| ' ' || cliente_id|| ' ' || v_hora_encomenda);
        --dbms_output.put_line('linha_encomenda: ' || v_data_encomenda || ' c:' || valor_count_diario|| ' ' || produto1_id|| ' ' || p1_quantidade|| ' ' || preco_linha_encomenda|| ' ' || iva_linha_encomenda);
        insert into linha_encomenda
        values (v_data_encomenda, valor_count_diario, produto1_id, p1_quantidade, preco_linha_encomenda,
                iva_linha_encomenda);

        update menu_do_dia
        set unidades_disponiveis = unidades_disponiveis - p1_quantidade
        where id_produto = produto1_id
          and dia = data;

        v_preco_total := preco_linha_encomenda;
        v_iva_total := iva_linha_encomenda;

        preco_linha_encomenda := 0;
        iva_linha_encomenda := 0;
        select preco_referencia into preco_linha_encomenda from produto where id = produto2_id;
        select iva into iva_linha_encomenda from produto where id = produto2_id;

        preco_linha_encomenda := preco_linha_encomenda * p1_quantidade;
        iva_linha_encomenda := iva_linha_encomenda * p1_quantidade;

        insert into linha_encomenda
        values (v_data_encomenda, valor_count_diario, produto2_id, p2_quantidade, preco_linha_encomenda,
                iva_linha_encomenda);

        update menu_do_dia
        set unidades_disponiveis = unidades_disponiveis - p2_quantidade
        where id_produto = produto2_id
          and dia = data;

        v_preco_total := v_preco_total + preco_linha_encomenda;
        v_iva_total := v_iva_total + iva_linha_encomenda;

        update encomenda
        set custo_total = v_preco_total,
            iva_total   = v_iva_total
        where contador_diario = valor_count_diario
          and dia = data;

    else
        raise ex_encomenda;
    end if;


EXCEPTION
    when ex_encomenda then
        raise_application_error(-20103, 'Impossivel fazer incomenda: sem stock');

end prcEncomendar;
/

begin
    prcEncomendar(1, to_date('19/07', 'DD/MM'), 1, 1, 5, 2);
    prcEncomendar(1, to_date('19/07', 'DD/MM'), 9, 3, 7, 4);

    prcEncomendar(2, to_date('19/07', 'DD/MM'), 1, 1, 7, 3);
    prcEncomendar(2, to_date('20/07', 'DD/MM'), 10, 2, 6, 2);

    prcEncomendar(3, to_date('19/07', 'DD/MM'), 5, 1, 7, 3);
    prcEncomendar(3, to_date('20/07', 'DD/MM'), 10, 2, 6, 2);

    prcEncomendar(4, to_date('20/07', 'DD/MM'), 2, 1, 8, 3);
    prcEncomendar(4, to_date('19/07', 'DD/MM'), 7, 1, 5, 2);

    prcEncomendar(5, to_date('20/07', 'DD/MM'), 6, 3, 10, 3);
    prcEncomendar(5, to_date('19/07', 'DD/MM'), 5, 1, 7, 2);


end;
/

-- 12. cada produto tem pelo menos dois ingredientes

--ingredientes do pão
insert into ingrediente_de_prato(id_produto, id_ingrediente, quantidade)
values (1, 3, 5);
insert into ingrediente_de_prato(id_produto, id_ingrediente, quantidade)
values (1, 9, 0.25);

--ingredientes dos rissois
insert into ingrediente(id, nome, unidade)
values (11, 'Camarão', 'kg');
insert into ingrediente_de_prato(id_produto, id_ingrediente, quantidade)
values (2, 11, 3);
insert into ingrediente_de_prato(id_produto, id_ingrediente, quantidade)
values (2, 9, 0.25);

--ingredientes da sopa de legumes
insert into ingrediente_de_prato(id_produto, id_ingrediente, quantidade)
values (3, 8, 0.75);
insert into ingrediente_de_prato(id_produto, id_ingrediente, quantidade)
values (3, 9, 0.25);

--ingredientes da sopa de cenoura
insert into ingrediente_de_prato(id_produto, id_ingrediente, quantidade)
values (4, 1, 3);
insert into ingrediente_de_prato(id_produto, id_ingrediente, quantidade)
values (4, 9, 0.25);

--ingredientes da francesinha
insert into ingrediente_de_prato(id_produto, id_ingrediente, quantidade)
values (5, 3, 2);
insert into ingrediente_de_prato(id_produto, id_ingrediente, quantidade)
values (5, 2, 500);

--ingredientes dos bifes de seitan
insert into ingrediente_de_prato(id_produto, id_ingrediente, quantidade)
values (6, 5, 250);
insert into ingrediente_de_prato(id_produto, id_ingrediente, quantidade)
values (6, 4, 500);

--ingredientes do vinho tinto
insert into ingrediente(id, nome, unidade)
values (12, 'Mula velha Reserva', 'litro');
insert into ingrediente_de_prato(id_produto, id_ingrediente, quantidade)
values (7, 12, 0.25);
insert into ingrediente_de_prato(id_produto, id_ingrediente, quantidade)
values (7, 10, 0.25);

--ingredientes do fino
insert into ingrediente(id, nome, unidade)
values (13, 'Cerveja Super Bock', 'litro');
insert into ingrediente_de_prato(id_produto, id_ingrediente, quantidade)
values (8, 13, 0.25);
insert into ingrediente_de_prato(id_produto, id_ingrediente, quantidade)
values (8, 10, 0.25);

--ingredientes da mousse de manga
insert into ingrediente_de_prato(id_produto, id_ingrediente, quantidade)
values (9, 6, 0.5);
insert into ingrediente_de_prato(id_produto, id_ingrediente, quantidade)
values (9, 7, 6);

--ingredientes do cheesecake
insert into ingrediente_de_prato(id_produto, id_ingrediente, quantidade)
values (10, 7, 6);
insert into ingrediente_de_prato(id_produto, id_ingrediente, quantidade)
values (10, 10, 1.5);


-- 13. cada produto tem uma foto
insert into foto
values (1, 1, 1, 'C:\Users\pao.jpeg', 'Foto de pão');
insert into foto
values (2, 2, 1, 'C:\Users\rissois.jpeg', 'Foto de rissois');
insert into foto
values (3, 3, 2, 'C:\Users\sopaLeg.png', 'Foto de sopa de legumes');
insert into foto
values (4, 4, 2, 'C:\Users\sopaCen.png', 'Foto de cenoura');
insert into foto
values (5, 5, 3, 'C:\Users\francesinha.bmp', 'Foto de francesinha');
insert into foto
values (6, 6, 3, 'C:\Users\bifesSeitan.bmp', 'Foto de bifes de seitan');
insert into foto
values (7, 7, 4, 'C:\Users\mulaVelha.gif', 'Foto de mula velha reserva');
insert into foto
values (8, 8, 4, 'C:\Users\fino.gif', 'Foto de fino');
insert into foto
values (9, 9, 1, 'C:\Users\mousseManga.jpeg', 'Foto de mousse de manga');
insert into foto
values (10, 10, 1, 'C:\Users\cheesecake.jpeg', 'Foto de cheesecake');

-- 14. clientes e o numero de encomendas feitas
select c.nome, c.nif, count(e.id_cliente) as "Nº Encomendas"
from cliente c
         inner join encomenda e on c.id = e.id_cliente
group by c.nome,
         c.nif
order by c.nome,
         c.nif
;

-- 15. clientes que não fizeram encomendas
select *
from cliente
where id not in (
    select id_cliente
    from encomenda
    group by id_cliente
    having count(*) > 1
);

-- 16. encomendas feitas no mês de julho
select *
from encomenda
where extract(month from dia) = 7;

-- 17. custo das encomendas feitas no mes de julho
select dia, contador_diario, sum(custo_total + iva_total) as "Custo da encomenda"
from encomenda
where extract(month from dia) = 7
group by dia, contador_diario;

-- 18. gasto dos clientes no mes de julho
select c.id, c.nome, sum(e.custo_total + e.iva_total) as "Gasto no mês de Julho"
from cliente c
         inner join encomenda e on c.id = e.id_cliente
where extract(month from (dia)) = 7
group by c.id,
         c.nome
order by c.id,
         c.nome
;

-- 19. Quantidade consumida de cada ingrediente no mês de julho
select distinct i.nome, sum(ip.quantidade) as "Quantidade consumida", i.unidade
from linha_encomenda le
         inner join produto p on le.id_produto = p.id
         inner join ingrediente_de_prato ip on ip.id_produto = p.id
         inner join ingrediente i on ip.id_ingrediente = i.id
group by i.nome,
         i.unidade;
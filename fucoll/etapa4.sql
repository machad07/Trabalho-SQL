create or replace procedure prcAtualizarTotalEncomendas(mes in int, ano in int)
    is
    v_iva_total   decimal(15, 3);
    v_preco_total decimal(15, 3);
    check_empty   boolean;
    ex_mes_invalido exception;
    ex_ano_invalido exception;
    ex_dados_insuficientes exception;

begin
    if mes not between 1 and 12 then
        raise ex_mes_invalido;
    end if;

    if ano < 0 then
        raise ex_ano_invalido;
    end if;


    check_empty := true;
    For r in (select dia, contador_diario
              from encomenda
              where extract(month from dia) = mes
                and extract(year from dia) = ano)
        LOOP

            select sum(preco)
            into v_preco_total
            from linha_encomenda
            where dia_encomenda = r.dia
              and contador_diario_encomenda = r.contador_diario;

            select sum(iva)
            into v_iva_total
            from linha_encomenda
            where dia_encomenda = r.dia
              and contador_diario_encomenda = r.contador_diario;

            update encomenda
            set custo_total = v_preco_total,
                iva_total   = v_iva_total
            where dia = r.dia
              and contador_diario = r.contador_diario;

            check_empty := false;
        end loop;

    if check_empty then
        raise ex_dados_insuficientes;
    end if;

EXCEPTION
    when ex_dados_insuficientes then
        raise_application_error(-20110, 'Não existem dados');
    when ex_mes_invalido then
        raise_application_error(-20111, 'Mês invalido');
    when ex_ano_invalido then
        raise_application_error(-20112, 'Ano invalido');

end prcAtualizarTotalEncomendas;
/

begin
    prcAtualizarTotalEncomendas(7, 2021);
end;
/


CREATE OR REPLACE TRIGGER trgEstado_Cliente
    BEFORE
        INSERT OR UPDATE
    ON cliente
    FOR EACH ROW

declare
    validation boolean;
    ex_valor_invalido exception;

begin
    validation := true;
    if :new.estado like 'activo' or :new.estado like 'suspenso' then
        validation := false;
    end if;

    if validation then
        raise ex_valor_invalido;
    end if;

EXCEPTION
    when ex_valor_invalido then
        raise_application_error(-20101, 'Valor do estado não é válido');

end trgEstado_Cliente;
/

CREATE OR REPLACE TRIGGER trgTipo_Produto
    BEFORE
        INSERT OR UPDATE
    ON produto
    FOR EACH ROW

declare
    validation boolean;
    ex_valor_invalido exception;

begin
    validation := true;

    if :new.tipo LIKE 'entrada' OR :new.tipo LIKE 'sopa' OR :new.tipo LIKE 'prato' OR :new.tipo LIKE 'bebida' OR
       :new.tipo LIKE 'sobremesa' then
        validation := false;
    end if;

    if validation then
        raise ex_valor_invalido;
    end if;

EXCEPTION
    when ex_valor_invalido then
        raise_application_error(-20102, 'Valor do tipo não é válido');

end trgTipo_Produto;
/

CREATE OR REPLACE TRIGGER trgHora_Entrega_Encomenda
    BEFORE
        INSERT OR UPDATE
    ON encomenda
    FOR EACH ROW

declare
    ex_valor_invalido exception;

begin

    if :new.hora_entrega < :old.hora_encomenda then
        raise ex_valor_invalido;
    end if;

EXCEPTION
    when ex_valor_invalido then
        raise_application_error(-20103, 'Hora de entrega não é válida');

end trgHora_Entrega_Encomenda;
/

CREATE OR REPLACE TRIGGER trgUnidade_Ingrediente
    BEFORE
        INSERT OR UPDATE
    ON ingrediente
    FOR EACH ROW

declare
    validation boolean;
    ex_valor_invalido exception;

begin
    validation := true;

    if :new.unidade LIKE 'kg' OR :new.unidade LIKE 'g' OR :new.unidade LIKE 'unidade' OR
       :new.unidade LIKE 'litro' then
        validation := false;
    end if;

    if validation then
        raise ex_valor_invalido;
    end if;

EXCEPTION
    when ex_valor_invalido then
        raise_application_error(-20104, 'Valor da unidade não é válido');

end trgUnidade_Ingrediente;
/



ALTER TABLE cliente
    DROP CONSTRAINT ckEstado;

insert into cliente(id, nome, telefone, morada, estado, nif)
values (20, 'Rui Silva', '309686952', 'Av. de Madrid Lote 45, 3ºB', 'estado', '739379585529');



ALTER TABLE encomenda
    DROP CONSTRAINT ck_horas;

update encomenda
set hora_entrega = to_date('10/07', 'DD/MM')
where dia = to_date('19/07', 'DD/MM') and contador_diario = 1;


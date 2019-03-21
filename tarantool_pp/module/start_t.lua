local stringx = require 'pl.stringx'

local start_t = {}

    start_t.pay = [[CREATE TABLE IF NOT EXISTS pay (
        docNo varchar(45),
        docDate varchar(45),
        sum varchar(45),
        payer_name varchar(100),
        payer_inn varchar(45),
        payer_kpp varchar(45),
        payer_account varchar(45),
        payer_bank_bic varchar(45),
        payer_bank_name varchar(100),
        payer_bank_city varchar(45),
        payer_bank_correspAcc varchar(45),
        payee_name varchar(100),
        payee_inn varchar(45),
        payee_kpp varchar(45),
        payee_account varchar(45),
        payee_bank_bic varchar(45),
        payee_bank_name varchar(100),
        payee_bank_city varchar(100),
        payee_bank_correspAcc varchar(45),
        paymentKind varchar(100),
        transitionKind varchar(100),
        priority varchar(100),
        code varchar(45),
        purpose varchar(300),
        payid varchar(45) primary key,
        excid varchar(45),
        status varchar(100),
        
        is_budget varchar(1),
        b_kbk varchar(25),
        b_DrawerStatus varchar(30),
        b_reason varchar(15),
        b_oktmo varchar(15),
        b_TaxPeriod varchar(30),
        b_DocNo varchar(30),
        b_DocDate varchar(30),
        b_PayType varchar(30));]]

    start_t.bic = function()
        box.sql.execute( [[CREATE TABLE IF NOT EXISTS bic (
            bic varchar(10) PRIMARY KEY,
            name varchar(100));]] )

        for line in io.lines( '/home/kukuzapa/work/tar_front/catalog/bic.csv' ) do 
            local split = stringx.split( line, ';' )
            box.sql.execute( [[INSERT INTO bic (bic,name) VALUES (']] .. split[1] .. [[', ']] .. split[2] .. [[');]] )
        end
    end

    start_t.kbk = function()
        box.sql.execute( [[CREATE TABLE IF NOT EXISTS kbk_admn (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            kbk varchar(3),
            name varchar(200),
            ppo VARCHAR(30));]] )

        for line in io.lines( '/home/kukuzapa/work/tar_front/catalog/kbk_admn.csv' ) do 
            local split = stringx.split( line, ';' )
            box.sql.execute( [[INSERT INTO kbk_admn (kbk,name,ppo) VALUES (']] .. split[1] .. [[', ']] .. split[2] .. [[', ']] .. split[3] .. [[');]] )
        end
        
        
        box.sql.execute( [[CREATE TABLE IF NOT EXISTS kbk_code (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            kbk varchar(25),
            name varchar(200),
            ppo VARCHAR(30),
            status VARCHAR(15));]] )

        for line in io.lines( '/home/kukuzapa/work/tar_front/catalog/kbk_code.csv' ) do 
            local split = stringx.split( line, ';' )
            box.sql.execute( [[INSERT INTO kbk_code (kbk,name,ppo,status) VALUES (']] .. split[1] .. [[', ']] .. split[2] .. [[',
                ']] .. split[3] .. [[', ']] .. split[4] .. [[');]] )
        end
    end

    start_t.oktmo = function()
        box.sql.execute( [[CREATE TABLE IF NOT EXISTS oktmo (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            oktmo VARCHAR(11));]] )

        for line in io.lines( '/home/kukuzapa/work/tar_front/catalog/oktmo.csv' ) do 
            --print( line )
        
            local split = stringx.split( line, ';' )
        
            if string.len( stringx.split( split[10] )[1] ) == 11 then
                --table.insert( fin, stringx.split( split[10] )[1] )
                box.sql.execute( [[INSERT INTO oktmo (oktmo) VALUES (']] .. stringx.split( split[10] )[1] .. [[');]] )
            end
        end
    end

return start_t
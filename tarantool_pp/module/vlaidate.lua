local inspect = require 'inspect'

local stringx = require 'pl.stringx'

local tablex = require 'pl.tablex'

--sum
local function v_sum( tbl, col )

    local str = tbl[col]

    --print( str )

    if not tonumber( str ) then
        --print('JJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJ')

    	return false
    end

    return true
end

--Вид операции
local function v_transitionkind( tbl, col )

    local str = tbl[col]

    if str == '01' or str == '02' or str == '06' or str == '16' then
        return true
    else
        return false
    end
end

--РС валидация
local function v_rs( tbl, col )

    local split = stringx.split( col, '_' )[1]

    local rs  = tbl[split .. '_ACCOUNT']

    local bic = tbl[split .. '_BANK_BIC']

    if not tonumber( rs ) then
    	return false
    end
     
    if string.len( rs ) ~= 20 then
	    return false
    end

    local tmp = string.sub(bic,7,7) .. string.sub(bic,8,8) .. string.sub(bic,9,9)

    if tmp == '000' or tmp == '001' then
        tmp = '0' .. string.sub(bic,5,5) .. string.sub(bic,6,6)
    end

    tmp = tmp .. rs

    local sum = 0

    local coef = { 7, 1, 3, 7, 1, 3, 7, 1, 3, 7, 1, 3, 7, 1, 3, 7, 1, 3, 7, 1, 3, 7, 1 }

    for i,v in pairs( coef ) do

        sum = sum + ( coef[i] * tonumber( string.sub(tmp,i,i)  )) % 10
    end

    if ( sum % 10 ) ~= 0 then
        return false
    end

    return true
end

--KS Validate
local function v_ks( tbl, col )

    local split = stringx.split( col, '_' )[1]

    local ks  = tbl[split .. '_BANK_CORRESPACC']

    local bic = tbl[split .. '_BANK_BIC']

    if not tonumber( ks ) then
    	return false
    end
     
    if string.len( ks ) ~= 20 then
	    return false
    end
    
    local tmp = '0' .. string.sub(bic,5,5) .. string.sub(bic,6,6) .. ks

    local sum = 0

    local coef = { 7, 1, 3, 7, 1, 3, 7, 1, 3, 7, 1, 3, 7, 1, 3, 7, 1, 3, 7, 1, 3, 7, 1 }

    for i,v in pairs( coef ) do

        sum = sum + ( coef[i] * tonumber( string.sub(tmp,i,i)  )) % 10
    end

    if ( sum % 10 ) ~= 0 then
        return false
    end

    return true
end

--BIC Validate
local function v_bic( tbl, col )

    local str = tbl[col]

    local sel = box.sql.execute( [[SELECT * FROM bic WHERE bic = ']] .. str .. [[';]] )

    if #sel == 0 then
        return false
    end

    return true
end

--DATE Validate
local function v_date( tbl, col )

    local str = tbl[col]

	if string.len( str ) ~= 10 then
		return false
	end

	local d,m,y = string.match( str, '(%d+).(%d+).(%d+)' )

	if d and m and y then
		
		local epoch = os.time( { year = y, month = m, day = d } )

		local zeromdy = string.format( "%02d.%02d.%04d", d, m, y )

		if zeromdy ~= os.date( '%d.%m.%Y', epoch ) then
			return false
		end
	else
		return false
	end

	return true
end

--DOCNO validate
local function v_docno( tbl, col )
    
    local docno = tbl[col]

    print( docno )

    if not tonumber( docno ) then
    	return false
    end
     
    if string.len( docno ) > 6 then
	    return false
    end

    return true
end

--INN Validate
local function v_inn( tbl, col )

    local str = tbl[col]

	if not tonumber( str ) then
    	return false
 	end

    if string.len( str ) ~= 12 and string.len( str ) ~= 10 then
        return false
    end

    if string.len( str ) == 10 then
        local k9 = { 2, 4, 10, 3, 5, 9, 4, 6, 8 }

        local s9 = 0

        for i,v in pairs( k9 ) do
            s9 = s9 + tonumber( string.sub(str,i,i) )*v
        end

        if ( s9 % 11 % 10 ) ~= tonumber( string.sub(str,10,10) ) then
            return false
        end
    end

    if string.len( str ) == 12 then
    	local k10 = { 7, 2, 4, 10, 3, 5, 9, 4, 6, 8 }
		local k11 = { 3, 7, 2, 4, 10, 3, 5, 9, 4, 6, 8 }

		local s10 = 0
		local s11 = 0

		for i,v in pairs( k10 ) do
            s10 = s10 + tonumber( string.sub(str,i,i) )*v
        end

        for i,v in pairs( k11 ) do
            s11 = s11 + tonumber( string.sub(str,i,i) )*v
        end 

        if ( s10 % 11 % 10 ) ~= tonumber( string.sub(str,11,11) ) then
            return false
        end

        if ( s11 % 11 % 10 ) ~= tonumber( string.sub(str,12,12) ) then
            return false
        end
    end

    return true
end

--budget kbk validate
local function v_b_kbk( tbl, col )

    local kbk = tbl[col]
    
    print( kbk )

    if not tonumber( kbk ) then
    	return false
    end
     
    if string.len( kbk ) < 20 then
	    return false
    end

    local admn = string.sub( kbk, 1, 3 )
    local code = string.sub( kbk, 4 )

    --print( [[
    --    SELECT * FROM kbk_code c
    --        INNER JOIN kbk_admn a ON c.ppo = a.ppo
    --        WHERE c.kbk = ']] .. code .. [['
    --        AND a.kbk = ']] .. admn .. [['
    --        AND c.status = 'Действующий';
    --]] )

    local sel = box.sql.execute( [[
        SELECT * FROM kbk_code c
            INNER JOIN kbk_admn a ON c.ppo = a.ppo
            WHERE c.kbk = ']] .. code .. [['
            AND a.kbk = ']] .. admn .. [['
            AND c.status = 'Действующий';
    ]] )

    --print( #sel )
    --print( inspect( sel ) )
    if #sel == 0 then
        return false
    end

    return true
end

--budget reason validate
local function v_b_reason( tbl, col )
    local reason = tbl[col]

    print( reason )

    local templ = { 'ТП', 'ЗД', 'ТР', 'РС', 'ОТ', 'РТ', 'ВУ', 'ПР', 'АП', 'АР', '0' }

    for i,v in pairs( templ ) do
        if reason == v then
            return true
        end
    end

    return false
end

--budget taxperiod
local function v_b_taxperiod( tbl, col )
    local taxperiod = tbl[col]

    local split = stringx.split( taxperiod, '.' )

    if #split ~= 3 then
        return false
    end

    if not tonumber( split[2] ) or not tonumber( split[3] ) then
    	return false
    end

    if string.len( split[2] ) ~= 2 or string.len( split[3] ) ~= 4 then
        return false
    end

    if tonumber( split[1] ) and string.len( split[1] ) == 2 then
        return true
    end

    local templ = {
        ['Д1'] = { '01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12' },
        ['Д2'] = { '01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12' },
        ['Д3'] = { '01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12' },
        ['МС'] = { '01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12' },
        ['КВ'] = { '01', '02', '03', '04' },
        ['ПЛ'] = { '01', '02' },
        ['ГД'] = { '00' }
    }

    if templ[split[1]] then
        if tablex.find( templ[split[1]], split[2] ) then
            return true
        else
            return false
        end
    end

    return false
end

--Статус налогоплательщика - валидация
local function v_b_drawerstatus( tbl, col )
    local drawerstatus = tbl[col]

    print( drawerstatus )

    local templ = { '01', '08', '09', '10', '11', '12', '13', '14', '15' }

    if tablex.find( templ, drawerstatus ) then
        return true
    else
        return false
    end

    --return true
end

--Тип платежа в бюджет
local function v_b_paytype( tbl, col )
    local paytype = tbl[col]

    local templ = { 'НС', 'АВ', 'ПЕ', 'СА', 'ВЗ', 'ГП', 'ПЛ', 'ПЦ', 'АШ', 'ИШ' }

    if tablex.find( templ, paytype ) then
        return true
    else
        return false
    end
end

--B_DOCNO
local function v_b_docno( tbl, col )

    local docno = tbl[col]

    local reason = tbl['B_REASON']

    if not tonumber( docno ) then
    	return false
    end

    print( '-----------------------------------' )
    print( 'b docno ', docno )
    print( 'b reason', reason )

    print( '-----------------------------------' )

    local templ = { 'ТР', 'РС', 'ОТ', 'РТ', 'ВУ', 'ПР', 'АП', 'АР' }

    if tablex.find( templ, reason ) then
        if docno == '0' then
            return false
        end
    else
        if docno ~= '0' then
            return false
        end
    end



    return true
end

--Validate budg docdate
local function v_b_docdate( tbl, col )
    local docdate = tbl[col]

    local split = stringx.split( docdate, '.' )

    if #split == 1 and split[1] == '0' then
        return true
    end
    
    if #split == 3 then
        if tonumber( split[1] ) < 1 or tonumber( split[1] ) > 31 then
            return false
        end

        if tonumber( split[2] ) < 1 or tonumber( split[2] ) > 12 then
            return false
        end
        
        if not tonumber( split[3] ) or string.len( split[3] ) ~= 4 then
            return false
        end
    else
        return false
    end

    return true
end

--validate oktmo
local function v_b_oktmo( tbl, col )
    local oktmo = tbl[col]

    if not tonumber( oktmo ) then
    	return false
    end

    if string.len( oktmo ) ~= 8 and string.len( oktmo ) ~= 11 then
        return false
    end

    if string.len( oktmo ) == 8 then
        oktmo = oktmo .. '000'
    end

    local sel = box.sql.execute( [[SELECT * FROM oktmo WHERE oktmo = ']] .. oktmo .. [[';]] )

    if #sel == 0 then
        return false
    end

    return true
end
----END----



local validate = {}

    

    validate['PAYER_INN']             = v_inn
    validate['PAYEE_INN']             = v_inn

    validate['DOCDATE']               = v_date

    validate['PAYER_BANK_BIC']        = v_bic
    validate['PAYEE_BANK_BIC']        = v_bic

    validate['PAYER_BANK_CORRESPACC'] = v_ks
    validate['PAYEE_BANK_CORRESPACC'] = v_ks

    validate['TRANSITIONKIND']        = v_transitionkind

    validate['SUM']                   = v_sum

    validate['PAYER_ACCOUNT']         = v_rs
    validate['PAYEE_ACCOUNT']         = v_rs

    validate['DOCNO']                 = v_docno

    validate['B_KBK']                 = v_b_kbk
    validate['B_REASON']              = v_b_reason
    validate['B_TAXPERIOD']           = v_b_taxperiod
    validate['B_DRAWERSTATUS']        = v_b_drawerstatus
    validate['B_PAYTYPE']             = v_b_paytype
    validate['B_DOCNO']               = v_b_docno
    validate['B_DOCDATE']             = v_b_docdate
    validate['B_OKTMO']               = v_b_oktmo
    
return validate
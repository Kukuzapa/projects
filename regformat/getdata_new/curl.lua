local curl    = require 'cURL'
local lfs     = require 'lfs'
local zzlib   = require 'module.zzlib'
local inspect = require 'inspect'
local tablex  = require 'pl.tablex'

--функция загрузки файла
local function curl_file_download( zone, url, file )
    
    curl.easy( {
        url     = 'https://getdata.tcinet.ru/' .. zone.tld .. '/' .. url,
        
        sslcert = lfs.currentdir() .. '/cert/clicert_' .. zone.name .. '.pem',
        sslkey  = lfs.currentdir() .. '/cert/clikey_' .. zone.name .. '.pem',

        writefunction = function( buf )
            file:write( buf )
        end 
    } ):perform():close()
end

--Сначала нам надо получить список файлов в наличии
local list = {}  --будущий список

--Список зон
local zones = { 
    {
        tld  = 'ru',
        name = 'ru'
    },
    {
        tld  = 'xn--p1ai',
        name = 'rf'
    }
}

--Примерные шаблоны файлов
local templ = { 'DomainDistrib', 'DomainList', 'Zone', 'DelList', 'DelReport', 'StopList' }


for _,zone in pairs( zones ) do


    local file = io.open( lfs.currentdir() .. '/files/' .. zone.name .. '/filelist.' .. zone.name, 'w+' )

    --Сохраняем в файл список файлов на сервере
    curl_file_download( zone, '', file )

    file:seek('set')

    --Идем по этому файлу и сохраняем названия файлов в лист
    for line in file:lines() do 

        local tmp = string.match( line, '".+"')

        if tmp then

            tmp = string.sub( tmp, 2, string.len( tmp ) -1 )

            for _,t in pairs( templ ) do
                if string.find( tmp, t ) then
                    list[t] = tmp
                end
            end
        end
    end 

    file:close()

    --Список ранее закаченных файлов
    local current_file_list = {}

    --Формируем его
    for file in lfs.dir( lfs.currentdir() .. '/files/' .. zone.name .. '/' ) do
        table.insert( current_file_list, file )
    end

    local delete_list = {}

    --Идем по списку новых файлов. Если этого названия нет в списке текущих, то закачиваем, а предыдущий добавляем в список на удаление
    for i,v in pairs( list ) do
        if not tablex.find( current_file_list, v ) then

            local file = io.open( lfs.currentdir() .. '/files/' .. zone.name .. '/' .. v, 'w+' )
            curl_file_download( zone, v, file )
            file:close()

            for _,u in pairs( current_file_list ) do
                if string.find( u, i ) then
                    table.insert( delete_list, u )
                end
            end
        end
    end

    --Удаляем старые
    for _,del in pairs( delete_list ) do
        os.remove( lfs.currentdir() .. '/files/' .. zone.name .. '/' .. del )
    end

    --Стоп лист обнавляется каждый час, поэтому его качаем всегда
    if list.StopList then
        local file = io.open( lfs.currentdir() .. '/files/' .. zone.name .. '/' .. list.StopList, 'w+' )
        curl_file_download( zone, list.StopList, file )
        file:close()
    end
end

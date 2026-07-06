-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=75398

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                               https://appliedmachinelearning.systems/contact/  | 
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal:  https://goo.gl/9Rj74e   |
--|                                                             Patreon :  http://tiny.cc/1ybwxz   |  
--|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   | 
--+------------------------------------------------------------------------------------------------+
function Init()
    strategy:name("Multi symbol logger");
    strategy:description("Logs rates into files");

    strategy.parameters:addGroup("Price Parameters");
    strategy.parameters:addString("instruments", "Instruments", "", "EUR/USD,USD/JPY");
    strategy.parameters:addString("TF", "TF", "Time frame", "m1");
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS);
    strategy.parameters:addString("path", "Path for files", "", core.app_path() .. "\\" .. "log");
end

local data = {};
function Prepare(nameOnly)
    local name = profile:id() .. "(" .. instance.bid:instrument() .. ")";
    instance:name(name);
    if nameOnly then
        return ;
    end
    local instruments, count = core.parseCsv(instance.parameters.instruments);
    for i = 1, count do
        data[i] = ExtSubscribe(i, instruments[i - 1], instance.parameters.TF, true, "bar");
    end
end

function ExtUpdate(id, source, period)
    local all_data_loaded;
    for i, instrument in ipairs(data) do
        if instrument ~= nil then
            if instrument:size() > 0 then
                flush(instrument);
                data[i] = nil;
                if all_data_loaded == nil then
                    all_data_loaded = true;
                end
            else
                all_data_loaded = false;
            end
        end
    end
    if all_data_loaded == true then
        terminal:alertMessage(instance.ask:instrument(), instance.bid[NOW], "All data saved", instance.bid:date(NOW));
    end
end

function flush(src)
    local f = io.open(instance.parameters.path .. "\\" .. string.gsub(src:instrument(), "/", "_") .. ".csv", "w");
    date_of_file_start = core.dateToTable(src:date(0));
    date_of_file_end = core.dateToTable(src:date(NOW));
    f:write(string.format("HDR;%s;%i.%i.%i %i:%i:%i;%i.%i.%i %i:%i:%i;%s;1;%f\n", 
        src:instrument(), date_of_file_start.day, date_of_file_start.month, date_of_file_start.year,
        date_of_file_start.hour, date_of_file_start.min, date_of_file_start.sec,
        date_of_file_end.day, date_of_file_end.month, date_of_file_end.year,
        date_of_file_end.hour, date_of_file_end.min, date_of_file_end.sec,
        src:barSize(), src:pipSize()));
    for i = 0, src:size() - 1 do
        local d = core.dateToTable(src:date(i));
        f:write(string.format("DAT;%i.%i.%i %i:%i:%i;%f;%f;%f;%f;;;;;%i;\n", 
            d.day, d.month, d.year, d.hour, d.min, d.sec,
            src.open[i], src.high[i], src.low[i], src.close[i],
            src.volume[i]));
    end
    f:close();
end

function ExtAsyncOperationFinished(cookie, success, message, message1, message2)
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");

--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal:  https://goo.gl/9Rj74e   |
--|                                                             Patreon :  http://tiny.cc/1ybwxz   |  
--|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   | 
--+------------------------------------------------------------------------------------------------+
--|  Cryptocurrency  |  Network                    |  Address                                      |
--+------------------------------------------------+-----------------------------------------------+
--|  USDT            |  ERC20 (ETH Ethereum)       |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
--|  USDT            |  TRC20 (Tron)               |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
--|  USDT            |  BEP20 (BSC BNB Smart Chain)|  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--|  USDT            |  Matic Polygon              |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--|  USDT            |  SOL Solana                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
--|  USDT            |  ARBITRUM Arbitrum One      |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--+------------------------------------------------+-----------------------------------------------+
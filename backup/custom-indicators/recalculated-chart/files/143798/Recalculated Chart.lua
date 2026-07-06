-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71533

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2021, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                              Support our efforts by donating   | 
--|                                                                 Paypal: https://goo.gl/9Rj74e  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |
--|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C                                 |
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |                                                  |   
--+------------------------------------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Recalculated Chart");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator:setTag("replaceSource", "t");    
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block 
local first;
local source = nil;
 

local  open=nil;
local  close=nil;
local  high=nil;
local  low=nil;

local pattern = "([^;]*);([^;]*)";
local db;

 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

 

	source = instance.source;
	first=source:first();
 
	require("storagedb");
    db = storagedb.get_db(name);	
	
    core.host:execute("addCommand", 1, "Select Level");
    core.host:execute("addCommand", 2, "Reset");
	
	open = instance:addStream("openup", core.Line, name, "", core.COLOR_LABEL , first);
    high = instance:addStream("highup", core.Line, name, "", core.COLOR_LABEL , first);
    low = instance:addStream("lowup", core.Line, name, "", core.COLOR_LABEL , first);
    close = instance:addStream("closeup", core.Line, name, "", core.COLOR_LABEL , first);
    instance:createCandleGroup("OVERLAY", "OVERLAY", open, high, low, close);
		
end

-- Indicator calculation routine
function Update(period, mode)


local Shift =  tonumber(db:get("Level" , 0));  

if period < first then
return;
end

	
    open[period] = source.open[period]-Shift;
	close[period] = source.close[period]-Shift;
	high[period] = source.high[period]-Shift;
	low[period] = source.low[period]-Shift;
 

		
 end


function AsyncOperationFinished(cookie, success, message)
 
	
	if cookie == 1 then
	Level, Date = string.match(message, pattern, 0);
	db:put("Level" , tostring(Level));  
	end
	
	if cookie == 2 then
	db:put("Level" , tostring(0));  
	end
end	
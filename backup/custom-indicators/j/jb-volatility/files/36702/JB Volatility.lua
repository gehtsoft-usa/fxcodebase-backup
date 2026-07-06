-- Id: 6991
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=20961

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("JB Volatility");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addInteger("CP", "Period", "", 20);
    indicator.parameters:addInteger("AP", "ATR Period", "", 10);
    indicator.parameters:addDouble("MP", "Multiplier", "", 2);

	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("High", "Higher Volatility", "", core.rgb(0, 0, 255));	
	indicator.parameters:addColor("Low", "Lower Volatility", "", core.rgb(255, 0, 0));	
	indicator.parameters:addColor("Neutral", "Neutral Color", "", core.rgb(128, 128, 128));	
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local open=nil;
local close=nil;
local high=nil;
local low=nil;

local CP, AP, MP;
local ATR;
-- Routine
function Prepare(nameOnly)
    Low = instance.parameters.Low;
    High = instance.parameters.High;
	Neutral = instance.parameters.Neutral;
	
	CP = instance.parameters.CP;
	AP = instance.parameters.AP;
	MP = instance.parameters.MP;
	
    source = instance.source;
	
    local name = profile:id() .. "(" .. source:name() .. ", "  .. CP .. ", " .. AP .. ", " .. MP .. ")";
    instance:name(name);
	if nameOnly then
		return;
	end
    ATR = core.indicators:create("ATR", source, AP);
    first = math.max( ATR.DATA:first(), CP );	
	
	open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first)
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first)
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first)
    instance:createCandleGroup("ZONE", "", open, high, low, close);
	
	
end

-- Indicator calculation routine
function Update(period, mode)
     
	if period < first   or not source:hasData(period) then
	open:setColor(period, Neutral);
    return;
    end 
 
    ATR:update(mode);
    
	
	high[period]= source.high[period];
	low[period]= source.low[period];		   
	close[period] = source.close[period];
	open[period]  = source.open[period];	
	
	
	local min, max;
	
	min, max =  mathex.minmax (source, period-CP +1, period);
				   
  
		

		        if  source.close[period] > min + MP*ATR.DATA[period] then
				open:setColor(period, High);
				elseif  source.close[period] < max  - MP*ATR.DATA[period] then
				open:setColor(period, Low);		
                else				
				open:setColor(period, Neutral); 
			    end 
		              
				   
				  
    end


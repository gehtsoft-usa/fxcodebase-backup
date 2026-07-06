
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2511

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |  
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Zero Lag");
    indicator:description("Zero Lag indicator from Futures & Commodities, Oct issue");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addInteger("N", "Lenth", "Inernal EMA length", 20);
    indicator.parameters:addInteger("GainLimit", "GainLimit", "Limit of gain term", 50);
	
	indicator.parameters:addGroup("Style Parameters");	
	indicator.parameters:addColor("ZL_UP", "Color of ZeroLag", "Color of ZeroLag", core.rgb(0, 255, 0));
	indicator.parameters:addColor("ZL_DN", "Color of ZeroLag", "Color of ZeroLag", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", " Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", " Line Style", " ", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
    
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local N;
local gainLimit;
 

local first;
local source = nil;

-- Streams block
local EMAI = nil;
local ZL = nil;
local DN;

local alpha

-- Routine
function Prepare(nameOnly) 
     
    N = instance.parameters.N;
    gainLimit = instance.parameters.GainLimit / 10;
    source = instance.source;
    
    local name = profile:id() .. "(" .. source:name() .. ", " .. N .. ", " .. instance.parameters.GainLimit .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
    
    EMAI = core.indicators:create("EMA", source, N  );

    first = EMAI.DATA:first() + 1; 

    alpha =  2.0 / (N + 1.0)
   
	
	ZL = instance:addStream("ZL", core.Line, name .. ".ZL", "ZL", instance.parameters.ZL_UP, first);
	ZL:setWidth(instance.parameters.width);
	ZL:setStyle(instance.parameters.style);
 
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    EMAI:update(mode);
    
    if period >= first and source:hasData(period) then
        local EMA = EMAI.DATA[period];

		local err = source[period] - ZL[period - 1]
		local gain = 0
        if math.abs(alpha * err) > 1e-9 then
          local diff = ZL[period - 1] - EMA
          gain = (err + alpha * diff) / (alpha * err)
        end
        -- Force gain to [-gainLimit; gainLimit] interval
        gain = math.max(math.min(gain, gainLimit), -gainLimit)
         
        -- Round gain to nearest value quanted by 0.1 interval
        if gain > 0 then
        	gain = math.floor(gain * 10 + 0.5) / 10;
        else
        	gain = math.ceil(gain * 10 - 0.5) / 10;
        end
        
        ZL[period] = alpha * (EMA + gain * err) + (1 - alpha) *  ZL[period - 1];	
		
		 
				 if ZL[period]< ZL[period-1] then	 
					ZL:setColor(period, instance.parameters.ZL_UP);
				 else	
					ZL:setColor(period, instance.parameters.ZL_DN);
				end	
		 	

    end
end
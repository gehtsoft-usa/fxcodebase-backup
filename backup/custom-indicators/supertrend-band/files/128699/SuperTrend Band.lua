-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=68919

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC | 
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
function Init()
    indicator:name("SuperTrend Band");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "Number of periods", "", 10);
    indicator.parameters:addDouble("M", "Multiplier", "", 1.5);
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color1", "Color of UP", "Color of UP", core.rgb(0, 255, 0));
    indicator.parameters:addColor("color2", "Color of DN", "Color of DN", core.rgb(255, 0, 0));
	 indicator.parameters:addInteger("width", "Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("style", "Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local N;
local M;

local first;
local source = nil;
local ATR = nil;

-- Streams block
 
local UP = nil;
local DN = nil;

local up, dn;

-- Routine
 function Prepare(nameOnly)   
    N = instance.parameters.N;
    M = instance.parameters.M;
    source = instance.source;
    
    local name = profile:id() .. "(" .. source:name() .. ", " .. N .. ", " .. M .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	ATR = core.indicators:create("ATR", source, N);
    first = ATR.DATA:first();
	
	
	up = instance:addInternalStream(0, 0);
	dn = instance:addInternalStream(0, 0);
	
    UP=instance:addStream("UP", core.Line, name .. ".UP", "UP", instance.parameters.color1, first);
   	UP:setWidth(instance.parameters.width);
    UP:setStyle(instance.parameters.style);
	UP:setPrecision(math.max(2, source:getPrecision()));
	
    DN=instance:addStream("DN", core.Line, name .. ".DN", "DN", instance.parameters.color2, first);
   	DN:setWidth(instance.parameters.width);
    DN:setStyle(instance.parameters.style);
	DN:setPrecision(math.max(2, source:getPrecision()));
	
end

-- Indicator calculation routine
function Update(period, mode)
    ATR:update(mode);
     
    if period < first then
	return;
	end
	
	
        local median, atr, change;
        atr = ATR.DATA[period];
        median = (source.high[period] + source.low[period]) / 2;
        up[period] = median - atr * M;
        dn[period] = median + atr * M;
		
		
     if source.close[period-1]> UP[period-1] then
	 UP[period]=math.max(up[period],UP[period-1]);
     else
	 UP[period]=up[period];
     end  	 
	 
	 
	 if source.close[period-1]< DN[period-1] then
	 DN[period]=math.min(dn[period],DN[period-1]);
     else
	 DN[period]=dn[period];
     end  	 
end
--[[
Up[i]=(H[i] + L[i] ) / 2 - (Factor*atr[i]) ;
Dn[i]=(H[i] + L[i] ) / 2 + (Factor*atr[i]) ;

TrendUp[i] = C[i-1] >TrendUp[i-1] ? Math.Max(Up[i],TrendUp[i-1]) : Up[i] ;
TrendDown[i]= C[i-1]<TrendDown[i-1]? Math.Min(Dn[i],TrendDown[i-1]) : Dn[i] ;
]]
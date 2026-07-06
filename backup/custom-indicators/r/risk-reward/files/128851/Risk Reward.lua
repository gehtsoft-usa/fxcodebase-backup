-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=68949

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

function Init()
    indicator:name("Risk Reward");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period", "Period", "", 20);
	indicator.parameters:addDouble("Deviations", "Deviations", "", 2);
    indicator.parameters:addInteger("ATR_Period", "ATR Period", "", 20);
	indicator.parameters:addDouble("ATR_Multiplier", "ATR_Multiplier", "", 4);
	
 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color1", "Long Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("color2", "Short Line Color", "", core.rgb(  255,0, 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
 
local first;
local source = nil;
local Indicator; 
local Long,Short;  
local  Period, Deviations;
local ATR_Period, ATR, ATR_Multiplier;
-- Routine
 function Prepare(nameOnly)   
 
 
    Period= instance.parameters.Period;
    Deviations= instance.parameters.Deviations;
	ATR_Period= instance.parameters.ATR_Period;
	ATR_Multiplier= instance.parameters.ATR_Multiplier;
	
	
	local Parameters= Period ..", "..Deviations..", "..ATR_Period..", "..ATR_Multiplier;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source; 
	
	Indicator = core.indicators:create("BB", source.close,   Period,  Deviations  );
	ATR = core.indicators:create("ATR", source ,  ATR_Period  );
    first=math.max(Indicator.DATA:first() ,ATR.DATA:first()); 
	
	
	Long = instance:addStream("Long" , core.Line, " Long"," Long",instance.parameters.color1, first );
	Long:setWidth(instance.parameters.width);
    Long:setStyle(instance.parameters.style);
    Long:setPrecision(math.max(2, source:getPrecision()));
	
	
	Short = instance:addStream("Short" , core.Line, " Short"," Short",instance.parameters.color2, first );
	Short:setWidth(instance.parameters.width);
    Short:setStyle(instance.parameters.style);
    Short:setPrecision(math.max(2, source:getPrecision()));
	
end

-- Indicator calculation routine
function Update(period, mode)

 
	if period < first 
	then
	return;
	end
	
	Indicator:update(mode);
	ATR:update(mode);
	
	
	local Stop = source.close[period-1] - (ATR_Multiplier * ATR.DATA[period]);
	Long[period]= (Indicator.TL[period]-source.high[period])/(source.high[period] -Stop);
	
	Stop = source.close[period-1] + (ATR_Multiplier * ATR.DATA[period]);
	Short[period]= math.abs((Indicator.BL[period]-source.low[period])/(Stop-source.low[period]));
				  
end
 
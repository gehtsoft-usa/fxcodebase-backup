-- Id: 9766
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59113

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
    indicator:name("Cutler's RSI");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
   
   
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("RP", "RSI Period", "", 14, 2, 1000);
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	indicator.parameters:addStringAlternative("Method", "DEMA", "DEMA" , "DEMA");
	indicator.parameters:addStringAlternative("Method", "TEMA", "TEMA" , "TEMA");
	indicator.parameters:addStringAlternative("Method", "PAR MA", "PAR MA" , "PAR_MA");
    
	 indicator.parameters:addGroup("Indicator Style");
	 indicator.parameters:addColor("RSI_color", "RSI color", "(RSI Color) Red", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("RSI_width", "RSI Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("RSI_style", "RSI Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("RSI_style", core.FLAG_LINE_STYLE);

	
	 indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 80);
    indicator.parameters:addDouble("oversold","Oversold Level","", 30);
     indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);

	

end
 
-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local first;
local source = nil;
local Method;
local Method, RP ;
local RSI ;
local pos, neg;
local Positiv, Negativ;
-- Streams block
 
-- Routine
function Prepare(nameOnly)   
    
    source = instance.source;
	RP = instance.parameters.RP;
	Method = instance.parameters.Method;
	
	assert(core.indicators:findIndicator(Method) ~= nil, "Please, download and install" .. Method .. "indicator");
	 
    local name = profile:id() .. "(" .. source:name() .. ", " .. RP.. ", " .. Method   .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	pos = instance:addInternalStream(0, 0);
    neg = instance:addInternalStream(0, 0);
	Positiv = core.indicators:create(Method, pos, RP);
	Negativ = core.indicators:create(Method, neg, RP);
    first= Positiv.DATA:first();
  
    
    RSI = instance:addStream("MACD", core.Line, name .. ".RSI", "RSI", instance.parameters.RSI_color,  first );
	RSI:setWidth(instance.parameters.RSI_width);
    RSI:setStyle(instance.parameters.RSI_style);
  
    RSI:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	 RSI:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
		
  
    RSI:setPrecision(math.max(2, instance.source:getPrecision())); 
end

 

 function Calculate(period, mode )
  
   
    
            diff = source[period] - source[period - 1];
            if (diff > 0) then 
                pos[period] = diff;
            else
                neg[period] = -diff;
            end
             
    		
			
			Positiv:update(mode);
			Negativ:update(mode);
			
	if first > period then
	return;
	end
	
		
        if (Negativ.DATA[period] == 0) then
            RSI[period] = 0;
        else
            RSI[period] = 100 - (100 / (1 + Positiv.DATA[period] / Negativ.DATA[period]));
        end
	
	 
 
 end
 

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode) 



    Calculate(period, mode );
	 
end
 
 

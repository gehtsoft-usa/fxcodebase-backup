-- Id: 4043
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1387

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
    indicator:name("Relative Momentum Index");
    indicator:description("Variation on the Relative Strength Index (RSI)");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
   

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "Smoothing period", "Smoothing period", 14, 2, 1000);
	indicator.parameters:addInteger("F", "Momentum period", "Momentum period", 4, 1, 1000);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrRSI", "Color of RMI Line", "Color of RMI Line", core.rgb(255, 0, 0));
	
	
	indicator.parameters:addInteger("width", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addColor("Over_Color", "Overbought /  Oversold Color", "", core.rgb(128, 128, 128));
	
	indicator.parameters:addInteger("Over_Width", "Overbought /  Oversold Width", "", 1, 1, 5);
    indicator.parameters:addInteger("Over_Style", "Overbought /  Oversold  Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Over_Style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addGroup("Overbought/Oversold Levels");
	 indicator.parameters:addInteger("Overbought", "Overbought Level", "", 70, 0, 100);
	 indicator.parameters:addInteger("Oversold", "Oversold Level", "", 30, 0, 100);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local n;

local Overbought;
local Oversold;


local first;
local source = nil;
local pos = nil;
local neg = nil;
local Frame;

-- Streams block
local RSI = nil;
local positive = nil;
local negative = nil;
local diff=0;

local Over_Style,Over_Width, Over_Color;

-- Routine
function Prepare(nameOnly)
    Over_Style = instance.parameters.Over_Style;
	Over_Width = instance.parameters.Over_Width ;
	Over_Color = instance.parameters.Over_Color;	

	
    Overbought = instance.parameters.Overbought;
	Oversold = instance.parameters.Oversold;
    n = instance.parameters.N;
    source = instance.source;
	Frame = instance.parameters.F;
   

    local name = profile:id() .. "(" .. source:name() .. ", " .. n .. ", ".. Frame ..")";
    instance:name(name);
    if nameOnly then
        return;
    end

	pos = instance:addInternalStream(0, 0);
    neg = instance:addInternalStream(0, 0);
	
	positive = core.indicators:create("WMA", pos, n);
	negative = core.indicators:create("WMA", neg, n);
	
    
	first = positive.DATA:first();
	
    RSI = instance:addStream("RSI", core.Line, name, "RSI", instance.parameters.clrRSI, first)    
    RSI:setPrecision(math.max(2, instance.source:getPrecision()));
    RSI:addLevel(0);    
    RSI:addLevel(Overbought,Over_Style,Over_Width, Over_Color);    
    RSI:addLevel(Oversold, Over_Style, Over_Width , Over_Color);    
    RSI:addLevel(100);  

    RSI:setWidth(instance.parameters.width);
    RSI:setStyle(instance.parameters.style);	
end

-- Indicator calculation routine
function Update(period,mode)

    if period < Frame then
	return;
	end
           
            diff = source[period] - source[period - Frame];
        
     		if (diff > 0) then 
                pos[period] = diff;
				neg[period] = 0;
				
            else
               neg[period] = -diff;
			   pos[period] = 0;
            end
			
			
			if period < first then
			return;
			end
				             
										   
							
					           positive:update(mode);
							   negative:update(mode);

								
										if (negative.DATA[period] == 0) then
											RSI[period] = 0;
										else
											RSI[period] = 100 - (100 / (1 + positive.DATA[period] / negative.DATA[period]));
										end
					
		
		
end

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=34092
-- Id: 8900

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("RSI STARC Indicator");
    indicator:description("RSI STARC Indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("RP", "RSI Period", "RSI Period", 14);
    indicator.parameters:addInteger("AP", "ATR Period", "ATR Period", 14);
    indicator.parameters:addInteger("MP", "MA Period", "MA Period", 14);
    indicator.parameters:addDouble("TM", "Top Line Multiplier", "Top Line Multiplier", 2);
    indicator.parameters:addDouble("BM", "Bottom  Line Multiplier", "Bottom  Line Multiplier", 2);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Top_color", "Color of Top", "Color of Top", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
   
    indicator.parameters:addColor("Central_color", "Color of Central", "Color of Central", core.rgb(128, 128, 128));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("Bottom_color", "Color of Bottom ", "Color of Bottom", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
	
	
	
	 indicator.parameters:addColor("RSI_color", "Color of RSI", "Color of RSI", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width4", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style4", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style4", core.FLAG_LINE_STYLE);
	
	
	
	
	
	 indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 70);
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
local RP;
local AP;
local MP;
local TM;
local BM;
local ATR, atr; 
local source = nil;
local RSI;
-- Streams block
local Top ,Bottom,Central;
local rsi = nil; 
local ma, MA;
local tr; 
 
-- Routine
function Prepare(nameOnly)
    RP = instance.parameters.RP;
    AP = instance.parameters.AP;
    MP = instance.parameters.MP;
    TM = instance.parameters.TM;
    BM = instance.parameters.BM;
	
    source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(RP) .. ", " .. tostring(AP) .. ", " .. tostring(MP) .. ", " .. tostring(TM) .. ", " .. tostring(BM) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        rsi = core.indicators:create("RSI", source.close, RP);
        
        tr=    instance:addInternalStream(0, 0);
        atr = core.indicators:create("MVA",tr, AP);	
        
        ma = core.indicators:create("MVA", rsi.DATA, MP);
        Top = instance:addStream("TOP", core.Line, name .. ".Top", "Top", instance.parameters.Top_color,  atr.DATA:first());
    Top:setPrecision(math.max(2, instance.source:getPrecision()));
		Top:setWidth(instance.parameters.width1);
        Top:setStyle(instance.parameters.style1);
       
		
        Central = instance:addStream("CENTRAL", core.Line, name .. ".Cental", ".Cental", instance.parameters.Central_color,  atr.DATA:first());
    Central:setPrecision(math.max(2, instance.source:getPrecision()));
		Central:setWidth(instance.parameters.width2);
        Central:setStyle(instance.parameters.style2);
		
        Bottom = instance:addStream("BOTTOM", core.Line, name .. ".Bottom", "Bottom", instance.parameters.Bottom_color,  atr.DATA:first());
    Bottom:setPrecision(math.max(2, instance.source:getPrecision()));
		Bottom:setWidth(instance.parameters.width3);
        Bottom:setStyle(instance.parameters.style3);
		
		
		 RSI = instance:addStream("RSI", core.Line, name .. ".RSI", "RSI", instance.parameters.RSI_color,  atr.DATA:first());
    RSI:setPrecision(math.max(2, instance.source:getPrecision()));
		RSI:setWidth(instance.parameters.width4);
        RSI:setStyle(instance.parameters.style4);
		  RSI:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
		RSI:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
 
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

    rsi:update(mode);
	ma:update(mode);
	


    if    period < AP
	or period <rsi.DATA:first()
	then
	return;
	end
	
	 TR(period  );
		
	 atr:update(mode);
	 if period < atr.DATA:first() then
	 return;
	 end
	 
	 
	   RSI[period] = rsi.DATA[period];	  
	    Central[period] = ma.DATA[period];	
        Top[period] = ma.DATA[period]+TM* atr.DATA[period];      
        Bottom[period] =  ma.DATA[period]-BM*atr.DATA[period];  
		
		

end


function TR (period) 
   tr[period] = math.abs(rsi.DATA[period-1]-rsi.DATA[period]) ;   
end

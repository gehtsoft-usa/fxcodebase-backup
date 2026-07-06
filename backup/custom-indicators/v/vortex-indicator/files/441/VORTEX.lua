-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=277

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+
 


-- Indicator profile initialization routine
function Init()
    indicator:name("The Vortext Indicator");
    indicator:description("The indicator was described in Jan, 10 issue of the 'Stock and Commodites' Magazin");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
   
   
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("N", "Length of the vortex", "No description", 14);
	
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("VIP_color", "Color of VI+", "Color of VI+", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("VIM_color", "Color of VI-", "Color of VI-", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 150);
    indicator.parameters:addDouble("oversold","Oversold Level","", 50);
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
local N;

local first;
local source = nil;

-- Streams block
local VIP = nil;
local VIM = nil;
local iVIP = nil;
local iVIN = nil;
local iATR = nil;

-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
    N = instance.parameters.N;
    source = instance.source;
    iATR = core.indicators:create("ATR", instance.source, 1);
 
    first = iATR.DATA:first() + N+1; 

   
    VIP = instance:addStream("VIP", core.Line, name .. ".VI+", "VI+", instance.parameters.VIP_color, first);
	VIP:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	VIP:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color); 
	VIP:setWidth(instance.parameters.width1);
    VIP:setStyle(instance.parameters.style1);
	VIP:setPrecision (4);
    VIM = instance:addStream("VIM", core.Line, name .. ".VI-", "VI-", instance.parameters.VIM_color, first);
	VIM:setWidth(instance.parameters.width2);
    VIM:setStyle(instance.parameters.style2);
	VIM:setPrecision (4);

    iVIP = instance:addInternalStream(1, 0);
    iVIM = instance:addInternalStream(1, 0);
end

-- Indicator calculation routine
function Update(period, mode)
    iATR:update(mode);
 
        iVIP[period] = math.abs(source.high[period] - source.low[period - 1]);
        iVIM[period] = math.abs(source.low[period] - source.high[period - 1]);
    
    if period < first then
	return;
	end
      
        svip = mathex.sum(iVIP, period-N+1, period);
        svim = mathex.sum(iVIM, period-N+1, period);
        satr = mathex.sum(iATR.DATA, period-N+1, period);

        VIP[period] = svip / satr * 100;
        VIM[period] = svim / satr * 100;
    
end


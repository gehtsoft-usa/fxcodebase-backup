-- Id: 12511

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61163

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
    indicator:name("Pro-Go indicator");
    indicator:description("Pro-Go indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "Period", 7);
	 indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color1", "Prof Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color2", "Public Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","",75);
    indicator.parameters:addDouble("oversold","Oversold Level","", 25);
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
local Period;

local first;
local source = nil;

-- Streams block
local ASI = nil;
local Prof, Public;
local prof, public;
local MA1, MA2;
local Raw1, Raw2, Raw3, Raw4;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
    source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
		prof = instance:addInternalStream(0, 0);
		public = instance:addInternalStream(0, 0);
		
		Raw1 = instance:addInternalStream(0, 0);
		Raw2 = instance:addInternalStream(0, 0);
		Raw3 = instance:addInternalStream(0, 0);
		Raw4 = instance:addInternalStream(0, 0);
		
		 MA1 = instance:addInternalStream(0, 0);
		 MA2 = instance:addInternalStream(0, 0);
	
		
		 first =source:first()+Period;
        Prof = instance:addStream("Prof", core.Line, name, "Prof", instance.parameters.color1, first);
    Prof:setPrecision(math.max(2, instance.source:getPrecision()));
		Prof:setWidth(instance.parameters.width1);
        Prof:setStyle(instance.parameters.style1);
		
		Prof:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
		Prof:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
		
		Public = instance:addStream("Public", core.Line, name, "Public", instance.parameters.color2, first);
    Public:setPrecision(math.max(2, instance.source:getPrecision()));
		Public:setWidth(instance.parameters.width2);
        Public:setStyle(instance.parameters.style2);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    
	prof[period]= source.open[period]-source.close[period];
	public[period]= source.open[period]-source.close[period-1];
	
	if period < first  or not  source:hasData(period) then
	return;
	end
	MA1[period]=mathex.avg(prof, period-Period+1, period);
	MA2[period]=mathex.avg(public, period-Period+1, period);
	
	
 
	
	if period < first  + Period  then
	return;
	end
	
	
	
	
	LLV,HHV=mathex.minmax(MA1, period-Period+1, period);
	Raw1[period]= MA1[period] - LLV;
	Raw2[period] = HHV  - LLV;
	
	
		 
    Prof[period]=(mathex.sum(Raw1 ,period-Period+1, period) / mathex.sum(Raw2 ,period-Period+1, period))*100;
	 
	
	LLV,HHV=mathex.minmax(MA2, period-Period+1, period);
	Raw3[period]=MA2[period] - LLV;
	Raw4[period]= HHV  - LLV;
	
	
	
	 if mathex.sum(Raw4 ,period-Period+1, period) == 0 
	 then
	 Public[period]=50;
	 else
	 Public[period]=(mathex.sum(Raw3 ,period-Period+1, period) / mathex.sum(Raw4 ,period-Period+1, period))*100;
   end
  
end

--[[
 
 PRO-GO - Williams-Professionals
Prof:=Mov(O - C,7,S);
(((Sum( Prof - LLV(Prof,7),7)) / Sum((HHV(Prof,7) - LLV(Prof,7)),7)))*100;
25;
75;
PRO-GO - Williams-Public
Public:= Mov(O - Ref(C,-1), 7, S);
((((Sum( Public - LLV(Public,7),7)) / Sum((HHV(Public,7) - LLV(Public,7)),7)))*100);
75;
25;

]]


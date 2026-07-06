-- Id: 15457

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63137

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
function Init()
    indicator:name("Bollinger Bands Outside Bands Count");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Bollinger Bands Calculation");
	indicator.parameters:addInteger("Period", "Period", "", 14, 2, 1000);
	indicator.parameters:addDouble("Deviations", "Number of standard deviations", "", 2);
	 
	indicator.parameters:addGroup("Calculation");
	
	
	
	indicator.parameters:addInteger("LookBack", "LookBack Period", "LookBack Period", 100);
	
	indicator.parameters:addString("Method", "Method", "Method" , "Over/Total &  Under/Total Central Line");
    indicator.parameters:addStringAlternative("Method", "(Over+Under)/Total", "(Over+Under)/Total" , "(Over+Under)/Total");
    indicator.parameters:addStringAlternative("Method", "Over/Total &  Under/Total" , "Over/Total &  Under/Total", "Over/Total &  Under/Total");
   -- indicator.parameters:addStringAlternative("Method", "(Over+Under)/Total Central Line", "(Over+Under)/Total Central Line" , "(Over+Under)/Total Central Line");
    indicator.parameters:addStringAlternative("Method", "Over/Total &  Under/Total Central Line" , "Over/Total Central Line &  Under/Total", "Over/Total &  Under/Total Central Line");
   
	indicator.parameters:addGroup("Line Style");
	indicator.parameters:addColor("color1", "Color of Ratio (Over)", "Color of Ratio", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
   
   indicator.parameters:addColor("color2", "Color of Ratio (Under)", "Color of Ratio", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local first;
local source = nil;
local LabelColor,LabelSize,X,Y, ShiftY;
local Over = nil;
local Under = nil;
local LookBack;
local min,max;
local Deviations, Period;
local BB;
local Method;
local OverRatio,OverRatio;
-- Routine
function Prepare(nameOnly)
    source = instance.source;
	
	LookBack= instance.parameters.LookBack;
	Method= instance.parameters.Method;
	 
	Deviations= instance.parameters.Deviations;
	Period= instance.parameters.Period;

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name); 
	
	if   (nameOnly) then
        return;
    end
	
	
	BB=core.indicators:create("BB",  source , Period, Deviations);
    first = BB.DATA:first() ; 
 
	
	Over = instance:addInternalStream(first, 0);
	Under = instance:addInternalStream(first, 0);
  
 
	if Method == "(Over+Under)/Total"  then
	Ratio = instance:addStream("Ratio", core.Line, name, "Ratio", instance.parameters.color1, first);
	Ratio:setWidth(instance.parameters.width1);
    Ratio:setStyle(instance.parameters.style1); 
	
	
	Ratio:setPrecision(math.max(2, instance.source:getPrecision()));
	elseif  Method == "Over/Total &  Under/Total" or Method == "Over/Total &  Under/Total Central Line" then
	
	OverRatio = instance:addStream("OverRatio", core.Line, name, "OverRatio", instance.parameters.color1, first);
	OverRatio:setWidth(instance.parameters.width1);
    OverRatio:setStyle(instance.parameters.style1); 
	
	
	UnderRatio = instance:addStream("UnderRatio", core.Line, name, "UnderRatio", instance.parameters.color2, first);
	UnderRatio:setWidth(instance.parameters.width2);
    UnderRatio:setStyle(instance.parameters.style2); 
	
	OverRatio:setPrecision(math.max(2, instance.source:getPrecision()));
	UnderRatio:setPrecision(math.max(2, instance.source:getPrecision()));
	end
end

-- Indicator calculation routine
function Update(period)

    BB:update(mode);
	
	Over[period]=0;
    Under[period]=0;     
 
		  
    if period < first or not  source:hasData(period) then
	return;
	end
	if Method == "(Over+Under)/Total" then
		if source[period]> BB.TL[period]then
		Over[period]=1;
		elseif source[period]< BB.BL[period]then
		Under[period]=1;
		end
		
	   max=mathex.sum(Over, math.max(first, period-LookBack+1), period);
       min=mathex.sum(Under, math.max(first, period-LookBack+1), period);
	    Ratio[period]=(max+min)/ ((period-math.max(first, period-LookBack+1) )/100);
	elseif  Method == "Over/Total &  Under/Total" then
		   if source[period]> BB.TL[period]then
			Over[period]=1;
			elseif source[period]< BB.BL[period]then
			Under[period]=1;
			end
			
		   max=mathex.sum(Over, math.max(first, period-LookBack+1), period);
		   min=mathex.sum(Under, math.max(first, period-LookBack+1), period);
			OverRatio[period]=max/ ((period-math.max(first, period-LookBack+1) )/100);
			UnderRatio[period]=min/ ((period-math.max(first, period-LookBack+1) )/100);
	 
	elseif  Method == "Over/Total &  Under/Total Central Line" then
		   if source[period]> BB.AL[period]then
			Over[period]=1;
			elseif source[period]< BB.AL[period]then
			Under[period]=1;
			end
			
		   max=mathex.sum(Over, math.max(first, period-LookBack+1), period);
		   min=mathex.sum(Under, math.max(first, period-LookBack+1), period);
			OverRatio[period]=max/ ((period-math.max(first, period-LookBack+1) )/100);
			UnderRatio[period]=min/ ((period-math.max(first, period-LookBack+1) )/100);
	  end
 
end
 
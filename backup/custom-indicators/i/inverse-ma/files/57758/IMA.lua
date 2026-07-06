-- Id: 8844

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=33995

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
    indicator:name("Inverse MA");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "Period", 14);
	
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addString("Mode", "Type of Normalization", "", "Normalization");
    indicator.parameters:addStringAlternative("Mode", "Normalization", "", "Normalization");
	indicator.parameters:addStringAlternative("Mode", "Period Normalization", "", "Period Normalization");
    indicator.parameters:addStringAlternative("Mode", "Period Anchored", "", "Period Anchored");
	indicator.parameters:addStringAlternative("Mode", "Period Anchored with Normalization", "", "Period Anchored with Normalization");
	
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addBoolean("Show" , "Show  MA", "", true);	

	indicator.parameters:addColor("MA_color", "Color of MA", "Color of MA", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("IMA_color", "Color of IMA", "Color of IMA", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;
local Show;
local first;
local source = nil;
local Method;
-- Streams block
local IMA = nil;
local MA=nil;
local ma, ima;
local Mode;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
	Mode = instance.parameters.Mode;
	Show = instance.parameters.Show;
	Method= instance.parameters.Method;
    source = instance.source;
	
	

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period).. ", " .. tostring(Method) .. ", " .. tostring(Mode).. ")";
    instance:name(name);

    if   (nameOnly) then
        return;
    end
	
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
	ma = core.indicators:create(Method,source, Period);
    ima= instance:addInternalStream(0, 0);
	
    first = ma.DATA:first();
	
	
	    if Show then
	    MA = instance:addStream("MA", core.Line, name, "MA", instance.parameters.MA_color, first);
		MA:setWidth(instance.parameters.width1);
        MA:setStyle(instance.parameters.style1);
		else
		MA= instance:addInternalStream(0, 0);
		end
        IMA = instance:addStream("IMA", core.Line, name, "IMA", instance.parameters.IMA_color, first);
		IMA:setWidth(instance.parameters.width2);
        IMA:setStyle(instance.parameters.style2);
    
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

    ma:update(mode);
    if period < first   then
	return;
	end
	
	local i, min1, max1, min2, max2;
	
	    MA[period] = ma.DATA[period];
		
		if Mode == "Normalization" then
        ima[period] = ima[period-1] - (  MA[period]  - MA[period-1] );
		
				if period == source:size()-1 then
				
					min1,max1=mathex.minmax(MA,  first, period );
					min2,max2=mathex.minmax(ima,  first, period );	

					 for i = first, source:size()-1 do
					IMA[i] =min1 +((max1-min1)/100) * ( (ima[i]-min2 )/ ((max2-min2)/100));				
					end
				
				end
				
			
		
		elseif Mode == "Period Anchored"  then
		
		       IMA[period] = MA[period-Period]
			   
		       for i = period-Period+1, period, 1 do
		       IMA[period] = IMA[period] - (  MA[i]  - MA[i-1] );
			   end
			   
		elseif Mode == "Period Anchored with Normalization"  then
		
		       ima[period] = MA[period-Period]
			   
		       for i = period-Period+1, period, 1 do
		       ima[period] = ima[period] - (  MA[i]  - MA[i-1] );
			   end
			   
			   if period > ma.DATA:first()+Period then
					min1,max1=mathex.minmax(MA,  period-Period+1, period );
					min2,max2=mathex.minmax(ima,  period-Period+1, period );	

					 for i = period-Period+1, period do
					IMA[i] =min1 +((max1-min1)/100) * ( (ima[i]-min2 )/ ((max2-min2)/100));				
					end
				end
			   
			   
		elseif Mode == "Period Normalization"  then
		
		      ima[period] = ima[period-1] - (  MA[period]  - MA[period-1] );
		
				 
				if period > ma.DATA:first()+Period then
					min1,max1=mathex.minmax(MA,  period-Period+1, period );
					min2,max2=mathex.minmax(ima,  period-Period+1, period );	

					 for i = period-Period+1, period do
					IMA[i] =min1 +((max1-min1)/100) * ( (ima[i]-min2 )/ ((max2-min2)/100));				
					end
				end
				
		
		end
		
    
end


-- Id: 14393

-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=62388

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
    indicator:name("Trend direction");
    indicator:description("Trend direction");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Caclulation");
	indicator.parameters:addInteger("Period", "Period","", 14);
    indicator.parameters:addDouble("OB", "OB Level","", 70);
     indicator.parameters:addDouble("OS", "OS Level","", 30);
	
	indicator.parameters:addGroup("Style");
    color = core.colors();
	indicator.parameters:addColor("color1", "Up Trend Color", "Color", color.Lime);
	indicator.parameters:addColor("color2", "Down Trend Color", "Color", color.Red);
    indicator.parameters:addColor("color3", "Neutral Color", " Color", color.Gray);
	
	
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
local oscillator = nil;
local RSI;
local signal;
local OB,OS;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
    OB = instance.parameters.OB;
	OS = instance.parameters.OS;
    source = instance.source;
	
	

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ")";
    instance:name(name); 
	
    if   (nameOnly) then
        return;
    end
	
	
	signal = instance:addInternalStream(0, 0);
	RSI = core.indicators:create("RSI", source, Period);
    first = RSI.DATA:first();
	
	
        oscillator = instance:addStream("oscillator", core.Bar, name, "oscillator", instance.parameters.color3, first);	 
		oscillator:addLevel(0);
        oscillator:addLevel(1);	

    oscillator:setPrecision(math.max(2, instance.source:getPrecision()));		
   
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode) 
		
    RSI:update(mode);
	
	 if period < first then
	 return;
	 end
	 
	 oscillator[period]=1;
	
	if RSI.DATA[period] > OB then	
	signal[period]=1;	
	elseif RSI.DATA[period] < OS then
	signal[period]=-1;
	else
	signal[period]=signal[period-1];
	end
	
	if signal[period]== 1 then	
	oscillator:setColor(period,  instance.parameters.color1);
	elseif signal[period]== -1 then
	oscillator:setColor(period,  instance.parameters.color2);
	else
	oscillator:setColor(period,  instance.parameters.color3);
	end
	
 
	
	
     
end
 
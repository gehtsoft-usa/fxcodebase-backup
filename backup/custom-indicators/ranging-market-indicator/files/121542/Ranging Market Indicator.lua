-- Id: 22443
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66790

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Ranging Market Indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	
	indicator.parameters:addGroup("Selector");
	
	indicator.parameters:addBoolean("S1", "Use ADX Filter", "", true);
	indicator.parameters:addBoolean("S2", "Use ATR Filter", "", true);
	indicator.parameters:addBoolean("S3", "Use RSI Filter", "", true);

	indicator.parameters:addGroup("1. ADX Calculation");
	
    indicator.parameters:addInteger("ADX_Period", "ADX Period", "", 14);
    indicator.parameters:addDouble("ADX_Level", "ADX Level", "", 25);
	
	indicator.parameters:addGroup("2. ATR Calculation");
	
    indicator.parameters:addInteger("ATR_Period", "ATR Period", "", 14);
    indicator.parameters:addInteger("ATR_MA_Period", "MA Period", "", 20);
	
	
	indicator.parameters:addGroup("3. RSI Calculation");
	
    indicator.parameters:addInteger("RSI_Period", "RSI Period", "", 14);
    indicator.parameters:addDouble("RSI_OB_Level", "OB Level", "", 60);
	indicator.parameters:addDouble("RSI_OS_Level", "OS Level", "", 40);
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Range", "Range color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Trend", "Trend color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral color", "", core.rgb(0, 0, 255));
	
   
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local Range,Trend, Neutral;
local first;
local source = nil;
local ADX, ADX_Period, ADX_Level;
local ATR_Period, ATR_MA_Period, ATR, ATR_MA; 
local RSI, RSI_Period, RSI_OB_Level, RSI_OS_Level;
local Oscillator;
local S1, S2, S3;

 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end


    Range = instance.parameters.Range;
    Trend= instance.parameters.Trend;
    Neutral= instance.parameters.Neutral;
	
	S1= instance.parameters.S1;
	S2= instance.parameters.S2;
	S3= instance.parameters.S3;
   
    
	source = instance.source;
	first= source:first();
	
	ADX_Period= instance.parameters.ADX_Period;
	ADX_Level= instance.parameters.ADX_Level;
	
	ATR_Period= instance.parameters.ATR_Period;
	ATR_MA_Period= instance.parameters.ATR_MA_Period;
	
	
	RSI_Period= instance.parameters.RSI_Period;
	RSI_OB_Level= instance.parameters.RSI_OB_Level;
	RSI_OS_Level= instance.parameters.RSI_OS_Level;
	
	 
 
	ADX=core.indicators:create("ADX",  source, ADX_Period);	
	first=math.max(first, ADX.DATA:first());
	
	ATR=core.indicators:create("ATR",  source, ATR_Period);	
	ATR_MA=core.indicators:create("MVA",  ATR.DATA, ATR_MA_Period);	
	first=math.max(first, ATR_MA.DATA:first());
	
	RSI=core.indicators:create("RSI",  source.close, RSI_Period);	
	first=math.max(first, RSI.DATA:first());
 
    	
	Oscillator = instance:addStream("Oscillator", core.Bar, "Oscillator", "Oscillator", Neutral, first);
	
	Oscillator:setPrecision(math.max(2, instance.source:getPrecision()));
     
		
end

-- Indicator calculation routine
function Update(period, mode)
	
	 
	
	if period < first then
	return;
	end
	
	
	if S1 then
		ADX:update(mode);
				   
		if ADX.DATA[period]> ADX_Level then  
		Oscillator[period]= 1;
		else
		Oscillator[period]= 0;
		end
	end
	
	
	if S2 then
	
		ATR:update(mode);
		ATR_MA:update(mode);
				   
		if ATR.DATA[period]> ATR_MA.DATA[period] then  
		Oscillator[period]= 1;
		else
		Oscillator[period]= 0;
		end
	
	end
	
	
	if S3 then
	
	    RSI:update(mode);
		
		if RSI.DATA[period]< RSI_OS_Level or RSI.DATA[period]>  RSI_OB_Level then  
		Oscillator[period]= 1;
		else
		Oscillator[period]= 0;
		end
	end
	
	if Oscillator[period] > 0 then
	Oscillator:setColor(period, Trend);	
	else
	Oscillator:setColor(period, Range);		
    end	
		 
		
		
				

		
 end



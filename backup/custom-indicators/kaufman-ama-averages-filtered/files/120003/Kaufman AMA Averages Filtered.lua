-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66282

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

function Init()
    indicator:name("Oscillator TemplateKaufman AMA Averages Filtered");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	
	
	indicator.parameters:addGroup("Calculation");
	
	indicator.parameters:addString("Price", "Filter Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted");	
	
	
    indicator.parameters:addString("Method", "Filter Method", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Method", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Method", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Method", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Method", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Method", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Method", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Method", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Method", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Method", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Method", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Method", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Method", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Method", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Method", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Method", "JSmooth", "", "JSmooth");
    indicator.parameters:addStringAlternative("Method", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Method", "ARSI", "", "ARSI");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "", "VIDYA");
    indicator.parameters:addStringAlternative("Method", "HPF", "", "HPF");
    indicator.parameters:addStringAlternative("Method", "VAMA", "", "VAMA");


    indicator.parameters:addInteger("Period", "Filter Period", "", 5);
	indicator.parameters:addInteger("N", "Period", "", 10);
	indicator.parameters:addDouble("Fast", "Fast","", 2);
	indicator.parameters:addDouble("Slow", "Slow","", 30);
	indicator.parameters:addDouble("Coeff", "Coeff","", 2);
	
	

	indicator.parameters:addGroup("Style"); 	
	indicator.parameters:addColor("color_Up", "Up Line Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("color_Down", "Down Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block


local first;
local source = nil;
 
local KAMA,Indicator;  
local Method, Period;
local  fast, slow;
local N;
local Work;
-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

	

    fast = (2.0 /( instance.parameters.Fast + 1));
    slow = (2.0 /( instance.parameters.Slow + 1));
  
    Method= instance.parameters.Method;
	Period= instance.parameters.Period;
	N= instance.parameters.N;
			
    source = instance.source;
	
	Work= instance:addInternalStream(0, 0);
    
	
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");

  
    Indicator = core.indicators:create("AVERAGES", source[instance.parameters.Price], Method, Period);
    
    first=Indicator.DATA:first();
	
	 
   
 
	KAMA = instance:addStream("KAMA" , core.Line, " KAMA"," KAMA",instance.parameters.color_Up, first+ N);
	KAMA:setWidth(instance.parameters.width);
    KAMA:setStyle(instance.parameters.style);
    
	
	
end

-- Indicator calculation routine
function Update(period, mode)

 
 
    Indicator:update(mode);
	
	
    if period < first + N then
	return;
	end
	
  
		  
	
    local signal = math.abs(Indicator.DATA[period]-Indicator.DATA[period-N]);
    Work[period]= math.abs(Indicator.DATA[period]-Indicator.DATA[period-1]);	
	local noise = mathex.sum(Work, period-N+1, period);
	
	 if (noise ~= 0) then
	 ratio = signal/noise;
	 end
	 
	 local smooth = math.pow(ratio*(fast-slow)+slow,instance.parameters.Coeff);
	
     KAMA[period]= KAMA[period-1]+smooth*(Indicator.DATA[period]-KAMA[period-1]);
	 
	 if KAMA[period] > KAMA[period-1] then
	 KAMA:setColor(period, instance.parameters.color_Up);
	 else
	 KAMA:setColor(period, instance.parameters.color_Down);
	 end
				  
end



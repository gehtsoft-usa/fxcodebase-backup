-- Id: 23053
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=67042

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
    indicator:name("ELDER´S MARKET THERMOMETER");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
 
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("lengthMA", "MA Length", "", 22,1, 2000);
	indicator.parameters:addDouble("explosiveMktThreshold", "Explosive Market Threshold", "", 3,0, 2000);
	indicator.parameters:addDouble("idleMarketThreshold", "Idle Market Threshold", "", 7,0, 2000);
 
	
	indicator.parameters:addString("Method", "MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
 
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color", "Label Color", "", core.rgb(128, 128, 128));
 
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Method, Price; 
local lengthMA, explosiveMktThreshold,idleMarketThreshold;
local first;
local source = nil;
 
local Oscillator;  
local MA;
local qc;

-- Routine
 function Prepare(nameOnly)   
   
    lengthMA= instance.parameters.lengthMA;
	explosiveMktThreshold= instance.parameters.explosiveMktThreshold;
	idleMarketThreshold= instance.parameters.idleMarketThreshold;

    Method= instance.parameters.Method;
     
	
	local Parameters=lengthMA ..  ", " ..explosiveMktThreshold ..  ", " ..idleMarketThreshold ..  ", " ..Method  ;
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. "," ..   Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    qc= instance:addInternalStream(0, 0);
			
    source = instance.source; 
   
	
	 
   
 
	Oscillator = instance:addStream("MarketThermometer" , core.Bar, " Market Thermometer"," Market Thermometer",instance.parameters.color, source:first()+1); 
	Oscillator:setPrecision(math.max(2, source:getPrecision()));
	
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
	MA = core.indicators:create(Method, Oscillator, lengthMA); 
    first=MA.DATA:first();
	
	
end

-- Indicator calculation routine
function Update(period, mode)

 
 
   
	
	
    if period < source:first()+1 then
	return;
	end
	
	if source.high[period]<source.high[period-1] and source.low[period]>source.low[period-1] then
    Oscillator[period]=0
    elseif (source.high[period]-source.high[period-1])> (source.low[period-1]-source.low[period]) then
    Oscillator[period]=math.abs(source.high[period]-source.high[period-1])
    else
    Oscillator[period] = math.abs(source.low[period-1] - source.low[period])
    end
	
		
    MA:update(mode);
	
	
    if period < first then
	return;
	end
	
	
	if MA.DATA[period]>Oscillator[period] then
	 qc[period]=(qc[period-1])+1
	else
	 qc[period]=0
	end 
	
	
	local r=0;
	local b=0;
	local g=0;
	 
	if  (Oscillator[period]< MA.DATA[period]) then
	 if qc[period]>idleMarketThreshold then
	  r=0
	  g=128
	  b=0
	 else
	  r=0
	  g=0
	  b=255
	 end 
	elseif  (Oscillator[period] > MA.DATA[period]) and (Oscillator[period] < MA.DATA[period]*explosiveMktThreshold)then
	 r=255
	 g=165
	 b=0
	else
	 r=255
	 g=0
	 b=0
	end 
	
	
	Oscillator:setColor(period, core.rgb(r, g, b));
				  
end


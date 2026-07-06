-- Id: 24343
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=68188

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC | 
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
    indicator:name("TAC Volume MACD TIMING");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
	indicator.parameters:addInteger("Period", "Period", "", 60, 1, 2000);
	indicator.parameters:addInteger("Shift", "Shift", "", 5, 0, 2000);
    indicator.parameters:addInteger("Period1", "Short Period", "", 12, 1, 2000);
	indicator.parameters:addInteger("Period2", "Long Period", "", 26, 1, 2000);
	indicator.parameters:addInteger("Period3", "Signal Period", "", 9, 1, 2000);
 
	local Delta=255/4;
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("Color10", "Neutral Color", "", core.rgb(128, 128, 128));
    indicator.parameters:addColor("Color11", "1. Up Color", "", core.rgb(0, Delta*1, 0));
	indicator.parameters:addColor("Color12", "2. Up Color", "", core.rgb(0, Delta*2, 0));
	indicator.parameters:addColor("Color13", "3. Up Color", "", core.rgb(0, Delta*3, 0));
	indicator.parameters:addColor("Color14", "4. Up Color", "", core.rgb(0, Delta*4, 0));
	
	indicator.parameters:addColor("Color9", "1. Down Color", "", core.rgb(Delta*1,0, 0));
	indicator.parameters:addColor("Color8", "2. Down Color", "", core.rgb( Delta*2,0,  0));
	indicator.parameters:addColor("Color7", "3. Down Color", "", core.rgb( Delta*3,0,  0));
	indicator.parameters:addColor("Color6", "4. Down Color", "", core.rgb( Delta*4,0,  0));
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block


local Period;
local Shift;
local first;
local source = nil;
local MACD;
local Timing;
local Wave;
local PriceVolume;
local Color={};
-- Routine
 function Prepare(nameOnly)    
 
    Period= instance.parameters.Period;
	Shift= instance.parameters.Shift;
	
	local Parameters= Period..", " ..Shift ..", " ..instance.parameters.Period1 ..", " .. instance.parameters.Period2..", " .. instance.parameters.Period3;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    Color[10]=instance.parameters.Color10;
	Color[11]=instance.parameters.Color11;
	Color[12]=instance.parameters.Color12;
	Color[13]=instance.parameters.Color13;
	Color[14]=instance.parameters.Color14;
	Color[9]=instance.parameters.Color9;
	Color[8]=instance.parameters.Color8;
	Color[7]=instance.parameters.Color7;
	Color[6]=instance.parameters.Color6;
			
    source = instance.source; 
	MACD = core.indicators:create("MACD", source.close, instance.parameters.Period1, instance.parameters.Period2, instance.parameters.Period3);
	first=math.max(MACD.SIGNAL:first(),Period) ;
	 
	PriceVolume = instance:addInternalStream(0, 0);
    Wave = instance:addInternalStream(0, 0);
 
	Timing = instance:addStream("Timing" , core.Bar, " Timing "," Timing ",Color[10], first+Shift);
    Timing:setPrecision(math.max(2, instance.source:getPrecision()));
 
	
	
end

-- Indicator calculation routine
function Update(period, mode)
 
	MACD:update(mode);
	
	
	PriceVolume[period]=source.close[period]*source.volume[period];
	
    if period < first then 
	return;
	end
	
	
	local lv1=mathex.sum(PriceVolume, period-Period+1, period);
	local lv2=mathex.sum(source.volume, period-Period+1, period);
    
	if lv2~= 0 then
	Wave[period]=lv1/lv2;
    end
	
	if period < first+Shift then 
	return;
	end
 
local HH=MACD.MACD[period];
local HH1=MACD.SIGNAL[period]; 

 Timing[period]=0;
	
--POSITIVO
if HH>=0 and HH>HH1 and Wave[period]>Wave[period-Shift] then
 Timing[period]=1
end
 
if HH>=0 and HH<HH1 and Wave[period]>Wave[period-Shift] then
 Timing[period]=2
end
 
if HH<=0 and HH<HH1 and Wave[period]>Wave[period-Shift] then
 Timing[period]=3
end
 
if HH<=0 and HH>HH1 and Wave[period]>Wave[period-Shift] then
 Timing[period]=4
end
 
--NEGATIVO
if HH<=0 and Wave[period]<Wave[period-Shift] then
 Timing[period]=-1
end
 
if HH<=0 and HH>HH1 and Wave[period]<Wave[period-Shift] then
 Timing[period]=-2
end
 
if HH>=0 and HH>HH1 and Wave[period]<Wave[period-Shift] then
 Timing[period]=-3
end
 
if HH>=0 and HH<HH1 and Wave[period]<Wave[period-Shift] then
 Timing[period]=-4
end


Timing:setColor(period, Color[10+Timing[period]]);
				  
end

 
 

 
 
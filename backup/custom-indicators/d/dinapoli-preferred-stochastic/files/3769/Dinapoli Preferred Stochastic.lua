-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1874
-- Id: 1307

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                   Paypal: https://goo.gl/9Rj74e  |
--|                    Patreon : https://www.patreon.com/mariojemic  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Dinapoli Preferred Stochastic");
    indicator:description("Dinapoli Preferred Stochastic");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
  
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("K", "Number of periods for %K", "The number of periods for %K.", 10, 2, 1000);
    indicator.parameters:addInteger("SD", "%D slowing periods", "The number of periods for slow %D.", 5, 2, 1000);
    indicator.parameters:addInteger("D", "Number of periods for %D", "The number of periods for %D.", 5, 2, 1000);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrFirst", "K line Color", "K line Color", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
	indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("clrSecond", "D line Color", "D line Color", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
	indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	
	 indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 80);
    indicator.parameters:addDouble("oversold","Oversold Level","", 20);
	    indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);

   

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local k;
local d;
local sd;

local source = nil;
local mins = nil;
local maxes = nil;

local FastK = nil;
local fastkFirst = nil;
local kFirst = nil;
local dFirst = nil;

-- Streams block
local K = nil;
local D = nil;

local  Smoothing = nil;
local  Signal = nil;

-- Routine
function Prepare(nameOnly)
    k = instance.parameters.K;
    d = instance.parameters.D;
    sd = instance.parameters.SD;
	
    source = instance.source;
	

    local name = profile:id() .. "(" .. source:name() .. ", " .. k .. ", " .. d .. ", " .. sd .. ", " .. ")";
    instance:name(name);  
    if nameOnly then
        return
    end
    mins = instance:addInternalStream(source:first() + k, 0);
    maxes = instance:addInternalStream(source:first() + k, 0);
	
    FastK = instance:addInternalStream(mins:first(), 0);	
	fastkFirst = FastK:first();
	
	Smoothing = instance:addInternalStream(fastkFirst+sd, 0);
	Signal = instance:addInternalStream(Smoothing:first()+d, 0);
			   
    K = instance:addStream("K", core.Line, name .. ".K", "K", instance.parameters.clrFirst, FastK:first() + sd);
    K:setPrecision(math.max(2, instance.source:getPrecision()));
	K:setWidth(instance.parameters.width1);
    K:setStyle(instance.parameters.style1);
	kFirst = K:first();
    D = instance:addStream("D", core.Line, name .. ".D", "D", instance.parameters.clrSecond,  Signal:first());
    D:setPrecision(math.max(2, instance.source:getPrecision()));
	D:setWidth(instance.parameters.width2);
    D:setStyle(instance.parameters.style2);
	dFirst = D:first();
	
	K:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	K:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color); 
 
end

-- Indicator calculation routine
function Update(period)
    if period < fastkFirst  then
	return;
	end
			
		 local minLow,  maxHigh=mathex.minmax(source, period-k+1, period);
		 FastK[period]= ((source.close[period] - minLow) / (maxHigh - minLow)) * 100;
		 
		Smoothing[period] =Smoothing[period-1] + (FastK[period] - Smoothing[period-1]) / sd;
		 
		if period <= kFirst then  
		return;
		end
		
			K[period]= Smoothing[period];
			
			Signal[period] = Signal[period-1] + (Smoothing[period] - Signal[period-1]) / d;
			
			 if  period >= dFirst then  	
			 D[period] =Signal[period];
			 end 
		
end


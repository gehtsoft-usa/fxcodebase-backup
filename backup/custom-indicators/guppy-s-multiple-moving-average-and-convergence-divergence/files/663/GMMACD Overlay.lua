-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=412

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

function Init()
    indicator:name("Guppy's Multiple Moving Average Convergence/Divergence Overlay");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	indicator.parameters:addGroup("Calculation");
  
    indicator.parameters:addBoolean("Show", "Use Signal Line", "", false);
	indicator.parameters:addInteger("Period", "MA Period", "", 9, 1, 1000);
	indicator.parameters:addGroup("Style");
  
    indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("Neutral", "Neutral Color", "", core.rgb(128, 128, 128));
end

local source = nil;
local GMMA = nil;
local out = nil;
local first = nil;

local  open=nil;
local  close=nil;
local  high=nil;
local  low=nil;
local Show,Period;
local Neutral, Up,Down;
 function Prepare(nameOnly)  
    source = instance.source;
	Show=instance.parameters.Show;
	Period=instance.parameters.Period;
    local name;
    -- set the indicator name (use the short name of our indicator: GMMA)
    name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	Neutral=instance.parameters.Neutral;
	Up=instance.parameters.Up;
	Down=instance.parameters.Down;
	
	assert(core.indicators:findIndicator("GMMA") ~= nil, "Please, download and install GMMA.LUA indicator");
	
    GMMA = core.indicators:create("GMMA", source.close);
    first = GMMA:getStream(11):first();
	
    out = instance:addInternalStream(first, 0);
	
	 	
	open = instance:addStream("openup", core.Line, name, "", core.rgb(0, 0, 0), first);
    high = instance:addStream("highup", core.Line, name, "", core.rgb(0, 0, 0), first);
    low = instance:addStream("lowup", core.Line, name, "", core.rgb(0, 0, 0), first);
    close = instance:addStream("closeup", core.Line, name, "", core.rgb(0, 0, 0), first);
    instance:createCandleGroup("OVERLAY", "OVERLAY", open, high, low, close);
    
end

function Update(period, mode)
    GMMA:update(mode);
	
	
	open[period] = source.open[period];
	close[period] = source.close[period];
	high[period] = source.high[period];
	low[period] = source.low[period];

    if (period < first) then
	open:setColor(period, Neutral);	
	return;
	end
	
        local f, s;
        f = GMMA:getStream(0)[period] + GMMA:getStream(1)[period] + GMMA:getStream(2)[period] +
            GMMA:getStream(3)[period] + GMMA:getStream(4)[period] + GMMA:getStream(5)[period];
        s = GMMA:getStream(6)[period] + GMMA:getStream(7)[period] + GMMA:getStream(9)[period] +
            GMMA:getStream(9)[period] + GMMA:getStream(10)[period] + GMMA:getStream(11)[period];
			
        out[period] = (f - s) / s * 100;
		
		
	      	if Show then 
			
			
									 if period < first+Period then
									open:setColor(period, Neutral);	
									return;
									end
									
									
									 local MA = mathex.avg(out, period-Period+1,period);
					
							
			                        if  out[period] > 0 and  out[period] > MA   then
									 open:setColor(period,instance.parameters.Up);
									elseif  out[period] < 0 and out[period] < MA  then
									 open:setColor(period,instance.parameters.Down);
									 else
									 open:setColor(period,instance.parameters.Neutral);
									 end 
									 
				else
					 
									if  out[period] > 0 and  out[period] > out[period-1]   then
									 open:setColor(period,instance.parameters.Up);
									elseif  out[period] < 0 and out[period] < out[period-1]  then
									 open:setColor(period,instance.parameters.Down);
									 else
									 open:setColor(period,instance.parameters.Neutral);
									end  
									 
									 
						
			 
				end
			 
end

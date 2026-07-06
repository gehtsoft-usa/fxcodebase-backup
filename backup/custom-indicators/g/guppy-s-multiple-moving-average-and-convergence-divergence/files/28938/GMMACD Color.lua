-- Id: 6186
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
    indicator:name("Guppy's Multiple Moving Average Convergence/Divergence");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
	 indicator.parameters:addInteger("Period", "MA Period", "", 9, 1, 2000);
	indicator.parameters:addGroup("Style");
	indicator.parameters:addBoolean("Show", "Show Signal Line", "", false);
    indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("Neutral", "Neutral Color", "", core.rgb(128, 128, 128));
	indicator.parameters:addColor("Signal", "Signal Color", "", core.rgb(0, 0, 255));
end

local source = nil;
local GMMA = nil;
local out, signal;
local first = nil;
local line=nil;
local MA;
local Buff;
local Show;
local Period;
 function Prepare(nameOnly)  
    Period=instance.parameters.Period;  
	Show=instance.parameters.Show;
    source = instance.source;
    local name;
    -- set the indicator name (use the short name of our indicator: GMMA)
    name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
	assert(core.indicators:findIndicator("GMMA") ~= nil, "Please, download and install GMMA.LUA indicator");    
	
    GMMA = core.indicators:create("GMMA", source);
	
    first = GMMA:getStream(11):first();
	Buff = instance:addInternalStream(0, 0);
	 
	out = instance:addStream("GMMACD", core.Bar, name .. ".GMMACD", "GMMACD",core.rgb(0, 0, 0), GMMA:getStream(11):first());   
    out:setPrecision(math.max(2, instance.source:getPrecision()));
    out:addLevel(0);
    
	MA = core.indicators:create("MVA", out, Period);
	
	
	if Show then
	signal = instance:addStream("SIGNAL", core.Line, name .. ".Signal", "Signal", instance.parameters.Signal, MA.DATA:first());
    signal:setPrecision(math.max(2, instance.source:getPrecision()));
    end	
  
end

function Update(period, mode)
    GMMA:update(mode);
	MA:update(mode);

    if (period < first) then 
	return;
	end
	
        local f, s;
        f = GMMA:getStream(0)[period] + GMMA:getStream(1)[period] + GMMA:getStream(2)[period] +
            GMMA:getStream(3)[period] + GMMA:getStream(4)[period] + GMMA:getStream(5)[period];
        s = GMMA:getStream(6)[period] + GMMA:getStream(7)[period] + GMMA:getStream(9)[period] +
            GMMA:getStream(9)[period] + GMMA:getStream(10)[period] + GMMA:getStream(11)[period];
        
		Buff[period] = (f - s) / s * 100;
		
		
		if period < MA.DATA:first() then
		return;
		end
		
		out[period]= Buff[period];
		
		if Show then
		signal[period]= MA.DATA[period];
		end
		
		if  out[period] > 0 and  out[period] > MA.DATA[period]   then
		 out:setColor(period,instance.parameters.Up);
		elseif  out[period] < 0 and out[period] < MA.DATA[period]  then
		 out:setColor(period,instance.parameters.Down);
		 else
		 out:setColor(period,instance.parameters.Neutral);
		end
		
		
		
    end


-- Id: 17678
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64470

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
    indicator:name("Modified Momentum Indicator");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
 

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Momentum_Period", "Momentum Period", "ADX The number of periods.", 14, 2, 1000);
	indicator.parameters:addInteger("MA_Period", "MA Period", "", 14, 2, 1000);
 

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color1", "Momentum Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("color2", "Signal Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID);


	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local ADXF, DMIF;
local source = nil;
local Momentum, MA,ma, MA_Period,Momentum_Period;
-- Routine
function Prepare(nameOnly)
    MA_Period = instance.parameters.MA_Period;
	Momentum_Period  = instance.parameters.Momentum_Period;
	
    source = instance.source;
    

    local name = profile:id() .. "(" .. source:name() .. ", " ..  Momentum_Period.. ", " .. MA_Period ..")";
    instance:name(name);
    if nameOnly then
        return;
    end
     
	 
    Momentum = instance:addStream("Momentum", core.Line, name , "Momentum", instance.parameters.color1, source:first()+ Momentum_Period)
    Momentum:setPrecision(math.max(2, instance.source:getPrecision()));
	Momentum:setWidth(instance.parameters.width1);
    Momentum:setStyle(instance.parameters.style1);
 
	ma = core.indicators:create("MVA", Momentum, MA_Period);
	 
	MA = instance:addStream("MA", core.Line, name, "MA", instance.parameters.color2,source:first()+ Momentum_Period+MA_Period)
    MA:setPrecision(math.max(2, instance.source:getPrecision()));
	MA:setWidth(instance.parameters.width2);
    MA:setStyle(instance.parameters.style2);
	
 
   
 
end

 

-- Indicator calculation routine
function Update(period, mode)
    
        if period < source:first()+ Momentum_Period then
		return;
		end
  
        Momentum[period]= source[period]-source[period-Momentum_Period+1];
		
        ma:update(mode);
        
		if period < source:first()+ Momentum_Period+MA_Period then
		return;
		end
        MA[period] = ma.DATA[period];
   
	 
end
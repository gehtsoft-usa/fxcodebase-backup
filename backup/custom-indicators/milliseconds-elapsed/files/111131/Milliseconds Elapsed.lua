-- Id: 17680
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64471

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
    indicator:name("Milliseconds Elapsed");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
 

    indicator.parameters:addGroup("Calculation");
 
	indicator.parameters:addInteger("MA_Period", "MA Period", "", 14, 2, 1000);
 

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color1", "Bar Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("color2", "MA Line Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);

	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local source = nil;
local Elapsed, MA,ma, MA_Period;
-- Routine
function Prepare(nameOnly)
    MA_Period = instance.parameters.MA_Period;
	
	
    source = instance.source;
    

    local name = profile:id() .. "(" .. source:name() .. ", " .. MA_Period ..")";
    instance:name(name);
    if nameOnly then
        return;
    end
      assert (  source:barSize()== "t1", "The chosen time frame must be t1!");
     
	 
    Elapsed = instance:addStream("Elapsed", core.Bar, name , "Elapsed", instance.parameters.color1, source:first() )
    Elapsed:setPrecision(math.max(2, instance.source:getPrecision()));
	 
	MA = instance:addStream("MA", core.Line, name, "MA", instance.parameters.color2,source:first() +MA_Period)
    MA:setPrecision(math.max(2, instance.source:getPrecision()));
	MA:setWidth(instance.parameters.width2);
    MA:setStyle(instance.parameters.style2);
	 
end

 
local last; 
-- Indicator calculation routine
function Update(period, mode)
    
   
      --  Elapsed[period]=  (source:date(period)-source:date(period-1))/86400;
		
	--	if last== source:serial(period) then		
		--return;
	--	end
		
		--last= source:serial(period);
		
       Elapsed[period]=(source:date(period)-source:date(period-1))*86400000;
        
		if period < source:first()+MA_Period then
		return;
		end
		
        MA[period] = mathex.avg(Elapsed, period-MA_Period+1, period);
   
	 
end
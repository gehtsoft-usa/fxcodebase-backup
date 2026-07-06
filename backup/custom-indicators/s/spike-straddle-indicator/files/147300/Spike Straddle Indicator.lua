-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72680

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+
--+------------------------------------------------------------------------------------------------+
--|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
--|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
--|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
--|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
--|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
--|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
--+------------------------------------------------------------------------------------------------+



-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Spike Straddle Indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addBoolean("Signal", "Signal Mode", "", false); 
	
    indicator.parameters:addInteger("atr_period", "ATR Period", "", 11);
    indicator.parameters:addInteger("CandleSize", "Candle Size, %", "", 150)
    indicator.parameters:addInteger("StradleSize", "Stradle Size, %", "", 10);
	
	
	indicator.parameters:addGroup("Line Style");	
	indicator.parameters:addInteger("Size", "Arrow Size", "", 30); 
   indicator.parameters:addColor("clrUP", "Up Arrow", "" ,  core.COLOR_UPCANDLE);
    indicator.parameters:addColor("clrDN",  "Down Arrow", "" , core.COLOR_DOWNCANDLE);	
	indicator.parameters:addColor("color", "Neutral Bar Color", "", core.rgb(0, 0, 255)); 

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
local Signal;	
local first;
local source = nil; 
local Indicator;
local Bar;	
local up, down;
-- Routine
 function Prepare(nameOnly)   
  
	source = instance.source
	
	Signal=instance.parameters.Signal;
	
    CandleSize = instance.parameters.CandleSize;
    StradleSize = instance.parameters.StradleSize;

    atr = core.indicators:create("ATR", source, instance.parameters.atr_period);	
	
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
 
	first=source:first()+4;  
	
	if Signal then
    Bar = instance:addStream("Bar", core.Bar, name, "Bar", instance.parameters.color, first );
    Bar:setPrecision(math.max(2, instance.source:getPrecision())); 
    Bar:addLevel(0);	
	else
    Bar = instance:addInternalStream(0, 0);	
	end
	
	
	up = instance:createTextOutput ("Up", "Up", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Top, instance.parameters.clrDN, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Bottom, instance.parameters.clrUP, 0);
 
end


function Update(period, mode)

 
	atr:update(mode); 
	  
	 if period < first then
	 return;
	 end
	  
	  
    up:setNoData(period);
    down:setNoData(period);		
    Bar[period]= 0;

    if  math.abs(source.open[period] - source.close[period]) > atr.DATA[period] * CandleSize / 100.0 then	
	  
	  
	    if  source.close[period] >  source.open[period] then
		Bar[period]= 1;
		up:set(period, source.high[period], "\108", source.high[period]); 
		else
		down:set(period, source.low[period], "\108", source.low[period]);	
		Bar[period]= -1;	
        end
	end
	
	
	
end


--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+

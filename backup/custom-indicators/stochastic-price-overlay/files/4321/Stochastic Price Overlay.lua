-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2097

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
    indicator:name("Stochastic Price Overlay");
    indicator:description("Shows the location of the current close relative to the high/low range over a set number of periods.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("K", "Number of periods for %K", "", 5, 2, 1000);
    indicator.parameters:addInteger("SD", "%D slowing periods", "", 3, 2, 1000);
    indicator.parameters:addInteger("D", "The number of periods for %D.", "", 3, 2, 1000);

    indicator.parameters:addString("KS", "Smoothing type for %K", "", "MVA");
    indicator.parameters:addStringAlternative("KS", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("KS", "EMA","", "EMA");
    indicator.parameters:addStringAlternative("KS", "MT4","", "FS");
    
    indicator.parameters:addString("DS", "Smoothing type for %D", "", "MVA");
    indicator.parameters:addStringAlternative("DS", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("DS", "EMA", "", "EMA");
			
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up", "Up Color", "", core.COLOR_UPCANDLE );
	indicator.parameters:addColor("Down", "Down Color", "", core.COLOR_DOWNCANDLE );
	indicator.parameters:addColor("Neutral", "Neutral Color", "", core.rgb(128, 128, 128) );
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;

local DS,KS;
local K,SD,D;

local  open=nil;
local  close=nil;
local  high=nil;
local  low=nil;

local Stochastic=nil;
local Up,Down,Neutral;
function Prepare(nameOnly)

     DS = instance.parameters.DS;
	 KS = instance.parameters.KS;
     K = instance.parameters.K;
	 SD = instance.parameters.SD;
	 D = instance.parameters.D;
	 Up= instance.parameters.Up;
	 Down= instance.parameters.Down;
	 Neutral= instance.parameters.Neutral;
  
	source = instance.source;     
	
		
    local name = profile:id() .. "(" .. source:name() ..", ".. K..", " .. SD .. ", " .. D ..", ".. KS.. ", ".. DS.. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	
	Stochastic=core.indicators:create("STOCHASTIC",  source, K,SD,D,KS,DS);
	first= Stochastic.DATA:first();

    	
	open = instance:addStream("openup", core.Line, name, "", core.rgb(0, 0, 0), first);
    high = instance:addStream("highup", core.Line, name, "", core.rgb(0, 0, 0), first);
    low = instance:addStream("lowup", core.Line, name, "", core.rgb(0, 0, 0), first);
    close = instance:addStream("closeup", core.Line, name, "", core.rgb(0, 0, 0), first);
    instance:createCandleGroup("MACD", "MACD", open, high, low, close);
		
end

-- Indicator calculation routine
function Update(period, mode)			
	

   	open[period]=source.open[period];
	close[period]=source.close[period];
	high[period]=source.high[period];
	low[period]=source.low[period];	
						
	 Stochastic:update(mode);		
			
			if period<first then
			open:setColor(period, Neutral);
			return;
			end
			
			
				
						if Stochastic.K[period] > Stochastic.D[period] then 	
					    open:setColor(period, Up);
						else
						open:setColor(period, Down); 
						end
	 
		
 end



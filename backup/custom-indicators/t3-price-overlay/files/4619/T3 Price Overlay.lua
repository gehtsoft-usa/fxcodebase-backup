-- More information about this indicator can be found at:
-- http://fxcodebase.com

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
    indicator:name("T3 Price Overlay");
    indicator:description("T3 Price Overlay");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	indicator.parameters:addGroup("Calculation");        			
	indicator.parameters:addString("M" , "Method for avegage", "", "T3");
	indicator.parameters:addStringAlternative("M" , "T3", "", "T3");
    indicator.parameters:addStringAlternative("M" , "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("M", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("M" , "LWMA", "", "LWMA");
	indicator.parameters:addInteger("Frame", "MA Frame", "", 14, 2, 1000); 
	indicator.parameters:addDouble("VF", "Volume Factor", "Volume Factor", 0.7, 0, 1);  

   indicator.parameters:addGroup("Style");  
   indicator.parameters:addColor("UC", "Up Color","", core.COLOR_UPCANDLE );
   indicator.parameters:addColor("DC", "Down Color","", core.COLOR_DOWNCANDLE);
   indicator.parameters:addColor("NC", "Neutral Color","", core.rgb(128, 128, 128));   
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;
local Frame=nil;
local VF=nil;

local M=nil;

local  open=nil;
local  close=nil;
local  high=nil;
local  low=nil;

local MALow;
local MAHigh;

local Flag=nil;

local UC,DC, NC;


function Prepare(nameOnly)
   
    M = instance.parameters.M;
    Frame = instance.parameters.Frame;
	VF = instance.parameters.VF;
	
	source = instance.source;	
	
	UC = instance.parameters.UC;
	DC = instance.parameters.DC;
	NC = instance.parameters.NC;
	
    local name;	
	if M ~= "T3" then
		name = profile:id() .. "(" .. source:name() ..", ".. M..", " .. Frame .. ")";
	else 
		name = profile:id() .. "(" .. source:name() ..", ".. M..", " .. Frame ..", ".. VF..")";
	end
	
	instance:name(name);
	if nameOnly then
		return;
	end
	if M ~= "T3" then
		assert(core.indicators:findIndicator(M) ~= nil, "Please, download and install ".. M .. " indicator");
		
		MALow= core.indicators:create(M, source.low,  Frame);
		MAHigh= core.indicators:create(M, source.high, Frame)
	else 
		assert(core.indicators:findIndicator("T3") ~= nil, "Please, download and install T3.lua indicator");
		assert(core.indicators:findIndicator("GD") ~= nil, "Please, download and install GD.lua indicator");
		
		MALow= core.indicators:create(M, source.low,  VF, Frame);
		MAHigh= core.indicators:create(M, source.high, VF, Frame)
	end
    first= MALow.DATA:first();
    	
	open = instance:addStream("open", core.Line, name, "", core.rgb(128, 128, 128), first);
    high = instance:addStream("high", core.Line, name, "", core.rgb(128, 128, 128), first);
    low = instance:addStream("low", core.Line, name, "", core.rgb(128, 128, 128), first);
    close = instance:addStream("close", core.Line, name, "", core.rgb(128, 128, 128), first);
    instance:createCandleGroup("OHLC", "OHLC", open, high, low, close);
	
	
		
end

-- Indicator calculation routine
function Update(period, mode)

			
			 MALow:update(mode);
			 MAHigh:update(mode);	
			 
			 
			open[period]=source.open[period];
			close[period]=source.close[period];
			high[period]=source.high[period];
			low[period]=source.low[period];		

            if period <= first then
            Flag=nil;						
			end			
			
			if period >= first+2 then	
			
						if  core.crossesOver(source.close, MAHigh.DATA, period) then 					
						Flag= "Buy"
						elseif core.crossesUnder(source.close, MALow.DATA, period)  then	
						Flag= "Sell"
						end				
						
						if Flag== "Buy" then
 			            open:setColor(period, UC);
                        elseif Flag=="Sell" then
						open:setColor(period, DC);
						else			
			            open:setColor(period, NC);
						end						
			
        	end				
 end



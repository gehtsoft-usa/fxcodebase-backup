-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2006

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  | 
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal:  https://goo.gl/9Rj74e   |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |
--|                                                      Buy Me a Coffee:  http://tiny.cc/pjh9vz   |  
--+------------------------------------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("MACD Price Overlay");
    indicator:description("MACD Price Overlay");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	indicator.parameters:addGroup("Calculation"); 
	indicator.parameters:addString("Type", "MACD / HISTOGRAM", "HISTOGRAM", "HISTOGRAM");
    indicator.parameters:addStringAlternative("Type", "Histogram", "", "HISTOGRAM");
    indicator.parameters:addStringAlternative("Type", "MACD/SIGNAL", "", "MACD");
	 indicator.parameters:addStringAlternative("Type", "MACD/ZERO", "", "ZERO");
	
    indicator.parameters:addInteger("SN", "Short EMA", "The period of the short EMA.", 12, 2, 1000);
    indicator.parameters:addInteger("LN", "Long EMA", "The period of the long EMA.", 26, 2, 1000);
    indicator.parameters:addInteger("IN", "Signal line", "The number of periods for the signal line.", 9, 2, 1000);
	
	indicator.parameters:addGroup("Style"); 
	indicator.parameters:addColor("Up" , "Up Trend Up Color","", core.rgb(0, 96, 191) );	
	indicator.parameters:addColor("UpDown" , "Up Trend Down Color","", core.rgb(0, 46, 141) );	
	indicator.parameters:addColor("Down" , "Down Trend Up Color","",  core.rgb(255, 0, 0));	
	indicator.parameters:addColor("DownDown" , "Down Trend Down Color","", core.rgb(219, 0, 0)  );	
	indicator.parameters:addColor("Neutral" , "Neutral Up Color","", core.rgb(128, 128, 128));	

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;
local TYPE=nil;

local  open=nil;
local  close=nil;
local  high=nil;
local  low=nil;

local SN;
local LN;
local IN;

local MACD = nil;

local Up,Down,Neutral;


function Prepare(nameOnly) 
    SN = instance.parameters.SN;
    LN = instance.parameters.LN;
    IN = instance.parameters.IN;
	TYPE = instance.parameters.Type;
	source = instance.source;
	
	
	Up = instance.parameters.Up;
	UpDown = instance.parameters.UpDown;
	Down = instance.parameters.Down;
	DownDown = instance.parameters.DownDown;
	Neutral = instance.parameters.Neutral;
	
	
	 local name = profile:id() .. "(" .. source:name() ..", ".. TYPE..", " .. SN .. ", " .. LN .. ", " .. IN .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
    -- Check parameters
    if (LN <= SN) then
       error("The short EMA period must be smaller than long EMA period");
    end

   
   

    MACD = core.indicators:create("MACD", source.close, SN,LN,IN); 	
	first= MACD.HISTOGRAM:first();
	
	open = instance:addStream("open", core.Line, name, "", core.rgb(0, 0, 0), first);
    high = instance:addStream("high", core.Line, name, "", core.rgb(0, 0, 0), first);
    low = instance:addStream("low", core.Line, name, "", core.rgb(0, 0, 0), first);
    close = instance:addStream("close", core.Line, name, "", core.rgb(0, 0, 0), first);
    instance:createCandleGroup("MACD", "MACD", open, high, low, close);
		
end

-- Indicator calculation routine
function Update(period, mode)

                open[period]=source.open[period];
				close[period]=source.close[period];
				high[period]=source.high[period];
				low[period]=source.low[period];	
				
    
	if period <= first then
	 open:setColor(period, Neutral);
	return;
	end
	
	   MACD:update(mode);
		  		
		if TYPE == "HISTOGRAM" then
		        if MACD.HISTOGRAM[period] > 0 then  
					if MACD.HISTOGRAM[period] > MACD.HISTOGRAM[period-1] then 	
					 open:setColor(period, Up); 
					else
					 open:setColor(period, UpDown);
					end
				else
					if MACD.HISTOGRAM[period] > MACD.HISTOGRAM[period-1] then 	
					 open:setColor(period, Down); 
					else
					 open:setColor(period, DownDown);
					end
				end
		elseif TYPE == "MACD" then
		        if MACD.MACD[period] > MACD.SIGNAL[period] then  
					if MACD.MACD[period] > MACD.MACD[period-1] then 	
					 open:setColor(period, Up); 
					else
					 open:setColor(period, UpDown);
					end
				else
					if MACD.MACD[period] > MACD.MACD[period-1] then 	
					 open:setColor(period, Down); 
					else
					 open:setColor(period, DownDown);
					end
				end	
		elseif TYPE == "ZERO" then
		
		
		        if  MACD.MACD[period] > 0 then
						if MACD.MACD[period] >  MACD.MACD[period-1] then 	
						 open:setColor(period, Up);  
						else
						  open:setColor(period, UpDown);
						end	
                else

						if MACD.MACD[period] >  MACD.MACD[period-1] then 	
						 open:setColor(period, Down);  
						else
						  open:setColor(period, DownDown);
						end		

               end				
		end
 
		
		
 end


--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
--+------------------------------------------------------------------------------------------------+
--|  Cryptocurrency  |  Network                    |  Address                                      |
--+------------------------------------------------+-----------------------------------------------+
--|  USDT            |  ERC20 (ETH Ethereum)       |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
--|  USDT            |  TRC20 (Tron)               |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
--|  USDT            |  BEP20 (BSC BNB Smart Chain)|  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--|  USDT            |  Matic Polygon              |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--|  USDT            |  SOL Solana                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
--|  USDT            |  ARBITRUM Arbitrum One      |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--+------------------------------------------------+-----------------------------------------------+
		
				
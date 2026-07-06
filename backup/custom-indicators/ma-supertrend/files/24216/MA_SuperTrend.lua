-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=12227
-- Id: 5634

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
    indicator:name("MA_SuperTrend");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	--indicator.parameters:addInteger("SSLFrame", "SSL Number of periods", "SSL The number of periods.", 2, 2, 1000);
	
	indicator.parameters:addGroup("MA Calculatin");
	
	indicator.parameters:addInteger("Period", "Averege Period", "", 20);
	indicator.parameters:addString("Method", "Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
	indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");

	
	indicator.parameters:addString("Type", "CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Type", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Type", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Type", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Type","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Type", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Type", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Type", "WEIGHTED", "", "weighted");
	
	indicator.parameters:addGroup("Super Trend Calculatin");
	indicator.parameters:addInteger("STFrame", "Super Trend Number of periods", "Super Trend Number of periods", 10);
    indicator.parameters:addDouble("Multiplier", "Super Trend Multiplier", "Super Trend Multiplier", 1.5);
	
	indicator.parameters:addBoolean("Broader", "Broader definition", "", false);
    
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UP", "Color of Up Trend", "Color of Up Trend", core.rgb(0, 255, 0));
	indicator.parameters:addColor("DOWN", "Color of Down Trend", "Color of Down Trend", core.rgb(255, 0, 0));
	indicator.parameters:addColor("NEUTRAL", "Color For Neutral", "Color of Neutral", core.rgb(255, 255, 255));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Type, Method, Period;

local first;
local source = nil;

-- Streams block
local up = nil;
local neutralup = nil;
local neutraldown = nil;
local down = nil;

--local SSLFrame=nil;
local STFrame=nil;
local Multiplier=nil;	
local Broader=nil;

local SSLFlag=nil
local STFlag=nil;
local MA, ST;

-- Routine
function Prepare(nameOnly)
    source = instance.source;
   
	 Type=instance.parameters.Type;
	 Method=instance.parameters.Method;
	 Period=instance.parameters.Period;
	
	
    STFrame=instance.parameters.STFrame;
    Multiplier=instance.parameters.Multiplier;
	
	Broader=instance.parameters.Broader;

    local name = profile:id() .. "(" .. source:name() .. ")" .. ", " ..Period.. ", " .. Method .. ", " .. STFrame .. ", ".. Multiplier;
	instance:name(name);
	if nameOnly then
		return;
	end

    assert(core.indicators:findIndicator("SUPERTREND") ~= nil, "Please, download and install SUPERTREND.LUA indicator");
	assert(core.indicators:findIndicator(Method) ~= nil, "Please, download and install "..Method..  " indicator");
	
	
	ST  = core.indicators:create("SUPERTREND", source, STFrame, Multiplier);	
	MA =core.indicators:create(Method, source[Type], Period);	
	
	 first = math.max(ST.DATA:first(), MA.DATA:first());
	
	
	if Broader then	
	up = instance:createTextOutput ("UP", "Up", "Wingdings", 20, core.H_Center, core.V_Top, instance.parameters.UP, 0);	
    down = instance:createTextOutput ("DOWN", "Down", "Wingdings", 20, core.H_Center, core.V_Bottom, instance.parameters.DOWN, 0);
	else	
	up = instance:createTextOutput ("UP", "Up", "Wingdings", 20, core.H_Center, core.V_Top, instance.parameters.UP, 0);	
    down = instance:createTextOutput ("DOWN", "Down", "Wingdings", 20, core.H_Center, core.V_Bottom, instance.parameters.DOWN, 0);	
	neutralup = instance:createTextOutput ("Neutral Up", "Neutral Up", "Wingdings", 20, core.H_Center, core.V_Top, instance.parameters.NEUTRAL, 0);	
	neutraldown = instance:createTextOutput ("Neutral Down", "Neutral Down ", "Wingdings", 20, core.H_Center, core.V_Bottom, instance.parameters.NEUTRAL, 0);    
	end
	
	
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period <  first+1 or not source:hasData(period) then
	return;
    end	

	  MA:update(mode);
	 ST:update(mode);
	
						if Broader then
						
							
							  
						
								if core.crossesOver(source.close, MA.DATA, period)   then
									SSLFlag= true;
							   elseif core.crossesUnder( source.close , MA.DATA, period)  then
									SSLFlag= false;               
								end
								
								if  ST.UP[period] > 0 then
									STFlag= true;
							   elseif ST.DN[period] > 0 then
									STFlag= false;               
								end
								
								if SSLFlag and STFlag and Flag~="Buy" then
								up:set(period, source.high[period], "\225"); 
								Flag="Buy"
								end
								
								if not SSLFlag and  not STFlag and Flag~= "Sell" then
								down:set(period, source.low[period], "\226");
								Flag="Sell";
								end
								
						
						else
						 
					
						
						
							   if core.crossesOver(source.close, MA.DATA, period) and ST.UP[period] > 0  then
									up:set(period, source.high[period], "\225"); 
							   elseif core.crossesOver(source.close, MA.DATA, period)  then
									neutralup:set(period, source.high[period], "\225"); 		
							   elseif core.crossesUnder( source.close , MA.DATA, period)  and ST.DN[period] > 0  then
									down:set(period, source.low[period], "\226");
								elseif core.crossesUnder( source.close , MA.DATA, period)   then
									neutraldown:set(period, source.low[period], "\226");
								end
						end	
						
					
			
					
   
end


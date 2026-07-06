-- Id: 19856

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65411&p=116278#p116278

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |  
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+


-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Weekly And Daily MACD");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("DailyFastLength", "Daily Fast Length", "Period", 12);   
	indicator.parameters:addInteger("DailySlowLength", "Daily Slow Length", "Period", 26);   
	indicator.parameters:addInteger("WeeklyFastLength", "Weekly Fast Length", "Period", 60);   
	indicator.parameters:addInteger("WeeklySlowLength", "Weekly Slow Lengthd", "Period", 130);   

	
	indicator.parameters:addGroup("Style");
 
    indicator.parameters:addColor("color1", "Relative Daily Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color2", "Weekly MACD Line Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;

local first;
local source = nil;

-- Streams block
local DailyFastLength, DailySlowLength, WeeklyFastLength, WeeklySlowLength; 
local WeeklyMACD,RelativeDailyLine ;
local DailyMACD;
local Show;
local Daily_MACD,Weekly_MACD;
-- Routine
function Prepare(nameOnly)   

    source = instance.source;
	
	
	DailyFastLength= instance.parameters.DailyFastLength;
	DailySlowLength= instance.parameters.DailySlowLength;
	WeeklyFastLength= instance.parameters.WeeklyFastLength;
	WeeklySlowLength= instance.parameters.WeeklySlowLength;
    

    local name = profile:id() .. "(" .. source:name() .. ", " .. DailyFastLength .. ", " .. DailySlowLength.. ", " .. WeeklyFastLength .. ", " .. WeeklySlowLength .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
   
 	 
	Daily_MACD =   core.indicators:create("MACD", source, DailyFastLength, DailySlowLength);	 
    Weekly_MACD =   core.indicators:create("MACD", source, WeeklyFastLength, WeeklySlowLength);	  
	
	first=math.max(Daily_MACD.MACD:first(),Weekly_MACD.MACD:first() );
  
	RelativeDailyLine = instance:addStream("RelativeDailyLine", core.Line, name .. ".RelativeDailyLine", "RelativeDailyLine", instance.parameters.color1, first); 
	RelativeDailyLine:setWidth(instance.parameters.width1);
    RelativeDailyLine:setStyle(instance.parameters.style1);
    WeeklyMACD = instance:addStream("WeeklyMACD", core.Line, name .. ".WeeklyMACD", "WeeklyMACD", instance.parameters.color2, first);
	WeeklyMACD:setWidth(instance.parameters.width2);
    WeeklyMACD:setStyle(instance.parameters.style2); 
	WeeklyMACD:addLevel(0);
	
	
	RelativeDailyLine:setPrecision(math.max(2, instance.source:getPrecision()));
	WeeklyMACD:setPrecision(math.max(2, instance.source:getPrecision()));
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)
   
	
	Daily_MACD:update(mode);
	Weekly_MACD:update(mode);
	
	 if period < first then
	return;
	end
 
    WeeklyMACD[period]=Weekly_MACD.MACD[period];
	RelativeDailyLine[period]=WeeklyMACD[period] + Daily_MACD.DATA[period];
	
 end

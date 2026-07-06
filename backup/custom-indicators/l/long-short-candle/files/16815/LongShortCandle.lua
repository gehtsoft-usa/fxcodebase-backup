	
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=7575

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


-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Long/Short Candle");
    indicator:description("Long/Short Candle");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("PERIOD", "Period", "Period", 10);
	indicator.parameters:addString("Type", "Body/Wick", "", "Body");
    indicator.parameters:addStringAlternative("Type", "Body", "", "Body");
    indicator.parameters:addStringAlternative("Type", "Wick", "", "Wick");
	
	indicator.parameters:addBoolean("Reversal", "Reversal Filter", "", false);
	
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up", "Color of Up Candle", "Color of Up Candle", core.COLOR_UPCANDLE );
    indicator.parameters:addColor("Down", "Color of Down Candle", "Color of Down Candle", core.COLOR_DOWNCANDLE );
	
	indicator.parameters:addBoolean("Show", "Show Overlay", "", true);
    indicator.parameters:addColor("Long", "Color of Long Candle", "Color of Long Candle", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Short", "Color of Short Candle", "Color of Short Candle", core.rgb(128, 128, 128));
	
	 indicator.parameters:addInteger("Size", "Font Size", "Font Size", 15);


end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local PERIOD;
local Reversal;
local first;
local source = nil;
local Show;
-- Streams block
local open = nil;
local close = nil;
local high = nil;
local low = nil;

 
local Long;
local Short;
local Type;
local RAW;
local Up, Down;
local font, Size;

-- Routine
 function Prepare(nameOnly)  
    
    Size= instance.parameters.Size;
	Show= instance.parameters.Show;
    Up = instance.parameters.Up;
	Reversal = instance.parameters.Reversal;
	Down = instance.parameters.Down;
    Type = instance.parameters.Type;
    PERIOD = instance.parameters.PERIOD;
    source = instance.source;
    first = source:first()+PERIOD+1; 
    Short = instance.parameters.Short;
	Long = instance.parameters.Long;
    local name = profile:id() .. "(" .. source:name() .. ", " .. PERIOD .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	RAW= instance:addInternalStream(0, 0);
	font = core.host:execute("createFont", "Wingdings", Size, true, false);
	
	open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first)
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first)
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first)
    instance:createCandleGroup("LS", "LS", open, high, low, close);
	
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
   
   
     core.host:execute ("removeLabel", source:serial(period))
    if Type == "Body" then
    RAW[period]= math.abs(source.close[period] - source.open[period]);
	else
	RAW[period]= source.high[period] - source.low[period];
	end

    if period < first or not  source:hasData(period) then	
	return;
	end
	if source.open[period]  <   source.close[period]  then
	open:setColor(period, Up);	
	elseif source.open[period]  >   source.close[period]  then
	open:setColor(period, Down);
    end	
		
	high[period]= source.high[period];
	low[period]= source.low[period];		   
	close[period] = source.close[period];
	open[period]  = source.open[period];
	
	
	
	local min, max;
	min, max =  mathex.minmax (RAW, period-PERIOD-1, period-1);

   if Reversal    
   and not ( (source.open[period]  <   source.close[period]  and source.open[period-1] >   source.close[period-1])
   or (source.open[period]  >   source.close[period]  and source.open[period-1] <   source.close[period-1]))
   then   
   return;   
   end   
   
   if RAW[period] > max 
   or  RAW[period] < min 
   then 
   
	   if source.open[period]  <   source.close[period] then
	   DrawArrow (period, true);
	   else
	   DrawArrow (period, false);
	   end
   end
	
	
	if not Show then
	return;
	end
	
	if RAW[period] > max then 
	open:setColor(period, Long);	
	
	elseif RAW[period] < min then 
	open:setColor(period, Short);			
	end	
	    
end


function DrawArrow (period, Flag)

	if Flag then
	core.host:execute("drawLabel1", source:serial(period), source:date(period), core.CR_CHART, source.low[period], core.CR_CHART, core.H_Center, core.V_Bottom,
								 font, Up, "\217");
	else							 
	core.host:execute("drawLabel1", source:serial(period),source:date(period), core.CR_CHART, source.high[period], core.CR_CHART, core.H_Center, core.V_Top,
								 font, Down, "\218");							 
	end
end

function ReleaseInstance()
       core.host:execute("deleteFont", font);
end


function AsyncOperationFinished(cookie, success, message)

end


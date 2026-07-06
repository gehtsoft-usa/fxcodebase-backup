-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61667

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
    indicator:name("MACD Signal");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
    indicator.parameters:addGroup("Calculation"); 	 
	
	indicator.parameters:addString("Price", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted");	
	
    indicator.parameters:addString("Type", "Type", "Type", "MACD/Signal");
    indicator.parameters:addStringAlternative("Type", "MACD/Signal", "MACD/Signal", "MACD/Signal");
	indicator.parameters:addStringAlternative("Type", "MACD/Zero", "MCAD/Zero", "MACD/Zero");
    indicator.parameters:addStringAlternative("Type", "Histogram/Zero", "Histogram/Zero", "Histogram/Zero");
	
    indicator.parameters:addInteger("SN", "Short EMA", "The period of the short EMA.", 12, 2, 1000);
    indicator.parameters:addInteger("LN", "Long EMA", "The period of the long EMA.", 26, 2, 1000);
    indicator.parameters:addInteger("IN", "Signal line", "The number of periods for the signal line.", 9, 2, 1000); 
 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255, 0, 0));
	 indicator.parameters:addInteger("Size", "Font Size", "", 15, 1, 1000);
	
end
-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
	local Size;
	local first;
	local source = nil;
	local Type;   
	local SN,LN,IN;
	local MACD;
	local font;
	local Price;
-- Streams block


-- Routine
function Prepare(nameOnly) 
    Size = instance.parameters.Size;
	Type= instance.parameters.Type;
    source = instance.source;
    
	SN = instance.parameters.SN;
	LN = instance.parameters.LN;
	IN = instance.parameters.IN;	
    Price= instance.parameters.Price;	
	
	
	local name = profile:id() .. "(" .. source:name()..", " .. Price .. ", " .. Type ..", " .. SN .. ", " .. LN .. ", " .. IN .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	font  = core.host:execute("createFont", "Wingdings", Size, false, false);
 
    MACD = core.indicators:create("MACD", source[Price], SN,LN,IN); 
	
	first = MACD.HISTOGRAM:first();
	
    

 end

 

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
   
   
     MACD:update(mode);
		
	if period < first then
	return;
    end	
 
    core.host:execute ("removeLabel", source:serial(period));
	
	if Type == "MACD/Signal" then
	       if MACD.MACD[period-1]<= MACD.SIGNAL[period-1] and  MACD.MACD[period] > MACD.SIGNAL[period]  then
           core.host:execute("drawLabel1", source:serial(period), source:date(period), core.CR_CHART, source.high[period], core.CR_CHART, core.H_Center,core.V_Top , font , instance.parameters.Up, "\225");
           elseif MACD.MACD[period-1]>= MACD.SIGNAL[period-1] and  MACD.MACD[period] < MACD.SIGNAL[period]  then
           core.host:execute("drawLabel1", source:serial(period), source:date(period), core.CR_CHART, source.low[period], core.CR_CHART, core.H_Center, core.V_Bottom, font , instance.parameters.Down, "\226");
           end		
	elseif Type == "MACD/Zero" then
	       if MACD.MACD[period-1]<= 0 and  MACD.MACD[period] > 0  then
           core.host:execute("drawLabel1", source:serial(period), source:date(period), core.CR_CHART, source.high[period], core.CR_CHART, core.H_Center,core.V_Top , font , instance.parameters.Up, "\225");
           elseif MACD.MACD[period-1]>= 0 and  MACD.MACD[period] < 0  then
           core.host:execute("drawLabel1", source:serial(period), source:date(period), core.CR_CHART, source.low[period], core.CR_CHART, core.H_Center, core.V_Bottom, font , instance.parameters.Down, "\226");
            end		
	else 
	      if MACD.HISTOGRAM[period-1]<= 0 and  MACD.HISTOGRAM[period] > 0  then
           core.host:execute("drawLabel1", source:serial(period), source:date(period), core.CR_CHART, source.high[period], core.CR_CHART, core.H_Center,core.V_Top , font , instance.parameters.Up, "\225");
           elseif MACD.HISTOGRAM[period-1]>= 0 and  MACD.HISTOGRAM[period] < 0  then
           core.host:execute("drawLabel1", source:serial(period), source:date(period), core.CR_CHART, source.low[period], core.CR_CHART, core.H_Center, core.V_Bottom, font , instance.parameters.Down, "\226");
           end		
	end
     
end

function ReleaseInstance()
       core.host:execute("deleteFont", font);
end
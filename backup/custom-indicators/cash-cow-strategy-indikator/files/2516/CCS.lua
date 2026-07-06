--+------------------------------------------------------------------+
--|                               Copyright © 2016, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Cash Cow Indicator ");
    indicator:description("Cash Cow Indicator ");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
	
    indicator.parameters:addInteger("Short", "Short Moving Average Period", "Short Moving Average Period", 5,2,2000);
	indicator.parameters:addInteger("Long", " Long Moving Average Period", "Long Moving Average Period", 20,2,2000);
    indicator.parameters:addDouble("Bottom", "Band Offset in percent", "Band Offset in percent", 1.2,0,100);
    indicator.parameters:addDouble("Top", "Band Offset in percent", "Band Offset in percent", 0.6,0,100);
	indicator.parameters:addBoolean("SE", "Show the Envelopes", "Show the Envelopes", false);
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addInteger("Size", "Size", "Size", 10);
	
	indicator.parameters:addColor("aUP", "UP Arrow color", "Color", core.rgb(0, 255, 0));
	indicator.parameters:addColor("aDOWN", "DOWN Arrow color", "Color", core.rgb(255, 0, 0));
	
	indicator.parameters:addColor("hColor", "High Line Color", "Color", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("lColor", "Low Line Color", "Color", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
     indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);

	indicator.parameters:addColor("cColor", "Central Line Color", "Color", core.rgb(128, 128, 128));
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
     indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local ShortFrame;
local LongFrame;
local Top;
local Bottom;
local Envelopes;
local Size;
local first;
local source = nil;

-- Streams block
local High = nil;
local Low = nil;
local Central=nil;
local ShortSMA=nil;
local LongSMA=nil;
local BUY,SELL;
local aUP,aDOWN;
local hColor, lColor,cColor;
-- Routine
function Prepare()
    ShortFrame = instance.parameters.Short;
	Envelopes = instance.parameters.SE;
	LongFrame = instance.parameters.Long;
	Size = instance.parameters.Size;
    Top = instance.parameters.Top;
    Bottom = instance.parameters.Bottom;
	aUP= instance.parameters.aUP;
	aDOWN= instance.parameters.aDOWN;
	hColor= instance.parameters.hColor;
	lColor= instance.parameters.lColor;
	cColor= instance.parameters.cColor;
    source = instance.source;

	
	ShortSMA = core.indicators:create("MVA", source.close, ShortFrame);
	LongSMA = core.indicators:create("MVA", source.close, LongFrame);
	    first = math.max(ShortSMA.DATA:first(),LongSMA.DATA:first());

    local name = profile:id() .. "(" .. source:name() .. ", " .. ShortFrame .. ", " .. LongFrame .. ", " .. Top .. ", " .. Bottom .. ")";
    instance:name(name);
	
	if Envelopes then
	High = instance:addStream("High", core.Line, name .. ".High", "",hColor, first);
	High:setWidth(instance.parameters.width1);
    High:setStyle(instance.parameters.style1);

	Central = instance:addStream("Central", core.Line, name .. ".Central", "", cColor, first);
	Central:setWidth(instance.parameters.width3);
    Central:setStyle(instance.parameters.style3);

    Low = instance:addStream("Low", core.Line, name .. ".Low", "", lColor, first);
	Low:setWidth(instance.parameters.width2);
    Low:setStyle(instance.parameters.style2);
	else
	High=instance:addInternalStream(0, 0);
	Central=instance:addInternalStream(0, 0);
	Low=instance:addInternalStream(0, 0);	
	end
	
	BUY = instance:createTextOutput ("BUY", "BUY", "Wingdings", Size, core.H_Center, core.V_Bottom, aUP, 0);
    SELL = instance:createTextOutput ("SELL", "SELL", "Wingdings", Size, core.H_Center, core.V_Top,aDOWN, 0);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)

ShortSMA:update(mode);
LongSMA:update(mode);

BUY:setNoData (period);
SELL:setNoData (period);

    if period < first  or not  source:hasData(period) then
	return;
	end
	
	local UP,DOWN;
	
	    if ShortSMA.DATA[period] >  LongSMA.DATA[period] then
		
			UP= (Top+ 100)/100;
			DOWN=  (100-Bottom)/100;
			
			High[period]=  ShortSMA.DATA[period]*UP;
			Central[period]=ShortSMA.DATA[period];
			Low[period]=  ShortSMA.DATA[period]*DOWN;
			
			if  source.high[period] <  High[period] and  source.high[period] > Central[period] and  source.close[period] < Central[period] and  source.close[period] > Low[period]then
			     if ShortSMA.DATA[period] > ShortSMA.DATA[period-1] and LongSMA.DATA[period] > LongSMA.DATA[period-1] then
			     BUY:set(period, source.low[period], "\225");
				 end
			end
		
		
		elseif ShortSMA.DATA[period] <  LongSMA.DATA[period] then
		
		   UP= (Bottom+ 100)/100;
			DOWN=  (100-Top)/100;
		    
			Low[period]=  ShortSMA.DATA[period]*UP;
			Central[period]=ShortSMA.DATA[period];
			High[period]=  ShortSMA.DATA[period]*DOWN;
			
			if  source.low[period] >  High[period] and  source.low[period] < Central[period] and  source.close[period] > Central[period] and  source.close[period] < Low[period]then
				if ShortSMA.DATA[period] < ShortSMA.DATA[period-1] and LongSMA.DATA[period] < LongSMA.DATA[period-1] then
				SELL:set(period, source.high[period], "\226");
				end
			end
			
		end
		
	 
end


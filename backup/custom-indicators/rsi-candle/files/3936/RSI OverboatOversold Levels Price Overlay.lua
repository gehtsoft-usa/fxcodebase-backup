-- Id: 1368
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1927

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("RSI Overboat/Oversold Levels Price Overlay");
    indicator:description("RSI Overboat/Oversold Levels Price Overlay");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addInteger("Frame", "RSI Period", "RSI Period", 14);
	indicator.parameters:addInteger("S", "MVA Period", "MVA Period", 3);
	
 
    indicator.parameters:addDouble("OB", "Overbought Level","", 70);
    indicator.parameters:addDouble("OS","Oversold Level","", 30);
	
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Top", "OB Zone Color","", core.rgb(0, 255, 0));
	 indicator.parameters:addColor("Central", "Central Color","", core.rgb(0, 0, 255));
	indicator.parameters:addColor("Bottom", "OS Zone Color","", core.rgb(255, 0, 0));
	
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Frame;

local first;
local source = nil;

-- Streams block
local Top=nil;
local Bottom=nil;

local RSIOpen = nil;
local RSIClose = nil; 
local OB, OS;
local RSIDifference=nil;
local PriceDifference=nil;

local MATop=nil;
local MABottom =nil;
local MACentral =nil;
local RawTop=nil;
local RawBottom=nil;
local RawCentral;
local Central;
local S=nil;

-- Routine
function Prepare(nameOnly)
    Frame = instance.parameters.Frame;
	S = instance.parameters.S;
    source = instance.source;
	
	OS = instance.parameters.OS;
	OB = instance.parameters.OB;
     
		
    local name = profile:id() .. "(" .. source:name() .. ", " .. Frame ..", "..S .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
    RSIOpen = core.indicators:create("RSI", source.open, Frame); 
	RSIClose = core.indicators:create("RSI", source.close, Frame);	
	
	RSIDifference=instance:addInternalStream(0, 0);
	PriceDifference=instance:addInternalStream(0, 0);
	
	RawTop= instance:addInternalStream(0, 0);
	RawBottom=instance:addInternalStream(0, 0);
	RawCentral=instance:addInternalStream(0, 0);
	
	MATop = core.indicators:create("MVA", RawTop, S);
	MABottom = core.indicators:create("MVA", RawBottom, S);
	MACentral= core.indicators:create("MVA", RawCentral, S);
	
	first = MATop.DATA:first() ;
	
	 Top = instance:addStream("Top", core.Line, name .. "Top", "Top", instance.parameters.Top, MATop.DATA:first());
	 Bottom = instance:addStream("Bottom", core.Line, name .. "Bottom", "Bottom",instance.parameters.Bottom,MATop.DATA:first());
	Central = instance:addStream("Central", core.Line, name .. "Central", "Central",instance.parameters.Central,MATop.DATA:first());
	 
	 Top:setWidth(instance.parameters.width);
     Top:setStyle(instance.parameters.style);
	 
	 Bottom:setWidth(instance.parameters.width);
     Bottom:setStyle(instance.parameters.style);
	 
	 Central:setWidth(instance.parameters.width);
     Central:setStyle(instance.parameters.style);
		
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)

    
	RSIOpen:update(mode);
	RSIClose:update(mode);
 

	
    if period < first or not  source:hasData(period) then
	return;
	end
	
			
		RSIDifference[period]=math.abs(RSIOpen.DATA[period]-RSIClose.DATA[period]);
		PriceDifference[period]=math.abs(source.open[period]-source.close[period]);
		RawTop[period]=source.close[period]+PriceDifference[period]*((OB-RSIClose.DATA[period])/RSIDifference[period]);
		RawBottom[period]=source.close[period]-PriceDifference[period]*((RSIClose.DATA[period]-OS)/RSIDifference[period]);
		RawCentral[period]=source.close[period]+PriceDifference[period]*((50-RSIClose.DATA[period])/RSIDifference[period]);
		
		MATop:update(mode);	
		MACentral:update(mode);
		MABottom:update(mode);
		
		if period  < MATop.DATA:first() then
		return;
		end
		
		
		Top[period]=MATop.DATA[period];
		Bottom[period]=MABottom.DATA[period]; 
		Central[period]=MACentral.DATA[period];
	   
	 
end


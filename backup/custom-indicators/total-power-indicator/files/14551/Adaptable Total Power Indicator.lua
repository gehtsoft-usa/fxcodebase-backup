-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=6307
-- Id: 10050

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Total Power Indicator");
    indicator:description("Total Power Indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

	indicator.parameters:addGroup("Calculation"); 
	indicator.parameters:addString("Price", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted");	
	
    indicator.parameters:addInteger("LB", "Lookback Period", "Lookback Period", 40);	
		indicator.parameters:addString("Method", "MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
 indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
    indicator.parameters:addInteger("PP", "Bear Power Period", "Power Period", 10);
		
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Power_color", "Color of Power", "Color of Power", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("widthPower", "Power Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("stylePower", "Power Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("stylePower", core.FLAG_LINE_STYLE);
	
	
    indicator.parameters:addColor("BearPower_color", "Color of BearPower", "Color of BearPower", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("widthBear", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleBear", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleBear", core.FLAG_LINE_STYLE);
	
	
    indicator.parameters:addColor("BullPower_color", "Color of BullPower", "Color of BullPower", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("widthBull", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleBull", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleBull", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "1. Level","", 100);
    indicator.parameters:addDouble("oversold","2. Level","", 50);
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
	
	
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local LB;
local PP;
local Method;
local first;
local source = nil;

-- Streams block
local Power = nil;
local BearPower = nil;
local BullPower = nil;
local Price;
local  Bulls,Bears;
local EMA;

-- Routine
function Prepare(nameOnly)
    LB = instance.parameters.LB;
	Method = instance.parameters.Method;
    PP = instance.parameters.PP;
	Price = instance.parameters.Price;
    source = instance.source;
	
    local name = profile:id() .. "(" .. source:name() .. ", " ..Price.. ", " .. LB .. ", " .. PP.. ", " .. Method .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	
	Bulls = instance:addInternalStream(0, 0);
	Bears = instance:addInternalStream(0, 0);
	
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
	EMA=core.indicators:create(Method, source[Price], PP);
	first = EMA.DATA:first();
    Power = instance:addStream("Power", core.Line, name .. ".Power", "Power", instance.parameters.Power_color, first+LB);
	Power:setWidth(instance.parameters.widthPower);
    Power:setStyle(instance.parameters.stylePower);
	
    BearPower = instance:addStream("BearPower", core.Line, name .. ".BearPower", "BearPower", instance.parameters.BearPower_color, first+LB);
	BearPower:setWidth(instance.parameters.widthBear);
    BearPower:setStyle(instance.parameters.styleBear);
	
    BullPower = instance:addStream("BullPower", core.Line, name .. ".BullPower", "BullPower", instance.parameters.BullPower_color, first+LB);
	BullPower:setWidth(instance.parameters.widthBull);
    BullPower:setStyle(instance.parameters.styleBull);
	
	Power:setPrecision(math.max(2, instance.source:getPrecision()));
	
	BearPower:setPrecision(math.max(2, instance.source:getPrecision()));
	BullPower:setPrecision(math.max(2, instance.source:getPrecision()));
	
	
	BullPower:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	BullPower:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

	
	
	 EMA:update(mode);
	 
	 
	      if period < first  then
	   return;
	   end
	
        Bulls[period] = source.high[period] - EMA.DATA[period];
		Bears[period] = source.low[period] - EMA.DATA[period];
		
		local BearCount=0;
		local BullCount=0;
		
       if period < first + LB  then
	   return;
	   end
	   
	   local i;
	   
	   for i=period -LB , period , 1 do
			   if Bulls[i] > 0 then
			   BullCount=BullCount+1;
			   end
			   
			   if Bears[i] < 0 then
			   BearCount=BearCount+1;
			   end
	   end
	
        Power[period] = math.abs(BearCount - BullCount)*100 / LB;
        BearPower[period] = BearCount*100/LB;
        BullPower[period] = BullCount*100/LB;
   
end


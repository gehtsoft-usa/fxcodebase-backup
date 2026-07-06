-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=6307
-- Id: 4536

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
    indicator.parameters:addInteger("LB", "Lookback Period", "Lookback Period", 40);
    indicator.parameters:addInteger("PP", "Power Period", "Power Period", 10);
	
	  indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Power_color", "Color of Power", "Color of Power", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("widthPower", "Power Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("stylePower", "Power Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("stylePower", core.FLAG_LINE_STYLE);
	
	
    indicator.parameters:addColor("BearPower_color", "Color of BearPower", "Color of BearPower", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("widthBear", "Bear Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleBear", "Bear Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleBear", core.FLAG_LINE_STYLE);
	
	
    indicator.parameters:addColor("BullPower_color", "Color of BullPower", "Color of BullPower", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("widthBull", "Bear Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleBull", "Bear Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleBull", core.FLAG_LINE_STYLE);
	
	
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local LB;
local PP;

local first;
local source = nil;

-- Streams block
local Power = nil;
local BearPower = nil;
local BullPower = nil;

local  Bulls,Bears;
local EMA;

-- Routine
function Prepare(nameOnly)
    LB = instance.parameters.LB;
    PP = instance.parameters.PP;
    source = instance.source;
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. LB .. ", " .. PP .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	Bulls = instance:addInternalStream(0, 0);
	Bears = instance:addInternalStream(0, 0);
	
	EMA=core.indicators:create("EMA", source.close, PP);
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
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

	
	
	 EMA:update(mode);
	 
	 
	   if period < EMA.DATA:first()  then
	   return;
	   end
	
        Bulls[period] = source.high[period] - EMA.DATA[period];
		Bears[period] = source.low[period] - EMA.DATA[period];
		
		local BearCount=0;
		local BullCount=0;
		
       if period < EMA.DATA:first()+LB  then
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


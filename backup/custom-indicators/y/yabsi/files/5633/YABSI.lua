-- Id: 2122
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2543

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
    indicator:name("YABSI");
    indicator:description("YABSI");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UP", "Color of Up Arrow", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("DOWN", "Color of Bottom Arrow", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Typical", "Color of Typical Line", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width", "Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	indicator.parameters:addBoolean("Show", "Show Typical", "", false);
	
	 indicator.parameters:addInteger("Size", "Font Size", "", 10);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local first;
local source = nil;

-- Streams block
local down = nil;
local up= nil;
local Typical;
local Show;
local Size;
-- Routine
function Prepare(nameOnly)
    Show=instance.parameters.Show;
    source = instance.source;
    first = source:first();
	
	Size=instance.parameters.Size;
  
	local name = profile:id() .. "(" .. source:name() .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	
	down = instance:createTextOutput ("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.UP, 0);
    up = instance:createTextOutput ("Down", "Down", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.DOWN, 0);
	
	if Show then
	Typical = instance:addStream("Typical", core.Line, name, "Typical", instance.parameters.Typical, source:first())
    Typical:setWidth(instance.parameters.width);
    Typical:setStyle(instance.parameters.style);
	end
	
end

local  triggerSell=false;
local  triggerBuy=false;
local buySellSwitch=nil;

 
-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)

	down:setNoData (period);
	up:setNoData (period);
	
    if period >= first and source:hasData(period) then	 
	 
	  if Show then
	  Typical[period]= source.typical[period];
	  end
 
      triggerSell=false;
	  triggerBuy=false;	
	
	  if source.close[period-1] < source.high[period] and source.typical[period-2] <  source.close[period-1] or source.typical[period-3] < source.close[period-1]  then
	  triggerSell=true;
	  triggerBuy=false;
	  end
	  
	  if source.close[period-1] > source.high[period] and source.typical[period-2] >  source.close[period-1] or source.typical[period-3] > source.close[period-1] then
	  triggerBuy=true;
	  triggerSell=false;
	  end  
     
	 if triggerBuy and not buySellSwitch then
	 up:set(period, source.high[period], "\108");
	 buySellSwitch=true; 
	 elseif triggerSell and buySellSwitch then
	 down:set(period, source.low[period], "\108");
	 buySellSwitch=false;
	 end
	
    end
end


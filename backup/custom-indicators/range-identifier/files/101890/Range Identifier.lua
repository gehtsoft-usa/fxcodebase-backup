-- Id: 14691
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62555

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
    indicator:name("Range Identifier");
    indicator:description("Range Identifier");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	
	indicator.parameters:addGroup("Selector");
	indicator.parameters:addBoolean("connectRanges", "Connect Ranges", "", false);
	indicator.parameters:addBoolean("showMidLine", "Show MidLine", "", true);
	indicator.parameters:addBoolean("showEMA", "Show EMA", "", true);
	indicator.parameters:addBoolean("hc", "Highlight Consolidation", "", true);

	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("lengthEMA", "EMA Period", "EMA Period", 34);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("ema_color", "Color of ema", "Color of ema", core.rgb(255, 0, 0));
    indicator.parameters:addColor("mid_color", "Color of mid", "Color of mid", core.rgb(255, 0, 0));
	

	 indicator.parameters:addColor("Up", "Channel color Up", "", core.rgb(0, 255, 0));
	 indicator.parameters:addColor("Down", "Channel color Down", "", core.rgb(255, 0, 0));
     indicator.parameters:addInteger("transparency", "Channel transparency (%)", "", 70, 0, 100);

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local lengthEMA;
local connectRanges,showMidLine,showEMA,hc;
local first;
local source = nil;

-- Streams block
local ema = nil;
local mid = nil;
local EMA;
local up,down;
local hh,ll;
-- Routine
function Prepare(nameOnly)
    lengthEMA = instance.parameters.lengthEMA;
	connectRanges = instance.parameters.connectRanges;
	showMidLine = instance.parameters.showMidLine;
	showEMA = instance.parameters.showEMA;
	hc = instance.parameters.hc;
    source = instance.source;
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(lengthEMA) .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	EMA = core.indicators:create("EMA", source.close, lengthEMA);
	
    first = math.max(EMA.DATA:first());

	
	up= instance:addInternalStream(first, 0);
	down= instance:addInternalStream(first, 0);
	
	hh = instance:addStream("hh", core.Line, name .. ".hh", "hh", core.rgb(128, 128,128), first);
	ll = instance:addStream("ll", core.Line, name .. ".ll", "ll", core.rgb(128, 128,128), first);
	instance:createChannelGroup("ch", "ch", hh, ll, core.rgb(128, 128,128), 100 - instance.parameters.transparency);


    if (not (nameOnly)) then
	    if showEMA then
        ema = instance:addStream("ema", core.Line, name .. ".ema", "ema", instance.parameters.ema_color, first);
		else
		ema= instance:addInternalStream(first, 0);
		end
		
		if showMidLine then
        mid = instance:addStream("mid", core.Line, name .. ".mid", "mid", instance.parameters.mid_color, first);
		else
		mid= instance:addInternalStream(first, 0);
		end
		
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)

    EMA:update(mode);
	
    if period < first or  not source:hasData(period) then
	return;
	end
	if source.close[period]< up[period-1] and source.close[period]>down[period-1] then
	up[period]=up[period-1];
	else
	up[period]=source.high[period];
	end
	
	
	if source.close[period]< up[period-1] and source.close[period]>down[period-1] then
	down[period]=down[period-1];
	else
	down[period]=source.low[period];
	end
	
	
	mid[period] = (up[period]+down[period])/2;	
    ema[period] = EMA.DATA[period];
  
  
    hh[period]= up[period];
   ll[period]= down[period];
   
    hh:setBreak (period, false);
	ll:setBreak (period, false);
   
      if not  connectRanges then   
   
			   if hh[period]~=hh[period-1] or ll[period]~=ll[period-1] then
		       hh:setBreak (period, true);
			   ll:setBreak (period, true);
			   end			    
	   end
	   
	   if hc then
	   
		   if source.close[period]> ema[period] then
		   hh:setColor(period, instance.parameters.Up);
		   else
		   hh:setColor(period, instance.parameters.Down);
		   end
      end
   
  
   
end
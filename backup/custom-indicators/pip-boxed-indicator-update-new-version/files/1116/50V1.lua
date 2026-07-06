-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=628

--+------------------------------------------------------------------+
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Pip Boxed");
    indicator:description("Pip Boxed Trading");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator:setTag("group", "Custom");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "Pips", "How many Pips in the Box", 50, 2, 1000);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("L1_color", "Color of Line High", "Color of Line High", core.rgb(0, 255, 0));
    indicator.parameters:addColor("L2_color", "Color of Line Low", "Color of Line Low", core.rgb(255, 0, 0));

    indicator.parameters:addColor("clrCloud1", "Color UP Box", "Color UP Box", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clrCloud2", "Color Down Box", "Color Down Box", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("transp", "Trans Cloud", "Trans Cloud", 80, 0, 100);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local L1;
local L2;
local L3;
local L4;
local N;

local first;
local source = nil;
local start = 0;
-- Streams block
local point ;
local openTime=1;
-- Routine
function Prepare(nameOnly)
    N = instance.parameters.N;
    source = instance.source;
    first = source:first();
    point = source:pipSize();
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
 
    L1 = instance:addStream("L1", core.Dot, name, "L1", instance.parameters.L1_color, first);
    L2 = instance:addStream("L2", core.Dot, name, "L2", instance.parameters.L2_color, first);
    L3 = instance:addStream("L3", core.Dot, name, "L3", instance.parameters.L1_color, first);
    L4 = instance:addStream("L4", core.Dot, name, "L4", instance.parameters.L2_color, first);

    instance:createChannelGroup("L1-L2", "L1-L2", L1, L2, instance.parameters.clrCloud1, 100 - instance.parameters.transp);
    instance:createChannelGroup("L3-L4", "L3-L4", L3, L4, instance.parameters.clrCloud2, 100 - instance.parameters.transp);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    
    if period == 1 then
        start = firstStart(period);
    end
    if period > 1 and source:hasData(period) then
        if (source.high[period] - start >= N*point and start ~= 0) or (start - source.low[period] >= N*point and start ~= 0 ) then
            if source.high[period] - start >= N*point  and start ~= 0 and openTime ~= period then
                core.drawLine(L1,core.range(openTime,period),start+N*point,openTime,start+N*point,period)
                core.drawLine(L2,core.range(openTime,period),start,openTime,start,period)
              
                start = start+N*point;
                openTime = period;
            end

            if start - source.low[period] >= N*point and start ~= 0 and openTime ~= period then
                core.drawLine(L4,core.range(openTime,period),start-N*point,openTime,start-N*point,period)
                core.drawLine(L3,core.range(openTime,period),start,openTime,start,period)
               
                start = start-N*point;
                openTime = period;
            end

       
        end  

    end
end

function firstStart(p)
  local condition= true;
  local i=0;
  
	  while condition do
	  i=i+N*point;
		   
		   if  i >= source.high[p] then		   
		   condition=false;		  	   
		   end
	  
	  end  
	  
	  openTime = p;
	   return i;	
end
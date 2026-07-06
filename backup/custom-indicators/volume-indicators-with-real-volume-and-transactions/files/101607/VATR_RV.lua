
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62412

--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
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
function Init()
    indicator:name("ATR with Volume indicator with Real volume/Transactions");
    indicator:description("ATR with Volume indicator with Real volume/Transactions");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("Ind", "Type of indicator", "", "Volume");
    indicator.parameters:addStringAlternative("Ind", "Volume", "", "Volume");
    indicator.parameters:addStringAlternative("Ind", "Transactions", "", "Transactions");
    indicator.parameters:addInteger("N", "Period", "Period", 14, 1, 1000);
    indicator.parameters:addBoolean("UseVolume", "Use volume", "Use volume", true);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addString("Type", "Type of ATR", "", "Histogram");
    indicator.parameters:addStringAlternative("Type", "Line", "", "Line");
    indicator.parameters:addStringAlternative("Type", "Histogram", "", "Histogram");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local n;
local UseVolume;

local first;
local source = nil;
local tr = nil;
local trFirst = nil;
local tAbs = math.abs;

-- Streams block
local ATR = nil;
local Ind;

local FirstStart;
local LastTime;

-- Routine
function Prepare(nameOnly)
    n = instance.parameters.N;
    UseVolume = instance.parameters.UseVolume;
    source = instance.source;
	
	
	local name = profile:id() .. "(" .. source:name() .. ", " .. n .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
    if UseVolume then
     if instance.parameters.Ind=="Volume" then
      Ind=core.indicators:create("REAL VOLUME", source);
     else
      Ind=core.indicators:create("TRANSACTIONS", source);
     end
    end 
     FirstStart=true;
     LastTime=0;

    
	
	
    tr = instance:addInternalStream(source:first() + 1, 0);
    first = tr:first() + n;
    if instance.parameters.Type=="Line" then
     ATR = instance:addStream("ATR", core.Line, name, "ATR", instance.parameters.clr, first)
     ATR:setWidth(instance.parameters.widthLinReg);
     ATR:setStyle(instance.parameters.styleLinReg);
    else
     ATR = instance:addStream("ATR", core.Bar, name, "ATR", instance.parameters.clr, first)
    end 
    local precision = math.max(2, source:getPrecision());
    ATR:setPrecision(precision);
    trFirst = tr:first();
end

function AsyncOperationFinished(cookie, success, message)

end

function getTrueRange(period)
    local hl = tAbs(source.high[period] - source.low[period]);
    local hc = tAbs(source.high[period] - source.close[period - 1]);
    local lc = tAbs(source.low[period] - source.close[period - 1]);

    local tr = hl;
    if (tr < hc) then
        tr = hc;
    end
    if (tr < lc) then
        tr = lc;
    end
    return tr;
end

-- Indicator calculation routine
function Update(period, mode)
    if period >= trFirst then
      if UseVolume then
        Ind:update(mode);
        if not(Ind.DATA:hasData(period)) then
            if period==trFirst then
                FirstStart=true;
            end    
            return;
        elseif FirstStart then
            FirstStart=false;
            instance:updateFrom(first);    
        elseif LastTime~=source:date(period) and period==source:size()-1 then
            LastTime=source:date(period);
            instance:updateFrom(period-10);
        end
        tr[period] = getTrueRange(period)*Ind.DATA[period];
      else
        tr[period] = getTrueRange(period);
      end  
    end
    if period >= first then
        ATR[period] = mathex.avg(tr, period - n + 1, period);
    end
end





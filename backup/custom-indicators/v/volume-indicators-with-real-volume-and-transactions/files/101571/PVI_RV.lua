-- Id: 14538

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

function Init()
    indicator:name("Positive Volume Index with Real volume/Transactions");
    indicator:description("Positive Volume Index with Real volume/Transactions");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("Ind", "Type of indicator", "", "Volume");
    indicator.parameters:addStringAlternative("Ind", "Volume", "", "Volume");
    indicator.parameters:addStringAlternative("Ind", "Transactions", "", "Transactions");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local PVI=nil;
local Ind;

local FirstStart;
local LastTime;

function Prepare(nameOnly)
    source = instance.source;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	 
	if   (nameOnly) then
        return;
    end
	
	
     if instance.parameters.Ind=="Volume" then
      Ind=core.indicators:create("REAL VOLUME", source);
     else
      Ind=core.indicators:create("TRANSACTIONS", source);
     end
     FirstStart=true;
     LastTime=0;
    PVI = instance:addStream("PVI", core.Line, name .. ".PVI", "PVI", instance.parameters.clr, first);
    PVI:setPrecision(math.max(2, instance.source:getPrecision()));
    PVI:setWidth(instance.parameters.widthLinReg);
    PVI:setStyle(instance.parameters.styleLinReg);
end

function AsyncOperationFinished(cookie, success, message)

end

function Update(period, mode)
   if (period>first) then
        Ind:update(mode);
        PVI[period]=1;
        if not(Ind.DATA:hasData(period)) then
            if period==first+1 then
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
    if Ind.DATA[period]>Ind.DATA[period-1] then
     PVI[period]=PVI[period-1]*(1+((source.close[period]-source.close[period-1])/source.close[period-1]));
    else
     PVI[period]=PVI[period-1];
    end
   elseif period==first then
    PVI[period]=1;
   end 
end


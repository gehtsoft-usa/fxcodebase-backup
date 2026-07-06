-- Id: 14522

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
    indicator:name("OHLC Volume indicator with Real volume/Transactions");
    indicator:description("OHLC Volume indicator with Real volume/Transactions");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("Ind", "Type of indicator", "", "Volume");
    indicator.parameters:addStringAlternative("Ind", "Volume", "", "Volume");
    indicator.parameters:addStringAlternative("Ind", "Transactions", "", "Transactions");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrUP", "Color UP", "Color UP", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clrDN", "Color DN", "Color DN", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("width", "width", "width", 1, 1, 5);
    indicator.parameters:addInteger("style", "style", "style", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);
end

local first;
local source = nil;
local BuffUP=nil;
local BuffDN=nil;
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
    BuffUP = instance:addStream("BuffUP", core.Line, name .. ".UP volume", "UP volume", instance.parameters.clrUP, first);
    BuffUP:setPrecision(math.max(2, instance.source:getPrecision()));
    BuffDN = instance:addStream("BuffDN", core.Line, name .. ".DN volume", "DN volume", instance.parameters.clrDN, first);
    BuffDN:setPrecision(math.max(2, instance.source:getPrecision()));
    BuffUP:setWidth(instance.parameters.width);
    BuffUP:setStyle(instance.parameters.style);
    BuffDN:setWidth(instance.parameters.width);
    BuffDN:setStyle(instance.parameters.style);
end

function Update(period, mode)
   if (period>first) then
        Ind:update(mode);
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
    local UPcoeff=source.high[period]-source.open[period];
    local DNcoeff=source.close[period]-source.low[period];
    BuffUP[period]=Ind.DATA[period]*UPcoeff/(UPcoeff+DNcoeff);
    BuffDN[period]=Ind.DATA[period]*DNcoeff/(UPcoeff+DNcoeff);
   end 
end

function AsyncOperationFinished(cookie, success, message)

end

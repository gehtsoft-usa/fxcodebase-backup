
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
    indicator:name("Money Flow Index with Real volume/Transactions");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Volume Indicators");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("Ind", "Type of indicator", "", "Volume");
    indicator.parameters:addStringAlternative("Ind", "Volume", "", "Volume");
    indicator.parameters:addStringAlternative("Ind", "Transactions", "", "Transactions");
    indicator.parameters:addInteger("N", "Periods", "", 14, 1, 1000);
    indicator.parameters:addInteger("Center", "Center line position", "", 50, 0, 100);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrMFI", "Indicator Line Color", "", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("widthMFI", "Indicator Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleMFI", "Indicator Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleMFI", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("clrCenter", "Center Line Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("widthCenter", "Center Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleCenter", "Center Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleCenter", core.FLAG_LINE_STYLE);
end

local source;
local N;
local first;
local first1;
local MFI;
local Prev;
local POS, NEG;
local Ind;

local FirstStart;
local LastTime;

function Prepare(nameOnly)
    source = instance.source;
    N = instance.parameters.N;
    first = source:first() + N + 1;
    first1 = source:first() + 1;
    Prev = instance.parameters.Prev;

    assert(source:supportsVolume(), "The source must have volume");

    name = profile:id() .. "(" .. source:name() .. "," .. N .. ")";
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

    POS = instance:addInternalStream(0, 0);
    NEG = instance:addInternalStream(0, 0);
    MFI = instance:addStream("MFI", core.Line, name, "MFI", instance.parameters.clrMFI, first);
    MFI:setPrecision(2);
    MFI:setWidth(instance.parameters.widthMFI);
    MFI:setStyle(instance.parameters.styleMFI);
    MFI:addLevel(100);
    MFI:addLevel(80);
    MFI:addLevel(20);
    MFI:addLevel(0);
    MFI:addLevel(instance.parameters.Center,instance.parameters.styleCenter,instance.parameters.widthCenter,instance.parameters.clrCenter);
end

function Update(period, mode)
    POS[period] = 0;
    NEG[period] = 0;

    if period >= first1 then
        Ind:update(mode);
        if not(Ind.DATA:hasData(period)) then
            if period==first1 then
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
        if source.typical[period] > source.typical[period - 1] then
            POS[period] = source.typical[period] * Ind.DATA[period];
        elseif source.typical[period] < source.typical[period - 1] then
            NEG[period] = source.typical[period] * Ind.DATA[period];
        end
    end

    if period >= first then
        local range, a, b, r;
        range = core.rangeTo(period, N);
        a = core.sum(POS, range);
        b = core.sum(NEG, range);
        if b ~= 0 then
            r = a / b;
        else
            r = 0;
        end
        MFI[period] = 100 - (100 / (1 + r));
    end
end

function AsyncOperationFinished(cookie, success, message)

end

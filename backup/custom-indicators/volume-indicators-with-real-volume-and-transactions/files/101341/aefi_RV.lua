
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
    indicator:name("Force Index");
    indicator:description("Dr. Alexander Elder's Force Index. The indicator combines price movements and volume to measure the strength of bulls and bears in the market.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Volume Indicators");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("Ind", "Type of indicator", "", "Volume");
    indicator.parameters:addStringAlternative("Ind", "Volume", "", "Volume");
    indicator.parameters:addStringAlternative("Ind", "Transactions", "", "Transactions");
    indicator.parameters:addBoolean("SM", "Smooth", "Choose false to see the RAW Force Index value", true);
    indicator.parameters:addInteger("N", "Smoothing Periods", "", 13, 1, 1000);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrFI", "Indicator Line Color", "", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("widthFI", "Indicator Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleFI", "Indicator Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleFI", core.FLAG_LINE_STYLE);
end

local source;
local first;
local first1;
local RawFI;
local FI;
local EMA;
local SM;
local Ind;

local FirstStart;
local LastTime;

 function Prepare(nameOnly)   
  
    source = instance.source;
    first1 = source:first() + 1;
    SM = instance.parameters.SM;

    assert(source:supportsVolume(), "The source must have volume");

    local name;
    name = profile:id() .. "(" .. source:name() .. "," ;
    if SM then
        name = name .. "EMA(" .. instance.parameters.N .. "))";
    else
        name = name .. "RAW)";
    end
    instance:name(name);
	
	 if   (nameOnly) then
        return;
    end

     if instance.parameters.Ind=="Volume" then
      Ind=core.indicators:create("REAL VOLUME", source);
     else
      Ind=core.indicators:create("TRANSACTIONS", source);
     end

    RawFI = instance:addInternalStream(first1, 0);
    if SM then
        EMA = core.indicators:create("EMA", RawFI, instance.parameters.N);
        first = EMA.DATA:first();
    else
        first = first1;
    end

    FI = instance:addStream("FI", core.Line, name, "FI", instance.parameters.clrFI, first);
    FI:setPrecision(0);
    FI:setWidth(instance.parameters.widthFI);
    FI:setStyle(instance.parameters.styleFI);
    FI:addLevel(0);
    FirstStart=true;
    LastTime=0;
end

function Update(period, mode)
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
            instance:updateFrom(period-2);
        end
        RawFI[period] = (source.close[period] - source.close[period - 1]) * Ind.DATA[period];
    end

    if period >= first then
        if SM then
            EMA:update(mode);
            FI[period] = EMA.DATA[period];
        else
            FI[period] = RawFI[period];
        end
    end
end

function AsyncOperationFinished(cookie, success, message)

end



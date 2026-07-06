
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
    indicator:name("On Balance Volume modified with Real volume/Transactions");
    indicator:description("Displays volume as a histogram with Real volume/Transactions");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Volume Indicators");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("Ind", "Type of indicator", "", "Volume");
    indicator.parameters:addStringAlternative("Ind", "Volume", "", "Volume");
    indicator.parameters:addStringAlternative("Ind", "Transactions", "", "Transactions");
    indicator.parameters:addDouble("Gate", "Gate, in pips", "", 2);

    indicator.parameters:addColor("clrV", "Indicator Color", "", core.rgb(65, 105, 225));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local source;
local close;
local volume;
local first;
local V;
local GatePips;
local Ind;

local FirstStart;
local LastTime;

function Prepare(nameOnly)
    source = instance.source;

    assert(instance.source:supportsVolume(), "The source must have volume");

    close = instance.source.close;
    first = instance.source:first();


    local name;
    name = profile:id() .. "(" .. instance.source:name() .. ", " .. instance.parameters.Gate .. ")";
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

    V = instance:addStream("OBV", core.Line, name, "OBV", instance.parameters.clrV, first);
    V:setWidth(instance.parameters.widthLinReg);
    V:setStyle(instance.parameters.styleLinReg);
    V:setPrecision(0);
    GatePips=instance.parameters.Gate*source:pipSize();
end

function Update(period, mode)
    if period == first then
        V[period] = 0;
    elseif period > first then
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

        if close[period] > close[period - 1]+GatePips then
            V[period] = V[period - 1] + Ind.DATA[period];
        elseif close[period] < close[period - 1]-GatePips then
            V[period] = V[period - 1] - Ind.DATA[period];
        else
            V[period] = V[period - 1];
        end
    end
end

function AsyncOperationFinished(cookie, success, message)

end

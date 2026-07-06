--http://fxcodebase.com/code/viewtopic.php?f=17&t=60537

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

function Init()
    indicator:name("Custom Time Frame Candle View");
    indicator:description("A chart will add a new Candle After passing of Set Number of Base Time Frame elements.");
    indicator:requiredSource(core.Tick);
    indicator:type(core.View);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("Instrument","Instrument","", "EUR/USD");
    indicator.parameters:setFlag("Instrument", core.FLAG_INSTRUMENTS);
    
    indicator.parameters:addString("TF", "Base Time Frame", "Base Time Frame" , "m1");
    indicator.parameters:addStringAlternative("TF", "m1", "m1" , "m1");
    indicator.parameters:addStringAlternative("TF", "H1", "H1" , "H1");
    indicator.parameters:addStringAlternative("TF", "D1", "D1" , "D1");
    indicator.parameters:addStringAlternative("TF", "W1", "W1" , "W1");
    indicator.parameters:addStringAlternative("TF", "M1", "M1" , "M1");
    
    indicator.parameters:addInteger("Step_1","Number Of Elements (1)","", 1);
    indicator.parameters:addInteger("count_1","Number Of Bars (1)","", 1);
    indicator.parameters:addInteger("Step_2","Number Of Elements (2)","", 1);
    indicator.parameters:addInteger("count_2","Number Of Bars (2)","", 1);
    indicator.parameters:addInteger("Step_3","Number Of Elements (3)","", 1);
    indicator.parameters:addInteger("count_3","Number Of Bars (3)","", 1);
    
    indicator.parameters:addBoolean("type", "Price Type","", true);
    indicator.parameters:setFlag("type", core.FLAG_BIDASK);

    indicator.parameters:addGroup("Range");
    indicator.parameters:addDate("to", "To","", 0);
    indicator.parameters:setFlag("to", core.FLAG_DATE_OR_NULL);
end
local Last;
local loading;
local History;
local open, high, low, close, volume;
local offer;
local offset;
local LastTime;
local Instrument;
local Count;
local FIRST;
local Step_1;
local Step_2;
local Step_3;
local count_1;
local count_2;
local count_3;
local LastS;
local TF;
local Old;
local counter = {};

function CreateBarCounter()
    local Step = {};
    Step.Steps = Step_1;
    Step.Count = count_1;
    counter[#counter + 1] = Step;
    Step = {};
    Step.Steps = Step_2;
    Step.Count = count_2;
    counter[#counter + 1] = Step;
    Step = {};
    Step.Steps = Step_3;
    Step.Count = count_3;
    counter[#counter + 1] = Step;
end

-- initializes the instance of the indicator
function Prepare(onlyName)
    FIRST=true;
    Step_1 = instance.parameters.Step_1;
    Step_2 = instance.parameters.Step_2;
    Step_3 = instance.parameters.Step_3;
    count_1 = instance.parameters.count_1;
    count_2 = instance.parameters.count_2;
    count_3 = instance.parameters.count_3;
    TF = instance.parameters.TF;
    Instrument = instance.parameters.Instrument;

    local name = string.format("%s, %s, %sx%d(%d)+%d(%d)+%d(%d)", profile:id(), Instrument, TF, Step_1, count_1, Step_2, count_2, Step_3, count_3);
    instance:name(name);

    if onlyName then
        return ;
    end
    CreateBarCounter();

    -- check whether the instrument is available
    local offers = core.host:findTable("offers");
    local enum = offers:enumerator();
    local row = enum:next();
    while row ~= nil do
        if row.Instrument == Instrument then
            break;
        end
        row = enum:next();
    end

    assert(row ~= nil, "Selected instrument is not available");
    offer = row.OfferID;

    instance:initView(Instrument, row.Digits, row.PointSize, true, true);

    count = Step_1 * count_1 + Step_2 * count_2 + Step_3 * count_3;
    History = core.host:execute("getHistory1", 1000, Instrument, TF, count, instance.parameters.to, instance.parameters.type);
    loading = true;
    
    if instance.parameters.to == 0 then 
        core.host:execute("subscribeTradeEvents", 2000, "offers");  
    end
    core.host:execute("setStatus", "Loading");

    open = instance:addStream("open", core.Line, name .. "." .. "Open", "open", 0, 0, 0);
    high = instance:addStream("high", core.Line, name .. "." .. "High", "high", 0, 0, 0);
    low = instance:addStream("low", core.Line, name .. "." .. "Low", "low", 0, 0, 0);
    close = instance:addStream("close", core.Line, name .. "." .. "Close", "close", 0, 0, 0);
    volume = instance:addStream("volume", core.Line, name .. "." .. "Volume", "Volume", 0, 0, 0);

    instance:createCandleGroup("candle", "candle", open, high, low, close, volume , TF);
end

function Update(period)
end

function AsyncOperationFinished(cookie, success, message)
    if cookie == 1000 then
        handleHistory(); 
        core.host:execute("setStatus", "");
    elseif cookie == 2000 then
        loading = false;
        handleUpdate()
    end
end

local lastDirection;

function GetSteps()
    if (#counter == 0) then
        return Step_3;
    end
    return counter[1].Steps;
end

function OnBarAdded()
    if (#counter == 0) then
        return;
    end
    if (counter[1].Count == 1) then
        table.remove(counter, 1);
        if (#counter == 0) then
            return;
        end
    end
    counter[1].Count = counter[1].Count - 1;
end

function calcValue(Index, period)
    if period < History:first() then
        return;
    end

    if period == 1 then
        instance:addViewBar(History:date(1));
        OnBarAdded();
        Index=Index+1;
        Count=1;
        open[Index] = History.open[period];  
        low[Index] = History.low[period]; 
        close[Index]=History.close[period]; 
        high[Index] = History.high[period]; 
    else 
        if Last ~= History:date(period) then
            Count = Count+1;
        end
        
        local step = GetSteps();
        if Count > step then
            Index = Index+1;
            Count = 1;
            instance:addViewBar(History:date(period));
            OnBarAdded();
            
            open[Index] = History.open[period];  
            low[Index] =  History.low[period];   
            close[Index]= History.close[period];  
            high[Index] = History.high[period];  
            volume[Index] = History.volume[period]; 
            Old=  History.volume[period]; 
        else
            
            close[Index]=History.close[period];     
            low[Index] = math.min(low[Index], History.low[period]); 
            high[Index]  = math.max(high[Index], History.high[period]); 
            
            if  Last ~= History:date(period) then
                Old = volume[Index]+History.volume[period];
                volume[Index] = Old ;
            else
                volume[Index] = Old + History.volume[period]; 
            end
        end 
        
        if Last ~= History:date(period) then
            Last = History:date(period);
        end
    end
   
    return Index; 
end

function handleHistory()
    local s = History:size() - 1;
    local i;
    local current = open:size() - 1;
    for i = 1, s, 1 do
        current = calcValue(current, i);
    end
    loading = false;
    LastTime=History:size()-1;
end

function handleUpdate()
    local current = open:size() - 1;    
    local i;           
    for i =   LastTime, History:size()-1, 1 do
        current = calcValue( current  ,i);
    end          
    LastTime=History:size()-1;    
end
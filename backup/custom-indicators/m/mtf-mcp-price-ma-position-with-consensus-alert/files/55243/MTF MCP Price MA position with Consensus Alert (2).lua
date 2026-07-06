-- Id: 8571
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=32425

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
--|                                Patreon :  https://goo.gl/GdXWeN  |  
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

function Init()
    indicator:name("MTF MCP Price / MA position with Consensus Alert");
    indicator:description("MTF MCP Price / MA position with Consensus Alert");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
     
    indicator.parameters:addGroup("Common Parameters");    
    indicator.parameters:addString("Type", "Currency pair Selector", "Currency pair Selector", "Multiple currency pair");
    indicator.parameters:addStringAlternative("Type", "Chart", "Chart", "Chart");
    indicator.parameters:addStringAlternative("Type", "Multiple currency pair", "Multiple currency pair", "Multiple currency pair");
    indicator.parameters:addStringAlternative("Type", "All currency pair", "All currency pair", "All currency pair");
    
    indicator.parameters:addGroup("Currency Pair Selector");    
    
    AddCurrencyPair(1, "EUR/USD", true);
    AddCurrencyPair(2, "USD/JPY", true);
    AddCurrencyPair(3, "GBP/USD", true);
    AddCurrencyPair(4, "USD/CHF", true);
    AddCurrencyPair(5, "EUR/CHF", true);
    AddCurrencyPair(6, "AUD/USD", true);
    AddCurrencyPair(7, "USD/CAD", true);
    AddCurrencyPair(8, "NZD/USD", true);
    AddCurrencyPair(9, "EUR/GBP", true);
    AddCurrencyPair(10, "EUR/JPY", true);

    indicator.parameters:addGroup("Time Frame Selector");    
    AddTimeFrame(1, "m30", true);
    AddTimeFrame(2, "H1", true);
    AddTimeFrame(3, "H4", true);
    AddTimeFrame(4, "H8", false);
    AddTimeFrame(5, "D1", false);
    
    indicator.parameters:addInteger("Size", "Font Size", "", 15);
    indicator.parameters:addInteger("RESET", "Number of Rows", "", 10);
    indicator.parameters:addInteger("Shift", "Vertical Shift", "", 0, 0, 10000);
    indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0));
    indicator.parameters:addColor("Up1", "Up Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Down1", "Down Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("No1", "Neutral Color", "", core.rgb(0, 0, 255));
    
    --Up
    indicator.parameters:addGroup("Alerts Sound");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", false);    
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);
    
    indicator.parameters:addGroup("Alerts Email");   
    indicator.parameters:addBoolean("SendEmail", "Send Email", "", false);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);
    
    ParametersAlert(1, "Pozitiv")
    ParametersAlert(2, "Negativ")
end

function AddCurrencyPair(id, Pair, Flag)
    indicator.parameters:addBoolean("Dodaj" .. id, "Show " .. Pair, "", Flag);
    indicator.parameters:addString("Pair" .. id, id .. ". Currency Pair", "", Pair);
	indicator.parameters:setFlag("Pair" .. id, core.FLAG_INSTRUMENTS);
end

function ParametersAlert(id, Label, Flag)
    indicator.parameters:addGroup(Label .. " Alert");
  
    indicator.parameters:addBoolean("ON" .. id, "Show " .. Label .. " Alert", "", false);
    
    indicator.parameters:addFile("Sound" .. id, Label .. " Consensus Sound", "", "");
    indicator.parameters:setFlag("Sound" .. id, core.FLAG_SOUND);

    indicator.parameters:addString("Labels" .. id, "Label", "", Label);
end 

function AddTimeFrame(id, FRAME, DEFAULT)
    indicator.parameters:addGroup(id .. ". Time Frame");
    indicator.parameters:addBoolean("USE" .. id, "Show This Time Frame", "", DEFAULT); 
    indicator.parameters:addString("TF" .. id, "Time frame", "", FRAME);
    indicator.parameters:setFlag("TF" .. id, core.FLAG_PERIODS);    
    
    indicator.parameters:addString("Price" .. id, "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price" .. id, "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price" .. id, "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price" .. id, "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price" .. id,"CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price" .. id, "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price" .. id, "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price" .. id, "WEIGHTED", "", "weighted");    

    indicator.parameters:addString("Method" .. id, "MA Method", "Method", "MVA");
    indicator.parameters:addStringAlternative("Method" .. id, "MVA", "MVA", "MVA");
    indicator.parameters:addStringAlternative("Method" .. id, "EMA", "EMA", "EMA");
    indicator.parameters:addStringAlternative("Method" .. id, "LWMA", "LWMA", "LWMA");
    indicator.parameters:addStringAlternative("Method" .. id, "TMA", "TMA", "TMA");
    indicator.parameters:addStringAlternative("Method" .. id, "SMMA", "SMMA", "SMMA");
    indicator.parameters:addStringAlternative("Method" .. id, "KAMA", "KAMA", "KAMA");
    indicator.parameters:addStringAlternative("Method" .. id, "VIDYA", "VIDYA", "VIDYA");
    indicator.parameters:addStringAlternative("Method" .. id, "WMA", "WMA", "WMA");
    indicator.parameters:addStringAlternative("Method" .. id, "HMA", "HMA", "HMA");
    
    indicator.parameters:addInteger("Period" .. id, "Period", "Period", 60);
end

local Dodaj = {};
local Period = {};
local Method = {};
local Price = {};
local loading = {};
local SourceData = {};
local Indicator = {};
local Pair = {};
local font, Wingdings, Bold;
local Size;
local source;
local TF = {};
local host;
local first;
local Test;
local Count;
local Up1, Down1, No1, LabelColor;
local Shift;
local Small;
local Sound = {};
local USE = {};
local RESET;
local Label = {};
local ON = {};
local Email;
local SendEmail;
local RecurrentSound,SoundFile;
local Alert;
local PlaySound;
local U = {};
local D = {};
local Number=2;
local Num=0;
local Consensus = {};
local id;
local Corection =0;
local HShift = {};
local VShift = {};
local Type;

function ReleaseInstance()
    core.host:execute("deleteFont", font);
    core.host:execute("deleteFont", Wingdings);
    core.host:execute("deleteFont", Bold);
    core.host:execute("deleteFont", Small);
end  

function Prepare(nameOnly)     
    Shift = instance.parameters.Shift; 
    RESET = instance.parameters.RESET;
    Type = instance.parameters.Type;
    source = instance.source;
     
    host = core.host;    
    
    Size = instance.parameters.Size;   
    local name = "(" .. profile:id() .. "," .. instance.source:name() .. "," .. source:barSize() .. ")"
	  instance:name(name);
	if   (nameOnly) then
        return;
    end
    
    local i,j;
    Up1 = instance.parameters.Up1;
    Down1 = instance.parameters.Down1;
    No1 = instance.parameters.No1;
    LabelColor = instance.parameters.Label;
    if Type == "Multiple currency pair" then 
        Count = 0;
        for i= 1, 10, 1 do     
            Dodaj[i] = instance.parameters:getBoolean("Dodaj" .. i);
            if Dodaj[i] then
                Count = Count + 1;
                Pair[Count] = instance.parameters:getString("Pair" .. i);    
            end
        end
    elseif Type == "All currency pair" then 
        Pair, Count = getInstrumentList();
    else
        Pair[1] = source:instrument();
        Count = 1;
    end

    for i = 1, 5, 1 do  
        USE[i] = instance.parameters:getBoolean("USE" .. i);

        if USE[i] then
            Num = Num + 1;
            TF[Num] = instance.parameters:getString("TF" .. i);    
            Period[Num] = instance.parameters:getInteger("Period" .. i);    
            Method[Num] = instance.parameters:getString("Method" .. i);    
            Price[Num] = instance.parameters:getString("Price" .. i);
            
        end        
    end    

  
    font = core.host:execute("createFont", "Courier", Size, false, false);
    Wingdings = core.host:execute("createFont", "Wingdings", Size + 1, false, false);
    Bold = core.host:execute("createFont", "Courier", Size + 1, false, true);   
    Small = core.host:execute("createFont", "Courier", Size, false, false); 
    ID = 0;
    for j = 1, Count, 1 do
        SourceData[j] = {};
        Indicator[j] = {};    
        loading[j] = {};    
        for i = 1, Num, 1 do    
            ID = ID + 1;
    assert(core.indicators:findIndicator(Method[i]) ~= nil, Method[i] .. " indicator must be installed");
            Test = core.indicators:create(Method[i], source.close, Period[i]);   
            first = Test.DATA:first();
            SourceData[j][i] = core.host:execute("getSyncHistory", Pair[j], TF[i], source:isBid(), math.min(300, first*2), 2000 + ID, 1000  + ID);
            loading[j][i] = true;  
            Indicator[j][i] = core.indicators:create(Method[i], SourceData[j][i][Price[i]], Period[i]);
        end
    end

    Initialization();
end

function Initialization()
    Size = instance.parameters.Size;
    SendEmail = instance.parameters.SendEmail;

    local i;
    for i = 1, Number, 1 do 
        Label[i] = instance.parameters:getString("Labels" .. i);
        ON[i] = instance.parameters:getBoolean("ON" .. i);
    end

    if SendEmail then
        Email = instance.parameters.Email;
    else
        Email = nil;
    end
    assert(not(SendEmail) or (SendEmail and Email ~= ""), "E-mail address must be specified");

    PlaySound = instance.parameters.PlaySound;
    if PlaySound then
        for i = 1, Number, 1 do 
            Sound[i] = instance.parameters:getString("Sound" .. i);
        end
    else 
        for i = 1, Number, 1 do 
            Sound[i] = nil;      
        end
    end

    for i = 1, Number, 1 do 
        assert(not(PlaySound) or (PlaySound and Sound[i] ~= "") or (PlaySound and Sound[i] ~= ""), "Sound file must be chosen"); 
    end

    RecurrentSound = instance.parameters.RecurrentSound;

    for i = 1, Number, 1 do 
        U[i] = nil;
        D[i] = nil;
    end
end    

function Calculate(period, mode)
    Corection = 1;
    local FLAG = false;
    local i,j;
    id = 1;
    local Reset = 0;
    local Broj = 0;
    for j = 1, Count, 1 do
        Reset = Reset + 1;
        if Reset == RESET + 1 then
            Corection = Corection + 1;
            Reset = 1;
        end
        
        HShift[j] = 150 + (Corection - 1) * 210;
        VShift[j] = 50 + (Reset - 1) * Size + Size / 2;
        core.host:execute("drawLabel1", id,  HShift[j] - 75, core.CR_LEFT, VShift[j], core.CR_TOP, core.H_Left, core.V_Center, Bold, LabelColor, Pair[j]);              
        id = id + 1;
        for i = 1, Num, 1 do    
            core.host:execute("drawLabel1", id, i * Size + HShift[j], core.CR_LEFT, 35 + Shift, core.CR_TOP, core.H_Left, core.V_Center, Small, LabelColor, i .. "");
            id = id + 1;
        end      
    end

    for j = 1, Count, 1 do
        Consensus[j] = 0;
        for i = 1, Num, 1 do
            Indicator[j][i]:update(core.UpdateLast);
            Draw(0, i, j);
        end
    end
    local C;
    local L;
    for i = 1, Count, 1  do
        if Consensus[i] == Num then
            C = Up1;
            L = "Buy"
        elseif Consensus[i] == -Num then
            C = Down1;
            L = "Sell"
        else
            C = No1;
            L = "Neutral"
        end
        if Num ~= 0 then
            core.host:execute("drawLabel1", id, HShift[i], core.CR_LEFT, VShift[i], core.CR_TOP, core.H_Left, core.V_Center, Bold, C, L);
            id = id + 1;
        end 
    end
end

function Draw(p, i, j)
    if Indicator[j][i].DATA:hasData(Indicator[j][i].DATA:size() - 1 - p) and SourceData[j][i].close:hasData(SourceData[j][i].close:size() - 1 - p) then                    
        local Color1 = nil;
        local Style1 = nil;
        if SourceData[j][i].close[SourceData[j][i].close:size() - 1 - p] > Indicator[j][i].DATA[Indicator[j][i].DATA:size() - 1 - p] then
            if p == 0 then
                Consensus[j] = Consensus[j] + 1;
            end

            Color1 = Up1;
            Style1 = "\110";
        elseif SourceData[j][i].close[SourceData[j][i].close:size() - 1 - p] < Indicator[j][i].DATA[Indicator[j][i].DATA:size() - 1 - p] then
            if p == 0 then
                Consensus[j] = Consensus[j] - 1;    
            end

            Color1 = Down1;
            Style1 = "\110";    
        else
            Color1 = No1;
            Style1 = "\110";    
        end

        if Style1 ~= nil then
            core.host:execute("drawLabel1", id, i * Size + HShift[j], core.CR_LEFT, VShift[j], core.CR_TOP, core.H_Left, core.V_Center, Wingdings, Color1, Style1);
            id = id + 1;
        end
    end
end

function Update(period, mode)
    core.host:execute("setStatus", "")
    if period < source:size() - 1 then
        return
    end

    local FLAG = false;
    for j = 1, Count, 1 do
        for i = 1, Num, 1 do    
            if loading[j][i] then
                FLAG = true;
            end
        end
    end
    if FLAG then 
        return;
    end

    Calculate(period, mode);

    if Num == 0 then
        return;
    end

    if period < source:size() - 1  then
        return
    end

    Activate(1, period); 
    Activate(2, period); 
end

function Activate(id, period)
    local i;

    if id == 1 and ON[id] then
        for i = 1, Count, 1 do
            if Consensus[i] == Num then
                D[i] = nil;
                if U[i] ~= source:serial(period) and period == source:size() - 1 then
                    U[i] = source:serial(period);
                    SoundAlert(Sound[id]);
                    EmailAlert(tostring(Label[id]) .. " Consensus", i);
                end
            end
        end         
    elseif id == 2 and ON[id] then 
        for i = 1, Count, 1 do
            if Consensus[i] == -Num then
                U[i] = nil;
                if D[i] ~= source:serial(period) and period == source:size() - 1 then
                    D[i] = source:serial(period);
                    SoundAlert(Sound[id]);
                    EmailAlert(tostring(Label[id]) .. " Consensus", i);
                end
            end
        end
    end
end            

function getInstrumentList()
    local list = {};
    local count = 0;    
    local row, enum;    
    enum = core.host:findTable("offers"):enumerator();
    row = enum:next();
    while row ~= nil do
        count = count + 1;
        list[count] = row.Instrument;
        row = enum:next();
    end

    return list, count;
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    local ID = 0;
    for j = 1, Count, 1 do
        for i = 1, Num, 1 do
            ID = ID + 1;
            if cookie == (1000 + ID) then
                loading[j][i] = true;
            elseif cookie == (2000 + ID) then
                loading[j][i] = false;
 
            end
        end
    end    
	
	
 	
	 local FLAG = false;
    for j = 1, Count, 1 do
        for i = 1, Num, 1 do
            if loading[j][i] then
                FLAG = true;
            end
        end
    end
	
	
	
    if not FLAG then
         instance:updateFrom(0);
    end
	
	

    return core.ASYNC_REDRAW;
end

function SoundAlert(Sound)
    terminal:alertSound(Sound, RecurrentSound);
end

function EmailAlert(Subject, i)
    if not SendEmail then
        return
    end
    local date = source:date(NOW);
    local DATA = core.dateToTable(date);
    local LABEL = DATA.month .. ", " .. DATA.day .. ", " .. DATA.hour .. ", " .. DATA.min .. ", " .. DATA.sec;
    terminal:alertEmail(Email, Subject, profile:id() .. ", " .. Pair[i]  .. ", " .. Subject .. ", " .. LABEL);
end


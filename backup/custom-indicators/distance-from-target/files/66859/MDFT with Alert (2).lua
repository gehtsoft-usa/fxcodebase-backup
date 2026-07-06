-- Id: 11217
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=40833

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
    indicator:name("Multiple Distance from Target with Alert");
    indicator:description("Multiple Distance from Target with Alert");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Levels");    
    local i;
    for i = 1, 10, 1 do
        Add(i);
    end
    
    indicator.parameters:addGroup("Calculation");    
    indicator.parameters:addString("Method", "Method", "Method" , "Pip");
    indicator.parameters:addStringAlternative("Method", "Pip", "Pip" , "Pip");
    indicator.parameters:addStringAlternative("Method", "Value", "Value" , "Value");
    
    indicator.parameters:addGroup("Style");
    indicator.parameters:addInteger("Size", "Font Size", "", 20); 
    indicator.parameters:addColor("Color", "Line Color ", " ", core.rgb(255, 0, 0));
    
    indicator.parameters:addGroup("Alert Style");
    indicator.parameters:addColor("Up", "Up Trend Color", "", core.rgb(0, 0, 255));
    indicator.parameters:addColor("Down", "Down Trend Color", "", core.rgb(0, 0, 255));
    
    indicator.parameters:addGroup("Alerts Sound");indicator.parameters:addGroup("Alerts Sound");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", false);    
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);
    
    indicator.parameters:addGroup("Alerts Email");   
    indicator.parameters:addBoolean("SendEmail", "Send Email", "", false);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);
    
    Parameters (1, "Cross")
end

function Add(id)
    indicator.parameters:addDouble("Level" .. id, id .. ". Level", "", 0);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

function Parameters(id, Label)
    indicator.parameters:addGroup(Label .. " Alert");
  
    indicator.parameters:addBoolean("ON" .. id , "Show " .. Label .. " Alert" , "", false);

    indicator.parameters:addFile("Up" .. id, Label .. " Cross Over Sound", "", "");
    indicator.parameters:setFlag("Up" .. id, core.FLAG_SOUND);
    
    indicator.parameters:addFile("Down" .. id, Label .. " Cross Under Sound", "", "");
    indicator.parameters:setFlag("Down" .. id, core.FLAG_SOUND);
    
    indicator.parameters:addString("Label" .. id, "Label", "", Label);
end 

local Number = 1;
local Up = {};
local Down = {};
local Label = {};
local ON = {};
local U = {};
local D = {};
local up = {};
local down = {};
 
local Email;
local SendEmail;
local RecurrentSound, SoundFile;

local Alert;
local Indicator;
local PlaySound;

local FIRST = true;
local level = {};

local Method;
local Num = 10;
local first;
local source = nil;

-- Streams block
local Color = nil;
local font;
local Size;
-- Routine
function Prepare(nameOnly)
    Color = instance.parameters.Color;
    Size = instance.parameters.Size;
    Method = instance.parameters.Method;
    source = instance.source;
    first = source:first();
    
    FIRST = true;
    
    for i = 1, Num, 1 do 
        level[i] = instance.parameters:getDouble("Level" .. i);
    end

    local name = profile:id() .. "(" .. source:name() .. ", " .. Method  .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    
    core.host:execute("setTimer", 3, 1);
    
    font = core.host:execute("createFont", "Ariel", Size, true, false); 
    Initialization();
end

function Initialization()
    Size = instance.parameters.Size;
    SendEmail = instance.parameters.SendEmail;
     
    local i;
    for i = 1, Number, 1 do      
        Label[i] = instance.parameters:getString("Label" .. i);
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
            Up[i] = instance.parameters:getString("Up" .. i);
            Down[i] = instance.parameters:getString("Down" .. i);
        end
    else 
        for i = 1, Number, 1 do 
            Up[i] = nil;
            Down[i] = nil;
        end
    end
    
    for i = 1, Number, 1 do 
        assert(not(PlaySound) or (PlaySound and Up[i] ~= "") or (PlaySound and Up[i] ~= ""), "Sound file must be chosen"); 
        assert(not(PlaySound) or (PlaySound and Down[i] ~= "") or (PlaySound and Down[i] ~= ""), "Sound file must be chosen");
    end
     
    RecurrentSound = instance.parameters.RecurrentSound;
    
    for i = 1, Number, 1 do 
        U[i] = nil;
        D[i] = nil;
    
        if ON[i] then
            up[i] = instance:createTextOutput("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Center, instance.parameters.Up, 0);
            down[i] = instance:createTextOutput("Dn", "Dn", "Wingdings", Size, core.H_Center, core.V_Center, instance.parameters.Down, 0);
        end
    end
end    

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    local i;
    for i = 1, Number, 1 do
        if ON[i] then
            down[i]:setNoData(period); 
            up[i]:setNoData(period);
        end
    end     
   
    Activate(1, period)
end

function Activate(id, period)
    local i; 
    local Level;
    for i = 1, Num, 1 do    
        Level = level[i];
        if id == 1 and ON[id] and Level ~= 0 then
            if source[period - 1] < Level and source[period] > Level then
                up[id]:set(period, Level, "\108");    
                D[id] = nil;
                if U[id] ~= source:serial(period) and period == source:size() - 1 then
                    U[id] = source:serial(period);
                    SoundAlert(Up[id]);
                    EmailAlert(i .. ". Level Cross Over");
                end
                core.host:execute("drawLabel1", i * 10 + 4, -100, core.CR_RIGHT, 2 * Size + (i * 100), core.CR_TOP, core.H_Center, core.V_Bottom, font, Color, "Cross Over");
            elseif source[period - 1] > Level and source[period] < Level then            
                down[id]:set(period, Level, "\108");                                 
                U[id] = nil;
                if D[id] ~= source:serial(period) and period == source:size() - 1 then
                    D[id] = source:serial(period);
                    SoundAlert(Down[id]);             
                    EmailAlert(i .. ". Level Cross Under");                                   
                end        
                core.host:execute("drawLabel1", i * 10 + 4, -100, core.CR_RIGHT, 2 * Size + (i * 100), core.CR_TOP, core.H_Center, core.V_Bottom, font, Color, "Cross Under");
             end
        end
    end
end

function SoundAlert(Sound)
    if not PlaySound then
        return;
    end
    if FIRST then
        FIRST = false;
        return;
    end
    terminal:alertSound(Sound, RecurrentSound);
end

function EmailAlert(Subject)
    if not SendEmail then
        return
    end
    local date = source:date(NOW);
    local DATA = core.dateToTable(date);
    local LABEL = DATA.month .. ", " .. DATA.day .. ", " .. DATA.hour .. ", " .. DATA.min .. ", " .. DATA.sec;
    terminal:alertEmail(Email, Subject, profile:id() .. "(" .. source:instrument() .. ")" .. Subject .. ", " .. LABEL);
 end

function AsyncOperationFinished(cookie, success, message)
    local Level;    
    for i = 1, Num, 1 do
        Level = level[i];
        if Level ~= 0 then
            core.host:execute("drawLine", i * 10 + 1, source:date(first), Level, source:date(source:size() - 1), Level, Color);
            core.host:execute("drawLabel1", i * 10 + 2, -100, core.CR_RIGHT, (i * 100), core.CR_TOP, core.H_Center, core.V_Bottom, font, Color, i .. ". Target : " .. string.format("%." .. 5 .. "f", Level));
            local Distance;
            if Method == "Pip" then
                Distance = (source[source:size() - 1] - Level) / source:pipSize();
            else
                Distance = source[source:size() - 1] - Level;
            end
            core.host:execute("drawLabel1", i * 10 + 3, -100, core.CR_RIGHT, Size + (i * 100), core.CR_TOP, core.H_Center, core.V_Bottom, font, Color, "Distance : " ..  string.format("%." .. 5 .. "f", Distance));                     
        end
    end
end
 
function ReleaseInstance()
    core.host:execute("deleteFont", font);      
    core.host:execute("killTimer", 1)
end

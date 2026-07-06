-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3102

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                              Support our efforts by donating   | 
--|                                                                 Paypal: https://goo.gl/9Rj74e  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+

--Your donations will allow the service to continue onward.
--+------------------------------------------------------------------------------------------------+
--|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
--|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
--|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
--|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
--|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
--|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
--+------------------------------------------------------------------------------------------------+



-- This indicator will provides Audio / Email Alerts if and when Super Trend indication is changed.
 

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("SuperTrend Indicator");
    indicator:description("The indicator displays the buying and selling with the colors. The indicator is initially developed by Jason Robinson for MT4");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Mode");
    indicator.parameters:addString("Live", "End of Turn / Live", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
    indicator.parameters:addStringAlternative("Live", "Live", "", "Live");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "Number of periods", "No description", 10);
    indicator.parameters:addDouble("M", "Multiplier", "No description", 1.5);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UP_color", "Color of UP", "Color of UP", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DN_color", "Color of DN", "Color of DN", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("width", "Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("style", "Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);

    indicator.parameters:addGroup("Cloud Style");
	indicator.parameters:addBoolean("Cloud", "Show Cloud", "" , true); 
	indicator.parameters:addInteger("Transparency", "Transparency", "", 90,0,100);
	 

    indicator.parameters:addGroup("Alert Style");
    indicator.parameters:addColor("Up", "Up Trend Color", "", core.rgb(0, 0, 255));
    indicator.parameters:addColor("Down", "Down Trend Color", "", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("Size", "Label Size", "", 10, 1, 100);

    indicator.parameters:addGroup("Alerts Sound");
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", true);
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);

    indicator.parameters:addGroup("Alerts Email");
    indicator.parameters:addBoolean("SendEmail", "Send Email", "", true);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);
    indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true);

    Parameters(1, "SuperTrend")
end

function Parameters( id, Label)
    indicator.parameters:addGroup(Label .. " Alert");

    indicator.parameters:addBoolean("ON" .. id, "Show " .. Label .. " Alert", "", true);

    indicator.parameters:addFile("Up" .. id, Label .. " Cross Over Sound", "", "");
    indicator.parameters:setFlag("Up" .. id, core.FLAG_SOUND);

    indicator.parameters:addFile("Down" .. id, Label .. " Cross Under Sound", "", "");
    indicator.parameters:setFlag("Down" .. id, core.FLAG_SOUND);

    indicator.parameters:addString("Label" .. id, "Label", "", Label);
end

local Number = 1;


-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Up = {};
local Down = {};
local Label = {};
local ON = {};
local Line;
local up = {};
local down = {};
local Size;
local Email;
local SendEmail;
local RecurrentSound, SoundFile;
local Show;
local Alert;
local PlaySound;
local Live;
local FIRST = true;

local U = {};
local D = {};

local N;
local M;

local first;
local source = nil;
local ATR = nil;

-- Streams block
local OUT = nil;
local UP = nil;
local DN = nil;
local TR = nil;

local Cloud, Transparency,Close; 
-- Routine
function Prepare(nameOnly) 
    FIRST = true;
    Show = instance.parameters.Show;
    Live = instance.parameters.Live;

    N = instance.parameters.N;
    M = instance.parameters.M;
    source = instance.source;
	
   Cloud= instance.parameters.Cloud;
   Transparency= instance.parameters.Transparency;
   Transparency= 100-Transparency;	
    
    local name = profile:id() .. "(" .. source:name() .. ", " .. N .. ", " .. M .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	ATR = core.indicators:create("ATR", source, N);
    first = ATR.DATA:first();
	
    UP = instance:addInternalStream(first, 0);
    DN = instance:addInternalStream(first, 0);
    TR = instance:addInternalStream(first, 0);
    OUT = instance:addStream("ST", core.Line, name .. ".Super Trend", "Super Trend", instance.parameters.UP_color, first);
    OUT:setWidth(instance.parameters.width);
    OUT:setStyle(instance.parameters.style);

    Initialization();
	
	
	if Cloud then   
    Close=instance:addStream("Close", core.Line, name, "Close", core.rgb( 128, 128, 128), 0);
	Close:setStyle(core.LINE_NONE);	
	instance:createChannelGroup("Group","Group" , OUT, Close,  instance.parameters.UP_color, Transparency);
	else
    Close = instance:addInternalStream(0, 0);	
	end
	
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
            up[i] = instance:createTextOutput ("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Center, instance.parameters.Up, 0);
            down[i] = instance:createTextOutput ("Dn", "Dn", "Wingdings", Size, core.H_Center, core.V_Center, instance.parameters.Down, 0);
        end
    end
end

function Activate(id, period)
    local Shift = 0;

    if Live ~= "Live" then
        period = period - 1;
        Shift = 1;
    end

    if id == 1 and ON[id] then
        if TR[period] == 1 and TR[period - 1] ~= 1 then
            up[id]:set(period, OUT[period], "\108");

            D[id] = nil;

            if U[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
                U[id] = source:serial(period);
                SoundAlert(Up[id]);
                EmailAlert(Label[id], " Cross Over", period);
                if Show then
                    Pop(Label[id], " Cross Over " );
                end
            end
        elseif TR[period] == -1 and TR[period - 1] ~= -1 then
            down[id]:set(period, OUT[period], "\108");
            U[id] = nil;

            if D[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
                D[id] = source:serial(period);
                SoundAlert(Down[id]);
                EmailAlert( Label[id], " Cross Under", period);
                if Show then
                    Pop(Label[id], " Cross Under ");
                end
            end
        end
    end

    if FIRST then
        FIRST = false;
    end
end

function AsyncOperationFinished (cookie, success, message)
end

function Pop(label, note)
      terminal:alertMessage(source:instrument(),source.close[NOW],   label .. " ( " .. source:instrument() .. " : " .. source:barSize() .. " ) "  .. label .. " : " .. note, source:date(NOW));
	  
 
end

function SoundAlert(Sound)
    if not PlaySound then
        return;
    end

    terminal:alertSound(Sound, RecurrentSound);
end

function EmailAlert( label, Subject, period)
    if not SendEmail then
        return
    end

    local date = source:date(period);
    local DATA = core.dateToTable(date);

    local delim = "\013\010";
    local Note = profile:id() .. delim .. " Label : " .. label .. delim .. " Alert : " .. Subject ;
    local Symbol = "Instrument : " .. source:instrument() ;
    local TF = "Time Frame : " .. source:barSize();
    local Time = " Date : " .. DATA.month .. " / " .. DATA.day .. " Time:  " .. DATA.hour .. " / " .. DATA.min .. " / " .. DATA.sec;
    local text = Note .. delim .. Symbol .. delim .. TF .. delim .. Time;
    terminal:alertEmail(Email, profile:id(), text);
end

-- Indicator calculation routine
function Update(period, mode)
    Calculation(period, mode);

    local i;
    for i = 1, Number, 1 do
        if ON[i] then
            down[i]:setNoData(period);
            up[i]:setNoData(period);
        end
    end

    if period < first then
        return;
    end
    Activate(1, period);
end

function Calculation(period, mode)
    ATR:update(mode);
    TR[period] = 1;

    if period <= first then
        return;
    end
    local change;

    UP[period] = source.median[period] + ATR.DATA[period] * M;
    DN[period] = source.median[period] - ATR.DATA[period] * M;
	Close[period]=source.close[period];
	

    if period >= first + 1 then
        change = false;
        if source.close[period] > UP[period - 1] then
            TR[period] = 1;
            if TR[period - 1] == -1 then
                change = true;
            end
        elseif source.close[period] < DN[period - 1] then
            TR[period] = -1;
            if TR[period - 1] == 1 then
                change = true;
            end
        else
            TR[period] = TR[period - 1];
        end

        local flag, flagh;

        if TR[period] < 0 and TR[period - 1] > 0 then
           flag = 1;
        else
           flag = 0;
        end

        if TR[period] > 0 and TR[period - 1] < 0 then
           flagh = 1;
        else
           flagh = 0;
        end

        if TR[period] > 0 and DN[period] < DN[period - 1] then
            DN[period] = DN[period - 1];
        end

        if TR[period] < 0 and UP[period] > UP[period - 1] then
            UP[period] = UP[period - 1];
        end

        if flag == 1 then
            UP[period] = source.median[period] + ATR.DATA[period] * M;
        end

        if flagh == 1 then
            DN[period] = source.median[period] - ATR.DATA[period] * M;
        end

        if TR[period] == 1 then
            OUT[period] = DN[period];
             OUT:setColor(period, instance.parameters.UP_color);
        end

        if TR[period] == -1 then
            OUT[period] = UP[period];
            OUT:setColor(period, instance.parameters.DN_color);
        end
    end
end

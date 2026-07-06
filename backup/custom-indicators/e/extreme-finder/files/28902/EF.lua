-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=15322


--+------------------------------------------------------------------+
--|                               Copyright � 2018, Gehtsoft USA LLC | 
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

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Extreme Finder");
    indicator:description("Extreme Finder");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Mode");  
    indicator.parameters:addString("Live", "End of Turn / Live", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
    indicator.parameters:addStringAlternative("Live", "Live", "", "Live");  
    
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("FP", "Forward Testing Period ", "", 5);
    indicator.parameters:addInteger("BP", "Backward Testing Period", "", 5);
    indicator.parameters:addDouble("SIZE", "Current Candle Min. Size (pips)", "", 0);
    indicator.parameters:addDouble("NEXT", "Next Candle Min. Size (pips)", "", 0);

    indicator.parameters:addGroup("Style");indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UP", "Up fractal color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DOWN", "Down fractal color", "", core.rgb(255, 0, 0));

    indicator.parameters:addColor("U_UP", "Unconfirmed Up fractal color", "", core.rgb(0, 0, 255));
    indicator.parameters:addColor("U_DOWN", "Unconfirmed Down fractal color", "", core.rgb(0, 0, 255));

    indicator.parameters:addInteger("Size", "Font Size", "", 10, 1, 100);

    indicator.parameters:addGroup("Alerts");
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", false);
    indicator.parameters:addFile("SoundFile", "Sound File", "", "");
    indicator.parameters:setFlag("SoundFile", core.FLAG_SOUND);
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);
    
    indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", false);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local FP;
local BP;
local Show, Live;
local first;
local source = nil;
local Flag;
-- Streams block
local up, down;
local u_up, u_down;
local UP, DOWN;
local U_UP, U_DOWN;
local Size, SIZE;
local NEXT;
local PlaySound, RecurrentSound, SoundFile;
local Last;
local Shift = 0;

function AsyncOperationFinished(cookie, success, message)
end

function SoundAlert(period)
    if not PlaySound then
        return;
    end
    terminal:alertSound(SoundFile, RecurrentSound);
end

-- Routine
function Prepare(nameOnly)
    SIZE = instance.parameters.SIZE;
    NEXT = instance.parameters.NEXT;
    UP = instance.parameters.UP;
    DOWN = instance.parameters.DOWN;
    Live = instance.parameters.Live;
    Show = instance.parameters.Show;

    U_UP = instance.parameters.U_UP;
    U_DOWN = instance.parameters.U_DOWN;

    Size = instance.parameters.Size;

    FP = instance.parameters.FP;
    BP = instance.parameters.BP;
    source = instance.source;
    first = source:first();

    Flag = nil;

    PlaySound = instance.parameters.PlaySound;
    if PlaySound then
        SoundFile = instance.parameters.SoundFile;
    else
        SoundFile = nil;
    end
    assert(not(PlaySound) or (PlaySound and SoundFile ~= ""), "Sound file must be chosen");
    RecurrentSound = instance.parameters.RecurrentSound;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(FP) .. ", " .. tostring(BP) .. ", " .. tostring(SIZE) .. ", " .. tostring(NEXT) .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end

    
        up = instance:createTextOutput("Confirmed Up", "Up", "Wingdings", Size, core.H_Center, core.V_Top, UP, 0);
        down = instance:createTextOutput("Confirmed Dn", "Dn", "Wingdings", Size, core.H_Center, core.V_Bottom, DOWN, 0);

        u_up = instance:createTextOutput("Unconfirmed Up", "Up", "Wingdings", Size, core.H_Center, core.V_Top, U_UP, 0);
        u_down = instance:createTextOutput("Unconfirmed Dn", "Dn", "Wingdings", Size, core.H_Center, core.V_Bottom, U_DOWN, 0);
  
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first or not source:hasData(period) then
        return;
    end

    if period < source:size() - 1 then
        return;
    end

    if Live ~= "Live" then
        period = period - 1;
        Shift = 1;
    else
        Shift = 0;
    end

    for i = first, period, 1 do
        Calculate(i)        
    end
end

function Calculate(i)
    up:setNoData(i);
    down:setNoData(i);
    u_up:setNoData(i);
    u_down:setNoData(i);

    if (SIZE * source:pipSize()) > math.abs(source.open[i] - source.close[i]) or (NEXT * source:pipSize()) > math.abs(source.open[math.min(i + 1, source:size() - 1 - Shift)] - source.close[math.min(i + 1, source:size() - 1 - Shift)]) then
        return;
    end

    BMin, BMax = mathex.minmax(source, math.max(first, i - BP), i);
    FMin, FMax= mathex.minmax(source, i, math.min(i + FP, source:size() - 1 - Shift));

    if BMax <= source.high[i] and FMax <= source.high[i] then
        if math.max(first, i - BP) == first or math.min(i + FP, source:size() - 1 - Shift) == source:size() - 1 - Shift then
            u_up:set(i, source.high[i], "\226");
        else
            up:set(i, source.high[i], "\226");
        end
        if i == source:size() - 1 - Shift and Last ~= source:serial(i) then
            Last = source:serial(i);
            SoundAlert(i);
            Pop(" Cross Over " , " Top ");
        end
    end

    if BMin >= source.low[i] and FMin >= source.low[i] then
        if math.max(first, i - BP) == first or math.min(i + FP, source:size() - 1 - Shift) == source:size() - 1 - Shift then
            u_down:set(i, source.low[i], "\225");
        else
            down:set(i, source.low[i], "\225");
        end
        if i == source:size() - 1 - Shift and Last ~= source:serial(i) then
            Last = source:serial(i)
            SoundAlert(i);
            Pop(" Cross Under " , " Bottom ");
        end
    end
end

function Pop(label, note)
    if not Show then
        return;
    end
    if source:isBar() then
        terminal:alertMessage(source:instrument(), 
            source[source:size() - 1],
            label .. " ( " .. source:instrument() .. " : " .. source:barSize() .. " ) " .. label,
            source.close[NOW]);
    else
        terminal:alertMessage(source:instrument(), 
            source[source:size() - 1], 
            label .. " ( " .. source:instrument() .. " ) " .. label,
            source.close[NOW]);
    end
end


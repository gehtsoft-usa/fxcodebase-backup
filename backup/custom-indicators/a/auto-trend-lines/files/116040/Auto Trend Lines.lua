-- Id: 19739

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=647&start=60


--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Trend Lines");
    indicator:description("Trend Lines");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("T", "Tolerated", "Tolerated", 1,0, 2000);
    indicator.parameters:addInteger("F", "Frame Size", "Frame Size", 200,6,2000);
    indicator.parameters:addInteger("cd", "Convergence Divergence", "Convergence Divergence", 50,0,100);
    
    indicator.parameters:addString("W", "Test Whole Frame", "Whole Y/N" , "Yes");
    indicator.parameters:addStringAlternative("W", "Test Whole Yes", "Whole Yes" , "Yes");
    indicator.parameters:addStringAlternative("W", "Test Whole No", "Whole No" , "No");
    
    indicator.parameters:addString("Pfractal", "Fractal", "Fractal Y/N" , "Yes");
    indicator.parameters:addStringAlternative("Pfractal", "Fractal Yes", "Fractal Yes" , "Yes");
    indicator.parameters:addStringAlternative("Pfractal", "Fractal No", "Fractal No" , "No");
    
    indicator.parameters:addString("HighLowClose", "Close or High and Low ", "Close or High and Low" , "HighLow");
    indicator.parameters:addStringAlternative("HighLowClose", "High/Low", "High/Low" , "HighLow");
    indicator.parameters:addStringAlternative("HighLowClose", "Close", "Close" , "Close");
    
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("top_color", "Color of Top", "Color of Top", core.rgb(0, 255, 0));
    indicator.parameters:addColor("bottom_color", "Color of Bottom", "Color of Bottom", core.rgb(0, 0, 255));
    
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);

    indicator.parameters:addGroup("Alerts Sound");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", false);	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);
    indicator.parameters:addFile("sound", "Sound", "", "");
    indicator.parameters:setFlag("sound", core.FLAG_SOUND);
    
    indicator.parameters:addGroup("Alerts Email");   
    indicator.parameters:addBoolean("SendEmail", "Send Email", "", false);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);
    indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first = nil;
local source = nil;
local line_id = 1;
local width, style;
--Variable
local upy = nil;
local downy = nil;
local frame = nil;
local last_period = -1;
local tolerated=0;
local Pfractal=nil;
local HighLowClose=nil;
local Whole=nil;
local cd=0;
local size =nil;
local whole;
local compare_source_high;
local compare_source_low;
local Email;
local SendEmail;
local RecurrentSound, SoundFile;
local Show;
local Alert;
local PlaySound;
local full_redraw = true;

-- Routine
function Prepare(nameOnly)

     source = instance.source;
    first = source:first();
	
	 frame = instance.parameters.F;
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. frame .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
   
    width = instance.parameters.width;
    style = instance.parameters.style;
    tolerated = instance.parameters.T;
    Pfractal = instance.parameters.Pfractal;
    CloseHighLow=instance.parameters.HighLowClose;
    Whole=instance.parameters.W;
    cd=(instance.parameters.cd);
    cd=cd/100;
    SendEmail = instance.parameters.SendEmail;
    if SendEmail then
        Email = instance.parameters.Email;
    else
        Email = nil;
    end
    assert(not(SendEmail) or (SendEmail and Email ~= ""), "E-mail address must be specified");
    PlaySound = instance.parameters.PlaySound;
    RecurrentSound = instance.parameters.RecurrentSound;
    SoundFile = instance.parameters.sound;
    assert(not (PlaySound and (SoundFile == "" or SoundFile == nil)), "Sound file must be chosen");

   

    upy = instance:addInternalStream(0, 0);
    downy = instance:addInternalStream(0, 0);
    
    
    
    size = source:size(period);
end

-- calculate fractals
function fractal(p)
    upy[p] = 0;
    downy[p] = 0;

    curr = source.high[p - 2];

    if (curr >= source.high[p - 4] and curr >= source.high[p - 3] and
        curr >= source.high[p - 1] and curr >= source.high[p]) then
        upy[p - 2] = source.high[p-2];
    end

    curr = source.low[p - 2];
    if (curr <= source.low[p - 4] and curr <= source.low[p - 3] and
        curr <= source.low[p - 1] and curr <= source.low[p]) then
        downy[p - 2] = source.low[p-2];
    end

    upy[p - 1] = 0;
    downy[p - 1] = 0;
    upy[p] = 0;
    downy[p] = 0;
end

-- get line equation coefficients
function getline(x1, y1, x2, y2)
    local a, b;

    a = ((y2 - y1) / (x2 - x1));
    b = (y1 - a * x1);
    return a, b;
end

local lines = {};

-- draws line based on two fractals 
function drawline(x1, y1, x2, y2, color)
    local date1=0;
    local date2=0;
    date1 = source:date(x1);
    date2 = source:date(x2);

    core.host:execute("drawLine", line_id, date1, y1, date2, y2, color, style, width);
    line_id = line_id + 1;
    if lines[date1] == nil then
        lines[date1] = true;
            SoundAlert();
            EmailAlert("New support/resistance created", "New support/resistance created", NOW);
            Pop("New support/resistance created", "New support/resistance created", NOW);
            SendAlert("New support/resistance created", "New support/resistance created", NOW);
    end
end

-- find last two up and down fractals
function Draw(period, frame)
    local i=0;
    local j=0;
    if Whole == "Yes" then
        whole = true;
    else
        whole = false;
    end
    
    if CloseHighLow == "HighLow" then
        compare_source_high = source.high;
        compare_source_low = source.low;
    else
        compare_source_high = source.close;
        compare_source_low = source.close;
    end
    for i=period-frame+1, period-1,1 do  
        if upy[i] ~= 0 then
            for j=i+1, period,1 do
                Process(true, i, j);
            end
        end
        if downy[i] ~= 0 then
            for j=i+1, period,1 do
                Process(false,i, j);
            end
        end
    end
end

function Process(Flag,i, j)
    local x=0;
    local a=0;
    local b=0;
    local tu=0;
    local k1=0;
    local Data;
    local compare_source;
    local Color; 
    local period = source:size()-2

    if Flag then
        Data=upy;
        compare_source=compare_source_high;
        Color=instance.parameters.top_color;
    else
        Data=downy;
        compare_source=compare_source_low;
        Color=instance.parameters.bottom_color;
    end

    if Data[j] == 0 then
        return;
    end
    a,b = getline(i,Data[i], j,Data[j]); 
    if (a==0 or b==0) then
        return;
    end

    if whole then 
        x=period-frame;
    else
        x=i;
    end   

    if Flag then
        for x = x, period, 1 do
            if compare_source[x] >  a * x + b   then
                tu = tu + 1;
            end    

            if  tu > tolerated then
                return;
            end
        end
    else
        for x = x, period, 1 do    
            if compare_source[x] <  a * x + b  then
                tu = tu + 1;
            end    
            if  tu > tolerated then
                return;
            end
        end
    end

    if tu > tolerated then
        return;
    end

    k1= a* period + b;

    if (math.abs(k1 -source.close[period])/math.abs(Data[i] - source.close[period]) )< 1/cd then
        drawline(i, Data[i], period, k1, Color);
    end
    tu=0; a=0; b=0; 
end
    
local last_period = nil;
    
function Update(period, mode)
    full_redraw = period ~= source:size() - 1;
    if period < source:first() then
        return;
    end
 
    local size = source:size();

    if Pfractal == "Yes" then
        if period < 6 then
            return;
        end
        fractal(period);
    else
        if period < size - frame then
            return;
        end
        upy[period] = source.high[period];
        downy[period] = source.low[period];
    end
  
    if source:size() < frame or period ~= source:size() - 1 then
        return;
    end
      
    if last_period ~= nil and last_period == source:serial(period) then        
        return ;
    end
    last_period = source:serial(period);
    
    period = period - 1;
    core.host:execute("removeAll");

    if period == source:size()-2 then   
        Draw(period, frame);
    end
end

function SoundAlert()
    if not PlaySound then
        return;
    end
	
	if SoundFile== nil or SoundFile=="" then
	return;
	end
	
   
    terminal:alertSound(SoundFile, RecurrentSound);
end

function EmailAlert(label, Subject, period)
    if not SendEmail then
        return
    end

    local date = source:date(period);
    local DATA = core.dateToTable(date);
    local delim = "\013\010";  
    local Note = profile:id() .. delim .. " Label : " .. label .. delim .. " Alert : " .. Subject;
    local Symbol = "Instrument : " .. source:instrument();
    local Time = " Date : " .. DATA.month .. " / " .. DATA.day .. " Time: " .. DATA.hour .. " / " .. DATA.min .. " / " .. DATA.sec;  
    local TF = "Time Frame : " .. source:barSize();       
    local text = Note .. delim .. Symbol .. delim .. TF .. delim .. Time;
    terminal:alertEmail(Email, profile:id(), text);
end

function Pop(label, Subject, period)
    if not Show then
        return;
    end
    
    local date = source:date(period);
    local DATA = core.dateToTable(date);
    local delim = "\013\010";  
    local Note = profile:id() .. delim .. " Label : " .. label .. delim .. " Alert : " .. Subject;
    local Symbol = "Instrument : " .. source:instrument();
    local Time = " Date : " .. DATA.month .. " / " .. DATA.day .. " Time: " .. DATA.hour .. " / " .. DATA.min .. " / " .. DATA.sec;
    local TF = "Time Frame : " .. source:barSize();       
    local text = Note .. delim .. Symbol .. delim .. TF .. delim .. Time;
    core.host:execute("prompt", 1, label, text);
end

function SendAlert(label, Subject, period)
    if not ShowAlert then
        return;
    end
    
    local date = source:date(period);
    local DATA = core.dateToTable(date);
    local delim = "\013\010";  
    local Note = profile:id() .. delim .. " Label : " .. label .. delim .. " Alert : " .. Subject;
    local Symbol = "Instrument : " .. source:instrument();
    local Time = " Date : " .. DATA.month .. " / " .. DATA.day .. " Time: " .. DATA.hour .. " / " .. DATA.min .. " / " .. DATA.sec;
    local TF = "Time Frame : " .. source:barSize();       
    local text = Note .. delim .. Symbol .. delim .. TF .. delim .. Time;
    terminal:alertMessage(source:instrument(), source[NOW], text, source:date(NOW));
end
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65501

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
    indicator:name("Color SAR");
    indicator:description("Helps to define the direction of the prevailing trend and the moment to close positions opened during the reversal.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addDouble("Step", "Step", "", 0.02 );
    indicator.parameters:addDouble("Max", "Max", "", 0.2 );
    indicator.parameters:addDouble("Level1", "1. Target Ratio", "", 1 );
    indicator.parameters:addDouble("Level2", "2. Target Ratio", "", 1.5 );
    indicator.parameters:addDouble("Level3", "3. Target Ratio", "", 2 );
    indicator.parameters:addDouble("Level4", "Trigger Line (in pips)", "", 0 );
    
    indicator.parameters:addBoolean("Historical", "Show Historical", "", true);
    indicator.parameters:addString("ShowLabel", "Show Label", "", "no");
    indicator.parameters:addStringAlternative("ShowLabel", "Do not show", "", "no");
    indicator.parameters:addStringAlternative("ShowLabel", "At the left", "", "left");
    indicator.parameters:addStringAlternative("ShowLabel", "At the right", "", "right");
    
    indicator.parameters:addInteger("Lookback", "Label Lookback Period", "", 100 );
    
    indicator.parameters:addGroup("Line Style"); 
    indicator.parameters:addColor("StartLineColor", "Start Line Color", "", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    
    indicator.parameters:addGroup("Label Style"); 
    indicator.parameters:addColor("LabelColor", "Label Color", "", core.COLOR_LABEL );
    indicator.parameters:addBoolean("LabelBackground", "Add Label Background", "", false);
    indicator.parameters:addColor("LabelBackgroundColor", "Label Background Color", "", core.COLOR_BACKGROUND);
    indicator.parameters:addInteger("FontSize", "Label Size", "", 8 );
    indicator.parameters:addColor("StopLineColor", "Stop Line Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
    
    indicator.parameters:addColor("TargetLineColor1", "1. Target Line Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
    
    indicator.parameters:addColor("TargetLineColor2", "2. Target  Line Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("width4", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style4", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style4", core.FLAG_LINE_STYLE);
    
    indicator.parameters:addColor("TargetLineColor3", "3. Target  Line Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("width5", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style5", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style5", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("TargetLineColor4", "Trigger Line Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("width6", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style6", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style6", core.FLAG_LINE_STYLE);
    
    indicator.parameters:addGroup("Alert Parameters");  
    indicator.parameters:addString("Live", "Execution", "", "End of Turn");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
    indicator.parameters:addStringAlternative("Live", "Live", "", "Live");  

    indicator.parameters:addInteger("ToTime", "Convert the date to", "", 6);
    indicator.parameters:addIntegerAlternative("ToTime", "EST", "", 1);
    indicator.parameters:addIntegerAlternative("ToTime", "UTC", "", 2);
    indicator.parameters:addIntegerAlternative("ToTime", "Local", "", 3);
    indicator.parameters:addIntegerAlternative("ToTime", "Server", "", 4);
    indicator.parameters:addIntegerAlternative("ToTime", "Financial", "", 5);
    indicator.parameters:addIntegerAlternative("ToTime", "Display", "", 6);    

    indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true);
    indicator.parameters:addBoolean("OnlyOnce", "Alert Once", "Subsequent Alert will be ignored.", false);    
    indicator.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
    
    indicator.parameters:addGroup("Alert Style");
    indicator.parameters:addColor("UpTrendColor", "Up Trend Color", "", core.rgb(0, 0, 255));
    indicator.parameters:addColor("DownTrendColor", "Down Trend Color", "", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("Size", "Label Size", "", 10, 1 , 100);
    
    indicator.parameters:addGroup("Alerts Sound");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", false);    
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);
    
    indicator.parameters:addGroup("Alerts Email");   
    indicator.parameters:addBoolean("SendEmail", "Send Email", "", false);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);

    Parameters (1, "SAR Alert");
end

function Parameters ( id, Label )
  
  
   indicator.parameters:addGroup(Label .. " Alert");
  
    indicator.parameters:addBoolean("ON"..id , "Show " .. Label .." Alert" , "", true);


    indicator.parameters:addFile("Up"..id, Label .. " Cross Over Sound", "", "");
    indicator.parameters:setFlag("Up"..id, core.FLAG_SOUND);
    
    indicator.parameters:addFile("Down"..id, Label .. " Cross Under Sound", "", "");
    indicator.parameters:setFlag("Down"..id, core.FLAG_SOUND);
    
     indicator.parameters:addString("Label"..id, "Label", "", Label);

end 

local     Number = 1;
local Up={};
local Down={};
local Label={};
local ON={};
local Size;
local Email;
local SendEmail;
local  RecurrentSound ,SoundFile  ;
local Show;
local Alert;
local PlaySound;
local Live;
local FIRST=true;
local OnlyOnce;
local U={};
local D={};
local UpTrendColor, DownTrendColor;
local OnlyOnceFlag;
local ShowAlert;
local Alert={}; 
local AlertLevel={};
local ToTime;
local Shift=0; 
local StartLineColor, StopLineColor, TargetLineColor1, TargetLineColor2, TargetLineColor3, TargetLineColor4;

local first;
local source = nil;
local tradeHigh = nil;
local tradeLow = nil;
local parOp = nil;
local position = nil;
local af = nil;
local Step;
local Max;

local FontSize,LabelColor,font;

local SAR = nil;
local Level1,Level2,Level3,Level4
local style1,style2,style3,style4;
local width1,width2,width3,width4,width5,width5;
local LabelBackgroundColor;
local LabelBackground;
local Historical,ShowLabel;
local Lookback;
function Prepare(nameOnly)   
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 
    if   (nameOnly) then
        return;
    end

    ToTime=instance.parameters.ToTime;
    if ToTime == 1 then
        ToTime=core.TZ_EST;
    elseif ToTime == 2 then
        ToTime=core.TZ_UTC;
    elseif ToTime == 3 then
        ToTime=core.TZ_LOCAL;
    elseif ToTime == 4 then
        ToTime=core.TZ_SERVER;
    elseif ToTime == 5 then
        ToTime=core.TZ_FINANCIAL;
    elseif ToTime == 6 then
        ToTime=core.TZ_TS;
    end
    
    LabelBackgroundColor = instance.parameters.LabelBackgroundColor;
    LabelBackground = instance.parameters.LabelBackground;
    FontSize= instance.parameters.FontSize;
    LabelColor= instance.parameters.LabelColor;
	Historical= instance.parameters.Historical;
	ShowLabel= instance.parameters.ShowLabel;
	
    font = core.host:execute("createFont", "Arial", FontSize, false, false);
    
    OnlyOnceFlag=true;
    FIRST=true;
    OnlyOnce = instance.parameters.OnlyOnce;
    ShowAlert = instance.parameters.ShowAlert;
    Show = instance.parameters.Show;
    Live = instance.parameters.Live;
    UpTrendColor = instance.parameters.UpTrendColor;
    DownTrendColor = instance.parameters.DownTrendColor;
    Size=instance.parameters.Size;
    StartLineColor=instance.parameters.StartLineColor;
    StopLineColor=instance.parameters.StopLineColor;
    TargetLineColor1=instance.parameters.TargetLineColor1;
    TargetLineColor2=instance.parameters.TargetLineColor2;
    TargetLineColor3=instance.parameters.TargetLineColor3;
	TargetLineColor4=instance.parameters.TargetLineColor4;
	Lookback=instance.parameters.Lookback;
    
    style1=instance.parameters.style1;
    style2=instance.parameters.style2;
    style3=instance.parameters.style3;
    style4=instance.parameters.style4;
	style5=instance.parameters.style5;
	style5=instance.parameters.style5;
    width1=instance.parameters.width1;
    width2=instance.parameters.width2;
    width3=instance.parameters.width3;
    width4=instance.parameters.width4;
    width5=instance.parameters.width5;
    width6=instance.parameters.width6;
    Level1=instance.parameters.Level1;
    Level2=instance.parameters.Level2;
    Level3=instance.parameters.Level3;
    Level4=instance.parameters.Level4;
	
    source = instance.source;
    first = source:first() + 1;

    Step = instance.parameters.Step;
    Max = instance.parameters.Max;

    tradeHigh = instance:addInternalStream(0, 0);
    tradeLow = instance:addInternalStream(0, 0);
    parOp = instance:addInternalStream(0, 0);
    position = instance:addInternalStream(0, 0);
    af = instance:addInternalStream(0, 0);
    SAR = instance:addInternalStream(first, 0); 
    for i= 1, Number , 1 do
        Alert[i]=instance:addInternalStream(0, 0);
        AlertLevel[i]=instance:addInternalStream(0, 0);
    end
    
    Initialization();    
    instance:ownerDrawn(true);
	
	FIRST_CANDLE=nil;
end

local init = false;
local label1 = {};
local label2 = {};
local label3 = {};
local label4 = {};
local label5 = {};
local label6 = {}; 
function Draw(stage, context)
    if stage~= 2 then
        return;
    end
    if not init then
        context:createFont(1, "Wingdings", context:pointsToPixels (Size), context:pointsToPixels (Size), 0);
        context:createFont(2, "Arial", 0, context:pointsToPixels(FontSize), 0);
        context:createSolidBrush(3, LabelBackgroundColor);
        init = true;
    end
    local start;
    if not Historical then
        start = math.max(context:firstBar(), source:size()-1)
    else
        start = source:size() - 1 - Lookback;
    end
    for period = start, math.min(context:lastBar(), source:size() - 1), 1 do
        x, x1, x2= context:positionOfBar (period);
        for Level = 1 , Number ,  1 do
            if Alert[Level]:hasData(period) then
                if Alert[Level][period]== 1 then
                    visible, y = context:pointOfPrice (AlertLevel[Level][period]);
                    width, height = context:measureText (1,  "\225", 0);
                    context:drawText (1,   "\225", UpTrendColor, -1,  x-width/2 ,  y , x+width/2 , y+height, 0 );    
                elseif Alert[Level][period]== -1 then
                    visible, y = context:pointOfPrice (AlertLevel[Level][period]);
                    width, height = context:measureText (1,  "\226", 0);
                    context:drawText (1,   "\226", DownTrendColor, -1,  x-width/2  ,  y-height, x+width/2 ,y, 0 );
                end
            end
        end
    end
    DrawLabel(label1, context);
    DrawLabel(label2, context);
    DrawLabel(label3, context);
    DrawLabel(label4, context);
    DrawLabel(label5, context);
	DrawLabel(label6, context);
end

function DrawLabel(label, context)
    if label.Text ~= nil then
        local visible, y = context:pointOfPrice(label.Rate);
        local width, height = context:measureText(2, label.Text, 0);
        local x;
        local pos;
        if ShowLabel == "left" then
            x = context:positionOfDate(label.DateEnd);
            pos = context.RIGHT + context.TOP;
        else
            x = context:positionOfDate(label.Date) - width;
            pos = context.LEFT + context.TOP;
        end
        context:drawText(2, label.Text, LabelColor, LabelBackgroundColor, x, y - height, x + width, y, pos);
    end
end

function  Initialization ()
    SendEmail = instance.parameters.SendEmail;
    local i;
    for i = 1, Number , 1 do 
        Label[i]=instance.parameters:getString("Label" .. i);
        ON[i]=instance.parameters:getBoolean("ON" .. i);
    end
    if SendEmail then
        Email = instance.parameters.Email;
    else
        Email = nil;
    end
    
    assert(not (SendEmail and (Email == "" or Email == nil )), "E-mail address must be specified");
    PlaySound = instance.parameters.PlaySound;
    if PlaySound then
        for i = 1, Number , 1 do 
            Up[i] = instance.parameters:getString("Up" .. i);
            Down[i] = instance.parameters:getString("Down" .. i);
        end
    else 
        for i = 1, Number , 1 do 
            Up[i] = nil;
            Down[i] = nil;
        end
    end
    for i = 1, Number , 1 do 
        assert( not(PlaySound  and (Up[i] == "" or Up[i] == nil ) ), "Sound file must be chosen");
        assert (not (PlaySoundand  and (Down[i] == "" or Down[i] == nil)), "Sound file must be chosen");
    end
    RecurrentSound = instance.parameters.RecurrentSound;
    for i = 1, Number , 1 do 
        U[i] = nil;
        D[i] = nil;     
    end
end

local ID=0;
local ids = {};
function New(period, id)
    if ids[period] == nil then
        ids[period] = {};
    end
    if ids[period][id] == nil then
        ids[period][id] = ID + 1;
        ID = ID + 1;
    end
    return ids[period][id];
end

function Update(period)
    local init = Step;
    local quant = Step;
    local maxVal = Max;
    local lastHighest = 0;
    local lastLowest = 0;
    local high = 0;
    local low = 0;
    local prevHigh = 0;
    local prevLow = 0;
    
    if period < first then
	   	ID=0;
        return;
	elseif period == first then	
		ID=0;
    end
    
    high = source.high[period];
    low = source.low[period];
    prevHigh = source.high[period - 1];
    prevLow = source.low[period - 1];
    if (period == first) then
        tradeHigh[period] = prevHigh;
        tradeLow[period] = prevLow;
        position[period] = -1;
        parOp[period] = prevHigh;
        af[period] = 0;
    else
        parOp[period] = parOp[period - 1];
        position[period] = position[period - 1];
        tradeHigh[period] = tradeHigh[period - 1];
        tradeLow[period] = tradeLow[period - 1];
        af[period] = af[period - 1];
    end
    lastHighest = tradeHigh[period];
    lastLowest = tradeLow[period];
    if high > lastHighest then
        tradeHigh[period] = high;
    end

    if low < lastLowest then
        tradeLow[period] = low;
    end

    if position[period] == 1 then
        if (low < parOp[period]) then
            position[period] = -1;
            SAR[period] = lastHighest;
            tradeHigh[period] = high;
            tradeLow[period] = low;
            af[period] = init;
            parOp[period] = SAR[period] + af[period] * (tradeLow[period] - SAR[period]);
            if (parOp[period] < high) then
                parOp[period] = high;
            end
            if (parOp[period] < prevHigh) then
                parOp[period] = prevHigh;
            end
        else
            SAR[period] = parOp[period];
            if (tradeHigh[period] > tradeHigh[period - 1] and af[period] < maxVal) then
                af[period] = af[period] + quant;
                if af[period] > maxVal then
                    af[period] = maxVal;
                end
            end

            parOp[period] = SAR[period] + af[period] * (tradeHigh[period] - SAR[period]);
            if (parOp[period] > low) then
                parOp[period] = low;
            end
            if (parOp[period] > prevLow) then
                parOp[period] = prevLow;
            end
        end
    else
        if (high > parOp[period]) then
            position[period] = 1;
            SAR[period] = lastLowest;
            tradeHigh[period] = high;
            tradeLow[period] = low;
            af[period] = init;
            parOp[period] = SAR[period] + af[period] * (tradeHigh[period] - SAR[period]);
            if (parOp[period] > low) then
                parOp[period] = low;
            end
            if (parOp[period] > prevLow) then
                parOp[period] = prevLow;
            end
        else
            SAR[period] = parOp[period];
            if (tradeLow[period] < tradeLow[period - 1] and af[period] < maxVal) then
                af[period] = af[period] + quant;
                if af[period] > maxVal then
                    af[period] = maxVal;
                end
            end

            parOp[period] = SAR[period] + af[period] * (tradeLow[period] - SAR[period]);
            if (parOp[period] < high) then
                parOp[period] = high;
            end
            if (parOp[period] < prevHigh) then
                parOp[period] = prevHigh;
            end
        end
    end
    
    if position[period]== 1 
        and  position[period-1]~= 1 
    then
        Alert[1][period]=1;
        AlertLevel[1][period]=  SAR[period] 
    elseif position[period]== -1
        and  position[period-1]~= -1 
    then
        Alert[1][period]=-1;
        AlertLevel[1][period]=  SAR[period] 
    end
	
	if ( not Historical and   period <source:size()-1)
	    or  (  Historical and   period < source:size()-1 - Lookback)
	then
	    return;
	end
		
    local p =FindLast(period);
    local Delta;
    if p~=0 then
        if position[p] == 1 then
            Delta=math.abs(SAR[p] - source.high[p]);
			 
            --Start Line
            core.host:execute("drawLine", New(p, 1), source:date(p), source.high[p], source:date(period), source.high[p], StartLineColor, style1, width1, win32.formatNumber(source.high[p], false, source:getPrecision()));
            
            --Stop Line
            core.host:execute("drawLine", New(p, 2), source:date(p), SAR[p], source:date(period), SAR[p], StopLineColor, style2, width2, win32.formatNumber(SAR[p], false, source:getPrecision()) );
            
            --1. Target
            core.host:execute("drawLine", New(p, 3), source:date(p), source.high[p]+Delta*Level1, source:date(period), source.high[p]+Delta*Level1, TargetLineColor1, style3, width3 , win32.formatNumber(source.high[p]+Delta*Level1, false, source:getPrecision()));
            
            --2. Target
            core.host:execute("drawLine", New(p, 4), source:date(p), source.high[p]+Delta*Level2, source:date(period), source.high[p]+Delta*Level2, TargetLineColor2, style4, width4, win32.formatNumber(source.high[p]+Delta*Level2, false, source:getPrecision()));
            
            --3. Target
            core.host:execute("drawLine", New(p, 5), source:date(p), source.high[p]+Delta*Level3, source:date(period), source.high[p]+Delta*Level3, TargetLineColor3, style5, width5, win32.formatNumber(source.high[p]+Delta*Level3, false, source:getPrecision()));
            if Level4~= 0 then
                --Trigger
                core.host:execute("drawLine", New(p, 6), source:date(p), source.high[p]+source:pipSize()*Level4, source:date(period), source.high[p]+source:pipSize()*Level4, TargetLineColor4, style6, width6, win32.formatNumber(source.high[p]+source:pipSize()*Level4, false, source:getPrecision()));
			end
            if LabelBackground then
                label1.Text = string.format("Entry : %s"
                    , win32.formatNumber(source.high[p], false, source:getPrecision()));
                label1.Date = source:date(period);
                label1.DateEnd = source:date(p);
                label1.Rate = source.high[p];
                label2.Text = string.format("Stop : %s (%s)"
                    , win32.formatNumber(SAR[p], false, source:getPrecision())
                    , win32.formatNumber(math.abs(SAR[p] - source.low[p]) / source:pipSize(), false, 1));
                label2.Date = source:date(period);
                label2.DateEnd = source:date(p);
                label2.Rate = SAR[p];
                label3.Text = string.format("1. Target : %s (%s)"
                    , win32.formatNumber(source.high[p] + Delta * Level1, false, source:getPrecision())
                    , win32.formatNumber(( Delta * Level1) / source:pipSize(), false, 1));
                label3.Date = source:date(period);
                label3.DateEnd = source:date(p);
                label3.Rate = source.high[p]+Delta*Level1;
                label4.Text = string.format("2. Target : %s (%s)"
                    , win32.formatNumber(source.high[p] + Delta * Level2, false, source:getPrecision())
                    , win32.formatNumber(( Delta * Level2 ) / source:pipSize(), false, 1));
                label4.Date = source:date(period);
                label4.DateEnd = source:date(p);
                label4.Rate = source.high[p]+Delta*Level2;
                label5.Text = string.format("3. Target : %s (%s)"
                    , win32.formatNumber(source.high[p] + Delta * Level3, false, source:getPrecision())
                    , win32.formatNumber(( Delta * Level3) / source:pipSize(), false, 1));
                label5.Date = source:date(period);
                label5.DateEnd = source:date(p);
                label5.Rate = source.high[p]+Delta*Level3;
				label6.Text = string.format("Trigger : %s (%s)"
                    , win32.formatNumber(source.high[p] +source:pipSize()*Level4, false, source:getPrecision())
                    , win32.formatNumber(Level4, false, 1));
                label6.Date = source:date(period);
                label6.DateEnd = source:date(p);
                label6.Rate = source.high[p]+source:pipSize()*Level4;
            elseif ShowLabel ~= "no" then
                local label1 = string.format("Entry : %s"
                    , win32.formatNumber(source.high[p], false, source:getPrecision()));
                local label2 = string.format("Stop : %s (%s)"
                    , win32.formatNumber(SAR[p], false, source:getPrecision())
                    , win32.formatNumber(math.abs(SAR[p] - source.low[p]) / source:pipSize(), false, 1));
                local label3 = string.format("1. Target : %s (%s)"
                    , win32.formatNumber(source.high[p] + Delta * Level1, false, source:getPrecision())
                    , win32.formatNumber(( Delta * Level1) / source:pipSize(), false, 1));
                local label4 = string.format("2. Target : %s (%s)"
                    , win32.formatNumber(source.high[p] + Delta * Level2, false, source:getPrecision())
                    , win32.formatNumber(( Delta * Level2 ) / source:pipSize(), false, 1));
                local label5 = string.format("3. Target : %s (%s)"
                    , win32.formatNumber(source.high[p] + Delta * Level3, false, source:getPrecision())
                    , win32.formatNumber(( Delta * Level3) / source:pipSize(), false, 1));
				local label6 = string.format("Trigger : %s (%s)"
                    , win32.formatNumber(source.high[p] + Level4*source:pipSize(), false, source:getPrecision())
                    , win32.formatNumber(Level4, false, 1));
                local date;
                local h_pos;
                if ShowLabel == "left" then
                    date = source:date(p);
                    h_pos = core.H_Right;
                else
                    date = source:date(period);
                    h_pos = core.H_Left;
                end
                core.host:execute("drawLabel1", New(p, 7), date, core.CR_CHART, source.high[p], core.CR_CHART, h_pos, core.V_Top,  font, LabelColor, label1);
                core.host:execute("drawLabel1", New(p, 8), date, core.CR_CHART, SAR[p], core.CR_CHART, h_pos, core.V_Top,  font, LabelColor, label2);
                core.host:execute("drawLabel1", New(p, 9), date, core.CR_CHART, source.high[p]+Delta*Level1, core.CR_CHART, h_pos, core.V_Top,  font, LabelColor, label3);
                core.host:execute("drawLabel1", New(p, 10), date, core.CR_CHART, source.high[p]+Delta*Level2, core.CR_CHART, h_pos, core.V_Top,  font, LabelColor, label4);
                core.host:execute("drawLabel1", New(p, 11), date, core.CR_CHART, source.high[p]+Delta*Level3, core.CR_CHART, h_pos, core.V_Top,  font, LabelColor, label5);
				if Level4~= 0 then
				    core.host:execute("drawLabel1", New(p, 12), date, core.CR_CHART, source.high[p]+source:pipSize()*Level4, core.CR_CHART, h_pos, core.V_Top,  font, LabelColor, label6);
				end
            end
        else
            Delta=math.abs(SAR[p]- source.low[p]);
            
            --Start Line
            core.host:execute("drawLine", New(p, 13), source:date(p), source.low[p], source:date(period), source.low[p], StartLineColor, style1, width1, win32.formatNumber(source.low[p], false, source:getPrecision()));
            
            --Stop Line
            core.host:execute("drawLine", New(p, 14), source:date(p), SAR[p], source:date(period), SAR[p], StopLineColor, style2, width2, win32.formatNumber(SAR[p], false, source:getPrecision()));
            
            --1. Target
            core.host:execute("drawLine", New(p, 15), source:date(p), source.low[p]-Delta*Level1, source:date(period), source.low[p]-Delta*Level1, TargetLineColor1, style3, width3, win32.formatNumber(source.low[p]-Delta*Level1, false, source:getPrecision()));
            
            --2. Target
            core.host:execute("drawLine", New(p, 16), source:date(p), source.low[p]-Delta*Level2, source:date(period), source.low[p]-Delta*Level2, TargetLineColor2, style4, width4, win32.formatNumber(source.low[p]-Delta*Level2, false, source:getPrecision()));
            
            --3. Target
            core.host:execute("drawLine", New(p, 17), source:date(p), source.low[p]-Delta*Level3, source:date(period), source.low[p]-Delta*Level3, TargetLineColor3, style5, width5, win32.formatNumber(source.low[p]-Delta*Level3, false, source:getPrecision()));
			
			if Level4~= 0 then
                --Trigger
                core.host:execute("drawLine", New(p, 18), source:date(p), source.low[p]-source:pipSize()*Level4, source:date(period), source.low[p]-source:pipSize()*Level4, TargetLineColor4, style5, width5, win32.formatNumber(source.low[p]-source:pipSize()*Level4, false, source:getPrecision()));
            end   
            if LabelBackground then
                label1.Text = string.format("Entry : %s"
                    , win32.formatNumber(source.low[p], false, source:getPrecision()));
                label1.Date = source:date(period);
                label1.DateEnd = source:date(p);
                label1.Rate = source.low[p];
                label2.Text = string.format("Stop : %s (%s)"
                    , win32.formatNumber(SAR[p], false, source:getPrecision())
                    , win32.formatNumber(math.abs(SAR[p] - source.low[p]) / source:pipSize(), false, 1));
                label2.Date = source:date(period);
                label2.DateEnd = source:date(p);
                label2.Rate = SAR[p];
                label3.Text = string.format("1. Target : %s (%s)"
                    , win32.formatNumber(source.low[p] - Delta * Level1, false, source:getPrecision())
                    , win32.formatNumber((Delta * Level1) / source:pipSize(), false, 1));
                label3.Date = source:date(period);
                label3.DateEnd = source:date(p);
                label3.Rate = source.low[p]-Delta*Level1;
                label4.Text = string.format("2. Target : %s (%s)"
                    , win32.formatNumber(source.low[p] - Delta * Level2, false, source:getPrecision())
                    , win32.formatNumber((Delta * Level2 ) / source:pipSize(), false, 1));
                label4.Date = source:date(period);
                label4.DateEnd = source:date(p);
                label4.Rate = source.low[p]-Delta*Level2;
                label5.Text = string.format("3. Target : %s (%s)"
                    , win32.formatNumber(source.low[p] - Delta * Level3, false, source:getPrecision())
                    , win32.formatNumber((Delta * Level3) / source:pipSize(), false, 1));
                label5.Date = source:date(period);
                label5.DateEnd = source:date(p);
                label5.Rate = source.low[p]-Delta*Level3;
            elseif ShowLabel ~= "no" then
                local label1 = string.format("Entry : %s"
                    , win32.formatNumber(source.low[p], false, source:getPrecision())  );
                local label2 = string.format("Stop : %s (%s)"
                    , win32.formatNumber(SAR[p], false, source:getPrecision())
                    , win32.formatNumber(math.abs(SAR[p] - source.low[p]) / source:pipSize(), false, 1));
                local label3 = string.format("1. Target : %s (%s)"
                    , win32.formatNumber(source.low[p] - Delta * Level1, false, source:getPrecision())
                    , win32.formatNumber((Delta * Level1 ) / source:pipSize(), false, 1));
                local label4 = string.format("2. Target : %s (%s)"
                    , win32.formatNumber(source.low[p] - Delta * Level2, false, source:getPrecision())
                    , win32.formatNumber((Delta * Level2) / source:pipSize(), false, 1));
                local label5 = string.format("3. Target : %s (%s)"
                    , win32.formatNumber(source.low[p] - Delta * Level3, false, source:getPrecision())
                    , win32.formatNumber(( Delta * Level3) / source:pipSize(), false, 1));
			    local label6 = string.format("Trigger : %s (%s)"
                    , win32.formatNumber(source.low[p] -source:pipSize()*Level4, false, source:getPrecision())
                    , win32.formatNumber( Level4, false, 1));
                local date;
                local h_pos;
                if ShowLabel == "left" then
                    date = source:date(p);
                    h_pos = core.H_Right;
                else
                    date = source:date(period);
                    h_pos = core.H_Left;
                end
                core.host:execute("drawLabel1", New(p, 19), date, core.CR_CHART, source.low[p], core.CR_CHART, h_pos, core.V_Top,  font, LabelColor, label1);
                core.host:execute("drawLabel1", New(p, 20), date, core.CR_CHART, SAR[p], core.CR_CHART, h_pos, core.V_Top,  font, LabelColor, label2);
                core.host:execute("drawLabel1", New(p, 21), date, core.CR_CHART, source.low[p]-Delta*Level1, core.CR_CHART, h_pos, core.V_Top,  font, LabelColor, label3);
                core.host:execute("drawLabel1", New(p, 22), date, core.CR_CHART, source.low[p]-Delta*Level2, core.CR_CHART, h_pos, core.V_Top,  font, LabelColor, label4);
                core.host:execute("drawLabel1", New(p, 23), date, core.CR_CHART, source.low[p]-Delta*Level3, core.CR_CHART, h_pos, core.V_Top,  font, LabelColor, label5);
				if Level4~= 0 then
				    core.host:execute("drawLabel1", New(p, 24), date, core.CR_CHART, source.low[p]-source:pipSize()*Level4, core.CR_CHART, h_pos, core.V_Top,  font, LabelColor, label6);
				end
            end
        end
    end
	
	if period < source:size()-1 then
	    return;
	end
	
    if Live~= "Live" then
        period=period-1;
        Shift=1;
    else
        Shift=0;
    end
    Activate (1, period);
end

function ReleaseInstance()
    core.host:execute("deleteFont", font);
end

function FindLast(period)

local p=0;


for i= period, first, -1 do

    if position[i] ~=  position[i-1] then
    p=i;
    break;
    end
end

  return p;

end




function Activate (id, period)


 
   
   
  
  
      if id == 1  and ON[id]  then
      
           
            if position[period] == 1  
            and   position[period-1] ~= 1  
            then
                       
                            
            
             D[id] = nil;
                           
                              if U[id]~=source:serial(period) 
                              and period == source:size()-1-Shift
                              and not FIRST 
                              and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag~= false))
                              then
                              
                              U[id]=source:serial(period);
                              SoundAlert(Up[id]);
                              EmailAlert(  Label[id], " Open Long ");
                              SendAlert( Label[id]," Open Long "); 
                              Pop(Label[id], " Open Long ", period );  
                              OnlyOnceFlag=false;
                              end
                              
            elseif position[period] == -1  
            and   position[period-1] ~= -1  
            then            
             
             U[id] = nil;
           
                             if  D[id]~=source:serial(period)
                             and period == source:size()-1-Shift
                             and not FIRST 
                             and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag~= false))
                             then                            
                             D[id]=source:serial(period);
                             SoundAlert(Down[id]);             
                             EmailAlert( Label[id] , " Open Short ");                                 
                             Pop(Label[id], " Open Short ", period );      
                             SendAlert( Label[id]," Open Short ");
                             OnlyOnceFlag=false;
                             end               
             end
            
      
     
      end
      
           
        if FIRST then
        FIRST=false;      
        end        

end


-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
end    
 

function SoundAlert(Sound)
 if not PlaySound then
 return;
 end

  terminal:alertSound(Sound, RecurrentSound);
end

 


function EmailAlert( label , Subject)

if not SendEmail then
return
end
 
   local now = core.host:execute("getServerTime");
    now = core.host:execute ("convertTime",  core.TZ_EST, ToTime, now);
    local DATA = core.dateToTable (now);
    
   local delim = "\013\010";  
   local Note=  profile:id().. delim.. " Label : " ..label  .. delim .. " Alert : " .. Subject ;   
   local Symbol= "Instrument : " .. source:instrument() ;
   local Time =  " Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec;  
   
   
    local TF= "Time Frame : " .. source:barSize();       
    local text = Note  .. delim ..  Symbol .. delim .. TF  .. delim .. Time;
    
    
 
   terminal:alertEmail(Email, profile:id(), text);
end

function Pop(label , Subject )
  
   if not Show then
   return;
   end
   
   local now = core.host:execute("getServerTime");
    now = core.host:execute ("convertTime",  core.TZ_EST, ToTime, now);
    local DATA = core.dateToTable (now);
    
    
    
   local delim = "\013\010";  
   local Note=  profile:id().. delim.. " Label : " ..label  .. delim .. " Alert : " .. Subject ;   
   local Symbol= "Instrument : " .. source:instrument() ;
   local Time =  " Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec;  
   
   
    local TF= "Time Frame : " .. source:barSize();       
    local text = Note  .. delim ..  Symbol .. delim .. TF  .. delim .. Time;
    
   
   core.host:execute ("prompt", 1, label , text );
end


function SendAlert(label ,Subject, period)
    if not ShowAlert then
        return;
    end
    
    local now = core.host:execute("getServerTime");
    now = core.host:execute ("convertTime",  core.TZ_EST, ToTime, now);
    local DATA = core.dateToTable (now);
    
    
   local delim = "\013\010";  
   local Note=  profile:id().. delim.. " Label : " ..label  .. delim .. " Alert : " .. Subject ;   
   local Symbol= "Instrument : " .. source:instrument() ;
   local Time =  " Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec;  
   
 
    local TF= "Time Frame : " .. source:barSize();       
    local text = Note  .. delim ..  Symbol .. delim .. TF  .. delim .. Time;
    
 
    terminal:alertMessage(source:instrument(), source[NOW], text, now);
end

 
 
 



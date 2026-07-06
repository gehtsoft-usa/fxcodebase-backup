-- Id: 20528
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3080

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
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
    indicator:name("Relative Stength Index with zone and trend highlighting");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Classic Oscillators");

    indicator.parameters:addInteger("N", "Number of Periods", "", 17, 2, 1000);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrRSI", "Line (neutral)", "", core.rgb(0, 255, 255));
    indicator.parameters:addColor("clrRSIUp", "Line (uptrend)", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clrRSIDn", "Line (downtrend)", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthRSI", "Line Width (in pixels)", "", 1, 1, 5);
    indicator.parameters:addInteger("styleRSI", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleRSI", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addBoolean("fill", "Highlight Areas over/under levels", "", true);
    indicator.parameters:addInteger("transparency", "Highlight transparency (%)", "", 30);
    indicator.parameters:addColor("clrFill", "Over Level Fill Color", "", core.rgb(255, 255, 0));
    indicator.parameters:addColor("clrBg", "Background Fill Color", "Leave this parameter in its default value", core.COLOR_BACKGROUND);
    
    
      indicator.parameters:addBoolean("Exit", "Reset on Zone Exit", "", true);
    
    
     indicator.parameters:addGroup("Averages Calculation");
     
     indicator.parameters:addBoolean("MA_Filter", "Use MA Filter", "", true);
    indicator.parameters:addString("Method", "Method", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Method", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Method", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Method", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Method", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Method", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Method", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Method", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Method", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Method", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Method", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Method", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Method", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Method", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Method", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Method", "JSmooth", "", "JSmooth");
    indicator.parameters:addStringAlternative("Method", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Method", "ARSI", "", "ARSI");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "", "VIDYA");
    indicator.parameters:addStringAlternative("Method", "HPF", "", "HPF");
    indicator.parameters:addStringAlternative("Method", "VAMA", "", "VAMA");


    indicator.parameters:addInteger("Period", "Period", "", 20);

    indicator.parameters:addGroup("Levels");
    indicator.parameters:addInteger("overbought", "Overbought level", "", 60, 0, 100);
    indicator.parameters:addInteger("oversold", "Oversold level", "", 40, 0, 100);
    indicator.parameters:addInteger("level_overboughtsold_width", "Level Line Width (in pixels)", "", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Level Line Style", "", core.LINE_DOT);
    indicator.parameters:addColor("level_overboughtsold_color", "","", core.COLOR_CUSTOMLEVEL);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
    
    
    indicator.parameters:addGroup("Alert Parameters");  
    indicator.parameters:addString("Live", "End of Turn / Live", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
    indicator.parameters:addStringAlternative("Live", "Live", "", "Live");   

    indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true);
    indicator.parameters:addBoolean("OnlyOnce", "Alert Once", "Subsequent Alert will be ignored.", false);    
    indicator.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
    
    indicator.parameters:addGroup("Alert Style");
    indicator.parameters:addColor("UpTrendColor", "Up Trend Color", "", core.rgb(0, 0, 255));
    indicator.parameters:addColor("DownTrendColor", "Down Trend Color", "", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("Size", "Label Size", "", 10, 1 , 100);
    
    indicator.parameters:addGroup("Alerts Sound");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", true);    
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);

    
    indicator.parameters:addGroup("Alerts Email");   
    indicator.parameters:addBoolean("SendEmail", "Send Email", "", true);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);

    
    Parameters (1, "Zone");    
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
local RecurrentSound ,SoundFile  ;
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
local font;
local ShowAlert;
local Shift=0; 
local Exit;

local Method, Period, Indicator;

local n;
local source;
local first1, first2;
local pos, neg;
local wmap, wman;
local rsi;
local clr, clrUp, clrDn;
local trend;

local fill, clrFill, clrBg;
local ob_level;
local ob_highlight1;
local ob_highlight2;
local os_level;
local os_highlight1;
local os_highlight2;
local Signal;
local MA_Filter;
function Prepare(onlyName)
     source = instance.source;
    n = instance.parameters.N;
    
    
     Method= instance.parameters.Method;
     Period= instance.parameters.Period;
     MA_Filter= instance.parameters.MA_Filter;
     Exit= instance.parameters.Exit;
    
 
    local name = profile:id() .. "(" .. source:name() .. "," .. n .. ")";
    instance:name(name);
    if onlyName then
        return ;
    end
    
    OnlyOnceFlag=true;
    FIRST=true;
    OnlyOnce = instance.parameters.OnlyOnce;
    ShowAlert = instance.parameters.ShowAlert;
    Show = instance.parameters.Show;
    Live = instance.parameters.Live;
    UpTrendColor = instance.parameters.UpTrendColor;
    DownTrendColor = instance.parameters.DownTrendColor;
    Size=instance.parameters.Size;
    font = core.host:execute("createFont", "Wingdings", Size, false, false);
    

   assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");   
    Indicator = core.indicators:create("AVERAGES", source, Method,Period);
   
    first1 = source:first() + 1;
    pos = instance:addInternalStream(first1, 0);
    neg = instance:addInternalStream(first1, 0);
    wmap = core.indicators:create("WMA", pos, n);
    wman = core.indicators:create("WMA", neg, n);
    first2 = math.max(Indicator.DATA:first(),wmap.DATA:first());

    clr = instance.parameters.clrRSI;
    clrUp = instance.parameters.clrRSIUp;
    clrDn = instance.parameters.clrRSIDn;


    RSI = instance:addStream("RSI", core.Line, name, "RSI", clr, first2);
    RSI:setWidth(instance.parameters.widthRSI);
    RSI:setStyle(instance.parameters.styleRSI);
    RSI:setPrecision(2);
    
    Signal = instance:addInternalStream(0, 0);

    trend = instance:addInternalStream(0, 0);

    RSI:addLevel(0, core.LINE_NONE);
    RSI:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    RSI:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    RSI:addLevel(100, core.LINE_NONE);

    fill = instance.parameters.fill;
    if fill then
        clrFill = instance.parameters.clrFill;
        clrBg = instance.parameters.clrBg;
        ob_level = instance.parameters.overbought;
        ob_highlight1 = instance:addInternalStream(first2, 0);
        ob_highlight2 = instance:addInternalStream(first2, 0);
        instance:createChannelGroup("ob", "ob", ob_highlight1, ob_highlight2, clrFill, 100 - instance.parameters.transparency);
        os_level = instance.parameters.oversold;
        os_highlight1 = instance:addInternalStream(first2, 0);
        os_highlight2 = instance:addInternalStream(first2, 0);
        instance:createChannelGroup("os", "os", os_highlight1, os_highlight2, clrFill, 100 - instance.parameters.transparency);
    end
    
    Initialization();
    
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
    assert(not(SendEmail) or (SendEmail and Email ~= ""), "E-mail address must be specified");
    
    
     PlaySound = instance.parameters.PlaySound;
    if PlaySound then
    
      for i = 1, Number , 1 do 
      Up[i]=instance.parameters:getString("Up" .. i);
      Down[i]=instance.parameters:getString("Down" .. i);
      end
    
    else 
    
      for i = 1, Number , 1 do 
       Up[i]=nil;
      Down[i]=nil;
      end
        
    end
    
        for i = 1, Number , 1 do 
      assert(not(PlaySound) or (PlaySound and Up[i] ~= "") or (PlaySound and Up[i] ~= ""), "Sound file must be chosen"); 
     assert(not(PlaySound) or (PlaySound and Down[i] ~= "") or (PlaySound and Down[i] ~= ""), "Sound file must be chosen");
    end
     
    RecurrentSound = instance.parameters.RecurrentSound;
    
    for i = 1, Number , 1 do 
    U[i] = nil;
    D[i] = nil;     
    end
         
end    


function Update(period, mode)
    
    
    Indicator:update(mode);
    
    Calculate (period, mode)    
    
    if Live~= "Live" then
    period=period-1;
    Shift=1;
    else
    Shift=0;
    end
    
    core.host:execute ("removeLabel", source:serial(period));     
     
    
    if period < first2 then
    return;
    end
    
    Activate (1, period);
end


function Calculate (period, mode)

    if period <first1 then
    return;
    end
    
    local diff = source[period] - source[period - 1];
    if diff >= 0 then
        pos[period] = diff;
        neg[period] = 0;
    else
        neg[period] = -diff;
        pos[period] = 0;
    end
    
    wmap:update(mode);
    wman:update(mode);
    if period < first2 then
    return;
    end
    local p, n, rs;
    p = wmap.DATA[period];
    n = wman.DATA[period];

    if n == 0 then
        RSI[period] = 0;
    else
        rs = p / n;
        RSI[period] = 100 - (100 / (1 + rs));
    end
    local t = trend[period - 1];
    if RSI[period - 1] >= ob_level
        and    RSI[period] < ob_level
        and (source[period]> Indicator.DATA[period] and MA_Filter or not MA_Filter )
    then
        t = -1;
    elseif RSI[period - 1] <= os_level
        and  RSI[period] > os_level
        and (source[period]< Indicator.DATA[period] and MA_Filter or not MA_Filter )
    then
        t = 1;
    end
    
    if Exit then
        if RSI[period] < ob_level
            and   RSI[period-1] >= ob_level
            and Signal[period-1]== 1
        then
            t=0;
        end
        if RSI[period] > os_level
            and   RSI[period-1] <= os_level
            and Signal[period-1]== -1
        then
            t=0;
        end
    end 
    if t == 0 then
        RSI:setColor(period, clr);
        Signal[period]=0;
    elseif t == 1 then
        RSI:setColor(period, clrUp);
        Signal[period]=1;
    elseif t == -1 then
        RSI:setColor(period, clrDn);
        Signal[period]=-1;
    end

    trend[period] = t;
    if fill and period < first2 then
        return;
    end
    
    ob_highlight1[period] = RSI[period];
    ob_highlight1:setColor(period, clrFill);
    ob_highlight2[period] = ob_level;
    if RSI[period] < ob_level then
        if RSI[period - 1] < ob_level then
            ob_highlight1[period] = nil;
        else
            ob_highlight1:setColor(period, clrBg);
        end
    else
        if RSI[period - 1] < ob_level then
            ob_highlight1[period - 1] = RSI[period - 1];
            ob_highlight1:setColor(period - 1, clrBg);
        end
    end
    os_highlight1[period] = RSI[period];
    os_highlight1:setColor(period, clrFill);
    os_highlight2[period] = os_level;

    if RSI[period] > os_level then
        if RSI[period - 1] > os_level then
            os_highlight1[period] = nil;
        else
            os_highlight1:setColor(period, clrBg);
        end
    else
        if RSI[period - 1] > os_level then
            os_highlight1[period - 1] = RSI[period - 1];
            os_highlight1:setColor(period - 1, clrBg);
        end
    end
end

function ReleaseInstance()
       core.host:execute("deleteFont", font);
end

function Activate (id, period)
    if id == 1  and ON[id]  then
        if  Signal[period] == 1 
            and  Signal[period-1] ~= 1 
            and (source[period] > Indicator.DATA[period] and MA_Filter or not MA_Filter )
        then
            core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, RSI[period], core.CR_CHART, core.H_Center, core.V_Bottom, font, UpTrendColor, "\225");
            D[id] = nil;
            if U[id]~=source:serial(period) 
                and period == source:size()-1-Shift
                and not FIRST 
            then
                OnlyOnceFlag=false;
                U[id]=source:serial(period);
                SoundAlert(Up[id]);
                EmailAlert(  Label[id], " Up ", period);
                SendAlert(" Up ");  
                Pop(Label[id], " Up " );      
            end
        elseif  Signal[period] == -1 
            and  Signal[period-1] ~= -1 
            and (source[period]< Indicator.DATA[period]and MA_Filter or not MA_Filter )
        then
            core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, RSI[period], core.CR_CHART, core.H_Center, core.V_Top, font, DownTrendColor, "\226");                           
            U[id] = nil;

            if  D[id]~=source:serial(period)
                and period == source:size()-1-Shift
                and not FIRST 
            then
                OnlyOnceFlag=false;
                D[id]=source:serial(period);
                SoundAlert(Down[id]);             
                EmailAlert( Label[id] , " Down ", period);    
                
                Pop(Label[id], " Down " );      
                SendAlert(" Down ");
            end
        end
    end

    if FIRST then
        FIRST=false;
    end
end


function AsyncOperationFinished (cookie, success, message)
end


function Pop(label , note)
  
   if not Show then
   return;
   end
  
  core.host:execute ("prompt", 1, label ,   " ( " .. source:instrument() .. " ) "  ..   label .. " : " .. note );
  

end


function SendAlert(message)
    if not ShowAlert then
        return;
    end
 
    terminal:alertMessage(source:instrument(), source[NOW], message, source:date(NOW));
end

function SoundAlert(Sound)
 if not PlaySound then
 return;
 end

  if OnlyOnce and OnlyOnceFlag== false then
 return;
 end
 
  terminal:alertSound(Sound, RecurrentSound);
end

 


function EmailAlert( label , Subject, period)

if not SendEmail then
return
end

 if OnlyOnce and OnlyOnceFlag== false then
 return;
 end

 
    local date = source:date(period);
    local DATA = core.dateToTable (date);
    
    
   local delim = "\013\010";  
   local Note=  profile:id().. delim.. " Label : " ..label  .. delim .. " Alert : " .. Subject ;   
   local Symbol= "Instrument : " .. source:instrument() ;
   local Time =  " Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec;  
   
    
    local Time =  " Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec;    
    local text = Note  .. delim ..  Symbol   .. delim .. Time; 
 
   terminal:alertEmail(Email, profile:id(), text);
end
     



-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66622

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
    indicator:name("MCP MTF ICH With Alert.Kijun-Tenkan");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    
    indicator.parameters:addGroup("Calculation");    
    indicator.parameters:addString("Indicator", "Indicator", "", "ICH");
    indicator.parameters:setFlag("Indicator",core.FLAG_INDICATOR);

    indicator.parameters:addBoolean("Chart" , "Use Chart Price Source", "", true); 
    
    AddParam(1, "m1");    
    AddParam(2, "m5");    
    AddParam(3, "m15");    
    AddParam(4, "m30");
    AddParam(5, "H1");
    AddParam(6, "H2");    
    AddParam(7, "H3");    
    AddParam(8, "H4");    
    AddParam(9, "H6");
    AddParam(10, "H8");
    AddParam(11, "D1");    
    AddParam(12, "W1");
    AddParam(13, "M1");
    
    
    indicator.parameters:addGroup("Alerts Sound");   
     
    indicator.parameters:addInteger("ToTime", "Convert the date to", "", 6);
    indicator.parameters:addIntegerAlternative("ToTime", "EST", "", 1);
    indicator.parameters:addIntegerAlternative("ToTime", "UTC", "", 2);
    indicator.parameters:addIntegerAlternative("ToTime", "Local", "", 3);
    indicator.parameters:addIntegerAlternative("ToTime", "Server", "", 4);
    indicator.parameters:addIntegerAlternative("ToTime", "Financial", "", 5);
    indicator.parameters:addIntegerAlternative("ToTime", "Display", "", 6);
    
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", false);    
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);
    
    indicator.parameters:addFile("Sound",   "Alert Sound", "", "");
    indicator.parameters:setFlag("Sound", core.FLAG_SOUND);
    indicator.parameters:addGroup("Alerts Dialog box");  
    indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true);
    
    indicator.parameters:addGroup("Alerts Email");   
    indicator.parameters:addBoolean("SendEmail", "Send Email", "", false);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL); 
       
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UP", "Color for Up Trend", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DN", "Color for Down Trend", "", core.rgb(255, 0, 0));    
    indicator.parameters:addColor("NO", "Color for Unclear Trend", "", core.rgb(255, 128, 0));
    
    indicator.parameters:addColor("AlertColor", "Alert Color", "", core.rgb(0, 0, 255));
    
    indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0));
    indicator.parameters:addDouble("Size", "As % of Cell", "", 90);
    indicator.parameters:addInteger("VShift", "Vertical Shift ", "Shift", 75); 
end

function AddParam(id, frame )
    
    indicator.parameters:addGroup(id.. ". Time Frame");     
    indicator.parameters:addString("On".. id , "Show This Slot", "","Alert");      
    indicator.parameters:addStringAlternative("On".. id, "View", "View" , "View");
    indicator.parameters:addStringAlternative("On".. id, "Alert", "Alert" , "Alert");
    indicator.parameters:addStringAlternative("On".. id, "Off", "Off" , "Off");
    
    indicator.parameters:addString("TF" .. id,  "Time frame", "", frame);
    indicator.parameters:setFlag("TF" .. id, core.FLAG_PERIODS);
    
    indicator.parameters:addString("Pair" .. id, "Pair", "", "EUR/USD");
    indicator.parameters:setFlag("Pair" .. id, core.FLAG_INSTRUMENTS);
end

local On={};
local Email;
local SendEmail; 
local Sound;
local RecurrentSound ,SoundFile  ;
local Show;
local PlaySound;

local UP, DN, NO,VShift;
local source = nil;
local TF={};
local Pair={};
local L={};    
local host;
local offset;
local weekoffset;
local SourceData={};
local loading={};  
local Size;
local USE={};
local Count=13;
local Number;
local Chart ;
local Label;
local Indicator={};
local day_offset, week_offset;

local Last={};
local Up={};
local Down={};
local AlertColor;
local ToTime;
    
-- Routine
function Prepare(nameOnly)

    source = instance.source;
 
    local name = profile:id() .. "(" .. source:name()  .. ")";
    instance:name(name); 
    if   (nameOnly) then
        return;
    end
        
    Chart=instance.parameters.Chart;
 
    UP = instance.parameters.UP;
    DN = instance.parameters.DN;
    NO = instance.parameters.NO;
    VShift = instance.parameters.VShift;
    
    ToTime = instance.parameters.ToTime;
    
    if ToTime == 1 then
    ToTime = core.TZ_EST;
    elseif ToTime == 2 then
    ToTime = core.TZ_UTC;
    elseif ToTime == 3 then
    ToTime = core.TZ_LOCAL;
    elseif ToTime == 4 then
    ToTime = core.TZ_SERVER;
    elseif ToTime == 5 then
    ToTime = core.TZ_FINANCIAL;
    elseif ToTime == 6 then
    ToTime = core.TZ_TS;
    end
    
    AlertColor = instance.parameters.AlertColor;
    
    Label = instance.parameters.Label;
    Shift = instance.parameters.Shift;
    Size = instance.parameters.Size;
    
    day_offset = core.host:execute("getTradingDayOffset");
    week_offset = core.host:execute("getTradingWeekOffset");
    
    host = core.host;
    offset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");
    
    local i;
 
    Number=0;
    for i = 1, Count, 1 do
    
        USE[i]=instance.parameters:getString("On" .. i)~= "Off";
        if USE[i]  then
            Number=Number+1;
    	    On[Number]=instance.parameters:getString("On" .. i)== "Alert";
            if  Chart   then    	
                Pair[Number]=source:name();      
            else
                Pair[Number]= instance.parameters:getString("Pair" .. i);
            end
            TF[Number]= instance.parameters:getString("TF" .. i);     
        end       	         
    end
   
    local tmpprofile = core.indicators:findIndicator(instance.parameters:getString("Indicator"));
    local tmpparams = instance.parameters:getCustomParameters("Indicator");
    Test = tmpprofile:createInstance(source, tmpparams);
    local First= Test.DATA:first()

    for i = 1, Number, 1 do    
        if (TF[i] == source:barSize() and   Pair[i] == source:name())     then
            SourceData[i]=source;
            loading[i]= false;
        else     
            SourceData[i] = core.host:execute("getSyncHistory", Pair[i], TF[i], source:isBid(), math.min(300, First) , 200+i, 100+i);       
            loading[i]= true;    	
        end 	
        Indicator[i] = tmpprofile:createInstance(SourceData[i], tmpparams);        
    end

    SendEmail = instance.parameters.SendEmail;
 
    if SendEmail then
        Email = instance.parameters.Email;
    else
        Email = nil;
    end
    
    assert(not(SendEmail) or (SendEmail and Email ~= ""), "E-mail address must be specified");
      
    RecurrentSound= instance.parameters.RecurrentSound;
    Show= instance.parameters.Show; 
    PlaySound = instance.parameters.PlaySound;
    
    if PlaySound then 
        Sound=instance.parameters.Sound; 
    else  
        Sound=nil;
    end
     
     
    assert(not(PlaySound) or (PlaySound and Sound ~= "") or (PlaySound and Sound ~= ""), "Sound file must be chosen"); 
       
     
    instance:ownerDrawn(true);
    core.host:execute ("setTimer", 1, 1);    
end

function ReleaseInstance()
core.host:execute ("killTimer", 1);
end 


function   Initialization(id,period)

    local Candle;
    Candle = core.getcandle(TF[id], source:date(period), offset, weekoffset);

  
    if loading[id] or SourceData[id]:size() == 0 then
        return false ;
    end

    
    if period < source:first() then
        return false;
    end

    local p = core.findDate(SourceData[id], Candle, false);

    -- candle is not found
    if p < 0 then
        return false;
    else return p;    
    end
    
end


function Update(period)
     
end

 
function Draw(stage, context)
    if stage ~= 2 then
        return;
    end
    
    local Flag = false;    
 
    for j = 1, Number, 1 do    	    
    	if loading[j] then    
    	Flag=true;
    	end     
    end    
    
    local Background;
    
    if Flag then
        return;
    end
      
    local xCell = (context:right () -context:left ())/(Number+1);    	
    local yCell = (context:bottom () -context:top ())/15;    	    

    for i = 1, Number, 1 do     
        local Color;
        Background=-1;
                     
        if Up[i]== SourceData[i]:serial(SourceData[i]:size()-1)  then
            Color=UP;
        elseif Down[i]== SourceData[i]:serial(SourceData[i]:size()-1) then
            Color=DN;
        else
            Color=NO;
        end    	

        if Last[i]== SourceData[i]:serial(SourceData[i]:size()-1) then
            Background=AlertColor;
        end
                             
        context:createFont (1, "Arial", (xCell/12)*(Size/100), yCell*(Size/100), 0);    

        width, height = context:measureText (1, tostring(Pair[i]), 0)    	    
        context:drawText (1, tostring(Pair[i]), Label, -1, context:left ()+(i-1)*xCell    , context:top ()+VShift+yCell/4, context:left ()+(i-1)*xCell + width, context:top ()+VShift+yCell/4 + height, 0);

        width, height = context:measureText (1, tostring(TF[i]), 0)    	    	
        context:drawText (1, tostring(TF[i]), Color, Background, context:left ()+(i-1)*xCell    , context:top ()+VShift+yCell*(5/4), context:left ()+(i-1)*xCell + width, context:top ()+VShift+yCell*(5/4) + height, 0);       
     end     	
end

-- the function is called when the async operation is finished

function AsyncOperationFinished(cookie)

    local j;     
    local Flag = false;    
    local Count=0;    
       
    for j = 1, Number, 1 do
    	
    	      if cookie == (100+j) then
    	      loading[j] = true;
    	      elseif  cookie == (200+j) then
    	      loading[j] = false;  
    	          
              end
    	      
    	if loading[j] then
    	Count=Count+1;
    	Flag=true;
    	end     
 
    end    
        
    if cookie== 1  and not Flag then
        
        for i = 1, Number, 1 do
            Indicator [i]:update(core.UpdateLast);     	
            Evaluate(i);    	    	    
        end          
    end 

    if Flag then
        core.host:execute ("setStatus", " Loading ".. (Number-Count) .."/" .. Number);
    else
        core.host:execute ("setStatus", " Loaded ");
        instance:updateFrom(0);
    end
    	       
    return core.ASYNC_REDRAW ;   
end


function Evaluate(i)    

    if not On[i] then
        return;
    end
        
    local p = Initialization((source:size()-1),i);
      
    if p==false then
        return;
    end
       
    if Last[i] == SourceData[i]:serial(p) then 
        return;
    end
    
    local SL = Indicator[i].SL;
    local TL = Indicator[i].TL;
    local SA = Indicator[i].SA;
    local SB = Indicator[i].SB;
    local period = p;
    
    	 
    if (period < SL:first() or period > SL:size() - 1) or
        not SA:hasData(period-1) or  not SB:hasData(period-1)then
        return
    end

    if SL[period] > TL[period] and SL[period - 1] <= TL[period - 1] and
        TL[period] > math.min(SA[period], SB[period]) and  TL[period] < math.max(SA[period], SB[period]) and 
        SL[period] > math.min(SA[period], SB[period]) and  SL[period] < math.max(SA[period], SB[period]) then

        if Last[i] ~= SourceData[i]:serial(period) then
            GiveAlert("Cross Over",i); 
            Last[i]= SourceData[i]:serial(period);
            Up[i] = Last[i];
        end
    elseif SL[period] < TL[period] and SL[period - 1] >= TL[period - 1] and
           TL[period] > math.min(SA[period], SB[period]) and  TL[period] < math.max(SA[period], SB[period]) and 
           SL[period] > math.min(SA[period], SB[period]) and  SL[period] < math.max(SA[period], SB[period]) then

        if Last[i] ~= SourceData[i]:serial(period) then
            GiveAlert("Cross Under",i); 
            Last[i]= SourceData[i]:serial(period);
            Down[i] = Last[i];
        end
    end                
end


function GiveAlert(Label,i)
    
    SoundAlert(Sound);
    Pop("Alert",  Pair[i], Label   ); 
    EmailAlert(  "Alert",   Pair[i], Label  );
end



function EmailAlert( label ,  Instrument,Label )

if not SendEmail then
    return
end

    now = core.host:execute("getServerTime");
    now= core.host:execute ("convertTime",  core.TZ_EST, ToTime, now);   
    local DATA = core.dateToTable (now);


    local delim = "\013\010";  

    local Time =  " Date : " .. DATA.month.." / ".. DATA.day .. delim .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec; 

    local text = " Instrument : " .. Instrument.. delim ..  Time.. delim  .. Label .. " : " ..label;
     
    terminal:alertEmail(Email, Label .. " : " ..label , text);
end
 
function Pop(label , Instrument,Label )

   if not Show then
   return;
   end
   
    now = core.host:execute("getServerTime");
    now= core.host:execute ("convertTime",  core.TZ_EST, ToTime, now);   
    local DATA = core.dateToTable (now);
    
    
   local delim = "\013\010";  
  
   local Time =  " Date : " .. DATA.month.." / ".. DATA.day.. delim .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec; 
   
    local text = " Instrument : " .. Instrument.. delim ..  Time.. delim  ..  label .. " : " .. Label ;

   core.host:execute ("prompt", 1,   profile:id()  ,   text );

end

function SoundAlert(iAlert )
 if not PlaySound then
 return;
 end 
  
     terminal:alertSound(iAlert, RecurrentSound);
end

function   Initialization(period,id)

    local Candle;
    Candle = core.getcandle(source:barSize(), source:date(period), day_offset, week_offset);
  
    if loading[id] or SourceData[id]:size() == 0  then
        return false;
    end

    
    if period < source:first() then
        return false;
    end

    local P = core.findDate(SourceData[id], Candle, false);
     

    -- candle is not found
    if P < 0    then
        return false;
    else return P;    
    end
end    

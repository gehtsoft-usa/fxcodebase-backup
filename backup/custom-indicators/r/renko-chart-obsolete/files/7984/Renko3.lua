
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2360

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
    indicator:name("Renko indicator");
    indicator:description("Renko indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator:setTag("replaceSource", "t");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Step", "Step in pips", "", 100);
    
    indicator.parameters:addGroup("Style");
    indicator.parameters:addBoolean("ShowSeparator", "Show period separator", "", false);
    indicator.parameters:addString("TF_Separator", "Step for separator", "", "Hour");
    indicator.parameters:addStringAlternative("TF_Separator", "Hour", "", "Hour");
    indicator.parameters:addStringAlternative("TF_Separator", "Day", "", "Day");
    indicator.parameters:addStringAlternative("TF_Separator", "Month", "", "Month");
    indicator.parameters:addStringAlternative("TF_Separator", "Year", "", "Year");
    indicator.parameters:addBoolean("ShowLabel", "Show time label", "", false);
    indicator.parameters:addBoolean("ShowDate", "Show date", "", false);
    indicator.parameters:addBoolean("ShowTime", "Show time", "", false);
    indicator.parameters:addInteger("StepLabel", "Label step in bars", "", 5);
    indicator.parameters:addColor("Lbl_color", "Color of labels", "Color of labels", core.rgb(255, 0, 0));
    indicator.parameters:addColor("Sep_color", "Color of separators", "Color of separators", core.rgb(128, 255, 255));
    indicator.parameters:addInteger("FontSize", "Font size", "", 10);
end

local first;
local source = nil;
local Step;
local ShowSeparator;
local TF_Separator;
local ShowLabel;
local ShowDate;
local ShowTime;
local StepLabel;
local BuffUP=nil;
local BuffDN=nil;
local RenkoBuff;
local RenkoBuffShift;
local i;
local open = nil;
local high = nil;
local low = nil;
local close = nil;
local TimeBuff;
local Label=nil;
local host;

function Prepare(nameOnly)
    source = instance.source.open;
    host=core.host;
    Step=instance.parameters.Step;
    ShowSeparator=instance.parameters.ShowSeparator;
    TF_Separator=instance.parameters.TF_Separator;
    ShowLabel=instance.parameters.ShowLabel;
    ShowDate=instance.parameters.ShowDate;
    ShowTime=instance.parameters.ShowTime;
    StepLabel=instance.parameters.StepLabel;
    first = source:first()+2;
    RenkoBuff = instance:addInternalStream(first, 0);
    TimeBuff = instance:addInternalStream(first, 0);
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Step .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
    open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first)
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first)
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first)
    instance:createCandleGroup("Renko", "Renko", open, high, low, close);
    Label = instance:createTextOutput ("Lbl", "Lbl", "Arial", instance.parameters.FontSize, core.H_Center, core.V_Bottom, instance.parameters.Lbl_color, first);
end

function CheckBuff(period)
 local ii;
 if RenkoBuffShift>period then
  for ii=first+1,period,1 do
   RenkoBuff[ii-1]=RenkoBuff[ii];
   TimeBuff[ii-1]=TimeBuff[ii];
  end
  RenkoBuffShift=RenkoBuffShift-1;
 end
end

function Update(period, mode)
   if (period==source:size()-1) then
    RenkoBuffShift=first;
    RenkoBuff[RenkoBuffShift]=source[first];
    TimeBuff[RenkoBuffShift]=source:date(first);
    for i=first+1,period,1 do
     if RenkoBuffShift==first then
      while source[i]>RenkoBuff[RenkoBuffShift]+Step*source:pipSize() do
       RenkoBuffShift=RenkoBuffShift+1;
       CheckBuff(period);
       RenkoBuff[RenkoBuffShift]=RenkoBuff[RenkoBuffShift-1]+Step*source:pipSize();
       TimeBuff[RenkoBuffShift]=source:date(i);
      end
      while source[i]<RenkoBuff[RenkoBuffShift]-Step*source:pipSize() do
       RenkoBuffShift=RenkoBuffShift+1;
       CheckBuff(period);
       RenkoBuff[RenkoBuffShift]=RenkoBuff[RenkoBuffShift-1]-Step*source:pipSize();
       TimeBuff[RenkoBuffShift]=source:date(i);
      end
     end
     
     if RenkoBuff[RenkoBuffShift]>RenkoBuff[RenkoBuffShift-1] then
      if source[i]>RenkoBuff[RenkoBuffShift]+Step*source:pipSize() then
       while source[i]>RenkoBuff[RenkoBuffShift]+Step*source:pipSize() do
        RenkoBuffShift=RenkoBuffShift+1;
        CheckBuff(period);
        RenkoBuff[RenkoBuffShift]=RenkoBuff[RenkoBuffShift-1]+Step*source:pipSize();
        TimeBuff[RenkoBuffShift]=source:date(i);
       end
      end
      if source[i]<RenkoBuff[RenkoBuffShift]-2.*Step*source:pipSize() then
       RenkoBuffShift=RenkoBuffShift+1;
       CheckBuff(period);
       RenkoBuff[RenkoBuffShift]=RenkoBuff[RenkoBuffShift-1]-2.*Step*source:pipSize();
       TimeBuff[RenkoBuffShift]=source:date(i);
       while source[i]<RenkoBuff[RenkoBuffShift]-Step*source:pipSize() do
        RenkoBuffShift=RenkoBuffShift+1;
        CheckBuff(period);
        RenkoBuff[RenkoBuffShift]=RenkoBuff[RenkoBuffShift-1]-Step*source:pipSize();
        TimeBuff[RenkoBuffShift]=source:date(i);
       end
      end
     end
     
     if RenkoBuff[RenkoBuffShift]<RenkoBuff[RenkoBuffShift-1] then
      if source[i]<RenkoBuff[RenkoBuffShift]-Step*source:pipSize() then
       while source[i]<RenkoBuff[RenkoBuffShift]-Step*source:pipSize() do
        RenkoBuffShift=RenkoBuffShift+1;
        CheckBuff(period);
        RenkoBuff[RenkoBuffShift]=RenkoBuff[RenkoBuffShift-1]-Step*source:pipSize();
        TimeBuff[RenkoBuffShift]=source:date(i);
       end
      end
      if source[i]>RenkoBuff[RenkoBuffShift]+2.*Step*source:pipSize() then
       RenkoBuffShift=RenkoBuffShift+1;
       CheckBuff(period);
       RenkoBuff[RenkoBuffShift]=RenkoBuff[RenkoBuffShift-1]+2.*Step*source:pipSize();
       TimeBuff[RenkoBuffShift]=source:date(i);
       while source[i]>RenkoBuff[RenkoBuffShift]+Step*source:pipSize() do
        RenkoBuffShift=RenkoBuffShift+1;
        CheckBuff(period);
        RenkoBuff[RenkoBuffShift]=RenkoBuff[RenkoBuffShift-1]+Step*source:pipSize();
        TimeBuff[RenkoBuffShift]=source:date(i);
       end
      end
     end
     
    end
    
    for i=first,period,1 do
     local NewPos=i-period+RenkoBuffShift;
     if NewPos<=first then
      open[i]=nil;
      close[i]=nil;
      low[i]=nil;
      high[i]=nil;
     else
      if RenkoBuff[NewPos]>RenkoBuff[NewPos-1] then
       open[i]=RenkoBuff[NewPos]-Step*source:pipSize();
       close[i]=RenkoBuff[NewPos];
       high[i]=close[i];
       low[i]=open[i];
      else
       open[i]=RenkoBuff[NewPos]+Step*source:pipSize();
       close[i]=RenkoBuff[NewPos];
       high[i]=open[i];
       low[i]=close[i];
      end 
      
      if ShowLabel==true then
       local a1,a2=math.modf(i/StepLabel);
       if a2==0 then
        local T=core.dateToTable(TimeBuff[NewPos]);
        local Str="";
        if ShowDate==true then
         Str=Str .. T.day .. "." .. T.month .. "." .. T.year .. " ";
        end
        if ShowTime==true then
         Str=Str .. T.hour .. ":" .. T.min .. ":" .. T.sec;
        end
        Label:set(i, low[i], Str, "");
       else
        Label:setNoData(i); 
       end
      end
      
      if ShowSeparator==true and TimeBuff[NewPos]>0 then
       local T1,T2;
       T1=core.dateToTable(TimeBuff[NewPos]);
       T2=core.dateToTable(TimeBuff[NewPos-1]);
       local Time1;
       local Time2;
       if TF_Separator=="Hour" then
        Time1=T1.hour;
        Time2=T2.hour;
       elseif TF_Separator=="Day" then
        Time1=T1.day;
        Time2=T2.day;
       elseif TF_Separator=="Month" then
        Time1=T1.month;
        Time2=T2.month;
       elseif TF_Separator=="Year" then
        Time1=T1.year;
        Time2=T2.year;
       end
       if Time1~=Time2 then
        host:execute("drawLine", i, source:date(i), low[i]-Step*source:pipSize(), source:date(i), high[i]+Step*source:pipSize(), instance.parameters.Sep_color);
       else
        host:execute ("removeLine", i) 
       end
      end
     
     end
    end
    
   end 
end


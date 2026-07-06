-- Id: 20307
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=548&p=112262

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

local indi_alerts = {};
indi_alerts.last_id = 0;
indi_alerts.FIRST = true;
function indi_alerts:AddParameters(parameters)
    indicator.parameters:addGroup("Mode");  
    indicator.parameters:addString("Live", "End of Turn / Live", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
    indicator.parameters:addStringAlternative("Live", "Live", "", "Live");
    
    indicator.parameters:addGroup("Alert Style");
    indicator.parameters:addColor("UpTrendColor", "Up Trend Color", "", core.rgb(0, 0, 255));
    indicator.parameters:addColor("DownTrendColor", "Down Trend Color", "", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("Size", "Label Size", "", 10, 1 , 100);
    
    indicator.parameters:addGroup("Alerts");
    indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true);
    indicator.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
    
    indicator.parameters:addGroup("Alerts Sound");
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", true);    
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);
    
    indicator.parameters:addGroup("Alerts Email");   
    indicator.parameters:addBoolean("SendEmail", "Send Email", "", true);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);
end

function indi_alerts:AddAlert(Label)
    self.last_id = self.last_id + 1;
    indicator.parameters:addGroup(Label .. " Alert");

    indicator.parameters:addBoolean("ON" .. self.last_id , "Show " .. Label .." Alert" , "", true);

    indicator.parameters:addFile("Up" .. self.last_id, Label .. " Cross Over Sound", "", "");
    indicator.parameters:setFlag("Up" .. self.last_id, core.FLAG_SOUND);
    
    indicator.parameters:addFile("Down" .. self.last_id, Label .. " Cross Under Sound", "", "");
    indicator.parameters:setFlag("Down" .. self.last_id, core.FLAG_SOUND);
    
    indicator.parameters:addString("Label" .. self.last_id, "Label", "", Label);
    indicator.parameters:addDouble("Tolerance" .. self.last_id, "Tolerance", "", 0);
end

indi_alerts.init = false;
function indi_alerts:Draw(stage, context)
    if stage ~= 2 then
        return;
    end
    if not self.init then
        context:createFont(1, "Wingdings", context:pointsToPixels(self.Size), context:pointsToPixels(self.Size), 0);
        self.init = true;
    end
    for period = math.max(context:firstBar(), self.source:first()), math.min(context:lastBar(), self.source:size()-1), 1 do
        x, x1, x2= context:positionOfBar(period);
        for _, level in ipairs(self.Alerts) do
            if level.Alert:hasData(period) then
                if level.Alert[period]== 1 then
                    visible, y = context:pointOfPrice (level.AlertLevel[period]);
                    width, height = context:measureText (1,  "\225", 0);
                    context:drawText (1,   "\225", self.UpTrendColor, -1,  x-width/2 ,  y-height , x+width/2 , y, 0 );    
                elseif level.Alert[period]== -1 then
                    visible, y = context:pointOfPrice (level.AlertLevel[period]);
                    width, height = context:measureText (1,  "\226", 0);
                    context:drawText (1,   "\226", self.DownTrendColor, -1,  x-width/2  ,  y , x+width/2 ,y+height, 0 );    
                end
            end
        end
    end
end
indi_alerts.Alerts = {};
function indi_alerts:Prepare()
    self.Show = instance.parameters.Show;
    self.Live = instance.parameters.Live;
    self.ShowAlert = instance.parameters.ShowAlert;
    
    self.UpTrendColor = instance.parameters.UpTrendColor;
    self.DownTrendColor = instance.parameters.DownTrendColor;
    self.Size = instance.parameters.Size;
    self.SendEmail = instance.parameters.SendEmail;

    self.PlaySound = instance.parameters.PlaySound;
    local i;
    for i = 1, 2, 1 do 
        local alert = {};
        alert.id = 1;
        alert.Tolerance = instance.parameters:getDouble("Tolerance" .. i);
        alert.Label = instance.parameters:getString("Label" .. i);
        alert.ON = instance.parameters:getBoolean("ON" .. i);
        alert.Up = self.PlaySound and instance.parameters:getString("Up" .. i) or nil;
        alert.Down = self.PlaySound and instance.parameters:getString("Down" .. i) or nil;
        assert(not(self.PlaySound) or (self.PlaySound and alert.Up ~= "") or (self.PlaySound and alert.Up ~= ""), "Sound file must be chosen"); 
        assert(not(self.PlaySound) or (self.PlaySound and alert.Down ~= "") or (self.PlaySound and alert.Down ~= ""), "Sound file must be chosen");
        alert.U = nil;
        alert.D = nil;
        alert.Alert = instance:addInternalStream(0, 0);
        alert.AlertLevel = instance:addInternalStream(0, 0);
        function alert:DownAlert(source, period, text, level)
            shift = indi_alerts.Live ~= "Live" and 1 or 0;
            self.Alert[period] = -1;
            self.AlertLevel[period] = level;
            self.U = nil;
            if self.D ~= source:serial(period) and period == source:size() - 1 - shift and not indi_alerts.FIRST then
                self.D = source:serial(period);
                indi_alerts:SoundAlert(self.Down);
                indi_alerts:EmailAlert(self.Label, text, period);
                indi_alerts:SendAlert(self.Label, text, period);
                if indi_alerts.Show then
                    indi_alerts:Pop(self.Label, text);
                end
            end
        end
        function alert:UpAlert(source, period, text, level)
            shift = indi_alerts.Live ~= "Live" and 1 or 0;
            self.Alert[period] = 1;
            self.AlertLevel[period] = level;
            self.D = nil;
            if self.U ~= source:serial(period) and period == source:size() - 1 - shift and not indi_alerts.FIRST then
                self.U=source:serial(period);
                indi_alerts:SoundAlert(self.Up);
                indi_alerts:EmailAlert(self.Label, text, period);
                indi_alerts:SendAlert(self.Label, text, period);
                if indi_alerts.Show then
                    indi_alerts:Pop(self.Label, text);
                end
            end
        end
        self.Alerts[#self.Alerts + 1] = alert;
    end

    self.Email = self.SendEmail and instance.parameters.Email or nil;
    assert(not(self.SendEmail) or (self.SendEmail and self.Email ~= ""), "E-mail address must be specified");
    self.RecurrentSound = instance.parameters.RecurrentSound;
end

function indi_alerts:Pop(label, note)
    core.host:execute("prompt", 1, label, " ( " .. self.source:instrument() .. label .. " : " .. note);
end

function indi_alerts:SoundAlert(Sound)
    if not self.PlaySound then
        return;
    end
    terminal:alertSound(Sound, self.RecurrentSound);
end

function indi_alerts:EmailAlert(label, Subject, period)
    if not self.SendEmail then
        return
    end

    local date = self.source:date(period);
    local DATA = core.dateToTable(date);
    local delim = "\013\010";  
    local Note=  profile:id().. delim.. " Label : " ..label  .. delim .. " Alert : " .. Subject;   
    local Symbol = "Instrument : " .. self.source:instrument() ;
    local Time =  " Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec; 
    local text = Note  .. delim ..  Symbol .. delim .. Time;
    terminal:alertEmail(self.Email, profile:id(), text);
end

function indi_alerts:SendAlert(label, Subject, period)
    if not self.ShowAlert then
        return;
    end
    
    local date = self.source:date(period);
    local DATA = core.dateToTable (date);
    local delim = "\013\010";  
    local Note=  profile:id().. delim.. " Label : " ..label  .. delim .. " Alert : " .. Subject;
    local Symbol= "Instrument : " .. self.source:instrument() ;
    local Time =  " Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec;  
    local TF= "Time Frame : " .. self.source:barSize();       
    local text = Note  .. delim ..  Symbol .. delim .. TF  .. delim .. Time;
    terminal:alertMessage(self.source:instrument(), self.source[NOW], text, self.source:date(NOW));
end

function Init()
    indicator:name("Linear Regression  Raff Channel with Alert");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("period", "Period", "Period", 50);    
    
  --  indicator.parameters:addString("Raff", "Raff Channel", "Raff Channel Y/N" , "Yes");
   -- indicator.parameters:addStringAlternative("Raff", "Yes", "Raff Channel Yes" , "Yes");
 --   indicator.parameters:addStringAlternative("Raff", "No", "Raff Channel No" , "No");
    
    indicator.parameters:addString("HighLowClose", "Close or High and Low ", "Close or High and Low" , "HighLow");
    indicator.parameters:addStringAlternative("HighLowClose", "High/Low", "High/Low" , "HighLow");
    indicator.parameters:addStringAlternative("HighLowClose", "Close", "Close" , "Close");
    
    indicator.parameters:addGroup("Channel Mode");
    indicator.parameters:addString("Model", "HighLow / Deviation ", "" , "HighLow");
    indicator.parameters:addStringAlternative("Model", "High/Low", "High/Low" , "HighLow");
    indicator.parameters:addStringAlternative("Model", "Deviation", "" , "Deviation");
    indicator.parameters:addDouble("Multiplier", "Deviation Multiplier", "If Deviation", 1.0, 0.0, 100.0);
    
    indicator.parameters:addGroup("Top Line Style");
    indicator.parameters:addColor("top_color", "Color of Top", "", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("widthT", "Width Top Line", "Width", 1, 1, 5);
    indicator.parameters:addInteger("styleT", "Style Top Line", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleT", core.FLAG_LINE_STYLE);
    
    indicator.parameters:addGroup("Cental Line Style");
    indicator.parameters:addColor("out_color", "Color of Central Line", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthC", "Width Central Line", "Width", 1, 1, 5);
    indicator.parameters:addInteger("styleC", "Style Central Line", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleC", core.FLAG_LINE_STYLE);
    
    indicator.parameters:addGroup("Bottom Line Style");
    indicator.parameters:addColor("bottom_color", "Color of Bottom", "", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("widthB", "Width Bottom Line", "Width", 1, 1, 5);
    indicator.parameters:addInteger("styleB", "Style Bottom Line", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleB", core.FLAG_LINE_STYLE);

    indi_alerts:AddParameters(indicator.parameters);
    indi_alerts:AddAlert("Upper Line Alert");
    indi_alerts:AddAlert("Bottom Line Alert");
end

local first;
local source = nil;
local a=0;
local b=0;
local c=0;
local petlja=0;
local oldx=0;
local oldy=0;
local frame=0;
local w=0;
local maksimum=0;
local minimum=0;
local dd=0;
local dl=0;
local gornja=0;
local doljnja=0;
--local raff;
local CloseHighLow;
local h=0;
local i=0;
local last_period=nil;
local Top, Bottom,Mid;
local Model=nil;
local Multiplier;
local ld;
local lg;
local dg = 0;
local dd = 0;
local x;
local y;
local xy;
local x2;

-- Routine
function Prepare(nameOnly)
    indi_alerts:Prepare();

    Multiplier =instance.parameters.Multiplier;
    Model =instance.parameters.Model;
    frame = instance.parameters.period;
    source = instance.source;
    indi_alerts.source = source;
    CloseHighLow=instance.parameters.HighLowClose;
    
    first = source:first()+frame;
    
    local name;
    if Model == "Deviation" then
        name = profile:id() .. "(" .. source:name() .. ", " .. frame ..", " ..   Model .. ", "  ..Multiplier .. ")";
    else
        name = profile:id() .. "(" .. source:name() .. ", " .. frame ..", " ..   Model .. ")";
    end
    
    instance:name(name);
    if nameOnly then
        return;
    end
    x = instance:addInternalStream(0, 0);
    y = instance:addInternalStream(0, 0);
    xy = instance:addInternalStream(0, 0);
    x2 = instance:addInternalStream(0, 0);
    
    Mid = instance:addStream("Central", core.Line, name, "Central", instance.parameters.out_color, first);
    Mid:setWidth(instance.parameters.widthC);
    Mid:setStyle(instance.parameters.styleC);
    
    --if raff =="Yes" then
        Bottom = instance:addStream("Bottom", core.Line, name, "Bottom", instance.parameters.bottom_color, first);
        Bottom:setWidth(instance.parameters.widthB);
        Bottom:setStyle(instance.parameters.styleB);
        
        Top = instance:addStream("Top", core.Line, name, "Top", instance.parameters.top_color, first);
        Top:setWidth(instance.parameters.widthT);
        Top:setStyle(instance.parameters.styleT);
  --  end

    instance:ownerDrawn(true);
    last_period =nil;
end

function Update(period)
    if  period  < first  then 
        return;
    end
         if period == source:size() -1 then
         
         
         
            if last_period ~=  source:serial(period) then
            last_period =  source:serial(period)
            Clear(period);
            end
    
            oldx=period- frame;

                        
            for i= 0 , frame, 1 do
            y[period-frame+i] = source.close[period-frame+i];
            xy[period-frame+i]=source.close[period-frame+i]*i;
            x[period-frame+i]=i;
            x2[period-frame+i]=i*i;
            end        

        c=((mathex.sum(x2, period-frame+1, period)) *frame-(mathex.sum(x, period-frame+1, period)) *(mathex.sum(x, period-frame+1, period)) );
        b=(mathex.sum (xy, period-frame+1, period) *frame-mathex.sum(x, period-frame+1, period) *mathex.sum(y, period-frame+1, period) )/c;        
        a=   (mathex.sum(y, period-frame+1, period) -mathex.sum(x, period-frame+1, period)*b) /frame;
        w=a+b*frame;
        
         oldy=a;
        
        core.drawLine(Mid, core.range(oldx, period), oldy, oldx, w,period);               
                
            --Raff Channel
                if  Model =="HighLow"   then
                                                                         
                    for petlja =1, frame, 1 do
                    
                                    if  CloseHighLow=="Close" then
                                    h=source.close[period-frame+petlja];
                                    l=source.close[period-frame+petlja]
                                    else
                                     h=source.high[period-frame+petlja];
                                     l=source.low[period-frame+petlja]
                                    end
                                                                    
                                    if petlja==1 then 
                                    maksimum = h - Mid[period-frame+petlja]; 
                                    minimum  =  Mid[period-frame+petlja] -l;
                                    end                                                            
                                                    
                            if (h - Mid[period-frame+petlja]) > maksimum then maksimum = (h - Mid[period-frame+petlja]); end
                            if (Mid[period-frame+petlja]- l )> minimum then minimum = (Mid[period-frame+petlja]- l); end
                        end                     
                                            
                          lg=(Mid[oldx] + maksimum );
                          dg=(Mid[period]+maksimum );
                         ld=(Mid[oldx]-minimum);
                         dd=(Mid[period] -minimum);                                             
                                 
                        
                     
                           core.drawLine(Top, core.range(oldx, period), lg, oldx, dg,period);    
                             core.drawLine(Bottom, core.range(oldx, period), ld, oldx, dd,period);        
                    elseif   Model ~= "HighLow"   then 
                    
                        local SD = mathex.stdev(source.close, period - frame , period);
                        
                        
                          lg=(Mid[oldx] + SD * Multiplier );
                          dg=(Mid[period]+SD * Multiplier );
                         ld=(Mid[oldx]-SD * Multiplier);
                         dd=(Mid[period] -SD * Multiplier);        
                    
                               core.drawLine(Top, core.range(oldx, period), lg, oldx, dg,period);    
                             core.drawLine(Bottom, core.range(oldx, period), ld, oldx, dd,period);        
                             
                                             
                    end
            
            
        end
    for _, alert in ipairs(indi_alerts.Alerts) do
        Activate(alert, period);
    end
end

function Clear(p)
    Top[p-frame-1] = nil;
    Bottom[p-frame-1] = nil;
    Mid[p-frame-1] = nil;
end

function Draw(stage, context)
    indi_alerts:Draw(stage, context, source);
end

function Activate(alert, period)
    if indi_alerts.Live ~= "Live" then
        period = period - 1;
    end
    alert.Alert[period] = 0;
    if alert.id == 1 and alert.ON then
        if alert.Tolerance == 0.0 then
            if source[period] == dg and source[period - 1] ~= dg then
                alert:UpAlert(source, period, alert.Label, dg);
            end
        else
            local tolerance = alert.Tolerance * source:pipSize();
            if source[period] >= dg - tolerance and source[period - 1] < dg - tolerance then
                alert:UpAlert(source, period, alert.Label, dg - tolerance);
            end
        end
    elseif alert.id == 2  and alert.ON then
        if alert.Tolerance == 0.0 then
            if source[period] == dd and source[period - 1] ~= dd then
                alert:UpAlert(source, period, alert.Label, dd);
            end
        else
            local tolerance = alert.Tolerance * source:pipSize();
            if source[period] <= dd - tolerance and source[period - 1] > dd - tolerance then
                alert:UpAlert(source, period, alert.Label, dd - tolerance);
            end
        end
    end

    if indi_alerts.FIRST then
        indi_alerts.FIRST = false;
    end
end

function AsyncOperationFinished (cookie, success, message)
end

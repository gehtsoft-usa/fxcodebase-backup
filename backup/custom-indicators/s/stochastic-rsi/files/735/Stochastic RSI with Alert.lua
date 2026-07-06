-- Id: 7227
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=451

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

-- This indicator provides Audio / Email Alerts for six signals.
-- 1) OB Zone Cross 
-- 2) OS Zone Cross
-- 3) Cental Line Cross
-- 4) Slope change
-- 5) Slope change in OB zone
-- 6) Slope change in OS zone
-- 7) K/D Line Cross

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=451

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams

function Init()
    indicator:name("Stochastic RSI with Alert");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator:name("Stochastic RSI");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "Number of periods for RSI", "", 14, 1, 200);
    indicator.parameters:addInteger("K", "%K Stochastic Periods", "", 14, 1, 200);
    indicator.parameters:addInteger("KS", "%K Slowing Periods", "", 5, 1, 200);
    indicator.parameters:addInteger("D2", "%D Slowing Stochastic Periods", "", 3, 1, 200);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("K_color", "Color of K", "Color of K", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("widthK", "Price Line width", "Price Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleK", "Price Line style", "Price Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleK", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("D_color", "Color of D", "Color of D", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthD", "Price Line width", "Price Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleD", "Price Line style", "Price Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleD", core.FLAG_LINE_STYLE);

    indicator.parameters:addGroup("OB/OS Levels");
    indicator.parameters:addDouble("OB", "OverBoughtLevel", "", 80, 0, 100);
    indicator.parameters:addDouble("OS", "OverSold Line Level", "", 20, 0, 100);
    indicator.parameters:addDouble("CL", "Central Line Level", "", 50, 0, 100);
    indicator.parameters:addInteger("level_overboughtsold_width", "OverBoughtSold Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "OverBoughtSold Line Style", "", core.LINE_SOLID);
    indicator.parameters:addColor("level_overboughtsold_color", "OverBoughtSold Color", "", core.rgb(255, 255, 0));
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);

	 indicator.parameters:addGroup("Alert Parameters");
		indicator.parameters:addString("Live", "End of Turn / Live", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
	indicator.parameters:addStringAlternative("Live", "Live", "", "Live");   
	
    indicator.parameters:addGroup("Alert Style");
    indicator.parameters:addColor("UpTrendColor", "Up Trend Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addColor("DownTrendColor", "Down Trend Color", "", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("Size", "Label Size", "", 10, 1, 100);

	indicator.parameters:addGroup("Alerts");
	indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true);
	indicator.parameters:addBoolean("OnlyOnce", "Alert Once", "Subsequent Alert will be ignored.", false);	
	indicator.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
	
	
    indicator.parameters:addGroup("Alerts Sound");
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", false);
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);

    indicator.parameters:addGroup("Alerts Email");
    indicator.parameters:addBoolean("SendEmail", "Send Email", "", false);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);

    Parameters(1, "OB Zone")
    Parameters(2, "OS Zone")
    Parameters(3, "CL Line")
    Parameters(4, "Slope")
    Parameters(5, "OB Zone Slope")
    Parameters(6, "OS Zone Slope")
	Parameters(7, "K/D Line ")
end

function Parameters(id, Label)
    indicator.parameters:addGroup(Label .. " Alert");

    indicator.parameters:addBoolean("ON" .. id, "Show " .. Label .. " Alert", "", false);

    indicator.parameters:addFile("Up" .. id, Label .. " Cross Over Sound", "", "");
    indicator.parameters:setFlag("Up" .. id, core.FLAG_SOUND);

    indicator.parameters:addFile("Down" .. id, Label .. " Cross Under Sound", "", "");
    indicator.parameters:setFlag("Down" .. id, core.FLAG_SOUND);

    indicator.parameters:addString("Label" .. id, "Label", "", Label);
end

local Number = 7;

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local Alert={}; 
local AlertLevel={};
local UpTrendColor, DownTrendColor;

local Up = {};
local Down = {};
local Label = {};
local ON = {};
local first;
local source = nil;
local Line;
local Size;
local Email;
local SendEmail;
local RecurrentSound, SoundFile;

local Indicator;
local PlaySound;
local Live;
local U = {};
local D = {};

-- Parameters block
local N;
local K;
local KS;
local D2;

local firstSKI;
local firstK;
local firstD;
local source = nil;

-- Streams block
local SKI = nil;
local SK = nil;
local SD = nil;
local RSI = nil;
local MVA1 = nil;
local MVA2 = nil;
local OB, OS, CL;
local Shift;

local OnlyOnceFlag;
local FIRST;
local OnlyOnce, ShowAlert, Show;
-- Routine
function Prepare(nameOnly)
    source = instance.source;
	
	OnlyOnceFlag=true;
	FIRST=true;
	OnlyOnce = instance.parameters.OnlyOnce;
	ShowAlert = instance.parameters.ShowAlert;
	Show = instance.parameters.Show;
	
    UpTrendColor = instance.parameters.UpTrendColor;
	DownTrendColor = instance.parameters.DownTrendColor;
	
    OB = instance.parameters.OB;
    OS = instance.parameters.OS;
    CL = instance.parameters.CL;
    N = instance.parameters.N;
    K = instance.parameters.K;
    KS = instance.parameters.KS;
    D2 = instance.parameters.D2;
	Live = instance.parameters.Live;

    first = source:first();

    local name = profile:id() .. "(" .. source:name() .. ", " .. N .. ", " .. K .. ", " .. KS .. ", " .. D2 .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    RSI = core.indicators:create("RSI", source, N);
    firstSKI = RSI.DATA:first() + K;
    SKI = instance:addInternalStream(firstSKI, 0);
    MVA1 = core.indicators:create("MVA", SKI, KS);
    firstK = MVA1.DATA:first();
    SK = instance:addStream("K", core.Line, name .. ".K", "K", instance.parameters.K_color, firstK);
    SK:setWidth(instance.parameters.widthK);
    SK:setStyle(instance.parameters.styleK);

    SK:addLevel(OB, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    SK:addLevel(CL, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    SK:addLevel(OS, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);

    MVA2 = core.indicators:create("MVA", SK, D2);
    firstD = MVA2.DATA:first();
    SD = instance:addStream("D", core.Line, name .. ".D", "D", instance.parameters.D_color, firstD);
    SD:setWidth(instance.parameters.widthD);
    SD:setStyle(instance.parameters.styleD);
	
	
	SK:setPrecision(math.max(2, instance.source:getPrecision()));  
	SD:setPrecision(math.max(2, instance.source:getPrecision()));  

	
	 for i= 1, Number , 1 do
		Alert[i]=instance:addInternalStream(0, 0);
		AlertLevel[i]=instance:addInternalStream(0, 0);
     end

	 
	Initialization();	
	instance:ownerDrawn(true);
	  
end


local init = false;
 
function Draw(stage, context)
 
	 if stage~= 2 then
	  return;
	  end
	  
	  
	
        if not init then
           context:createFont (1, "Wingdings", context:pointsToPixels (Size), context:pointsToPixels (Size), 0);
            init = true;
        end
		
		

		
		for period= math.max(context:firstBar (),source:first()), math.min( context:lastBar (), source:size()-1), 1 do
		
		 
		
		 x, x1, x2= context:positionOfBar (period);
		 
		 for Level = 1 , Number ,  1 do
		   if Alert[Level]:hasData(period) then
		     
		    if Alert[Level][period]== 1 then
			visible, y = context:pointOfPrice (AlertLevel[Level][period]);
			
			  width, height = context:measureText (1,  "\108", 0);
              context:drawText (1,   "\108", UpTrendColor, -1,  x-width/2 ,  y-height/2 , x+width/2 , y+height/2, 0 );	
   
			elseif Alert[Level][period]== -1 then
			visible, y = context:pointOfPrice (AlertLevel[Level][period]);
			width, height = context:measureText (1,  "\108", 0);
			 context:drawText (1,   "\108", DownTrendColor, -1,  x-width/2  ,  y-height/2, x+width/2 ,y+height/2, 0 );	
		    end
		  end
		    
		 
		end
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
         assert(not(PlaySound and ON[i]) or (PlaySound and ON[i] and Up[i] ~= "") or (PlaySound and ON[i] and Up[i] ~= ""), "Sound file must be chosen");
        assert(not(PlaySound and ON[i] ) or (PlaySound and ON[i] and Down[i] ~= "") or (PlaySoundand and ON[i]  and Down[i] ~= ""), "Sound file must be chosen");
    end

    RecurrentSound = instance.parameters.RecurrentSound;

    for i = 1, Number, 1 do
        U[i] = nil;
        D[i] = nil; 
    end
end

function Calculate(period, mode)
    RSI:update(mode);

    if (period >= firstSKI) then
        local min, max;
        min, max = mathex.minmax(RSI.DATA, period - K + 1, period);

        if (min == max) then
            SKI[period] = 100;
        else
            SKI[period] = (RSI.DATA[period] - min) / (max - min) * 100;
        end
    end

    MVA1:update(mode);

    if period >= firstK then
        SK[period] = MVA1.DATA[period];
    end

    MVA2:update(mode);

    if (period >= firstD) then
        SD[period] = MVA2.DATA[period];
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
  
    Calculate(period, mode);
	
	
	if Live~= "Live" then
	period=period-1;
	Shift=1;
	else
	Shift=0;
	end
	
	  if period < first then
        return;
    end
 

    Activate(1, period);
    Activate(2, period);
    Activate(3, period);
    Activate(4, period);
    Activate(5, period);
    Activate(6, period);
	Activate(7, period);
end





function Activate(id, period)

Alert[id][period]=0;



    if id == 1 and ON[id] then
        if SK[period] > OB and SK[period-1] <= OB then     
		    Alert[id][period]= 1;	
 			AlertLevel[id][period]= OB; 		   
            D[id] = nil;
            if U[id] ~= source:serial(period) and period == source:size() - 1 -Shift  and not FIRST  then
                U[id] = source:serial(period);
                SoundAlert(Up[id]);
                EmailAlert(Label[id] , " Cross Over", period);
				Pop(Label[id], " Cross Over ", period ); 
				SendAlert(Label[id], " Cross Over ", period ); 
				OnlyOnceFlag=false;
            end
        elseif SK[period] < OB and SK[period-1] >= OB then  
			 Alert[id][period]= -1;	
 			AlertLevel[id][period]= OB; 
            U[id] = nil;
            if D[id] ~= source:serial(period) and period == source:size() - 1 -Shift  and not FIRST  then
                D[id] = source:serial(period);
                SoundAlert(Down[id]);
                EmailAlert(Label[id] , " Cross Under", period);
				Pop(Label[id], " Cross Under ", period ); 
				SendAlert(Label[id], " Cross Under ", period );
				OnlyOnceFlag=false;
            end
        end
    elseif id == 2 and ON[id] then
        if SK[period] > OS and SK[period - 1] <= OS then
            Alert[id][period]= 1;	
 			AlertLevel[id][period]= OS; 
            D[id] = nil;
            if U[id] ~= source:serial(period) and period == source:size() - 1 -Shift  and not FIRST  then
                U[id] = source:serial(period);
                SoundAlert(Up[id]);
                EmailAlert(Label[id] , " Cross Over", period);
				Pop(Label[id], " Cross Over ", period ); 
				SendAlert(Label[id], " Cross Over ", period ); 
				OnlyOnceFlag=false;
            end
        elseif SK[period] < OS and SK[period - 1] >= OS then
            Alert[id][period]= -1;	
 			AlertLevel[id][period]= OS; 
            U[id] = nil;
            if D[id] ~= source:serial(period) and period == source:size() - 1 -Shift  and not FIRST  then
                D[id] = source:serial(period);
                SoundAlert(Down[id]);
                EmailAlert(Label[id] , " Cross Under", period);
				Pop(Label[id], " Cross Under ", period ); 
				SendAlert(Label[id], " Cross Under ", period );
				OnlyOnceFlag=false;
            end
        end
    elseif id == 3 and ON[id] then
        if SK[period] > CL and SK[period - 1] < CL then
             Alert[id][period]= 1;	
 			AlertLevel[id][period]= CL; 
            D[id] = nil;
            if U[id] ~= source:serial(period) and period == source:size() - 1 -Shift  and not FIRST  then
                U[id] = source:serial(period);
                SoundAlert(Up[id]);
                EmailAlert(Label[id], " Cross Over", period);
				Pop(Label[id], " Cross Over ", period ); 
				SendAlert(Label[id], " Cross Over ", period ); 
				OnlyOnceFlag=false;
            end
        elseif SK[period] < CL and SK[period - 1] >= CL then
             Alert[id][period]= -1;	
 			AlertLevel[id][period]= CL; 
            U[id] = nil;
            if D[id] ~= source:serial(period) and period == source:size() - 1 -Shift  and not FIRST  then
                D[id] = source:serial(period);
                SoundAlert(Down[id]);
                EmailAlert(Label[id] , " Cross Under", period);
				Pop(Label[id], " Cross Under ", period ); 
				SendAlert(Label[id], " Cross Under ", period ); 
				OnlyOnceFlag=false;
            end
        end
    elseif id == 4 and ON[id] then
        if SK[period] > SK[period - 1] and SK[period - 1] <= SK[period - 2]  then
            Alert[id][period]= 1;	
 			AlertLevel[id][period]= SK[period]; 
            D[id] = nil;
            if U[id] ~= source:serial(period) and period == source:size() - 1 -Shift  and not FIRST  then
                U[id] = source:serial(period);
                SoundAlert(Up[id]);
                EmailAlert(Label[id] , " Up", period);
				Pop(Label[id], " Up ", period ); 
				SendAlert(Label[id], " Up ", period ); 
				OnlyOnceFlag=false;
            end
        elseif SK[period] < SK[period - 1] and SK[period - 1] >= SK[period - 2]  then
            Alert[id][period]= -1;	
 			AlertLevel[id][period]= SK[period]; 
            U[id] = nil;
            if D[id] ~= source:serial(period) and period == source:size() - 1 -Shift  and not FIRST  then
                D[id] = source:serial(period);
                SoundAlert(Down[id]);
                EmailAlert(Label[id] ,  " Down", period);
				Pop(Label[id], " Down ", period ); 
				SendAlert(Label[id], " Down ", period ); 
				OnlyOnceFlag=false;
            end
        end
    elseif id == 5 and ON[id] and SK[period] > OB then
        if SK[period] > SK[period - 1] and SK[period - 1] <= SK[period - 2]  and not FIRST then
            Alert[id][period]= 1;	
 			AlertLevel[id][period]= SK[period]; 
            D[id] = nil;
            if U[id] ~= source:serial(period) and period == source:size() - 1 -Shift  and not FIRST   then
                U[id] = source:serial(period);
                SoundAlert(Up[id]);
                EmailAlert(Label[id], " Up", period);
				Pop(Label[id], " Up ", period ); 
				SendAlert(Label[id], " Up ", period ); 
				OnlyOnceFlag=false;
            end
        elseif SK[period] < SK[period - 1] and SK[period - 1] >= SK[period - 2]  and not FIRST  then
             Alert[id][period]= -1;	
 			AlertLevel[id][period]= SK[period]; 
            U[id] = nil;
            if D[id] ~= source:serial(period) and period == source:size() - 1 -Shift  and not FIRST  then
                D[id] = source:serial(period);
                SoundAlert(Down[id]);
                EmailAlert(Label[id] , " Down", period);
				Pop(Label[id], " Down ", period ); 
				SendAlert(Label[id], " Down ", period ); 
				OnlyOnceFlag=false;
            end
        end
    elseif id == 6 and ON[id] and SK[period] < OS then
        if SK[period] > SK[period - 1] and SK[period - 1] <= SK[period - 2] then
             Alert[id][period]= 1;	
 			AlertLevel[id][period]= SK[period]; 
            D[id] = nil;
            if U[id] ~= source:serial(period) and period == source:size() - 1 -Shift  and not FIRST  then
                U[id] = source:serial(period);
                SoundAlert(Up[id]);
                EmailAlert(Label[id] , " Up", period);
				Pop(Label[id], " Up ", period );
                SendAlert(Label[id], " Up ", period ); 	
                OnlyOnceFlag=false;				
            end
        elseif SK[period] < SK[period - 1] and SK[period - 1] >= SK[period - 2]   and not FIRST  then
            Alert[id][period]= -1;	
 			AlertLevel[id][period]= SK[period]; 
            U[id] = nil;
            if D[id] ~= source:serial(period) and period == source:size() - 1 -Shift  and not FIRST  then
                D[id] = source:serial(period);
                SoundAlert(Down[id]);
                EmailAlert(Label[id], " Down", period);
				Pop(Label[id], " Down ", period ); 
				SendAlert(Label[id], " Down ", period ); 
				OnlyOnceFlag=false;
            end
        end
		
		 elseif id == 7 and ON[id]  then
        if SK[period] > SD[period ] and SK[period - 1] <= SD[period - 1] then
             Alert[id][period]= 1;	
 			AlertLevel[id][period]= SK[period]; 
            D[id] = nil;
            if U[id] ~= source:serial(period) and period == source:size() - 1 -Shift  and not FIRST  then
                U[id] = source:serial(period);
                SoundAlert(Up[id]);
                EmailAlert(Label[id] , " Cross Over", period);
				Pop(Label[id], " Cross Over ", period ); 
				SendAlert(Label[id], " Cross Over ", period ); 
				OnlyOnceFlag=false;
            end
        elseif SK[period] < SD[period ] and SK[period - 1] >= SD[period - 1] then
            Alert[id][period]= -1;	
 			AlertLevel[id][period]= SK[period]; 
            U[id] = nil;
            if D[id] ~= source:serial(period) and period == source:size() - 1 -Shift  and not FIRST  then
                D[id] = source:serial(period);
                SoundAlert(Down[id]);
                EmailAlert(Label[id]," Cross Under" , period);
				Pop(Label[id], " Cross Under ", period ); 
                SendAlert(Label[id], " Cross Under ", period ); 
                OnlyOnceFlag=false;				
            end
        end
    end
	
	   if FIRST then
        FIRST=false;      
        end	
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
   
   
    local TF= "Time Frame : " .. source:barSize();       
    local text = Note  .. delim ..  Symbol .. delim .. TF  .. delim .. Time;
	 
 
   terminal:alertEmail(Email, profile:id(), text);
end


function Pop(label , Subject, period)
  
   if not Show then
   return;
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
   
   
    local TF= "Time Frame : " .. source:barSize();       
    local text = Note  .. delim ..  Symbol .. delim .. TF  .. delim .. Time;
	
   
   core.host:execute ("prompt", 1, label , text );


end

function SendAlert(label ,Subject, period)
    if not ShowAlert then
        return;
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
   
 
    local TF= "Time Frame : " .. source:barSize();       
    local text = Note  .. delim ..  Symbol .. delim .. TF  .. delim .. Time;
	
 
    terminal:alertMessage(source:instrument(), source[NOW], text, source:date(NOW));
end


function AsyncOperationFinished (cookie, success, message)
end

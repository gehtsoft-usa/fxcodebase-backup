-- Id: 18733
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64947

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
    indicator:name("Price MA Cross Alert with BB");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
      
    indicator.parameters:addGroup("Calculation");		
	indicator.parameters:addString("Price", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price", "CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted");

    --SMMA Parameters
    indicator.parameters:addInteger("SMMAPeriod", "Number of periods (MA)", "The number of periods. ", 7, 1, 10000);
	
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
	--BB Parameters
    indicator.parameters:addInteger("BBN", "Number of periods(BB)", "The number of periods.(BB)", 20, 1, 10000);
    indicator.parameters:addDouble("BBDev", "Number of standard deviations", "The number of standard deviations.", 2.0, 0.0001, 1000.0);
		
    --Style Parameters
	indicator.parameters:addGroup("SMMA Style");   
    indicator.parameters:addColor("clrSMMA", "Line color", "The color of the Smoothed Moving Average line", core.rgb(192, 192, 131));
    indicator.parameters:addInteger("widthSMMA", "Line width", "The width of the Smoothed Moving Average line", 1, 1, 5);
    indicator.parameters:addInteger("styleSMMA", "Line style", "The style of the Smoothed Moving Average line", core.LINE_SOLID);
    indicator.parameters:setFlag("styleSMMA", core.FLAG_LEVEL_STYLE);
	
	indicator.parameters:addGroup("BB Style");
    indicator.parameters:addColor("clrBB", "Band lines color", "The color of upper and lower lines of the band", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthBB", "Band lines width", "The width of upper and lower lines of the band", 1, 1, 5);    
    indicator.parameters:addInteger("styleBB", "Band lines style", "The style of upper and lower lines of the band", core.LINE_SOLID);
    indicator.parameters:setFlag("styleBB", core.FLAG_LEVEL_STYLE);
    
    indicator.parameters:addGroup("Alert Parameters");  
	indicator.parameters:addString("Live", "Execution", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
	indicator.parameters:addStringAlternative("Live", "Live", "", "Live");   

	indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true);
	indicator.parameters:addBoolean("OnlyOnce", "Alert Once", "Subsequent Alert will be ignored.", false);	
	indicator.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
	
	indicator.parameters:addGroup("Alert Style");
    indicator.parameters:addColor("MATrendColor", "MA Trend Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addColor("BBTrendColor", "BB Trend Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("Size", "Label Size", "", 10, 1 , 100);
	
	indicator.parameters:addGroup("Alerts Sound");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", false);	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);

	indicator.parameters:addGroup("Alerts Email");   
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", false);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);
    
	Parameters (1, "Alert");
   -- Parameters (2, "BB Cross");		
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

local Number = 1;
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
local MATrendColor, BBTrendColor;
local OnlyOnceFlag;
local font;
local ShowAlert;
local first;
local source = nil;
local Price;
local Alert={}; 
local AlertLevel={};

local BB;
local SMMA;

local BB;
local SMMAStream;
local BBTLStream;
local BBBLStream;
local Method;
-- Routine
function Prepare(nameOnly)   
    
	OnlyOnceFlag=true;
	FIRST=true;
	OnlyOnce = instance.parameters.OnlyOnce;
	ShowAlert = instance.parameters.ShowAlert;
	Show = instance.parameters.Show;
	Live = instance.parameters.Live;
	MATrendColor = instance.parameters.MATrendColor;
	BBTrendColor = instance.parameters.BBTrendColor;
	Size=instance.parameters.Size;	
	Price = instance.parameters.Price;
	
	Method= instance.parameters.Method;
    source = instance.source;

	local smmaPeriod = instance.parameters.SMMAPeriod;
    local bbn = instance.parameters.BBN;
    local bbdev = instance.parameters.BBDev;	 

    -- Base name of the indicator.
    local name = profile:id() .. "(" .. source:name() .. ", " .. Price.. ", " .. "SMA(".. smmaPeriod .. ", " .. Method  .. ") , " .. "BB(".. bbn .. ", " .. bbdev .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
		 
	 -- Create smma and bb indicators
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
    SMMA = core.indicators:create(Method, source[Price], smmaPeriod);	
	BB = core.indicators:create("BB", source[Price], bbn, bbdev);
	
    first=math.max(BB.DATA:first(),SMMA.DATA:first() );

    SMMAStream = instance:addStream("SMMA", core.Line, name, "SMMA", instance.parameters.clrSMMA,  first)
  	SMMAStream:setWidth(instance.parameters.widthSMMA);
    SMMAStream:setStyle(instance.parameters.styleSMMA);
              
    BBTLStream = instance:addStream("TL", core.Line, name .. ".TL", "TL", instance.parameters.clrBB, first);
    BBTLStream:setWidth(instance.parameters.widthBB);
    BBTLStream:setStyle(instance.parameters.styleBB);
    BBBLStream = instance:addStream("BL", core.Line, name .. ".BL", "BL", instance.parameters.clrBB, first)
    BBBLStream:setWidth(instance.parameters.widthBB);
    BBBLStream:setStyle(instance.parameters.styleBB);
         
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
                    context:drawText (1,   "\108", MATrendColor, -1,  x-width/2  ,  y-height , x+width/2 , y, 0);	                     
               elseif Alert[Level][period]== 2 then  
                    visible, y = context:pointOfPrice (AlertLevel[Level][period]);
                    width, height = context:measureText (1,  "\108", 0);
                    context:drawText (1,   "\108", BBTrendColor, -1,  x-width/2 ,  y-height , x+width/2 , y, 0);
                end
            end
        end
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
        assert( not(PlaySound  and (Up[i] == "" or Up[i] == nil ) ), "Sound file must be chosen");
        assert (not (PlaySoundand  and (Down[i] == "" or Down[i] == nil)), "Sound file must be chosen");
    end
     
    RecurrentSound = instance.parameters.RecurrentSound;
	
	for i = 1, Number , 1 do 
        U[i] = nil;
        D[i] = nil;	 
	end	 
end	

 function Calculate(period, mode)
 
    SMMA:update(mode);
    BB:update(mode);

    if   period < first then
        return;
	end
	
	SMMAStream[period]= SMMA.DATA[period];
	BBTLStream[period]= BB.TL[period];
	BBBLStream[period]= BB.BL[period];
 end
 
-- Indicator calculation routine
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
	
    Activate (1, period)
   -- Activate (2, period)
end

function Activate (id, period)

    Alert[id][period]=0;
   
    if id == 1 and ON[id]  then
	  
        if core.crosses(source[Price], SMMAStream, period) == true 
		and
		(
		 math.abs(BBBLStream[period] - BBTLStream[period]) - 
        math.abs(BBBLStream[period -1] - BBTLStream[period -1]) > 0  
		)
		then

            Alert[id][period]= 1;	
            AlertLevel[id][period]= SMMAStream[period]		   			
            D[id] = nil;
                               
            if U[id]~=source:serial(period) and period == source:size()-1-Shift
            and not FIRST 
            and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag~= false)) then
                                  
                U[id]=source:serial(period);
                SoundAlert(Up[id]);
                EmailAlert(  Label[id], "MA and Prices Cross", period);
                SendAlert( Label[id],"MA and Prices Cross", period); 
                Pop(Label[id], "MA and Prices Cross", period );  
                OnlyOnceFlag=false;
            end	   
        end
	end
	 
    if FIRST then
        FIRST=false;      
    end
end

function AsyncOperationFinished (cookie, success, message)
end

function SoundAlert(Sound)
    if not PlaySound then
        return;
    end

    terminal:alertSound(Sound, RecurrentSound);
end

function EmailAlert( label , Subject, period)

    if not SendEmail then
        return
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
 
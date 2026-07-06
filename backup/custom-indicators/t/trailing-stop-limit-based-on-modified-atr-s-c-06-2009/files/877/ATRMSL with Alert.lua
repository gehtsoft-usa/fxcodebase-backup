-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=514

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

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("ATR Modified Stop/Loss");
    indicator:description("The Stop/Loss indicator based on the modified ATR published in the Stock & Commodities 06/2009");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    
	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "Number of periods to smooth ATR", "No description", 5);
    indicator.parameters:addDouble("Factor", "The factor to calculate stop/loss", "No description", 3.5);
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("SL_color", "Color of SL", "Color of SL", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	  indicator.parameters:addGroup("Mode");  
	indicator.parameters:addString("Live", "End of Turn / Live", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
	indicator.parameters:addStringAlternative("Live", "Live", "", "Live");   
	
	indicator.parameters:addGroup("Alert Style");
    indicator.parameters:addColor("UpTrendColor", "Up Trend Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addColor("DownTrendColor", "Down Trend Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("Size", "Label Size", "", 10, 1 , 100);
	
	indicator.parameters:addGroup("Alerts Sound");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", true);	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);
	indicator.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
	
	indicator.parameters:addGroup("Alerts Email");   
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", true);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);
	indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true);
	
	indicator.parameters:addBoolean("OnlyOnce", "Alert Once", "Subsequent Alert will be ignored.", false);
	
	Parameters (1, "Price/ ATRMSL Line Cross")
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

local 	Number = 1;

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local N;
local Factor;

local firstHL;
local source = nil;
local HL = nil;
local HLMVA = nil;
local firstDIFF;
local DIFF = nil;
local DIFFEMA = nil;
local first;

-- Streams block
local SL = nil;


--
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
local font;
local ShowAlert;
--

-- Routine
function Prepare(nameOnly) 
    N = instance.parameters.N;
    Factor = instance.parameters.Factor;
    source = instance.source;
	
	local name = profile:id() .. "(" .. source:name() .. ", " .. N .. ", " .. Factor .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end

    firstHL = source:first();
    HL = instance:addInternalStream(firstHL, 0);
    HLMVA = core.indicators:create("MVA", HL, N);

    firstDIFF = HLMVA.DATA:first();
    DIFF = instance:addInternalStream(firstDIFF, 0);

    DIFFEMA = core.indicators:create("EMA", DIFF, 2 * N - 1);
    first = DIFFEMA.DATA:first();

  
    SL = instance:addStream("SL", core.Line, name, "SL", instance.parameters.SL_color, first);
	SL:setWidth(instance.parameters.width);
    SL:setStyle(instance.parameters.style);
	
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

-- Indicator calculation routine
function Update(period, mode)
    
	Calculation (period, mode);
   
     core.host:execute ("removeLabel", source:serial(period)); 
   
     if period < first then
	 return;
	 end
	
    Activate (1, period)
	
end

function Calculation(period, mode)

if period < firstHL then
	return;
	end
        HL[period] = source.high[period] - source.low[period];
        HLMVA:update(mode);
    

    if period < firstDIFF then
	return;
	end
        local chl, cmov;
        local hilo, href, lref;

        chl = HL[period];
        cmov = HLMVA.DATA[period];

        if chl < 1.5 * cmov then
            hilo = chl;
        else
            hilo = 1.5 * cmov;
        end

        if source.low[period] <= source.high[period - 1] then
            href = source.high[period] - source.close[period - 1];
        else
            href = (source.high[period] - source.close[period - 1]) - (source.low[period] - source.high[period - 1]) / 2;
        end

        if source.high[period] >= source.low[period - 1] then
            lref = source.close[period - 1] - source.low[period];
        else
            lref = source.close[period - 1] - source.low[period] - (source.low[period - 1] - source.high[period]) / 2;
        end

        DIFF[period] = math.max(hilo, href, lref);
        DIFFEMA:update(mode);
   

    if period < first then
	SL[period] = source.close[period];
	return;
	end
        local loss;
        loss = DIFFEMA.DATA[period] * Factor;

        if source.close[period] > SL[period - 1] and source.close[period - 1] > SL[period - 2] then
            SL[period] = math.max(SL[period - 1], source.close[period] - loss);
        elseif source.close[period] < SL[period - 1] and source.close[period - 1] < SL[period - 2] then
            SL[period] = math.min(SL[period - 1], source.close[period] + loss);
        elseif source.close[period] > SL[period - 1] then
            SL[period] = source.close[period] - loss;
        else
            SL[period] = source.close[period] + loss;
        end
   
   end
   
   
   function ReleaseInstance()
       core.host:execute("deleteFont", font);
end	   

function Activate (id, period)

   local Shift=0;
   

   if Live~= "Live" then
	period=period-1;
	Shift=1;
	end
 
	  if id == 1  and ON[id]  then
	  
	       
			if  source.close[period] > SL[period] 
			and   source.close[period-1] <= SL[period-1] 
			then
			           
						    
             core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, SL[period], core.CR_CHART, core.H_Center, core.V_Bottom, font, UpTrendColor, "\225");

 						 
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  then
							  OnlyOnceFlag=false;
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Cross Over", period);
							  SendAlert("Crossed over");  
							        
									Pop(Label[id], " Cross Over " );  	
								    
								 
							  end
			elseif  source.close[period] < SL[period] 
			and   source.close[period-1] >= SL[period-1] 
            then			
			
			            			 
			               core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, SL[period], core.CR_CHART, core.H_Center, core.V_Top, font, UpTrendColor, "\226");						   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 then
							 OnlyOnceFlag=false;
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " Cross Under", period);	
								 
									Pop(Label[id], " Cross Under " );  	
								    SendAlert("Crossed under");
							 
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
  
   core.host:execute ("prompt", 1, label ,   " ( " .. source:instrument() .. " : " .. source:barSize() .. " ) "  ..   label .. " : " .. note );
 

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
	 

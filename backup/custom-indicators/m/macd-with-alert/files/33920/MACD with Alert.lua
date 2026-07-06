-- Id: 6626

-- Available @ http://fxcodebase.com/code/viewtopic.php?f=17&t=19034

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
    indicator:name("MACD with Alert");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Mode");  
	indicator.parameters:addString("Live", "End of Turn / Live", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
	indicator.parameters:addStringAlternative("Live", "Live", "", "Live");   
   
   
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("SN", "Short MA", "", 12, 2, 1000);
	indicator.parameters:addString("Method1", "MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
	indicator.parameters:addStringAlternative("Method1", "PAR MA", "PAR MA" , "PAR_MA");

    indicator.parameters:addInteger("LN", "Long MA", "", 26, 2, 1000);
	indicator.parameters:addString("Method2", "MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");
	indicator.parameters:addStringAlternative("Method2", "PAR MA", "PAR MA" , "PAR_MA");
	

	
    indicator.parameters:addInteger("IN", "Signal Line", "", 9, 2, 1000);
	indicator.parameters:addString("Method3", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method3", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method3", "EMA", "EMA" , "EMA");
 indicator.parameters:addStringAlternative("Method3", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method3", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method3", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method3", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method3", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method3", "WMA", "WMA" , "WMA");
	indicator.parameters:addStringAlternative("Method3", "PAR MA", "PAR MA" , "PAR_MA");

	indicator.parameters:addDouble("CL", "Centaral Line Level", "", 0);
	
	 indicator.parameters:addGroup("Indicator Style");
	 indicator.parameters:addColor("MACD_color", "MACD color", "(MACD Color)Red", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("MACD_width", "MACD Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("MACD_style", "MACD Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("MACD_style", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("SIGNAL_color", "Signal color", "(Signal Color) Blue", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("SIGNAL_width", "SIGNAL Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("SIGNAL_style", "SIGNAL Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("SIGNAL_style", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("HISTOGRAM_Up_color", "Up Histogram", "Up Histogram", core.rgb(0, 255, 0));
    indicator.parameters:addColor("HISTOGRAM_Down_color", "Down Histogram", "Down Histogram", core.rgb(255, 0, 0));

	
	indicator.parameters:addGroup("Alert Style");
    indicator.parameters:addColor("Down", "Up Trend Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addColor("Up", "Down Trend Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("Size", "Label Size", "", 10, 1 , 100);
	
	indicator.parameters:addGroup("Alerts Sound");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", true);	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);
	
	indicator.parameters:addGroup("Alerts Email");   
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", true);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);
	indicator.parameters:addGroup("Dialog box");  
	indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true);
	
	
	Parameters (1, "MACD / Central Line")
	Parameters (2, "MACD / Signal")
	Parameters (3, "Histogram / Central Line")
	

	
	
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

local 	Number = 3;

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Up={};
local Down={};
local Label={};
local ON={};
local first;
local source = nil;
local Line;
local up={};
local down={};
local Size;
local Email;
local SendEmail;
local  RecurrentSound ,SoundFile  ;
local Method2, Method1,Method;
local Alert;
local Indicator;
local PlaySound;


local SN;
local LN;
local IN;
local CL;
local Live;
local U={};
local D={};

local EMAS = nil;
local EMAL = nil;
local MVAI = nil;
local Method3;
-- Streams block
local MACD = nil;
local SIGNAL = nil;
local HISTOGRAM = nil;
local firstPeriodMACD;
local firstPeriodSIGNAL;
local FIRST;
local Show;


-- Routine
function AsyncOperationFinished(cookie, success, message, message1, message2)
end


function Prepare(nameOnly)   
    FIRST=true;
    source = instance.source;	
    Method3 = instance.parameters.Method3;
	Method2 = instance.parameters.Method2;
	Method1 = instance.parameters.Method1;
	Live = instance.parameters.Live;
    Show = instance.parameters.Show;	
	
	assert(core.indicators:findIndicator(Method1) ~= nil, "Please, download and install " .. Method1 .." indicator");
	assert(core.indicators:findIndicator(Method2) ~= nil, "Please, download and install " .. Method2 .." indicator");
	assert(core.indicators:findIndicator(Method3) ~= nil, "Please, download and install " .. Method3 .." indicator");
	
	CL = instance.parameters.CL;
	 SN = instance.parameters.SN;
    LN = instance.parameters.LN;
    IN = instance.parameters.IN;
	
	if (LN <= SN) then
       error("The short MA period must be smaller than long MA period");
    end
   

    -- Base name of the indicator.
    local name = profile:id() .. "(" .. source:name() .. ", " .. SN.. ", " .. Method1 .. ", " .. LN.. ", " .. Method2 .. ", " .. IN.. ", " .. Method3 .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	
	 -- Create short and long EMAs for the source
	
	EMAS = core.indicators:create(Method1, source, SN);

	
	
    EMAL = core.indicators:create(Method2, source, LN);
	
	 -- Create the output stream for the MACD. The first period is equal to the
    -- biggest first period of source EMA streams
    firstPeriodMACD = EMAL.DATA:first();
    MACD = instance:addStream("MACD", core.Line, name .. ".MACD", "MACD", instance.parameters.MACD_color, firstPeriodMACD);
    MACD:setPrecision(math.max(2, instance.source:getPrecision()));
	MACD:setWidth(instance.parameters.MACD_width);
    MACD:setStyle(instance.parameters.MACD_style);


    -- Create MVA for the MACD output stream.
		
    MVAI = core.indicators:create(Method3, MACD, IN);
	
    
    -- Create output for the signal and histogram
    firstPeriodSIGNAL = MVAI.DATA:first();
    SIGNAL = instance:addStream("SIGNAL", core.Line, name .. ".SIGNAL", "SIGNAL", instance.parameters.SIGNAL_color, firstPeriodSIGNAL);
    SIGNAL:setPrecision(math.max(2, instance.source:getPrecision()));
	SIGNAL:setWidth(instance.parameters.SIGNAL_width);
    SIGNAL:setStyle(instance.parameters.SIGNAL_style);
    HISTOGRAM = instance:addStream("HISTOGRAMUP", core.Bar, name .. ".HISTOGRAMUP", "HISTOGRAMUP", instance.parameters.HISTOGRAM_Up_color, firstPeriodSIGNAL);
    HISTOGRAM:setPrecision(math.max(2, instance.source:getPrecision()));

	first = MVAI.DATA:first();
	Initialization();
  
end


function  Initialization ()
     Size=instance.parameters.Size;
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
	
		if ON[i] then
		up[i] = instance:createTextOutput ("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Center, instance.parameters.Up, 0);
		down[i] = instance:createTextOutput ("Dn", "Dn", "Wingdings", Size, core.H_Center, core.V_Center, instance.parameters.Down, 0);
		end
	end
		
	

	
end	


 function Calculate(period, mode)
 
    EMAS:update(mode);
    EMAL:update(mode);

    if (period >= firstPeriodMACD) then
      
         MACD[period] = EMAS.DATA[period] - EMAL.DATA[period];
    end

  
    MVAI:update(mode);
    
    if (period >= firstPeriodSIGNAL) then
        SIGNAL[period] = MVAI.DATA[period];
      
       
        HISTOGRAM[period] = MACD[period] - SIGNAL[period];
        
       
            if( HISTOGRAM[period] > HISTOGRAM[period - 1]) then
             HISTOGRAM:setColor(period, instance.parameters.HISTOGRAM_Up_color);  
            else
              HISTOGRAM:setColor(period, instance.parameters.HISTOGRAM_Down_color);  
           
       end     
    end
 
 
 end
 

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode) 

if period < first then
return;
end

    Calculate(period, mode);
	
	
	local i;
	for i = 1, Number , 1 do
		  if ON[i] then
		 down[i]:setNoData (period); 
		 up[i]:setNoData (period);
		 end
   end	 
	
    Activate (1, period)
	Activate (2, period)
	Activate (3, period)
end

function Activate (id, period)

    local Shift=0;
   

   if Live~= "Live" then
	period=period-1;
	Shift=1;
	end


		
	  if id == 1  and ON[id]  then
	  
	       
			if 	MACD[period-1] > CL
			and MACD[period] <  CL
			then
			           
						     up[id]:set(period , CL, "\108");	
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST
							  then
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id] .." Cross Over");
							  Pop(Label[id], " Cross Over " );  	
							  end
			elseif	MACD[period-1] < CL 
			and  MACD [period] >  CL			
            then			
			
			            			 
			               down[id]:set(period , CL, "\108");	  						   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST
							 then
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] .. " Cross Under");	
                             Pop(Label[id], " Cross Under " );  								 
			                     end			   
	         end
			
	  
	  elseif id == 2  and ON[id] then
	  
	        if 	MACD[period-1] > SIGNAL[period-1]
			and MACD[period] <  SIGNAL[period]
			then
			           
						     up[id]:set(period , SIGNAL[period], "\108");	
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST
							  then
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id] .." Cross Over");
							  Pop(Label[id], " Cross Over " );  	
							  end
			elseif	MACD[period-1] < SIGNAL[period-1] 
			and  MACD[period]  >  SIGNAL[period]			
            then			
			
			            			 
			               down[id]:set(period , SIGNAL[period], "\108");	  						   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST
							 then
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] .. " Cross Under");		
							 Pop(Label[id], " Cross Under " );  	
			                 end			   
	         end
	       
	  elseif id == 3  and ON[id] then	  	

            if 	HISTOGRAM[period-1] > CL
			and HISTOGRAM[period] <  CL
			then
			           
						     up[id]:set(period , CL, "\108");	
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1 -Shift
							  and not FIRST
							  then
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id] .." Cross Over");
							  Pop(Label[id], " Cross Over " );  	
							  end
			elseif	HISTOGRAM[period-1] < CL
			and  HISTOGRAM[period]  >  CL			
            then			
			
			            			 
			               down[id]:set(period , CL, "\108");	  						   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST
							 then
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] .. " Cross Under");		
                             Pop(Label[id], " Cross Under " );  								 
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
 
 
 terminal:alertSound(Sound, RecurrentSound);
end
 

function EmailAlert( Subject)

if not SendEmail then
return
end

  
    local date = source:date(NOW);
	local DATA = core.dateToTable (date);
	
    local LABEL =  DATA.month..", ".. DATA.day ..", ".. DATA.hour  ..", ".. DATA.min ..", ".. DATA.sec;
 

  local text=  profile:id() .. "(" .. source:instrument() .. ")" .. source[NOW]..", " .. Subject..", " .. LABEL ;
  terminal:alertEmail(Email, profile:id(), text);
end

function Pop(label , note)
  
   if not Show then
   return;
   end
   if source:isBar () then
   core.host:execute ("prompt", 1, label ,   " ( " .. source:instrument() .. " : " .. source:barSize() .. " ) "  ..   label .. " : " .. note );
  else
  core.host:execute ("prompt", 1, label ,   " ( " .. source:instrument() .. " ) "  ..   label .. " : " .. note );
  end

end
	 
function AsyncOperationFinished (cookie, success, message)
end

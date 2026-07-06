
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63195

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
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("HA OBOS  with Alert");
    indicator:description("HA OBOS  with Alert");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("PERIOD", "Period", "", 9);
	indicator.parameters:addDouble("ExtremeOB", "ExtremeOB", "", 80);
	indicator.parameters:addDouble("ExtremeOS", "ExtremeOS", "", -80);
	indicator.parameters:addString("Filter", "Filter Out", "", "Nothing");	
	indicator.parameters:addStringAlternative("Filter", "Inside", "Inside" , "Inside");
    indicator.parameters:addStringAlternative("Filter", "Outside", "Outside" , "Outside");
	indicator.parameters:addStringAlternative("Filter", "Nothing", "Nothing" , "Nothing");
	indicator.parameters:addGroup("Style");
   
	
	indicator.parameters:addColor("Neutral", "Color of Neutral", "", core.rgb(128, 128, 128));  
	
	
	indicator.parameters:addColor("UpTrendColor", "Up Trend Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("DownTrendColor", "Down Trend Color", "", core.rgb(255, 0, 0))
	indicator.parameters:addInteger("Size", "Label Size", "", 10, 1 , 100);
	
	 indicator.parameters:addGroup("Mode");  
	indicator.parameters:addString("Live", "End of Turn / Live", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
	indicator.parameters:addStringAlternative("Live", "Live", "", "Live");   
   
   
 
	
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
	
	Parameters (1, "Up");
	Parameters (2, "Down");
	Parameters (3, "Overbought/Oversold");
end


function Parameters ( id, Label )
  
  
   indicator.parameters:addGroup(Label .. " Alert");
  
    indicator.parameters:addBoolean("ON"..id , "Show " .. Label .." Alert" , "", true);


    indicator.parameters:addFile("Up"..id, Label .. " Cross Over Sound", "", "");
    indicator.parameters:setFlag("Up"..id, core.FLAG_SOUND);
 
	
	 indicator.parameters:addString("Label"..id, "Label", "", Label);

end 

local 	Number = 3;

local Up={};
local Filter;
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

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local PERIOD;

local first;
local iFIRST;

local open=nil;
local close=nil;
local high=nil;
local low=nil;

local source = nil;

-- Streams block
local open,low, high, close;
local MA={};
local BUFFER={};
local iopen, iclose, ihigh, ilow;
local UP, DOWN;
local Signal;
local ExtremeOB,ExtremeOS;
local Shift=0;
-- Routine
function Prepare(nameOnly)
    Filter = instance.parameters.Filter;
    OnlyOnceFlag=true;
	FIRST=true;
	Size = instance.parameters.Size;
	OnlyOnce = instance.parameters.OnlyOnce;
	ShowAlert = instance.parameters.ShowAlert;
	Show = instance.parameters.Show;
	Live = instance.parameters.Live;
	ExtremeOB = instance.parameters.ExtremeOB;
	ExtremeOS  = instance.parameters.ExtremeOS;	
	UpTrendColor = instance.parameters.UpTrendColor;
	DownTrendColor = instance.parameters.DownTrendColor;
	
    PERIOD = instance.parameters.PERIOD;
    source = instance.source;
	
	

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(PERIOD) .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
	 HA = core.indicators:create("HA", source );
    iFIRST = HA.DATA:first();
	
	font = core.host:execute("createFont", "Wingdings", Size, false, false);

          Signal= instance:addInternalStream(0, 0);	
	    
	      BUFFER[1]= instance:addInternalStream(iFIRST, 0);	
		  BUFFER[2]= instance:addInternalStream(iFIRST, 0);	
          BUFFER[3]= instance:addInternalStream(iFIRST, 0);		 
          BUFFER[4]= instance:addInternalStream(iFIRST, 0);			   
		  BUFFER[5]= instance:addInternalStream(iFIRST, 0);				
		  BUFFER[6]= instance:addInternalStream(iFIRST, 0);		 
		  
		  UP= instance:addInternalStream(iFIRST, 0);
		  DOWN= instance:addInternalStream(iFIRST, 0);		  
		  
	      MA[1] = core.indicators:create("EMA", BUFFER[1],  PERIOD);
	      MA[2] = core.indicators:create("EMA", BUFFER[5],  PERIOD);
		  MA[3] = core.indicators:create("EMA",  BUFFER[6],  PERIOD);
		  MA[4] = core.indicators:create("EMA", UP,  PERIOD);
		   first = MA[4].DATA:first();

    
	
    iopen= instance:addInternalStream(0, 0);
	iclose= instance:addInternalStream(0, 0);
	ilow= instance:addInternalStream(0, 0);
	ihigh= instance:addInternalStream(0, 0);
	
 
	
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
	  --Down[i]=instance.parameters:getString("Down" .. i);
	  end
	
    else 
	
	  for i = 1, Number , 1 do 
       Up[i]=nil;
	--  Down[i]=nil;
	  end
		
    end
    
        for i = 1, Number , 1 do 
	  assert(not(PlaySound) or (PlaySound and Up[i] ~= "") or (PlaySound and Up[i] ~= ""), "Sound file must be chosen"); 
	-- assert(not(PlaySound) or (PlaySound and Down[i] ~= "") or (PlaySound and Down[i] ~= ""), "Sound file must be chosen");
	end
	 
    RecurrentSound = instance.parameters.RecurrentSound;
	
	for i = 1, Number , 1 do 
	U[i] = nil;
	D[i] = nil;	 
	end
		 
end	


-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)
	
    HA:update(mode);
    if period < iFIRST or not source:hasData(period) then
        return;		
    end
	
    
	BUFFER[1][period]=(HA.high[period]+HA.low[period]+HA.close[period]*2)/4;
	
  	
	MA[1]:update(mode);	
	BUFFER[3][period]= MA[1].DATA[period];
	
	if  period <  iFIRST + PERIOD  then
	return;
	end
		
	
	BUFFER[4][period] = mathex.stdev (BUFFER[1], period - PERIOD, period);
	
		
	BUFFER[5][period] =  (BUFFER[1][period]  - BUFFER[3][period]) *100  / BUFFER[4][period];

	MA[2]:update(mode);
	BUFFER[6][period]= MA[2].DATA[period] ;

	MA[3]:update(mode);
	UP[period]=MA[3].DATA[period];

	MA[4]:update(mode);
	DOWN[period] =MA[4].DATA[period];
	
	if UP[period]< DOWN[period] then
	iopen[period] = UP[period];
	iclose[period] = DOWN[period];
	else
	iopen[period] = DOWN[period];
	iclose[period] = UP[period];
	end
	
	ihigh[period] = math.max(iopen[period], iclose[period]);
	ilow[period] = math.min(iopen[period], iclose[period]); 
	 
	
	if iopen[period-1] < iopen[period] and iclose[period]< iclose[period-1] then 
	Signal[period]= 0;
	else
		if UP[period] > DOWN[period] then  
		Signal[period]= 1;
		else 
		Signal[period]= -1;
		end
	end
	
	if Live~= "Live" then
	period=period-1;
	Shift=1;
	else
	Shift=0;
	end
	
	
	
	core.host:execute ("removeLabel", source:serial(period)); 
	
	 Activate (1, period);
	 Activate (2, period);
	 Activate (3, period);
	
end



function Activate (id, period)
  
  
  
      if Filter== "Outside"
	  and
	   ( (ihigh[period] > ExtremeOB )
	   or ( ilow[period] < ExtremeOS )
	   )
	   then
	   return;
	   end
	   
	     if Filter== "Inside"
	  and
	   ( (ihigh[period] < ExtremeOB )
	   and ( ilow[period] > ExtremeOS )
	   )
	   then
	   return;
	   end
	   
	   
 
	  if id == 1  and ON[id]  then
	  
	       
			if  Signal[period]==1 
			and   Signal[period-1]~=1 
			
			then
			           
						    
          if ihigh[period] > ExtremeOB then
          core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, HA.low[period], core.CR_CHART, core.H_Center, core.V_Bottom, font, UpTrendColor, "\225" .. "\108");
		  else
 		  core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, HA.low[period], core.CR_CHART, core.H_Center, core.V_Bottom, font, UpTrendColor, "\225");
		  end
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  then
							  OnlyOnceFlag=false;
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Up Trend ", period);
							  SendAlert(" Up Trend "); 
							  Pop(Label[id], " Up Trend " );  
							  SendAlert(" Up Trend ");
							 
			                  end			   
	         end
			
	  
	 
	  end
	  
	    if id == 2  and ON[id]  then
	  
	       
			if  Signal[period]==-1 
			and   Signal[period-1]~=-1 
			then
			           
						    
       

 			if ilow[period] < ExtremeOS then 			 
			core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, HA.high[period], core.CR_CHART, core.H_Center, core.V_Top, font, DownTrendColor, "\226" .. "\108");	
            else			
			core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, HA.high[period], core.CR_CHART, core.H_Center, core.V_Top, font, DownTrendColor, "\226");
            end			
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  then
							  OnlyOnceFlag=false;
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Down Trend ", period);
							  SendAlert(" Down Trend ");
							  Pop(Label[id], " Down Trend " );
							  SendAlert(" Down Trend ");
							 
			                  end			   
	         end
			
	  
	 
	  end
	  
	  
	  
	    if id == 3  and ON[id]  then
	  
	       
			if  Signal[period]==0
			and   Signal[period-1]~=0 
			then
			           
						    
                if Signal[period-1]==-1 then
					if ihigh[period] > ExtremeOB then
					core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, HA.low[period], core.CR_CHART, core.H_Center, core.V_Bottom, font, UpTrendColor, "\225" .. "\108" );
					else
					core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, HA.low[period], core.CR_CHART, core.H_Center, core.V_Bottom, font, UpTrendColor, "\225");	
					end				
				elseif Signal[period-1]==1 then
					 if ilow[period] < ExtremeOS then
					 core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, HA.high[period], core.CR_CHART, core.H_Center, core.V_Top, font, DownTrendColor, "\226" .. "\108"); 	
					 else				 
					 core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, HA.high[period], core.CR_CHART, core.H_Center, core.V_Top, font, DownTrendColor, "\226"); 	
					 end				 
				end		   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  then
							  OnlyOnceFlag=false;
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  
									  if Signal[period-1]~=1 then 
									  EmailAlert(  Label[id], " Overbought ", period);
									  SendAlert(" Overbought" );  
									  Pop(Label[id], " Overbought " ); 
									  SendAlert(" Overbought ");
									  end
									  
									  if Signal[period-1]~=-1 then 
									  EmailAlert(  Label[id], " Oversold ", period);
									  SendAlert(" Oversold ");  
									  Pop(Label[id], " Oversold " ); 
									  SendAlert(" Oversold ");
									  end
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
	 

function ReleaseInstance()
       core.host:execute("deleteFont", font);
end	   
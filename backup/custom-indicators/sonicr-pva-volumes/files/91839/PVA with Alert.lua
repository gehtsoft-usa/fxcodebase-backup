-- Id: 12073
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60177

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("SonicR PVA Volumes");
    indicator:description("SonicR PVA Volumes");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("SonicR PVA Volumes Calculation");
    indicator.parameters:addInteger("PVA_Climax_Period", "PVA Climax Period", "PVA Climax Period", 10);
    indicator.parameters:addInteger("PVA_Rising_Period", "PVA Rising Period", "PVA Rising Period", 10);
    indicator.parameters:addDouble("PVA_Rising_Factor", "PVA Rising Factor", "PVA Rising Factor", 1);
    indicator.parameters:addDouble("PVA_Extreme_Factor", "PVA Extreme Factor", "PVA Extreme Factor", 2);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Neutral", "Color of Neutral", "Color of Neutral", core.rgb(128,128, 128));
	
	indicator.parameters:addColor("RisingBull", "Color of Rising Bull", "Color of Rising Bull", core.rgb(0,200, 0));	
	indicator.parameters:addColor("RisingBear", "Color of Rising Bear", "Color of Rising Bear", core.rgb(200,0, 0));
	
	indicator.parameters:addColor("ClimaxBull", "Color of Climax Bull", "Color of Climax Bull", core.rgb(0,255, 0));	
	indicator.parameters:addColor("ClimaxBear", "Color of Climax Bear", "Color of Climax Bear", core.rgb(255,0, 0));
	
	indicator.parameters:addGroup("MA Calculation");
	indicator.parameters:addBoolean("Cross", "Use MA Cross Filter", "", false);
	
	
	indicator.parameters:addInteger("Period", "MA Period", "Period" , 14);
	
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
 indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addGroup("Mode");  
	indicator.parameters:addString("Live", "End of Turn / Live", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
	indicator.parameters:addStringAlternative("Live", "Live", "", "Live");
	
	
	indicator.parameters:addGroup("Alert Style");
	indicator.parameters:addInteger("Size", "Label Size", "", 10, 1 , 100);
	
	indicator.parameters:addGroup("Alerts Sound");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", true);	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);
	
	indicator.parameters:addGroup("Alerts Email");   
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", true);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);
	indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true);
	indicator.parameters:addBoolean("OnlyOnce", "Alert Once", "Subsequent Alert will be ignored.", false);	
		
	Parameters(1, "Rising Bull");
	Parameters(2, "Rising Bear")
	Parameters(3, "Climax Bull")
	Parameters(4, "Climax Bear")
end


function Parameters ( id, Label )
  
  
   indicator.parameters:addGroup(Label .. " Alert");
  
    indicator.parameters:addBoolean("ON"..id , "Show " .. Label .." Alert" , "", true);


    indicator.parameters:addFile("Up"..id, Label .. " Cross Over Sound", "", "");
    indicator.parameters:setFlag("Up"..id, core.FLAG_SOUND);
	
 
	
	 indicator.parameters:addString("Label"..id, "Label", "", Label);

end 

local 	Number = 4;
local Color={};
-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local PVA_Climax_Period;
local PVA_Rising_Period;
local PVA_Rising_Factor;
local PVA_Extreme_Factor;
local ma_volume;
local first;
local source = nil;
local Range;
-- Streams block
local Volume = nil;
local Signal;


-- Parameters block
local Up={};
local Label={};
local ON={};
local Line;
local up={};
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
local OnlyOnceFlag;
local Cross,cross;
local Method;
local Period;
local MA,ma;
-- Routine
function Prepare(nameOnly)
    OnlyOnceFlag=true;
	FIRST=true;
	OnlyOnce = instance.parameters.OnlyOnce;
	Method = instance.parameters.Method;
	Period = instance.parameters.Period;
	Cross = instance.parameters.Cross;
	Show = instance.parameters.Show;
	Live = instance.parameters.Live;
	
	  Color[1]=  instance.parameters.RisingBull;
	 Color[2]=  instance.parameters.RisingBear;
	  Color[3]=  instance.parameters.ClimaxBull;
	   Color[4]=  instance.parameters.ClimaxBear;
	
	
    PVA_Climax_Period = instance.parameters.PVA_Climax_Period;
    PVA_Rising_Period = instance.parameters.PVA_Rising_Period;
    PVA_Rising_Factor = instance.parameters.PVA_Rising_Factor;
    PVA_Extreme_Factor = instance.parameters.PVA_Extreme_Factor;
    source = instance.source;
	 
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(PVA_Climax_Period) .. ", " .. tostring(PVA_Rising_Period) .. ", " .. tostring(PVA_Rising_Factor) .. ", " .. tostring(PVA_Extreme_Factor) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
		ma_volume = core.indicators:create("MVA", source.volume, PVA_Rising_Period);
		first = ma_volume.DATA:first();
		
		Range = instance:addInternalStream(0, 0);
		Signal = instance:addInternalStream(0, 0);
	
		 assert(source:supportsVolume(), "The source must have volume");
        Volume = instance:addStream("Volume", core.Bar, name, "Volume", instance.parameters.Neutral, first);
    Volume:setPrecision(math.max(2, instance.source:getPrecision()));
		if Cross then
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
		ma= core.indicators:create(Method, source.close, Period);
		MA = instance:addStream("MA", core.Line, name, "MA", instance.parameters.Neutral, first);
    MA:setPrecision(math.max(2, instance.source:getPrecision()));
		core.host:execute ("attachOuputToChart", "MA") 
		end
    end
	
	Initialization();
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)


  local Flag= Calculation(period, mode);

  if Flag == -1 then
  return;
  end
  
  
  
  local i;
	for i = 1, Number , 1 do
		  if ON[i] then
		 up[i]:setNoData (period);  
		 end
   end	 
   
   
   if not (not Cross or  (Cross and core.crosses (source.close, ma.DATA,period)) )  then
   return;
   end
   
   if Cross then
	   if core.crossesOver (source.close, ma.DATA,period) then
	   cross = true;
	   elseif core.crossesUnder (source.close, ma.DATA,period) then
	   cross = false;   
	   end
	else
	cross=nil;
    end	
        
        Activate (1, period)
	  Activate (2, period)
	   Activate (3, period)
	    Activate (4, period)
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
	  
	  end
	
    else 
	
	  for i = 1, Number , 1 do 
       Up[i]=nil; 
	  end
		
    end
    
        for i = 1, Number , 1 do 
	  assert(not(PlaySound) or (PlaySound and Up[i] ~= "") or (PlaySound and Up[i] ~= ""), "Sound file must be chosen"); 
	 
	end
	 
    RecurrentSound = instance.parameters.RecurrentSound;
	
	for i = 1, Number , 1 do 
	U[i] = nil; 
	
		if ON[i] then
		up[i] = instance:createTextOutput (Label[i] , Label[i], "Wingdings", Size, core.H_Center, core.V_Center,Color[i] , 0);
		core.host:execute ("attachTextToChart", Label[i]);
		end
	end
		
	

	
end	


function Calculation(period, mode)

    if Cross and period < ma.DATA:first()+1 then
	return -1;
	elseif Cross then
	ma:update(mode);
	MA[period]=ma.DATA[period];
	end
	
  
    Volume[period] = source.volume[period];		
	Volume:setColor(period, instance.parameters.Neutral);
	Signal[period]=0;
	
	ma_volume:update(mode);
	
	if period < first or not  source:hasData(period) then
	return -1;
	end
	
	 if(source.volume[period] >= ma_volume.DATA[period] * PVA_Rising_Factor) then
	 
	  if(source.close[period] > source.open[period]) then
	  Volume:setColor(period, instance.parameters.RisingBull);
	  Signal[period]=1;
	  end
	  
      if(source.close[period] <= source.open[period]) then
	  Volume:setColor(period, instance.parameters.RisingBear);
	  Signal[period]=-1;
	  end 
	 
	 end
	
	Range[period]= (source.high[period]-source.low[period])*source.volume[period];
	
	if period < PVA_Climax_Period then 
	return -1; 
	end
	
	local max = mathex.max( Range, period -PVA_Climax_Period, period-1 );
	
	
    if Range[period] >=  max  or  (source.volume[period] >= ma_volume.DATA[period] * PVA_Extreme_Factor) then
	
			if(source.close[period] > source.open[period]) then
			  Volume:setColor(period, instance.parameters.ClimaxBull);
			  Signal[period]=2;
			  end
			  
			  if(source.close[period] <= source.open[period]) then
			  Volume:setColor(period, instance.parameters.ClimaxBear);
			  Signal[period]=-2;
			  end 
	  
	  
	end
	
end


function Activate (id, period)

   local Shift=0;
   

   if Live~= "Live" then
	period=period-1;
	Shift=1;
	end
	
	
	 
	if cross== true then
	iLabel= Label[id].. " MA CrossOver Confirmation"; 
	elseif cross== false then
	iLabel= Label[id].. " MA CrossUnder Confirmation"; 
	else
	iLabel= Label[id];
	end
	
 
	  if id == 1  and ON[id]  then
	  
	       
			if  Signal[period]== 1
			and Volume[period]~=0 		     
			then
			              
               				  
                              up[id]:set(period ,  source.open[period], "\108");	
                               					  
						   
			
			 U[2] = nil;
			 U[3] = nil;
			 U[4] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  then
							  OnlyOnceFlag=false;
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], iLabel, period);
							    
							        if Show then
									Pop(Label[id], iLabel );  	
								    end
								 
							  end
		end
	  
	 
	  elseif id == 2  and ON[id]  then
	  
	       
			if  Signal[period]== -1
			and Volume[period]~=0 
		 
			then
			           
						      up[id]:set(period , source.open[period], "\108");	
						   
			
			 U[1] = nil;
			 U[3] = nil;
			 U[4] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  then
							  OnlyOnceFlag=false;
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], iLabel, period);
							    
							        if Show then
									Pop(Label[id],iLabel );  	
								    end
								 
							  end
		end
	  
	 
	 elseif id == 3  and ON[id]  then
	  
	       
			if  Signal[period]== 2
			and Volume[period]~=0 
			 
			then
			           
						      up[id]:set(period ,  source.open[period], "\108");	
						   
			
			 U[1] = nil;
			 U[2] = nil;
			 U[4] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  then
							  OnlyOnceFlag=false;
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], iLabel, period);
							    
							        if Show then
									Pop(Label[id], iLabel );  	
								    end
								 
							  end
		end
	  
	 
	  elseif id == 4  and ON[id]  then
	  
	       
			if  Signal[period]== -2
			and Volume[period]~=0 
			 
			then
			           
						      up[id]:set(period , source.open[period], "\108");	
						   
			
			 U[1] = nil;
			 U[2] = nil;
			 U[3] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  then
							  OnlyOnceFlag=false;
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], iLabel, period);
							    
							        if Show then
									Pop(Label[id], iLabel );  	
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

   core.host:execute ("prompt", 1, label ,
   " ( " .. source:instrument() .. " : " .. source:barSize() .. " ) "  ..   label .. " : " .. note );


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
   local TF= "Time Frame : " .. source:barSize();    
   local Time =  " Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec; 
   
     local text = Note  .. delim ..  Symbol .. delim .. TF  .. delim .. Time;
	

   terminal:alertEmail(Email, profile:id(), text);
 
end
	 




-- Id: 14992

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62495

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
    indicator:name("ZerolLagRSI");
    indicator:description("ZerolLagRSI");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Mode");  
	indicator.parameters:addString("Live", "End of Turn / Live", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
	indicator.parameters:addStringAlternative("Live", "Live", "", "Live");   
	
	
    indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("smoothing1", "1. Smoothing","", 15);  
	indicator.parameters:addInteger("smoothing2", "2. Smoothing","", 7);  
	
	indicator.parameters:addDouble("Factor1", "1. Factor","", 0.05);
	indicator.parameters:addInteger("RSI_period1", "1. RSI Period","", 8);	
	
	indicator.parameters:addDouble("Factor2", "2. Factor","", 0.1);
	indicator.parameters:addInteger("RSI_period2", "2. RSI Period","", 21);
	
	indicator.parameters:addDouble("Factor3", "3. Factor","", 0.16);
	indicator.parameters:addInteger("RSI_period3", "3. RSI Period","", 34);
	
	indicator.parameters:addDouble("Factor4", "4. Factor","", 0.26);
	indicator.parameters:addInteger("RSI_period4", "4. RSI Period","", 55);
	
	indicator.parameters:addDouble("Factor5", "5. Factor","", 0.43);
  	indicator.parameters:addInteger("RSI_period5", "5. RSI Period","", 89);
	
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("ZerolLagRSI_color", "Color of ZerolLagRSI", "Color of ZerolLagRSI", core.rgb(0, 0, 255));
	
	indicator.parameters:addColor("UpUp", "Up in Up Trend", "Up in Up Trend", core.rgb(0, 255, 0));
	indicator.parameters:addColor("UpDown", "Down in Up Trend", "Down in Up Trend", core.rgb(0, 200, 0));
	indicator.parameters:addColor("DownUp", "Up in Up Trend", "Up in Up Trend", core.rgb(255, 0, 0));
	indicator.parameters:addColor("DownDown", "Down in Down Trend", "Down in Down Trend", core.rgb(200, 0, 0));
	
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
	
	Parameters (1, "Zero Line");
	Parameters (2, "Direction");
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block


function Parameters ( id, Label )
  
  
   indicator.parameters:addGroup(Label .. " Alert");
  
    indicator.parameters:addBoolean("ON"..id , "Show " .. Label .." Alert" , "", true);
    

    indicator.parameters:addFile("Up"..id, Label .. " Cross Over Sound", "", "");
    indicator.parameters:setFlag("Up"..id, core.FLAG_SOUND);
	
	indicator.parameters:addFile("Down"..id, Label .. " Cross Under Sound", "", "");
    indicator.parameters:setFlag("Down"..id, core.FLAG_SOUND);
	
	 indicator.parameters:addString("Label"..id, "Label", "", Label);

end 

local 	Number = 2;

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

local first;
local source = nil;
local smoothing1, smoothing2;
-- Streams block
local ZerolLagRSI = nil;
local Factor1, Factor2, Factor3,Factor4,Factor5;
local RSI_period1, RSI_period2, RSI_period3, RSI_period4, RSI_period5;
local Factor1, Factor2, Factor3, Factor4, Factor5;
local FastTrend,SlowTrend;
local RSI={};
local smoothConst1, smoothConst2;
-- Routine
function Prepare(nameOnly)
    source = instance.source;
	
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
	
	
	
	smoothing1=instance.parameters.smoothing1;
	smoothing2=instance.parameters.smoothing2;
	
	RSI_period1=instance.parameters.RSI_period1;
	RSI_period2=instance.parameters.RSI_period2;
	RSI_period3=instance.parameters.RSI_period3;
	RSI_period4=instance.parameters.RSI_period4;
	RSI_period5=instance.parameters.RSI_period5;
	
	Factor1=instance.parameters.Factor1;
	Factor2=instance.parameters.Factor2;
	Factor3=instance.parameters.Factor3;
	Factor4=instance.parameters.Factor4;
	Factor5=instance.parameters.Factor5;
	
	smoothConst1=(smoothing1-1.0)/smoothing1;
    smoothConst2=(smoothing2-1.0)/smoothing2;
	
    

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);

    if   (nameOnly) then
        return;
    end
	
	RSI[1] = core.indicators:create("RSI", source, RSI_period1);
	RSI[2] = core.indicators:create("RSI", source, RSI_period2);
	RSI[3] = core.indicators:create("RSI", source, RSI_period3);
	RSI[4] = core.indicators:create("RSI", source, RSI_period4);
	RSI[5] = core.indicators:create("RSI", source, RSI_period5);
	
	FastTrend= instance:addInternalStream(0, 0);
	SlowTrend= instance:addInternalStream(0, 0);
	
    first = math.max( RSI[1].DATA:first(),  RSI[2].DATA:first(), RSI[3].DATA:first(), RSI[4].DATA:first(), RSI[5].DATA:first());
	
	
        ZerolLagRSI = instance:addStream("ZerolLagRSI", core.Bar, name, "ZerolLagRSI", instance.parameters.ZerolLagRSI_color, first);
        ZerolLagRSI:setPrecision(math.max(2, source:getPrecision())); 
	
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
-- TODO: Add your code for calculation output values
function Update(period,mode)

    ZerolLagRSI:setColor(period, instance.parameters.ZerolLagRSI_color);
		
	RSI[1]:update(mode);
    RSI[2]:update(mode);
	RSI[3]:update(mode);
	RSI[4]:update(mode);
	RSI[5]:update(mode);
	
	if period < first or not  source:hasData(period) then
	return;
	end
	
	  local Osc1 = Factor1 * RSI[1].DATA[period];
      local Osc2 = Factor2 * RSI[2].DATA[period];
      local Osc3 = Factor2 * RSI[3].DATA[period];
      local Osc4 = Factor4 * RSI[4].DATA[period];
      local Osc5 = Factor5 * RSI[5].DATA[period];
      
      FastTrend[period] = Osc1 + Osc2 + Osc3 + Osc4 + Osc5;
      SlowTrend[period] = FastTrend[period]/ smoothing1 + SlowTrend[period-1] * smoothConst1;
      
      ZerolLagRSI[period]=(FastTrend[period]-SlowTrend[period])/smoothing2+ZerolLagRSI[period-1]*smoothConst2;
	   
		
	local diff=ZerolLagRSI[period]-ZerolLagRSI[period-1];
	
	if ZerolLagRSI[period] > 0 then
	    if diff > 0 then
		ZerolLagRSI:setColor(period, instance.parameters.UpUp);
		else
		ZerolLagRSI:setColor(period, instance.parameters.UpDown);
		end
	else	
	    if diff > 0 then
		ZerolLagRSI:setColor(period, instance.parameters.DownUp);
		else
		ZerolLagRSI:setColor(period, instance.parameters.DownDown);
		end 
	end
	
	
	core.host:execute ("removeLabel", source:serial(period)); 

	
    Activate (1, period);
	Activate (2, period);
     
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
	  
	       
			if  ZerolLagRSI[period] > 0
			and   ZerolLagRSI[period-1] <= 0
			then
			           
						    
             core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, 0, core.CR_CHART, core.H_Center, core.V_Bottom, font, UpTrendColor, "\225");

 						 
						   
			
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
			elseif  ZerolLagRSI[period] < 0
			and   ZerolLagRSI[period-1] >= 0
            then			
			
			            			 
			               core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART,0, core.CR_CHART, core.H_Center, core.V_Top, font, DownTrendColor, "\226");						   
						   
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
	  
	  
	  if id == 2  and ON[id]  then
	  
	       
			if  ZerolLagRSI[period] > ZerolLagRSI[period-1]
			and   ZerolLagRSI[period-1] <= ZerolLagRSI[period-2]
			then
			           
						    
             core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, ZerolLagRSI[period], core.CR_CHART, core.H_Center, core.V_Bottom, font, UpTrendColor, "\225");

 						 
						   
			
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
			elseif  ZerolLagRSI[period] < ZerolLagRSI[period-1]
			and   ZerolLagRSI[period-1] >= ZerolLagRSI[period-2]
            then			
			
			            			 
			               core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART,ZerolLagRSI[period], core.CR_CHART, core.H_Center, core.V_Top, font, DownTrendColor, "\226");						   
						   
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
	 




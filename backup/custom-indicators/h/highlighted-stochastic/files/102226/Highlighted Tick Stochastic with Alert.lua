-- Id: 14940
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62636

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
    indicator:name("Highlighted Stochastic");
    indicator:description("Highlighted Stochastic");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
   
   
    indicator.parameters:addGroup("Alert Parameters");  
	indicator.parameters:addString("Live", "End of Turn / Live", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
	indicator.parameters:addStringAlternative("Live", "Live", "", "Live");   
	
	indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true);	
    indicator.parameters:addBoolean("OnlyOnce", "Alert Once", "Subsequent Alert will be ignored.", false);	
	indicator.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
   
    indicator.parameters:addGroup("Calculation");
 
		
    indicator.parameters:addInteger("K", "Number of periods for %K", "The number of periods for %K.", 5, 2, 1000);
    indicator.parameters:addInteger("SD", "%D slowing periods", "The number of periods for slow %D.", 3, 2, 1000);
    indicator.parameters:addInteger("D", "Number of periods for %D", "The number of periods for %D.", 3, 2, 1000);

    indicator.parameters:addString("MVAT_K", "Smoothing type for %K", "The type of smoothing algorithm for %K.", "MVA");
    indicator.parameters:addStringAlternative("MVAT_K", "MVA", "MVA", "MVA");
    indicator.parameters:addStringAlternative("MVAT_K", "EMA", "EMA", "EMA");
    indicator.parameters:addStringAlternative("MVAT_K", "MetaTrader", "The MetaTrader algorithm.", "MT");
	indicator.parameters:addStringAlternative("MVAT_K" , "LWMA", "", "LWMA");	
	indicator.parameters:addStringAlternative("MVAT_K" , "KAMA", "", "KAMA");	
	indicator.parameters:addStringAlternative("MVAT_K" , "SMMA", "", "SMMA");	
	indicator.parameters:addStringAlternative("MVAT_K" , "TMA", "", "TMA");	
	indicator.parameters:addStringAlternative("MVAT_K" , "VIDYA", "", "VIDYA");	
	indicator.parameters:addStringAlternative("MVAT_K" , "WMA", "", "WMA");	
    
    indicator.parameters:addString("MVAT_D", "Smoothing type for %D", "The type of smoothing algorithm for %D.", "MVA");
    indicator.parameters:addStringAlternative("MVAT_D", "MVA", "MVA", "MVA");
    indicator.parameters:addStringAlternative("MVAT_D", "EMA", "EMA", "EMA");
	indicator.parameters:addStringAlternative("MVAT_D" , "LWMA", "", "LWMA");	
	indicator.parameters:addStringAlternative("MVAT_D" , "KAMA", "", "KAMA");	
	indicator.parameters:addStringAlternative("MVAT_D" , "SMMA", "", "SMMA");	
	indicator.parameters:addStringAlternative("MVAT_D" , "TMA", "", "TMA");	
	indicator.parameters:addStringAlternative("MVAT_D" , "VIDYA", "", "VIDYA");	
	indicator.parameters:addStringAlternative("MVAT_D" , "WMA", "", "WMA");	

    indicator.parameters:addGroup("Line Style");
    indicator.parameters:addColor("UpColor", "Up Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DownColor", "Down Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("transparency", "Channel transparency (%)", "", 70, 0, 100);

	
	indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 80);
    indicator.parameters:addDouble("oversold","Oversold Level","", 20);
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
	indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
	
	
	indicator.parameters:addGroup("Alert Style");
    indicator.parameters:addColor("UpTrendColor", "Up Trend Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addColor("DownTrendColor", "Down Trend Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("Size", "Label Size", "", 10, 1 , 100);
	
	indicator.parameters:addGroup("Alerts Sound");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", true);	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);
	
	
	indicator.parameters:addGroup("Alerts Email");   
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", true);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);

	
	
	Parameters (1, "K/D Line");
	Parameters (2, "K/OB");
	Parameters (3, "K/OS");
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
-- Parameters block
local OB,OS;
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
 
 

local k;
local d;
local sd;
local averageTypeK = nil;
local averageTypeD = nil;
local source = nil;

local UpColor,DownColor;
-- Streams block
local kLine = nil;
local dLine = nil; 
local Stochastic;
local font;
-- Routine
function Prepare(nameOnly)
    k = instance.parameters.K;
    d = instance.parameters.D;
    sd = instance.parameters.SD; 
    source = instance.source;
	UpColor = instance.parameters.UpColor;
	DownColor = instance.parameters.DownColor;
	
	OS=instance.parameters.oversold;
	OB=instance.parameters.overbought;
	
	OnlyOnceFlag=true;
	FIRST=true;
	OnlyOnce = instance.parameters.OnlyOnce;
	ShowAlert = instance.parameters.ShowAlert;
	Show = instance.parameters.Show;
	Live = instance.parameters.Live;
	UpTrendColor = instance.parameters.UpTrendColor;
	DownTrendColor = instance.parameters.DownTrendColor;
	Size=instance.parameters.Size;
	
    
    averageTypeK = instance.parameters.MVAT_K;
    averageTypeD = instance.parameters.MVAT_D;

    local name = profile:id() .. "(" .. source:name().. ", " .. k .. ", " .. d .. ", " .. sd .. ", " .. averageTypeK .. ", " .. averageTypeD .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
    font = core.host:execute("createFont", "Wingdings", Size, false, false);
	
	assert(core.indicators:findIndicator("GTBS") ~= nil, "Please, download and install GTBS.LUA indicator");
	
	
	Stochastic= core.indicators:create("GTBS", source ,"Tick", k, d, sd , averageTypeK, averageTypeD);
	first=Stochastic.D:first();
	kLine = instance:addStream("K", core.Line, name .. ".K", "K", UpColor,Stochastic.K:first()); 
    kLine:setPrecision(math.max(2, instance.source:getPrecision()));
    dLine = instance:addStream("D", core.Line, name .. ".D", "D", UpColor,Stochastic.D:first()); 
    dLine:setPrecision(math.max(2, instance.source:getPrecision()));
	
	 kLine:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	 kLine:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
		
     instance:createChannelGroup("ch", "ch", kLine, dLine, UpColor, 100 - instance.parameters.transparency);

	 
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
 
  Stochastic:update(mode);
  
  if period < first then
  return;
  end
  
	                      kLine[period] = Stochastic.K[period]
						  dLine[period] = Stochastic.D[period]
						  
		                  if kLine[period] > dLine[period] then
						  dLine:setColor(period, UpColor);
						  kLine:setColor(period, UpColor);
						 else
						    dLine:setColor(period, DownColor);
						  kLine:setColor(period, DownColor);
						 end 
						 
	core.host:execute ("removeLabel", source:serial(period)); 

	 Activate (1, period); 
     Activate (2, period); 
	 Activate (3, period); 
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
	  
	       
			if  kLine[period] > dLine[period] 
			and   kLine[period-1] <= dLine[period-1] 
			then
			           
						    
             core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, dLine[period], core.CR_CHART, core.H_Center, core.V_Bottom, font, UpTrendColor, "\225");

 						 
						   
			
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
			elseif  kLine[period] < dLine[period] 
			and   kLine[period-1] >= dLine[period-1] 
            then			
			
			            			 
			               core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, dLine[period], core.CR_CHART, core.H_Center, core.V_Top, font, DownTrendColor, "\226");						   
						   
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
	  
	       
			if  kLine[period] > OB
			and   kLine[period-1] <=  OB
			then
			           
						    
             core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART,  OB, core.CR_CHART, core.H_Center, core.V_Bottom, font, UpTrendColor, "\225");

 						 
						   
			
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
			elseif  kLine[period] <  OB
			and   kLine[period-1] >=  OB
            then			
			
			            			 
			               core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART,  OB, core.CR_CHART, core.H_Center, core.V_Top, font, DownTrendColor, "\226");						   
						   
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
	  
	
     	  if id == 3  and ON[id]  then
	  
	       
			if  kLine[period] > OS
			and   kLine[period-1] <=  OS
			then
			           
						    
             core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART,  OS, core.CR_CHART, core.H_Center, core.V_Bottom, font, UpTrendColor, "\225");

 						 
						   
			
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
			elseif  kLine[period] <  OS
			and   kLine[period-1] >=  OS
            then			
			
			            			 
			               core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART,  OS, core.CR_CHART, core.H_Center, core.V_Top, font, DownTrendColor, "\226");						   
						   
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
   
   core.host:execute ("prompt", 1, label ,   " ( " .. source:instrument()  .. " ) "  ..   label .. " : " .. note );
  

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
   
        
    local text = Note  .. delim ..  Symbol   .. delim .. Time;
 
 
   terminal:alertEmail(Email, profile:id(), text);
end
	 




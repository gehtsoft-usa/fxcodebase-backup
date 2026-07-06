-- Id: 14918
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61196

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
    indicator:name("Averages Awesome Oscillator Convergence divergence");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	
	indicator.parameters:addGroup("Mode");  
	indicator.parameters:addString("Live", "End of Turn / Live", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
	indicator.parameters:addStringAlternative("Live", "Live", "", "Live");   
	
	
    indicator.parameters:addGroup("Calculation"); 
	indicator.parameters:addInteger("FM", "Fast Moving Average", "The number of periods to calculate the fast moving average of Price", 5, 2, 10000);
    indicator.parameters:addInteger("SM", "Slow Moving Average", "The number of periods to calculate the slow moving average of Price", 35, 2, 10000);
    
   	indicator.parameters:addString("Method1", "Fast/Slow Moving Average Method", "", "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method1", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method1", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Method1", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Method1", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Method1", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Method1", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Method1", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Method1", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Method1", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Method1", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Method1", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Method1", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Method1", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Method1", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Method1", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Method1", "JSmooth", "", "JSmooth");
	indicator.parameters:addStringAlternative("Method1", "KAMA", "", "KAMA");
    
    indicator.parameters:addInteger("Period", "Signal Line Moving Average Period", "The number of periods to calculate the fast moving average of the Awesome Oscillator", 5, 2, 10000);
	 indicator.parameters:addString("Method2", "Signal Line Moving Average Method", "", "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method2", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Method2", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method2", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Method2", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Method2", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Method2", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Method2", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Method2", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Method2", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Method2", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Method2", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Method2", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Method2", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Method2", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Method2", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Method2", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Method2", "JSmooth", "", "JSmooth");
	indicator.parameters:addStringAlternative("Method2", "KAMA", "", "KAMA");
	
	
	 indicator.parameters:addString("Type", "Histogram Source Selector", "", "Histogram");
    indicator.parameters:addStringAlternative("Type", "Awesome", "", "Awesome");
    indicator.parameters:addStringAlternative("Type", "Signal", "", "Signal");
    indicator.parameters:addStringAlternative("Type", "Histogram", "", "Histogram");
	
	
	indicator.parameters:addGroup("Style");

	 indicator.parameters:addColor("AOColor", "Awesome Line Color", "Awesome Line Color", core.rgb(128, 128,128));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("SignalColor", "Signal Line Color", "Signal Line Color", core.rgb(0, 128,255));
	 indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addColor("HistogramColor", "Histogram Line Color", "Histogram Line Color", core.rgb(128, 0,255));
	 indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
	
	    
    indicator.parameters:addColor("iUp", "Color for higher Histogram bars", "Color for higher bars", core.rgb(0, 255, 0));
    indicator.parameters:addColor("iDown", "Color for lower Histogram bars", "Color for lower bars", core.rgb(255, 0, 0));
	
	
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
	
	Parameters (1, "AO/Signal")
	Parameters (2, "AO/Zero")
	
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

local 	Number = 2;


local Method1;
local Method2;
local Period;
local FM;
local SM;
local iUp,iDown; 
local first;
local source = nil;
local Signal, signal;
local Type;


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

 
local AO = nil;
 
local FMVA = nil;
local SMVA = nil;
local SignalColor;
local HistogramColor;
local AOColor;
local Histogram;
function Prepare(nameOnly)
    FM = instance.parameters.FM;
    SM = instance.parameters.SM;
    SC = instance.parameters.SC;
	Type = instance.parameters.Type;
	Method1 = instance.parameters.Method1;
	Method2 = instance.parameters.Method2;
	Period = instance.parameters.Period;
	SignalColor = instance.parameters.SignalColor;
	HistogramColor = instance.parameters.HistogramColor;
	AOColor= instance.parameters.AOColor;
	iUp= instance.parameters.iUp;
	iDown= instance.parameters.iDown;
	
	
		OnlyOnceFlag=true;
	FIRST=true;
	OnlyOnce = instance.parameters.OnlyOnce;
	ShowAlert = instance.parameters.ShowAlert;
	Show = instance.parameters.Show;
	Live = instance.parameters.Live;
	UpTrendColor = instance.parameters.UpTrendColor;
	DownTrendColor = instance.parameters.DownTrendColor;
	Size=instance.parameters.Size;
    source = instance.source; 
    local name = profile:id() .. "(" .. source:name() .. ", " .. FM .. ", " .. SM .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
    font = core.host:execute("createFont", "Wingdings", Size, false, false);
	

	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");
    assert(FM < SM, "Fast moving average parameter must be less than slow moving average");

    FMVA = core.indicators:create("AVERAGES", source,Method1, FM, false);
    SMVA = core.indicators:create("AVERAGES", source,Method1, SM, false);
	
	first = math.max(FMVA.DATA:first(),SMVA.DATA:first());

    if Type == "Awesome" then
    AO = instance:addStream("AO", core.Bar, name .. ".AO", "AO", AOColor, first);
	else
	AO = instance:addStream("AO", core.Line, name .. ".AO", "AO", AOColor, first);
	AO:setWidth(instance.parameters.width1);
    AO:setStyle(instance.parameters.style1);
	end
	
	 signal = core.indicators:create("AVERAGES", AO,Method2, Period, false);
	
	
	if Type == "Signal" then
	Signal = instance:addStream("Signal", core.Bar, name .. ".Signal", "Signal", SignalColor, signal.DATA:first());
	else  
	Signal = instance:addStream("Signal", core.Line, name .. ".Signal", "Signal", SignalColor, signal.DATA:first());
	Signal:setWidth(instance.parameters.width2);
    Signal:setStyle(instance.parameters.style2);
	end
	
	if Type == "Histogram" then
	Histogram = instance:addStream("Histogram", core.Bar, name .. ".Histogram", "Histogram", HistogramColor, signal.DATA:first());
	else
	 Histogram = instance:addStream("Histogram", core.Line, name .. ".Histogram", "Histogram", HistogramColor, signal.DATA:first());
	Histogram:setWidth(instance.parameters.width3);
    Histogram:setStyle(instance.parameters.style3);
	end
	
	
	AO:setPrecision(math.max(2, instance.source:getPrecision()));
	Signal:setPrecision(math.max(2, instance.source:getPrecision()));
	Histogram:setPrecision(math.max(2, instance.source:getPrecision()));
	
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


function Update(period, mode)
 
    FMVA:update(mode);
    SMVA:update(mode);

    if (period  < first) then
	return;
	end
   
    AO[period] = FMVA.DATA[period] - SMVA.DATA[period];
 
    if Type == "Awesome" then
		 if AO[period] > AO[period-1] then
		AO:setColor(period, iUp);
		else
		AO:setColor(period, iDown);
		end
	end
	
	 signal:update(mode);
	
	if (period  < signal.DATA:first()) then
	return;
	end
	
	Signal[period]=signal.DATA[period];
	
	Histogram[period]=AO[period]- Signal[period];
	
	if Type == "Signal" then
		 if Signal[period] > Signal[period-1] then
		Signal:setColor(period, iUp);
		else
		Signal:setColor(period, iDown);
		end
	end
	
	
		if Type == "Histogram" then
		 if Histogram[period] > Histogram[period-1] then
		Histogram:setColor(period, iUp);
		else
		Histogram:setColor(period, iDown);
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
	  
	       
			if  AO[period] > Signal[period] 
			and  AO[period-1] <= Signal[period-1] 
			then
			           
						    
             core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, Signal[period], core.CR_CHART, core.H_Center, core.V_Bottom, font, UpTrendColor, "\225");

 						 
						   
			
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
			elseif  AO[period] < Signal[period] 
			and   AO[period-1] >= Signal[period-1] 
            then			
			
			            			 
			               core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, Signal[period], core.CR_CHART, core.H_Center, core.V_Top, font, DownTrendColor, "\226");						   
						   
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
	  
	       
			if  AO[period] > 0
			and  AO[period-1] <= 0
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
			elseif  AO[period] < 0
			and   AO[period-1] >= 0
            then			
			
			            			 
			               core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, 0, core.CR_CHART, core.H_Center, core.V_Top, font, DownTrendColor, "\226");						   
						   
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
	 




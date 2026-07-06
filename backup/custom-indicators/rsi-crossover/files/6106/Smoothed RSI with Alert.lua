
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2675

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
    indicator:name("Smoothed RSI");
    indicator:description("Smoothed RSI");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	
	indicator.parameters:addGroup("Alert Parameters");  
	indicator.parameters:addString("Live", "End of Turn / Live", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
	indicator.parameters:addStringAlternative("Live", "Live", "", "Live");   
	indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true);
	indicator.parameters:addBoolean("OnlyOnce", "Alert Once", "Subsequent Alert will be ignored.", false);	

    indicator.parameters:addInteger("RSIFrame", "RSI Period", "", 14);
	
	indicator.parameters:addGroup("MA Parameters");
    indicator.parameters:addInteger("MAFrame", "MA Period", "MA Period", 10);
	indicator.parameters:addString("Method", "MA Method", "MA Method", "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "", "TMA"); 
	
		
	indicator.parameters:addGroup("Overbought/oversold Level");
    indicator.parameters:addInteger("overbought", "Overbought Level", "", 70, 0, 100);
    indicator.parameters:addInteger("oversold", "Oversold Level", "", 30, 0, 100);
    indicator.parameters:addInteger("level_overboughtsold_width", "Over Bought/Sold Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Over Bought/Sold Line Style", "", core.LINE_SOLID);
    indicator.parameters:addColor("level_overboughtsold_color", "Over Bought/Sold Line Color", "", core.rgb(255, 0, 0));
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addGroup("MA Line Style");	
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	--indicator.parameters:addColor("signal_color", "MALine Color", "", core.rgb(128, 128, 128));
	
	indicator.parameters:addGroup("Cloud Style");	
	indicator.parameters:addInteger("Transparency", "Transparency", "", 40,0,100);
    indicator.parameters:addColor("ColorUp", "Color of Up", "Color of Up", core.rgb( 0, 255, 0));   
    indicator.parameters:addColor("ColorDown", "Color of Down", "Color of Down", core.rgb(255, 0, 0));
 
	
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

	
	Parameters (1, "Central Line")
	Parameters (2, "OB Line")
	Parameters (3, "OS Line")
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
local RSIFrame;
local MAFrame;
local Method;
local Transparency,UpColor, DownColor,UpSignal,DownSignal;

local ColorUp=nil;
local ColorDown=nil;

local first;
local source = nil;

-- Streams block 
local MA = nil;
local Indicator={};
local Zero ;
local Long;
local Short; 
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
 
-- Routine
function Prepare(nameOnly)
    Method = instance.parameters.Method;
    RSIFrame = instance.parameters.RSIFrame;
    MAFrame = instance.parameters.MAFrame;
	Transparency=instance.parameters.Transparency;
	ColorUp=instance.parameters.ColorUp;
	ColorDown=instance.parameters.ColorDown; 
	Transparency= 100-Transparency;
	UpTrendColor = instance.parameters.UpTrendColor;
	DownTrendColor = instance.parameters.DownTrendColor;
	UpSignal = instance.parameters.UpTrendColor;
	DownSignal= instance.parameters.DownTrendColor;
	OB=instance.parameters.overbought; 
	OS=instance.parameters.oversold;
	
	
	OnlyOnceFlag=true;
	FIRST=true;
	OnlyOnce = instance.parameters.OnlyOnce;
	Show = instance.parameters.Show;
	Live = instance.parameters.Live;
	Size=instance.parameters.Size;
	
	font = core.host:execute("createFont", "Wingdings", Size, false, false);
	
    source = instance.source;
	
	
	local name = profile:id() .. "(" .. source:name() .. ", " .. RSIFrame .. ", " .. MAFrame .. "," .. Method.. ")";
    instance:name(name);	
	
	if   (nameOnly) then
        return;
    end
   
	
	assert(core.indicators:findIndicator(Method) ~= nil, "Please, download and install "..Method.." indicator");
	
	Indicator[1]= core.indicators:create("RSI", source, RSIFrame);	 
 
	
	Long = instance:createTextOutput ("Long", "Long", "Wingdings", Size, core.H_Center, core.V_Bottom, UpSignal, 0);
    Short = instance:createTextOutput ("Short", "Short", "Wingdings", Size, core.H_Center, core.V_Top, DownSignal, 0);
	core.host:execute ("attachTextToChart", "Long")
	core.host:execute ("attachTextToChart", "Short")
	

    


	Indicator[2]= core.indicators:create(Method, Indicator[1].DATA, MAFrame);	
	 first= Indicator[2].DATA:first();
		
    MA = instance:addStream("MA", core.Line, name .. ".MA", "MA", ColorUp, first);
    MA:setWidth(instance.parameters.width);
    MA:setStyle(instance.parameters.style);	
    
	
	
	MA:addLevel(OB, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    MA:addLevel(OS, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
	MA:setPrecision(2);

	Zero=instance:addInternalStream (first, 0);
	 
	
	 
	Initialization();
	
	instance:createChannelGroup("ChannelGroup","ChannelGroup" , MA, Zero, ColorUp, Transparency); 
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
  
	 
 
	
	   Calculate(period, mode);

    core.host:execute ("removeLabel", source:serial(period)); 
   
     if period < first then
	 return;
	 end
	
    Activate (1, period);
	Activate (2, period);
	Activate (3, period);
end


function Activate (id, period)

   local Shift=0;
   

   if Live~= "Live" then
	period=period-1;
	Shift=1;
	end
 
	  if id == 1  and ON[id]  then
	  
	       
			if  MA[period] > 50
			and   MA[period-1] <= 50
			then
			           
						    
             core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, 50, core.CR_CHART, core.H_Center, core.V_Bottom, font, UpTrendColor, "\225");

 						 
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  then
							  OnlyOnceFlag=false;
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Cross Over", period);
							    
							        
									Pop(Label[id], " Cross Over " );  	
								    
								 
							  end
			elseif  MA[period] < 50
			and   MA[period-1] >= 50
            then			
			
			            			 
			               core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, 50, core.CR_CHART, core.H_Center, core.V_Top, font, DownTrendColor, "\226");						   
						   
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
								  
							 
			                  end			   
	         end
			
	  
	 
	  end
	  
	  
	  
	   if id == 2  and ON[id]  then
	  
	       
			if  MA[period] > OB
			and   MA[period-1] <= OB
			then
			           
						    
             core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, OB, core.CR_CHART, core.H_Center, core.V_Bottom, font, UpTrendColor, "\225");

 						 
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  then
							  OnlyOnceFlag=false;
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Cross Over", period);
							    
							        
									Pop(Label[id], " Cross Over " );  	
								    
								 
							  end
			elseif  MA[period] < OB
			and   MA[period-1] >= OB
            then			
			
			            			 
			               core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, OB, core.CR_CHART, core.H_Center, core.V_Top, font, DownTrendColor, "\226");						   
						   
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
								  
							 
			                  end			   
	         end
			
	  
	 
	  end
	  
	  
	  
	  
	   if id == 3  and ON[id]  then
	  
	       
			if  MA[period] > OS
			and   MA[period-1] <= OS
			then
			           
						    
             core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, OS, core.CR_CHART, core.H_Center, core.V_Bottom, font, UpTrendColor, "\225");

 						 
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  then
							  OnlyOnceFlag=false;
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Cross Over", period);
							    
							        
									Pop(Label[id], " Cross Over " );  	
								    
								 
							  end
			elseif  MA[period] < OS
			and   MA[period-1] >= OS
            then			
			
			            			 
			               core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, OS, core.CR_CHART, core.H_Center, core.V_Top, font, DownTrendColor, "\226");						   
						   
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
								  
							 
			                  end			   
	         end
			
	  
	 
	  end
        if FIRST then
        FIRST=false;      
        end		

end

function Calculate(period, mode) 		

  if period < first or not  source:hasData(period) then
	return;
	end
	
 
	
		Indicator[1]:update(mode);	 
		Indicator[2]:update(mode);
		
		Short:setNoData (period);	
		Long:setNoData (period);  
		
			if not Indicator[2].DATA:hasData(period) 
			or not Indicator[2].DATA:hasData(period-1) 
			then
			return
			end
		
			

			   if core.crossesOver (Indicator[2].DATA, 50, period) then
			   Long:set(period, source[period], "\108");
			   elseif core.crossesUnder (Indicator[2].DATA, 50, period) then
			   Short:set(period, source[period], "\108");
			   end
			
			   MA[period]= Indicator[2].DATA[period];
			 
			   
			   Zero[period]= 50;
			   
			   if MA[period] > 50 then
			   MA:setColor(period, ColorUp);
			   else 
			   MA:setColor(period, ColorDown);  	   
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
	 

	


-- Id: 9309
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=41176

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
    indicator:name("RSI MA Cross Alert");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
   
    indicator.parameters:addGroup("Mode");  
	indicator.parameters:addString("Live", "End of Turn / Live", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
	indicator.parameters:addStringAlternative("Live", "Live", "", "Live");
   
   
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("RP", "RSI Period", "", 14, 2, 1000);
    indicator.parameters:addInteger("MP", "MA Period", "", 14, 2, 1000);
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addBoolean("Filter", "Use OB/OS Filter", "", false);	
 

 
	
	 indicator.parameters:addGroup("Indicator Style");
	 indicator.parameters:addColor("RSI_color", "RSI color", "(RSI Color) Red", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("RSI_width", "RSI Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("RSI_style", "RSI Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("RSI_style", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("MA_color", "MA color", "(MA Color) Blue", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("MA_width", "MA Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("MA_style", "MA Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("MA_style", core.FLAG_LINE_STYLE);
	
	
	 indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 80);
    indicator.parameters:addDouble("oversold","Oversold Level","", 30);
     indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);

	
	indicator.parameters:addGroup("Alert Style");
    indicator.parameters:addColor("Up", "Up Trend Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addColor("Down", "Down Trend Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("Size", "Label Size", "", 10, 1 , 100);
	
	indicator.parameters:addGroup("Alerts Sound");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", false);	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);
	
	indicator.parameters:addGroup("Alerts Email");   
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", false);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);
	
	
	Parameters (1, "RSI / MA Line")
 
	

	
	
end

function Parameters ( id, Label )
  
  
   indicator.parameters:addGroup(Label .. " Alert");
  
    indicator.parameters:addBoolean("ON"..id , "Show " .. Label .." Alert" , "", false);


    indicator.parameters:addFile("Up"..id, Label .. " Cross Over Sound", "", "");
    indicator.parameters:setFlag("Up"..id, core.FLAG_SOUND);
	
	indicator.parameters:addFile("Down"..id, Label .. " Cross Under Sound", "", "");
    indicator.parameters:setFlag("Down"..id, core.FLAG_SOUND);
	
	 indicator.parameters:addString("Label"..id, "Label", "", Label);

end 

local 	Number = 1;

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
local Filter;
local Alert;
local Indicator;
local PlaySound;

local FIRST=true;
 

local U={};
local D={};

local Method, RP,MP;
local RSI, MA, rsi, ma;
 

local OnlyOnceFlag;
local FIRST; 
local Show;
local Live;
-- Routine
function Prepare(nameOnly)   
    
    source = instance.source;
	
	OnlyOnceFlag=true;
	FIRST=true;
	
	Filter= instance.parameters.Filter;
	OnlyOnce = instance.parameters.OnlyOnce;
	Show = instance.parameters.Show;
	Live = instance.parameters.Live;
	
	FIRST=true;
	
	Method = instance.parameters.Method;
	RP = instance.parameters.RP;
    MP = instance.parameters.MP;
	
	 

    -- Base name of the indicator.
    local name = profile:id() .. "(" .. source:name() .. ", " .. RP .. ", " .. Method .. ", " .. MP .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	
	 -- Create short and long EMAs for the source
    rsi = core.indicators:create("RSI", source, RP);
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
    ma = core.indicators:create(Method, rsi.DATA, MP);
	
 
 
    RSI = instance:addStream("MACD", core.Line, name .. ".RSI", "RSI", instance.parameters.RSI_color, rsi.DATA:first());
    RSI:setPrecision(math.max(2, instance.source:getPrecision()));
	RSI:setWidth(instance.parameters.RSI_width);
    RSI:setStyle(instance.parameters.RSI_style);
 
    MA = instance:addStream("MA", core.Line, name .. ".MA", "MA", instance.parameters.MA_color,  ma.DATA:first());
    MA:setPrecision(math.max(2, instance.source:getPrecision()));
	MA:setWidth(instance.parameters.MA_width);
    MA:setStyle(instance.parameters.MA_style);
	
	

    RSI:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	RSI:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
		

   
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
 
    rsi:update(mode);
   
    if rsi.DATA:first()> period then
	return;
	end
	
	RSI[period]= rsi.DATA[period];
	
	 ma:update(mode);

	 if ma.DATA:first()> period then
	return;
	end
	
	MA[period]= ma.DATA[period];
 
 end
 

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode) 



    Calculate(period, mode);
	
	
	local i;
	for i = 1, Number , 1 do
		  if ON[i] then
		 down[i]:setNoData (period); 
		 up[i]:setNoData (period);
		 end
   end	 
   
   if period < ma.DATA:first() then
return;
end
	
    Activate (1, period)
 
end



function Activate (id, period)

   local Shift=0;
   

   if Live~= "Live" then
	period=period-1;
	Shift=1;
	end
 
	  if id == 1  and ON[id]  then
	  
	       
			if RSI[period] > MA[period]
			and RSI[period-1] <= MA[period-1]
			and ( not Filter or Filter and RSI[period] < instance.parameters.oversold )
			then
			           
						     up[id]:set(period , MA[period], "\108");	
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  then
							  OnlyOnceFlag=false;
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Cross Over", period);
							    
							        if Show then
									Pop(Label[id], " Cross Over " );  	
								    end
								 
							  end
			elseif  RSI[period] < MA[period]
			and RSI[period-1] >= MA[period-1]
			and ( not Filter or Filter and RSI[period] > instance.parameters.overbought )
            then			
			
			            			 
			               down[id]:set(period , MA[period], "\108");	  						   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 then
							 OnlyOnceFlag=false;
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " Cross Under", period);	
								 if Show then
									Pop(Label[id], " Cross Under " );  	
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
   " ( " .. source:instrument()  .. " ) "  ..   label .. " : " .. note );


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
   
     local text = Note  .. delim ..  Symbol  .. delim .. Time;
 
   terminal:alertEmail(Email, profile:id(), text);
end
	 


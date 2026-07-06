-- Id: 14951

-- Available @ http://fxcodebase.com/code/viewtopic.php?f=17&t=27291

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
    indicator:name("MTF WAAB with Alert");
    indicator:description("MTF WAAB with Alert");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    
	Add (1 , "m1" ,core.rgb( 128, 128, 128));
	Add (2 , "m5",core.rgb( 0, 0, 255) );
	Add (3 , "m15",core.rgb( 0, 255, 0) );
    Add (4 , "m30",core.rgb( 255, 0, 0) ); 
	
		
	
   
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
	
	
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
	
	Parameters (1, "WAAB / Level");

end

function Add (id , FRAME, Color)

    indicator.parameters:addGroup(id.. ". Time Frame");	
    indicator.parameters:addString("TF"..id, id.. ". Time frame", "", FRAME);
    indicator.parameters:setFlag("TF"..id, core.FLAG_PERIODS);
	
		
    indicator.parameters:addInteger("ADXP"..id, "ADX Period", "ADX Period", 14);
	
    indicator.parameters:addInteger("BBP"..id, "Bollinger Period", "Bollinger Period", 20);
	indicator.parameters:addString("Price"..id, "Bollinger Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price"..id, "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price"..id, "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price"..id, "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price"..id,"CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price"..id, "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price"..id, "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price"..id, "WEIGHTED", "", "weighted");	
	
	 indicator.parameters:addDouble("Level"..id, "Level","", 0);
	 
	indicator.parameters:addColor("Color"..id, "Line Color", "Color of WAAB", Color);
	 
	 
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

local loading={};
local TF={};

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local ADXP={};
local BBP={};
local Level={};
local first;
local source = nil;
local Source={};
-- Streams block
local WAAB = {};
local waab={};
local Price={};
local Color={};


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
local dayoffset,weekoffset; 
local iNumber;
-- Routine
function Prepare(nameOnly)
    
    source = instance.source;
   
 
	
	dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");	
	 s, e = core.getcandle(source:barSize(), core.now(), 0, 0);
	
	iNumber=0;
	for i= 1, 4, 1 do 
    	s1, e1 = core.getcandle(instance.parameters:getString ("TF"..i), core.now(), 0, 0);
		if (e - s) <= (e1 - s1)  then
		 
			iNumber=iNumber+1;
			TF[iNumber]=instance.parameters:getString ("TF"..i);
			ADXP[iNumber] = instance.parameters:getInteger ("ADXP"..i);
			BBP[iNumber] = instance.parameters:getInteger ("BBP"..i);
			Price[iNumber] = instance.parameters:getString ("Price"..i);
			Level[iNumber] = instance.parameters:getDouble ("Level"..i);
			Color[iNumber]= instance.parameters:getDouble ("Color"..i);
		end
	end

	OnlyOnceFlag=true;
	FIRST=true;
	OnlyOnce = instance.parameters.OnlyOnce;
	ShowAlert = instance.parameters.ShowAlert;
	Show = instance.parameters.Show;
	Live = instance.parameters.Live;
	UpTrendColor = instance.parameters.UpTrendColor;
	DownTrendColor = instance.parameters.DownTrendColor;
	Size=instance.parameters.Size;

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
    if (not (nameOnly)) then
		font = core.host:execute("createFont", "Wingdings", Size, false, false);
	    for i= 1, iNumber, 1 do  
    assert(core.indicators:findIndicator("WAAB") ~= nil, "WAAB" .. " indicator must be installed");
			Test = core.indicators:create("WAAB", source, ADXP[i], BBP[i], Price[i] );  			
			first= Test.DATA:first()*2+1 ; 				
			Source[i] = core.host:execute("getSyncHistory",source:instrument(), TF[i], source:isBid(), first, 200+i, 100+i);
			waab[i] =core.indicators:create("WAAB", Source[i], ADXP[i], BBP[i], Price[i])
			WAAB[i] = instance:addStream("WAAB".. i, core.Line, name, i.. ". WAAB", Color[i], first);
    WAAB[i]:setPrecision(math.max(2, instance.source:getPrecision()));
			WAAB[i]:addLevel(Level[i], instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
		end
    end
	
	Initialization();
	
end


function   FindPeriod(period,id)

    local Candle;
    Candle = core.getcandle(source:barSize(), source:date(period), dayoffset, weekoffset);
  
    if loading[id] or Source[id]:size() == 0  then
        return false;
    end

    
    if period < source:first() then
        return false;
    end

    local P = core.findDate(Source [id], Candle, false);
	 

    -- candle is not found
    if P < 0    then
        return false;
	else return P;	
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
function Update(period, mode) 
 
	  
	local Flag= false;
	
	for i= 1, iNumber, 1 do
	
		if loading[i] then		
			Flag=true;
		else
			waab[i]:update(mode);
			p=FindPeriod(period,i);
			WAAB[i][period]= waab[i].DATA[p];
		end
		
	end
		
	
	 
	
	if period < source:size()-1 then  
		return;
    end
	
	for i= 1, iNumber, 1 do  
		Activate (1, period,i);
	end
	
   
end



function ReleaseInstance()
	core.host:execute("deleteFont", font);
end	   

function Activate (id, period,fig)

   local Shift=0;
   

   	if Live~= "Live" then
		period=period-1;
		Shift=1;
	end
 
	  if id == 1  and ON[id]  then
	  
	       
			if  WAAB[fig][period] > Level[fig]
			and   WAAB[fig][period-1] <= Level[fig]
			then
			         	   
			
			 D[fig] = nil;
						   
							  if U[fig]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  then
							  OnlyOnceFlag=false;
							  U[fig]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id],TF[fig].. " Cross Over", period);
							  SendAlert(TF[fig].."Crossed over");  
							        
									Pop(Label[id], TF[fig].. " Cross Over " );  	
								    
								 
							  end
			elseif  WAAB[fig][period] < Level[fig]
			and   WAAB[fig][period-1] >= Level[fig]
            then			
			
			             
						   
		     U[fig] = nil;
		   
			                 if  D[fig]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 then
							 OnlyOnceFlag=false;
							 D[fig]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] ,TF[fig].." Cross Under", period);	
								 
									Pop(Label[id],TF[fig].. " Cross Under " );  	
								    SendAlert(TF[fig].. "Crossed under");
							 
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
	 

	  
   -- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
     local j;	 
	local Flag = false;	
	local Count=0;	
	
	
	
    for j = 1, iNumber, 1 do
		
			  if cookie == (100+j) then
			  loading[j] = true;
		      elseif  cookie == (200+j) then
			  loading[j] = false;  		 
              end
			  
		if loading[j] then
		Count=Count+1;
		Flag=true;
		end	 

		  
		if Flag then
		core.host:execute ("setStatus", " Loading ".. (iNumber-Count) .."/" .. iNumber);
		else
		
		instance:updateFrom(0);
		core.host:execute ("setStatus", " Loaded ".. (iNumber-Count) .."/" .. iNumber);
		end
			  
	end    
   
        
		return core.ASYNC_REDRAW ;
end
 




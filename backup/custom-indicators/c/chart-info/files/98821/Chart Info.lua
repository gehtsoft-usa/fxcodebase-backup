
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61866

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
    indicator:name("Chart Info");
    indicator:description("Chart Info");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Selector");   
    indicator.parameters:addBoolean("Time", "Time", "", true);	
    indicator.parameters:addBoolean("Spread", "Spread", "", true);	
	indicator.parameters:addBoolean("I1", "1. Indicator", "", false)
	indicator.parameters:addString("INDICATOR1", "Indicator", "", "");
    indicator.parameters:setFlag("INDICATOR1", core.FLAG_INDICATOR );
	indicator.parameters:addBoolean("I2", "2. Indicator", "", false)
	indicator.parameters:addString("INDICATOR2", "Indicator", "", "");
    indicator.parameters:setFlag("INDICATOR2",core.FLAG_INDICATOR);
	indicator.parameters:addBoolean("I3", "3. Indicator", "", false)
	indicator.parameters:addString("INDICATOR3", "Indicator", "", "");
    indicator.parameters:setFlag("INDICATOR3",core.FLAG_INDICATOR);
	
	indicator.parameters:addGroup("Time Until Candle End");	
	indicator.parameters:addString("Type", "Type", "", "Time");
    indicator.parameters:addStringAlternative("Type", "Time", "", "Time");
    indicator.parameters:addStringAlternative("Type", "Percentage", "", "Percentage");
	
	indicator.parameters:addString("Units", "Units", "", "Minute");
    indicator.parameters:addStringAlternative("Units", "Minute", "", "Minute");
    indicator.parameters:addStringAlternative("Units", "Seconds", "", "Seconds");	
	
	
	indicator.parameters:addDouble("TriggerLevel", "Trigger Level (in units / percentage)", "", 1, 0, 1000);
	
	
	

	
	indicator.parameters:addString("evPos", "Vertical position", "", "Top");
    indicator.parameters:addStringAlternative("evPos", "Top", "", "Top");
    indicator.parameters:addStringAlternative("evPos", "Middle", "", "Middle");
    indicator.parameters:addStringAlternative("evPos", "Bottom", "", "Bottom");
    indicator.parameters:addString("ehPos", "Horizontal position", "", "Right");
    indicator.parameters:addStringAlternative("ehPos", "Left", "", "Left");
    indicator.parameters:addStringAlternative("ehPos", "Centre", "", "Centre");
    indicator.parameters:addStringAlternative("ehPos", "Right", "", "Right");
	
	indicator.parameters:addGroup("Alerts Sound");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", true);	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);
	
	indicator.parameters:addFile("Sound",   "Alert Sound", "", "");
    indicator.parameters:setFlag("Sound", core.FLAG_SOUND);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Color", "Label Color", "Color of Label ", core.COLOR_LABEL );
	indicator.parameters:addInteger("Size", "Font Size", "Font Size", 10 );
	indicator.parameters:addColor("Up", "Color Of Up", "", core.rgb(0, 0, 255));
	indicator.parameters:addColor("Down", "Color Of Down", "", core.rgb(255, 0, 0)); 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Indicator={};
local first;
local source = nil;
local Length;
local Color = nil;
local Context;
local Size;
local evPos, eHPos;
local font;
local Type;
local TriggerLevel;
local Units;
local Sound;
local  RecurrentSound ,SoundFile  ;
local PlaySound;
local Alert=nil;
local Last;
local Length0, Length1;
local Up, Down;
local SL=0;
local Count;
local Spread;
local Time;
local I={};
local iprofile={};
local iparams={};


function Add(i)
  if not I[i] then
  return;
  end   
	iprofile[i] = core.indicators:findIndicator(instance.parameters:getString("INDICATOR".. i));
	iparams[i] = instance.parameters:getCustomParameters("INDICATOR".. i);
 
	if  iprofile[i]:requiredSource() == core.Tick then
	Indicator[i] = iprofile[i]:createInstance(source.close, iparams[i]);
	else
	Indicator[i] = iprofile[i]:createInstance(source, iparams[i]);
	end
	
end
function Prepare(nameOnly)
    source = instance.source;
    first = source:first();
	Spread= instance.parameters.Spread;
	Time= instance.parameters.Time;
	Up= instance.parameters.Up;
	Down= instance.parameters.Down;
	Color= instance.parameters.Color;
	Size= instance.parameters.Size;
	evPos= instance.parameters.evPos;
	ehPos= instance.parameters.ehPos;
	Type= instance.parameters.Type;
	TriggerLevel= instance.parameters.TriggerLevel;
	Units= instance.parameters.Units;
	I[1]=  instance.parameters.I1;
	I[2]=  instance.parameters.I2;
	I[3]=  instance.parameters.I3;
	
	
	for i= 1, 3, 1 do
	Add(i);
	end

 
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. Type.. ", " .. TriggerLevel.. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	 
	 assert(source:isAlive(), "The chart must be the live price, not a history");
    assert(source:barSize() ~= "t1", "The chart must be the bar history, not tick history");
    local s, e;  
    s, e = core.getcandle(source:barSize(), 0, 0, 0);
    Length = math.floor((e - s) * 86400 + 0.5);
		
	s0, e0 = core.getcandle("m1", 0, 0, 0);
	if Units== "Minute" then
	Length0= e0-s0;
	else
	Length0= (e0-s0)/60;
	end
	Length1= ( e-s)/Length0;
	
	if Type =="Time" then 
	     assert( not (TriggerLevel >=  (Length1/Length0)), "The maximum TriggerLevel in units must be less than " .. (Length1/Length0) );	   
	else 
	     assert( not (TriggerLevel >=  100), "Maximum percentage must be less than 100");
	end	
		
		
    font = core.host:execute("createFont",  "Arial", Size, false, false);
	core.host:execute ("setTimer", 1, 1);
	
	
	RecurrentSound= instance.parameters.RecurrentSound;
	PlaySound = instance.parameters.PlaySound;
	
    if PlaySound then 
	  Sound=instance.parameters.Sound; 
    else  
      Sound=nil;
	 end
	 
	 
	assert(not(PlaySound) or (PlaySound and Sound ~= "") or (PlaySound and Sound ~= ""), "Sound file must be chosen"); 
	  
end

 function AddIndicator(i)  
 
       if not I[i] then
	   return;
	   end
	  
	   
	Indicator[i]:update(core.UpdateLast); 
	   
    Count=Count+1;
           if evPos == "Top" then
            VPos, VAlign = core.CR_TOP, core.V_Center; 
            HOffset=0;
           VOffset=(Count)*Size*1.5;			
        elseif evPos == "Bottom" then
            VPos, VAlign = core.CR_BOTTOM, core.V_Center;   
             HOffset=0;
            VOffset=-(Count)*Size*1.5;			
        else
            VPos, VAlign = core.CR_CENTER, core.V_Center;    
             HOffset=0;
            VOffset=(Count)*Size*1.5;			
        end
		
		 local HPos, HAlign;
        if ehPos == "Left" then
            HPos, HAlign = core.CR_LEFT, core.H_Right;
        elseif ehPos == "Right" then
            HPos, HAlign = core.CR_RIGHT, core.H_Left;
        else
            HPos, HAlign = core.CR_CENTER, core.H_Center;
        end
 
        local Text=  instance.parameters:getString("INDICATOR".. i)  .. " ";
       
        for j=0, Indicator[i]:getStreamCount ()-1,1 do
		Value=  string.format("%." .. 4 .. "f",  Indicator[i]:getStream (j)[Indicator[i]:getStream (j):size()-1]);
        Text = Text .. " ".. tostring(j+1) .. ". " .. Value;  
        end		
		 
		
        core.host:execute("drawLabel1", Count, HOffset, HPos, VOffset, VPos, HAlign, VAlign,   font, Color, Text);
 end
 


function ReleaseInstance() 
core.host:execute("deleteFont", font);
core.host:execute ("killTimer", 1);
end

 
 function AsyncOperationFinished (cookie)
 
 
 if cookie~= 1 then
 return;
 end
 
    Count=0;  
	
    AddTime()  
	AddBidAsk();
	
	for i=1, 3, 1 do
	AddIndicator(i);
	end
	
 end
 
 function AddTime()
 
       if not Time then
	   return;
	   end 
 
         Count=Count+1;
       if evPos == "Top" then
            VPos, VAlign = core.CR_TOP, core.V_Center; 
            HOffset=0;
           VOffset=(Count)*Size*1.5;			
        elseif evPos == "Bottom" then
            VPos, VAlign = core.CR_BOTTOM, core.V_Center;   
             HOffset=0;
            VOffset=-(Count)*Size*1.5;			
        else
            VPos, VAlign = core.CR_CENTER, core.V_Center;    
             HOffset=0;
            VOffset=(Count)*Size*1.5;			
        end
		
		 local HPos, HAlign;
        if ehPos == "Left" then
            HPos, HAlign = core.CR_LEFT, core.H_Right;
        elseif ehPos == "Right" then
            HPos, HAlign = core.CR_RIGHT, core.H_Left;
        else
            HPos, HAlign = core.CR_CENTER, core.H_Center;
        end
 
  
 
		
		  local now = core.now();
       
        now = core.host:execute("convertTime", 3, 1, now); 
        local past = math.floor((now - source:date(source:size()-1)) * 86400 + 0.5);
        past = Length - past;
		
		if past> Length then
		 past= past - Length;
		end
		
		local Text="";
		
        if past > 0 then
		
		    if Type == "Time" then
            local h, m, s;
            s = math.floor(past % 60);
            m = math.floor((past / 60)) % 60;
            h = math.floor(past / 3600);
            Text=  string.format("%i:%02i:%02i\013\010", h, m, s);
			else
			Text=string.format("%." .. 2 .. "f",  past/(Length/100));
			end
		else
 		Text="00:00:00";
        end		
		
		 core.host:execute("drawLabel1", Count, HOffset, HPos, VOffset, VPos, HAlign, VAlign,   font, Color, "Time thill end :" ..  Text);
		 
        
		if Units == "Minute" then
	    past= past/60;
		end
		
	    if Type ~="Time" then
		past= past/(Length1/100)
		end 
		
		
		
		if Type =="Time" 
		and past <=  TriggerLevel
		and Last~= source:serial(source:size()-1)
		then 
		   SoundAlert(Sound);
		    Last= source:serial(source:size()-1)
		elseif Type =="Percentage" 
		and  past < TriggerLevel
		and Last~= source:serial(source:size()-1)
		then	
		SoundAlert(Sound );
		Last= source:serial(source:size()-1)
		end	
 end
 
 function AddBidAsk()  
 
       if not Spread then
	   return;
	   end
	   
	  if not(checkReady("offers")) then
                    return ;
       end
				
    Count=Count+1;
           if evPos == "Top" then
            VPos, VAlign = core.CR_TOP, core.V_Center; 
            HOffset=0;
           VOffset=(Count)*Size*1.5;			
        elseif evPos == "Bottom" then
            VPos, VAlign = core.CR_BOTTOM, core.V_Center;   
             HOffset=0;
            VOffset=-(Count)*Size*1.5;			
        else
            VPos, VAlign = core.CR_CENTER, core.V_Center;    
             HOffset=0;
            VOffset=(Count)*Size*1.5;			
        end
		
		 local HPos, HAlign;
        if ehPos == "Left" then
            HPos, HAlign = core.CR_LEFT, core.H_Right;
        elseif ehPos == "Right" then
            HPos, HAlign = core.CR_RIGHT, core.H_Left;
        else
            HPos, HAlign = core.CR_CENTER, core.H_Center;
        end
 
       local ASK = core.host:findTable("offers"):find("Instrument", source:instrument()).Ask;
	    local BID = core.host:findTable("offers"):find("Instrument", source:instrument()).Bid;
		
 	   if ASK== nil or BID == nil then
		return;
		end
		
		
		local sub_value = 0; 
	
	  sub_value = (ASK - BID) / source:pipSize() ;
	 
	  
			 
			 if sub_value ~= SL then
					 
					 if  sub_value > SL  then
					SpreadColor =Up;
					 else
					  SpreadColor =Down;
					 end
			         SL  = sub_value;
			 end
			 
			  Text= "Spread :" .. string.format("%." .. source:getPrecision() .. "f", sub_value);
             core.host:execute("drawLabel1", Count, HOffset, HPos, VOffset, VPos, HAlign, VAlign,   font, Color, Text);
 end
 



function SoundAlert(iAlert )
 if not PlaySound then
 return;
 end

  terminal:alertSound(iAlert, RecurrentSound);

end

	 

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    
end


function checkReady(table)
    local rc;
    if Account == "TESTACC_ID" then
        -- run under debugger/simulator
        rc = true;
    else
        rc = core.host:execute("isTableFilled", table);
    end

    return rc;
end


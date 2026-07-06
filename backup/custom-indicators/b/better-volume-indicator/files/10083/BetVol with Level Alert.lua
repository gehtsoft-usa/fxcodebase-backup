-- Id: 19755
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=4037

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
    indicator:name("Climax Volume Spread v2");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "GSL");
	
    indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("N", "Average Period", "", 20);
    indicator.parameters:addInteger("Back", "Analyse Period Back", "", 20);
    indicator.parameters:addBoolean("TwoBars", "Use TwoBars", "", false);
    indicator.parameters:addInteger("Level", "Alert Level", "", 0);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("LowVol_color", "Color of LowVol_color", "Color of LowVol_color", core.rgb(255, 255, 0));
    indicator.parameters:addColor("ClimaxUp_color", "Color of ClimaxUp", "Color of ClimaxUp", core.rgb(255, 0, 0));
    indicator.parameters:addColor("ClimaxDn_color", "Color of ClimaxDn", "Color of ClimaxDn", core.rgb(255, 255, 255));
    indicator.parameters:addColor("DensityUp_color", "Color of Churn", "Color of DensityUp", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DensityDn_color", "Color of ClimaxChurn", "Color of DensityDn", core.rgb(255, 0, 128));
    indicator.parameters:addColor("VolumeBar_color", "Color of VolumeBar", "Color of VolumeBar", core.rgb(128, 128, 128));
    indicator.parameters:addColor("SMAline_color", "Color of SMAline", "Color of SMAline", core.rgb(255, 0, 0));
	
	
	 indicator.parameters:addGroup("Alert Parameters");  
	indicator.parameters:addString("Live", "Execution", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
	indicator.parameters:addStringAlternative("Live", "Live", "", "Live");  

 
	 
	indicator.parameters:addInteger("ToTime", "Convert the date to", "", 6);
    indicator.parameters:addIntegerAlternative("ToTime", "EST", "", 1);
    indicator.parameters:addIntegerAlternative("ToTime", "UTC", "", 2);
    indicator.parameters:addIntegerAlternative("ToTime", "Local", "", 3);
    indicator.parameters:addIntegerAlternative("ToTime", "Server", "", 4);
    indicator.parameters:addIntegerAlternative("ToTime", "Financial", "", 5);
	indicator.parameters:addIntegerAlternative("ToTime", "Display", "", 6);	

	indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true);
	indicator.parameters:addBoolean("OnlyOnce", "Alert Once", "Subsequent Alert will be ignored.", false);	
	indicator.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
	
	indicator.parameters:addGroup("Alert Style");
    indicator.parameters:addColor("UpTrendColor", "Up Trend Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addColor("DownTrendColor", "Down Trend Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("Size", "Label Size", "", 10, 1 , 100);
	
	indicator.parameters:addGroup("Alerts Sound");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", false);	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);

	
	indicator.parameters:addGroup("Alerts Email");   
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", false);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);

	
	Parameters (1, "Level");	
	Parameters (2, "Volume/MA");	
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
local ShowAlert;
local Alert={}; 
local AlertLevel={};
local ToTime;
local Shift=0; 
local Level;

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local N;
local Back;

local first;
local source = nil;

-- Streams block
local ClimaxUp = nil;
local ClimaxDn = nil;
local DensityUp = nil;
local DensityDn = nil;
local VolumeBar = nil;
local SMAline = nil;

-- Routine
function Prepare(nameOnly)
    N = instance.parameters.N;
    Back = instance.parameters.Back;
	Level = instance.parameters.Level;
    source = instance.source;
    first = source:first() + N + Back -1;
	
	
	ToTime=instance.parameters.ToTime;
	
	if ToTime == 1 then
	ToTime=core.TZ_EST;
	elseif ToTime == 2 then
	ToTime=core.TZ_UTC;
	elseif ToTime == 3 then
	ToTime=core.TZ_LOCAL;
	elseif ToTime == 4 then
	ToTime=core.TZ_SERVER;
	elseif ToTime == 5 then
	ToTime=core.TZ_FINANCIAL;
	elseif ToTime == 6 then
	ToTime=core.TZ_TS;
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
	
	

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(N) .. ", " .. tostring(Back) .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end

   
        Value1 = instance:addInternalStream(0,0);
        Value2 = instance:addInternalStream(0,0);
        Value3 = instance:addInternalStream(0,0);
        Value4 = instance:addInternalStream(0,0);
        Value5 = instance:addInternalStream(0,0);
        Value6 = instance:addInternalStream(0,0);
        Value7 = instance:addInternalStream(0,0);
        Value8 = instance:addInternalStream(0,0);
        Value9 = instance:addInternalStream(0,0);
        Value10 = instance:addInternalStream(0,0);
        Value11 = instance:addInternalStream(0,0);
        Value12 = instance:addInternalStream(0,0);
        Value13 = instance:addInternalStream(0,0);
        Value14 = instance:addInternalStream(0,0);
        Value15 = instance:addInternalStream(0,0);
        Value16 = instance:addInternalStream(0,0);
        Value17 = instance:addInternalStream(0,0);
        Value18 = instance:addInternalStream(0,0);
        Value19 = instance:addInternalStream(0,0);
        Value20 = instance:addInternalStream(0,0);
        Value21 = instance:addInternalStream(0,0);
        Value22 = instance:addInternalStream(0,0);
        VolumeBar = instance:addStream("VolumeBar", core.Bar, name .. ".VolumeBar", "VolumeBar", instance.parameters.VolumeBar_color, first);
    VolumeBar:setPrecision(math.max(2, instance.source:getPrecision()));
        SMAline = instance:addStream("SMAline", core.Line, name .. ".SMAline", "SMAline", instance.parameters.SMAline_color, first);
    SMAline:setPrecision(math.max(2, instance.source:getPrecision()));
    
	
	     for i= 1, Number , 1 do
		Alert[i]=instance:addInternalStream(0, 0);
		AlertLevel[i]=instance:addInternalStream(0, 0);
     end
	
	Initialization();	
	instance:ownerDrawn(true);	 
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
	
    assert(not (SendEmail and (Email == "" or Email == nil )), "E-mail address must be specified");
	
	
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
	  	 assert( not(PlaySound  and (Up[i] == "" or Up[i] == nil ) ), "Sound file must be chosen");
        assert (not (PlaySoundand  and (Down[i] == "" or Down[i] == nil)), "Sound file must be chosen");
	end
	 
    RecurrentSound = instance.parameters.RecurrentSound;
	
	for i = 1, Number , 1 do 
	U[i] = nil;
	D[i] = nil;	 
	end
		 
end	

local init = false;
 
function Draw(stage, context)
 
	 if stage~= 2 then
	  return;
	  end
	  
	  
	
        if not init then
           context:createFont (1, "Wingdings", context:pointsToPixels (Size), context:pointsToPixels (Size), 0);
            init = true;
        end
		
		

		
		for period= math.max(context:firstBar (),source:first()), math.min( context:lastBar (), source:size()-1), 1 do
		
		 
		
		 x, x1, x2= context:positionOfBar (period);
		 
		 for Level = 1 , Number ,  1 do
		   if Alert[Level]:hasData(period) then
		     
		    if Alert[Level][period]== 1 then
			visible, y = context:pointOfPrice (AlertLevel[Level][period]);
			
			  width, height = context:measureText (1,  "\225", 0);
              context:drawText (1,   "\225", UpTrendColor, -1,  x-width/2 ,  y-height , x+width/2 , y, 0 );	
   
			elseif Alert[Level][period]== -1 then
			visible, y = context:pointOfPrice (AlertLevel[Level][period]);
			width, height = context:measureText (1,  "\226", 0);
			 context:drawText (1,   "\226", DownTrendColor, -1,  x-width/2  ,  y , x+width/2 ,y+height, 0 );	
		    end
		  end
		    
		 
		end
		end
		
  
end		

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    local p = period;
        local HIGH = source.high[period];
        local LOW = source.low[period];
        local OPEN = source.open[period];
        local CLOSE = source.close[period];
        local VOLUME = source.volume[period];
        VolumeBar[period] = VOLUME;
        SMAline[period] = 0;
    if period < first then
        Value1[p] = 0;
        Value2[p] = 0;
        Value3[p] = 0;
        Value4[p] = 0;
        Value5[p] = 0;
        Value6[p] = 0;
        Value7[p] = 0;
        Value8[p] = 0;
        Value9[p] = 0;
        Value10[p] = 0;
        Value11[p] = 0;
        Value12[p] = 0;
        Value13[p] = 0;
        Value14[p] = 0;
        Value15[p] = 0;
        Value16[p] = 0;
        Value17[p] = 0;
        Value18[p] = 0;
        Value19[p] = 0;
        Value20[p] = 0;
        Value21[p] = 0;
        Value22[p] = 0;
    end
    if period >= first and source:hasData(period) then
        SMAline[period] = mathex.avg(source.volume,period-N+1,period);
        --if instance.parameters.BidAsk  == 0 then
        --    Range = HIGH-CLOSE;
        --elseif instance.parameters.BidAsk  == 1 then
        --    Range = CLOSE-LOW;
        --else
            Range = HIGH-LOW;
        --end

        if  CLOSE > OPEN then
            Value1[p] = VOLUME*(Range/(2*Range + OPEN - CLOSE));
        elseif CLOSE < OPEN then
            Value1[p] = VOLUME*((Range + CLOSE-OPEN)/(2*Range + CLOSE-OPEN));
        end
        if CLOSE == OPEN then
            Value1[p] = 0.5*VOLUME;
        end
        Value2[p] =     VOLUME - Value1[p];
        Value3[p] =     Value1[p] + Value2[p];
        Value4[p] =     Value1[p] * Range;
        Value5[p] = (   Value1[p]-Value2[p])*Range
        Value6[p] =     Value2[p]*Range;
        Value7[p] = (   Value2[p]-Value1[p])*Range;
        if Range ~= 0 then
            Value8[p]  =    Value1[p]/Range;
            Value9[p]  = (  Value1[p]-Value2[p])/Range;
            Value10[p] =    Value2[p]/Range;
            Value11[p] = (  Value2[p]-Value1[p])/Range;
            Value12[p] =    Value3[p]/Range;
        end

        Value13[p] = Value3[p] + Value3[p-1];
        Value14[p] = (Value1[p]+Value1[p-1])*(mathex.max(source.high,p-2+1,p) - mathex.min(source.low,p-2+1,p));
        Value15[p] = (Value1[p]+Value1[p-1] - Value2[p] - Value2[p-1]) * (mathex.max(source.high,p-2+1,p) - mathex.min(source.low,p-2+1,p));
        Value16[p] = (Value2[p]+Value2[p-1])*(mathex.max(source.high,p-2+1,p) - mathex.min(source.low,p-2+1,p));
        Value17[p] = (Value2[p]+Value2[p-1] - Value1[p] - Value1[p-1]) * (mathex.max(source.high,p-2+1,p) - mathex.min(source.low,p-2+1,p));
        if mathex.max(source.high,p-2+1,p) ~= mathex.min(source.low,p-2+1,p) then
            Value18[p] = (Value1[p] + Value1[p-1])/(mathex.max(source.high,p-2+1,p) - mathex.min(source.low,p-2+1,p));
        end
        Value19[p] = (Value1[p]+Value1[p-1] - Value2[p] - Value2[p-1]) / (mathex.max(source.high,p-2+1,p) - mathex.min(source.low,p-2+1,p));
        Value20[p] = (Value2[p]+Value2[p-1]) / (mathex.max(source.high,p-2+1,p) - mathex.min(source.low,p-2+1,p));
        Value21[p] = (Value2[p]+Value2[p-1] - Value1[p] - Value1[p-1]) / (mathex.max(source.high,p-2+1,p) - mathex.min(source.low,p-2+1,p));
        Value22[p] = Value13[p]/(mathex.max(source.high,p-2+1,p) - mathex.min(source.low,p-2+1,p));

        if not instance.parameters.TwoBars then
            --Con 1 or Con 11
            if (Value3[p] == mathex.min(Value3,p-Back+1,p)) then  -- Yellow -- TwoBars or (Vlaue13[p] == mathex.min(Value13,p-Back+1,p)) then
                VolumeBar:setColor(period,instance.parameters.LowVol_color);
            end
            --Con 2 or Con 3 or Con 8 or Con 9 or Con 12 or Con 13 or Con 18 or con 19
            if (Value4[p] == mathex.max(Value4,p-Back+1,p) and CLOSE > OPEN) or
               (Value5[p] == mathex.max(Value5,p-Back+1,p) and CLOSE > OPEN) or
               (Value10[p] == mathex.min(Value10,p-Back+1,p) and CLOSE > OPEN) or 
               (Value11[p] == mathex.min(Value11,p-Back+1,p) and CLOSE > OPEN) then  --RED -- TwoBars or (Vlaue13[p] == mathex.min(Value13,p-Back+1,p)) then
                VolumeBar:setColor(period,instance.parameters.ClimaxUp_color);
            end
            --Con 4 or Con 5 or Con 6 or Con 7 or Con 14 or Con 15 or Con 16 or con 17
            if (Value6[p] == mathex.max(Value6,p-Back+1,p) and CLOSE < OPEN) or
               (Value7[p] == mathex.max(Value7,p-Back+1,p) and CLOSE < OPEN) or
               (Value8[p] == mathex.min(Value8,p-Back+1,p) and CLOSE < OPEN) or 
               (Value9[p] == mathex.min(Value9,p-Back+1,p) and CLOSE < OPEN) then -- White
                VolumeBar:setColor(period,instance.parameters.ClimaxDn_color);
            end
            -- Churn Con 10
            if Value12[p] == mathex.max(Value12,p-Back+1,p) then -- Green
                VolumeBar:setColor(period,instance.parameters.DensityUp_color);
            end
            --ClimaxChurn
            if (Value12[p] == mathex.max(Value12,p-Back+1,p) ) and 
               (    (Value4[p] == mathex.max(Value4,p-Back+1,p) and CLOSE > OPEN) or
                    (Value5[p] == mathex.max(Value5,p-Back+1,p) and CLOSE > OPEN) or
                    (Value10[p] == mathex.min(Value10,p-Back+1,p) and CLOSE > OPEN) or 
                    (Value11[p] == mathex.min(Value11,p-Back+1,p) and CLOSE > OPEN) or
                    (Value6[p] == mathex.max(Value6,p-Back+1,p) and CLOSE < OPEN) or
                    (Value7[p] == mathex.max(Value7,p-Back+1,p) and CLOSE < OPEN) or
                    (Value8[p] == mathex.min(Value8,p-Back+1,p) and CLOSE < OPEN) or 
                    (Value9[p] == mathex.min(Value9,p-Back+1,p) and CLOSE < OPEN) ) then
                VolumeBar:setColor(period,instance.parameters.DensityDn_color);
            end
        else
            --Con 1 or Con 11
            if (Value13[p] == mathex.min(Value13,p-Back+1,p)) then  -- Yellow -- TwoBars or (Vlaue13[p] == mathex.min(Value13,p-Back+1,p)) then
                VolumeBar:setColor(period,instance.parameters.LowVol_color);
            end
            --Con 2 or Con 3 or Con 8 or Con 9 or Con 12 or Con 13 or Con 18 or con 19
            if ((Value14[p] == mathex.max(Value14,p-Back+1,p)) and (CLOSE > OPEN) and (source.close[p-1] > source.open[p-1])) or
               ((Value15[p] == mathex.max(Value15,p-Back+1,p)) and (CLOSE > OPEN) and (source.close[p-1] > source.open[p-1])) or
               ((Value20[p] == mathex.min(Value20,p-Back+1,p)) and (CLOSE > OPEN) and (source.close[p-1] > source.open[p-1])) or 
               ((Value21[p] == mathex.min(Value21,p-Back+1,p)) and (CLOSE > OPEN) and (source.close[p-1] > source.open[p-1])) then  --RED -- TwoBars or (Vlaue13[p] == mathex.min(Value13,p-Back+1,p)) then
                VolumeBar:setColor(period,instance.parameters.ClimaxUp_color);
            end
            --Con 4 or Con 5 or Con 6 or Con 7 or Con 14 or Con 15 or Con 16 or con 17
            if ((Value16[p] == mathex.max(Value16,p-Back+1,p)) and (CLOSE < OPEN) and (source.close[p-1] < source.open[p-1])) or
               ((Value17[p] == mathex.max(Value17,p-Back+1,p)) and (CLOSE < OPEN) and (source.close[p-1] < source.open[p-1])) or
               ((Value18[p] == mathex.min(Value18,p-Back+1,p)) and (CLOSE < OPEN) and (source.close[p-1] < source.open[p-1])) or 
               ((Value19[p] == mathex.min(Value19,p-Back+1,p)) and (CLOSE < OPEN) and (source.close[p-1] < source.open[p-1])) then -- White
                VolumeBar:setColor(period,instance.parameters.ClimaxDn_color);
            end
            -- Churn Con 10
            if Value22[p] == mathex.max(Value22,p-Back+1,p) then -- Green
                VolumeBar:setColor(period,instance.parameters.DensityUp_color);
            end
            --ClimaxChurn
            if (Value22[p] == mathex.max(Value22,p-Back+1,p) ) and 
               (    ((Value14[p] == mathex.max(Value14,p-Back+1,p)) and (CLOSE > OPEN) and (source.close[p-1] > source.open[p-1])) or
                    ((Value15[p] == mathex.max(Value15,p-Back+1,p)) and (CLOSE > OPEN) and (source.close[p-1] > source.open[p-1])) or
                    ((Value20[p] == mathex.min(Value20,p-Back+1,p)) and (CLOSE > OPEN) and (source.close[p-1] > source.open[p-1])) or 
                    ((Value21[p] == mathex.min(Value21,p-Back+1,p)) and (CLOSE > OPEN) and (source.close[p-1] > source.open[p-1])) or
                    ((Value16[p] == mathex.max(Value16,p-Back+1,p)) and (CLOSE < OPEN) and (source.close[p-1] < source.open[p-1])) or
                    ((Value17[p] == mathex.max(Value17,p-Back+1,p)) and (CLOSE < OPEN) and (source.close[p-1] < source.open[p-1])) or
                    ((Value18[p] == mathex.min(Value18,p-Back+1,p)) and (CLOSE < OPEN) and (source.close[p-1] < source.open[p-1])) or 
                    ((Value19[p] == mathex.min(Value19,p-Back+1,p)) and (CLOSE < OPEN) and (source.close[p-1] < source.open[p-1])) ) then
                VolumeBar:setColor(period,instance.parameters.DensityDn_color);
            end
        end
    end
	
	
	  if Live~= "Live" then
	period=period-1;
	Shift=1;
	else
	Shift=0;
	end
	
	
     if period < first then
	 return;
	 end
	
    Activate (1, period);
	Activate (2, period);
	
	
end




function Activate (id, period)


   Alert[id][period]=0;
   
   
  
  
	  if id == 1  and ON[id]  and Level~=0  then
	  
	       
			if  VolumeBar[period] > Level 
			then
			           
						    
         
                Alert[id][period]= 1;	
 				AlertLevel[id][period]= Level
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag~= false))
							  then
							  
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Cross Over ");
							  SendAlert( Label[id]," Crossed over "); 
							  Pop(Label[id], " Cross Over ", period );  
							  OnlyOnceFlag=false;
							  end
							  
			 
	         end
			
	  
	 
	  end
	  
	  
	  	  if id == 2  and ON[id]    then
	  
	       
			if  VolumeBar[period] > SMAline[period] 
			and   VolumeBar[period-1] <= SMAline[period-1] 
			then          
						    
         
                Alert[id][period]= 1;	
 				AlertLevel[id][period]= SMAline[period] 
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag~= false))
							  then
							  
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Cross Over ");
							  SendAlert( Label[id]," Crossed over "); 
							  Pop(Label[id], " Cross Over ", period );  
							  OnlyOnceFlag=false;
							  end
							  
			elseif  VolumeBar[period] < SMAline[period] 
			and   VolumeBar[period-1] >= SMAline[period-1] 
            then			
			
			            			 
			                Alert[id][period]= -1;	
							AlertLevel[id][period]= SMAline[period] 
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag~= false))
							 then							
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " Cross Under ");								 
							 Pop(Label[id], " Cross Under ", period );  	
							 SendAlert( Label[id]," Crossed under ");
							 OnlyOnceFlag=false;
			                 end			   
	         end
			
	  
	 
	  end
	  
		   
        if FIRST then
        FIRST=false;      
        end		

end


function AsyncOperationFinished (cookie, success, message)
end

 

function SoundAlert(Sound)
 if not PlaySound then
 return;
 end

  terminal:alertSound(Sound, RecurrentSound);
end

 


function EmailAlert( label , Subject)

if not SendEmail then
return
end
 
   local now = core.host:execute("getServerTime");
	now = core.host:execute("convertTime", core.TZ_EST, ToTime, now);
	local DATA = core.dateToTable (now);
    
   local delim = "\013\010";  
   local Note=  profile:id().. delim.. " Label : " ..label  .. delim .. " Alert : " .. Subject ;   
   local Symbol= "Instrument : " .. source:instrument() ;
   local Time =  " Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec;  
   
   
    local TF= "Time Frame : " .. source:barSize();       
    local text = Note  .. delim ..  Symbol .. delim .. TF  .. delim .. Time;
	
	
 
   terminal:alertEmail(Email, profile:id(), text);
end
	 
	 
	 
	 

function Pop(label , Subject )
  
   if not Show then
   return;
   end
   
   local now = core.host:execute("getServerTime");
	now = core.host:execute("convertTime", core.TZ_EST, ToTime, now);
	local DATA = core.dateToTable (now);
	
	
    
   local delim = "\013\010";  
   local Note=  profile:id().. delim.. " Label : " ..label  .. delim .. " Alert : " .. Subject ;   
   local Symbol= "Instrument : " .. source:instrument() ;
   local Time =  " Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec;  
   
   
    local TF= "Time Frame : " .. source:barSize();       
    local text = Note  .. delim ..  Symbol .. delim .. TF  .. delim .. Time;
	
   
   core.host:execute ("prompt", 1, label , text );


end


function SendAlert(label ,Subject, period)
    if not ShowAlert then
        return;
    end
	
	local now = core.host:execute("getServerTime");
	now = core.host:execute("convertTime", core.TZ_EST, ToTime, now);
	local DATA = core.dateToTable (now);
	
    
   local delim = "\013\010";  
   local Note=  profile:id().. delim.. " Label : " ..label  .. delim .. " Alert : " .. Subject ;   
   local Symbol= "Instrument : " .. source:instrument() ;
   local Time =  " Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec;  
   
 
    local TF= "Time Frame : " .. source:barSize();       
    local text = Note  .. delim ..  Symbol .. delim .. TF  .. delim .. Time;
	
 
    terminal:alertMessage(source:instrument(), source[NOW], text, now);
end

 
 
 



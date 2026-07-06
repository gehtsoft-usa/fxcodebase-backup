-- Id: 15724
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63215&p=105115#p105115

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
    indicator:name(" 3in1 Stochastic ");
    indicator:description("");
   indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    
	
	AddTimeFrame(1, "H1");
	AddTimeFrame(2, "H4");
	AddTimeFrame(3, "H8");
 
 
 
    indicator.parameters:addGroup("Alert Parameters");  
	indicator.parameters:addString("Live", "End of Turn / Live", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
	indicator.parameters:addStringAlternative("Live", "Live", "", "Live");   
    indicator.parameters:addBoolean("ChangeOnly", "Change Only", "", true);
	indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true);
	indicator.parameters:addBoolean("OnlyOnce", "Alert Once", "Subsequent Alert will be ignored.", false);	
	indicator.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
	
	indicator.parameters:addGroup("Alert Style");
    indicator.parameters:addColor("UpTrendColor", "Up Trend Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("DownTrendColor", "Down Trend Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("NeutralTrendColor", "Netural Trend Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("Size", "Label Size", "", 15, 1 , 100);
	
	indicator.parameters:addGroup("Alerts Sound");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", true);	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);

	
	indicator.parameters:addGroup("Alerts Email");   
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", true);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);

	
	Parameters (1, " Alert ");	
	
	indicator.parameters:addGroup("1. Stochastic Style");
	indicator.parameters:addColor("ColorUp1", "K Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("ColorDown1", "S Line Color", "", core.rgb(255, 0, 0));
 
	
	indicator.parameters:addGroup("2. Stochastic Style");
	indicator.parameters:addColor("ColorUp2", "Channel color Up", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("ColorDown2", "Channel color Down", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("Transparency2", "Channel transparency (%)", "", 70, 0, 100);
	
	indicator.parameters:addGroup("3. Stochastic Style");
	indicator.parameters:addColor("ColorUp3", "Channel color Up", "", core.rgb(0, 0, 255));
	indicator.parameters:addColor("ColorDown3", "Channel color Down", "", core.rgb(255, 128, 192));
    indicator.parameters:addInteger("Transparency3", "Channel transparency (%)", "", 70, 0, 100);

	indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 7);
    indicator.parameters:addDouble("oversold","Oversold Level","", -7);
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
end

function AddTimeFrame(id, TF)

  indicator.parameters:addGroup(id.. ". Time Frame Calculation");	


    indicator.parameters:addString("TF" ..id, "Time Frame", "", TF);  
	indicator.parameters:setFlag ("TF" ..id, core.FLAG_BARPERIODS);
	indicator.parameters:addInteger("K" ..id, "Number of periods for %K", "The number of periods for %K.", 5, 2, 1000);
    indicator.parameters:addInteger("SD"..id, "%D slowing periods", "The number of periods for slow %D.", 3, 2, 1000);
    indicator.parameters:addInteger("D"..id, "Number of periods for %D", "The number of periods for %D.", 3, 2, 1000);

    indicator.parameters:addString("MVAT_K"..id, "Smoothing type for %K", "The type of smoothing algorithm for %K.", "MVA");
    indicator.parameters:addStringAlternative("MVAT_K"..id, "MVA", "MVA", "MVA");
    indicator.parameters:addStringAlternative("MVAT_K"..id, "EMA", "EMA", "EMA");
    indicator.parameters:addStringAlternative("MVAT_K"..id, "MetaTrader", "The MetaTrader algorithm.", "MT");
	indicator.parameters:addStringAlternative("MVAT_K" ..id, "LWMA", "", "LWMA");	
	indicator.parameters:addStringAlternative("MVAT_K"..id , "KAMA", "", "KAMA");	
	indicator.parameters:addStringAlternative("MVAT_K"..id , "SMMA", "", "SMMA");	
	indicator.parameters:addStringAlternative("MVAT_K"..id , "TMA", "", "TMA");	
	indicator.parameters:addStringAlternative("MVAT_K"..id , "VIDYA", "", "VIDYA");	
	indicator.parameters:addStringAlternative("MVAT_K"..id , "WMA", "", "WMA");	
    
    indicator.parameters:addString("MVAT_D"..id, "Smoothing type for %D", "The type of smoothing algorithm for %D.", "MVA");
    indicator.parameters:addStringAlternative("MVAT_D"..id, "MVA", "MVA", "MVA");
    indicator.parameters:addStringAlternative("MVAT_D"..id, "EMA", "EMA", "EMA");
	indicator.parameters:addStringAlternative("MVAT_D"..id , "LWMA", "", "LWMA");	
	indicator.parameters:addStringAlternative("MVAT_D"..id , "KAMA", "", "KAMA");	
	indicator.parameters:addStringAlternative("MVAT_D"..id , "SMMA", "", "SMMA");	
	indicator.parameters:addStringAlternative("MVAT_D"..id , "TMA", "", "TMA");	
	indicator.parameters:addStringAlternative("MVAT_D"..id , "VIDYA", "", "VIDYA");	
	indicator.parameters:addStringAlternative("MVAT_D"..id , "WMA", "", "WMA");
	
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
local iU={};
local iD={};
local UpTrendColor, DownTrendColor,NeutralTrendColor;
local OnlyOnceFlag;
--local font;
local ShowAlert;
local first;
local source = nil;
local Shift=0; 
local Trend;
local TF={};
local iK={};
local iSD={};
local iD={};
local iMVAT_K={};
local iMVAT_D={};
local Indicator={};
local Source={};
local loading={};
local Count=3;
local Arial;
local iCount;
local dayoffset, weekoffset;
local K={};
local D={};
local ChangeOnly;
local Color1Up, Color1Down, Color2Up, Color2Down, Color3Up, Color3Down;
-- Routine
function Prepare(nameOnly)   
    Color1Up = instance.parameters.ColorUp1;
	Color1Down = instance.parameters.ColorDown1;
	Color2Up = instance.parameters.ColorUp2;
	Color2Down = instance.parameters.ColorDown2;
	Color3Up = instance.parameters.ColorUp3;
	Color3Down= instance.parameters.ColorDown3;
	OnlyOnceFlag=true;
	FIRST=true;
	ChangeOnly= instance.parameters.ChangeOnly;
	
	OnlyOnce = instance.parameters.OnlyOnce;
	ShowAlert = instance.parameters.ShowAlert;
	Show = instance.parameters.Show;
	Live = instance.parameters.Live;
	UpTrendColor = instance.parameters.UpTrendColor;
	DownTrendColor = instance.parameters.DownTrendColor;
	NeutralTrendColor = instance.parameters.NeutralTrendColor;
	Size=instance.parameters.Size;	
	source = instance.source; 
	  -- Base name of the indicator.
    local name = profile:id() .. "(" .. source:name()   .. ")";
	instance:name(name);
	if (nameOnly) then
        return;
    end
	font = core.host:execute("createFont", "Wingdings", Size, false, false);
	--Arial= core.host:execute("createFont", "Arial", Size, false, false);
	dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");
	iCount = instance:addInternalStream(0, 0);

	
	
	local s, e, S,E;
    s, e = core.getcandle(source:barSize(), core.now(), 0, 0); 
	for i= 1, Count, 1 do
    TF[ i]=instance.parameters:getString("TF" .. i);	
	S, E = core.getcandle(TF[i], core.now(), 0, 0);
    assert ((e - s) <= (E - S), "The chosen time frame must be equal to or bigger than the chart time frame!");
	
	iMVAT_K[i]=instance.parameters:getString("MVAT_K" .. i);
    iMVAT_D[i]=instance.parameters:getString("MVAT_D" .. i);
	iK[i]=instance.parameters:getInteger("K" .. i);
    iSD[i]=instance.parameters:getInteger("SD" .. i);
	iD[i]=instance.parameters:getInteger("D" .. i);
	
	Trend = instance:addInternalStream(0, 0);
	
	Source[i]= core.host:execute("getSyncHistory", source:instrument(), TF[i], source:isBid(), (iK[i]+iSD[i]+iD[i]) ,20000 + i , 10000 +i);	
	loading[i] = true;  
	Indicator[i]= core.indicators:create("STOCHASTIC", Source[i], iK[i],iSD[i],iD[i],iMVAT_K[i],iMVAT_D[i]  );
	
		
		K[i] =  instance:addStream("K"..i, core.Line, name, i..". K", instance.parameters:getColor("ColorUp" .. i),  Indicator[i].K:first());
    K[i]:setPrecision(math.max(2, instance.source:getPrecision()));
		if i== 1 then
		K[i]:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
		K[i]:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);  
		end
		
		D[i] =  instance:addStream("K"..i, core.Line, name, i.. ". D", instance.parameters:getColor("ColorDown" .. i), Indicator[i].D:first());
    D[i]:setPrecision(math.max(2, instance.source:getPrecision()));
		if i~= 1 then
		instance:createChannelGroup(i.. ".ch", i.. ".ch", K[i] , D[i], instance.parameters:getColor("ColorUp" .. i), 100 - instance.parameters:getInteger("Transparency" .. i));
		end
	end

  
	 
	   
	Initialization();
end



-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)


 local i ;
 
 
		 for i = 1, Count, 1 do	
			  if cookie == ( 10000 +  i) then
			  loading[i] = true;
		      elseif  cookie == (20000+ i) then
			  loading[i] = false;    
			  end
		       
          end

	
	
    local FLAG=false; 
	local Number=0;
	
	for i = 1, Count, 1 do
		 

                 if loading [i] then
				 FLAG= true;
				 Number=Number+1;
				 end 
         
    end
	
	if FLAG then
	 core.host:execute ("setStatus", "  Loading "..(Count - Number) .. " / " ..  Count );	 
	else
	core.host:execute ("setStatus", "Loaded");
	 instance:updateFrom(0);		
	end
   
        
    return core.ASYNC_REDRAW ;
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
	iU[i] = nil;
	iD[i] = nil;	 
	end
		 
end	


 

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode) 



	core.host:execute ("removeLabel", source:serial(period)); 
    
		
    Activate (1, period,mode)
 
end

function ReleaseInstance()
       core.host:execute("deleteFont", font);
	  -- core.host:execute("deleteFont", Arial);
end	   

function   FindPeriod(id, period)

    local Candle;
    Candle = core.getcandle(TF[id], source:date(period), dayoffset, weekoffset);

  
    if loading[id] or Source[id]:size() == 0 then
        return false ;
    end

    
    if period < source:first() then
        return false;
    end

    local p = core.findDate(Source[id], Candle, false);

    -- candle is not found
    if p < 0 then
        return false;
	else return p;	
    end
	
end	

function Activate (id, period,mode )

    if Live~= "Live" then
	period=period-1;
	Shift=1;
	else
	Shift=0;
	end
	
 
	local  p={};
	 p[1]=FindPeriod(1, period);
	 p[2]=FindPeriod(2, period);
	 p[3]=FindPeriod(3, period);
	  
	if not loading[1]  then
	

         
             Indicator[1]:update(mode  );	 		 
			 K[1][period]=  Indicator[1].K[p[1]];
			 D[1][period]=  Indicator[1].D[p[1]];
			 
			  if  K[1][period] >  D[1][period]   then
			 K[1]:setColor(period, Color1Up);
			 else
			 K[1]:setColor(period, Color1Down);
			 end
		 
	 
	end
	
	
	if not loading[2] then
 
	
 
	        Indicator[2]:update(mode );  
			  K[2][period]=  Indicator[2].K[p[2]];
			 D[2][period]=  Indicator[2].D[p[2]];
			 
				   if  K[2][period] >  D[2][period] then
				 K[2]:setColor(period, Color2Up);
				 else
				 K[2]:setColor(period, Color2Down);
				 end
	 
	end
	
	
	if not loading[3]    then
	 
	          Indicator[3]:update(mode ) ;
			  K[3][period]=  Indicator[3].K[p[3]];
			 D[3][period]=  Indicator[3].D[p[3]];
			 
				 
				  if  K[3][period] >  D[3][period] then
				 K[3]:setColor(period, Color3Up);
				 else
				 K[3]:setColor(period, Color3Down);
				 end
	 
	end
	
      
	 if not p[1] or not p[2] or not p[3] 
	 or not  Indicator[3].D:hasData(p[3]) or not  Indicator[2].D:hasData(p[2]) or not  Indicator[1].D:hasData(p[1])
	 then
	 return;	 
	 end
	 
	  
	 
	   -- local Trend=0;
		
		if K[1][period]>  D[1][period]
	--	and  K[1][period-1]<=  D[1][period-1]
		and K[2][period]> D[2][period]
		and  K[3][period]> D[3][period]
		then
		Trend[period]=1;
		elseif  K[1][period]<  D[1][period]
	--	and  K[1][period-1]>=  D[1][period-1]
		and K[2][period]< D[2][period]
		and   K[3][period]< D[3][period]
		then
		Trend[period]=-1;
		else
		Trend[period]=Trend[period-1];
		end
	
	 
 
	  
	 
 
	  if id == 1  and ON[id]  then
	  
	       
			if Trend[period]==1
            and (ChangeOnly and Trend[period-1]~=1 or not  ChangeOnly)			
			then
			           					 
						   
			
			 iD[id] = nil;
						   
							  if iU[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  then
							  OnlyOnceFlag=false;
							  iU[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], "  Up Trend ", period);
							  SendAlert(" Up Trend "); 
							  Pop(Label[id], " Up Trend " );  
							  end
							  
							     core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, D[1][period], core.CR_CHART, core.H_Center, core.V_Bottom, font, UpTrendColor, "\236");	
			elseif Trend[period]==-1
            and (ChangeOnly and Trend[period-1]~=-1 or not  ChangeOnly)		
            then			
			
			            			 
			         	   
						   
		     iU[id] = nil;
		   
			                 if  iD[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 then
							 OnlyOnceFlag=false;
							 iD[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " Down Trend ", period);
							 Pop(Label[id], " Down Trend " ); 
							 SendAlert(" Down Trend ");
							 
			                  end	
                             core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, D[1][period], core.CR_CHART, core.H_Center, core.V_Bottom, font, DownTrendColor, "\238");							  
	         end
			
	  
	 
	  end 
	  
		   
        if FIRST then
        FIRST=false;      
        end		

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
	 


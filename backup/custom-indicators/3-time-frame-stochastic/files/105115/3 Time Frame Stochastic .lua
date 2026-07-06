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
    indicator:name(" 3 Time Frame Stochastic ");
    indicator:description("");
   indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    
	
	AddTimeFrame(1, "m1");
	AddTimeFrame(2, "m5");
	AddTimeFrame(3, "m15");
 
    indicator.parameters:addGroup("Alert Parameters");  
	indicator.parameters:addString("Live", "End of Turn / Live", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
	indicator.parameters:addStringAlternative("Live", "Live", "", "Live");   

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

	
	Parameters (1, "Alert");	
	
end

function AddTimeFrame(id, TF)

  indicator.parameters:addGroup(id.. ". Time Frame Calculation");	


    indicator.parameters:addString("TF" ..id, "Time Frame", "", TF);  
	
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
local U={};
local D={};
local UpTrendColor, DownTrendColor,NeutralTrendColor;
local OnlyOnceFlag;
--local font;
local ShowAlert;
local first;
local source = nil;
local Shift=0; 

local TF={};
local K={};
local SD={};
local D={};
local MVAT_K={};
local MVAT_D={};
local Indicator={};
local Source={};
local loading={};
local Count=3;
local Arial;
local iCount;
local dayoffset, weekoffset;
-- Routine
function Prepare(nameOnly)
    
	OnlyOnceFlag=true;
	FIRST=true;
	OnlyOnce = instance.parameters.OnlyOnce;
	ShowAlert = instance.parameters.ShowAlert;
	Show = instance.parameters.Show;
	Live = instance.parameters.Live;
	UpTrendColor = instance.parameters.UpTrendColor;
	DownTrendColor = instance.parameters.DownTrendColor;
	NeutralTrendColor = instance.parameters.NeutralTrendColor;
	Size=instance.parameters.Size;
	-- Base name of the indicator.
	source = instance.source; 
    local name = profile:id() .. "(" .. source:name()   .. ")";
    instance:name(name);
	if (nameOnly) then
        return;
    end
	--font = core.host:execute("createFont", "Wingdings", Size, false, false);
	Arial= core.host:execute("createFont", "Arial", Size, false, false);
	dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");
	iCount = instance:addInternalStream(0, 0);
	
	for i= 1, Count, 1 do
    TF[ i]=instance.parameters:getString("TF" .. i);
	MVAT_K[i]=instance.parameters:getString("MVAT_K" .. i);
    MVAT_D[i]=instance.parameters:getString("MVAT_D" .. i);
	K[i]=instance.parameters:getInteger("K" .. i);
    SD[i]=instance.parameters:getInteger("SD" .. i);
	D[i]=instance.parameters:getInteger("D" .. i);
	
	
	Source[i]= core.host:execute("getSyncHistory", source:instrument(), TF[i], source:isBid(), (K[i]+SD[i]+D[i]) ,20000 + i , 10000 +i);	
	loading[i] = true;  
	Indicator[i]= core.indicators:create("STOCHASTIC", Source[i], K[i],SD[i],D[i],MVAT_K[i],MVAT_D[i]  );
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
				 
				  if loading [10+i] then
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
	U[i] = nil;
	D[i] = nil;	 
	end
		 
end	


 

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period) 


    if Live~= "Live" then
	period=period-1;
	Shift=1;
	else
	Shift=0;
	end
	
	core.host:execute ("removeLabel", source:serial(period)); 
    
		
    Activate (1, period)
 
end

function ReleaseInstance()
       --core.host:execute("deleteFont", font);
	   core.host:execute("deleteFont", Arial);
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

function Activate (id, period)
 
	
	if loading[1] or loading[2] or loading[3] then
	return;
	end
	
     Indicator[1]:update(core.UpdateLast);
	 Indicator[2]:update(core.UpdateLast);
	 Indicator[3]:update(core.UpdateLast);
	 
	 p={};
	 p[1]=FindPeriod(1, period);
	 p[2]=FindPeriod(2, period);
	 p[3]=FindPeriod(3, period);
	 
	 if not p[1] or not p[2] or not p[3] then
	 return;
	 end
	 
	 iCount[period]=0;
	
	for i= 1, Count, 1 do
	
		if Indicator[i].K[p[i]] >Indicator[i].D[p[i]] then
		iCount[period]=iCount[period]+1;
		elseif Indicator[i].K[p[i]] <Indicator[i].D[p[i]] then
		iCount[period]=iCount[period]-1;
		end
	
	end
	 
	 
	if iCount[period]> 0 then
	Color=UpTrendColor;
	X=1;
    elseif iCount[period]< 0 then
	Color=DownTrendColor;
	X=-1;
	else
	Color=NeutralTrendColor;
	X=0;
    end
	

	if iCount[period]~= iCount[period-1] then 
		
	    if math.abs(iCount[period])== 0 then
 
		    core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, source.low[period], core.CR_CHART, core.H_Center, core.V_Bottom, Arial, Color, "0");	
		 elseif math.abs(iCount[period])== 1 then
		
			if X== 1 then
			core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, source.low[period], core.CR_CHART, core.H_Center, core.V_Bottom, Arial, Color, "1");
			else
			core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, source.high[period], core.CR_CHART, core.H_Center, core.V_Top, Arial, Color, "1");
			end
			
		elseif math.abs(iCount[period])== 2 then
		    if X== 1 then
			core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, source.low[period], core.CR_CHART, core.H_Center, core.V_Bottom, Arial, Color, "2");
			else
			core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, source.high[period], core.CR_CHART, core.H_Center, core.V_Top, Arial, Color, "2");
			end
		elseif math.abs(iCount[period]) == 3 then
		    if X== 1 then
			core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, source.low[period], core.CR_CHART, core.H_Center, core.V_Bottom, Arial, Color, "3");
			else
			core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, source.high[period], core.CR_CHART, core.H_Center, core.V_Top, Arial, Color, "3");
			end
		end
 	end
	
	
	 
  
 
	  if id == 1  and ON[id]  then
	  
	       
			if  iCount[period]== 3
			and iCount[period]~= 3
			then
			           					 
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  then
							  OnlyOnceFlag=false;
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], "  Up Trend ", period);
							  SendAlert(" Up Trend "); 
							  Pop(Label[id], " Up Trend " );  
							  end
			elseif  iCount[period]== -3
			and iCount[period]~= -3
            then			
			
			            			 
			         	   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 then
							 OnlyOnceFlag=false;
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " Down Trend ", period);
							 Pop(Label[id], " Down Trend " ); 
							 SendAlert(" Down Trend ");
							 
			                  end			   
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
	 


-- Id: 16304

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=34071

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


function Init()
    indicator:name("CCI dots indicator");
    indicator:description("CCI dots indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("CCI_Period", "CCI period", "", 14);
    indicator.parameters:addInteger("Period", "Period", "", 10);
	indicator.parameters:addDouble("OBO", "OB Cross Over Level", "", 100);
	indicator.parameters:addDouble("OBU", "OB Cross Under Level", "", 100);
	indicator.parameters:addDouble("OSO", "OS Cross Over Level", "", -100);
	indicator.parameters:addDouble("OSU", "OS Cross Under Level", "", -100);
	
	indicator.parameters:addGroup("Filter Calculation");
	indicator.parameters:addBoolean("Use_Filter" , "Use Filter" , "", true);
	indicator.parameters:addString("MA_Price", "MA Price Source", "", "close");
    indicator.parameters:addStringAlternative("MA_Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("MA_Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("MA_Price", "LOW", "", "low");
    indicator.parameters:addStringAlternative("MA_Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("MA_Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("MA_Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("MA_Price", "WEIGHTED", "", "weighted");	
	
	indicator.parameters:addInteger("MA_Period", "MA Period", "", 14);
  
	indicator.parameters:addString("MA_Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("MA_Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("MA_Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("MA_Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("MA_Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("MA_Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("MA_Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("MA_Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("MA_Method", "WMA", "WMA" , "WMA");
	
	
	
	
	 indicator.parameters:addGroup("Mode");  
	indicator.parameters:addString("Live", "End of Turn / Live", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
	indicator.parameters:addStringAlternative("Live", "Live", "", "Live");
	
	
	
	indicator.parameters:addGroup("Alert Style");
    indicator.parameters:addColor("UpColor1", "Zero Line Cross Over Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addColor("DownColor1", "Zero Line Cross Under Color", "", core.rgb(0, 0, 255));
	
	  indicator.parameters:addColor("UpColor2", "OB Line Cross Over Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("DownColor2", "OB Line Cross Under Color", "", core.rgb(0, 255, 0));
	
	  indicator.parameters:addColor("UpColor3", "OS Line Cross Over Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("DownColor3", "OS Line Cross Under Color", "", core.rgb(255, 0, 0));
	
	
	indicator.parameters:addInteger("Size", "Label Size", "", 10, 1 , 100);
	
	indicator.parameters:addGroup("Alerts Sound");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", true);	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);
	
	indicator.parameters:addGroup("Alerts Email");   
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", true);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);
	indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true);
	
	
	Parameters (1, "Zero Line");
    Parameters (2, "OB Line");
    Parameters (3, "OS Line"); 
end

local first;
local source = nil;
local CCI_Period;
local Period;
local CCI;
local OBU, OSU;
local OBO, OSO;

function Parameters ( id, Label )
  
  
   indicator.parameters:addGroup(Label .. " Alert");
  
    indicator.parameters:addBoolean("ON"..id , "Show " .. Label .." Alert" , "", true);
    indicator.parameters:addBoolean("Over"..id , "Show " .. Label .." CrossOver Alert" , "", true);
	 indicator.parameters:addBoolean("Under"..id , "Show " .. Label .." CrossUnder Alert" , "", true);
    
    indicator.parameters:addFile("Up"..id, Label .. " Cross Over Sound", "", "");
    indicator.parameters:setFlag("Up"..id, core.FLAG_SOUND);
	
	indicator.parameters:addFile("Down"..id, Label .. " Cross Under Sound", "", "");
    indicator.parameters:setFlag("Down"..id, core.FLAG_SOUND);
	
	 indicator.parameters:addString("Label"..id, "Label", "", Label);

end 

local 	Number = 3;
local Over={};
local Under={};
local Up={};
local Down={};
local Label={};
local ON={};
local Line;
local up={};
local down={};
local Size;
local Email;
local SendEmail;
local  RecurrentSound ,SoundFile  ;
local Show;
local Alert;
local PlaySound;
local Live;
local FIRST=true;
local U={};
local D={};
local UpColor={};
local DownColor={};

local MA_Method, MA_Period, MA_Price,Use_Filter,MA;

function Prepare(nameOnly)
      FIRST=true;
	  Show = instance.parameters.Show;
	Live = instance.parameters.Live;
	
	MA_Method=instance.parameters.MA_Method;
	MA_Period=instance.parameters.MA_Period;
	MA_Price=instance.parameters.MA_Price;
	Use_Filter=instance.parameters.Use_Filter;
	  
     
    source = instance.source;
	OBO=instance.parameters.OBO;
	OSO=instance.parameters.OSO;	
	OBU=instance.parameters.OBU;
	OSU=instance.parameters.OSU;
    CCI_Period=instance.parameters.CCI_Period;
    Period=instance.parameters.Period;
	CCI = core.indicators:create("CCI", source, CCI_Period);	
    assert(core.indicators:findIndicator(MA_Method) ~= nil, MA_Method .. " indicator must be installed");
    MA = core.indicators:create(MA_Method, source[MA_Price], MA_Period);
	first = math.max(CCI.DATA:first(), Period, MA.DATA:first());
    
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.CCI_Period .. ", " .. instance.parameters.Period .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
	
	Initialization();
    
end


function  Initialization ()
     Size=instance.parameters.Size;
	 SendEmail = instance.parameters.SendEmail;
	 
	 local i;
	 for i = 1, Number , 1 do 
	  Label[i]=instance.parameters:getString("Label" .. i);
	  ON[i]=instance.parameters:getBoolean("ON" .. i);
	  Over[i]=instance.parameters:getBoolean("Over" .. i);
	  Under[i]=instance.parameters:getBoolean("Under" .. i);
	  UpColor[i]=instance.parameters:getDouble("UpColor" .. i);
      DownColor[i]=instance.parameters:getDouble("DownColor" .. i);
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
		up[i] = instance:createTextOutput ("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Center, UpColor[i], 0);
		down[i] = instance:createTextOutput ("Dn", "Dn", "Wingdings", Size, core.H_Center, core.V_Center, DownColor[i], 0);
		end
	end
		
	

	
end	





function Update(period, mode)
   if period<first then
   return;
   end

   
    CCI:update(mode);
	
	 if Use_Filter then
	MA:update(mode);
	end	
	
	local i;
	for i = 1, Number , 1 do
		  if ON[i] then
		 down[i]:setNoData (period); 
		 up[i]:setNoData (period);
		 end
   end	 
   
   local Range=(mathex.avg(source.high, period-Period+1, period)-mathex.avg(source.low, period-Period+1, period))/2;
	
    Activate (1, period,Range);
	Activate (2, period,Range);
	Activate (3, period,Range);
	   
end


function Activate (id, period,Range)

   local Shift=0;
   

   if Live~= "Live" then
	period=period-1;
	Shift=1;
	end
 
	  if id == 1  and ON[id]  then
	  
	       
			if CCI.DATA[period-1]<=0 and CCI.DATA[period]>0 	
            and (not Use_Filter or source.close[period]> MA.DATA[period]  )			
			then 
			
			 D[id] = nil;           if Over[id]  then
						          up[id]:set(period ,source.low[period]-Range, "\108");	
						          end		  
							      
								  if U[id]~=source:serial(period) 
								  and period == source:size()-1-Shift
								  and not FIRST 								    
								  then
								  U[id]=source:serial(period);
								  
									  if Over[id]  then
									  SoundAlert(Up[id]);
									  EmailAlert(  Label[id], " Cross Over", period);
									 
											if Show then
											Pop(Label[id], " Cross Over " );  	
											end
										end	
									 
								  end
			elseif CCI.DATA[period-1]>=0 and CCI.DATA[period]<0 	
            and (not Use_Filter or source.close[period]< MA.DATA[period]  )			
            then			
			 
		     U[id] = nil;
			                 if Under[id] then
									  down[id]:set(period , source.high[period]+Range, "\108");	
							end		 
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 then
							     D[id]=source:serial(period);
								 
							       if Under[id] then 
								  SoundAlert(Down[id]);			 
								  EmailAlert( Label[id] , " Cross Under", period);	
									 if Show then
										Pop(Label[id], " Cross Under " );  	
									 end
								 
								  end	 
							 end	  
	         end
			
	  
	 
	  end
	  
	   if id == 2  and ON[id]  then
	  
	       
			if CCI.DATA[period-1]<=OBO and CCI.DATA[period]>OBO			
			then    
			
			 D[id] = nil;        if Over[id]  then
						          up[id]:set(period ,source.low[period]-Range, "\108");	
						          end	
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  then
							        U[id]=source:serial(period);
									
									if Over[id] then 
								     SoundAlert(Up[id]);
								     EmailAlert(  Label[id], " Cross Over", period);
									
										if Show then
										Pop(Label[id], " Cross Over " );  	
										end
									 end
							  end
			elseif CCI.DATA[period-1]>=OBU and CCI.DATA[period]<OBU 			
            then		   			   
						   
		     U[id] = nil;
			                if Under[id] then
									  down[id]:set(period , source.high[period]+Range, "\108");	
							end		 
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 then
									 D[id]=source:serial(period);	
								 
									 if Under[id] then 
									 SoundAlert(Down[id]);			 
									 EmailAlert( Label[id] , " Cross Under", period);	
										 if Show then
											Pop(Label[id], " Cross Under " );  	
										 end
									  end
			                  end			   
	         end
			
	  
	 
	  end
	  
	   if id == 3  and ON[id]  then
	  
	       
			if CCI.DATA[period-1]<=OSO and CCI.DATA[period]>OSO			
			then    
			
			 D[id] = nil;     
			 
			                    if Over[id]  then
						          up[id]:set(period ,source.low[period]-Range, "\108");	
						          end	
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  then
							   U[id]=source:serial(period);
								   if Over[id] then 
								  SoundAlert(Up[id]);
								  EmailAlert(  Label[id], " Cross Over", period);
									
										if Show then
										Pop(Label[id], " Cross Over " );  	
										end
									 
								  end
							  end
			elseif CCI.DATA[period-1]>=OSU and CCI.DATA[period]<OSU			
            then	 							 		   
						   
		     U[id] = nil;
			                if Under[id] then
									  down[id]:set(period , source.high[period]+Range, "\108");	
							end		  
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 then 
							  D[id]=source:serial(period);    
									   if Under[id] then
									  
									 SoundAlert(Down[id]);			 
									 EmailAlert( Label[id] , " Cross Under", period);	
										 if Show then
											Pop(Label[id], " Cross Under " );  	
										 end
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
   " ( " .. source:instrument() .. " : " .. source:barSize() .. " ) "  ..   label .. " : " .. note );


end

function SoundAlert(Sound)
 if not PlaySound then
 return;
 end

 
 terminal:alertSound(Sound, RecurrentSound);
end

 

function EmailAlert( label , Subject, period)

if not SendEmail then
return
end

  
    local date = source:date(period);
	local DATA = core.dateToTable (date);
	
    
   local delim = "\013\010";  
   local Note=  profile:id().. delim.. " Label : " ..label  .. delim .. " Alert : " .. Subject ;   
   local Symbol= "Instrument : " .. source:instrument() ;
   local TF= "Time Frame : " .. source:barSize();    
   local Time =  " Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec; 
   
     local text = Note  .. delim ..  Symbol .. delim .. TF  .. delim .. Time;
	

   terminal:alertEmail(Email, profile:id(), text);
end
	 




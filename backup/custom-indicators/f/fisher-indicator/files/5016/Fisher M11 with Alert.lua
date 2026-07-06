-- Id: 12012
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1729

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
    indicator:name("Fisher_m11 indicator");
    indicator:description("Fisher_m11 indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("RangePeriods", "RangePeriods", "RangePeriods", 35);
    indicator.parameters:addDouble("PriceSmoothing", "PriceSmoothing", "PriceSmoothing", 0.3, 0, 0.9999);
    indicator.parameters:addDouble("IndexSmoothing", "IndexSmoothing", "IndexSmoothing", 0.3, 0, 0.9999);
	
    indicator.parameters:addGroup("Style");		
    indicator.parameters:addColor("clrUP", "UP trend", "UP trend", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clrDN", "DN trend", "DN trend", core.rgb(255, 0, 0));
	
	
	indicator.parameters:addGroup("Mode");  
	indicator.parameters:addString("Live", "End of Turn / Live", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
	indicator.parameters:addStringAlternative("Live", "Live", "", "Live");
	
	
	
	indicator.parameters:addGroup("Alert Style");
    indicator.parameters:addColor("Up", "Up Trend Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addColor("Down", "Down Trend Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("Size", "Label Size", "", 10, 1 , 100);
	
	indicator.parameters:addGroup("Alerts Sound");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", true);	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);
	
	indicator.parameters:addGroup("Alerts Email");   
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", true);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);
	indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true);
	    indicator.parameters:addBoolean("OnlyOnce", "Alert Once", "Subsequent Alert will be ignored.", false);	

	
	
	Parameters (1, "1. Level",2);
	Parameters (2, "2. Level",-2);
 
	
end


function Parameters ( id, Label,Level )
  
  
   indicator.parameters:addGroup(Label .. " Alert");
  
    indicator.parameters:addBoolean("ON"..id , "Show " .. Label .." Alert" , "", true);
	
	 indicator.parameters:addDouble("Level"..id , "Level" , "", Level);
	
    indicator.parameters:addFile("Up"..id, Label .. " Cross Over Sound", "", "");
    indicator.parameters:setFlag("Up"..id, core.FLAG_SOUND);
	
	indicator.parameters:addFile("Down"..id, Label .. " Cross Under Sound", "", "");
    indicator.parameters:setFlag("Down"..id, core.FLAG_SOUND);
	
	 indicator.parameters:addString("Label"..id, "Label", "", Label);

end 

local 	Number = 2;

local first;
local source = nil;
local RangePeriods;
local PriceSmoothing;
local IndexSmoothing;
local buffUP=nil;
local buffDN=nil; 
local buffAll;

--*************************

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
local Level= {};
local PlaySound;
local Live;
local FIRST=true;
 
local OnlyOnce;
local U={};
local D={};
 
local OnlyOnceFlag;

function Prepare(nameOnly)

    OnlyOnceFlag=true;
	FIRST=true;
	OnlyOnce = instance.parameters.OnlyOnce;
	Show = instance.parameters.Show;
	Live = instance.parameters.Live;
	
	
    source = instance.source;
    RangePeriods=instance.parameters.RangePeriods;
    PriceSmoothing=instance.parameters.PriceSmoothing;
    IndexSmoothing=instance.parameters.IndexSmoothing;
	
	
	local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.RangePeriods .. ", " .. instance.parameters.PriceSmoothing .. ", " .. instance.parameters.IndexSmoothing .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
    buff1 = instance:addInternalStream(0, 0);
    buff2 = instance:addInternalStream(0, 0);
    first = source:first()+2;
    
	
	buffALL = instance:addStream("Fisher", core.Bar, name .. "Fisher", "Fisher", instance.parameters.clrUP, first+2*RangePeriods+4);
    buffALL:setPrecision(math.max(2, instance.source:getPrecision()));
	
	
	Initialization();
	
	for i= 1, Number, 1 do
		if ON[i] then
		buffALL:addLevel(Level[i]);
		end
	end   
	
end


function  Initialization ()
     Size=instance.parameters.Size;
	 SendEmail = instance.parameters.SendEmail;
	 
	 local i;
	 for i = 1, Number , 1 do 
	  Label[i]=instance.parameters:getString("Label" .. i);
	  ON[i]=instance.parameters:getBoolean("ON" .. i);
	  Level[i]=instance.parameters:getDouble("Level" .. i);
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

function Update(period, mode)

    if (period<first+2*RangePeriods+4) then
	return;
	end
	
	 
	Calculation(period, mode);
	
	local i;
	for i = 1, Number , 1 do
		  if ON[i] then
		 down[i]:setNoData (period); 
		 up[i]:setNoData (period);
		 end
   end	 
    
    Activate (1, period);
	Activate (2, period);

	
   
end

function Calculation (period, mode)
 local LowestLow=core.min(source.low,core.rangeTo(period,RangePeriods));
     local HighestHigh=core.max(source.high,core.rangeTo(period,RangePeriods));
     if HighestHigh-LowestLow<0.1*source:pipSize() then
      HighestHigh=LowestLow+0.1*source:pipSize();
     end
     local GreatestRange=HighestHigh-LowestLow;
     local MidPrice=(source.high[period]+source.low[period])/2.;
     local PriceLocation=0.;
     if GreatestRange~=0. then
      PriceLocation=(MidPrice-LowestLow)/GreatestRange;
      PriceLocation=2.*PriceLocation-1.;
     end
     buff2[period]=PriceSmoothing*buff2[period-1]+(1.-PriceSmoothing)*PriceLocation;
     local SmoothedLocation=buff2[period];
     SmoothedLocation=math.min(SmoothedLocation,0.99);
     SmoothedLocation=math.max(SmoothedLocation,-0.99);
     local FishIndex=0.;
     if 1.-SmoothedLocation~=0. then
      FishIndex=math.log((1.+SmoothedLocation)/(1.-SmoothedLocation));
     end
     buff1[period]=IndexSmoothing*buff1[period-1]+(1.-IndexSmoothing)*FishIndex;
     
	 buffALL[period]=buff1[period];
	 
     if buffALL[period]>0. then
      buffALL:setColor(period, instance.parameters.clrUP);
     else
      buffALL:setColor(period, instance.parameters.clrDN); 
     end
   
end


function Activate (id, period)

   local Shift=0;
   

   if Live~= "Live" then
	period=period-1;
	Shift=1;
	end
 
	  if ON[id]  then
	  
	       
			if buffALL[period] > Level[id]
			and buffALL[period-1] <= Level[id]
			then
			           
						     up[id]:set(period , Level[id], "\108");	
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  then
							  OnlyOnceFlag=false;
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Cross Over " .. Level[id], period);
							    
							        if Show then
									Pop(Label[id], " Cross Over ".. Level[id] );  	
								    end
								 
							  end
			elseif buffALL[period] < Level[id]
			and buffALL[period-1] >= Level[id]
            then			
			
			            			 
			               down[id]:set(period , Level[id], "\108");	  						   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 then
							 OnlyOnceFlag=false;
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " Cross Under " .. Level[id] , period);	
								 if Show then
									Pop(Label[id], " Cross Under ".. Level[id] );  	
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
   local TF= "Time Frame : " .. source:barSize();    
   local Time =  " Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec; 
   
     local text = Note  .. delim ..  Symbol .. delim .. TF  .. delim .. Time;
 
 terminal:alertEmail(Email, profile:id(), text);
end
	 




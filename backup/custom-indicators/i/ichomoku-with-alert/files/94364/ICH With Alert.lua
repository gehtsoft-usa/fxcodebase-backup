-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60794

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
    indicator:name("Ichimoku");
    indicator:description("Enables to quickly discern and filter  at a glance  the low-probability trading setups from those of higher probability.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator:setTag("group", "Trend");
	
	indicator.parameters:addGroup("Mode");  
	indicator.parameters:addString("Live", "End of Turn / Live", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
	indicator.parameters:addStringAlternative("Live", "Live", "", "Live");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("X", "Tenkan-sen period","", 9, 1, 10000);
    indicator.parameters:addInteger("Y", "Kijun-sen period","", 26, 1, 10000);
    indicator.parameters:addInteger("Z","Senkou Span B period","", 52, 1, 10000);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrTS", "Tenkan-sen Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("widthSL", "Line Width","", 1, 1, 5);
    indicator.parameters:addInteger("styleSL","Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("styleSL", core.FLAG_LEVEL_STYLE);

    indicator.parameters:addColor("clrKS", "Kijun-sen Line Color","", core.rgb(0, 255, 255));
    indicator.parameters:addInteger("widthTL", "Line Width","", 1, 1, 5);
    indicator.parameters:addInteger("styleTL", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("styleTL", core.FLAG_LEVEL_STYLE);

    indicator.parameters:addColor("clrCS", "Chinkou Span Line Color","", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("widthCS", "Line Width","", 1, 1, 5);
    indicator.parameters:addInteger("styleCS", " Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("styleCS", core.FLAG_LEVEL_STYLE);

    indicator.parameters:addColor("clrSSA", "Senkou span A Line Color","", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthSSA", "Line Width","", 1, 1, 5);
    indicator.parameters:addInteger("styleSSA", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("styleSSA", core.FLAG_LEVEL_STYLE);

    indicator.parameters:addColor("clrSSB", "Senkou span B Line Color","", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("widthSSB", "Line Width","", 1, 1, 5);
    indicator.parameters:addInteger("styleSSB", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("styleSSB", core.FLAG_LEVEL_STYLE);

    indicator.parameters:addInteger("transp", "Cloud transparency %","", 80, 0, 100);
	
	
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
	
	
	Parameters (1, "Tenkan-sen");
	Parameters (2, "Kijun-sen")
	Parameters (3, "Chinkou Span")
	Parameters (4, "Senkou span A")
	Parameters (5, "Senkou span B")
	Parameters (6, "Tenkan-sen/Kijun-sen")
	Parameters (7, "Senkou span A/Senkou span B")	
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local Tenkan;
local Kijun;
local Senkou;

local firstPeriod;
local source = nil;

local csFirst = nil;
local slFirst = nil;
local tlFirst = nil;
local saFirst = nil;
local sbFirst = nil;
local chFirst = nil;

-- Streams block
local SL = nil;
local TL = nil;
local CS = nil;
local SA = nil;
local SB = nil;
local SA1 = nil;
local SB2 = nil;
local clrSSA, clrSSB;



function Parameters ( id, Label )
  
  
   indicator.parameters:addGroup(Label .. " Alert");
  
    indicator.parameters:addBoolean("ON"..id , "Show " .. Label .." Alert" , "",false);

    indicator.parameters:addFile("Up"..id, Label .. " Cross Over Sound", "", "");
    indicator.parameters:setFlag("Up"..id, core.FLAG_SOUND);
	
	indicator.parameters:addFile("Down"..id, Label .. " Cross Under Sound", "", "");
    indicator.parameters:setFlag("Down"..id, core.FLAG_SOUND);
	
	 indicator.parameters:addString("Label"..id, "Label", "", Label);

end 

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
local OnlyOnce;
local U={};
local D={}; 
local OnlyOnceFlag;

local 	Number = 7;

-- Routine
function Prepare(nameOnly)
    Tenkan = instance.parameters.X;
    Kijun = instance.parameters.Y;
    Senkou = instance.parameters.Z;
    source = instance.source;
	
	FIRST=true;
	OnlyOnce = instance.parameters.OnlyOnce;
	Show = instance.parameters.Show;
	Live = instance.parameters.Live;
	
	
    firstPeriod = source:first();

    local name = profile:id() .. "(" .. source:name() .. ", " .. Tenkan .. ", " .. Kijun .. ", " .. Senkou .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
    SL = instance:addStream("SL", core.Line, name .. ".TL", "TL", instance.parameters.clrTS, firstPeriod + Tenkan - 1)
    SL:setWidth(instance.parameters.widthSL);
    SL:setStyle(instance.parameters.styleSL);
    TL = instance:addStream("TL", core.Line, name .. ".KL", "KL", instance.parameters.clrKS, firstPeriod + Kijun - 1)
    TL:setWidth(instance.parameters.widthTL);
    TL:setStyle(instance.parameters.styleTL);
    CS = instance:addStream("CS", core.Line, name .. ".CS", "CS", instance.parameters.clrCS, firstPeriod, -Kijun)
    CS:setWidth(instance.parameters.widthCS);
    CS:setStyle(instance.parameters.styleCS);
    SA = instance:addStream("SA", core.Line, name .. ".SA", "SA", instance.parameters.clrSSA, math.max(SL:first(), TL:first()), Kijun)
    SA:setWidth(instance.parameters.widthSSA);
    SA:setStyle(instance.parameters.styleSSA);
    SB = instance:addStream("SB", core.Line, name .. ".SB", "SB", instance.parameters.clrSSB, firstPeriod + Senkou - 1, Kijun)
    SB:setWidth(instance.parameters.widthSSB);
    SB:setStyle(instance.parameters.styleSSB);

    csFirst = CS:first() + Kijun;
    slFirst = SL:first();
    tlFirst = TL:first();
    saFirst = SA:first();
    sbFirst = SB:first();

    chFirst = math.max(saFirst, sbFirst);
    SA1 = instance:addInternalStream(chFirst, Kijun);
    SB1 = instance:addInternalStream(chFirst, Kijun);
    instance:createChannelGroup("SA-SB", "SA-SB", SA1, SB1, instance.parameters.clrSSA, 100 - instance.parameters.transp);
    clrSSA = instance.parameters.clrSSA;
    clrSSB = instance.parameters.clrSSB;
	
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
		up[i] = instance:createTextOutput ("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Center, instance.parameters.Up, Kijun);
		down[i] = instance:createTextOutput ("Dn", "Dn", "Wingdings", Size, core.H_Center, core.V_Center, instance.parameters.Down, Kijun);
		end
	end
		
	

	
end	



 function Update(period)

  if (period < chFirst) then
	return;
	end
 
  Calculation(period);
  
  
  local i;
	for i = 1, Number , 1 do
		  if ON[i] then
		 down[i]:setNoData (period); 
		 up[i]:setNoData (period);
		 end
   end	 
   
 
    Activate (1, period);
    Activate (2, period);
	Activate (3, period);
	Activate (4, period);
	Activate (5, period); 
	Activate (6, period);
    Activate (7, period); 	
 end
 
 
function Activate (id, period)
 
 
	  if id == 1  and ON[id]  then 
	  Logic(id, SL,period);
	  end
	  
	  if id == 2  and ON[id]  then 
	   Logic(id, TL,period); 
	  end
	  
	  if id == 3  and ON[id]  then 
	  Logic(id, CS,period); 
	  end
	  
	  if id == 4  and ON[id]  then
	  Logic(id, SA,period); 
	  end
	  
	  if id == 5  and ON[id]  then 
	  Logic(id, SB,period); 
	  end 
	  
	   if id == 6  and ON[id]  then 
	  Logic(id, SL,period, TL); 
	  end 
		   
       if id == 7  and ON[id]  then 
	  Logic(id, SA,period, SB); 
	  end 
		   
		   
        if FIRST then
        FIRST=false;      
        end		

end

function Logic(id, Data,period, DataLine)


   local Shift=0;
 
 
   if id == 3  
   then
   
		if Live~= "Live" then
	   period=period-Kijun-1;
	   Shift=Kijun+1;
	   else
	    period=period-Kijun;
	   Shift=Kijun;
	   end
   end
   

  
   if id == 7   
   then
   
		if Live~= "Live" then
	   period=period+Kijun-1;
	   Shift=-Kijun-1;
	   else
	    period=period+Kijun;
	   Shift=-Kijun;
	   end
   end
  
   --SL,TL,CS,SA,SB

    if Live~= "Live" and id ~= 3 and  id ~= 6 and  id ~= 7  then
	period=period-1;
	Shift=1;
	end
	
	if period < Data:first() 
	or  period > Data:size()-1
	then
	return;
	end
	
	
	if id== 6 or id== 7    then  
          if Data[period] > DataLine[period]
			and Data[period-1] <= DataLine[period-1]
			then
			           
						     up[id]:set(period , DataLine[period], "\108");	
						   
			
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
			elseif  Data[period] < DataLine[period]
			and Data[period-1] >= DataLine[period-1]
            then			
			
			            			 
			               down[id]:set(period , DataLine[period], "\108");	  						   
						   
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
    	else
	
				if source.close[period] > Data[period]
			and source.close[period-1] <= Data[period-1]
			then
			           
						     up[id]:set(period , Data[period], "\108");	
						   
			
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
			elseif  source.close[period] < Data[period]
			and source.close[period-1] >= Data[period-1]
            then			
			
			            			 
			               down[id]:set(period , Data[period], "\108");	  						   
						   
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
	----------------
	
	      
	
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
 
 --Alert
   terminal:alertSound(Sound, RecurrentSound);
end
 

function EmailAlert( label , Subject, period)

if not SendEmail then
return
end

 if OnlyOnce and OnlyOnceFlag== false then
 return;
 end

 
    local date = source:date(NOW);
	local DATA = core.dateToTable (date);
	
    
   local delim = "\013\010";  
   local Note=  profile:id().. delim.. " Label : " ..label  .. delim .. " Alert : " .. Subject ;   
   local Symbol= "Instrument : " .. source:instrument() ;
   local TF= "Time Frame : " .. source:barSize();    
   local Time =  " Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec; 
   
  local text = Note  .. delim ..  Symbol .. delim .. TF   .. delim .. Time; 
  terminal:alertEmail(Email, profile:id(), text);
end
 
 
function Calculation(period)
    if (period < csFirst) then
	return;
	end
        CS[period - Kijun] = source.close[period];
     

    local p, hh, ll;

    if (period < slFirst) then
	return;
	end
        ll, hh = mathex.minmax(source, period - Tenkan + 1, period);
        SL[period] = (hh + ll) / 2;
    
    if (period < tlFirst) then
	return;
	end
	
        ll, hh = mathex.minmax(source, period - Kijun + 1, period);
        TL[period] = (hh + ll) / 2;
     

    local p = period + Kijun;

    if (period < saFirst) then
	return;
	end
        SA[p] = (SL[period] + TL[period]) / 2;
   

    if (period < sbFirst) then
	return;
	end
	
        ll, hh = mathex.minmax(source, period - Senkou + 1, period);
        SB[p] = (hh + ll) / 2;
     

    if (period < chFirst) then
	return;
	end
        SA1[p] = SA[p];
        SB1[p] = SB[p];
        if (SA[p] > SB[p]) then
            SA1:setColor(p, clrSSB);
        else
            SA1:setColor(p, clrSSA);
        end
    
end



-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65446

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
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
    indicator:name("TMA CG indicator");
    indicator:description("TMA CG indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("Price", "Price type", "", "close");
    indicator.parameters:addStringAlternative("Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted"); 
    indicator.parameters:addInteger("HalfLength", "Half Length", "", 56);
    indicator.parameters:addDouble("BandDeviations", "Band Deviations", "", 2.5);
    indicator.parameters:addBoolean("Interpolate", "Interpolate", "", true);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("tmclr", "TM Color", "TM Color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("tmwidth", "TM Line width", "TM Line width", 1, 1, 5);
    indicator.parameters:addInteger("tmstyle", "TM Line style", "TM Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("tmstyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("upclr", "Up Color", "Up Color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("upwidth", "Up Line width", "Up Line width", 1, 1, 5);
    indicator.parameters:addInteger("upstyle", "Up Line style", "Up Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("upstyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("dnclr", "Dn Color", "Dn Color", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("dnwidth", "Dn Line width", "Dn Line width", 1, 1, 5);
    indicator.parameters:addInteger("dnstyle", "Dn Line style", "Dn Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("dnstyle", core.FLAG_LINE_STYLE);
  --  indicator.parameters:addColor("upaclr", "Up arrow Color", "Up arrow Color", core.rgb(255, 0, 0));
   -- indicator.parameters:addColor("dnaclr", "Dn arrow Color", "Dn arrow Color", core.rgb(0, 0, 255));
   -- indicator.parameters:addInteger("DotSize", "Dot size", "Dot size", 3, 1, 5);
	
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

	
	Parameters (1, "Alert");	
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
local UpTrendColor, DownTrendColor;
local OnlyOnceFlag;
local ShowAlert;
local Alert={}; 
local AlertLevel={};
local ToTime;
local Shift=0; 

local first;
local source = nil;
local HalfLength;
local BandDeviations;
local Interpolate;
local Price;

local tmBuffer, upBuffer, dnBuffer, dnArrow, upArrow;
local wuBuffer, wdBuffer;

function Prepare(nameOnly) 

     source = instance.source;
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end

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
	
	
   
    Price=instance.parameters.Price;
    HalfLength=instance.parameters.HalfLength;
    BandDeviations=instance.parameters.BandDeviations;
    Interpolate=instance.parameters.Interpolate;
    first = source:first()+2*HalfLength;
    wuBuffer = instance:addInternalStream(first, 0);
    wdBuffer = instance:addInternalStream(first, 0);
    
	
    tmBuffer = instance:addStream("tmBuffer", core.Line, name .. ".tmBuffer", "tmBuffer", instance.parameters.tmclr, first);
    tmBuffer:setWidth(instance.parameters.tmwidth);
    tmBuffer:setStyle(instance.parameters.tmstyle);
    upBuffer = instance:addStream("upBuffer", core.Line, name .. ".upBuffer", "upBuffer", instance.parameters.upclr, first);
    upBuffer:setWidth(instance.parameters.tmwidth);
    upBuffer:setStyle(instance.parameters.tmstyle);
    dnBuffer = instance:addStream("dnBuffer", core.Line, name .. ".dnBuffer", "dnBuffer", instance.parameters.dnclr, first);
    dnBuffer:setWidth(instance.parameters.tmwidth);
    dnBuffer:setStyle(instance.parameters.tmstyle);
    --dnArrow = instance:addStream("dnArrow", core.Dot, name .. ".dnArrow", "dnArrow", instance.parameters.dnaclr, first);
   -- upArrow = instance:addStream("upArrow", core.Dot, name .. ".upArrow", "upArrow", instance.parameters.upaclr, first);
   -- dnArrow:setWidth(instance.parameters.DotSize);
   -- upArrow:setWidth(instance.parameters.DotSize);
	
	
     for i= 1, Number , 1 do
		Alert[i]=instance:addInternalStream(0, 0);
		AlertLevel[i]=instance:addInternalStream(0, 0);
     end
	
	Initialization();	
	instance:ownerDrawn(true);	 
	
	
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
			
			  width, height = context:measureText (1,  "\108", 0);
              context:drawText (1,   "\108", UpTrendColor, -1,  x-width/2 ,  y-height , x+width/2 , y, 0 );	
   
			elseif Alert[Level][period]== -1 then
			visible, y = context:pointOfPrice (AlertLevel[Level][period]);
			width, height = context:measureText (1,  "\108", 0);
			 context:drawText (1,   "\108", DownTrendColor, -1,  x-width/2  ,  y , x+width/2 ,y+height, 0 );	
		    end
		  end
		    
		 
		end
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




function Update(period, mode)
   if period<first then
   return;
   end
   
    local i, j, k;
    local FullLength=2*HalfLength+1;

    local sum=(HalfLength+1)*source[Price][period];
    local sumw=HalfLength+1;

    k=HalfLength;
    for j=1, HalfLength, 1 do
      i=source:size()-1-period;
      sum=sum+k*source[Price][period-j];
      sumw=sumw+k;

      if j<=i then
        sum=sum+k*source[Price][period+j];
        sumw=sumw+k;
      end

      k=k-1;
    end
    tmBuffer[period]=sum/sumw;

    local diff=source[Price][period]-tmBuffer[period];

    if period>=first+HalfLength then
      if period==first+HalfLength then
        upBuffer[period]=tmBuffer[period];
        dnBuffer[period]=tmBuffer[period];

        if diff>=0 then
          wuBuffer[period]=diff*diff;
          wdBuffer[period]=0;
        else
          wdBuffer[period]=diff*diff;
          wuBuffer[period]=0;
        end
      else
        if diff>=0 then
          wuBuffer[period]=(wuBuffer[period-1]*(FullLength-1)+diff*diff)/FullLength;
          wdBuffer[period]=wdBuffer[period-1]*(FullLength-1)/FullLength;
        else
          wdBuffer[period]=(wdBuffer[period-1]*(FullLength-1)+diff*diff)/FullLength;
          wuBuffer[period]=wuBuffer[period-1]*(FullLength-1)/FullLength;
        end
        upBuffer[period]=tmBuffer[period-1]+BandDeviations*math.sqrt(wuBuffer[period]);
        dnBuffer[period]=tmBuffer[period-1]-BandDeviations*math.sqrt(wdBuffer[period]);

        if source.high[period-1]>upBuffer[period-1] and source.close[period-1]>source.open[period-1] and source.close[period]<source.open[period] then
        --  upArrow[period]=source.high[period];
		  
		    	
 				AlertLevel[1][period]= source.high[period];
				Alert[1][period]=1;		   
       -- else
        --  upArrow[period]=nil;
        end

        if source.low[period-1]<dnBuffer[period-1] and source.close[period-1]<source.open[period-1] and source.close[period]>source.open[period] then
        --  dnArrow[period]=source.low[period];
		      AlertLevel[1][period]= source.low[period];
				Alert[1][period]=-1;		
				
     --   else
         -- dnArrow[period]=nil;
        end
      end
    end
	
	
	 if Live~= "Live" then
	period=period-1;
	Shift=1;
	else
	Shift=0;
	end 
	
	
    Activate (1, period)
	
end
	
function Activate (id, period)

 
   
   
  
  
	  if id == 1  and ON[id]  then
	  
	       
			if   Alert[id][period]== 1 
			then
			           
					 
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag~= false))
							  then
							  
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Top ");
							  SendAlert( Label[id]," Top "); 
							  Pop(Label[id], " Top ", period );  
							  OnlyOnceFlag=false;
							  end
							  
			elseif Alert[id][period]== -1 
            then			
			
			            			 
 
							 
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag~= false))
							 then							
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " Bottom ");								 
							 Pop(Label[id], " Bottom ", period );  	
							 SendAlert( Label[id]," Bottom ");
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
	now = core.host:execute ("convertTime",  core.TZ_EST, ToTime, now);
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
	now = core.host:execute ("convertTime",  core.TZ_EST, ToTime, now);
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
	now = core.host:execute ("convertTime",  core.TZ_EST, ToTime, now);
	local DATA = core.dateToTable (now);
	
    
   local delim = "\013\010";  
   local Note=  profile:id().. delim.. " Label : " ..label  .. delim .. " Alert : " .. Subject ;   
   local Symbol= "Instrument : " .. source:instrument() ;
   local Time =  " Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec;  
   
 
    local TF= "Time Frame : " .. source:barSize();       
    local text = Note  .. delim ..  Symbol .. delim .. TF  .. delim .. Time;
	
 
    terminal:alertMessage(source:instrument(), source[NOW], text, now);
end

 
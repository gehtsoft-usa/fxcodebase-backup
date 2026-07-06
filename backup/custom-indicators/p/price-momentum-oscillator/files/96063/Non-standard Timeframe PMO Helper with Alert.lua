-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61209


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
    indicator:name("Non-standard Timeframe Price Momentum Oscillator");
    indicator:description("Non-standard Timeframe Price Momentum Oscillator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
	indicator.parameters:addString("TF", "Time frame", "", "Chart");
	
    indicator.parameters:addInteger("one", "Short Period", "Period", 20);
	indicator.parameters:addInteger("two", "Long Period", "Period", 35);
	indicator.parameters:addInteger("Period", "Signal Period", "Period", 10);
	
	indicator.parameters:addBoolean("SH", "Show Horizontal Line", "", true);
	indicator.parameters:addBoolean("SV", "Show Vertical Line", "", true);
	indicator.parameters:addBoolean("ShowHistorical", "Show Historical", "", true);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up_color", "Color of PMO Up", "Color of PMO", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down_color", "Color of PMO Down", "Color of PMO", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	
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
 
	
	indicator.parameters:addGroup("Alerts Sound");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", false);	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);

	
	indicator.parameters:addGroup("Alerts Email");   
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", false);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);

	
	Parameters (1, "Cross");	
 
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
local ShowAlert;
 
local ToTime;
local Shift=0; 


-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local one, two;

local first;
local source = nil; 
-- Streams block
local PMO = nil;
local Signal;
local EMA;
local Period;
local SH,SV;

local Show;
local TF;
local weekoffset, dayoffset;
local loading;
local SourceData;

-- Routine
function Prepare(nameOnly)
    one = instance.parameters.one;
	two = instance.parameters.two;
	Period= instance.parameters.Period;
	SH= instance.parameters.SH;
	SV= instance.parameters.SV;
	ShowHistorical= instance.parameters.ShowHistorical;
    source = instance.source;
    first = source:first(); 
	
	
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

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(one) .. ", " .. tostring(two) .. ", " .. tostring(Period).. ")";
    instance:name(name);

    if   (nameOnly) then
        return;
    end
	

	assert(core.indicators:findIndicator("PMO") ~= nil, "Please, download and install PMO.LUA indicator");
	
	TF= instance.parameters.TF;
	if TF=="Chart" then
	TF=source:barSize();
	end
	
	
	dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");
	

    local precision = math.max(2, source:getPrecision());

	if TF ~= "Chart"then
	local s1, e1, s2, e2;
    s1, e1 = core.getcandle(source:barSize(),0, 0, 0);
    s2, e2 = core.getcandle(TF, 0, 0, 0);
    assert ((e1 - s1) <= (e2 - s2), "The chosen time frame must be equal to or bigger than the chart time frame!");
	end
	
	if TF ~= source:barSize() then 
    SourceData = core.host:execute("getSyncHistory", source:instrument(), TF, source:isBid(), 0, 100, 101);
    loading=true; 
	
	Indicator = core.indicators:create("PMO", SourceData.close, one, two, Period);
	else	 
	Indicator = core.indicators:create("PMO", source, one, two, Period);
	end
	
	
        PMO = instance:addInternalStream(0, 0);	  	
		Signal = instance:addInternalStream(0, 0);		
		instance:ownerDrawn(true);

	 
	
	Initialization();	 
    
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
    if stage ~= 2  then
	return;
	end
	
	local ItIs=false;
	
        if not init then
            context:createPen (1	, context:convertPenStyle (instance.parameters.style), instance.parameters.width,  instance.parameters.Up_color);
			context:createPen (2    , context:convertPenStyle (instance.parameters.style), instance.parameters.width, instance.parameters.Down_color);
            init = true;
        end

		
		for period=    source:size()-1 ,  context:firstBar () , -1 do
		
		    if PMO:hasData(period)
			and Signal:hasData(period)
			then
			
				
				if PMO[period]> Signal[period] 
				and PMO[period-1]<= Signal[period-1]
				then
				
				ItIs=true;
				
				if SV then
				x, x1, x2 = context:positionOfBar (period);
				context:drawLine (1, x, context:top (), x, context:bottom ());
				end
				
				if SH then
				visible, y = context:pointOfPrice (source[period] );
				context:drawLine (1, x, y, context:right (), y);
				end
				
				elseif PMO[period]< Signal[period]
				and PMO[period-1]>= Signal[period-1]
				then
				
				ItIs=true;
				
				
				if SV then
				x, x1, x2 = context:positionOfBar (period);			
				context:drawLine (2, x, context:top (), x, context:bottom ());
				end
				
				if SH then
				visible, y = context:pointOfPrice (source[period] );
				context:drawLine (2, x, y, context:right (), y);
				end
				end
				
				
				if not ShowHistorical and ItIs then
				break;
				end
             end
       end		
end		

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)

   if period < first or not source:hasData(period) then
	return;
	end  
	
	
 Indicator:update(mode);
	 
  if TF ~= source:barSize() then 
	 
	 local p =  InitializationPeriod(period) 
     
        if not p then
        return;
        end
		 
		
	
		
		PMO[period]= Indicator.PMO[p];
		Signal[period]= Indicator.SIGNAL[p];
		
		else
		
		 
		 
 
		
		PMO[period]= Indicator.PMO[period];
		Signal[period]= Indicator.SIGNAL[period];
		
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
	
end 

function Activate (id, period)


    
   
   
  
  
	  if id == 1  and ON[id]  then
	  
	       
			if PMO[period]> Signal[period] 
			and PMO[period-1]<= Signal[period-1]
			then
			           
						    
         
                 
						   
			
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
							  
			elseif PMO[period]< Signal[period] 
			and PMO[period-1]>= Signal[period-1]
            then			
			
			            			 
			              
						   
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
 
 
-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    if cookie == 100 then
        loading = false;
        instance:updateFrom(0);
    elseif cookie == 101 then
        loading = true;
    end
end

function   InitializationPeriod(period)

    local Candle;
    Candle = core.getcandle(TF, source:date(period), dayoffset, weekoffset);

  
    if loading or SourceData:size() == 0 then
        return false ;
    end

    
    if period < source:first() then
        return false;
    end

    local p = core.findDate(SourceData, Candle, false);

    -- candle is not found
    if p < 0 then
        return false;
    else return p;    
    end
    
end    

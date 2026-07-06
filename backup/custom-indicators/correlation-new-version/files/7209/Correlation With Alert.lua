-- Id: 2787
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3093

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                              Support our efforts by donating   | 
--|                                                                 Paypal: https://goo.gl/9Rj74e  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+

--Your donations will allow the service to continue onward.
--+------------------------------------------------------------------------------------------------+
--|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
--|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
--|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
--|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
--|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
--|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
--+------------------------------------------------------------------------------------------------+


--//////////////////////////////////////////////////////////////////////////////
--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

local Number = 4;
local Symbols={"\225","\226","\225","\226"};
local Font={"Wingdings", "Wingdings",  "Wingdings", "Wingdings"};
local Alert_Name={ "Top Line Cross" ,"Top Line Cross", "Bottom Line Cross" ,"Bottom Line Cross"};
local Signal_Name={"Cross Over", "Cross Under","Cross Over", "Cross Under"};
--//////////////////////////////////////////////////////////////////////////////
--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\


function Init()
    indicator:name("Correlation With Alert");
    indicator:description(" ");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator); 
	
	indicator.parameters:addGroup("Alert Levels");
	indicator.parameters:addDouble("Top", "Top Line", "", 0.25 );
	indicator.parameters:addDouble("Bottom", "Bottom Line", "", -0.25 );		
	
    indicator.parameters:addGroup("Prices");
    indicator.parameters:addInteger("N", "Number of bars", "", 14, 5, 100);
    indicator.parameters:addString("Src", "The source stream", "", "close");
    indicator.parameters:addStringAlternative("Src", "open", "", "open");
    indicator.parameters:addStringAlternative("Src", "high", "", "high");
    indicator.parameters:addStringAlternative("Src", "low", "", "low");
    indicator.parameters:addStringAlternative("Src", "close", "", "close");
    indicator.parameters:addStringAlternative("Src", "median", "", "median");
    indicator.parameters:addStringAlternative("Src", "typical", "", "typical");
    indicator.parameters:addStringAlternative("Src", "weighted", "", "weighted");
    indicator.parameters:addString("INST", "The instrument to compare with", "", "EUR/JPY");
    indicator.parameters:setFlag("INST", core.FLAG_INSTRUMENTS);
    indicator.parameters:addString("Dst", "The  stream to compare width", "", "close");
    indicator.parameters:addStringAlternative("Dst", "open", "", "open");
    indicator.parameters:addStringAlternative("Dst", "high", "", "high");
    indicator.parameters:addStringAlternative("Dst", "low", "", "low");
    indicator.parameters:addStringAlternative("Dst", "close", "", "close");
    indicator.parameters:addStringAlternative("Dst", "median", "", "median");
    indicator.parameters:addStringAlternative("Dst", "typical", "", "typical");
    indicator.parameters:addStringAlternative("Dst", "weighted", "", "weighted");
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Line Color", "", core.rgb(0, 255, 255));
    indicator.parameters:addInteger("width", "Line Width (in pixels)", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addColor("clrP", "Postive Fill Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clrN", "Negative Fill Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("T", "Fill Transparency (%)", "", 70, 0, 100);
    indicator.parameters:addGroup("Levels");
    indicator.parameters:addColor("clrL", "Level Color", "", core.COLOR_CUSTOMLEVEL);
    indicator.parameters:addInteger("widthL", "Level Width (in pixels)", "", 1, 1, 5);
    indicator.parameters:addInteger("styleL", "Level Style", "", core.LINE_DOT);
    indicator.parameters:setFlag("styleL", core.FLAG_LEVEL_STYLE);

--\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
 
    indicator.parameters:addGroup("Alert Parameters");  
	indicator.parameters:addString("Signal_Execution", "Signal Execution", "", "End of Turn");
    indicator.parameters:addStringAlternative("Signal_Execution", "End of Turn", "", "End of Turn");
	indicator.parameters:addStringAlternative("Signal_Execution", "Live", "", "Live");  
	
 
	indicator.parameters:addString("Alert_Execution", "Alert Execution", "", "Live");
    indicator.parameters:addStringAlternative("Alert_Execution", "End of Turn", "", "End of Turn");
	indicator.parameters:addStringAlternative("Alert_Execution", "Live", "", "Live");  

   
   	indicator.parameters:addString("Alert_Triger", "Alert Triger", "", "Both");
    indicator.parameters:addStringAlternative("Alert_Triger", "Timer", "", "Timer");
	indicator.parameters:addStringAlternative("Alert_Triger", "Price", "", "Price");
    indicator.parameters:addStringAlternative("Alert_Triger", "Both", "", "Both");
	
    indicator.parameters:addInteger("Timer", "Execution Timer (in seconds)", "", 1, 0, 1000);
 
   
    
 
	 
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
--indicator.parameters:addBoolean("Show_Unconfirmed", "Show Unconfirmed Signals", "", false);
 
  
	
	indicator.parameters:addGroup("Alerts Sound");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", true);	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);

	
	indicator.parameters:addGroup("Alerts Email");   
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", false);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);

	
	local Color={};
	Color[1]= core.rgb(0, 255, 0);
	Color[2]= core.rgb(255, 0, 0);
	Color[3]= core.rgb(0, 255, 0);
	Color[4]= core.rgb(255, 0, 0);	
	
	for i= 1, Number, 1 do
	Parameters (i, Alert_Name[i], Signal_Name[i],Color[i]);	
 
 	end
 
	 
end

local source;                             -- the indicator source
local other;                              -- the additional data stream
local other_stream;
local loading;                            -- flag indicating the other data stream is being loaded
local load_from;                          -- the date/time the data was loaded the last time from
local instrument;                         -- the instrument to be loaded

local price_src, price_dst, price_first;  -- prices
local roc_src, roc_dst, roc_first;        -- rate of change
local output, output_first;               -- output stream

local f1, f2;                             -- fill streams
local clrP, clrN;                         -- positive and negative colors

local N;

local Bottom, Top;

function Prepare(onlyName)
    source = instance.source;
    N = instance.parameters.N;
    price_first = source:first();
	
	Bottom = instance.parameters.Bottom;
	Top = instance.parameters.Top;

    instrument = instance.parameters.INST;

    local name;
    name = profile:id() .. "(" .. source:name() .. "." .. instance.parameters.Src .. "," .. instrument .. "." .. instance.parameters.Dst .. "," .. instance.parameters.N .. ")";
    instance:name(name);
    if onlyName then
        return ;
    end

    price_src = source[instance.parameters.Src];
    price_dst = instance:addInternalStream(price_first, 0);

    roc_first = price_first + 1;
    roc_src = instance:addInternalStream(roc_first, 0);
    roc_dst = instance:addInternalStream(roc_first, 0);

    output_first = roc_first + N;

    output = instance:addStream("C", core.Line, name, "C", instance.parameters.clr, output_first);
    output:setWidth(instance.parameters.width);
    output:setStyle(instance.parameters.style);
    output:setPrecision(2);

    output:addLevel(-1, instance.parameters.styleL, instance.parameters.widthL, instance.parameters.clrL);
    output:addLevel(0, instance.parameters.styleL, instance.parameters.widthL, instance.parameters.clrL);
    output:addLevel(1, instance.parameters.styleL, instance.parameters.widthL, instance.parameters.clrL);
	
	output:addLevel(Top);
	output:addLevel(Bottom);

    clrP = instance.parameters.clrP;
    clrN = instance.parameters.clrN;
    f1 = instance:addInternalStream(output_first, 0);
    f2 = instance:addInternalStream(output_first, 0);
    instance:createChannelGroup("H", "H", f1, f2, clrP, 100 - instance.parameters.T);

--\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\

   
   	Alert_Triger= instance.parameters.Alert_Triger;
	
	 
 
    if Alert_Triger ~= "Timer" then
    core.host:execute("subscribeTradeEvents", 1, "offers");
    end
	

	
	Timer= instance.parameters.Timer 
	Initialization();	
	instance:ownerDrawn(true);	
	
	if Alert_Triger ~= "Price" then-- this will work for Timer and Both
    core.host:execute ("setTimer", 3 , Timer);
	end
			
end 

function ReleaseInstance()
core.host:execute ("killTimer", 3 );
end 
 
 
--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^




function Parameters ( id, Label1,Label2,internal_color )
  
  
   indicator.parameters:addGroup(Label1 .. " Alert");
  
    indicator.parameters:addBoolean("Alert_ON"..id , "Show " .. Label2 .." Alert" , "", true);
    indicator.parameters:addBoolean("Signal_ON"..id , "Show " .. Label2 .." Signal" , "", true); 
	

    indicator.parameters:addFile("Sound"..id, Label2 .. " Sound", "", "");
    indicator.parameters:setFlag("Sound"..id, core.FLAG_SOUND);

    indicator.parameters:addString("Alert_Label1"..id, "Alert Label", "", Label1);
	 indicator.parameters:addString("Alert_Label2"..id, "Alert Signal", "", Label2);
	 
	 
	 indicator.parameters:addColor("Color"..id, "Label Color", "",internal_color); 
	indicator.parameters:addInteger("Size"..id, "Label Size", "", 10, 1 , 100);

end 



local Sound={};
local Label1={};
local Label2={};
local Signal_ON={}; 
local Alert_ON={}; 
local Email;
local SendEmail;
local  RecurrentSound ,SoundFile  ;
local Show;
 
local PlaySound;
--local Live;
--local FIRST=true;
local OnlyOnce;
local ItIs={};
local Color={};
local Size={};
local OnlyOnceFlag;
local ShowAlert;
local Alert={}; 
local AlertLevel={};
local ToTime;
local Shift=0; 
local Timer;
--local Show_Unconfirmed;
local Signal_Execution, Alert_Execution,Alert_Triger;
local Alignment={};
--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^




function Update(period, mode)
    local from, to;

    if period < price_first then
        return ;
    end

    if other == nil then
        -- if the data is not loaded yet at all
        -- load the data
        from = source:date(source:first());   -- oldest data to load
        if source:isAlive() then              -- newest data to load or 0 if the source is "alive"
            to = 0;
        else
            to = source:date(source:size() - 1);
        end
        load_from = from;
        loading = true;
        other = core.host:execute("getHistory", 2, instrument, source:barSize(), from, to, source:isBid());
		return ;
    end

    if loading then
        return ;
    end
	
	if other~= nil then
        other_stream = other[instance.parameters.Dst];
	end

    local curr_date = source:date(period);
    if curr_date < load_from then
        -- if the data we are trying to get is oldest than previously loaded
        -- the extend the history to the oldest data we can request
        from = source:date(source:first());     -- load from the oldest data we have in source
        if other:size() > other:first() then
            to = other:date(other:first());     -- to the oldest data we have in other instrument
        else
            to = load_from;
        end
        load_from = from;
        loading = true;
        core.host:execute("extendHistory", 2, other, from, to);
        return ;
    end

    -- the date is in the loaded range
    -- try to find it
    local other_period = core.findDate(other, curr_date, true);

    if other_period ~= -1 then
        price_dst[period] = other_stream[other_period];
        if not(price_dst:hasData(period - 1)) and period > price_first then
            for i = price_first, period - 1, 1 do
                price_dst[i] = other_stream[other_period];
                if i > price_first then
                    roc_dst[i] = 0;
                end
            end
        end
    else
        if price_dst:hasData(period - 1) then
            price_dst[period] = price_dst[period - 1]
        end
    end

    if period < roc_first then
	return;
	end
	
        roc_src[period] = (price_src[period] - price_src[period - 1]) * 100 / price_src[period - 1];
         if price_dst:hasData(period - 1) then
            roc_dst[period] = (price_dst[period] - price_dst[period - 1]) * 100 / price_dst[period - 1];
         end

    if period <= output_first  then
	return;
	end
	
	
        local from = period - N + 1;
        output[period] = mathex.correl(roc_src, roc_dst, from, period, from, period);
        f1[period] = output[period];
        f2[period] = 0;
        if f1[period] > 0 then
            f1:setColor(period, clrP);
        else
            f1:setColor(period, clrN);
        end
 


--\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
	
	if Signal_Execution~= "Live" then-- if Signal_Execution is NOT a Live shift period by 1 
	period=period-1;	 
	end
	

    for id=1, Number, 1 do
    Signal_Logic (id, period);
	end
end




 

function  Initialization ()


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
	
	Signal_Execution = instance.parameters.Signal_Execution;
	Alert_Execution = instance.parameters.Alert_Execution;

	 
	OnlyOnce = instance.parameters.OnlyOnce;
	ShowAlert = instance.parameters.ShowAlert;
	Show = instance.parameters.Show;
	--Live = instance.parameters.Live;
	Show_Unconfirmed= instance.parameters.Show_Unconfirmed;

     for i= 1, Number , 1 do
		Alert[i]=instance:addInternalStream(0, 0);
		AlertLevel[i]=instance:addInternalStream(0, 0);
		Alignment[i]= instance:addInternalStream(0, 0);
     end
	 
	 
    
	 SendEmail = instance.parameters.SendEmail;
	 
	 local i;
	 for i = 1, Number , 1 do 
	  Label1[i]=instance.parameters:getString("Alert_Label1" .. i);
	  Label2[i]=instance.parameters:getString("Alert_Label2" .. i);
	  Signal_ON[i]=instance.parameters:getBoolean("Signal_ON" .. i);
	  Alert_ON[i]=instance.parameters:getBoolean("Alert_ON" .. i);
	 end
	 
	 
	 

    if SendEmail then
        Email = instance.parameters.Email;
    else
        Email = nil;
    end
	
    assert(not (SendEmail and (Email == "" or Email == nil )), "E-mail address must be specified");
	
	
	for i = 1, Number , 1 do 
	  Color[i]=instance.parameters:getColor("Color" .. i);
	  Size[i]=instance.parameters:getInteger("Size" .. i);
	end  
	
	 PlaySound = instance.parameters.PlaySound;
    if PlaySound then
    
	  for i = 1, Number , 1 do 
	  Sound[i]=instance.parameters:getString("Sound" .. i);
	 
	  end
	
    else 
	
	  for i = 1, Number , 1 do 
       Sound[i]=nil; 
	  end
		
    end
    
        for i = 1, Number , 1 do 
	  	 assert( not(PlaySound  and (Sound[i] == "" or Sound[i] == nil ) ), "Sound file must be chosen");
    
	end
	 
    RecurrentSound = instance.parameters.RecurrentSound;
	
	for i = 1, Number , 1 do 
	ItIs[i] = nil; 
	end
		 
end	

 


function Signal_Logic (id, period)


       
	  --  if not Show_Unconfirmed then
	   -- Alert[id][period]= 0;	
		--end
  
	
	    --id 1 will define Cross Over Alert
	    if id== 1  then   
			if  output[period] > Top
			and   output[period-1] <= Top
			then
			           
						    
         
                Alert[id][period]= 1;	
 				AlertLevel[id][period]= Top 
				Alignment[id][period]= -1;		   
					
						   							  
			elseif  output[period] < Top
			and   output[period-1] >= Top
            then			
			--We will reset CrossOver Alert 
						   
		  
		     Alert[id][period]= 0;
			                
	         end
			
	    end
		
	    --id 2 will define Cross Under Alert		
		if id== 2   then  
			if  output[period] < Top
			and   output[period-1] >= Top
			then
			           
						    
         
                Alert[id][period]= 1;	
 				AlertLevel[id][period]= Top
				Alignment[id][period]= 1;		   
			
						   
							  							  
			elseif  output[period] > Top 
			and   output[period-1] <= Top 
            then			
			 --We will reset CrossUnder Alert  
		 
		     Alert[id][period]= 0;
			                
	         end
			
	    end
		
		
		
			    --id 1 will define Cross Over Alert
	    if id== 3  then   
			if  output[period] > Bottom
			and   output[period-1] <= Bottom
			then
			           
						    
         
                Alert[id][period]= 1;	
 				AlertLevel[id][period]= Bottom 
				Alignment[id][period]= -1;		   
					
						   							  
			elseif  output[period] < Top
			and   output[period-1] >= Top
            then			
			--We will reset CrossOver Alert 
						   
		  
		     Alert[id][period]= 0;
			                
	         end
			
	    end
		
	    --id 2 will define Cross Under Alert		
		if id== 4   then  
			if  output[period] < Bottom
			and   output[period-1] >= Bottom
			then
			           
						    
         
                Alert[id][period]= 1;	
 				AlertLevel[id][period]= Bottom
				Alignment[id][period]= 1;		   
			
						   
							  							  
			elseif  output[period] > Bottom 
			and   output[period-1] <= Bottom 
            then			
			 --We will reset CrossUnder Alert  
		 
		     Alert[id][period]= 0;
			                
	         end
			
	    end



end
 





function AsyncOperationFinished (cookie, success, message)


     if cookie == 2 then
        loading = false;
        -- update the indicator output when loading is finished 
       instance:updateFrom(0);   
    end
	
	
 
	
 
	
    local Last_Period=source:size()-1;
	
	
	if Signal_Execution~= "Live" then
	Last_Period=Last_Period-1;	 
	end
	
    if Alert_Execution~= "Live" then
	Last_Period=Last_Period-1;	 
	end
	
	
     if Last_Period < N 
	 then
	 return;
	 end
	
	
	for i=1, Number, 1 do
    Alert_Logic (i, Last_Period);
    end
	
	

    instance:updateFrom(0);  
    return core.ASYNC_REDRAW ;
end




 

function Alert_Logic (id, period)



   
   
  
  
	if not  Alert_ON[id]  then
	return;
	end
	
	  
	    if   Alert[id][period]== 1  then   
		 
			           
  	   
							  if ItIs[id]~=source:serial(period)  
							  --and not FIRST 
							  and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag~= false))
							  --and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag== true))
							  then
							  
							  ItIs[id]=source:serial(period);
							  SoundAlert(Sound[id]);
							  EmailAlert( Label1[id], Label2[id]);
							  SendAlert( Label1[id],Label2[id],period); 
							  Pop(Label1[id], Label2[id], period );  
							  OnlyOnceFlag=false;
							  end 
		else
		
							   ItIs[id]=nil;
			 
			
	    end
		
 
	  
		   
       -- if FIRST then
        --FIRST=false;      
       -- end		

end

 

function SoundAlert(internal_sound)
 if not PlaySound then
 return;
 end

  terminal:alertSound(internal_sound, RecurrentSound);
end

 


function EmailAlert( label1,label2 )

if not SendEmail then
return
end
 
   local now = core.host:execute("getServerTime");
	now = core.host:execute ("convertTime",  core.TZ_EST, ToTime, now);
	local DATA = core.dateToTable (now);
    
   --delim == djelim == new line	
   local delim = "\013\010";  
   local Note=  profile:id().. delim.. " Label : " ..label1  .. delim .. "Alert : " .. label2 ;   
   local Symbol= "Instrument : " .. source:instrument() ;
   local Time =  "Date : " .. DATA.month.." / ".. DATA.day .."Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec;  
   
   
    local TF= "Time Frame : " .. source:barSize();       
    local text = Note  .. delim ..  Symbol .. delim .. TF  .. delim .. Time;
	
	
 
   terminal:alertEmail(Email, profile:id(), text);
end
	 
	 
	 
	 
function Pop(label1,label2 , period)
 
 
 if not Show then
   return;
   end
 
   local now = core.host:execute("getServerTime");
	now = core.host:execute ("convertTime",  core.TZ_EST, ToTime, now);
	local DATA = core.dateToTable (now);
   
   local delim = "\013\010";   
	
   local Symbol= "Instrument : " .. source:instrument() ;
   local TF= "Time Frame : " .. source:barSize();   
    local Time =  "Date : " .. DATA.month.." / ".. DATA.day .. delim .. "Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec; 
    local Text= Symbol .. delim ..  TF .. delim ..  Time.. delim ..  label1 .. ":" ..    label2     
   core.host:execute ("prompt", 1, profile:id(),  Text );


end

function SoundAlert(sound_file)
 if not PlaySound then
 return;
 end
 
 terminal:alertSound(sound_file, RecurrentSound);
end

 
function SendAlert(label1,label2, period)
    if not ShowAlert then
        return;
    end
	
	local delim = "\013\010";  
	
	 local now = core.host:execute("getServerTime");
	now = core.host:execute ("convertTime",  core.TZ_EST, ToTime, now);
	local DATA = core.dateToTable (now);
	
   local Symbol= "Instrument : " .. source:instrument() ;
   local TF= "Time Frame : " .. source:barSize();   
    local Time =  "Date : " .. DATA.month.." / ".. DATA.day .. delim ..  "Time :"   .. DATA.hour  .. " / ".. DATA.min .." / ".. DATA.sec; 
  
    local Text= Symbol .. delim ..  TF .. delim ..  Time.. delim ..  label1 .. ":" ..    label2  
	
 
    terminal:alertMessage(source:instrument(), source[NOW], Text, source:date(NOW));
end



local init = false;
 
function Draw(stage, context)
 
	 if stage~= 2 then
	  return;
	  end
	  
	  
	
        if not init then
		   for Level = 1 , Number ,  1 do
           context:createFont (Level, Font[Level], context:pointsToPixels (Size[Level]), context:pointsToPixels (Size[Level]), 0);
		   end
            init = true;
        end
		
		

		
		for period= math.max(context:firstBar (),source:first()), math.min( context:lastBar (), source:size()-1), 1 do
		
		 
		
		 x, x1, x2= context:positionOfBar (period);
		 
				 for Level = 1 , Number ,  1 do
					   if Alert[Level]:hasData(period) and Signal_ON[Level] then
						 
							if Alert[Level][period]== 1
							and Alert[Level][period-1]~= 1
							then
							visible, y = context:pointOfPrice (AlertLevel[Level][period]);
							
							  width, height = context:measureText (1,  Symbols[Level], 0);

                              if Alignment[Level][period]==-1 then
							   context:drawText (Level,  Symbols[Level], Color[Level], -1,  x-width/2 ,  y , x+width/2 , y+height, 0 );	--low
							  else
							   context:drawText (Level,  Symbols[Level], Color[Level], -1,  x-width/2 ,  y-height , x+width/2 , y, 0 );	--high, have my arrow above the high
							  end
							  
				   
							 end
					  end
						
				 
				end
		end
		
  
end		
 
 --^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

 
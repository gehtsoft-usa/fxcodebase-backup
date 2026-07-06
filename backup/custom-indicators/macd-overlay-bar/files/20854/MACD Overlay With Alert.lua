-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=9806

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


-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("MACD Overlay");
    indicator:description("MACD Overlay");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	
	indicator.parameters:addGroup("Mode");  
	indicator.parameters:addString("Live", "End of Turn / Live", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
	indicator.parameters:addStringAlternative("Live", "Live", "", "Live");
   
	
	indicator.parameters:addGroup("Selector");
	indicator.parameters:addString("Method", "Indicator Method", "Method" , "MACD / Zero & MACD Slope");
    indicator.parameters:addStringAlternative("Method", "MACD / Zero & MACD Slope", "MACD / Zero & MACD Slope" , "MACD / Zero & MACD Slope");
    indicator.parameters:addStringAlternative("Method", "MACD / Signal", "MACD / Signal" , "MACD / Signal");
    indicator.parameters:addStringAlternative("Method", "Histogram/Zero & Histogram Slope", "Histogram/Zero & Histogram Slope" , "Histogram/Zero & Histogram Slope");
    indicator.parameters:addStringAlternative("Method", "MACD/Signal & MACD/Zero", "MACD/Signal & MACD/Zero" , "MACD/Signal & MACD/Zero");
	
     indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("SN", "Short EMA", "", 12, 2, 1000);
    indicator.parameters:addInteger("LN", "Long EMA", "", 26, 2, 1000);
    indicator.parameters:addInteger("IN", "Signal Line", "", 9, 2, 1000);
	
	indicator.parameters:addString("Price", "Price", "", "close");
    indicator.parameters:addStringAlternative("Price", "close", "", "close");
    indicator.parameters:addStringAlternative("Price", "open", "", "open");
    indicator.parameters:addStringAlternative("Price", "high", "", "high");
    indicator.parameters:addStringAlternative("Price", "low", "", "low");
    indicator.parameters:addStringAlternative("Price", "median", "", "median");
    indicator.parameters:addStringAlternative("Price", "typical", "", "typical");
    indicator.parameters:addStringAlternative("Price", "weighted", "", "weighted");
	
	 indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("UpUp", "Up in Up Trend Histogram", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("UpDown", "Down in Up Trend Histogram", "", core.rgb(0, 200, 0));
	indicator.parameters:addColor("DownDown", "Down in Down Trend Histogram", "", core.rgb( 200,0, 0));
	indicator.parameters:addColor("DownUp", "Up in Down  Trend Trend Histogram", "", core.rgb( 255,0, 0));
	
		
	indicator.parameters:addGroup("Alert Style");
    indicator.parameters:addColor("Up", "Up Arrow Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addColor("Down", "Down Arrow Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("Size", "Label Size", "", 10, 1 , 100);
	
	indicator.parameters:addGroup("Alerts Sound");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", true);	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);
	
	indicator.parameters:addGroup("Alerts Email");   
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", true);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);
	indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true);
	 indicator.parameters:addBoolean("ON" , "Show Alert" , "", true);
	
	
	Parameters (1, " Alert ");

 
end


function Parameters ( id, Label )
  
  
   indicator.parameters:addGroup(Label .. " Alert");
  
   

    indicator.parameters:addFile("Up"..id, Label .. " Up Trend Sound", "", "");
    indicator.parameters:setFlag("Up"..id, core.FLAG_SOUND);
	
	indicator.parameters:addFile("Down"..id, Label .. " Down Trend Sound", "", "");
    indicator.parameters:setFlag("Down"..id, core.FLAG_SOUND);
	
	 indicator.parameters:addString("Label"..id, "Label", "", Label);

end 

local 	Number = 1;

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local SN;
local LN;
local IN;
local Price;
local first;
local source = nil;
local Method;
-- Streams block
local MACD = nil;

local UpUp, DownDown, UpDown, DownUp;

local HZU = nil;
local HZL = nil;

local open=nil;
local close=nil;
local high=nil;
local low=nil;


local Up={};
local Down={};
local Label={};
local ON;
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
local FIRST=true;
local U={};
local D={};
local Live;


-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

   
	FIRST=true;
	Live = instance.parameters.Live;
	Show = instance.parameters.Show;
	ON = instance.parameters.ON;
	
    Price = instance.parameters.Price;
	Method = instance.parameters.Method;
    SN = instance.parameters.SN;
    LN = instance.parameters.LN;
    IN = instance.parameters.IN;
	UpUp = instance.parameters.UpUp;
	DownDown = instance.parameters.DownDown;
	UpDown = instance.parameters.UpDown;
	DownUp = instance.parameters.DownUp;
	
	 if (LN <= SN) then
       error("The short EMA period must be smaller than long EMA period");
    end
	
	
    source = instance.source;

   
	MACD = core.indicators:create("MACD",source[Price], SN , LN , IN);
	 first = MACD.SIGNAL:first();
	
  
	open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first)
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first)
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first)
    instance:createCandleGroup("ZONE", "Overlay", open, high, low, close);
     
	
	Initialization();
	
end



function  Initialization ()
     Size=instance.parameters.Size;
	 SendEmail = instance.parameters.SendEmail;
	 
	 local i;
	 for i = 1, Number , 1 do 
	  Label[i]=instance.parameters:getString("Label" .. i);	  
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
	
		 if ON then
		up[i] = instance:createTextOutput ("Alert", "Alert", "Wingdings", Size, core.H_Center, core.V_Center, instance.parameters.Up, 0);
		down[i] = instance:createTextOutput ("Alert", "Alert", "Wingdings", Size, core.H_Center, core.V_Center, instance.parameters.Down, 0);
		 end
	end
		
	

	
end	

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)



    local i;
	for i = 1, Number , 1 do
		  if ON  then
		 down[i]:setNoData (period); 
		 up[i]:setNoData (period);
		 end
   end	  
   
   Calculation (period, mode); 	
end


function  Calculation (period, mode)

 if period < first or not  source:hasData(period) then
       return;
    end
	
	high[period]= source.high[period];
	low[period]= source.low[period];		   
	close[period] = source.close[period];
	open[period]  = source.open[period];	
	
	MACD:update(mode);
	
	 local Shift=0;   

   if Live~= "Live" then	
	Shift=1;
	end
	
	
	if Method== "MACD / Zero & MACD Slope" then
	
	         if  MACD.MACD[period-Shift] > 0
			 and MACD.MACD[period-1-Shift] <= 0  then
			 Activate (1, period-Shift)
			 end
			 
			 
			 
			 if  MACD.MACD[period-Shift] < 0
			 and MACD.MACD[period-1-Shift] >= 0  then
			 Activate (2, period-Shift)
			 end
			 
			 
	
			if MACD.MACD[period] > 0  then
			
			
			 
			 if MACD.MACD[period] > MACD.MACD[period-1] then			 
			 open:setColor(period, UpUp);			 
			 else
			  open:setColor(period, UpDown);
			  
			 end
			else
				
				 if MACD.MACD[period] > MACD.MACD[period-1] then
				 open:setColor(period, DownUp);
				  
				 else
				 open:setColor(period, DownDown);
				 
				 end
			end
	end
	
	
	if Method== "MACD / Signal" then
	
	
	          if   MACD.MACD[period-Shift] > MACD.SIGNAL[period-Shift]
			 and MACD.MACD[period-Shift-1] <= MACD.SIGNAL[period-Shift-1]
			 then
			 Activate (1, period-Shift)
			 end
			 
			  if   MACD.MACD[period-Shift] < MACD.SIGNAL[period-Shift]
			 and MACD.MACD[period-Shift-1] >= MACD.SIGNAL[period-Shift-1]
			 then
			 Activate (2, period-Shift)
			 end
			 	
			if MACD.MACD[period] > MACD.SIGNAL[period] then
			 open:setColor(period, UpUp);			
			else
			 open:setColor(period, DownDown);			 
			end
	end
	
	
	
	if Method== "Histogram/Zero & Histogram Slope" then
	
	         if   MACD.HISTOGRAM[period-Shift] > 0
			 and MACD.HISTOGRAM[period-Shift-1] <= 0 
			 then
			 Activate (1, period-Shift)
			 end
			 
			  if    MACD.HISTOGRAM[period-Shift] < 0
			 and MACD.HISTOGRAM[period-Shift-1] >= 0
			 then
			 Activate (2, period-Shift)
			 end
	
	
			if MACD.HISTOGRAM[period] > 0 then
			
				  if MACD.HISTOGRAM[period] > MACD.HISTOGRAM[period-1] then
				 open:setColor(period, UpUp);
				 else
				 open:setColor(period, UpDown);
				 
				 end
			else
			           
				 if MACD.HISTOGRAM[period] > MACD.HISTOGRAM[period-1] then
				 open:setColor(period, DownUp);
				 
				 else
				 open:setColor(period, DownDown);
				
				 end
			end
	end
	
	if Method== "MACD/Signal & MACD/Zero" then
	
	
	       if   MACD.MACD[period-Shift] > MACD.SIGNAL[period-Shift] 
			 and MACD.MACD[period-Shift-1] <= MACD.SIGNAL[period-Shift-1] 
			 then
			 Activate (1, period-Shift)
			 end
			 
			  if  MACD.MACD[period-Shift] < MACD.SIGNAL[period-Shift] 
			 and MACD.MACD[period-Shift-1] >= MACD.SIGNAL[period-Shift-1] 
			 then
			 Activate (2, period-Shift)
			 end
			 
			 
			 
	
		if MACD.MACD[period] > MACD.SIGNAL[period]  then
		
				if MACD.MACD[period] > 0 then
				  open:setColor(period, UpUp);  
				
				else
					open:setColor(period, UpDown );  	
					
				end
		else    
		   
				if MACD.MACD[period] > 0 then
				
				  open:setColor(period, DownUp);  
				else
					open:setColor(period, DownDown);  	
					
				end  
		
		end
	end 
end



function Activate (flag, period )
local Shift =0;
   if Live~= "Live" then	
	Shift=1;
	end

 if not ON then return; end


local id=1;
 
	  if flag == 1   then
	  
	  
	    up[id]:set(period , source.low[period], "\217");	
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  then
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Up Trend " , period);
							    
							        if Show then
									Pop(Method, " Up Trend " );  	
								    end
								 
							  end
	         			
	      
		    D[id] = nil;	
			
	  end
	  
	  if flag == 2   then
	  
	   down[id]:set(period , source.high[period], "\218");	
	  
	       
		 		   
							  if D[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  then
							  D[id]=source:serial(period);
							  SoundAlert(Down[id]);
							  EmailAlert(  Label[id], " Down Trend " , period);
							    
							        if Show then
									Pop(Method, " Down Trend " ); 
								    end
								 
							  end
	        			
	    
		    U[id] = nil;	
		
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
   
     local text = Note  .. delim ..  Symbol .. delim .. TF .. delim ..Price .. delim .. Time;
 
  terminal:alertEmail(Email, profile:id(), text);
end
	 

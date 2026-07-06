-- Id: 16938
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64046&p=108875#p108875

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
    indicator:name("Overbought/Oversold Indicator");
    indicator:description("Overbought/Oversold Indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    
    local colour = core.colors();
    indicator.parameters:addGroup("OBOS Calculation");
    indicator.parameters:addInteger("OBOSPeriod", "Period", "", 9);
	
	
	 indicator.parameters:addGroup("Channel Calculation"); 
    indicator.parameters:addString("Method", "Method", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Method", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Method", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Method", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Method", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Method", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Method", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Method", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Method", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Method", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Method", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Method", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Method", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Method", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Method", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Method", "JSmooth", "", "JSmooth");
    indicator.parameters:addStringAlternative("Method", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Method", "ARSI", "", "ARSI");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "", "VIDYA");
    indicator.parameters:addStringAlternative("Method", "HPF", "", "HPF");
    indicator.parameters:addStringAlternative("Method", "VAMA", "", "VAMA");


    indicator.parameters:addInteger("Period", "Period", "", 20);
	
	indicator.parameters:addInteger("DeviationPeriod", "Deviation Period", "", 20);
	indicator.parameters:addDouble("DeviationMultiplier", "Deviation Multiplier", "", 2);

	
	indicator.parameters:addGroup("Candle Style");
    indicator.parameters:addColor("UP_color", "Color of UP", "", colour.Lime);
    indicator.parameters:addColor("DN_color", "Color of DOWN", "", colour.Red);
    indicator.parameters:addColor("OBOS_color", "Color of Overbought/Oversold", "", colour.Blue);
	
	indicator.parameters:addGroup("Line Style");
    indicator.parameters:addColor("ZL_color", "Zero line color", "", colour.Yellow);
    indicator.parameters:addColor("MID_color", "Mid line color", "", colour.Gray);

    indicator.parameters:addInteger("widthLinReg", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
	

	
	indicator.parameters:addGroup("Channel Style");
	indicator.parameters:addColor("TLC", "Top Line color", "", core.rgb(0, 200, 0));
	indicator.parameters:addColor("BLC", "Bottom Line Color", "", core.rgb(200, 0, 0));
	indicator.parameters:addColor("CLC", "Central Line Color", "", core.rgb(0, 0, 200));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addString("Live", "End of Turn / Live", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
	indicator.parameters:addStringAlternative("Live", "Live", "", "Live");   

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

	
	Parameters (1, "Top Line");	
	Parameters (2, "Bottom Line");	
	 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries

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
local font;
local ShowAlert;
local Shift=0; 
local Alert={}; 
local AlertLevel={};



-- Parameters block
local OBOSPeriod;

local first;
local iFIRST;

local source = nil;
local AVERAGES, Method, Period;
-- Streams block
local open,low, high, close;
local MA={};
local BUFFER={};
local UP, DOWN;
local Top, Bottom, Central;
local DeviationPeriod, DeviationMultiplier;
local topUp, topDown;
local  bottomUp, bottomDown;
-- Routine
function Prepare(nameOnly)
    OBOSPeriod = instance.parameters.OBOSPeriod;
	Method= instance.parameters.Method;
	Period= instance.parameters.Period;
	DeviationPeriod= instance.parameters.DeviationPeriod;
	DeviationMultiplier= instance.parameters.DeviationMultiplier;
    source = instance.source;
    iFIRST = source:first();
	
	
	OnlyOnceFlag=true;
	FIRST=true;
	OnlyOnce = instance.parameters.OnlyOnce;
	ShowAlert = instance.parameters.ShowAlert;
	Show = instance.parameters.Show;
	Live = instance.parameters.Live;
	UpTrendColor = instance.parameters.UpTrendColor;
	DownTrendColor = instance.parameters.DownTrendColor;
	Size=instance.parameters.Size;
	

    local name = profile:id() .. "(" .. source:name()   .. ")";
    instance:name(name);	
	
    if (not (nameOnly)) then
		BUFFER[1]= instance:addInternalStream(iFIRST, 0);	
		BUFFER[2]= instance:addInternalStream(iFIRST, 0);	
		BUFFER[3]= instance:addInternalStream(iFIRST, 0);		 
		BUFFER[4]= instance:addInternalStream(iFIRST, 0);			   
		BUFFER[5]= instance:addInternalStream(iFIRST, 0);				
		BUFFER[6]= instance:addInternalStream(iFIRST, 0);		 
		
		UP= instance:addInternalStream(iFIRST, 0);
		DOWN= instance:addInternalStream(iFIRST, 0);		  
		
		MA[1] = core.indicators:create("EMA", BUFFER[1],  OBOSPeriod);
		MA[2] = core.indicators:create("EMA", BUFFER[5],  OBOSPeriod);
		MA[3] = core.indicators:create("EMA",  BUFFER[6],  OBOSPeriod);
		MA[4] = core.indicators:create("EMA", UP,  OBOSPeriod);
		first = MA[4].DATA:first();

        open=instance:addStream("open", core.Line, name, "open", core.rgb(128, 128, 128), first);
    open:setPrecision(math.max(2, instance.source:getPrecision()));
		high=instance:addStream("high", core.Line, name, "high", core.rgb(128, 128, 128), first);
    high:setPrecision(math.max(2, instance.source:getPrecision()));
		low=instance:addStream("low", core.Line, name, "low", core.rgb(128, 128, 128), first);
    low:setPrecision(math.max(2, instance.source:getPrecision()));
		close=instance:addStream("close", core.Line, name, "close", core.rgb(128, 128, 128), first);
    close:setPrecision(math.max(2, instance.source:getPrecision()));
		instance:createCandleGroup("OBOS", "", open, high, low, close);
        mid=instance:addStream("MID", core.Line, name.."MID", "MID", instance.parameters.MID_color, first);
    mid:setPrecision(math.max(2, instance.source:getPrecision()));

    
        open:addLevel(0, instance.parameters.styleLinReg, instance.parameters.widthLinReg, instance.parameters.ZL_color);
       
 
		
		assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");
		AVERAGES = core.indicators:create("AVERAGES", mid,  Method,Period);
		
		
		Top=instance:addStream("Top", core.Line, name, "Top", instance.parameters.TLC, math.max(AVERAGES.DATA:first(), first +DeviationPeriod));
    Top:setPrecision(math.max(2, instance.source:getPrecision()));
		Bottom=instance:addStream("Bottom", core.Line, name, "Bottom", instance.parameters.BLC, math.max(AVERAGES.DATA:first(), first +DeviationPeriod));
    Bottom:setPrecision(math.max(2, instance.source:getPrecision()));
		Central=instance:addStream("Central", core.Line, name, "Central", instance.parameters.CLC, math.max(AVERAGES.DATA:first(), first +DeviationPeriod));
    Central:setPrecision(math.max(2, instance.source:getPrecision()));
		
		Top:setWidth(instance.parameters.width);
        Top:setStyle(instance.parameters.style);
		Bottom:setWidth(instance.parameters.width);
        Bottom:setStyle(instance.parameters.style);
		Central:setWidth(instance.parameters.width);
        Central:setStyle(instance.parameters.style);
		
			
		for i= 1, Number , 1 do
			Alert[i]=instance:addInternalStream(0, 0);
			AlertLevel[i]=instance:addInternalStream(0, 0);
		end
		
		Initialization();	
		instance:ownerDrawn(true);	 
		
		topUp = instance:createTextOutput ("topUp", "topUp", "Wingdings", Size, core.H_Center, core.V_Top, UpTrendColor, 0);
		topDown = instance:createTextOutput ("topDown", "topDown", "Wingdings", Size, core.H_Center, core.V_Bottom, DownTrendColor, 0);
		core.host:execute ("attachTextToChart", "topUp");
		core.host:execute ("attachTextToChart", "topDown");
		
		bottomUp = instance:createTextOutput ("bottomUp", "bottomUp", "Wingdings", Size, core.H_Center, core.V_Top, UpTrendColor, 0);
		bottomDown = instance:createTextOutput ("bottomDown", "bottomDown", "Wingdings", Size, core.H_Center, core.V_Bottom, DownTrendColor, 0);
		core.host:execute ("attachTextToChart", "bottomUp");
		core.host:execute ("attachTextToChart", "bottomDown");
	
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


-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)
    if period < iFIRST or not source:hasData(period) then
        return;		
    end
	
    
	BUFFER[1][period]=(source.high[period]+source.low[period]+source.close[period]*2)/4;
	
  	
	MA[1]:update(mode);	
	BUFFER[3][period]= MA[1].DATA[period];
	
	if  period <  iFIRST + OBOSPeriod  then
	return;
	end
	
	BUFFER[4][period] = mathex.stdev (BUFFER[1], period - OBOSPeriod, period);
	
		
	BUFFER[5][period] =  (BUFFER[1][period]  - BUFFER[3][period]) *100  / BUFFER[4][period];

	MA[2]:update(mode);
	BUFFER[6][period]= MA[2].DATA[period] ;

	MA[3]:update(mode);
	UP[period]=MA[3].DATA[period];

	MA[4]:update(mode);
	DOWN[period] =MA[4].DATA[period];
	
	if period < first then
	return;
	end

	open[period] = DOWN[period];
	close[period] = UP[period];
	high[period] = math.max(open[period], close[period]);
    low[period] = math.min(open[period], close[period]);
	
    if low[period-1] < low[period] and high[period]< high[period-1] then
        open:setColor(period, instance.parameters.OBOS_color);
	else
		if UP[period] > DOWN[period] then 
		open:setColor(period, instance.parameters.UP_color);
		else
		open:setColor(period, instance.parameters.DN_color);
		end
	end
	
	mid[period] = (high[period] + low[period])/2;
	
	
   	AVERAGES:update(mode);	
	
	if period < math.max(AVERAGES.DATA:first(), first + DeviationPeriod) then
	return;
	end
	
	local Deviation= mathex.stdev (mid, period-DeviationPeriod+1, period)*DeviationMultiplier;
	
	Central[period]= AVERAGES.DATA[period];	
	Top[period]= Central[period]+Deviation;
    Bottom[period]= Central[period]-Deviation;
	
	
	  if Live~= "Live" then
	period=period-1;
	Shift=1;
	else
	Shift=0;
	end
	
	
	
    Activate (1, period);
    Activate (2, period);
	
end


function Activate (id, period)


   Alert[id][period]=0;
   
    topUp:setNoData(period );
    topDown:setNoData(period );
	bottomUp:setNoData(period );
    bottomDown:setNoData(period );
  
	  if id == 1  and ON[id]  then
	  
	       
			if  mid[period] > Top[period] 
			and   mid[period-1] <= Top[period-1] 
			then
			           
					topUp:set(period , source.high[period ], "\217", source.high[period]);	    
         
                Alert[id][period]= 1;	
 				AlertLevel[id][period]= Top[period] 
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag~= false))
							  then
							  
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Cross Over ", period);
							  SendAlert( Label[id]," Crossed over ", period); 
							  Pop(Label[id], " Cross Over ", period );  
							  OnlyOnceFlag=false;
							  end
							  
			elseif  mid[period] < Top[period] 
			and   mid[period-1] >= Top[period-1] 
            then			
			       	topDown:set(period , source.low[period ], "\218", source.low[period]);	    
			            			 
			                Alert[id][period]= -1;	
							AlertLevel[id][period]= Top[period] 
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag~= false))
							 then							
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " Cross Under ", period);								 
							 Pop(Label[id], " Cross Under ", period );  	
							 SendAlert( Label[id]," Crossed under ", period);
							 OnlyOnceFlag=false;
			                 end			   
	         end
			
	  
	 
	  end
	  
	  
	   if id == 2  and ON[id]  then
	  
	       
			if  mid[period] > Bottom[period] 
			and   mid[period-1] <= Bottom[period-1] 
			then
			           
			  	bottomUp:set(period , source.high[period ], "\217", source.high[period]);	    			                 
         
                Alert[id][period]= 1;	
 				AlertLevel[id][period]= Bottom[period] 
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag~= false))
							  then
							  
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Cross Over ", period);
							  SendAlert( Label[id]," Crossed over ", period); 
							  Pop(Label[id], " Cross Over ", period );  
							  OnlyOnceFlag=false;
							  end
							  
			elseif  mid[period] < Bottom[period] 
			and   mid[period-1] >= Bottom[period-1] 
            then			
			   bottomDown:set(period , source.low[period ], "\218", source.low[period]);	    			      
			            			 
			                Alert[id][period]= -1;	
							AlertLevel[id][period]= Bottom[period] 
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag~= false))
							 then							
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " Cross Under ", period);								 
							 Pop(Label[id], " Cross Under ", period );  	
							 SendAlert( Label[id]," Crossed under ", period);
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

 


function EmailAlert( label , Subject, period)

if not SendEmail then
return
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
	 
	 
	 
	 

function Pop(label , Subject, period)
  
   if not Show then
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
	
   
   core.host:execute ("prompt", 1, label , text );


end


function SendAlert(label ,Subject, period)
    if not ShowAlert then
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
	
 
    terminal:alertMessage(source:instrument(), source[NOW], text, source:date(NOW));
end

 
 
 

-- Id: 13887

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62054

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



--[[
This script gives a score out of 100 in increments of 2.5,
based on the 5 periods entered and the following eight indicator tests:
1.Close>=EMA(x) 
2. RSI(x)>=50 
3. OBV>=OBV[x periods ago]   
4. PVT>=PVT[x periods ago]
5.Percentrank(x)>=50 
6.Lower donchian channel(x period) is rising
7. Accumulation/distribution>=A/D[x periods ago]
8. Volatility stop : Close>=Highest(L3 periods)-n.ATR where n =1,2,3,4,5
..where x equals L1,L2,L3,L4 and L5
]]
-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Weight of Evidence");
    indicator:description("Weight of Evidence");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");	
	
	
	indicator.parameters:addString("Price", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted");	
	
	
	indicator.parameters:addInteger("L1", "1. Length", "Length", 3);
	indicator.parameters:addInteger("L2", "2. Length", "Length", 5);
	indicator.parameters:addInteger("L3", "3. Length", "Length", 10);
	indicator.parameters:addInteger("L4", "4. Length", "Length", 20);
	indicator.parameters:addInteger("L5", "5. Length", "Length", 50);
	
    indicator.parameters:addInteger("Smoothing", "Smoothing", "Smoothing", 3);

	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color1", "Weight of Evidence Line Color", "Weight of Evidence Line Color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color2", "Signal Line Color", "Signal Line Color", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addGroup("Buy/Sell Levels");
	 indicator.parameters:addDouble("OB", "OB level", "OB level", 100);
    indicator.parameters:addDouble("OS", "OS level", "OS level", 0);
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
	
	indicator.parameters:addGroup("Mode");  
	indicator.parameters:addString("Live", "End of Turn / Live", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
	indicator.parameters:addStringAlternative("Live", "Live", "", "Live");   
	
	indicator.parameters:addGroup("Alert Style");
    indicator.parameters:addColor("UpTrendColor", "Up Trend Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addColor("DownTrendColor", "Down Trend Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("Size", "Label Size", "", 10, 1 , 100);
	
	indicator.parameters:addGroup("Alerts Sound");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", true);	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);
	indicator.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
	
	indicator.parameters:addGroup("Alerts Email");   
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", true);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);
	indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true);
	 indicator.parameters:addBoolean("OnlyOnce", "Alert Once", "Subsequent Alert will be ignored.", false);	
	
	Parameters (1, "WoE Signal Cross");
	Parameters (2, "WoE OB Cross");
	Parameters (3, "WoE OS Cross");
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

local 	Number = 3;

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local WoE,Signal,signal;
local first;
local source = nil;
local OB,OS;
local Smoothing;
local L={};
local Price;
local EMA={};
local RSI={};
local PVT;
local OBV;
local ATR; 
local WAD={};
local Min={};
-- Routine


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

function Prepare(nameOnly)

    OnlyOnceFlag=true;
	FIRST=true;
	OnlyOnce = instance.parameters.OnlyOnce;
	ShowAlert = instance.parameters.ShowAlert;
	Show = instance.parameters.Show;
	Live = instance.parameters.Live;
	UpTrendColor = instance.parameters.UpTrendColor;
	DownTrendColor = instance.parameters.DownTrendColor;
	Size=instance.parameters.Size;
	font = core.host:execute("createFont", "Wingdings", Size, false, false);
	
	assert(core.indicators:findIndicator("WAD") ~= nil, "Please, download and install WAD.LUA indicator");  
	
    Smoothing = instance.parameters.Smoothing;
	Price = instance.parameters.Price;
	L[1]= instance.parameters.L1;
	L[2]= instance.parameters.L2;
	L[3]= instance.parameters.L3;
	L[4]= instance.parameters.L4;
	L[5]= instance.parameters.L5;
    OB = instance.parameters.OB;
    OS = instance.parameters.OS;
    source = instance.source;
	 
    first = source:first();
	
	local name = profile:id() .. "(" .. source:name().. ", " .. Price.. ", " .. L[1].. ", " .. L[2].. ", " .. L[3].. ", " .. L[4].. ", " .. L[5].. ", " .. Smoothing.. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	for i=1, 5 ,1 do
	EMA[i]= core.indicators:create("EMA", source[Price], L[i]);
	first=math.max(first, EMA[i].DATA:first());
	RSI[i]= core.indicators:create("RSI", source[Price], L[i]);
	first=math.max(first, RSI[i].DATA:first());
	WAD[i]= core.indicators:create("WAD", source, L[i]);
	first=math.max(first, WAD[i].DATA:first());
	
	Min[i]= instance:addInternalStream(0, 0);
	end
	
	PVT = instance:addInternalStream(0, 0);
	
	OBV= core.indicators:create("OBV", source  );
	first=math.max(first, OBV.DATA:first());
	
	ATR= core.indicators:create("ATR", source, L[3]  );	
	first=math.max(first, ATR.DATA:first());

    

 
        WoE = instance:addStream("WoE", core.Line, name, "WoE", instance.parameters.color1,source:first());
		WoE:addLevel(OB, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	    WoE:addLevel(OS, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
		WoE:setWidth(instance.parameters.width1);
        WoE:setStyle(instance.parameters.style1);
		signal = core.indicators:create("EMA", WoE, Smoothing);
		
		Signal = instance:addStream("Signal", core.Line, name, "Signal", instance.parameters.color2,signal.DATA:first());
		Signal:setWidth(instance.parameters.width2);
        Signal:setStyle(instance.parameters.style2);	
		
		
		WoE:setPrecision(math.max(2, instance.source:getPrecision()));
	    Signal:setPrecision(math.max(2, instance.source:getPrecision()));
   
	
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
function Update(period,mode)

  Calculation(period,mode);
  
      core.host:execute ("removeLabel", source:serial(period)); 
   
     if period < first then
	 return;
	 end
	
    Activate (1, period);
	Activate (2, period);
	Activate (3, period);
	
end

function Calculation(period,mode)
    OBV:update(mode);	
	ATR:update(mode);	
	 
    if period < first then
	return;
	end
	
	 local Total=0;
	
	local max= mathex.max(source.high, period-L[3]+1, period);
	 PVT[period] = ((source.close [period] - source.close [period-1] ) / source.close[period-1]) * source.volume[period] + PVT [period - 1];        
	
	for i=1, 5 ,1 do	
    EMA[i]:update(mode);
		if source[Price][period]>= EMA[i].DATA[period] then
		Total=Total+1;
		end
	RSI[i]:update(mode);	
	    if RSI[i].DATA[period]>= 50 then
		Total=Total+1;
		end
		
	
	    if OBV.DATA[period]>= OBV.DATA[period-L[i]+1] then
		Total=Total+1;
		end	
		
		if source[Price][period]> (max +ATR.DATA[period]*i) then
		Total=Total+1;
		end
		
		 if PVT[period]>= PVT[period-L[i]+1] then
		Total=Total+1;
		end	
		
	    WAD[i]:update(mode);
	    if WAD[i].DATA[period]>= WAD[i].DATA[period-L[i]+1] then
		Total=Total+1;
		end	
		
		if PercentRank( source[Price], L[i],period) >= 50 then
		Total=Total+1;
		end
		
		First , Second= iCalculate(period,i);
		
		if First > Second then
		Total=Total+1;
		end
		
		
	end
	
	
    WoE[period] = 100*Total/40; 
	
	signal:update(mode);
	
	if period < signal.DATA:first() then
	return;
	end
	
	Signal[period]= signal.DATA[period];

end

function iCalculate (Start, i)

local First=0;
local Second=0;

Min[i][Start]= mathex.min(source.low, Start-L[i]+1, Start);

for period= Start, source:first(), -1 do
   
   if Min[i][period]> Min[i][period-1] then
   First = period;
   end
   
   if Min[i][period] < Min[i][period-1] then
   Second = period;
   end
   
   if First~= 0 and Second~= 0 then
   break;
   end

end

return First, Second;

end


function PercentRank( Data, Periods,period) 
 
   local Count = 0; 
   for  i = 1, Periods, 1  do  
	   if  Data[period] >  Data[period-i] then
	   Count = Count+1;
	   end
   end 
   
  return 100 * Count / Periods; 
end 




function ReleaseInstance()
       core.host:execute("deleteFont", font);
end	   

function Activate (id, period)

   local Shift=0;
   

   if Live~= "Live" then
	period=period-1;
	Shift=1;
	end
 
	  if id == 1  and ON[id]  then
	  
	       
			if  WoE[period] > Signal[period] 
			and   WoE[period-1] <= Signal[period-1] 
			then
			           
						    
             core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, Signal[period], core.CR_CHART, core.H_Center, core.V_Bottom, font, UpTrendColor, "\225");

 						 
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  then
							  OnlyOnceFlag=false;
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Cross Over", period);
							  SendAlert("Crossed over");  
							        
									Pop(Label[id], " Cross Over " );  	
								    
								 
							  end
			elseif  WoE[period] < Signal[period] 
			and   WoE[period-1] >= Signal[period-1] 
            then			
			
			            			 
			               core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, Signal[period], core.CR_CHART, core.H_Center, core.V_Top, font, UpTrendColor, "\226");						   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 then
							 OnlyOnceFlag=false;
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " Cross Under", period);	
								 
									Pop(Label[id], " Cross Under " );  	
								    SendAlert("Crossed under");
							 
			                  end			   
	         end
			
	  
	 
	  end
	  
	   if id == 2  and ON[id]  then
	  
	       
			if  WoE[period] > OB
			and   WoE[period-1] <= OB
			then
			           
						    
             core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, OB, core.CR_CHART, core.H_Center, core.V_Bottom, font, UpTrendColor, "\225");

 						 
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  then
							  OnlyOnceFlag=false;
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Cross Over", period);
							  SendAlert("Crossed over");  
							        
									Pop(Label[id], " Cross Over " );  	
								    
								 
							  end
			elseif  WoE[period] < OB
			and   WoE[period-1] >= OB
            then			
			
			            			 
			               core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, OB, core.CR_CHART, core.H_Center, core.V_Top, font, UpTrendColor, "\226");						   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 then
							 OnlyOnceFlag=false;
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " Cross Under", period);	
								 
									Pop(Label[id], " Cross Under " );  	
								    SendAlert("Crossed under");
							 
			                  end			   
	         end
			
	  
	 
	  end
	  
	  
	  
	   if id == 3  and ON[id]  then
	  
	       
			if  WoE[period] > OS
			and   WoE[period-1] <=  OS
			then
			           
						    
             core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART,  OS, core.CR_CHART, core.H_Center, core.V_Bottom, font, UpTrendColor, "\225");

 						 
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  then
							  OnlyOnceFlag=false;
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Cross Over", period);
							  SendAlert("Crossed over");  
							        
									Pop(Label[id], " Cross Over " );  	
								    
								 
							  end
			elseif  WoE[period] <  OS
			and   WoE[period-1] >=  OS
            then			
			
			            			 
			               core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART,  OS, core.CR_CHART, core.H_Center, core.V_Top, font, UpTrendColor, "\226");						   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 then
							 OnlyOnceFlag=false;
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " Cross Under", period);	
								 
									Pop(Label[id], " Cross Under " );  	
								    SendAlert("Crossed under");
							 
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
	 



-- Id: 15959
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59518

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
    indicator:name("Relative Currency Strength with Alert");
    indicator:description("Relative Currency Strength with Alert");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);


	
	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addString("Method", "Method", "Method" , "Pairs");
    indicator.parameters:addStringAlternative("Method", "Pairs", "Pairs" , "Pairs");
    indicator.parameters:addStringAlternative("Method", "Index", "Index" , "Index");
	indicator.parameters:addBoolean("LabelShow" , "Shown Labels", "", true);	 
 
	
    indicator.parameters:addInteger("Period", "Period", "Period", 24);
	indicator.parameters:addString("TF", "Time frame", "", "D1");
    indicator.parameters:setFlag("TF", core.FLAG_PERIODS);
	
	
	
	local i;
	local Coloring={core.rgb(255, 0, 0),core.rgb(0,255, 0), core.rgb(0, 0, 100),core.rgb(0 , 0, 0), core.rgb(128, 128, 128), core.rgb(255, 128, 0) , core.rgb(128, 255, 0) , core.rgb( 0, 128, 255), core.rgb(0, 255, 128), core.rgb(255, 0, 128) };
    local Pairs={"EUR/USD","GBP/USD","USD/JPY","AUD/USD","EUR/GBP","EUR/JPY","EUR/AUD",	"GBP/JPY","GBP/CHF","AUD/JPY"};
	local Indexes={"USD","EUR","JPY","GBP","AUD"};
	
	indicator.parameters:addGroup("Pairs Style");
	 for i = 1 , 10, 1 do
	 AddPairs(i, Pairs[i], Coloring[i]);
	 end
	 
	 
	 indicator.parameters:addGroup("Indexes Style");
	 for i = 1 , 5, 1 do	 
	 AddIndexes(i, Indexes[i], Coloring[i])
	end
	
	 indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 0);
    indicator.parameters:addDouble("oversold","Oversold Level","", 0);
	indicator.parameters:addDouble("custom","Custom Level","", 0);
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
	
	indicator.parameters:addGroup("Alert Parameters");  
	indicator.parameters:addString("Live", "End of Turn / Live", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
	indicator.parameters:addStringAlternative("Live", "Live", "", "Live");   

	indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true);
	indicator.parameters:addBoolean("OnlyOnce", "Alert Once", "Subsequent Alert will be ignored.", false);	
	indicator.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
	
	
	indicator.parameters:addGroup("Alerts Sound");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", true);	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);

	
	indicator.parameters:addGroup("Alerts Email");   
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", true);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);

	
	Parameters (1, "OB Cross");	
	Parameters (2, "OS Cross");	
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


function AddPairs(id, Pair, Color)

    indicator.parameters:addBoolean("pOn"..id , "Shown ".. Pair, "", true);	 
    indicator.parameters:addColor("pColor".. id, Pair .. " Line Color", "", Color);
end 

function AddIndexes(id, Pair, Color)
 indicator.parameters:addBoolean("iOn"..id , "Shown ".. Pair, "", true);	 
    indicator.parameters:addColor("iColor".. id, Pair .. " Line Color", "", Color);
end 

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries

local 	Number = 2;
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
local Shift=0; 

-- Parameters block
local Period;
	local Pairs={"EUR/USD","GBP/USD","USD/JPY","AUD/USD","EUR/GBP","EUR/JPY","EUR/AUD",	"GBP/JPY","GBP/CHF","AUD/JPY"};
	local Indexes={"USD","EUR","JPY","GBP","AUD"};
local first;
local source = nil;
local Coloring={core.rgb(255, 0, 0),core.rgb(0,255, 0), core.rgb(0, 0, 100),core.rgb(0 , 0, 0), core.rgb(128, 128, 128), core.rgb(255, 128, 0) , core.rgb(128, 255, 0) , core.rgb( 0, 128, 255), core.rgb(0, 255, 128), core.rgb(255, 0, 128) };
-- Streams block
local Index = {};
local Pair={};
local Method;
local offset,weekoffset;
local SourceData={};
local  TF;
local host; 
local loading={};
local Last,last;
local p1={};
local p2={};
local iLabel;
local pColor={};
local iColor={};
local iOn={};
local pOn={};
local Raw={};
local max;
local Type;
local pauto =  "(%a%a%a)/(%a%a%a)";
local db;
local name;
local LabelShow;
local pattern = "([^;]*);([^;]*)";
local oversold, overbought;
function Parse(message)
    local level, date;
    level, date = string.match(message, pattern, 0);
	

    if  date == nil then
        return  0;
     end
	
    return tonumber(date),tonumber(level) ;
end

 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	
    Period = instance.parameters.Period; 
	Method= instance.parameters.Method;	
	TF= instance.parameters.TF;
    source = instance.source;
    first = source:first();
	LabelShow= instance.parameters.LabelShow;
    
	
	overbought= instance.parameters.overbought;
	oversold= instance.parameters.oversold; 
	
	OnlyOnceFlag=true;
	FIRST=true;
	OnlyOnce = instance.parameters.OnlyOnce;
	ShowAlert = instance.parameters.ShowAlert;
	Show = instance.parameters.Show;
	Live = instance.parameters.Live;
		
	
	require("storagedb");
    db = storagedb.get_db(name);
	
	host=core.host;	
	offset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");	

	
	local i, C, xOn;
	for  i = 1, 10, 1 do
    Raw[i]=	instance:addInternalStream(0, 0);
    pColor[i]= instance.parameters:getDouble("pColor" .. i);
	pOn[i]= instance.parameters:getBoolean("pOn" .. i);
		if i <= 5 then
		iColor[i]= instance.parameters:getDouble("iColor" .. i);
		iOn[i]= instance.parameters:getBoolean("iOn" .. i);
		end
	 
	 
	 
	 local Flag =  FindInstrument(Pairs[i]);	
			 
			
			assert(   Flag , "Please Subscribe to " .. Pairs[i] ) ;
			
			if not Flag then
			error( "Please Subscribe to " .. Pairs[i]);
			end
			
			if  Flag then	 				
			SourceData[i] = core.host:execute("getSyncHistory",Pairs[i], TF, source:isBid(), Period, 200+i, 100+i);
			loading[i]=true;
			  
			end
	 
	end

    if (not (nameOnly)) then
	 if Method == "Index" then
	 max= 5;
	 iLabel=Indexes;
	 C=iColor;
	 xOn=iOn;
	 else
	 max= 10;
	 iLabel=Pairs;
	 C=pColor;
	 xOn=pOn;
	 end
	 
	 --local Off=true;
	 
	    for i = 1, max , 1 do
		
			if xOn[i] then
			Pair[i] = instance:addStream("Pair".. i, core.Line, name,  iLabel[i], C[i], first);
    Pair[i]:setPrecision(math.max(2, instance.source:getPrecision()));
		    	--if Off then			
				Pair[i]:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
				Pair[i]:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);  			
				Pair[i]:addLevel(0, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
				Pair[i]:addLevel(instance.parameters.custom, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
				--Off = false;
				--end
			else
			Pair[i]= instance:addInternalStream(0, 0);
			end
		end
    end
	
	
	
	core.host:execute("addCommand",1111, "Set Start", "");	
	core.host:execute("addCommand",2222, "Reset", "");	
    core.host:execute ("setTimer",1,  5);
	 
    AlertInitialization();
end


function  AlertInitialization ()
    
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
	for i = 1, max , 1 do
		
		U[i]={}
		D[i]={}
		
		   for j = 1, Number , 1 do 
			U[i][j] = nil;
			D[i][j] = nil;	 
			end
	end	
	
		 
end	


 
function FindInstrument(Instrument)
  
   
    local row, enum;   
	local Flag= false;
   
    enum = core.host:findTable("offers"):enumerator();
    row = enum:next();
    while row ~= nil do
       
        if Instrument == row.Instrument then
		Flag= true;
		break;
		end
         row = enum:next(); 
    end

    return Flag;
end

local Mark;
-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)

if period < source:size()-1 then
return;
end


	local Flag = false;
	
	for i = 1, 28 , 1 do
		if loading[i] then
		Flag = true;
		end
	end
	
	if Flag then
	return;
	end
	
	
    local k;
         for k = first, source:size()-1, 1 do
		 Calculate(k); 
		 end
		 
	  
			if LabelShow then
			   for i = 1, max , 1 do
					core.host:execute ("drawLabel", i, source:date(source:size()-1), Pair[i][period], iLabel[i]) ;
			   end	   
			end
         
  
	if period < source:size()-1 then
    return;
    end
	
	if Live~= "Live" then
	period=period-1;
	Shift=1;
	else
	Shift=0;
	end
		 
		 
	
    for i=1, max, 1 do
    Activate (1, i, period);
    Activate (2, i , period);
	end
end



function Activate (id, i, period)

  
	  if id == 1  and ON[id]  then
	  
	       
			if  Pair[i][period] > overbought 
			and   Pair[i][period-1] <= overbought 
			then 
						   
			
			 D[i][id] = nil;
						   
							  if U[i][id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  then
							  OnlyOnceFlag=false;
							  U[i][id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Cross Over", period,i);
							  SendAlert("Crossed over");  
							        
									Pop(Label[id], " Cross Over ",i );  	
								    
								 
							  end
			elseif  Pair[i][period] < overbought 
			and   Pair[i][period-1]>= overbought 
            then			
			 
						   
		     U[i][id] = nil;
		   
			                 if  D[i][id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 then
							 OnlyOnceFlag=false;
							 D[i][id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " Cross Under", period,i);	
								 
									Pop(Label[id], " Cross Under ",i );  	
								    SendAlert("Crossed under");
							 
			                  end			   
	         end
			
	  
	 
	  end
	  
	    if id == 2  and ON[id]  then
	  
	       
			if  Pair[i][period] > oversold 
			and   Pair[i][period-1] <= oversold 
			then 
						   
			
			 D[i][id] = nil;
						   
							  if U[i][id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  then
							  OnlyOnceFlag=false;
							  U[i][id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Cross Over", period,i);
							  SendAlert("Crossed over");  
							        
									Pop(Label[id], " Cross Over ",i );  	
								    
								 
							  end
			elseif  Pair[i][period ] < oversold 
			and   Pair[i][period-1] >= oversold
            then			
			 
						   
		     U[i][id] = nil;
		   
			                 if  D[i][id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 then
							 OnlyOnceFlag=false;
							 D[i][id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " Cross Under", period,i);	
								 
									Pop(Label[id], " Cross Under ",i );  	
								    SendAlert("Crossed under" );
							 
			                  end			   
	         end
			
	  
	 
	  end
	  

	  
        if FIRST then
        FIRST=false;      
        end		

end


function AsyncOperationFinished (cookie, success, message)
end

--iLabel
function Pop(label , note,i)
  
   if not Show then
   return;
   end
   local InstrumentLabel =  " Instrument : " .. iLabel[i]; 
   core.host:execute ("prompt", 1, label ,   " ( " ..  InstrumentLabel  .. ", "  ..source:barSize() .. " ) "  ..   label .. " : " .. note );
 

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

 


function EmailAlert( label , Subject, period,i)

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
   local Time =  " Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec;  
   local InstrumentLabel =  " Instrument : " .. iLabel[i];
 
   
    
    local TF= "Time Frame : " .. source:barSize();       
    local text = Note .. delim .. InstrumentLabel  .. delim .. TF  .. delim .. Time;
 
	
 
   terminal:alertEmail(Email, profile:id(), text);
end
	 




function  Calculate(period)

local Date;
      Date=tonumber(db:get ("Date1", 0));
	 
	local i; 
	 local Flag = false;
	 
	 for i = 1, 10 , 1 do
	   if loading[i] then		
		Flag=true;
		end	 
	 end
	 	 
	 if Flag then 
	 return;
	 end
	  
   local p;
   local Candle;

							 
	for i = 1, 10 , 1 do	
	
         p =Initialization(period,i);
	
			if p~= false then		
					
					 if Date== 0 then
					 Candle = core.getcandle(source:barSize(), source:date(source:size()-1 -Period), offset, weekoffset);
					 p1[i]= core.findDate(SourceData[i], Candle, false);
					 p2[i]=  p;			 
					 else
					 
					 
					 p2[i]=  p;	
							 Candle = core.getcandle(source:barSize(), Date, offset, weekoffset);
							 p1[i]= core.findDate(SourceData[i], Candle, false);
							
					 end
			
				 
				
				Raw[i][period] = ( SourceData[i].close[p2[i]]-SourceData[i].close[p1[i]]) /(SourceData[i].close[p1[i]]/100);
				
				end 	 
	end
	
	
	for i = 1, max , 1 do
	
		 
			if Method == "Pairs" then
			 Pair[i][period]= Raw[i][period];
			 else
			 Pair[i][period]= CalculateIndex( i , period);
			 end
		 	 
		 
    end

end

function CalculateIndex(i, period)

local crncy1, crncy2, j ;
local iCount=0;
local iSum=0;
	for j = 1 , 10 , 1 do 
	crncy1, crncy2 = string.match(Pairs[j], pauto);

		if crncy1== Indexes[i] then
		iCount=iCount+1;
		iSum=iSum+Raw[j][period];
		end

		if crncy2== Indexes[i] then
		iSum=iSum-Raw[j][period];
		iCount=iCount+1;
		end

	end

 

return iSum/iCount;

end

function   Initialization(period,id)

    local Candle;
    Candle = core.getcandle(source:barSize(), source:date(period), offset, weekoffset);
  
    if loading[id] or SourceData[id]:size() == 0  then
        return false;
    end

    
    if period < source:first() then
        return false;
    end

    local P = core.findDate(SourceData[id], Candle, false);
	 

    -- candle is not found
    if P < 0    then
        return false;
	else return P;	
    end
			
end	


function AsyncOperationFinished(cookie, success, message)
	 
     local j;	 
	local Flag = false;	
	local Count=0;	
	
    for j = 1, 10, 1 do
		
			  if cookie == (100 +j) then
			  loading[j] = true;
		      elseif  cookie == (200+j) then
			  loading[j] = false;	              		 
              end
			  
		if loading[j] then
		Count=Count+1;
		Flag=true;
		end	 

		  
	
	end    
	
	
	 
	  local date,k; 
		
	
	 if cookie ==1111 then	  
     date  = Parse(message); 	    
	  db:put("Date1", tostring(date));	
	  
		--for k = first, source:size()-1, 1 do
		-- Calculate(k); 
		-- end
	  
	 elseif cookie == 2222 then
	 db:put("Date1", tostring(0));
	    -- for k = first, source:size()-1, 1 do
		-- Calculate(k); 
		-- end
     end    
	 
	 
	 if cookie== 1 and not Flag then
	   for k = first, source:size()-1, 1 do
		  Calculate(k); 
		  end
	 end
	 
	 
	 	if Flag then
		core.host:execute ("setStatus", " Loading ".. (10-Count) .."/" .. 10);
		else
		core.host:execute ("setStatus","Loaded");		
		instance:updateFrom(0)
		end
			  
   
        
		return core.ASYNC_REDRAW ;
end

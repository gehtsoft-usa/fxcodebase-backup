-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=15690

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
    indicator:name("Line Cross Alert");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
	
	indicator.parameters:addBoolean("startof", "Extend start" , "", false);
    indicator.parameters:addBoolean("endof", "Extend end" , "", false);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up", "Up Cross Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Cross Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("Size", "Label Size", "", 10, 1 , 100);
	
	indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addGroup("Alerts");
	indicator.parameters:addBoolean("live_alert", "Live alert", "", true);
    indicator.parameters:addString("TF", "Time frame", "", "m5");
    indicator.parameters:setFlag("TF", core.FLAG_PERIODS);
	indicator.parameters:addBoolean("PlaySound", "Play Sound", "", false);
    indicator.parameters:addFile("SoundFile", "Sound File", "", "");
    indicator.parameters:setFlag("SoundFile", core.FLAG_SOUND);
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);
	
	indicator.parameters:addGroup("Email");   
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", false);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;
local Line;
local db;
local START, END;
local up, down;
local Size;
local Email;
local SendEmail;
local PlaySound, RecurrentSound ,SoundFile  ;
local Crossover, Crossunder;
local Alert;
local live_alerts;
local timeframe;

-- Routine
 function Prepare(nameOnly)    
    source = instance.source;
    first = source:first();
	START=instance.parameters.startof;
	END=instance.parameters.endof;
	Size=instance.parameters.Size;
	
	
	 local name = string.format("%s %s ", profile:id(), source:name() );
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	SendEmail = instance.parameters.SendEmail;

    if SendEmail then
        Email = instance.parameters.Email;
    else
        Email = nil;
    end
    assert(not(SendEmail) or (SendEmail and Email ~= ""), "E-mail address must be specified");
		
	PlaySound = instance.parameters.PlaySound;
    if PlaySound then
        SoundFile = instance.parameters.SoundFile;
    else
        SoundFile = nil;
    end
    assert(not(PlaySound) or (PlaySound and SoundFile ~= ""), "Sound file must be chosen"); 
    RecurrentSound = instance.parameters.RecurrentSound;
	
	Crossover=nil;
	Crossunder=nil;
	timeframe = "Live";
	if not instance.parameters.live_alert then
		timeframe = instance.parameters.TF;
		target_source = core.host:execute("getSyncHistory", source:instrument(), timeframe, source:isBid(), 0, 100, 101);
	end
 
	
	require("storagedb");
	db = storagedb.get_db(source:name());
	
	up = instance:createTextOutput ("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Center, instance.parameters.Up, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", Size, core.H_Center, core.V_Center, instance.parameters.Down, 0);
   	
	core.host:execute("addCommand", 1001, "First", "");
    core.host:execute("addCommand", 1002, "Second", "");
    core.host:execute("addCommand", 1003, "Reset", "");	
  
	Line=instance:addStream("Line", core.Line, name, "Line", instance.parameters.color, first);
	Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
end

local LAST;
-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period) 
	if period<source:size()-1 then
		return;
	end

  	local DateOne=nil;
	local LevelOne=nil;
	local DateTwo=nil;
	local LevelTwo=nil;
  
    DateOne=db:get ("FirstDate", 0);
	LevelOne=tonumber(db:get ("FirstLevel", 0));
	DateTwo=db:get ("SecondDate", 0);
	LevelTwo=tonumber(db:get ("SecondLevel", 0));
	
	if DateOne~= nil and  DateOne~= 0 and DateTwo~= nil and  DateTwo~= 0  and (DateOne ~= DateTwo and LevelOne~= LevelTwo ) and  LevelTwo~= 0 and  LevelOne~= 0 then
		local First= core.findDate (source, DateOne, false)
		local Second= core.findDate (source, DateTwo, false)
		if First  >= first and Second  >= first then
			core.drawLine(Line, core.range(First, Second), LevelOne, First, LevelTwo, Second); 
		end	 
		
		local a,b =  getline(First, LevelOne, Second, LevelTwo);
		local LevelFirst = a * 1 + b;
		local LevelEnd = a * (source:size()-1) + b;
		local Tu= math.min(First, Second) ;
		local Tam= math.max(First, Second);
		local Tul, Taml;
		
		if Tu == First then
			Tul =LevelOne;
			Taml = LevelTwo;
		else
			Taml =LevelOne;
			Tul= LevelTwo;
		end 
	 
	  	local i;
	  	if not END then 
		   	for i= Tam,source:size()-1, 1  do
		   		Line[i] =nil;
		    	up:setNoData (i);
				down:setNoData (i);
		   	end
	  	else
		  	if Tam < source:size()-1 and  Tam > first then
		  		core.drawLine(Line, core.range( Tam, source:size()-1), Taml, Tam, LevelEnd, source:size()-1); 
		  	end
      	end
   
		if not START then 
			for i= Tu ,first, -1  do
		   		Line[i] =nil;
		    	up:setNoData (i);
				down:setNoData (i);
		   	end 
       	else
			if Tu < source:size()-1 and  Tu > first then
		   		core.drawLine(Line, core.range(first, Tu), LevelFirst, first, Tul, Tu); 
			end
	   	end
   	end	  
   
    local j;
	for j = first+1, source:size()-1 do
		if Line:hasData(j) and  Line:hasData(j-1) then
			if 	core.crossesOver(source, Line ,j)	then
				up:set(j , Line[j], "\108");	
				down:setNoData (j); 	  
			elseif 	core.crossesUnder(source, Line,j)	then	
				down:set(j , Line[j], "\108");
				up:setNoData (j);						    
			else
				up:setNoData (j); 	
				down:setNoData (j);						 
			end	
		end
	end

	if period < source:size()-1 then
		return;
	end
	local current_period, prev_period = GetPeriods(period);
	if current_period ~= nil then
		CheckForAlerts(current_period, prev_period);
	end
end

local last_serial = nil;
function GetPeriods(period)
	if target_source == nil then
		return period, period - 1;
	end
	if target_source:size() < 2 then
		return nil, nil;
	end
	local serial = target_source:serial(NOW);
	if last_serial ~= serial then
		last_serial = serial;
		local s, e = core.getcandle(timeframe, target_source:date(NOW - 1), core.host:execute("getTradingDayOffset"), core.host:execute("getTradingWeekOffset"));
		local index = core.findDate(source, s, false);
		if index == -1 then
			return nil, nil;
		end
		return period, index;
	end
	return nil, nil;
end

function CheckForAlerts(period, prev_period)
	if source[period] > Line[period] and source[prev_period] < Line[prev_period] then
		Crossunder = nil;
		if Crossover ~= source:date(period) then
			Crossover = source:date(period);
			SoundAlert();
			EmailAlert("Cross Over");
		end
	end

	if source[period] < Line[period] and source[prev_period] > Line[prev_period] then			
		Crossover = nil;
		if Crossunder ~= source:date(period) then
			Crossunder = source:date(period);
			SoundAlert();			 
			EmailAlert("Cross Under");								   
		end			   
	end
end

local pattern = "([^;]*);([^;]*)";

function Parse(message)
    local level, date;
    level, date = string.match(message, pattern, 0);
	
    if level == nil or date == nil then
        return nil, nil;
    end
	
    return tonumber(date),tonumber(level) ;
end

function AsyncOperationFinished(cookie, success, message)

	local DateOne=nil;
	local LevelOne=nil;
	local DateTwo=nil;
	local  LevelTwo=nil;

    if cookie == 1001 then
         DateOne, LevelOne  = Parse(message);		 
		
		 db:put("FirstDate"  , tostring(DateOne));
		 db:put("FirstLevel", tostring(LevelOne));    
		 
		 for i= first, source:size()-1, 1  do
		   Line[i] =nil;
		    up:setNoData (i);
			down:setNoData (i);
		   end
    
    elseif cookie == 1002 then      
	
        DateTwo, LevelTwo  = Parse(message);  
		db:put("SecondDate", tostring(DateTwo));
		db:put("SecondLevel", tostring(LevelTwo)); 

         for i= first, source:size()-1, 1  do
		   Line[i] =nil;
		    up:setNoData (i);
			down:setNoData (i);
		   end		
	
	elseif cookie == 1003 then
    	   db:put("FirstDate"  , tostring(0));
		  db:put("FirstLevel", tostring(0));
           db:put("SecondDate", tostring(0));
	    	db:put("SecondLevel", tostring(0));
    
        for i= first, source:size()-1, 1  do
		   Line[i] =nil;
		    up:setNoData (i);
			down:setNoData (i);
		   end
		   
	end	
	
	DateOne=db:get ("FirstDate", 0);
	  LevelOne=tonumber(db:get ("FirstLevel", 0));
	  DateTwo=db:get ("SecondDate", 0);
	  LevelTwo=tonumber(db:get ("SecondLevel", 0));
	  
	  
	  if DateOne== DateTwo 
	  or LevelOne== LevelTwo
	  then
	  
	          db:put("FirstDate"  , tostring(0));
				  db:put("FirstLevel", tostring(0));
				   db:put("SecondDate", tostring(0));
					db:put("SecondLevel", tostring(0));
	
	end
	if DateOne~= nil and  DateOne~= 0 and DateTwo~= nil and  DateTwo~= 0  and (DateOne ~= DateTwo or LevelOne~= LevelTwo ) and  LevelTwo~= 0 and  LevelOne~= 0 then
	local First= core.findDate (source, DateOne, false)
	local Second= core.findDate (source, DateTwo, false)
     core.drawLine(Line, core.range(First, Second), LevelOne, First, LevelTwo, Second);  

   	 
	  local a,b =  getline(First, LevelOne, Second, LevelTwo);
	local LevelFirst = a * 1 + b;
    local LevelEnd = a * (source:size()-1) + b;
	 
	 
	local Tu= math.min(First, Second) ;
	local Tam= math.max(First, Second);
	local Tul, Taml;
	
	
	if Tu == First then
	 Tul =LevelOne;
	 Taml = LevelTwo;
	else
	 Taml =LevelOne;
	  Tul= LevelTwo;
	end 
	
	
	 
	  local i;
	  if not END then 
		   for i= Tam,source:size()-1, 1  do
		   Line[i] =nil;
		    up:setNoData (i);
			down:setNoData (i);
		   end
	  else
		  if Tam < source:size()-1 and  Tam > first then
		  core.drawLine(Line, core.range( Tam, source:size()-1), Taml, Tam, LevelEnd, source:size()-1); 
		  end
      end
   
		if not START then 
			for i= Tu ,first, -1  do
		   Line[i] =nil;
		    up:setNoData (i);
			down:setNoData (i);
		   end 
       else
			if Tu < source:size()-1 and  Tu > first then
		   core.drawLine(Line, core.range(first, Tu), LevelFirst, first, Tul, Tu); 
			end
	   end
   end	  
  					 
	
end


     -- get line equation coefficients
function getline(x1, y1, x2, y2)
    local a, b;

    a = ((y2 - y1) / (x2 - x1));
    b = (y1 - a * x1);
    return a, b;
end
 
function SoundAlert()
 
 
 if not PlaySound then
 return;
 end
 
 
 terminal:alertSound(SoundFile, RecurrentSound);
end

function EmailAlert( Subject)

if not SendEmail then
return
end

  
    local date = source:date(NOW);
	local DATA = core.dateToTable (date);
	
    local LABEL =  DATA.month..", ".. DATA.day ..", ".. DATA.hour  ..", ".. DATA.min ..", ".. DATA.sec;
 

  local text= profile:id() .. "(" .. source:instrument() .. ")" .. source[NOW]..", " .. Subject..", " .. LABEL ;
  terminal:alertEmail(Email, Subject, text);
end
	 


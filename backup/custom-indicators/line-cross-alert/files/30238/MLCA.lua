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
    indicator:name("Multiple Line Cross Alert");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
	
	
		indicator.parameters:addBoolean("startof", "Extend start" , "", false);
    indicator.parameters:addBoolean("endof", "Extend end" , "", false);
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addInteger("Size", "Label Size", "", 10, 1 , 100);
	 indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
	  indicator.parameters:addColor("selected", "Selected Line Color", "", core.rgb(0, 0, 255));
	   indicator.parameters:addColor("undefined", "Undefined Line Color", "", core.rgb(0, 0, 0));
	indicator.parameters:addInteger("width", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addGroup("Alerts");   
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
local db;
local Size;
local pattern = "([^;]*);([^;]*)";
local Index={};
local Count;
local Line={};
local name; 
local font;
local START, END;
local Last;
local Email;
local SendEmail;
local PlaySound, RecurrentSound ,SoundFile  ;
local Alert;

local Crossover={};
local Crossunder={};	
-- Routine
 function Prepare(nameOnly)    
    source = instance.source;
    first = source:first();
	
	
	 name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	Size=instance.parameters.Size;
	
	
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
	
	
	
	START = instance.parameters.startof;
	END = instance.parameters.endof;
	
	
	
	require("storagedb");
	db = storagedb.get_db( source:name() );
	
	 font = core.host:execute("createFont", "Arial", Size, true, false);
  
  
	core.host:execute("addCommand", 10, "New", "");	
	core.host:execute("addCommand", 11, "Next", "");
    core.host:execute("addCommand", 12, "Previous", "");
    core.host:execute("addCommand", 13, "Delete", "");	
    core.host:execute("addCommand", 14, "Reset", "");	
    core.host:execute("addCommand", 15, "Line Start", "");	
	core.host:execute("addCommand", 16, "Line End", "");	
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode) 

if period<source:size()-1 then
return;
end

core.host:execute ("removeAll")




  local Count =db:get ("Count", 0);   
  local Cursor =tonumber(db:get ("Cursor", 0));   
 
  if 	Count~= 0 then
		for i = 1, Count, 1 do
		
		     local DateOne = tonumber(db:get(tostring ("DateOne".. i)  , 0));					 
		       local LevelOne = tonumber(db:get(tostring ("LevelOne".. i)  , 0));
                local DateTwo = tonumber(db:get(tostring ("DateTwo".. i ) , 0));					 
		       local LevelTwo = tonumber(db:get(tostring ("LevelTwo".. i)  , 0));	
		
		    local color;
			if DateOne== 0 or DateTwo == 0 then
			 color= instance.parameters.undefined;
			elseif i == Cursor then
			 color= instance.parameters.selected;
			else
			 color =  instance.parameters.color;   
			end
			
			if Last ~= source:serial(period) then
			Last = source:serial(period);
				local j;
				for j = 1, Count, 1 do
				Crossunder[j] = nil;
				Crossover[j] = nil;
				end
			end
		
			
			 local Text= tostring(i);
					core.host:execute("drawLabel1", i,-i*20, core.CR_RIGHT,50, core.CR_TOP, core.H_Left, core.V_Center,
						font,  color,  Text);
						
			 	 if  DateOne~=0 and DateTwo ~= 0 and  LevelOne~=0 and LevelTwo ~= 0 then
				 
						  local First= core.findDate (source, DateOne, true)
						local Second= core.findDate (source, DateTwo, true)
										 
						local a,b;
						a, b =  getline(First, LevelOne, Second, LevelTwo);
						
						if START then
						LevelOne = a * 1 + b;
						DateOne = source:date(1);
						end
						if END then
						LevelTwo= a * (source:size()-1) + b;	
						DateTwo = source:date(source:size()-1);				
						end  
						
						 core.host:execute("drawLine", 100+i, DateOne, LevelOne, DateTwo, LevelTwo, color);
						 
						  if a ~= nil and b~= nil then
			  
			           if 	source[period] >  a *  ((source:size()-1) + b)
						and source[period-1] < a * ((source:size()-2) + b)
						then
						
						Crossunder[i] = nil;
									   
										  if Crossover[i]~=source:date(period) then
										 Crossover[i]=source:date(period);
										 SoundAlert();
										 EmailAlert( "Cross Over");
										 end
						elseif	source[period] < ( a * (source:size()-1) + b)
						and source[period-1] >  (a * (source:size()-2) + b)
						then			
						 Crossover[i] = nil;
					   
										 if  Crossunder[i]~=source:date(period) then
										 Crossunder[i]=source:date(period);
										 SoundAlert();			 
										 EmailAlert( "Cross Under");								   
											 end			   
						 end
				end		 
			 
			    end
						
			
			 
		end
  end		
  	    
end

function Parse(message)
    local level, date;
    level, date = string.match(message, pattern, 0);
	
    if level == nil or date == nil then
        return nil, nil;
    end
	
    return tonumber(date),tonumber(level) ;
end

function ReleaseInstance()
       core.host:execute("deleteFont", font);
       
end



function AsyncOperationFinished(cookie, success, message)

   
   local Date
   local Level
   Date, Level  = Parse(message);		
   
   if cookie == 10 then
			 local  Count = tonumber( db:get ("Count", 0));
			 local  Count = tonumber( db:get ("Count", 0));
			   db:put("Count"  , tostring(Count+1));			   			 
				db:put("Cursor"  , tostring(Count+1));
   elseif cookie == 13 then
		   		   
			 local Cursor =  tonumber( db:get ("Cursor", 0));			   
			 Delete(Cursor);
		   
	elseif cookie == 11 then
 
              local Cursor =  tonumber( db:get ("Cursor", 0));	
              local Count = tonumber( db:get ("Count", 0)); 
			   Cursor=Cursor+1;
			  if Cursor  > Count then
			  Cursor = Count;
			  end
			  
			  db:put("Cursor"  , tostring(Cursor));
   
   elseif cookie == 12 then
   
              local Cursor =  tonumber( db:get ("Cursor", 0));	
			  Cursor=Cursor-1;
              if Cursor  < 1 then
			  Cursor = 1;
			  end
			  
			  			  
			  db:put("Cursor"  , tostring(Cursor));
	elseif cookie == 14 then
               local Count = tonumber( db:get ("Count", 0));
			   local Cursor =  tonumber( db:get ("Cursor", 0));
			   
			   local i;
			   for i = 1, Count , 1 do
			    Delete(i);
			   end	
			  
			  
			-- db:put("Cursor"  , tostring(Count));				  
		    db:put("Count"  , tostring(0));					 
			db:put("Cursor"  , tostring(0));	
			  
   Cursor= Cursor-1
   
   elseif cookie == 15 then
	   local Cursor =  tonumber( db:get ("Cursor", 0));	
		 db:put(tostring ("DateOne".. Cursor)  , tostring(Date));					 
		 db:put(tostring ("LevelOne".. Cursor)  , tostring(Level));
   elseif cookie == 16 then 
	   local Cursor =  tonumber( db:get ("Cursor", 0));	
		 db:put(tostring ("DateTwo".. Cursor)  , tostring(Date));					 
		 db:put(tostring ("LevelTwo".. Cursor)  , tostring(Level));
   end
   
   
   if cookie == 10 or cookie==13 	or cookie==11 or cookie==12  or cookie==14 or cookie==15 or cookie==16 then
	instance:updateFrom(source:size()-1);     
  	return core.ASYNC_REDRAW ;		 
	end

-- table.remove(a, 1)
--table.insert(a, line)
-- 
	
end

function Delete (Cursor)

              db:put(tostring ("DateOne".. Cursor)  , tostring(0));	
			    db:put(tostring ("LevelOne".. Cursor)  , tostring(0));	
				
              db:put(tostring ("DateTwo".. Cursor)  , tostring(0));				 
              db:put(tostring ("LevelTwo".. Cursor)  , tostring(0));
end


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
	 

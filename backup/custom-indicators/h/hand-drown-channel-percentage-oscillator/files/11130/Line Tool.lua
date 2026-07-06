-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=4511

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
    indicator:name("Line Tool");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addBoolean("ExtendEnd" ,  "Extend Line End " , "" , true);	
	indicator.parameters:addBoolean("ExtendBeginning" ,  "Extend Line Beginning " , "" , false);
    indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local first;
local source = nil;

-- Streams block
local db; 
local name;
local color;
local DATA={};
local Percentage;
local ExtendEnd;
local ExtendBeginning;
-- Routine

 function Prepare(nameOnly)  
    ExtendBeginning= instance.parameters.ExtendBeginning;
    ExtendEnd= instance.parameters.ExtendEnd;
    color= instance.parameters.color;
    source = instance.source;
    first = source:first();

    name =  profile:id() .. ", " .. source:name();
    instance:name(name);	
	
	if   (nameOnly) then
        return;
    end
	
	require("storagedb");
    db = storagedb.get_db(source:name());	
	
	 
	
	core.host:execute("addCommand", 1, "Botttom Line First", "");
	core.host:execute("addCommand", 2, "Botttom Line Second"  , "");
	
	core.host:execute("addCommand", 3, "Top Line First", "");
	core.host:execute("addCommand", 4, "Top Line Second"  , "");
	core.host:execute("addCommand", 5, "Reset");
	
	TOP= instance:addStream ("Top",  core.Line,  "Top", "Top", color, first);
	TOP:setWidth(instance.parameters.width);
    TOP:setStyle(instance.parameters.style);
	BOTTOM = instance:addStream ("Bottom",  core.Line, "Bottom", "Bottom", color, first);	
	BOTTOM:setWidth(instance.parameters.width);
    BOTTOM:setStyle(instance.parameters.style);
	
end

function getline(x1, y1, x2, y2)
    local a, b;

    a = ((y2 - y1) / (x2 - x1));
    b = (y1 - a * x1);
    return a, b;
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
   
	 
	local i;
	 if period < first then
			for i = period ,  first , 1 do
			TOP[i]=0;
			BOTTOM[i]=0;
			end  
      end
	
	if period < source:size()-1 or not source:hasData(period) then
	return;
	end
       
	
    for i = 1 , NOW, 1 do
	TOP[i]=0;
	BOTTOM[i]=0;
    end
	
	  
		   DATA["BFD"]=db:get ("BFD", 0);
		   if DATA["BFD"] == nil then 
		    return;
			end
		    DATA["BFD"]=core.findDate (source, DATA["BFD"], false);			
		   DATA["BFL"]=tonumber(db:get ("BFL", 0));		    
		   
		    DATA["BSD"]=db:get ("BSD", 0);
			 if DATA["BSD"] == nil then 
		    return;
			end
		    DATA["BSD"]= core.findDate (source, DATA["BSD"], false);	
		    DATA["BSL"]=tonumber(db:get ("BSL", 0));		   
		   
		   DATA["TFD"]=db:get ("TFD", 0);
		    if DATA["TFD"] == nil then 
		    return;
			end
		    DATA["TFD"]= core.findDate (source, DATA["TFD"], false);	
		   DATA["TFL"]=tonumber(db:get ("TFL", 0));	          
          
		   
		   DATA["TSD"]=db:get ("TSD", 0);
		    if DATA["TSD"] == nil then 
		    return;
			end
		    DATA["TSD"]= core.findDate (source, DATA["TSD"], false);
		   DATA["TSL"]=tonumber(db:get ("TSL", 0));
		   
		   
		   if DATA["BFD"] < first or DATA["BSD"] < first then
		   return;
		   end
		   
		 
		   
		  
		  
		   
		   if DATA["BFL"]~=0 and  DATA["BSL"]~= 0 and DATA["BFD"]~= DATA["BSD"] then
		    local a,b,y;
		   
   		    a,b= getline(DATA["BFD"], DATA["BFL"], DATA["BSD"], DATA["BSL"]);
	       
		   
		     if ExtendEnd then
			 
				 if a~=0 and b~=0 then
				   y = a *(period) + b;				
				 DATA["BSD"]=(period);
				 DATA["BSL"]=y;
			    end	 
			 end
			 
			
			 
			 if ExtendBeginning then
				 if a~=0 and b~=0 then
				   y = a *(1) + b;
				 DATA["BFD"]=1;
				 DATA["BFL"]=y;
				 end
			 end
			 
		    
		    core.drawLine(BOTTOM,  core.range(DATA["BFD"],DATA["BSD"]),  DATA["BFL"], DATA["BFD"],  DATA["BSL"], DATA["BSD"]);
		   end	
		   
		     if DATA["TFD"] < first or DATA["TSD"] < first then
		   return;
		   end
		   
		   if DATA["TFL"]~=0 and  DATA["TSL"]~= 0  and DATA["TFD"]~= DATA["TSD"] then
		   
		    local c,d,Y;
		     c,d= getline(DATA["TFD"], DATA["TFL"], DATA["TSD"], DATA["TSL"]);
	       
		   
		     if ExtendEnd then
				  if c~=0 and d~=0 then
				  Y = c * (period) + d;
				 DATA["TSD"]=(period);
				 DATA["TSL"]=Y;
				 end
			 end
			 
			 if ExtendBeginning then
				  if c~=0 and d~=0 then
				  Y = c * 1 + d;
				 DATA["TFD"]=1;
				 DATA["TFL"]=Y;
				 end
			 end
		   
		   
		    core.drawLine(TOP, core.range(DATA["TFD"],DATA["TSD"]),  DATA["TFL"], DATA["TFD"],  DATA["TSL"], DATA["TSD"]);
		  end	
		  

end


-- This method will be called when the command is executed (e.g. when the user clicks the corresponding menu command in the MarketScope).
-- Parameters:
-- cookie - the command identifier previously specified in core.host:execute("addCommand", ..
-- success - always true
-- message - information about the point to which the user clicked to view the menu. The format is: "{rate};{OLE date}"
local pattern = "([^;]*);([^;]*)";
function AsyncOperationFinished(cookie, success, message)
    -- check that this is our "Show marker" command
	
	    local date;
        local level;
	
        
		level, date = string.match(message, pattern, pos);
		
	
    if cookie == 1 then
	
			 db:put("BFL",tostring(level));			
			   db:put("BFD", tostring((date)));
	 
    elseif cookie == 2 then

            	db:put("BSL", tostring(level));			
			   db:put("BSD", tostring((date)));
			 
	 
    elseif cookie == 3 then
	
		        db:put("TFL", tostring(level));			
			   db:put("TFD", tostring((date)));
			
	 
    elseif cookie == 4 then
	
			   db:put("TSL", tostring(level));			
			   db:put("TSD", tostring((date)));			   
	
	 
    elseif cookie == 5 then
	
	           db:put("BFL", tostring(0));			
			   db:put("BFD", tostring(0));		
               db:put("BSL", tostring(0));			
			   db:put("BSD", tostring(0));	
               db:put("TFL", tostring(0));			
			   db:put("TFD", tostring(0));	
	           db:put("TSL", tostring(0));			
			   db:put("TSD", tostring(0));			   
	 
   end   
	
end
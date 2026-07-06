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
    indicator:name("Percentage Tool");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
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
local TOP;
local BOTTOM;
local ExtendEnd;
local ExtendBeginning;
-- Routine


function getline(x1, y1, x2, y2)
    local a, b;

    a = ((y2 - y1) / (x2 - x1));
    b = (y1 - a * x1);
    return a, b;
end

 function Prepare(nameOnly)  
    color= instance.parameters.color;
    source = instance.source;
    first = source:first();
	
	ExtendBeginning= instance.parameters.ExtendBeginning;
    ExtendEnd= instance.parameters.ExtendEnd;

    name =  profile:id() .. ", " .. source:name();
    instance:name(name);	
	
	if   (nameOnly) then
        return;
    end
	
	require("storagedb");
    db = storagedb.get_db(source:name());
	TOP= instance:addInternalStream(first, 0);
	BOTTOM = instance:addInternalStream(first, 0); 

	Percentage = instance:addStream ("Percentage",  core.Line, "Percentage", "Percentage", color, first);
	Percentage:setWidth(instance.parameters.width);
    Percentage:setStyle(instance.parameters.style);
end


local LAST=0;
-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)


    	local i;
 
     if period < first then
			for i = period ,  first , 1 do
			TOP[i]=0;
			BOTTOM[i]=0;
			end  
      end

    if period < source:size()-1  then	
	return;
	end
       
	   
	for i = first ,  source:size()-1 , 1 do
	TOP[i]=0;
	BOTTOM[i]=0;
    end  

	
	  
		   DATA["BFD"]=tostring(db:get ("BFD", 0));
		   if DATA["BFD"] == nil or DATA["BFD"] == 0 then 
		    return;
			end
		    DATA["BFD"]=core.findDate (source, DATA["BFD"],false);			
		   DATA["BFL"]=tonumber(db:get ("BFL", 0));		    
		   
		    DATA["BSD"]=tostring(db:get ("BSD", 0));
			 if DATA["BSD"] == nil  or DATA["BSD"] == 0  then 
		    return;
			end
		    DATA["BSD"]= core.findDate (source, DATA["BSD"], false);	
		    DATA["BSL"]=tonumber(db:get ("BSL", 0));		   
		   
		   DATA["TFD"]=tostring(db:get ("TFD", 0));
		    if DATA["TFD"] == nil  or DATA["TFD"] == 0  then 
		    return;
			end
		    DATA["TFD"]= core.findDate (source, DATA["TFD"], false);	
		   DATA["TFL"]=tonumber(db:get ("TFL", 0));	          
          
		   
		   DATA["TSD"]=tostring(db:get ("TSD", 0));
		    if DATA["TSD"] == nil or DATA["TSD"] == 0  then 
		    return;
			end
		    DATA["TSD"]= core.findDate (source, DATA["TSD"], false);
		   DATA["TSL"]=tonumber(db:get ("TSL", 0));
		   
		   
		     if DATA["BFD"] < first or DATA["BSD"] < first then
		   return;
		   end
		   
		   if DATA["TFD"] < first or DATA["TSD"] < first then
		   return;
		   end
		   
		 
		   if DATA["BFL"]~=0 and  DATA["BSL"]~= 0 then
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
		   
		   if DATA["TFL"]~=0 and  DATA["TSL"]~= 0 then
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
		  
		   for i = 1 , source:size()-1, 1 do
		      if TOP[i] ~= 0 and BOTTOM[i] ~= 0  then
			 Percentage[i] = ((source.close[i] -   BOTTOM[i])/( TOP[i] -BOTTOM[i]))*100;
			 else
			 Percentage[i]=nil;
			  end
		   end
			
end

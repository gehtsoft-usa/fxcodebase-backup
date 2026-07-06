-- Id: 13535

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61773


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
    indicator:name("Net Volume");
    indicator:description("Net Volume");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	 indicator.parameters:addGroup("Calculation"); 	 
	indicator.parameters:addString("TF" , "Time Frame ", "", "m1");
    indicator.parameters:setFlag("TF", core.FLAG_PERIODS);


	indicator.parameters:addString("Method", "Method", "Method" , "Cumulative");
    indicator.parameters:addStringAlternative("Method", "Cumulative", "Cumulative" , "Cumulative");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
	
	 indicator.parameters:addGroup("Style"); 	 
	 indicator.parameters:addColor("Volume_Up", "Color of Up", "Color of Up", core.rgb(0, 255, 0));
	 indicator.parameters:addColor("Volume_Down", "Color of Down", "Color of Down", core.rgb(255, 0, 0));
	 
	 indicator.parameters:addGroup("Zero Line");	
    
	 indicator.parameters:addColor("zero_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("zero_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("zero_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("zero_style", core.FLAG_LEVEL_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;
local Source={};
local loading={};
local Method;
-- Streams block
local Buy = nil;
local Sell = nil;
local Up;
local Down;
local Cumulative;
local dayoffset, weekoffset;
local Volume;
local TF;
local Multiplier;

local  First,Last;
-- Routine
function Prepare(nameOnly)
    source = instance.source;
	Method=instance.parameters.Method;
	TF=instance.parameters.TF;
    first = source:first();
	 
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");
	
	assert(TF ~= "t1", "The time frame must not be tick");
	
	local s1, e1, s2, e2;
    s1, e1 = core.getcandle(source:barSize(), core.now(), 0, 0);
    s2, e2 = core.getcandle(TF, core.now(), 0, 0);
	Multiplier= (e1 - s1) / (e2 - s2)
    assert ((e1 - s1) >= (e2 - s2), "The chosen time frame must be equal to or bigger than the chart time frame!");
	 
    if (not (nameOnly)) then
	   
	    Volume = instance:addStream("Volume", core.Bar, name .. ".Volume", "Volume", instance.parameters.Volume_Up, first);
    Volume:setPrecision(math.max(2, instance.source:getPrecision()));
 
		
		Up = instance:addInternalStream(0, 0);
		Down = instance:addInternalStream(0, 0);
		 
    end
	
	
	instance:ownerDrawn(true);
    core.host:execute ("setTimer", 1, 1);
	
end

local init = false;
 
function Draw(stage, context)
    if stage ~= 2 then    
	return;
	end
	
		context:createPen (1, context:convertPenStyle (instance.parameters.zero_style), instance.parameters.zero_width, instance.parameters.zero_color);
	visible, y =context:pointOfPrice (0);
	context:drawLine (1,context:left (), y , context:right (), y  );
	
	 First=context:firstBar ();
	 Last=context:lastBar ();
	 
	 
end	

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
     
	 from, to = core.getcandle(source:barSize(), source:date(period), dayoffset, weekoffset);
	 Initialization(period,from, to)
end


 

function   Initialization(period,from, to)

       if  loading[source:serial(period)] ~= false then  
	   return;
	   end
 
    
	S= core.findDate (Source[source:serial(period)], from, false);
	E= core.findDate (Source[source:serial(period)], to, false);
	
    if S==-1 or E == -1 then
    return;
    end	
   
   
   
            Up[period]=0;
			Down[period]=0   
			 
		   
			
			 
			 
			 
			  
			 
   for i=  S, E ,1  do
     
	     if Source[source:serial(period)].close[i]>Source[source:serial(period)].open[i]  then
		 Up[period]=Up[period]+1;
		 elseif Source[source:serial(period)].close[i]<Source[source:serial(period)].open[i]  then
		 Down[period]=Down[period]-1;
		 end
	 
   end
   
   
          
			 Volume[period]=   Up[period]+Down[period];  
			 
			 if Volume[period] > 0 then
			 Volume:setColor(period, instance.parameters.Volume_Up);
			 else
			 Volume:setColor(period, instance.parameters.Volume_Down);
			 end
   
end	

 

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie) 
    
	
	  if cookie ~= 1 then
        loading[cookie] = false; 		
	    instance:updateFrom(0);   
		return core.ASYNC_REDRAW ;
		else
		
                
						for period= First,Last, 1 do
					 from, to = core.getcandle(source:barSize(), source:date(period), dayoffset, weekoffset);
					 
					
						if Source[source:serial(period)] == nil then
							if period==source:size()-1 then
							Source[source:serial(period)] =core.host:execute("getHistory", source:serial(period), source:instrument(), TF, from, 0, source:isBid()); 
							else
							Source[source:serial(period)] =core.host:execute("getHistory", source:serial(period), source:instrument(), TF, from, to, source:isBid()); 
							end
						loading[source:serial(period)]= true;
						end
						 
		
		             end
		
    end
end

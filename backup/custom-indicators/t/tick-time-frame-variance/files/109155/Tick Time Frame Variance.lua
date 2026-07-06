-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64121
-- Id: 17067

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Tick Time Frame Variance");
    indicator:description("Tick Time Frame Variance");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
 
    indicator.parameters:addInteger("LookBackPeriod", "LookBack Period", "Use 0 for all data", 100);
	indicator.parameters:addBoolean("SquareRoot" ,  "Calculate SquareRoot" , "" , true);	
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Color", "Color of Variance", "Color of Variance", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("Width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("Style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Style", core.FLAG_LINE_STYLE);
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local first;
local source = nil;
-- Streams block
local Stream={};
local Loading={};
local LookBackPeriod;
local SquareRoot;
-- Routine
function Prepare(nameOnly)
    LookBackPeriod = instance.parameters.LookBackPeriod; 
	SquareRoot = instance.parameters.SquareRoot;
    source = instance.source;
    first=source:first();

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	
    if (not (nameOnly)) then
        Variance = instance:addStream("Variance", core.Line, name .. ".Variance", "Variance", instance.parameters.Color, source:first());
    Variance:setPrecision(math.max(2, instance.source:getPrecision()));
		Variance:setWidth(instance.parameters.Width);
        Variance:setStyle(instance.parameters.Style);
      
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)

	
	if (period <= first and LookBackPeriod==0) 
	or (period <= source:size()-1-LookBackPeriod and LookBackPeriod~=0) 
	then
	return;
	end
	
	period=period-1;	
	 
	
	if Stream[source:serial(period)]== nil then
	from, to = core.getcandle(source:barSize(), source:date(period), core.host:execute("getTradingDayOffset"), core.host:execute("getTradingWeekOffset"));
	Stream[source:serial(period)] = core.host:execute("getHistory", source:serial(period), source:instrument(), "t1", from, to, source:isBid());
	Loading[source:serial(period)]=true;
    end
	
	
	local Sum=0;
	local Count=0;
	 
    for i= 1, 	Stream[source:serial(period)]:size()-1,1 do
	Count=Count+1;
	Sum= Sum+Stream[source:serial(period)][i];	
	end
	
	local Average= Sum/Count;
	
	
	 Sum=0;
	
	for i= 1, 	Stream[source:serial(period)]:size()-1,1 do	
	Sum= Sum+ (Stream[source:serial(period)][i] -Average)^2;	
	end
	
	
	if SquareRoot then
	Variance[period]=(Sum/(Count-1))^(1/2);
	else
	Variance[period]=(Sum/(Count-1));
	end
	
end

function AsyncOperationFinished(cookie, success, message)
            
       Loading[cookie] = false;           
       
	   
	   
	   local Flag=false;
	   local Count=0;
	   
	   for i=1,  #Loading, 1 do
		   if  Loading[i] then
		   Flag=true;
		   else
		   Count=Count+1;
		   core.host:execute ("setStatus", " Loading "..  Count .."/" .. (source:size()-1));
		   end
	   end
	   
	   
	    if not Flag then
	    instance:updateFrom(source:first());
	    end
		
		return core.ASYNC_REDRAW ;
	   

end



 
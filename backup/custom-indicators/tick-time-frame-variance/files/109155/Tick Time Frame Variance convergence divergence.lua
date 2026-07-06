-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64121
-- Id: 18078

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
    indicator:name("Tick Time Frame Variance convergence divergence");
    indicator:description("Tick Time Frame Variance convergence divergence");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
 
    indicator.parameters:addInteger("LookBackPeriod", "LookBack Period", "Use 0 for all data", 100);
	indicator.parameters:addBoolean("SquareRoot" ,  "Calculate SquareRoot" , "" , true);	
	
	
	indicator.parameters:addInteger("Period", "MA Period", "Period" , 10);
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
	
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Color", "Color of Variance", "Color of Variance", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("Width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("Style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Style", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addColor("SColor", "Color of Signal", "Color of Signal", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("SWidth", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("SStyle", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("SStyle", core.FLAG_LINE_STYLE);
	
	
	 indicator.parameters:addColor("HColor", "Color of Histogram", "Color of Histogram", core.rgb(0, 0, 255));
 
 
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
local Signal, signal, Method,Period,Histogram;
-- Routine
function Prepare(nameOnly)
    LookBackPeriod = instance.parameters.LookBackPeriod; 
	SquareRoot = instance.parameters.SquareRoot;
	Method = instance.parameters.Method;
	Period = instance.parameters.Period;
    source = instance.source;
    first=source:first();

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	
    if (not (nameOnly)) then
        Variance = instance:addStream("Variance", core.Line, name .. ".Variance", "Variance", instance.parameters.Color, source:first());
    Variance:setPrecision(math.max(2, instance.source:getPrecision()));
		Variance:setWidth(instance.parameters.Width);
        Variance:setStyle(instance.parameters.Style);
		
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
		signal = core.indicators:create(Method, Variance, Period);
		
	    Signal = instance:addStream("Signal", core.Line, name .. ".Signal", "Signal", instance.parameters.SColor, signal.DATA:first());
    Signal:setPrecision(math.max(2, instance.source:getPrecision()));
		Signal:setWidth(instance.parameters.SWidth);
        Signal:setStyle(instance.parameters.SStyle);
		
		Histogram = instance:addStream("Histogram", core.Bar, name .. ".Histogram", "Histogram", instance.parameters.HColor, signal.DATA:first());
    Histogram:setPrecision(math.max(2, instance.source:getPrecision()));
      
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)

	
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
	
	signal:update(mode);
	
	if period <   signal.DATA:first() then
	return;
	end
	
	Signal[period]= signal.DATA[period];
	Histogram[period]= Variance[period] -Signal[period];
	
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
		signal:update(core.UpdateAll);
	    instance:updateFrom(source:first());
	    end
		
		return core.ASYNC_REDRAW ;
	   

end



 
-- Id: 7510
--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name( "Raw Volatility Quality Index");
    indicator:description("Volatility Quality Index by Thomas Stridsman");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	indicator.parameters:addGroup("Calculation");	
	indicator.parameters:addString("Method", "Method", "Method" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
	indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
	
	 indicator.parameters:addBoolean("Steady", "Steady", "" , false); 
 
	indicator.parameters:addInteger("Length", "Length", "", 14);
    indicator.parameters:addInteger("Smoothing", "Smoothing", "", 14);
    --indicator.parameters:addDouble("Filter", "Filter", "", 5);
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("UP", "Up Trend Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("DOWN", "Down Trend Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("NO", "Neutral Color", "", core.rgb(128, 128, 128));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Method;
local first;
local source = nil;
 
-- Streams block
local SumVQ = nil;
local VQ;
local DIR;
local UP, DOWN;
--local Filter;
local Smoothing;
local TR, MH, ML, MO, MC, MC1;
local Length;
local Steady;
local NO;
-- Routine
function Prepare(nameOnly)
    NO = instance.parameters.NO;
    Steady = instance.parameters.Steady;
    Method = instance.parameters.Method;
    Length = instance.parameters.Length;
    Smoothing = instance.parameters.Smoothing;
   -- Filter = instance.parameters.Filter;
    UP = instance.parameters.UP;
	DOWN = instance.parameters.DOWN;
    source = instance.source;
   
	VQ = instance:addInternalStream (0,0);
	DIR = instance:addInternalStream (0,0);
	
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
	MH= core.indicators:create(Method, source.high , Length);
	ML= core.indicators:create(Method, source.low , Length);
	
	
	MO= core.indicators:create(Method, source.open , Length);
	if (Steady) then 
	MC= core.indicators:create(Method, source.median , Length);
	else
	MC= core.indicators:create(Method, source.close , Length);
	end

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Method)  .. ", " .. tostring(Length) .. ", " .. tostring(Smoothing).. ")";
    instance:name(name);

	 first = MH.DATA:first();
	
    if (not (nameOnly)) then
       
		SumVQ= instance:addStream("VQB", core.Bar, name, "VQB", NO, first);
    SumVQ:setPrecision(math.max(2, instance.source:getPrecision()));
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period < first or not  source:hasData(period) then
	return;
	end
	
	
    
	if period <= first then
	SumVQ[period] = source.close[period];	
	return;
	end
	
	
	MH:update(mode);
    ML:update(mode);
    MO:update(mode);
    MC:update(mode);

		
    VQ[period] = math.abs(((MC.DATA[period] - MC.DATA[period - Smoothing]) / math.max( (MH.DATA[period] - ML.DATA[period] ), (MH.DATA[period] - MC.DATA[period - Smoothing]), (MC.DATA[period - Smoothing] - ML.DATA[period])) + (MC.DATA[period] - MO.DATA[period]) / (MH.DATA[period] - ML.DATA[period])) * 0.5) * ((MC.DATA[period] - MC.DATA[period - Smoothing] + (MC.DATA[period] - MO.DATA[period])) * 0.5);
	SumVQ[period] =VQ[period] ;
	



    DIR[period] = DIR[period -1];
   if SumVQ[period] - SumVQ[period-1] > 0 then
   DIR[period] = 1;
   end   
  
   if SumVQ[period -1 ] - SumVQ[period] >  0 then
   DIR[period] = -1;    
   end
   
    if DIR[period] == 1 then
    SumVQ:setColor(period, UP);	
    elseif DIR[period] == -1 then
    SumVQ:setColor(period, DOWN);
	else
	 SumVQ:setColor(period, NO);
    end   
    
end


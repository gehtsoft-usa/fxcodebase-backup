-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60644
-- Id: 11661

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

function Init()
    indicator:name("Onisuk Filter");
    indicator:description("Onisuk Filter Helper");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup(  "Selector");
	
	indicator.parameters:addBoolean("On1", "Show 1. Scenario", "", true);
	indicator.parameters:addBoolean("On2", "Show 2. Scenario", "", true);
	indicator.parameters:addBoolean("On3", "Show 3. Scenario", "", true);
	
	indicator.parameters:addGroup(1 .. ". Scenario Calculation");
	indicator.parameters:addInteger("Period11", "1. Period ", "", 3);
	indicator.parameters:addString("Method11", "MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method11", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method11", "EMA", "EMA" , "EMA");
 indicator.parameters:addStringAlternative("Method11", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method11", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method11", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method11", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method11", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method11", "WMA", "WMA" , "WMA");
 	
	
	indicator.parameters:addInteger("Period12", "2. Period ", "", 7);
	indicator.parameters:addString("Method12", "MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method12", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method12", "EMA", "EMA" , "EMA");
 indicator.parameters:addStringAlternative("Method12", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method12", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method12", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method12", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method12", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method12", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addInteger("Period13", "3. Period ", "", 50);
	indicator.parameters:addString("Method13", "MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method13", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method13", "EMA", "EMA" , "EMA");
 indicator.parameters:addStringAlternative("Method13", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method13", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method13", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method13", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method13", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method13", "WMA", "WMA" , "WMA");
	
	
	indicator.parameters:addGroup(2 .. ". Scenario Calculation");
	
	indicator.parameters:addInteger("Period21", "1. Period ", "",20);
	indicator.parameters:addString("Method21", "MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method21", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method21", "EMA", "EMA" , "EMA");
 indicator.parameters:addStringAlternative("Method21", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method21", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method21", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method21", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method21", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method21", "WMA", "WMA" , "WMA");
 	
	
	indicator.parameters:addInteger("Period22", "2. Period ", "", 50);
	indicator.parameters:addString("Method22", "MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method22", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method22", "EMA", "EMA" , "EMA");
 indicator.parameters:addStringAlternative("Method22", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method22", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method22", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method22", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method22", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method22", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addGroup(3 .. ". Scenario Calculation");
	
	indicator.parameters:addInteger("Period31", "1. Period ", "", 20);
	indicator.parameters:addString("Method31", "MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method31", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method31", "EMA", "EMA" , "EMA");
 indicator.parameters:addStringAlternative("Method31", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method31", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method31", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method31", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method31", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method31", "WMA", "WMA" , "WMA");
 	
	
	indicator.parameters:addInteger("Period32", "2. Period ", "", 50);
	indicator.parameters:addString("Method32", "MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method32", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method32", "EMA", "EMA" , "EMA");
 indicator.parameters:addStringAlternative("Method32", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method32", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method32", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method32", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method32", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method32", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addGroup(  "Style");	

	indicator.parameters:addColor("Up", "Color of Up Alert", "Color of Up", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Color Down Alert", "Color of Down", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("Size", "Arrow Size", "Arrow Size", 10);
	
 
 
 
	
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Up ;
local Down ;
local On={};
local first={};
local source = nil;
local Period={};
local Indicator={};
-- Streams block
local up 
local down 
local Size 
local Method={};
local U={};
local D={};
local Note={};
local Flag={};
-- Routine
function Prepare(nameOnly)
    source = instance.source;
     
	On[1]= instance.parameters.On1;
	On[2]= instance.parameters.On2;
	On[3]= instance.parameters.On3;
		 
	Up= instance.parameters.Up;
	Down= instance.parameters.Down;	
	Size= instance.parameters.Size;	 
	 
    local name = profile:id() .. "(" .. source:name() .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	
	if On[1] then
	Period[1]={};
	Indicator[1]={};
	Method[1]={};
	Period[1][1]= instance.parameters.Period11;
	Period[1][2]= instance.parameters.Period12;
	Period[1][3]= instance.parameters.Period13;
	
	Method[1][1]= instance.parameters.Method11;
	Method[1][2]= instance.parameters.Method12;
	Method[1][3]= instance.parameters.Method13;
	
    assert(core.indicators:findIndicator(Method[1][1]) ~= nil, Method[1][1] .. " indicator must be installed");
	Indicator[1][1] = core.indicators:create(Method[1][1], source.close,Period[1][1]);
    assert(core.indicators:findIndicator(Method[1][2]) ~= nil, Method[1][2] .. " indicator must be installed");
	Indicator[1][2] = core.indicators:create(Method[1][2], source.close,Period[1][2]);
    assert(core.indicators:findIndicator(Method[1][3]) ~= nil, Method[1][3] .. " indicator must be installed");
	Indicator[1][3] = core.indicators:create(Method[1][3], source.close,Period[1][3]);
	
	first[1]=math.max(Indicator[1][1].DATA:first(),Indicator[1][2].DATA:first(),Indicator[1][3].DATA:first());
	
	
	end
	if On[2] then
	Period[2]={};
	Method[2]={};
	Indicator[2]={};
	
	Period[2][1]= instance.parameters.Period21;
	Period[2][2]= instance.parameters.Period22;
	
	Method[2][1]= instance.parameters.Method21;
	Method[2][2]= instance.parameters.Method22;	 
	
    assert(core.indicators:findIndicator(Method[2][1]) ~= nil, Method[2][1] .. " indicator must be installed");
	Indicator[2][1] = core.indicators:create(Method[2][1], source.close,Period[2][1]);
    assert(core.indicators:findIndicator(Method[2][2]) ~= nil, Method[2][2] .. " indicator must be installed");
	Indicator[2][2] = core.indicators:create(Method[2][2], source.close,Period[2][2]);	
	
	first[2]=math.max(Indicator[2][1].DATA:first(),Indicator[2][2].DATA:first());
	
	 
	end
	if On[3] then	
	Period[3]={};
	Method[3]={};
	Indicator[3]={};
	
	Period[3][1]= instance.parameters.Period31;
	Period[3][2]= instance.parameters.Period32;
	
	Method[3][1]= instance.parameters.Method31;
	Method[3][2]= instance.parameters.Method32;	 
	
    assert(core.indicators:findIndicator(Method[3][1]) ~= nil, Method[3][1] .. " indicator must be installed");
	Indicator[3][1] = core.indicators:create(Method[3][1], source.close,Period[3][1]);
    assert(core.indicators:findIndicator(Method[3][2]) ~= nil, Method[3][2] .. " indicator must be installed");
	Indicator[3][2] = core.indicators:create(Method[3][2], source.close,Period[3][2]);	
	
	first[3]=math.max(Indicator[3][1].DATA:first(),Indicator[3][2].DATA:first());	 
	end
	
	up  = instance:createTextOutput ("Up" , "Up", "Wingdings", Size , core.H_Center, core.V_Bottom, Up , source:first());
    down  = instance:createTextOutput ("Down" , "Down", "Wingdings", Size , core.H_Center, core.V_Top, Down  , source:first());	
    
	U[1]= instance:addInternalStream(0, 0);
	D[1]= instance:addInternalStream(0, 0);
	
	U[2]= instance:addInternalStream(0, 0);
	D[2]= instance:addInternalStream(0, 0);
	
	U[3]= instance:addInternalStream(0, 0);
	D[3]= instance:addInternalStream(0, 0);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)


   U[1][period]=  0;
   U[2][period]=  0;
   U[3][period]=  0;
   
   D[1][period]=  0;
   D[2][period] =  0;
   D[3][period]=  0;
   
    up:setNoData (period);
	down:setNoData (period);
    	
    Calculation1 (1,period, mode);
	Calculation2 (2, period, mode);
	Calculation3 (3, period, mode);	
	
	
	Note[1]="";
	Note[2]="";	
	 
	Flag[1]=0;
	Flag[2]=0;
	
	if U[1][period]== 1 then
	Note[1]= Note[1] .. " 1. ";
	Flag[1]=1;
	end
	
	if U[2][period]== 1 then
	Note[1]= Note[1] .. " 2. ";
	Flag[1]=1;
	end
	
	if U[3][period]== 1 then
	Note[1]= Note[1] .. " 3. ";
	Flag[1]=1;
	end
	
	
	
	
	 
	if D[1][period]== 1 then
	Note[2]= Note[2] .. " 1. ";
	Flag[2]=1;
	end
	
	if D[2][period]== 1 then
	Note[2]= Note[2] .. " 2. ";
	Flag[2]=1;
	end
	
	if D[3][period]== 1 then
	Note[2]= Note[2] .. " 3. ";
	Flag[2]=1;
	end
	
	if Flag[1]== 1  then 
	up:set(period, source.low[period], "\225",Note[1]);	
	end
	
	if Flag[2]== 1  then  
	down:set(period, source.high[period], "\226",Note[2]);	
	end 
end

function Calculation1(id, period, mode)
   
	
	if not On[id] then
	return;
	end
	
	Indicator[1][1]:update(mode);
	Indicator[1][2]:update(mode);
	Indicator[1][3]:update(mode);
	
	if period < first[id] then
	return;
	end
	 
	
	--[[EMA 3 > EMA 7 
	AND
	EMA 7 > EMA 50
	AND
	Candle Closing Price is < Candle Opening Price]]
	
	if Indicator[1][1].DATA[period] >  Indicator[1][2].DATA[period]
	and Indicator[1][2].DATA[period] >  Indicator[1][3].DATA[period]
	and  source.close[period] <   source.open[period]
	then
	U[1][period]=1;		
	elseif Indicator[1][1].DATA[period] <  Indicator[1][2].DATA[period]
	and Indicator[1][2].DATA[period] <  Indicator[1][3].DATA[period]
	and  source.close[period] >   source.open[period]
	then
	D[1][period]=1;
	end
end

function Calculation2(id,period, mode)    
	
    if not On[id] then
	return;
	end
	
	Indicator[2][1]:update(mode);
	Indicator[2][2]:update(mode);
	
	if period < first[id] then
	return;
	end
	 
	--[[EMA 20 > EMA 50
	AND
	Candle Low Price < EMA 20
	AND
	Candle Open Price > EMA 20
	AND
	Candle Close Price > EMA 20
	THEN]]
	
	if Indicator[2][1].DATA[period] >  Indicator[2][2].DATA[period]
	and source.low[period] <  Indicator[2][1].DATA[period]
	and source.open[period] >  Indicator[2][1].DATA[period]
	and source.close[period] >  Indicator[2][1].DATA[period]	 
	then
	U[2][period]=1;	
	elseif Indicator[2][1].DATA[period]<  Indicator[2][2].DATA[period]
	and source.high[period] >  Indicator[2][1].DATA[period]
	and source.open[period] <  Indicator[2][1].DATA[period]
	and source.close[period] <  Indicator[2][1].DATA[period]
	then
	D[2][period]=1;
	end
	
end

function Calculation3(id,period, mode)
   	
    if not On[id] then
	return;
	end
	
	Indicator[3][1]:update(mode);
	Indicator[3][2]:update(mode);
	
	if period < first[id] then
	return;
	end
	 
	--[[EMA 20 > EMA 50
	AND
	Candle Low Price < EMA 50
	AND
	Candle Open Price > EMA 50
	AND
	Candle Close Price > EMA 50]]

   if Indicator[3][1].DATA[period] >  Indicator[3][2].DATA[period]
	and source.low[period] <  Indicator[3][2].DATA[period]
	and source.open[period] >  Indicator[3][2].DATA[period]
	and source.close[period] >  Indicator[3][2].DATA[period]	 
	then
	U[3][period]=1;	
	elseif Indicator[3][1].DATA[period]<  Indicator[3][2].DATA[period]
	and source.high[period] >  Indicator[3][2].DATA[period]
	and source.open[period] <  Indicator[3][2].DATA[period]
	and source.close[period] <  Indicator[3][2].DATA[period]
	then
	D[3][period]=1;
	end
	
end
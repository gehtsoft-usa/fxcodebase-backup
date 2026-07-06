-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2065

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
    indicator:name("Fibonacci Bollinger Bands");
    indicator:description("Fibonacci Bollinger Bands");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	
	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("MF", "Fibonacci Bollinger Bands Period", "", 20);
    indicator.parameters:addInteger("AF", "ATR Period", "", 20);
	local i,j;
	--local FIB={-0,618, -0.382, -0.272, 0, 0.236, 0.382, 0.5 , 0.618, 0.764, 1 , 1.272 , 1.618, 2.618, 4.618};
	i=1;
    indicator.parameters:addDouble("F"..i, "1. Fibonacci Level", " ", 1.6180);
	i=2;
    indicator.parameters:addDouble("F"..i, "2. Fibonacci Level", " ", 2.6180);
	i=3;
    indicator.parameters:addDouble("F"..i, "3. Fibonacci Level", " ", 4.2360);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("CC", "Cental Line Color", " ", core.rgb(125, 125, 125));
	i=1;
    indicator.parameters:addColor("FC"..i, "Color of  1. Fibonacci", " ", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width"..i, "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style"..i, "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style"..i, core.FLAG_LINE_STYLE);
	i=2;
    indicator.parameters:addColor("FC"..i, "Color of 2. Fibonacci", " ", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width"..i, "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style"..i, "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style"..i, core.FLAG_LINE_STYLE);	
	i=3;
    indicator.parameters:addColor("FC"..i, "Color of 3. Fibonacci", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width"..i, "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style"..i, "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style"..i, core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local MF;
local AF;
local F={};
local FC={};
local first;
local source = nil;

-- Streams block
local SMA = nil;
local ATR =nil;
local Fibonacci = {};              
local Style={};
local Width={};
local CENTRAL=nil;

local ATRFirst=nil;
local MVAFirst=nil;

-- Routine
function Prepare(nameOnly)   

    
	local i;
	
    MF = instance.parameters.MF;
	AF = instance.parameters.AF;
	for i = 1, 3 , 1 do
	FC[i]= instance.parameters:getColor("FC".. i);
	F[i]= instance.parameters:getDouble("F".. i);
	Style[i]=instance.parameters:getString("style".. i);
    Width[i]=instance.parameters:getString("width".. i);
	end
    source = instance.source;
    first = source:first();
	
	   local name = profile:id() .. "(" .. source:name() .. ", " .. MF ..", ".. AF.. ", " .. F[1] .. ", " .. F[3] .. ", " .. F[3] .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
		
	SMA = core.indicators:create("MVA", source.close, MF);
	MVAFirst=SMA.DATA:first();
	ATR = core.indicators:create("ATR", source, AF);
	ATRFirst=ATR.DATA:first();
	
 
    CENTRAL = instance:addStream("Central", core.Line, name .. ".Central", "CL", instance.parameters.CC,  math.max(MVAFirst,ATRFirst) );
	for i=1,3,1 do
    Fibonacci[i] = instance:addStream("Fibonacci"..i, core.Line, name .. ".F"..i, "F"..i, FC[i],  math.max(MVAFirst,ATRFirst));
	Fibonacci[i]:setWidth(Width[i]);
    Fibonacci[i]:setStyle(Style[i]);
	Fibonacci[i+3] = instance:addStream("Fibonacci"..(i+3), core.Line, name .. ".F"..i, "F"..i, FC[i],  math.max(MVAFirst,ATRFirst));
	Fibonacci[i+3]:setWidth(Width[i]);
    Fibonacci[i+3]:setStyle(Style[i]);
	end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)

    
  
	
		SMA:update(mode);
		ATR:update(mode);
		
		  if period < math.max(MVAFirst,ATRFirst) or not source:hasData(period) then
		  return;
		  end
		  
		
        CENTRAL[period] = SMA.DATA[period];
		
		
		local i;
		for i=1,3, 1 do
        Fibonacci[i][period] = CENTRAL[period]+ATR.DATA[period]*F[i];
		Fibonacci[i+3][period] = CENTRAL[period]-ATR.DATA[period]*F[i];
	    end
    
end


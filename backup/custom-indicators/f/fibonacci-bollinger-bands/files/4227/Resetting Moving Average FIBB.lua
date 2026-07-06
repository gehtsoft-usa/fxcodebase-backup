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
    indicator:name("Resetting Moving Average Fibonacci Bollinger Bands");
    indicator:description("Fibonacci Bollinger Bands");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	
	indicator.parameters:addGroup("Calculation");
    --indicator.parameters:addInteger("MF", "Fibonacci Bollinger Bands Period", "", 20);
	
	indicator.parameters:addInteger("Lookback1", "MA Lookback Period", "Lookback Period", 300);
    indicator.parameters:addDouble("Barrier1", "MA Barrier", "Barrier", 2);
	
	
	
	indicator.parameters:addBoolean("Method", "Use Resetting ATR", "", true);
    indicator.parameters:addInteger("AF", "Classical ATR Period", "", 20);
	
	
	indicator.parameters:addInteger("Lookback2", "ATR Lookback Period", "Lookback Period", 300);
    indicator.parameters:addDouble("Barrier2", "ATR Barrier", "Barrier", 2);
	
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
--local MF;
local Lookback1;
local Barrier1;
local Lookback2;
local Barrier2;


local AF;
local Method;

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

local Raw11;
local Raw12;
local Period1;

local Raw21;
local Raw22;
local Period2;
local TF;
local tAbs = math.abs;

-- Routine
function Prepare(nameOnly)   

    
	local i;
	
   -- MF = instance.parameters.MF;
   Lookback1= instance.parameters.Lookback1;
   Barrier1= instance.parameters.Barrier1;

	AF = instance.parameters.AF;
	Method = instance.parameters.Method;
	
	
	Lookback2= instance.parameters.Lookback2;
    Barrier2= instance.parameters.Barrier2;
   
	for i = 1, 3 , 1 do
	FC[i]= instance.parameters:getColor("FC".. i);
	F[i]= instance.parameters:getDouble("F".. i);
	Style[i]=instance.parameters:getString("style".. i);
    Width[i]=instance.parameters:getString("width".. i);
	end
    source = instance.source;
    first = source:first();
	
	   local name = profile:id() .. "(" .. source:name() .. ", " .. Lookback1 .. ", " ..  Barrier1 ..", ".. AF.. ", " .. F[1] .. ", " .. F[3] .. ", " .. F[3] .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	Raw11 = instance:addInternalStream(0, 0);
    Raw12 = instance:addInternalStream(0, 0);   
	Period1 = instance:addInternalStream(0, 0); 
	 if Method then 
	 Raw21 = instance:addInternalStream(0, 0);
    Raw22 = instance:addInternalStream(0, 0);   
	Period2 = instance:addInternalStream(0, 0); 
	TR = instance:addInternalStream(0, 0);
	 else
	 ATR = core.indicators:create("ATR", source, AF);
    end
	
 
	
    CENTRAL = instance:addStream("Central", core.Line, name .. ".Central", "CL", instance.parameters.CC, source:first() );
	for i=1,3,1 do
    Fibonacci[i] = instance:addStream("Fibonacci"..i, core.Line, name .. ".F"..i, "F"..i, FC[i],   source:first() );
	Fibonacci[i]:setWidth(Width[i]);
    Fibonacci[i]:setStyle(Style[i]);
	Fibonacci[i+3] = instance:addStream("Fibonacci"..(i+3), core.Line, name .. ".F"..i, "F"..i, FC[i],  source:first() );
	Fibonacci[i+3]:setWidth(Width[i]);
    Fibonacci[i+3]:setStyle(Style[i]);
	end
end

function getTrueRange(period)
    local hl = tAbs(source.high[period] - source.low[period]);
    local hc = tAbs(source.high[period] - source.close[period - 1]);
    local lc = tAbs(source.low[period] - source.close[period - 1]);

    local tr = hl;
    if (tr < hc) then
        tr = hc;
    end
    if (tr < lc) then
        tr = lc;
    end
    return tr;
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)

    
     Raw11[period]   =	(source[period]-source[period-1])/source[period];	
 	 Raw12[period]   = (source[period-1]-source[period])/source[period];
	 
	 
	 if period < Lookback1 then
	 return;
	 end
	 
	 
	 local  Average = mathex.avg(Raw11, period-Lookback1+1, period);
       
	    local j; 
		local  Variance=0;
		
		for j = 0, Lookback1, 1 do			 
		Variance =Variance+ math.pow( (Raw12[period-j] - Average),2);				
		end
					
		local  sDev = math.sqrt( Variance/Lookback1 );
		local  sDevNow = ((source[period]-source[period-1])/source[period])/ sDev;
			
		 
		if  math.abs(sDevNow) > Barrier1 then
		Period1[period]=1;
        else
		Period1[period]=Period1[period-1]+ 1;
        end		
			
		if period < Period1[period] then
        return;
        end
	   
	   
	
		--SMA:update(mode);
		
		 if Method then 


         TR[period] = getTrueRange(period);		 
		 
          Raw21[period]   =	(TR[period]-source[period-1])/TR[period];	
 	      Raw22[period]   = (TR[period-1]-TR[period])/TR[period];	

  
  
          if period < Lookback2 then
	      return;
	     end
	 
	 
	   local  Average = mathex.avg(Raw21, period-Lookback2+1, period);
       
	    local j; 
		local  Variance=0;
		
		for j = 0, Lookback2, 1 do			 
		Variance =Variance+ math.pow( (Raw22[period-j] - Average),2);				
		end
					
		local  sDev = math.sqrt( Variance/Lookback2 );
		local  sDevNow = ((TR[period]-TR[period-1])/TR[period])/ sDev;
			
		 
		if  math.abs(sDevNow) > Barrier2 then
		Period2[period]=1;
        else
		Period2[period]=Period2[period-1]+ 1;
        end		
			
		if period < Period2[period] then
        return;
        end
		  
		  ATR_Value = mathex.avg(TR, period-Period2[period]+1, period);
		 else
		 ATR:update(mode);
		 end
		 

		
		  
		
        CENTRAL[period] = mathex.avg(source, period-Period1[period]+1, period);
		
		
		local i;
		for i=1,3, 1 do
			if Method then 
			Fibonacci[i][period] = CENTRAL[period]+ATR_Value*F[i];
			Fibonacci[i+3][period] = CENTRAL[period]-ATR_Value*F[i];
			else
			Fibonacci[i][period] = CENTRAL[period]+ATR.DATA[period]*F[i];
			Fibonacci[i+3][period] = CENTRAL[period]-ATR.DATA[period]*F[i];
			end
	    end
    
end


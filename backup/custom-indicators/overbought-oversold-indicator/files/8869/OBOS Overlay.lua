-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3664

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
    indicator:name("Overbought/Oversold Indicator Overlay");
    indicator:description("Overbought/Oversold Indicator Overlay");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("PERIOD", "Period", "", 9);
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UP_color", "Color of UP", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("DN_color", "Color of DOWN", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("OB_color", "Color of Overbought/Oversold", "", core.rgb(0, 0, 255));
	indicator.parameters:addColor("Neutral", "Color of Neutral", "", core.rgb(128, 128, 128));  
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local PERIOD;

local first;
local FIRST;

local open=nil;
local close=nil;
local high=nil;
local low=nil;

local source = nil;

-- Streams block
local open,low, high, close;
local MA={};
local BUFFER={};
local iopen, iclose, ihigh, ilow;
local UP, DOWN;
-- Routine
function Prepare(nameOnly)
    PERIOD = instance.parameters.PERIOD;
    source = instance.source;
    FIRST = source:first();

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(PERIOD) .. ")";
    instance:name(name);

    if   (nameOnly) then
        return;
    end	
	    
	      BUFFER[1]= instance:addInternalStream(FIRST, 0);	
		  BUFFER[2]= instance:addInternalStream(FIRST, 0);	
          BUFFER[3]= instance:addInternalStream(FIRST, 0);		 
          BUFFER[4]= instance:addInternalStream(FIRST, 0);			   
		  BUFFER[5]= instance:addInternalStream(FIRST, 0);				
		  BUFFER[6]= instance:addInternalStream(FIRST, 0);		 
		  
		  UP= instance:addInternalStream(FIRST, 0);
		  DOWN= instance:addInternalStream(FIRST, 0);		  
		  
	      MA[1] = core.indicators:create("EMA", BUFFER[1],  PERIOD);
	      MA[2] = core.indicators:create("EMA", BUFFER[5],  PERIOD);
		  MA[3] = core.indicators:create("EMA",  BUFFER[6],  PERIOD);
		  MA[4] = core.indicators:create("EMA", UP,  PERIOD);
		   first = MA[4].DATA:first();

   
	
    iopen= instance:addInternalStream(0, 0);
	iclose= instance:addInternalStream(0, 0);
	--ilow= instance:addInternalStream(0, 0);
	--ihigh= instance:addInternalStream(0, 0);
		  
    open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first)
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first)
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first)
    instance:createCandleGroup("ZONE", "", open, high, low, close);
 
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)


    high[period]= source.high[period];
	low[period]= source.low[period];		   
	close[period] = source.close[period];
	open[period]  = source.open[period];

   open:setColor(period, instance.parameters.Neutral);	
	

    if period < FIRST or not source:hasData(period) then
        return;		
    end
	
    
	BUFFER[1][period]=(source.high[period]+source.low[period]+source.close[period]*2)/4;
	
  	
	MA[1]:update(mode);	
	BUFFER[3][period]= MA[1].DATA[period];
	
	if  period <  FIRST + PERIOD  then
	return;
	end
		
	
	BUFFER[4][period] = mathex.stdev (BUFFER[1], period - PERIOD, period);
	
		
	BUFFER[5][period] =  (BUFFER[1][period]  - BUFFER[3][period]) *100  / BUFFER[4][period];

	MA[2]:update(mode);
	BUFFER[6][period]= MA[2].DATA[period] ;

	MA[3]:update(mode);
	UP[period]=MA[3].DATA[period];

	MA[4]:update(mode);
	DOWN[period] =MA[4].DATA[period];
	
	--[[if UP[period]< DOWN[period] then
	iopen[period] = UP[period];
	iclose[period] = DOWN[period];
	else
	iopen[period] = DOWN[period];
	iclose[period] = UP[period];
	end
	
	ihigh[period] = math.max(iopen[period], iclose[period]);
	ilow[period] = math.min(iopen[period], iclose[period]); 
	 
	
	if iopen[period-1] < iopen[period] and iclose[period]< iclose[period-1] then
	open:setColor(period, instance.parameters.OB_color);
	else
		if UP[period] > DOWN[period] then 
		open:setColor(period, instance.parameters.UP_color);
		else
		open:setColor(period, instance.parameters.DN_color);
		end
	end]]
	
	
	if UP[period] < DOWN[period] then
        iclose[period] = UP[period];
        iopen[period]  = DOWN[period];
    else
        iopen[period] = DOWN[period];
       iclose[period]  = UP[period];
    end

 
    
    if iopen[period - 1] < iopen[period] and iclose[period-1] < iclose[period ] then
        open:setColor(period, instance.parameters.UP_color);
    elseif iopen[period - 1] > iopen[period] and iclose[period-1] > iclose[period ] then
         open:setColor(period, instance.parameters.DN_color);	
    else
         open:setColor(period, instance.parameters.OB_color);	
    end
	
	
end
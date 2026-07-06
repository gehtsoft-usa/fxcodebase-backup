-- Id: 16358

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63669

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
    indicator:name("Overbought/Oversold Indicator");
    indicator:description("Overbought/Oversold Indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    
    local colour = core.colors();

    indicator.parameters:addInteger("PERIOD", "Period", "", 9);
    indicator.parameters:addInteger("OB_level", "OB level", "", 100);
    indicator.parameters:addInteger("OS_level", "OS level", "", -100);
    indicator.parameters:addColor("UP_color", "Color of UP", "", colour.Lime);
    indicator.parameters:addColor("DN_color", "Color of DOWN", "", colour.Red);
    indicator.parameters:addColor("OBOS_color", "Color of Overbought/Oversold", "", colour.Blue);
    indicator.parameters:addColor("ZL_color", "Zero line color", "", colour.Yellow);
    indicator.parameters:addColor("OB_color", "OB line color", "", colour.Magenta);
    indicator.parameters:addColor("OS_color", "OS line color", "", colour.Magenta);
    indicator.parameters:addColor("MID_color", "Mid line color", "", colour.Gray);
    indicator.parameters:addColor("OB_shade_color", "OB shading color", "", colour.Pink);
    indicator.parameters:addColor("OS_shade_color", "OS shading color", "", colour.Cyan);
    indicator.parameters:addInteger("widthLinReg", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
    indicator.parameters:addInteger("transparency", "Transparency percentage", "", 50, 0, 100);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local PERIOD;

local first;
local FIRST;

local source = nil;

-- Streams block
local open,low, high, close;
local MA={};
local BUFFER={};

local UP, DOWN;
-- Routine
function Prepare(nameOnly)
    PERIOD = instance.parameters.PERIOD;
    source = instance.source;
    FIRST = source:first();

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(PERIOD) .. ")";
    instance:name(name);

    if nameOnly then
        return
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

 
        open=instance:addStream("open", core.Line, name, "open", core.rgb(128, 128, 128), first);
    open:setPrecision(math.max(2, instance.source:getPrecision()));
		high=instance:addStream("high", core.Line, name, "high", core.rgb(128, 128, 128), first);
    high:setPrecision(math.max(2, instance.source:getPrecision()));
		low=instance:addStream("low", core.Line, name, "low", core.rgb(128, 128, 128), first);
    low:setPrecision(math.max(2, instance.source:getPrecision()));
		close=instance:addStream("close", core.Line, name, "close", core.rgb(128, 128, 128), first);
    close:setPrecision(math.max(2, instance.source:getPrecision()));
		instance:createCandleGroup("OBOS", "", open, high, low, close);
        mid=instance:addStream("MID", core.Line, name.."MID", "MID", instance.parameters.MID_color, first);
    mid:setPrecision(math.max(2, instance.source:getPrecision()));
 
        open:addLevel(0, instance.parameters.styleLinReg, instance.parameters.widthLinReg, instance.parameters.ZL_color);
        open:addLevel(instance.parameters.OB_level, instance.parameters.styleLinReg, instance.parameters.widthLinReg, instance.parameters.OB_color);
        open:addLevel(instance.parameters.OS_level, instance.parameters.styleLinReg, instance.parameters.widthLinReg, instance.parameters.OS_color);
            
        out1 = instance:addInternalStream(first, 0);
        out2 = instance:addInternalStream(first, 0);
        instance:createChannelGroup("ZONE", "ZONE", out1, out2, core.rgb(128, 128, 128), 100 - instance.parameters.transparency, true);

end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)
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

	open[period] = DOWN[period];
	close[period] = UP[period];
	high[period] = math.max(open[period], close[period]);
    low[period] = math.min(open[period], close[period]);
	
    if low[period-1] < low[period] and high[period]< high[period-1] then
        open:setColor(period, instance.parameters.OBOS_color);
	else
		if UP[period] > DOWN[period] then 
		open:setColor(period, instance.parameters.UP_color);
		else
		open:setColor(period, instance.parameters.DN_color);
		end
	end
	
	mid[period] = (high[period] + low[period])/2;
    
    if mid[period] >= instance.parameters.OB_level then
        out1[period] = 1000;
        out2[period] = -1000;
        out1:setColor(period, instance.parameters.OB_shade_color);
    elseif mid[period] <= instance.parameters.OS_level then
        out1[period] = 1000;
        out2[period] = -1000;
        out1:setColor(period, instance.parameters.OS_shade_color);
    else
        out1[period] = nil;
        out2[period] = nil;
    end
end

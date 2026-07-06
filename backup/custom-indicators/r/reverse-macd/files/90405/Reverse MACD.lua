-- Id: 10301
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59742

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Reverse MACD");
    indicator:description("A trend-following momentum indicator that shows the relationship between two moving averages of prices.");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Selection"); 
 
	indicator.parameters:addGroup("Calculation"); 	
    indicator.parameters:addInteger("x", "Short MA", "The period of the short  MA.", 12, 2, 1000);
    indicator.parameters:addInteger("y", "Long  MA", "The period of the long  MA.", 26, 2, 1000);
    indicator.parameters:addInteger("z", "Signal line", "The number of periods for the signal line.", 9, 2, 1000);
	
    indicator.parameters:addInteger("type", "MA Method", "Method" , 1);
    indicator.parameters:addIntegerAlternative("type", "MVA", "MVA" , 1);
    indicator.parameters:addIntegerAlternative("type", "EMA", "EMA" , 2);
			
	indicator.parameters:addGroup("Style"); 
	indicator.parameters:addColor("MACD_color", "MACD color", "The color of MACD.", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("SIGNAL_color", "Signal color", "The color of SIGNAL.", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("Histogram_Color", "Histogram Color",  "The color of   Histogram.", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local x;
local y;
local z;

local type;
local source = nil;

-- Streams block
local MACD = nil; 
local SIGNAL=nil;
local HISTOGRAM=nil;
local ax, ay,az; 
local xEMA, yEMA;
local xSMA, ySMA;
local smacd,cmacd;
-- Routine
function Prepare(nameOnly)
   type = instance.parameters.type;
    x = instance.parameters.x;
    y = instance.parameters.y;
    z = instance.parameters.z; 
	
	ax= 2/(x+1);
	ay= 2/(y+1);
	az= 2/(z+1);
    source = instance.source;

    -- Check parameters
    if (y <= x) then
       error("The short MA period must be smaller than long MA period");
    end
    local Label;
	
	if type == 1 then
	Label="MVA";
	else
	Label="EMA";
	end
    local name = profile:id() .. "(" .. source:name() .. ", " .. x .. ", " .. y .. ", " .. z .. ", " .. Label .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	
	xSMA = core.indicators:create("MVA", source, x);
	ySMA = core.indicators:create("MVA", source, y);
	
	 xEMA = core.indicators:create("EMA", source, x);
	 yEMA = core.indicators:create("EMA", source, y);
	 
	 smacd = instance:addInternalStream(0, 0);
	 cmacd = instance:addInternalStream(0, 0);
	 
	 zSMA = core.indicators:create("MVA", smacd, z);	
	 zEMA = core.indicators:create("EMA", cmacd, z);
 
    MACD = instance:addStream("MACD", core.Line, name .. ".MACD", "MACD", instance.parameters.MACD_color, math.max(x, y ));
	MACD:setWidth(instance.parameters.width1);
    MACD:setStyle(instance.parameters.style1);
 
    SIGNAL = instance:addStream("SIGNAL", core.Line, name .. ".SIGNAL", "SIGNAL", instance.parameters.SIGNAL_color, math.max(x, y ));
	SIGNAL:setWidth(instance.parameters.width2);
    SIGNAL:setStyle(instance.parameters.style2);
    HISTOGRAM = instance:addStream("HISTOGRAM", core.Line, name .. "HISTOGRAM", "HISTOGRAM", instance.parameters.Histogram_Color, math.max(x, y, z));
	HISTOGRAM:setWidth(instance.parameters.width3);
    HISTOGRAM:setStyle(instance.parameters.style3);
	
end
 
 
-- Indicator calculation routine
function Update(period, mode)

 

	 
	 if type == 2 then
	 
	  xEMA:update(mode);
     yEMA:update(mode);

		 if period <  yEMA.DATA:first()  then
		return;
		end
	 
	  cmacd[period]= xEMA.DATA[period] - yEMA.DATA[period];  
	 
	 zEMA:update(mode);
	 
	   if period <  zEMA.DATA:first()  then
		return;
		end 

	 
	 peflat= (ax* xEMA.DATA[period] - ay*yEMA.DATA[period])/(ax-ay);
	 peeq0= ((1-ay)*yEMA.DATA[period] - (1-ax)* xEMA.DATA[period])/(ax-ay);
     pesig= (zEMA.DATA[period] - (1-ax)* xEMA.DATA[period] + (1-ay)*yEMA.DATA[period])/(ax-ay);
	
	MACD[period] = peflat;
	SIGNAL[period] =  peeq0;
	HISTOGRAM[period]=pesig;  
	else
	
	xSMA:update(mode);
    ySMA:update(mode);
	
	if period <  ySMA.DATA:first()  then
	return;
	end
	
	smacd[period]= xSMA.DATA[period] - ySMA.DATA[period];
	
	zSMA:update(mode);
	
	   if period <  zSMA.DATA:first()  then
		return;
		end 
	 psflat= (x*source[period-y+1] - y*source[period-x+1])/(x-y);
	 pseq0= (x*y*(xSMA.DATA[period]-ySMA.DATA[period])+x*source[period-y+1]-y*source[period-x+1])/(x-y);
	 pssig= ((x*y*z - x*y)*smacd[period] - x*y*z*zSMA.DATA[period] -(y*z - y)*source[period-x+1] + (x*z-x)*source[period-y+1] +x*y * smacd[period-z+1]  )/(x*z-y*z-x+y);


    MACD[period] = psflat;
	SIGNAL[period] =pseq0;
	HISTOGRAM[period] =pssig; 
    end	
				 
			
	
end



-- Id: 11123

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60294

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
function Init()
    indicator:name("Ticks Volume Indicator Histogram ");
    indicator:description("Ticks Volume Indicator Histogram");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

 
 indicator.parameters:addGroup("Calculation"); 
	indicator.parameters:addInteger("r", "First Smoothing", "r", 12);
    indicator.parameters:addInteger("s",  "Second Smoothing", "", 12);


    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up", "Up Color", "Up Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Down", "Down Color", "Down Color", core.rgb(255, 0, 0));
end

local first;
local source = nil;
local Histogram;

local r;
local s;
 

local  FIRST;
local TVI = nil;
local UpTicks, DownTicks
local EMA_UpTicks, DEMA_UpTicks;
local EMA_DownTicks, DEMA_DownTicks;




 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	
    source = instance.source;
	
	r = instance.parameters.r;
    s = instance.parameters.s; 
    source = instance.source;
    first = source:first();
	
	UpTicks= instance:addInternalStream(first, 0);
	DownTicks= instance:addInternalStream(first, 0);
	
	EMA_UpTicks=core.indicators:create("EMA",UpTicks , r);
	EMA_DownTicks=core.indicators:create("EMA",DownTicks , r);
	
   
    DEMA_UpTicks= core.indicators:create("EMA",EMA_UpTicks.DATA , r);
	DEMA_DownTicks=core.indicators:create("EMA",EMA_DownTicks.DATA , r);
	
   FIRST= DEMA_UpTicks.DATA:first();

   

   
        TVI = instance:addInternalStream(source:first() + 1, 0);
 
   
    Histogram = instance:addStream("Histogram", core.Bar, name .. "Histogram", "Histogram", instance.parameters.Up, first);
    Histogram:setPrecision(math.max(2, instance.source:getPrecision()));
	 Histogram:addLevel(0, core.LINE_NONE , 1, core.rgb(128, 128, 128));    
	 Histogram:addLevel(1, core.LINE_NONE , 1, core.rgb(128, 128, 128));  	
 

end

function Update(period, mode)

Histogram[period]=1;

if period < first or not source:hasData(period) then
return;
end

 
Calculate(period, mode);

	if  TVI[period]>  TVI[period-1] then
	Histogram:setColor(period, instance.parameters.Up);
	else
	Histogram:setColor(period, instance.parameters.Down);
	end
end


function Calculate(period, mode)
  
    
    
    UpTicks[period]=(source.volume[period]+(source.close[period]-source.open[period])/source:pipSize())/2;
    DownTicks[period]=source.volume[period]-UpTicks[period];
	
	
	EMA_UpTicks:update(mode);
	DEMA_UpTicks:update(mode);  
	
	EMA_DownTicks:update(mode);
	DEMA_DownTicks:update(mode);  
	
	 if period <  FIRST then
	return;
	end
	
	  
      TVI[period] =100.0*(DEMA_UpTicks.DATA[period]-DEMA_DownTicks.DATA[period])/(DEMA_UpTicks.DATA[period]+DEMA_DownTicks.DATA[period]);
    
end


-- Id: 18896

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65023

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


function Init()
    indicator:name("Guppy mma oscillator binary");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

	indicator.parameters:addGroup("Calculation");
	
	indicator.parameters:addInteger("SignalPeriod", "Signal Period", "", 13);   
	indicator.parameters:addBoolean("ZeroLineCrosses", "Zero Line Crosses", "", true);   
	indicator.parameters:addGroup("Style ");
 
    indicator.parameters:addInteger("width", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
 
	
	indicator.parameters:addColor("color1", "Line Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("color2", "Signal Line Color", "", core.rgb(255, 0, 0));
end

local source = nil;
local EMAs = {};    -- an array of outputs
local buffer1,buffer2;
local buffer3,buffer4;
local ZeroLineCrosses;
local alpha;
local SignalPeriod;
function CreateEMA(index )
 
    -- create the line
    EMAs[index] = instance:addInternalStream(0, 0);
				
end

function Prepare(nameOnly)
    source = instance.source;
    local name;
	
	ZeroLineCrosses=instance.parameters.ZeroLineCrosses;
	SignalPeriod=instance.parameters.SignalPeriod;

    -- set the indicator name (use the short name of our indicator: GMMA)
    name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end

    CreateEMA(0);
    CreateEMA(1);
    CreateEMA(2);
    CreateEMA(3);
    CreateEMA(4);
    CreateEMA(5);

    CreateEMA(6);
    CreateEMA(7);
    CreateEMA(8);
    CreateEMA(9);
    CreateEMA(10);
    CreateEMA(11);
	
	
	  buffer3= instance:addInternalStream(0, 0);
	  buffer4= instance:addInternalStream(0, 0);
	
	  buffer1 = instance:addStream("Line", core.Line, name .. "Line", "Line", instance.parameters.color1, source:first());				
    buffer1:setPrecision(math.max(2, instance.source:getPrecision()));
	  buffer1:setWidth(instance.parameters.width);
	  buffer1:setStyle(instance.parameters.style);
	  
	  buffer2 = instance:addStream("Signal", core.Line, name .. "Signal", "Signal", instance.parameters.color2, source:first());				
    buffer2:setPrecision(math.max(2, instance.source:getPrecision()));
	  buffer2:setWidth(instance.parameters.width);
	  buffer2:setStyle(instance.parameters.style);
	  
	  alpha = 2.0/(1.0+SignalPeriod);
end

function CalcEMA(index, N, period)
    local first;

    first = source:first() + N - 1;
    if period < first then
       return ;
    elseif period == first then
       -- range: period - N + 1, period - N + 2, ..., period
       local range = core.rangeTo(period, N);
       EMAs[index][period] = core.avg(source, range);
    else
       local k;
       k = 2.0 / (N + 1.0);
       -- EMA - PRICE * K - PREV EMA * (1 - K)
       EMAs[index][period] = source[period] * k + EMAs[index][period - 1] * (1 - k);
    end
	
	
end

function Update(period)
    CalcEMA(0, 3, period);
    CalcEMA(1, 5, period);
    CalcEMA(2, 8, period);
    CalcEMA(3, 10, period);
    CalcEMA(4, 12, period);
    CalcEMA(5, 15, period);

    CalcEMA(6, 30, period);
    CalcEMA(7, 35, period);
    CalcEMA(8, 40, period);
    CalcEMA(9, 45, period);
    CalcEMA(10, 50, period);
    CalcEMA(11, 60, period);
	
	
	local Sum=0;
	
	for i= 0, 11 , 1 do		
		if i< 6 then
		Sum=Sum+EMAs[i][period];
		else
		Sum=Sum-EMAs[i][period];
		end
	end
  
	
	  buffer3[period] = Sum*10.0;
      buffer4[period] = buffer4[period-1]+alpha*(buffer3[period]-buffer4[period-1]);
	
	
	 if ZeroLineCrosses  then
         
            if (buffer3[period] > 0) then buffer1[period]= 1; buffer2[period]=-1; end
            if (buffer3[period]< 0)  then buffer1[period]=-1; buffer2[period]= 1; end
        
    else
 
            if (buffer3[period] > buffer4[period]) then  buffer1[period]= 1; buffer2[period]=-1; end
            if (buffer3[period] < buffer4[period])  then  buffer1[period]=-1; buffer2[period]= 1; end
    end
	
 
	
end



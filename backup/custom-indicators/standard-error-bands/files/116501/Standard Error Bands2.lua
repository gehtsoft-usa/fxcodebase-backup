
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62102

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
    indicator:name("Standard Error Bands");
    indicator:description("Standard Error Bands");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period", "Period", "Period", 21);
    indicator.parameters:addInteger("Smoothing", "Smoothing period", "Smoothing period", 3);
    indicator.parameters:addDouble("Multiplier", "Multiplier", "Multiplier", 1);
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("Top_color", "Color of Top", "Color of Top", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("Central_color", "Color of Central", "Color of Central", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("Bottom_color", "Color of Bottom", "Color of Bottom", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;
local Smoothing;
local Multiplier;

local first;
local source = nil;

-- Streams block
local Top1, Top2 = nil, nil;
local Central = nil;
local Bottom1, Bottom2 = nil, nil;
local Raw;

local RawT1, RawT2, RawB1, RawB2;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
    Smoothing = instance.parameters.Smoothing;
    Multiplier = instance.parameters.Multiplier;
    source = instance.source;
	
    first = source:first()+Period;

	
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ", " .. tostring(Smoothing) .. ", " .. tostring(Multiplier) .. ")";
    instance:name(name);
    if   (nameOnly) then
        return;
    end
	
	
	Raw = instance:addInternalStream(first, 0);
    RawT1 = instance:addInternalStream(first, 0);
    RawT2 = instance:addInternalStream(first, 0);
    RawB1 = instance:addInternalStream(first, 0);
    RawB2 = instance:addInternalStream(first, 0);
   
        Top1 = instance:addStream("Top1", core.Line, name .. ".Top1", "Top1", instance.parameters.Top_color, first+Smoothing);
        Top1:setWidth(instance.parameters.width1);
        Top1:setStyle(instance.parameters.style1);
        Top2 = instance:addStream("Top2", core.Line, name .. ".Top2", "Top2", instance.parameters.Top_color, first+Smoothing);
        Top2:setWidth(instance.parameters.width1);
        Top2:setStyle(instance.parameters.style1);
		
        Central = instance:addStream("Central", core.Line, name .. ".Central", "Central", instance.parameters.Central_color, first+Smoothing);
		Central:setWidth(instance.parameters.width2);
        Central:setStyle(instance.parameters.style2);
		
        Bottom1 = instance:addStream("Bottom1", core.Line, name .. ".Bottom1", "Bottom1", instance.parameters.Bottom_color, first+Smoothing);
        Bottom1:setWidth(instance.parameters.width3);
        Bottom1:setStyle(instance.parameters.style3);
        Bottom2 = instance:addStream("Bottom2", core.Line, name .. ".Bottom2", "Bottom2", instance.parameters.Bottom_color, first+Smoothing);
        Bottom2:setWidth(instance.parameters.width3);
        Bottom2:setStyle(instance.parameters.style3);
		
    
end

function alphabeta(index, L)
    local i;
    local sum1, sum2, sum3, sum4, sum5=0, 0, 0, 0, 0;

    for i=1, L, 1 do
        sum1=sum1+i*source[index-L+i];
        sum2=sum2+i;
        sum3=sum3+source[index-L+i];
        sum4=sum4+i*i;
    end

    local val1=sum1-sum2*sum3/L;
    local val2=sum4-sum2*sum2/L;

    return sum3/L-val1*sum2/(val2*L), val1/val2;
end

function Update(period)

    if period < first or not source:hasData(period) then
	return;
	end
	
	Raw[period]= mathex.lreg (source, period-Period+1, period);
	
	 if period < first + Smoothing then
	 return;
	 end
	
	
       
        Central[period] = mathex.avg(Raw, period-Smoothing+1,period);

    local i;
    local sum1, sum2, sum3, sum4, sum5, sum6=0, 0, 0, 0, 0, 0;

    for i=1, Period, 1 do
        sum1=sum1+i*source[period-Period+i];
        sum2=sum2+i;
        sum3=sum3+source[period-Period+i];
        sum4=sum4+i*i;
        sum5=sum5+source[period-Period+i]*source[period-Period+i];
        sum6=sum6+(Raw[period-Period+i]-source[period-Period+i])*(Raw[period-Period+i]-source[period-Period+i]);
    end

    local val1=sum1-sum2*sum3/Period;
    local val2=sum4-sum2*sum2/Period;

    local A, B=sum3/Period-val1*sum2/(val2*Period), val1/val2;

        val1=sum5-(A*sum3)-(B*sum1);
        val2=Period-2;
        local narrow=math.sqrt(val1/val2);
        local est=sum6/val2;
        local wide=math.sqrt(est);

        RawT1[period]=Raw[period]+Multiplier*narrow;
        RawT2[period]=Raw[period]+Multiplier*wide;

        RawB1[period]=Raw[period]-Multiplier*narrow;
        RawB2[period]=Raw[period]-Multiplier*wide;

        Top1[period]=mathex.avg(RawT1, period-Smoothing+1,period);
        Top2[period]=mathex.avg(RawT2, period-Smoothing+1,period);

        Bottom1[period]=mathex.avg(RawB1, period-Smoothing+1,period);
        Bottom2[period]=mathex.avg(RawB2, period-Smoothing+1,period);
end


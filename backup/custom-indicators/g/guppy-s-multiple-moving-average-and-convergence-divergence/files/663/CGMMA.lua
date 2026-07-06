--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+

local Period ={3,5,8,10,12,15,30,35,40,45,50,60};

function Init()
    indicator:name("Customizable Guppy's Multiple Moving Average");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

	local i;
	indicator.parameters:addGroup("Calculation");
	for i =1, 12, 1 do 	
		indicator.parameters:addInteger("Period"..i, "Period", "", Period[i]);
	end

    indicator.parameters:addGroup("Style ");	
	for i =1, 12, 1 do 
    indicator.parameters:addInteger("widtd"..i, "Line ".. i.. ". Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style"..i, "Line "..i..". Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style"..i, core.FLAG_LINE_STYLE);
	end
	
	indicator.parameters:addColor("S_COLOR", "Color for the short EMA group", "", core.rgb(0, 0, 255));
    indicator.parameters:addColor("L_COLOR", "Color for the long EMA group", "", core.rgb(255, 0, 0));

end

local source = nil;
local EMAs = {};    -- an array of outputs

function CreateEMA(index, N,  color, name, width,style)
    local label;
    	-- line label
  
	label = "EMA" .. N;
    -- create the line
	
	
    EMAs[index] = instance:addStream(label, core.Line, name .. label, label,
                                     color, source:first() + N - 1);
									 
	EMAs[index]:setWidth(width);
	EMAs[index]:setStyle(style);								 
end

function Prepare()
    source = instance.source;
    local name;

    -- set the indicator name (use the short name of our indicator: GMMA)
    name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);

    CreateEMA(0, instance.parameters:getInteger("Period" .. 1), instance.parameters.S_COLOR, name,instance.parameters:getInteger("widtd" .. 1),instance.parameters:getInteger("style" .. 1));
    CreateEMA(1, instance.parameters:getInteger("Period" .. 2), instance.parameters.S_COLOR, name,instance.parameters:getInteger("widtd" .. 2),instance.parameters:getInteger("style" .. 2));
    CreateEMA(2, instance.parameters:getInteger("Period" .. 3), instance.parameters.S_COLOR, name,instance.parameters:getInteger("widtd" .. 3),instance.parameters:getInteger("style" .. 3));
    CreateEMA(3, instance.parameters:getInteger("Period" .. 4), instance.parameters.S_COLOR, name,instance.parameters:getInteger("widtd" .. 4 ),instance.parameters:getInteger("style" .. 4));
    CreateEMA(4, instance.parameters:getInteger("Period" .. 5), instance.parameters.S_COLOR, name,instance.parameters:getInteger("widtd" .. 5 ),instance.parameters:getInteger("style" .. 5));
    CreateEMA(5, instance.parameters:getInteger("Period" .. 6), instance.parameters.S_COLOR, name,instance.parameters:getInteger("widtd" .. 6 ),instance.parameters:getInteger("style" .. 6));

    CreateEMA(6, instance.parameters:getInteger("Period" .. 7), instance.parameters.L_COLOR, name,instance.parameters:getInteger("widtd" .. 7),instance.parameters:getInteger("style" .. 7));
    CreateEMA(7, instance.parameters:getInteger("Period" .. 8), instance.parameters.L_COLOR, name,instance.parameters:getInteger("widtd" .. 8 ),instance.parameters:getInteger("style" .. 8));
    CreateEMA(8, instance.parameters:getInteger("Period" .. 9), instance.parameters.L_COLOR, name,instance.parameters:getInteger("widtd" .. 9),instance.parameters:getInteger("style" .. 9));
    CreateEMA(9, instance.parameters:getInteger("Period" .. 10), instance.parameters.L_COLOR, name,instance.parameters:getInteger("widtd" .. 10),instance.parameters:getInteger("style" .. 10));
    CreateEMA(10, instance.parameters:getInteger("Period" .. 11), instance.parameters.L_COLOR, name,instance.parameters:getInteger("widtd" .. 11),instance.parameters:getInteger("style" .. 11));
    CreateEMA(11, instance.parameters:getInteger("Period" .. 12), instance.parameters.L_COLOR, name,instance.parameters:getInteger("widtd" .. 12 ),instance.parameters:getInteger("style" .. 12));
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
    CalcEMA(0, instance.parameters:getInteger("Period" .. 1), period);
    CalcEMA(1, instance.parameters:getInteger("Period" .. 2), period);
    CalcEMA(2, instance.parameters:getInteger("Period" .. 3), period);
    CalcEMA(3, instance.parameters:getInteger("Period" .. 4), period);
    CalcEMA(4, instance.parameters:getInteger("Period" .. 5), period);
    CalcEMA(5, instance.parameters:getInteger("Period" .. 6), period);

    CalcEMA(6, instance.parameters:getInteger("Period" .. 7), period);
    CalcEMA(7, instance.parameters:getInteger("Period" .. 8), period);
    CalcEMA(8, instance.parameters:getInteger("Period" .. 9), period);
    CalcEMA(9, instance.parameters:getInteger("Period" .. 10), period);
    CalcEMA(10, instance.parameters:getInteger("Period" .. 11), period);
    CalcEMA(11, instance.parameters:getInteger("Period" .. 12), period);
end



-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=412

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

function Init()
    indicator:name("Guppy's Multiple Moving Average");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

	local i;
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

function CreateEMA(index, N, color, name, width,style)
    local label;
    -- line label
    label = "EMA" .. N;
    -- create the line
    EMAs[index] = instance:addStream(label, core.Line, name .. label, label,
                                     color, source:first() + N - 1);
									 
	EMAs[index]:setWidth(width);
	EMAs[index]:setStyle(style);								 
end

 function Prepare(nameOnly)  
    source = instance.source;
    local name;

    -- set the indicator name (use the short name of our indicator: GMMA)
    name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	

    CreateEMA(0, 3, instance.parameters.S_COLOR, name,instance.parameters:getInteger("widtd" .. 1),instance.parameters:getInteger("style" .. 1));
    CreateEMA(1, 5, instance.parameters.S_COLOR, name,instance.parameters:getInteger("widtd" .. 2),instance.parameters:getInteger("style" .. 2));
    CreateEMA(2, 8, instance.parameters.S_COLOR, name,instance.parameters:getInteger("widtd" .. 3),instance.parameters:getInteger("style" .. 3));
    CreateEMA(3, 10, instance.parameters.S_COLOR, name,instance.parameters:getInteger("widtd" .. 4 ),instance.parameters:getInteger("style" .. 4));
    CreateEMA(4, 12, instance.parameters.S_COLOR, name,instance.parameters:getInteger("widtd" .. 5 ),instance.parameters:getInteger("style" .. 5));
    CreateEMA(5, 15, instance.parameters.S_COLOR, name,instance.parameters:getInteger("widtd" .. 6 ),instance.parameters:getInteger("style" .. 6));

    CreateEMA(6, 30, instance.parameters.L_COLOR, name,instance.parameters:getInteger("widtd" .. 7),instance.parameters:getInteger("style" .. 7));
    CreateEMA(7, 35, instance.parameters.L_COLOR, name,instance.parameters:getInteger("widtd" .. 8 ),instance.parameters:getInteger("style" .. 8));
    CreateEMA(8, 40, instance.parameters.L_COLOR, name,instance.parameters:getInteger("widtd" .. 9),instance.parameters:getInteger("style" .. 9));
    CreateEMA(9, 45, instance.parameters.L_COLOR, name,instance.parameters:getInteger("widtd" .. 10),instance.parameters:getInteger("style" .. 10));
    CreateEMA(10, 50, instance.parameters.L_COLOR, name,instance.parameters:getInteger("widtd" .. 11),instance.parameters:getInteger("style" .. 11));
    CreateEMA(11, 60, instance.parameters.L_COLOR, name,instance.parameters:getInteger("widtd" .. 12 ),instance.parameters:getInteger("style" .. 12));
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
end



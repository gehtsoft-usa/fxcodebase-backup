
-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=62394

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
    indicator:name("Internal Smoothing Algorithm");
    indicator:description("Internal Smoothing Algorithm");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("SmoothPeriod", "Smooth Period", "Smooth Period", 5);
    indicator.parameters:addInteger("SmoothPhase", "Smooth Phase", "Smooth Phase", 0);
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("Output_color", "Color of Output", "Color of Output", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local SmoothPeriod;
local SmoothPhase;

local first;
local source = nil;

local ld_56;
local ld_64;
-- Streams block
local Output = nil;
local Data={};
-- Routine
function Prepare(nameOnly)
    SmoothPeriod = instance.parameters.SmoothPeriod;
    SmoothPhase = instance.parameters.SmoothPhase;
    source = instance.source;
    first = source:first()+SmoothPeriod;
	
	
	local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(SmoothPeriod) .. ", " .. tostring(SmoothPhase) .. ")";
    instance:name(name);

    if   (nameOnly) then
        return;
    end
	
	Data[0] = instance:addInternalStream(0, 0);
	Data[1] = instance:addInternalStream(0, 0);
	Data[2] = instance:addInternalStream(0, 0);
	Data[3] = instance:addInternalStream(0, 0);
	Data[4] = instance:addInternalStream(0, 0);
	Data[5] = instance:addInternalStream(0, 0);
	Data[6] = instance:addInternalStream(0, 0);
	Data[7] = instance:addInternalStream(0, 0);
	Data[8] = instance:addInternalStream(0, 0);
	Data[9] = instance:addInternalStream(0, 0);
	
	ld_56 = math.max(math.log(math.sqrt((SmoothPeriod - 1.0) / 2.0)) / math.log(2.0) + 2.0, 0);
    ld_64 = math.max(ld_56 - 2.0, 0.5);
    
        Output = instance:addStream("Output", core.Line, name, "Output", instance.parameters.Output_color, first);
		Output:setWidth(instance.parameters.width);
        Output:setStyle(instance.parameters.style);
    
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    

	
    if period < first
	or not source:hasData(period) then	
	return;
	end
		
   local  ld_72 = source[period] - (Data[5][period-1]);
   local  ld_80 = source[period]- (Data[6][period-1]);
   
    Data[7][period] = 0;	
	
	if (math.abs(ld_72) > math.abs(ld_80)) then Data [7][period] = math.abs(ld_72); end;
    if (math.abs(ld_72) < math.abs(ld_80)) then Data [7][period] = math.abs(ld_80); end;
	
	if period < 10 then
	return;
	end
	
	Data[8][period] = Data[8][period- 1]  + (Data[7][period]  - (Data[7][period - 10])) / 10.0;   
    local  ld_88 = math.min(math.max(4.0 * SmoothPeriod, 30), 150);
   
    local ld_32;
    if  period <   ld_88   then
    return;
	end
	
	ld_32= ((Data[9][period - 1]) * ld_88 - Data[8][period - ld_88] + (Data[8][period])) / ld_88;
   
    Data[9][period] = ld_32;
	if (Data[ 9][period] > 0.0) then
	ld_40 = (Data[7][period]) / (Data[9][period]);
    else
	ld_40 = 0;
	end
	if (ld_40 > math.pow(ld_56, 1.0 / ld_64))  then ld_40 = math.pow(ld_56, 1.0 / ld_64); end
    if (ld_40 < 1.0)  then  ld_40 = 1.0; end
	
	
	local  ld_96 = math.pow(ld_40, ld_64);
    local ld_104 = math.sqrt((SmoothPeriod - 1.0) / 2.0) * ld_56;
    local ld_112 = math.pow(ld_104 / (ld_104 + 1.0), math.sqrt(ld_96));
	
	if (ld_72 > 0.0)  then 
	Data [5][period] = source[period]; 
	else
	Data[5][period] = source[period] - ld_112 * ld_72;
	end
	
	
	if (ld_80 < 0.0) then
	Data[6][period] = source[period];
    else
    Data[ 6][period] = source[period] - ld_112 * ld_80;
    end
	
	local  ld_120 = math.max(math.min(SmoothPhase, 100), -100) / 100.0 + 1.5;
    local ld_128 = (SmoothPeriod - 1.0) / 2.0 / ((SmoothPeriod - 1.0) / 2.0 + 2.0);
    local ld_136 = math.pow(ld_128, ld_96);
	
	Data[0][period] = source[period] + ld_136 * (Data[0][period-1] - source[period]);
    Data[1][period] = (source[period] - (Data [ 0][period])) * (1 - ld_128) + ld_128 * (Data[1][period - 1]);
    Data[2][period] = Data [0][period] + ld_120 * (Data [1][period]);
    Data[3][period] = (Data[2][period] - (Data [ 4][period-1])) * math.pow(1 - ld_136, 2) + math.pow(ld_136, 2) * (Data[3][period - 1]);
    Data[4][period] = Data[4] [period - 1]+ (Data [3][period]);
	
    Output[period] = Data [4][period];
    
end


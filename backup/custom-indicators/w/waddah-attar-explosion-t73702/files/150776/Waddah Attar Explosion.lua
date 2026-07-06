-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=73702
 

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+
 

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("Waddah Attar Explosion");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "ATR Period", "", 7);	
    indicator.parameters:addInteger("Period1", "Fast Period", "", 20);	
    indicator.parameters:addInteger("Period2", "Slow Period", "", 40);	
    indicator.parameters:addInteger("Period3", "BB Period", "", 20);	
    indicator.parameters:addInteger("Period4", "ATR Period", "", 100);
	indicator.parameters:addInteger("Sensitivity", "Sensitivity", "", 150); 
    indicator.parameters:addDouble("Multiplier", "Multiplier", "", 2);	
    indicator.parameters:addDouble("ATR_Multiplier", "ATR Multiplier", "", 3.7);		
    indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("up", "Color of Up trend", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("up_down", "Color of Down in Up trend", "", core.rgb(0, 200, 0));
    indicator.parameters:addColor("down_up", "Color of Up in Down trend", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("down", "Color of Down trend", "", core.rgb(100, 0, 0));	
    indicator.parameters:addColor("E_color", "Color of explosion line", "", core.rgb(128, 64, 0));
    indicator.parameters:addColor("D_color", "Color of dead zone line", "", core.rgb(128, 128, 128));	
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
	indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local Sensitivity;
local DeadZonePip;
local Period1;
local Period2;
local Period3;
local Multiplier;

local first;
local firstBB;
local source = nil;

-- Streams block
local TG = nil;
local TR = nil;
local E = nil;

local EMAF = nil;
local EMAS = nil; 

-- Routine
function Prepare(nameOnly)
    Sensitivity = instance.parameters.Sensitivity;
    DeadZonePip = instance.parameters.DeadZonePip;
	Period1 = instance.parameters.Period1;
	Period2 = instance.parameters.Period2;
	Period3 = instance.parameters.Period3;
	Period4 = instance.parameters.Period4;	
	Multiplier = instance.parameters.Multiplier;
	ATR_Multiplier= instance.parameters.ATR_Multiplier;
    source = instance.source;


    local name = profile:id() .. "(" .. source:name() .. ", " .. Period1 .. ", " .. Period2.. ", " .. Period3.. ", " .. Period4.. ", " .. Multiplier  .. ", " .. ATR_Multiplier.. ", " .. Sensitivity  .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	
    ATR = core.indicators:create("ATR", source, Period4);	
    EMAF = core.indicators:create("EMA", source.close, Period1);
    EMAS = core.indicators:create("EMA", source.close, Period2);
    first = math.max(EMAS.DATA:first(),EMAF.DATA:first(),ATR.DATA:first());
    firstBB = source:first() + Period3; 
	
    Trend = instance:addStream("Trend", core.Bar, name .. ".Trend", "Trend", instance.parameters.up, first);
    Trend:setPrecision(math.max(2, instance.source:getPrecision()));
    
    ExplosionLine = instance:addStream("ExplosionLine", core.Line, name .. ".ExplosionLine", "ExplosionLine", instance.parameters.E_color, first);
    ExplosionLine:setPrecision(math.max(2, instance.source:getPrecision()));
	ExplosionLine:setWidth(instance.parameters.width);
	ExplosionLine:setStyle(instance.parameters.style);
    ExplosionLine:addLevel(0); 
	
    DeadZoneLine = instance:addStream("DeadZoneLine", core.Line, name .. ".DeadZoneLine", "ExplosionLine", instance.parameters.D_color, first);
    DeadZoneLine:setPrecision(math.max(2, instance.source:getPrecision()));
	DeadZoneLine:setWidth(instance.parameters.width);
	DeadZoneLine:setStyle(instance.parameters.style);
	
end

-- Indicator calculation routine
function Update(period, mode)
    EMAF:update(mode);
    EMAS:update(mode);
    ATR:update(mode); 
    if period < firstBB then
	return;
	end
	
        local p = core.rangeTo(period, Period3)
        local ml = core.avg(source.close, p);
        local d = core.stdev(source.close, p);
        BB_H  = ml + 2 * d;
        BB_L  = ml - 2 * d;
		ExplosionLine[period] =  BB_H  - BB_L;
 

 
        local trend, explosion;
        trend = (MACD(period) - MACD(period - 1)) * Sensitivity; 
        if trend > 0 then
            Trend[period] = trend; 
			
			if Trend[period]>Trend[period-1] then
			Trend:setColor(period, instance.parameters.up);		
            else
			Trend:setColor(period, instance.parameters.up_down);					
            end
			
        elseif trend < 0 then
            Trend[period] = -trend;
			
			if Trend[period]>Trend[period-1] then
			Trend:setColor(period, instance.parameters.down_up);		
            else
			Trend:setColor(period, instance.parameters.down);					
            end
			
        end

    DeadZoneLine[period]=ATR.DATA[period]*ATR_Multiplier
	
	
end

function MACD(period)
    return EMAF.DATA[period] - EMAS.DATA[period];
end

--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
--|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
--|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
--|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
--|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
--|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
--+------------------------------------------------------------------------------------------------+
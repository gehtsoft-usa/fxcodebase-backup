-- Id: 2471
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2068


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
    indicator:name("Trend lord");
    indicator:description("Trend lord");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "Period", 50);
    indicator.parameters:addBoolean("StrategyMode", "Don't change, parameter is for strategies only!!!", "", false);

    indicator.parameters:addGroup("Style");
	  indicator.parameters:addString("Type", "Line/Bar", "", "BAR");
        indicator.parameters:addStringAlternative("Type", "Bar", "", "BAR");
        indicator.parameters:addStringAlternative("Type", "Line", "", "LINE");		
    indicator.parameters:addColor("clrUP", "UP color", "UP color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clrDN", "DN color", "DN color", core.rgb(255, 0, 0));
end

local first;
local source = nil;
local Period;
local MA;
local buffUP=nil;
local buffDN=nil;
local array1;
local array2;
local Type;

function Prepare(nameOnly)
    Type=instance.parameters.Type;
    source = instance.source;
    Period=instance.parameters.Period;

    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ")";
    instance:name(name);

    if   (nameOnly) then
        return;
    end

    MA = core.indicators:create("LWMA", source, Period);
    firstMA = MA.DATA:first();
    MA2 = core.indicators:create("LWMA", MA.DATA, math.sqrt(Period));
    array1 = MA2.DATA;
    first = array1:first() + 1;

    if instance.parameters.StrategyMode then
        array2 = instance:addStream("D", core.Line, name .. ".D", "D", core.rgb(0, 0, 0), first);
        array2:setStyle(core.LINE_NONE);
    else
        array2 = instance:addInternalStream(first, 0);
    end
    if Type == "BAR" then
    buffUP = instance:addStream("UP", core.Bar, name .. ".UP", "UP", instance.parameters.clrUP, first);
    buffDN = instance:addStream("DN", core.Bar, name .. ".DN", "DN", instance.parameters.clrDN, first);
	else
	buffUP = instance:addStream("UP", core.Line, name .. ".UP", "UP", instance.parameters.clrUP, first);
    buffDN = instance:addStream("DN", core.Line, name .. ".DN", "DN", instance.parameters.clrDN, first);
	end
	
	array2:setPrecision(math.max(2, instance.source:getPrecision()));
	buffUP:setPrecision(math.max(2, instance.source:getPrecision()));
	buffDN:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)
    MA:update(mode);
    MA2:update(mode);

    if period >= first then
        array2[period] = array2[period - 1];
        if array1[period] > array1[period - 1] then
            array2[period] = 1;
        elseif array1[period] < array1[period - 1] then
            array2[period] = -1;
        end

        if array2[period] > 0 then
            buffUP[period] = array1[period];
            if array2[period - 1] < 0 then
                buffUP[period - 1] = array1[period - 1];
                buffDN[period - 1] = nil;
            end
        elseif array2[period] < 0 then
            buffDN[period]=array1[period];
            if array2[period - 1] > 0 then
                buffDN[period - 1] = array1[period - 1];
                buffUP[period - 1] = nil;
            end
        end
     end
end


-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59631

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
    indicator:name("Trailing Limit level indicator");
    indicator:description("Trailing Limit level indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addDouble("Percent", "Percent", "", 1);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UPclr", "UP color", "UP color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DNclr", "DN color", "DN color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Percent;
local TSL=nil;
local TLL=nil;

function Prepare(nameOnly)
    source = instance.source;
    Percent=instance.parameters.Percent/100;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Percent .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
    TSL = instance:addInternalStream(0, 0);
	
    TLL = instance:addStream("TSL", core.Line, name .. ".TSL", "TSL", instance.parameters.UPclr, first);
    TLL:setWidth(instance.parameters.widthLinReg);
    TLL:setStyle(instance.parameters.styleLinReg);
end

function Update(period, mode)


    if period<first then
	return;
	end
	
    local loss=source.close[period]*Percent;
    if source.close[period]>TSL[period-1] and source.close[period-1]>TSL[period-1] then
     TSL[period]=math.max(TSL[period-1], source.close[period]-loss);
     TLL:setColor(period, instance.parameters.DNclr);
    elseif source.close[period]<TSL[period-1] and source.close[period-1]<TSL[period-1] then
     TSL[period]=math.min(TSL[period-1], source.close[period]+loss);
     TLL:setColor(period, instance.parameters.UPclr);
    elseif source.close[period]>TSL[period-1] then
     TSL[period]=source.close[period]-loss;
     TLL:setColor(period, instance.parameters.DNclr);
    else
     TSL[period]=source.close[period]+loss;
     TLL:setColor(period, instance.parameters.UPclr);
    end 
    
	if TSL[period] > source.close[period] then
	TLL[period]=TSL[period]-loss*2;
	else
	TLL[period]=TSL[period]+loss*2;
	end
	
end


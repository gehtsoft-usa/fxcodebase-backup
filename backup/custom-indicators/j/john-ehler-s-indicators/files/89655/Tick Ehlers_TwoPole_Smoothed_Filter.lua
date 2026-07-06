
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1262

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
    indicator:name("Ehlers TwoPole smoothes filter");
    indicator:description("Ehlers TwoPole smoothes filter");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("CuttOffPeriod", "CuttOffPeriod", "", 15);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr_Line", "Color of Line", "Color of Line", core.rgb(255, 0, 0));
	    indicator.parameters:addInteger("widthLinReg1", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg1", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg1", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local CuttOffPeriod; 
local BuffLine=nil;
local a1;
local b1;
local coeff1, coeff2, coeff3;

function Prepare(nameOnly)   
    source = instance.source;
    CuttOffPeriod=instance.parameters.CuttOffPeriod;
     
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.CuttOffPeriod .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
    BuffLine = instance:addStream("BuffLine", core.Line, name .. ".BuffLine", "BuffLine", instance.parameters.clr_Line, first);
	BuffLine:setWidth(instance.parameters.widthLinReg1);
    BuffLine:setStyle(instance.parameters.styleLinReg1);
    a1=math.exp(-math.sqrt(2.)*math.pi/CuttOffPeriod);
    b1=2.*a1*math.cos(math.pi*math.sqrt(2.)/CuttOffPeriod);
    coeff2=b1;
    coeff3=-a1*a1;
    coeff1=1.-coeff2-coeff3;
end

function Update(period, mode)
 
     if period>first  then
      BuffLine[period]=coeff1*source[period]+coeff2*BuffLine[period-1]+coeff3*BuffLine[period-2];
     else
      BuffLine[period]=source[period];
     end 
    
end


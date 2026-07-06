-- Id: 10862
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=10878


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
    indicator:name("William Blau Mean Deviation Index");
    indicator:description("William Blau Mean Deviation Index");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Smooth_Period1", "Smooth period 1", "", 20);
    indicator.parameters:addInteger("Smooth_Period2", "Smooth period 2", "", 5);
    indicator.parameters:addInteger("Smooth_Period3", "Smooth period 3", "", 3);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Smooth_Period1;
local Smooth_Period2;
local Smooth_Period3;
local MD;
local EMA1, EMA2, EMA3;
local Blau_MDI=nil;

function Prepare(nameOnly)  
    source = instance.source;
    Smooth_Period1=instance.parameters.Smooth_Period1;
    Smooth_Period2=instance.parameters.Smooth_Period2;
    Smooth_Period3=instance.parameters.Smooth_Period3;
    first = source:first()+2;
	
	  local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Smooth_Period1 .. ", " .. instance.parameters.Smooth_Period2 .. ", " .. instance.parameters.Smooth_Period3 .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
    MD = instance:addInternalStream(first, 0);
    EMA1 = core.indicators:create("EMA", source, Smooth_Period1);
    EMA2 = core.indicators:create("EMA", MD, Smooth_Period2);
    EMA3 = core.indicators:create("EMA", EMA2.DATA, Smooth_Period3);
  
	
	
    Blau_MDI = instance:addStream("Blau_MDI", core.Line, name .. ".Blau_MDI", "Blau_MDI", instance.parameters.clr, EMA3.DATA:first());
    Blau_MDI:setWidth(instance.parameters.widthLinReg);
    Blau_MDI:setStyle(instance.parameters.styleLinReg);
	
	Blau_MDI:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)
   if period>first then
    EMA1:update(mode);
    MD[period]=source[period]-EMA1.DATA[period];
    EMA2:update(mode);
    EMA3:update(mode);
    Blau_MDI[period]=EMA3.DATA[period];
   end 
end


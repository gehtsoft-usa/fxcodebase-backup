-- Id: 4527

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1262

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
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
    indicator:name("Ehlers TwoPole smoothes oscillator");
    indicator:description("Ehlers TwoPole smoothes oscillator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    
    indicator.parameters:addInteger("CuttOff", "CuttOff", "", 15);
    indicator.parameters:addDouble("alpha", "alpha", "", 0.15);
    indicator.parameters:addInteger("shift", "shift", "", 0);

    indicator.parameters:addColor("clr_Line", "Color of Line", "Color of Line", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clr_buff1", "Color of Buff1", "Color of Buff1", core.rgb(255, 0, 0));
    indicator.parameters:addColor("clr_buff2", "Color of Buff2", "Color of Buff2", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local CuttOff;
local alpha;
local shift;
local Buff1=nil;
local Buff2=nil;
local BuffLine=nil;
local Ind;

function Prepare(nameOnly)   
    source = instance.source;
    CuttOff=instance.parameters.CuttOff;
    alpha=instance.parameters.alpha;
    shift=instance.parameters.shift;
	
	
	 local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.CuttOff .. ", " .. instance.parameters.alpha .. ", " .. instance.parameters.shift .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	assert(core.indicators:findIndicator("EHLERS_TWOPOLE_SMOOTHED_FILTER") ~= nil, "Please, download and install EHLERS_TWOPOLE_SMOOTHED_FILTER.LUA indicator");    
	
    Ind = core.indicators:create("EHLERS_TWOPOLE_SMOOTHED_FILTER", source, CuttOff);
    first = Ind.DATA:first()+3;
   
	
    Buff1 = instance:addStream("Buff1", core.Bar, name .. ".Buff1", "Buff1", instance.parameters.clr_buff1, first);
    Buff2 = instance:addStream("Buff2", core.Bar, name .. ".Buff2", "Buff2", instance.parameters.clr_buff2, first);
    BuffLine = instance:addStream("BuffLine", core.Line, name .. ".BuffLine", "BuffLine", instance.parameters.clr_Line, first);
    BuffLine:setWidth(instance.parameters.widthLinReg);
    BuffLine:setStyle(instance.parameters.styleLinReg);
    BuffLine:addLevel(0);
	
	BuffLine:setPrecision(math.max(2, instance.source:getPrecision()));
	Buff1:setPrecision(math.max(2, instance.source:getPrecision()));
	Buff2:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)
    if (period>first) then
     Ind:update(mode);
     local Val=Ind.DATA[period]-Ind.DATA[period-1];
     local Val1=Ind.DATA[period-1]-Ind.DATA[period-2];
     local Val2=Ind.DATA[period-2]-Ind.DATA[period-3];
     BuffLine[period]=(alpha-(alpha*alpha/4.))*Val+(alpha*alpha/2.)*Val1-(alpha-3.*alpha*alpha/4.)*Val2+2.*(1-alpha)*BuffLine[period-1]-(1-alpha)*(1-alpha)*BuffLine[period-2];
     if BuffLine[period]<BuffLine[period-1] then
      Buff1[period]=BuffLine[period];
      Buff2[period]=nil;
     else
      Buff1[period]=nil;
      Buff2[period]=BuffLine[period];
     end
     
    end 
end


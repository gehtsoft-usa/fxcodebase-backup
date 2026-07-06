-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=10396


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
    indicator:name("i-Fractals-sig indicator");
    indicator:description("i-Fractals-sig indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("bd", "Last bar body length", "Last bar body length", 7);
    indicator.parameters:addInteger("bdd", "Body lenght for double top/buttom bars", "Body lenght for double top/buttom bars", 40);
    indicator.parameters:addInteger("sd", "Shadow difference for fractal bars", "Shadow difference for fractal bars", 11);
    indicator.parameters:addInteger("sdd", "Shadow difference for double tops/buttoms bars", "Shadow difference for double tops/buttoms bars", 6);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UPclr", "UP Color", "UP Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DNclr", "DN Color", "DN Color", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("DotSize", "Dot size", "Dot size", 4, 1, 5);
end

local first;
local source = nil;
local bd;
local bdd;
local sd;
local sdd;
local iFractals=nil;

 function Prepare(nameOnly)   
    source = instance.source;
    bd=instance.parameters.bd*source:pipSize();
    bdd=instance.parameters.bdd*source:pipSize();
    sd=instance.parameters.sd*source:pipSize();
    sdd=instance.parameters.sdd*source:pipSize();
    first = source:first()+6;
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.bd .. ", " .. instance.parameters.bdd .. ", " .. instance.parameters.sd .. ", " .. instance.parameters.sdd .. ")";
    instance:name(name);
	if   (nameOnly) then
        return;
    end
	
	
    iFractals = instance:addStream("iFractals", core.Dot, name .. ".iFractals", "iFractals", instance.parameters.UPclr, first);
    iFractals:setWidth(instance.parameters.DotSize);
end

function Update(period, mode)
   if (period<first ) then
   return;
   end
    local bc1=false;
    local bc2=false;
    local bc3=false;
    local sc1=false;
    local sc2=false;
    local sc3=false;
    if source.low[period-3]-source.low[period-2]>sd and source.low[period-4]-source.low[period-2]>sd and source.low[period-1]-source.low[period-2]>sd and source.close[period-1]-source.open[period-1]>bd then
     bc1=true;
    end
    if source.high[period-2]-source.high[period-3]>sd and source.high[period-2]-source.high[period-4]>sd and source.high[period-2]-source.high[period-1]>sd and source.open[period-1]-source.close[period-1]>bd then
     sc1=true;
    end
    if source.low[period-4]-source.low[period-2]>sd and source.low[period-5]-source.low[period-2]>sd and source.low[period-1]-source.low[period-2]>sd and source.close[period-1]-source.open[period-1]>bd and math.abs(source.low[period-3]-source.low[period-2])<sdd then
     bc2=true;
    end
    if source.high[period-2]-source.high[period-4]>sd and source.high[period-2]-source.high[period-5]>sd and source.high[period-2]-source.high[period-1]>sd and source.open[period-1]-source.close[period-1]>bd and math.abs(source.high[period-3]-source.high[period-2])<sdd then
     sc2=true;
    end
    if source.low[period-3]-source.low[period-2]>sd and source.low[period-4]-source.low[period-2]>sd and math.abs(source.low[period-1]-source.low[period-2])<sdd and source.close[period-1]-source.open[period-1]>bdd and source.open[period-2]-source.close[period-2]>bdd then
     bc3=true;
    end
    if source.high[period-2]-source.high[period-3]>sd and source.high[period-2]-source.high[period-4]>sd and math.abs(source.high[period-2]-source.high[period-1])<sdd and source.open[period-1]-source.close[period-1]>bdd and source.close[period-2]-source.open[period-2]>bdd then
     sc3=true;
    end
    if bc1 or bc2 or bc3 then
     iFractals[period]=source.low[period];
     iFractals:setColor(period,instance.parameters.UPclr);
    end
    if sc1 or sc2 or sc3 then
     iFractals[period]=source.high[period];
     iFractals:setColor(period,instance.parameters.DNclr);
    end
   
end


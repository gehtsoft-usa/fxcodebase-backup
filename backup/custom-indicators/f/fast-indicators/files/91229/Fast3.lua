-- Id: 10585

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60020

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Fast3 indicator");
    indicator:description("Fast3 indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period1", "Period 1", "", 3);
    indicator.parameters:addInteger("Period2", "Period 2", "", 9);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UPclr", "UP color", "UP color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DNclr", "DN color", "DN color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("ArrowSize", "Arrow size", "", 10);
end

local first;
local source = nil;
local Period1;
local Period2;
local St;
local MA1, MA2;
local UP=nil;
local DN=nil;
local Sqrt2, Sqrt3;
local pipSize;

function Prepare(nameOnly)
    source = instance.source;
    Period1=instance.parameters.Period1;
    Period2=instance.parameters.Period2;
    
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period1 .. ", " .. instance.parameters.Period2 .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    St = instance:addInternalStream(0, 0);
    MA1 = core.indicators:create("LWMA", St, Period1);
    MA2 = core.indicators:create("LWMA", St, Period2);
	
	first = math.max(MA1.DATA:first() ,MA2.DATA:first())+2;
    UP = instance:createTextOutput ("Up", "Up", "Wingdings", instance.parameters.ArrowSize, core.H_Center, core.V_Bottom, instance.parameters.UPclr, 0);
    DN = instance:createTextOutput ("Dn", "Dn", "Wingdings", instance.parameters.ArrowSize, core.H_Center, core.V_Top, instance.parameters.DNclr, 0);
    Sqrt2=math.sqrt(2);
    Sqrt3=math.sqrt(3);
    pipSize=source:pipSize();
end

function Update(period, mode)
   
   
    if period < source:first() + 2 then
	 return;
	 end
	 
    St[period]=(source.close[period]-source.open[period]+(source.close[period-1]-source.open[period-1])/Sqrt2+(source.close[period-2]-source.open[period-2])/Sqrt3)/pipSize;
    MA1:update(mode);
    MA2:update(mode);
	
	 if period<first then
	 return;
	 end
    if MA1.DATA[period-2]>MA2.DATA[period-2] and MA1.DATA[period-1]<MA2.DATA[period-1] and MA1.DATA[period]<MA2.DATA[period] and St[period-2]>=St[period-1] then
     DN:set(period, source.high[period], "\230");
    else
     DN:setNoData(period);
    end
    if MA1.DATA[period-2]<MA2.DATA[period-2] and MA1.DATA[period-1]>MA2.DATA[period-1] and MA1.DATA[period]>MA2.DATA[period] and St[period-2]<=St[period-1] then
     UP:set(period, source.low[period], "\228");
    else
     UP:setNoData(period);
    end
   
end


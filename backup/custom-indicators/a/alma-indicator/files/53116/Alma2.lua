-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=27883
-- Id: 8354

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Alma2 indicator");
    indicator:description("Alma2 indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 9);
    indicator.parameters:addDouble("Sigma", "Sigma", "", 6);
    indicator.parameters:addDouble("Offset", "Offset", "", 0.85);
    indicator.parameters:addDouble("DampingFactor", "Damping factor", "", 1);
    indicator.parameters:addDouble("PctFilter", "Pct filter", "", 0);
    indicator.parameters:addBoolean("ColorMode", "ColorMode", "", true);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("MainClr", "Main color", "Main color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("UPclr", "UP color", "UP color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("DNclr", "DN color", "DN color", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Period;
local Sigma;
local Offset;
local DampingFactor;
local PctFilter;
local ColorMode;
local Alma=nil;
local w={};
local Alma1, Alma2, Buff, Alma3, Del;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    Sigma=instance.parameters.Sigma;
    Offset=instance.parameters.Offset;
    DampingFactor=instance.parameters.DampingFactor;
    PctFilter=instance.parameters.PctFilter;
    ColorMode=instance.parameters.ColorMode;
   
    local i;
    local m=math.floor(Offset*(Period-1));
    local s=Period/Sigma;
    local wSum=0;
    for i=0,Period-1,1 do
     w[i]=math.exp(-(i-m)*(i-m)/(2*s*s));
     wSum=wSum+w[i];
    end
    for i=0,Period-1,1 do
     w[i]=w[i]/wSum;
    end
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.Sigma .. ", " .. instance.parameters.Offset .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	assert(core.indicators:findIndicator("ALMA") ~= nil, "Please, download and install ALMA.LUA indicator");    
    Alma1 = core.indicators:create("ALMA", source, math.floor(Period/2), Sigma, Offset, false);
    Alma2 = core.indicators:create("ALMA", source, Period, Sigma, Offset, false);
	
	first =math.max( Alma1.DATA:first(),Alma2.DATA:first());
    Buff = instance:addInternalStream(0, 0);
    Alma3 = core.indicators:create("ALMA", Buff, math.floor(math.sqrt(Period)), Sigma, Offset, false);
    Del = instance:addInternalStream(0, 0);
    Alma = instance:addStream("Alma", core.Line, name .. ".Alma", "Alma", instance.parameters.MainClr, Alma3.DATA:first());
    Alma:setWidth(instance.parameters.widthLinReg);
    Alma:setStyle(instance.parameters.styleLinReg);
end

function Update(period, mode)
   
    Alma1:update(mode);
    Alma2:update(mode);
	
	if (period<first) then
	return;
	end
	
    Buff[period]=Alma1.DATA[period]+DampingFactor*(Alma1.DATA[period]-Alma2.DATA[period]);
   
   
   	 Alma3:update(mode);
    
	if period < Alma3.DATA:first() then
	return;
	end
	
	
    if (period<Period) then
	return;
	end
	
	Alma[period]=Alma3.DATA[period];
	
    if PctFilter>0 then
     Del[period]=math.abs(Alma[period]-Alma[period-1]);
     local StdDev=mathex.stdev(Del, core.rangeTo(period, Period));
     local Filter=PctFilter*StdDev;
     if Del[period]<Filter then
      Alma[period]=Alma[period-1];
     end
    end
       	
	 if ColorMode then
		 if Alma[period]>Alma[period-1] then
		  Alma:setColor(period, instance.parameters.UPclr);
		 elseif Alma[period]<Alma[period-1] then
		  Alma:setColor(period, instance.parameters.DNclr);
		 end
	 end
     
 
end



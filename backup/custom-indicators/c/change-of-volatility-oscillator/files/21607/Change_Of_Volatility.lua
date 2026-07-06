-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=10398
-- Id: 5391

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                   Paypal: https://goo.gl/9Rj74e  |
--|                    Patreon : https://www.patreon.com/mariojemic  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Change of Volatility indicator");
    indicator:description("Change of Volatility indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("MPeriod", "Momentum Period", "", 1);
    indicator.parameters:addInteger("Short", "Short", "", 6);
    indicator.parameters:addInteger("Long", "Long", "", 100);
    indicator.parameters:addInteger("MaxTrendLevel", "Max. trend level", "", 80);
    indicator.parameters:addInteger("MiddleTrendLevel", "Middle trend level", "", 50);
    indicator.parameters:addInteger("FlatLevel", "Flat level", "", 30);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("MaxTrendClr", "Max trend Color", "Max trend Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("MiddleTrendClr", "Middle trend Color", "Middle trend Color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("FlatClr", "Flat Color", "Flat Color", core.rgb(0, 0, 255));
    indicator.parameters:addColor("NeutralClr", "Neutral Color", "Neutral Color", core.rgb(192, 192, 192));
end

local first;
local source = nil;
local MPeriod;
local Short;
local Long;
local MaxTrendLevel;
local MiddleTrendLevel;
local FlatLevel;
local CoV=nil;
local Momentum;
local StdDev_Short;
local StdDev_Long;

function Prepare(nameOnly)
    source = instance.source;
    MPeriod=instance.parameters.MPeriod;
    Short=instance.parameters.Short;
    Long=instance.parameters.Long;
    MaxTrendLevel=instance.parameters.MaxTrendLevel;
    MiddleTrendLevel=instance.parameters.MiddleTrendLevel;
    FlatLevel=instance.parameters.FlatLevel;
   
	local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.MPeriod .. ", " .. instance.parameters.Short .. ", " .. instance.parameters.Long .. ", " .. instance.parameters.MaxTrendLevel .. ", " .. instance.parameters.MiddleTrendLevel .. ", " .. instance.parameters.FlatLevel .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	assert(core.indicators:findIndicator("STDDEV") ~= nil, "Please, download and install STDDEV.LUA indicator");  
	assert(core.indicators:findIndicator("MOMENTUM") ~= nil, "Please, download and install MOMENTUM.LUA indicator");  
	
    Momentum = core.indicators:create("MOMENTUM", source, MPeriod);
    StdDev_Short = core.indicators:create("STDDEV", Momentum.DATA, Short);
    StdDev_Long = core.indicators:create("STDDEV", Momentum.DATA, Long);
	
	 first = math.max(StdDev_Short.DATA:first(), StdDev_Long.DATA:first(), Momentum.DATA:first());
    CoV = instance:addStream("CoV", core.Bar, name .. ".CoV", "CoV", instance.parameters.NeutralClr, first);
    CoV:addLevel(FlatLevel);
    CoV:addLevel(MiddleTrendLevel);
    CoV:addLevel(MaxTrendLevel);
	
	CoV:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)
   if (period<first) then
   return;
   end
   
		Momentum:update(mode);
		StdDev_Short:update(mode);
		StdDev_Long:update(mode);
		if StdDev_Long.DATA[period]~=0 then
		 CoV[period]=100*StdDev_Short.DATA[period]/StdDev_Long.DATA[period];
		else
		 CoV[period]=0;
		end
		if CoV[period]>MaxTrendLevel then
		 CoV:setColor(period,instance.parameters.MaxTrendClr);
		elseif CoV[period]>MiddleTrendLevel then
		 CoV:setColor(period,instance.parameters.MiddleTrendClr);
		elseif CoV[period]>FlatLevel then
		 CoV:setColor(period,instance.parameters.FlatClr);
		else
		 CoV:setColor(period,instance.parameters.NeutralClr);
		end
    
end


-- Id: 9004
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=627

--+------------------------------------------------------------------+
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

-- The indicator corresponds to the Ichimoku Kinko Hyo indicator in MetaTrader.

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("Alternate Ichimoku");
    indicator:description("An Alternate Ichimoku");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator:setTag("group", "Custom");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("SSP", "SSP", "Period Priority Line", 75);
    indicator.parameters:addInteger("SSK", "SSK", "Tolerance Second Line", 75);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrTS", "S/L Line", "Stop-Order Line", core.rgb(255, 255, 0));
	
    indicator.parameters:addColor("clrSSA", "Priority Line", "1st Leading Line", core.rgb(255, 0, 0));
    indicator.parameters:addColor("clrSSB", "Tolerance Second Line", "2nd Leading Line", core.rgb(0, 0, 255));
    indicator.parameters:addColor("clrCloudup", "Cloud UP", "Cloud Color UP", core.rgb(0, 255, 0));
	indicator.parameters:addColor("clrClouddn", "Cloud DN", "Cloud Color DN", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("transp", "Transparence", "Cloud Transparence", 80, 0, 100);
    indicator.parameters:addBoolean("M", "Additional Lines", "Draw Middle Line and Shenkou Line", false);
    indicator.parameters:addColor("clrKS", "Middle Line", "Middle Line of Priority Line and overdue Line", core.rgb(0, 255, 255));
    indicator.parameters:addColor("clrCS", "Chikou Span", "Chikou Span Lagging Line Closed Price Backwards", core.rgb(0, 255, 0));



end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local SSP;
local SSK;
local M;

local firstPeriod;
local source = nil;

local csFirst = nil;
local slFirst = nil;
local tlFirst = nil;
local saFirst = nil;
local sbFirst = nil;

local SsMax, SsMin, SsMax05, SsMin05, Rsmin, Rsmax, Tsmin, Tsmax;


-- Streams block
local SL = nil;
local TL = nil;
local CS = nil;
local SA = nil;
local SB = nil;

-- Routine
function Prepare(nameOnly)
    SSP = instance.parameters.SSP;
    SSK = instance.parameters.SSK;
    M = instance.parameters.M;
    source = instance.source;
    firstPeriod = source:first();

    local name = profile:id() .. "(" .. source:name() .. ", " .. SSP .. ", " .. SSK .. ", " .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    SL = instance:addStream("SL", core.Line, name .. ".SL", "SL", instance.parameters.clrTS, SSP*2)
    ML = instance:addStream("ML", core.Line, name .. ".ML", "ML", instance.parameters.clrKS, firstPeriod + SSP*2 - 1)
    CS = instance:addStream("CS", core.Line, name .. ".CS", "CS", instance.parameters.clrCS, firstPeriod, -SSP)
    SA = instance:addStream("SA", core.Line, name .. ".SA", "SA", instance.parameters.clrSSA, SSP*2)
    SB = instance:addStream("SB", core.Line, name .. ".SB", "SB", instance.parameters.clrSSB, SSP*2)
	SA1 = instance:addInternalStream(SSP*2)
    SB1 = instance:addInternalStream(SSP*2)
	SA2 = instance:addInternalStream(SSP*2)
    SB2 = instance:addInternalStream(SSP*2)
    instance:createChannelGroup("SA-SBup", "SA-SBup", SA1, SB1, instance.parameters.clrCloudup, 100 - instance.parameters.transp);
	instance:createChannelGroup("SA-SBdn", "SA-SBdn", SA2, SB2, instance.parameters.clrClouddn, 100 - instance.parameters.transp);
    csFirst = CS:first() + SSP*2;
    slFirst = SL:first();
    tlFirst = ML:first();
    saFirst = SA:first();
    sbFirst = SB:first();
end

-- Indicator calculation routine
function Update(period)
    if period >= SSP*2 + SSK then
        SsMax = core.max(source.high,core.rangeTo(period,SSP))
        SsMin = core.min(source.low,core.rangeTo(period,SSP))
        SsMax05 = core.max(source.high,core.rangeTo(period-SSK,SSP))
        SsMin05 = core.min(source.low,core.rangeTo(period-SSK,SSP))
		
        SA[period] = (SsMax+SsMin)/2;
        SB[period] = (SsMax05+SsMin05)/2;
        Tsmax = core.max(source.high,core.rangeTo(period,SSP*1.62))
        Tsmin = core.min(source.low,core.rangeTo(period,SSP*1.62))
        SL[period] = (Tsmax + Tsmin) / 2;
        if M then
            ML[period] = ((SsMax+SsMin)/2 + (SsMax05+SsMin05)/2)/2;
            CS[period - SSP] = source.close[period];
        end
        if SA[period] <= SB[period] then
			SA2[period] = SA[period];
			SB2[period] = SB[period];
			--SA:setColor(period,instance.parameters.clrClouddn);
			--SB:setColor(period,instance.parameters.clrCloudup);
		else
			SA1[period] = SA[period];
			SB1[period] = SB[period];
		end
    end

end







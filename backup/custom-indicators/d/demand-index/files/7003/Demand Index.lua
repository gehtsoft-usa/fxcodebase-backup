-- Id: 2719
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3020

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
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
    indicator:name("Demand Index by James Sibbet");
    indicator:description("Demand Index by James Sibbet");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Length", "Period", "", 5);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("DI_color", "Color of DI", "Color of DI", core.rgb(255, 0, 0));
		indicator.parameters:addInteger("width", "Line Width", "", 1, 1, 5);
     indicator.parameters:addInteger("style", "DEMA Line Style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Length;

local first;
local source = nil;

-- Streams block
local DI = nil;

local VA;
local VolAvg;

local WghtClose;
local AvgTR;

local BuyPres;
local SellPres;

local ATR;

-- Routine
function Prepare(nameOnly)
    Length = instance.parameters.Length;
    source = instance.source;
    first = source:first();

    local name = profile:id() .. "(" .. source:name() .. ", " .. Length .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	
	VA=core.indicators:create("MVA", source.volume,Length );
	
	BuyPres=instance:addInternalStream (first, 0);
	SellPres=instance:addInternalStream (first, 0);
	
	TR=instance:addInternalStream (first, 0);
	ATR=core.indicators:create("MVA", TR,Length );
	
	AvgTR=instance:addInternalStream (first, 0);
	VolAvg=instance:addInternalStream (first, 0);
	WghtClose = instance:addInternalStream (first, 0);
	
    DI = instance:addStream("DI", core.Line, name, "DI", instance.parameters.DI_color, first+Length+1);
	DI:setWidth(instance.parameters.width);
	DI:setStyle(instance.parameters.style);
	
	DI:setPrecision(math.max(2, instance.source:getPrecision()));
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)
 
 
 WghtClose[period] = (source.high[period] + source.low[period] + source.close[period] + source.close[period]) * 0.25;
 TR[period] = math.max(source.high[period-1],source.high[period]) - math.min(source.low[period-1],source.low[period]);
 

 VA:update(core.UpdateLast);

 if period <= first+Length then 
 return;
 end
 
 VolAvg[period] = VA.DATA[period]; 
  

 
 ATR:update(core.UpdateLast);
 
 AvgTR[period] = ATR.DATA[period];
VolAvg[period] = ((VolAvg[period-1] * (Length - 1)) + source.volume[period]) / Length;

if  WghtClose[period] ~= 0 and WghtClose[period-1] ~= 0 and 	AvgTR[period] ~= 0 and VolAvg[period] ~= 0 then

local WtCRatio = (WghtClose[period] - WghtClose[period-1]) / math.min(WghtClose[period],WghtClose[period-1]) ;
local VolRatio = source.volume[period] / VolAvg[period];
local Constant = ((WghtClose[period] * 3) /AvgTR[period]) * math.abs (WtCRatio);
if Constant > 88 then
Constant = 88 
end


Constant = VolRatio / math.exp (Constant);

local BuyP,SellP;

if WtCRatio > 0 then
 		BuyP = VolRatio;
		SellP = Constant;
else
		BuyP = Constant;
		SellP = VolRatio;
end

BuyPres[period] = ((BuyPres [period-1] * (Length - 1)) + BuyP) / Length;
SellPres[period] = ((SellPres [period-1] * (Length - 1)) + SellP) / Length;

local TempDI = 1;
local Sign;

if SellPres[period] > BuyPres[period] then

		Sign = -1;
        if SellPres[period] ~= 0 then
		TempDI = BuyPres[period] / SellPres[period];
		end
else

		Sign = 1;
        if BuyPres[period] ~= 0 then 
		TempDI = SellPres[period] / BuyPres[period];
		end
end

local DMIndx;

     TempDI = TempDI * Sign;
	if  TempDI < 0 then
	  DMIndx = -1 - TempDI
	else
	  DMIndx = 1 - TempDI ;
	end  


 DI[period] = DMIndx;
end


	 
end


-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64460
-- Id: 17663

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

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("Relative Dynamic Zone Stochastic RSI");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

	
	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "Number of periods for RSI", "", 14, 1, 200);
    indicator.parameters:addInteger("K", "%K Stochastic Periods", "", 14, 1, 200);
    indicator.parameters:addInteger("KS", "%K Slowing Periods", "", 5, 1, 200);
    indicator.parameters:addInteger("D", "%D Slowing Stochastic Periods", "", 3, 1, 200);
	
	indicator.parameters:addGroup("Bollinger Band Calculation");
	indicator.parameters:addInteger("Period", "Period", "", 20, 1, 10000);
    indicator.parameters:addDouble("Dev","Number of standard deviations", "", 2.0, 0.0001, 1000.0);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("K_color", "Color of K", "Color of K", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
	indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("D_color", "Color of D", "Color of D", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
	indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addColor("BAND_color", "Color of Band", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addColor("CENTRAL_color", "Color of Central Line", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width4", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style4", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style4", core.FLAG_LINE_STYLE);

end

-- Indicator instance initialization routine

-- Parameters block
local N;
local K;
local KS;
local D;

local BB, Period, Dev;

local firstSKI;
local firstK;
local firstD;
local source = nil;

-- Streams block
local SKI = nil;
local SK = nil;
local SD = nil;
local RSI = nil;
local MVA1 = nil;
local MVA2 = nil;
local Raw_SK,Raw_SD;
 
-- Routine
function Prepare(nameOnly)
    N = instance.parameters.N;
    K = instance.parameters.K;
    KS = instance.parameters.KS;
    D = instance.parameters.D;
	Period= instance.parameters.Period;
	Dev= instance.parameters.Dev;
    source = instance.source;
    first = source:first();

    local name = profile:id() .. "(" .. source:name() .. ", " .. N .. ", " .. K .. ", " .. KS ..", " .. D.. ", " .. Period ..", " .. Dev .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    RSI = core.indicators:create("RSI", source, N);
    firstSKI = RSI.DATA:first() + K;
    SKI = instance:addInternalStream(firstSKI, 0);
    MVA1 = core.indicators:create("MVA", SKI, KS);
    firstK = MVA1.DATA:first();
	
	
 
   	Raw_SK = instance:addInternalStream(0, 0);	
	
	MVA2 = core.indicators:create("MVA", Raw_SK, D);
    firstD = MVA2.DATA:first();
	
	Raw_SD  = instance:addInternalStream(0, 0);	
 
	BB=core.indicators:create("BB",  Raw_SK, Period, Dev);
	
    SK = instance:addStream("K", core.Line, name .. ".K", "K", instance.parameters.K_color, BB.DATA:first());
    SK:setPrecision(math.max(2, instance.source:getPrecision()));
   SK:addLevel(0);
    SK:addLevel(50);
    SK:addLevel(100);
	SK:setWidth(instance.parameters.width1);
    SK:setStyle(instance.parameters.style1);

  
    SD = instance:addStream("D", core.Line, name .. ".D", "D", instance.parameters.D_color,  BB.DATA:first());
    SD:setPrecision(math.max(2, instance.source:getPrecision()));
	SD :setWidth(instance.parameters.width2);
    SD :setStyle(instance.parameters.style2);
	
	CENTRAL = instance:addStream("CENTRAL", core.Line, name, "Central", instance.parameters.CENTRAL_color, BB.AL:first());
    CENTRAL:setPrecision(math.max(2, instance.source:getPrecision()));
	CENTRAL:setWidth(instance.parameters.width4);
    CENTRAL:setStyle(instance.parameters.style4);
	
	UP = instance:addStream("UP", core.Line, name, "Top", instance.parameters.BAND_color, BB.TL:first());
    UP:setPrecision(math.max(2, instance.source:getPrecision()));
	UP:setWidth(instance.parameters.width3);
    UP:setStyle(instance.parameters.style3);
	
	DOWN = instance:addStream("DOWN", core.Line, name, "Bottom", instance.parameters.BAND_color, BB.BL:first());
    DOWN:setPrecision(math.max(2, instance.source:getPrecision()));
	DOWN:setWidth(instance.parameters.width3);
    DOWN:setStyle(instance.parameters.style3);

	 
end

-- Indicator calculation routine
function Update(period, mode)
    RSI:update(mode);

    if (period <  firstSKI) then
	return;
	end
	
        local min,max = mathex.minmax(RSI.DATA, period-K+1, period);
        if (min == max) then
            SKI[period] = 100;
        else
            SKI[period] = (RSI.DATA[period] - min) / (max - min) * 100;
        end
    

    MVA1:update(mode);

    if period < firstK then
	return;
	end
	
        Raw_SK[period] = MVA1.DATA[period];
 
    MVA2:update(mode);

    if (period < firstD) then
	return;
	end
	
        Raw_SD[period] = MVA2.DATA[period];
		

  	 BB:update(mode);
	 
	  if period < BB.DATA:first()   then 
	 return;
	 end	 
 
			
		SK[period]=(Raw_SK[period]-BB.BL[period])/((BB.TL[period]-BB.BL[period])/100);
        SD[period]=	(Raw_SD[period]-BB.BL[period])/((BB.TL[period]-BB.BL[period])/100)	;
	  
       CENTRAL[period]=(50-BB.BL[period])/((BB.TL[period]-BB.BL[period])/100);
       UP[period]=	(80-BB.BL[period])/((BB.TL[period]-BB.BL[period])/100)	;
       DOWN[period]= (20-BB.BL[period])/((BB.TL[period]-BB.BL[period])/100)	;

end


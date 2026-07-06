-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65817

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

-- Indicator profile initialization routine

function Init()
    indicator:name("ADXVMA");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("ChandeEMA", "Chande EMA", "", 14, 2, 2000);	
	indicator.parameters:addInteger("WeightDM", "Weight DM", "", 14, 2, 2000);
	indicator.parameters:addInteger("WeightDI", "WeightDI", "", 14, 2, 2000);
	indicator.parameters:addInteger("Length", "Length", "", 14, 2, 2000);
	indicator.parameters:addInteger("WeightDX", "WeightDX", "", 14, 2, 2000);
 
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("Up", "Up Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral Line Color", "", core.rgb(0, 0, 255));
	
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local ChandeEMA; 
local WeightDM;
local WeightDI;
local Length;

local Up, Down,Neutral;

local first;

local Price = nil;
local ADXVMA;


local out; 
local pdm,mdm;
local pdi, mdi;
local WeightDX;
-- Routine
function Prepare(nameOnly) 
	ChandeEMA= instance.parameters.ChandeEMA; 
	WeightDM= instance.parameters.WeightDM;
	WeightDI= instance.parameters.WeightDI;
	WeightDX= instance.parameters.WeightDX;
	Length= instance.parameters.Length;
 
    local name = profile:id() .. "(" ..  instance.source:name() .. ", " ..  ChandeEMA .. ", " ..  WeightDM .. ", " ..  WeightDX .. ", " ..  WeightDI.. ", " ..  Length .. ")";
    instance:name(name); 
    if   (nameOnly) then
        return;
    end
	
	Up= instance.parameters.Up;
	Down= instance.parameters.Down;
	Neutral= instance.parameters.Neutral;
    Price = instance.source;
	out = instance:addInternalStream(0, 0);
	pdm = instance:addInternalStream(0, 0);
	mdm = instance:addInternalStream(0, 0);
	pdi= instance:addInternalStream(0, 0);
	mdi= instance:addInternalStream(0, 0);
  
    first = Price:first() + 1;
 
	ADXVMA = instance:addStream("ADXVMA" , core.Line, " ADXVMA"," ADXVMA",Neutral, first);
	ADXVMA:setWidth(instance.parameters.width);
    ADXVMA:setStyle(instance.parameters.style);
end

-- Indicator calculation routine
function Update(period, mode)
    if period < first then
		return;
	end
	if (Price[period] > Price[period - 1]) then
		pdm[period] = Price[period] - Price[period - 1];
	else 
		mdm[period] = Price[period - 1] - Price[period];
	end
	if not pdm:hasData(period - 1) and not mdm:hasData(period - 1) then
		pdm[period] = ((WeightDM - 1) * pdm[period] + pdm[period]) / WeightDM;
		mdm[period] = ((WeightDM - 1) * mdm[period] + mdm[period]) / WeightDM;
	else
		pdm[period] = ((WeightDM - 1) * pdm[period - 1] + pdm[period]) / WeightDM;
		mdm[period] = ((WeightDM - 1) * mdm[period - 1] + mdm[period]) / WeightDM;
	end
	
	local TR = pdm[period] + mdm[period];
	if (TR > 0) then 
		pdi[period] = pdm[period] / TR;
		mdi[period] = mdm[period] / TR;  
	else 
		pdi[period]=0; 
		mdi[period]=0;
	end
	
	if not pdi:hasData(period - 1) and not mdi:hasData(period - 1) then
		pdi[period] = ((WeightDI - 1) * pdi[period] + pdi[period]) / WeightDI;
		mdi[period] = ((WeightDI - 1) * mdi[period] + mdi[period]) / WeightDI;
	else
		pdi[period] = ((WeightDI - 1) * pdi[period - 1] + pdi[period]) / WeightDI;
		mdi[period] = ((WeightDI - 1) * mdi[period - 1] + mdi[period]) / WeightDI;
	end
	local DI_Diff = math.abs(pdi[period] - mdi[period]);
	--Only positive momentum signals are used.
	local DI_Sum = pdi[period] + mdi[period];
	--Zero case, DI_Diff will also be zero when DI_Sum i s zero.
	if (DI_Sum > 0) then
		out[period] = DI_Diff / DI_Sum 
	else 
		if not out:hasData(period - 1) then
			out[period] = ((WeightDX - 1) * DI_Diff / DI_Sum + DI_Diff / DI_Sum) / WeightDX;
		else
			out[period] = ((WeightDX - 1) * out[period - 1] + DI_Diff / DI_Sum) / WeightDX; 
		end
	end
	if period < Length then
		return;
	end
	local LLV, HHV = mathex.minmax(out, period - Length + 1, period);
	local diff = HHV - LLV;
	local VI = 0;
	if (diff > 0) then 
		VI = (out[period] - LLV) / diff; 
	end
	if not ADXVMA:hasData(period - 1) then
		ADXVMA[period] = Price[period];
	else
		ADXVMA[period] = ((ChandeEMA - VI) * ADXVMA[period - 1] + VI * Price[period]) / ChandeEMA;
	end
	--Chande VMA formula with ema built in. 
	if ADXVMA[period] > ADXVMA[period-1] then
		ADXVMA:setColor(period, Up);	
	elseif ADXVMA[period] < ADXVMA[period-1] then
		ADXVMA:setColor(period, Down);	
	else
		ADXVMA:setColor(period, Neutral);	
	end
end


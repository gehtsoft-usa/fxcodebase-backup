-- Id: 13877

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62054

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
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



--[[
This script gives a score out of 100 in increments of 2.5,
based on the 5 periods entered and the following eight indicator tests:
1.Close>=EMA(x) 
2. RSI(x)>=50 
3. OBV>=OBV[x periods ago]   
4. PVT>=PVT[x periods ago]
5.Percentrank(x)>=50 
6.Lower donchian channel(x period) is rising
7. Accumulation/distribution>=A/D[x periods ago]
8. Volatility stop : Close>=Highest(L3 periods)-n.ATR where n =1,2,3,4,5
..where x equals L1,L2,L3,L4 and L5
]]
-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Weight of Evidence");
    indicator:description("Weight of Evidence");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");	
	
	
	indicator.parameters:addString("Price", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted");	
	
	
	indicator.parameters:addInteger("L1", "1. Length", "Length", 3);
	indicator.parameters:addInteger("L2", "2. Length", "Length", 5);
	indicator.parameters:addInteger("L3", "3. Length", "Length", 10);
	indicator.parameters:addInteger("L4", "4. Length", "Length", 20);
	indicator.parameters:addInteger("L5", "5. Length", "Length", 50);
	
    indicator.parameters:addInteger("Smoothing", "Smoothing", "Smoothing", 3);

	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color1", "Weight of Evidence Line Color", "Weight of Evidence Line Color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color2", "Signal Line Color", "Signal Line Color", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addGroup("Buy/Sell Levels");
	 indicator.parameters:addDouble("OB", "OB level", "OB level", 100);
    indicator.parameters:addDouble("OS", "OS level", "OS level", 0);
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local WoE,Signal,signal;
local first;
local source = nil;
local OB,OS;
local Smoothing;
local L={};
local Price;
local EMA={};
local RSI={};
local PVT;
local OBV;
local ATR; 
local WAD={};
local Min={};
-- Routine
function Prepare(nameOnly)
    Smoothing = instance.parameters.Smoothing;
	Price = instance.parameters.Price;
	L[1]= instance.parameters.L1;
	L[2]= instance.parameters.L2;
	L[3]= instance.parameters.L3;
	L[4]= instance.parameters.L4;
	L[5]= instance.parameters.L5;
    OB = instance.parameters.OB;
    OS = instance.parameters.OS;
    source = instance.source;
	
	
	local name = profile:id() .. "(" .. source:name().. ", " .. Price.. ", " .. L[1].. ", " .. L[2].. ", " .. L[3].. ", " .. L[4].. ", " .. L[5].. ", " .. Smoothing.. ")";
    instance:name(name);
    if   (nameOnly) then
        return;
    end
	
	
	assert(core.indicators:findIndicator("WAD") ~= nil, "Please, download and install WAD.LUA indicator");    
	
	 
    first = source:first();
	
	for i=1, 5 ,1 do
	EMA[i]= core.indicators:create("EMA", source[Price], L[i]);
	first=math.max(first, EMA[i].DATA:first());
	RSI[i]= core.indicators:create("RSI", source[Price], L[i]);
	first=math.max(first, RSI[i].DATA:first());
	WAD[i]= core.indicators:create("WAD", source, L[i]);
	first=math.max(first, WAD[i].DATA:first());
	
	Min[i]= instance:addInternalStream(0, 0);
	end
	
	PVT = instance:addInternalStream(0, 0);
	
	OBV= core.indicators:create("OBV", source  );
	first=math.max(first, OBV.DATA:first());
	
	ATR= core.indicators:create("ATR", source, L[3]  );	
	first=math.max(first, ATR.DATA:first());

    
 
        WoE = instance:addStream("WoE", core.Line, name, "WoE", instance.parameters.color1,first);
		WoE:addLevel(OB, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	    WoE:addLevel(OS, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
		WoE:setWidth(instance.parameters.width1);
        WoE:setStyle(instance.parameters.style1);
		signal = core.indicators:create("EMA", WoE, Smoothing);
		
		Signal = instance:addStream("Signal", core.Line, name, "Signal", instance.parameters.color2,signal.DATA:first());
		Signal:setWidth(instance.parameters.width2);
        Signal:setStyle(instance.parameters.style2);
		
		
		WoE:setPrecision(math.max(2, instance.source:getPrecision()));
	    Signal:setPrecision(math.max(2, instance.source:getPrecision()));
		
   
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)

    OBV:update(mode);	
	ATR:update(mode);	
	 
    if period < first then
	return;
	end
	
	 local Total=0;
	
	local max= mathex.max(source.high, period-L[3]+1, period);
	 PVT[period] = ((source.close [period] - source.close [period-1] ) / source.close[period-1]) * source.volume[period] + PVT [period - 1];        
	
	for i=1, 5 ,1 do	
    EMA[i]:update(mode);
		if source[Price][period]>= EMA[i].DATA[period] then
		Total=Total+1;
		end
	RSI[i]:update(mode);	
	    if RSI[i].DATA[period]>= 50 then
		Total=Total+1;
		end
		
	
	    if OBV.DATA[period]>= OBV.DATA[period-L[i]+1] then
		Total=Total+1;
		end	
		
		if source[Price][period]> (max +ATR.DATA[period]*i) then
		Total=Total+1;
		end
		
		 if PVT[period]>= PVT[period-L[i]+1] then
		Total=Total+1;
		end	
		
	    WAD[i]:update(mode);
	    if WAD[i].DATA[period]>= WAD[i].DATA[period-L[i]+1] then
		Total=Total+1;
		end	
		
		if PercentRank( source[Price], L[i],period) >= 50 then
		Total=Total+1;
		end
		
		First , Second= Calculate(period,i);
		
		if First > Second then
		Total=Total+1;
		end
		
		
	end
	
	
    WoE[period] = 100*Total/40; 
	
	signal:update(mode);
	
	if period < signal.DATA:first() then
	return;
	end
	
	Signal[period]= signal.DATA[period];
	
end

function Calculate (Start, i)

local First=0;
local Second=0;

Min[i][Start]= mathex.min(source.low, Start-L[i]+1, Start);

for period= Start, source:first(), -1 do
   
   if Min[i][period]> Min[i][period-1] then
   First = period;
   end
   
   if Min[i][period] < Min[i][period-1] then
   Second = period;
   end
   
   if First~= 0 and Second~= 0 then
   break;
   end

end

return First, Second;

end


function PercentRank( Data, Periods,period) 
 
   local Count = 0; 
   for  i = 1, Periods, 1  do  
	   if  Data[period] >  Data[period-i] then
	   Count = Count+1;
	   end
   end 
   
  return 100 * Count / Periods; 
end 

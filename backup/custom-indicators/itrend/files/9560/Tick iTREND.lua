-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3880

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2021, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                              Support our efforts by donating   | 
--|                                                                 Paypal: https://goo.gl/9Rj74e  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |
--|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C                                 |
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |                                                  |   
--+------------------------------------------------------------------------------------------------+

function Init()
    indicator:name("iTREND");
    indicator:description("iTREND");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	
 
	
	
	indicator.parameters:addGroup("Bollinger  Component Parameters");	
	indicator.parameters:addString("Bollinger_Mode", "Bollinger Mode", "", "CL");
	indicator.parameters:addStringAlternative("Bollinger_Mode", "Central Band Line", "", "CL");
	indicator.parameters:addStringAlternative("Bollinger_Mode","Top Band Line", "", "TL");
	indicator.parameters:addStringAlternative("Bollinger_Mode","Bottom Band Line", "", "BL");
 
	indicator.parameters:addInteger("Bollinger_Period", "Bands Period", "", 20);
	indicator.parameters:addDouble("Bollinger_Deviation", "Bands Deviation", "", 2);
	 
	
	indicator.parameters:addGroup("Power Component Parameters");	 
    indicator.parameters:addInteger("Period", "Min/Max Period", "", 2);
    indicator.parameters:addInteger("Power_Period", "Power Period", "", 13);
	indicator.parameters:addString("Power_Mode", "Power MA Mode", "", "EMA");
	 indicator.parameters:addStringAlternative("Power_Mode", "(EMA) Exponential Moving Average", "", "EMA");
    indicator.parameters:addStringAlternative("Power_Mode", "(SMA) Simple Moving Average", "", "MVA");   
    indicator.parameters:addStringAlternative("Power_Mode", "(LWMA) Linear-weighted Moving Average", "", "LWMA");
    indicator.parameters:addStringAlternative("Power_Mode", "(LSMA) Least Square Moving Average (Regression)", "", "REGRESSION");
    indicator.parameters:addStringAlternative("Power_Mode", "(SMMA) Smoothed Moving Average", "", "SMMA");
    indicator.parameters:addStringAlternative("Power_Mode", "(WMA) Wilders Smooth", "", "WMA");
   
	
	indicator.parameters:addGroup("Bollinger Component Style Parameters");
	indicator.parameters:addInteger("Bollinger_Width", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("Bollinger_Style", "Line Style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("Bollinger_Style", core.FLAG_LINE_STYLE);	
	indicator.parameters:addColor("Bollinger_Color", "Color of Bollinger Line", "", core.rgb(0, 255, 0));
	
	indicator.parameters:addGroup("Power Component Style Parameters");
	indicator.parameters:addInteger("Power_Width", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("Power_Style", "Line Style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("Power_Style", core.FLAG_LINE_STYLE);		
	indicator.parameters:addColor("Power_Color", "Color of Power Line", "", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local Bands_Deviation; 
local Power_Period;
local Power_Mode; 
local Bollinger_Mode; 
local Bands_Period;
local Price_Mode;
local first;
local source = nil;
local Period;
-- Streams block
local Indicator_Power;
local Indicator_Bollinger;
local Power = nil;
local  Bollinger = nil;
local BANDS={};


-- Routine
function Prepare(nameOnly) 
    Bollinger_Mode= instance.parameters.Bollinger_Mode;  
    Bollinger_Deviation= instance.parameters.Bollinger_Deviation; 
    Bollinger_Period= instance.parameters.Bollinger_Period; 
    Power_Mode = instance.parameters.Power_Mode;
    Power_Period = instance.parameters.Power_Period;
	Period= instance.parameters.Period;
    source = instance.source;
    

    local name = profile:id() .. "(" ..  source:name()    .. ", " .. tostring(Period)   .. ", " .. tostring(Power_Period).. ", " .. tostring(Power_Mode)
	 .. ", " .. tostring(Bollinger_Period).. ", " .. tostring(Bollinger_Deviation).. ", " .. tostring(Bollinger_Mode)  .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	
    assert(core.indicators:findIndicator(Power_Mode) ~= nil, Power_Mode .. " indicator must be installed");
	Indicator_Power = core.indicators:create(Power_Mode, source ,Power_Period ); 
	Indicator_Bollinger = core.indicators:create("BB", source ,Power_Period ); 
	BANDS["TL"]=  Indicator_Bollinger:getStream (0);
	BANDS["BL"]=  Indicator_Bollinger:getStream (1);	
    BANDS["CL"]=  Indicator_Bollinger:getStream (2);	
	
	first = math.max( source:first(),Indicator_Power.DATA:first(),BANDS[Bollinger_Mode]:first() ) ;

 
        Power = instance:addStream("Power", core.Line, name, "Power", instance.parameters.Power_Color, first);
        Power:setPrecision(math.max(2, instance.source:getPrecision()));
		Power:setWidth(instance.parameters.Power_Width);
        Power:setStyle(instance.parameters.Power_Style);
		Bollinger  = instance:addStream("Bollinger", core.Line, name, "Bollinger", instance.parameters.Bollinger_Color, first);
        Bollinger:setPrecision(math.max(2, instance.source:getPrecision()));
		Bollinger:setWidth(instance.parameters.Bollinger_Width);
        Bollinger:setStyle(instance.parameters.Bollinger_Style);
 
 
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period <first or not  source:hasData(period) then
	return;
	end
	
	local min,max=mathex.minmax(source, period-Period+1,  period);
	
	   Indicator_Power:update(mode); 	
	   Indicator_Bollinger:update(mode); 	
	
       Power[period] = -((max - Indicator_Power.DATA[period])+ (min - Indicator_Power.DATA[period])); 
	   
	   Bollinger[period]= source[period] - BANDS[Bollinger_Mode][period];
	 
end


-- Id: 3582
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3880

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

function Init()
    indicator:name("iTREND");
    indicator:description("iTREND");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	
	indicator.parameters:addGroup("Price Type");	
	
	indicator.parameters:addString("Price_Mode", "Price Type", "", "close");
	indicator.parameters:addStringAlternative("Price_Mode","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price_Mode", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price_Mode", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price_Mode", "LOW", "", "low");    
    indicator.parameters:addStringAlternative("Price_Mode", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price_Mode", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price_Mode", "WEIGHTED", "", "weighted");
	
	
	indicator.parameters:addGroup("Bollinger  Component Parameters");	
	indicator.parameters:addString("Bollinger_Mode", "Bollinger Mode", "", "CL");
	indicator.parameters:addStringAlternative("Bollinger_Mode", "Central Band Line", "", "CL");
	indicator.parameters:addStringAlternative("Bollinger_Mode","Top Band Line", "", "TL");
	indicator.parameters:addStringAlternative("Bollinger_Mode","Bottom Band Line", "", "BL");
    
	
	indicator.parameters:addString("Bollinger_Price", "Power Price", "", "close");
	indicator.parameters:addStringAlternative("Bollinger_Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Bollinger_Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Bollinger_Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Bollinger_Price", "LOW", "", "low");    
    indicator.parameters:addStringAlternative("Bollinger_Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Bollinger_Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Bollinger_Price", "WEIGHTED", "", "weighted");
	indicator.parameters:addInteger("Bollinger_Period", "Bands Period", "", 20);
	indicator.parameters:addDouble("Bollinger_Deviation", "Bands Deviation", "", 2);
	 
	
	indicator.parameters:addGroup("Power Component Parameters");	
	indicator.parameters:addString("Power_Price", "Power Price", "", "close");
	indicator.parameters:addStringAlternative("Power_Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Power_Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Power_Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Power_Price", "LOW", "", "low");    
    indicator.parameters:addStringAlternative("Power_Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Power_Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Power_Price", "WEIGHTED", "", "weighted");

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
local Power_Price;
local Power_Period;
local Power_Mode;
local Bollinger_Price;
local Bollinger_Mode;
local Price;
local Bands_Period;
local Price_Mode;
local first;
local source = nil;

-- Streams block
local Indicator_Power;
local Indicator_Bollinger;
local Power = nil;
local  Bollinger = nil;
local BANDS={};


-- Routine
function Prepare(nameOnly)
    Price_Mode= instance.parameters.Price_Mode;
    Bollinger_Mode= instance.parameters.Bollinger_Mode;
    Bollinger_Price= instance.parameters.Bollinger_Price;  
    Bollinger_Deviation= instance.parameters.Bollinger_Deviation; 
    Bollinger_Period= instance.parameters.Bollinger_Period;
    Power_Price = instance.parameters.Power_Price;
    Power_Mode = instance.parameters.Power_Mode;
    Power_Period = instance.parameters.Power_Period;
    source = instance.source;
    

    local name = profile:id() .. "(" ..  source:name() .. ", " .. tostring(Price_Mode) .. ", " .. tostring(Power_Price) .. ", " .. tostring(Power_Period).. ", " .. tostring(Power_Mode)
	.. ", " .. tostring(Bollinger_Price).. ", " .. tostring(Bollinger_Period).. ", " .. tostring(Bollinger_Deviation).. ", " .. tostring(Bollinger_Mode)  .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	
    assert(core.indicators:findIndicator(Power_Mode) ~= nil, Power_Mode .. " indicator must be installed");
	Indicator_Power = core.indicators:create(Power_Mode, source[Power_Price],Power_Period ); 
	Indicator_Bollinger = core.indicators:create("BB", source[Bollinger_Price],Power_Period ); 
	BANDS["TL"]=  Indicator_Bollinger:getStream (0);
	BANDS["BL"]=  Indicator_Bollinger:getStream (1);	
    BANDS["CL"]=  Indicator_Bollinger:getStream (2);	
	
	first = math.max( source:first(),Indicator_Power.DATA:first(),BANDS[Bollinger_Mode]:first() ) ;

    if (not (nameOnly)) then
        Power = instance:addStream("Power", core.Line, name, "Power", instance.parameters.Power_Color, first);
    Power:setPrecision(math.max(2, instance.source:getPrecision()));
		Power:setWidth(instance.parameters.Power_Width);
        Power:setStyle(instance.parameters.Power_Style);
		Bollinger  = instance:addStream("Bollinger", core.Line, name, "Bollinger", instance.parameters.Bollinger_Color, first);
    Bollinger:setPrecision(math.max(2, instance.source:getPrecision()));
		Bollinger:setWidth(instance.parameters.Bollinger_Width);
        Bollinger:setStyle(instance.parameters.Bollinger_Style);
    end
	Price= source[Price_Mode];
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period >= first and source:hasData(period) then
	
	   Indicator_Power:update(mode); 	
	   Indicator_Bollinger:update(mode); 	
	
       Power[period] = -((source.high[period] - Indicator_Power.DATA[period])+ (source.low[period] - Indicator_Power.DATA[period])); 
	   
	   Bollinger[period]= Price[period] - BANDS[Bollinger_Mode][period];
	   
    end
end


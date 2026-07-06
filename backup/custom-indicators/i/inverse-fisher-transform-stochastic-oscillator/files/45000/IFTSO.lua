-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=26223
-- Id: 7902

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
    indicator:name(" Inverse Fisher Transform Stochastic Oscillator");
    indicator:description(" Inverse Fisher Transform Stochastic Oscillator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("P0", "MA Period", "MA Period", 2);
    indicator.parameters:addInteger("P1", "Stochastic Period", "Stochastic Period", 30);
    indicator.parameters:addInteger("P2", "Slowing Period", "Slowing Period", 5);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("IFTStoch_color", "Color of IFTStoch", "Color of IFTStoch", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Signal_color", "Color of Signal", "Color of Signal", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 80);
    indicator.parameters:addDouble("oversold","Oversold Level","", 20);
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
local P0;
local P1;
local P2;
local MA={};
local first;
local source = nil;

-- Streams block
local IFTStoch = nil;
local Signal = nil;
local RBW, One, Two;
-- Routine
function Prepare(nameOnly)
    P0 = instance.parameters.P0;
    P1 = instance.parameters.P1;
    P2 = instance.parameters.P2;
    source = instance.source;
     
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(P0) .. ", " .. tostring(P1) .. ", " .. tostring(P2) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
		MA[1] = core.indicators:create("MVA", source, P0);
		MA[2] = core.indicators:create("MVA", MA[1].DATA, P0);
		MA[3] = core.indicators:create("MVA", MA[2].DATA, P0);
		MA[4] = core.indicators:create("MVA", MA[3].DATA, P0);
		MA[5] = core.indicators:create("MVA", MA[4].DATA, P0);
		MA[6] = core.indicators:create("MVA", MA[5].DATA, P0);
		MA[7] = core.indicators:create("MVA", MA[6].DATA, P0);
		MA[8] = core.indicators:create("MVA", MA[7].DATA, P0);
		MA[9] = core.indicators:create("MVA", MA[8].DATA, P0);
		MA[10] = core.indicators:create("MVA", MA[9].DATA, P0);
		
		
		RBW = instance:addInternalStream(MA[10].DATA:first(), 0);
		One = instance:addInternalStream(MA[10].DATA:first()+P1, 0);
		Two = instance:addInternalStream(MA[10].DATA:first()+P1, 0);
        IFTStoch = instance:addStream("IFTStoch", core.Line, name .. ".IFTStoch", "IFTStoch", instance.parameters.IFTStoch_color, MA[10].DATA:first() +P1+P2);
    IFTStoch:setPrecision(math.max(2, instance.source:getPrecision()));
		IFTStoch:setWidth(instance.parameters.width1);
        IFTStoch:setStyle(instance.parameters.style1);
        Signal = instance:addStream("Signal", core.Line, name .. ".Signal", "Signal", instance.parameters.Signal_color, MA[10].DATA:first() +P1+P2);
    Signal:setPrecision(math.max(2, instance.source:getPrecision()));
		Signal:setWidth(instance.parameters.width1);
        Signal:setStyle(instance.parameters.style1);
		
		IFTStoch:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
		IFTStoch:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color); 
		IFTStoch:addLevel(50, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color); 
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

  
	
	MA[1]:update(mode);
	MA[2]:update(mode);
	MA[3]:update(mode);
	MA[4]:update(mode);
	MA[5]:update(mode);
	MA[6]:update(mode);
	MA[7]:update(mode);
	MA[8]:update(mode);
	MA[9]:update(mode);
	MA[10]:update(mode);
	
	if period < MA[10].DATA:first()   then
	return;
	end
	
	
	RBW[period] = ( 5 * MA[1].DATA[period] + 4 * MA[2].DATA[period] + 3 * MA[3].DATA[period] + 2 * MA[4].DATA[period] + MA[5].DATA[period] + MA[6].DATA[period] + MA[7].DATA[period] + MA[8].DATA[period] + MA[9].DATA[period] + MA[10].DATA[period] ) / 20 ;
	
	
	if period < MA[10].DATA:first() +P1  then
	return;
	end
	local min, max = mathex.minmax (RBW, period-P1+1, period)
	
	One[period] = RBW[period] -min;
	Two[period] =max-min;
	 
	 if period < MA[10].DATA:first() +P1+P2  then
	return;
	end

 IFTStoch[period]  = (mathex.sum(One, period- P2+1, period )/ ( mathex.sum(Two, period- P2+1, period )  + 0.0001 ) * 100 ) ;

local x = 0.1 * ( IFTStoch[period] - 50 ) ;


Signal[period] = ( (  math.exp ( 2 * x ) - 1 ) /  (  math.exp ( 2 * x ) + 1 ) + 1 ) * 50 ;
 
 
 
end


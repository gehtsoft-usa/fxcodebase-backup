-- Id: 10698
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60116

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
    indicator:name("PG Cycle");
    indicator:description("PG Cycle");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("P1", "1. Averaging Period", "1. Period", 9);
    indicator.parameters:addInteger("P2", "2. Averaging Period", "2. Period", 19);
    indicator.parameters:addInteger("P3", "3. Averaging Period", "3. Period", 6);
    indicator.parameters:addInteger("P4", "RSI  Period", "RSI Period", 8);
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("PGC_color", "Color of PGC", "Color of PGC", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 70);
    indicator.parameters:addDouble("oversold","Oversold Level","", 30);
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
local P1;
local P2;
local P3;
local P4;
local hausse, baisse;   
local first;
local source = nil;

-- Streams block
local PGC = nil;
local mmHausse,mmBaisse;

local AVG1,AVGofAVG1,AVG2,AVGofAVG2,AVG3,AVGofAVG3;
local z1, z2,z3, e;

-- Routine
function Prepare(nameOnly)
    P1 = instance.parameters.P1;
    P2 = instance.parameters.P2;
    P3 = instance.parameters.P3;
    P4 = instance.parameters.P4;
	
	source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(P1) .. ", " .. tostring(P2) .. ", " .. tostring(P3) .. ", " .. tostring(P4) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
	
		z1 = instance:addInternalStream(0, 0);
		z2 = instance:addInternalStream(0, 0);
		z3 = instance:addInternalStream(0, 0);
		e = instance:addInternalStream(0, 0);
		hausse = instance:addInternalStream(0, 0);
		baisse = instance:addInternalStream(0, 0);
		
		
		AVG1 = core.indicators:create("EMA", source, P1);
		AVGofAVG1 = core.indicators:create("EMA", AVG1.DATA, P1);
		
		
		AVG2 = core.indicators:create("EMA", source, P2);
		AVGofAVG2 = core.indicators:create("EMA", AVG2.DATA, P2);
		
		AVG3 = core.indicators:create("EMA", e, P3);
		AVGofAVG3 = core.indicators:create("EMA", AVG3.DATA, P3);
		
		mmHausse = core.indicators:create("WMA", hausse, P4);
		mmBaisse = core.indicators:create("WMA", baisse, P4);
        PGC = instance:addStream("PGC", core.Line, name, "PGC", instance.parameters.PGC_color, mmHausse.DATA:first());
    PGC:setPrecision(math.max(2, instance.source:getPrecision()));
		PGC:setWidth(instance.parameters.width);
        PGC:setStyle(instance.parameters.style);
		PGC:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
		PGC:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
		
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)


       AVG1:update(mode); 
	   AVGofAVG1:update(mode);
	   
	   if period < AVGofAVG1.DATA:first()   then
	   return;
	   end
	   
	   z1[period] = (2*AVG1.DATA[period])-AVGofAVG1.DATA[period];
	   
	   AVG2:update(mode); 
	   AVGofAVG2:update(mode);
	   
	    if period < AVGofAVG2.DATA:first()   then
	   return;
	   end
	   
	   z2[period] = (2*AVG2.DATA[period])-AVGofAVG2.DATA[period];
	   
	   
	   e[period] = z1[period] - z2[period]
	   
	   
	    if period < AVGofAVG3.DATA:first()   then
	   return;
	   end
	   AVG3:update(mode); 
	   AVGofAVG3:update(mode);
	   
	   z3[period] = (2*AVG3.DATA[period])-AVGofAVG3.DATA[period];
		  
		if z3[period] -z3[period-1] > 0 then 
		hausse[period]=z3[period] -z3[period-1];
        baisse[period]=0;
        end		
		if z3[period-1] -z3[period] > 0 then 
		hausse[period]=0
        baisse[period]=z3[period-1] -z3[period];
        end		   
		
		mmHausse:update(mode)
        mmBaisse:update(mode)
		
		if period < mmHausse.DATA:first()   then
	   return;
	   end
	   
	   local RS = mmHausse.DATA[period] / mmBaisse.DATA[period];
	
	PGC[period] =  100 - 100 / (1 + RS);
 end

 --[[

z1 = dema[9](close)
z2 = dema[19](close)
e = z1 - z2
z3 = dema[6](e)
f = z3
rem daily variations
hausse = MAX(0,f-f[1])
baisse  = MAX(0,f[1]-f)
rem average earnings if a period of rising
rem average losses if a period of falling
mmHausse = WILDERAVERAGE[8](hausse)
mmBaisse = WILDERAVERAGE[8](baisse)
rem ratio
RS = mmHausse / mmBaisse[/b]
Rem finaly the RSI of the ZeroLag
PGcycle = 100 - 100 / (1 + RS)


]]
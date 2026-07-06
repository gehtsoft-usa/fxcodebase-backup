-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=27709
-- Id: 8113

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
    indicator:name("Simple Stochastic Stack");
    indicator:description("Stochastic Stack");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
     indicator.parameters:addGroup("Calculation");	
	 
	 indicator.parameters:addInteger("Period", "Period", "Period", 34);
     indicator.parameters:addDouble("Next", "Incremental (Next)", "Incremental (Next)", 1.2);
	
	 indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("Up", "Color of UP Trend", " ", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Color of DOWN Trend", " ", core.rgb(255, 0, 0));
	
	indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 25);
    indicator.parameters:addDouble("oversold","Oversold Level","", -25);
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
local Up, Down;
local Next,Period;
local first;
local source = nil;
local  K={};
local SD={};
local  D={};
local  MVAT_K={};
local MVAT_D={};

-- Streams block
local SS = nil;
local Indicator={};
-- Routine
function Prepare(nameOnly)
    Next = instance.parameters.Next;
	Period = instance.parameters.Period;
    source = instance.source;
	Up = instance.parameters.Up;
	Down = instance.parameters.Down;
	first = source:first();

    local name = profile:id() .. "(" .. source:name() .. "," .. Period .. "," .. Next  .. ")";
    instance:name(name);

	if (not (nameOnly)) then
		local i;
		for i = 1, 8 , 1 do
			if i == 1 then		
				K[i]= Period;
				SD[i]= K[i]/2;
				D[i]= SD[i]/2;	
				MVAT_K[i]=  "EMA";
				MVAT_D[i]=  "EMA";
			else
				K[i]= K[i-1]*Next;
				SD[i]= K[i]/2;
				D[i]= SD[i]/2;	
				MVAT_K[i]=  "EMA";
				MVAT_D[i]=  "EMA";
			end  
		
			Indicator[i]= core.indicators:create("STOCHASTIC", source, K[i], SD[i], D[i],MVAT_K[i],MVAT_D[i]);
			first = math.max(first,Indicator[i].K:first() )
		end
        SS = instance:addStream("SS", core.Bar, name, "SS", Up, first);
    SS:setPrecision(math.max(2, instance.source:getPrecision()));
		SS:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
		SS:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

    local i;
	for i = 1, 8 , 1 do
	Indicator[i]:update(mode);
	end

    if period < first   then
	return;
	end
	
	SS[period] = 0;
	
	 
	for i = 1, 8 , 2 do
			
			SS[period] = SS[period] + (Indicator[i].K[period] - Indicator[i+1].K[period]);
	end		
    
	
	if SS[period]> 0 then
	SS:setColor(period, Up);
	else
	SS:setColor(period, Down);
	end
end


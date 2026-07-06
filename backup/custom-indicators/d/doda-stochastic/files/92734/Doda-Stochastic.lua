-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60317
-- Id: 11156

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
    indicator:name("Doda-Stochastic");
    indicator:description("Doda-Stochastic");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Slw", "Slow Period", "Slow Period", 8);
    indicator.parameters:addInteger("Pds", "Stochastic Period", "Stochastic Period", 13);
    indicator.parameters:addInteger("Slwsignal", "Signal Period", "Signal Period", 9);
	
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("K_color", "Color of K", "Color of K", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("D_color", "Color of D", "Color of D", core.rgb(255, 0, 0));
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
local Slw;
local Pds;
local Slwsignal;

local first;
local source = nil;
local R;
local K = nil;
local D = nil;
local smconst, smconst1;
-- Routine
function Prepare(nameOnly)
    Slw = instance.parameters.Slw;
    Pds = instance.parameters.Pds;
    Slwsignal = instance.parameters.Slwsignal;
	
	
	smconst=2/(1+Slw);
    smconst1=2/(1+Slwsignal);
	
    source = instance.source;
    first = source:first()+Pds;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Slw) .. ", " .. tostring(Pds) .. ", " .. tostring(Slwsignal) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        R= instance:addInternalStream(0, 0);
        K = instance:addStream("K", core.Line, name .. ".K", "K", instance.parameters.K_color, first);
    K:setPrecision(math.max(2, instance.source:getPrecision()));
        D = instance:addStream("D", core.Line, name .. ".D", "D", instance.parameters.D_color, first);
    D:setPrecision(math.max(2, instance.source:getPrecision()));
		K:setWidth(instance.parameters.width1);
        K:setStyle(instance.parameters.style1);
		D:setWidth(instance.parameters.width2);
        D:setStyle(instance.parameters.style2);
		
		K:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
		K:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first or not  source:hasData(period) then
	return;
	end
    
     local minLow, minHigh;
	 local Now;	  	 
	 local Range;
	 
	    --Range=(High[Highest(NULL,0,MODE_HIGH,shift+Pds,Pds)]-Low[Lowest(NULL,0,MODE_LOW,shift+Pds,Pds)]);
        minLow, maxHigh = mathex.minmax(source, period - Pds + 1, period);		
		Range= maxHigh-minLow;
	
		if Range~= 0 then
		 Now=100*((source.close[period]-minLow)/Range)
		else
		Now=50;
        end				
		
       R[period] =smconst *(Now- R[period-1])+ R[period-1];
	   
	     if period < first +Pds then
		return;
		end	   
	   
	     
	    minLow, maxHigh = mathex.minmax(R, period - Pds + 1, period);
		Range= maxHigh-minLow;
		
		if Range~= 0 then
		Now=100*((R[period]-minLow)/Range)
		else
		Now=50;
        end			   
	   
	    K[period]= smconst *(Now-K[period-1])+K[period-1];		
        D[period] = smconst1 *(K[period]-D[period-1])+D[period-1];
		
	
    
end


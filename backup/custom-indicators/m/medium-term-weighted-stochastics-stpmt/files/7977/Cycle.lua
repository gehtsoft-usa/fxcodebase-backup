-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3329
-- Id: 3058

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                   Paypal: https://goo.gl/9Rj74e  |
--|                    Patreon : https://www.patreon.com/mariojemic  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Cycle");
    indicator:description("Cycle");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

	 	Parameters (1 , 5, 3, 3, "MVA", "MVA" ); 
		Parameters (2 , 14, 3, 3, "MVA", "MVA" ); 
		Parameters (3 , 45, 14, 3, "MVA", "MVA" ); 
		Parameters (4 , 75, 20, 3, "MVA", "MVA" ); 
		
		
		
		
		indicator.parameters:addGroup("Cycle Style");
		indicator.parameters:addInteger("width", "Line Width", "", 1, 1, 5);	
       indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
	   indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	   
	   indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
	   
	   
	    indicator.parameters:addGroup("STPMT MA Calculation");
	 indicator.parameters:addInteger("Frame", "The number of periods STPMT MA", "", 9,  2, 1000);
	   
	
     
	 indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 100);
    indicator.parameters:addDouble("oversold","Oversold Level","", -100);
	    indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
   
	
	
end


function Parameters (id , K, SD, D, KS, DS)


  	indicator.parameters:addGroup(id..". STOCHASTIC COMPONENT");
    indicator.parameters:addInteger("K"..id, " ComponentNumber of periods for %K", "", K, 2, 1000);
    indicator.parameters:addInteger("SD"..id,"Component %D slowing periods", "", SD, 2, 1000);
    indicator.parameters:addInteger("D"..id, "The number of periods for %D.", "", D,  2, 1000);

    indicator.parameters:addString("KS"..id, "Component Smoothing type for %K", "", KS);
    indicator.parameters:addStringAlternative("KS"..id, "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("KS"..id, "EMA","", "EMA");
    indicator.parameters:addStringAlternative("KS"..id, "MT4","", "MT");
    
    indicator.parameters:addString("DS"..id, "Component Smoothing type for %D", "", DS);
    indicator.parameters:addStringAlternative("DS"..id, "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("DS"..id, "EMA", "", "EMA"); 	

	
end



-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local DS={};
local KS={};
local K={};
local SD={};
local D={};

local Cycle;
local Frame;



local STOCHASTIC={};
local Indicator={};

local STPMT;
local STPMT_MA;
local MA;

local first;
local source = nil;

-- Routine
function Prepare(nameOnly)
   
    source = instance.source;
    first = source:first();
	Frame= instance.parameters.Frame;
	
	local i;
	local name=  profile:id() .. "(" .. source:name() ..  ")";
	
	for i= 1, 4, 1 do	
		DS[i]=instance.parameters:getString ("DS"..i);
		KS[i]=instance.parameters:getString ("KS"..i);
		K[i]=instance.parameters:getInteger ("K"..i);
		SD[i]=instance.parameters:getInteger ("SD"..i);
		D[i]=instance.parameters:getInteger ("D"..i);
		if not nameOnly then
			Indicator[i] =  core.indicators:create("STOCHASTIC", source, K[i], SD[i], D[i], DS[i], DS[i]);	
			first = math.max(first, Indicator[i].DATA:first() );
			STOCHASTIC[i]= instance:addInternalStream (Indicator[i].DATA:first(), 0);
		end
		name = name..   "(" .. K[i] .. ", ".. SD[i].. ", " .. D[i] .. ", ".. DS[i] .. ", " ..  KS[i]..  ")";
	end
	
	instance:name(name);
	if nameOnly then
		return;
	end
	
	STPMT = instance:addInternalStream (first, 0);	
	MA  = core.indicators:create("MVA", STPMT, Frame);	
	
	
	STPMT_MA = instance:addInternalStream (first, 0);
	

 
	
	Cycle= instance:addStream("Cycle", core.Line, name .. "Cycle", "Cycle",  instance.parameters.color, first+Frame);
	Cycle:setWidth(instance.parameters.width);
	Cycle:setStyle(instance.parameters.style);

    Cycle:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	Cycle:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);  
    
	
    Cycle:setPrecision(math.max(2, instance.source:getPrecision()));
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period < first or not source:hasData(period) then
	return;
	end
	
	local i;
	
	for i= 1, 4, 1 do	
    Indicator[i]:update(mode);	
	
		if Indicator[i].DATA:hasData(period) then	
		STOCHASTIC[i][period] = Indicator[i].DATA[period];
		end
	
	end  
	
   
		
	
	STPMT[period] = (4.1 * STOCHASTIC[1][period] + 2.5 *STOCHASTIC[2][period] + STOCHASTIC[3][period] + 4 * STOCHASTIC[4][period]) / 11.6;	
	
	 if period < first +Frame  then
	return;
	end	
	MA:update(mode);	
	
	STPMT_MA[period]= MA.DATA[period];
	
	Cycle[period]= (STPMT[period]-  STPMT_MA[period])*6;
		
		
 
end


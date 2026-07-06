-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3329
-- Id: 3049

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
    indicator:name("Medium Term Weighted Stochastics");
    indicator:description("Medium Term Weighted Stochastics");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

	 	Parameters (1 , 5, 3, 3, "MVA", "MVA" ); 
		Parameters (2 , 14, 3, 3, "MVA", "MVA" ); 
		Parameters (3 , 45, 14, 3, "MVA", "MVA" ); 
		Parameters (4 , 75, 20, 3, "MVA", "MVA" ); 
		
		
		 indicator.parameters:addGroup("Selector");
		 indicator.parameters:addBoolean("Show", "Show Components", "", true);
		
		indicator.parameters:addGroup("STPMT Style");
		indicator.parameters:addInteger("width", "Line Width", "", 1, 1, 5);	
       indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
	   indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	   
	   indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
	   
	   
	    indicator.parameters:addGroup("STPMT MA Calculation");
	 indicator.parameters:addInteger("Frame", "The number of periods STPMT MA", "", 9,  2, 1000);
	   
	   
	   indicator.parameters:addGroup("STPMT MA Style");
		indicator.parameters:addInteger("width_MA", "Line Width", "", 1, 1, 5);	
       indicator.parameters:addInteger("style_MA", "Line Style", "", core.LINE_SOLID);
	   indicator.parameters:setFlag("style_MA", core.FLAG_LEVEL_STYLE);		   
	   
	   indicator.parameters:addColor("color_MA", "Line Color", "", core.rgb(0, 255, 0));
    
   
	
		 indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 0);
    indicator.parameters:addDouble("oversold","Oversold Level","", 100);
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
 
	indicator.parameters:addColor("color".. id, "Line Color", "", core.rgb( 192,  192,  192));
	
	indicator.parameters:addInteger("width"..id, "Line Width", "", 1, 1, 5);	
    indicator.parameters:addInteger("style"..id, "Line Style", "", core.LINE_DOT);
	indicator.parameters:setFlag("style"..id, core.FLAG_LEVEL_STYLE);	 
	

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

local Show;
local Frame;

local STYLE={};
local  WIDTH={};
local COLOR={};

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
	Show= instance.parameters.Show;
	
	local i;
	local name=  profile:id() .. "(" .. source:name() ..  ")";
	
	for i= 1, 4, 1 do	
		DS[i]=instance.parameters:getString ("DS"..i);
		KS[i]=instance.parameters:getString ("KS"..i);
		K[i]=instance.parameters:getInteger ("K"..i);
		SD[i]=instance.parameters:getInteger ("SD"..i);
		D[i]=instance.parameters:getInteger ("D"..i);
		
		STYLE[i]=instance.parameters:getInteger ("style"..i);
		WIDTH[i]=instance.parameters:getInteger ("width"..i);
		COLOR[i]=instance.parameters:getInteger ("color"..i);
		
		if not nameOnly then
			Indicator[i] =  core.indicators:create("STOCHASTIC", source, K[i], SD[i], D[i], DS[i], DS[i]);	
			
			first = math.max(source:first(), Indicator[i].DATA:first() );
	
			if Show then
				STOCHASTIC[i] = instance:addStream("Stochastic".. i, core.Line, name .. "Stochastic", i,  COLOR[i], first );
    STOCHASTIC[i]:setPrecision(math.max(2, instance.source:getPrecision()));
				STOCHASTIC[i]:setWidth(WIDTH[i]);
				STOCHASTIC[i]:setStyle(STYLE[i]);
			else
				STOCHASTIC[i]= instance:addInternalStream (first, 0);
			end
		end
	
		name = name..   "(" .. K[i] .. ", ".. SD[i].. ", " .. D[i] .. ", ".. DS[i] .. ", " ..  KS[i]..  ")";
	end
	instance:name(name);
	if nameOnly then
		return;
	end
	
	
	STPMT = instance:addStream("STPMT", core.Line, name .. "STPMT", "STPMT",  instance.parameters.color, first);
    STPMT:setPrecision(math.max(2, instance.source:getPrecision()));
	STPMT:setWidth(instance.parameters.width);
	STPMT:setStyle(instance.parameters.style);
	
	MA  = core.indicators:create("MVA", STPMT, Frame);	
	
	
	STPMT_MA = instance:addStream("STPMT_MA", core.Line, name .. "STPMT_MA", "MA",  instance.parameters.color_MA, first+Frame);
    STPMT_MA:setPrecision(math.max(2, instance.source:getPrecision()));
	STPMT_MA:setWidth(instance.parameters.width_MA);
	STPMT_MA:setStyle(instance.parameters.style_MA);
	
	STPMT_MA:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	STPMT_MA:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period < first or not  source:hasData(period) then
	return;
	end
	
	local i;
	
	for i= 1, 4, 1 do	
    Indicator[i]:update(mode);	
	
		if Indicator[i].DATA:hasData(period) then	
		STOCHASTIC[i][period] = Indicator[i].DATA[period];
		end
	
	end  
	
	
	 if period < first +Frame  then
	return;
	end		
		
		
	STPMT[period] = (4.1 * STOCHASTIC[1][period] + 2.5 *STOCHASTIC[2][period] + STOCHASTIC[3][period] + 4 * STOCHASTIC[4][period]) / 11.6;	
	
	
	if period < first +Frame  then
	return;
	end		
	MA:update(mode);
	STPMT_MA[period]= MA.DATA[period];
		
		
 
end


-- Id: 1491
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2040

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
    indicator:name("Dynamic Zone RSI");
    indicator:description("Dynamic Zone RSI");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addInteger("RF", "RSI Frame", "", 5);
	indicator.parameters:addInteger("BF", "Band Period", "", 30);
	indicator.parameters:addDouble("SD", "Standard deviation", "", 1.3185);
	
	
    indicator.parameters:addColor("RSI_color", "Color of RSI", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addColor("BAND_color", "Color of Band", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addColor("CENTRAL_color", "Color of Central Line", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local RF;
local BF;
local SD;

local first;
local source = nil;

-- Streams block
local RSI = nil;
local UP=nil;
local DOWN=nil;
local CENTRAL=nil;
local BUFFER=nil;

-- Routine
function Prepare(nameOnly)
    RF = instance.parameters.RF;
	BF = instance.parameters.BF;
	SD = instance.parameters.SD;
    source = instance.source;
    
	
	 local name = profile:id() .. "(" .. source:name() .. ", " .. RF.. ", " .. BF.. ", " .. SD .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
			
	BUFFER=core.indicators:create("RSI",  source.close, RF);
	RSI = instance:addStream("RSI", core.Line, name, "RSI", instance.parameters.RSI_color, BUFFER.DATA:first());	
	RSI:setWidth(instance.parameters.width1);
    RSI:setStyle(instance.parameters.style1);
		
	BB=core.indicators:create("BB",  RSI, BF, SD);
	
	first = source:first();
    
	CENTRAL = instance:addStream("CENTRAL", core.Line, name, "Central", instance.parameters.CENTRAL_color, first);
	CENTRAL:setWidth(instance.parameters.width3);
    CENTRAL:setStyle(instance.parameters.style3);
	
	UP = instance:addStream("UP", core.Line, name, "Top", instance.parameters.BAND_color, first);
	UP:setWidth(instance.parameters.width2);
    UP:setStyle(instance.parameters.style2);
	
	DOWN = instance:addStream("DOWN", core.Line, name, "Bottom", instance.parameters.BAND_color, first);
	DOWN:setWidth(instance.parameters.width2);
    DOWN:setStyle(instance.parameters.style2);
	
	RSI:setPrecision(math.max(2, instance.source:getPrecision()));
	CENTRAL:setPrecision(math.max(2, instance.source:getPrecision()));
	UP:setPrecision(math.max(2, instance.source:getPrecision()));
	DOWN:setPrecision(math.max(2, instance.source:getPrecision()));
	
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)
     
	
	 
	 
     BUFFER:update(mode); 
	 
    if period <  BUFFER.DATA:first() then
    return;
    end
	
	 RSI[period]= BUFFER.DATA[period];
	 
	 BB:update(mode);
	 
	  if period < first or not source:hasData(period) then 
	 return;
	 end	 
				
				
			CENTRAL[period] = BB.AL[period];
	        UP[period] =BB.TL[period] ;
	        DOWN[period] = BB.BL[period];
				
 
end


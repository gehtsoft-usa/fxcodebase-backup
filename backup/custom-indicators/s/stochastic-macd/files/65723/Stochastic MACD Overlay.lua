-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=40074

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  | 
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal:  https://goo.gl/9Rj74e   |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |
--|                                                      Buy Me a Coffee:  http://tiny.cc/pjh9vz   |  
--+------------------------------------------------------------------------------------------------+


function Init()
    indicator:name("Stochastic MACD Overlay");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Short", "Short Period", "Short Period", 12);
    indicator.parameters:addInteger("Long", "Long Period", "Long Period", 35);
    indicator.parameters:addInteger("Signal", "Signal Period", "Signal Period", 9);
	indicator.parameters:addInteger("Stochastic", "Stochastic Period", "Stochastic Period", 18);
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
 indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
 
	
	indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("OB", "Overbought Level","", 80);
    indicator.parameters:addDouble("OS","Oversold Level","", 20);
	
	
	
	indicator.parameters:addGroup("Style");		
	indicator.parameters:addColor("OB_UP", "OB Up Color","", core.rgb(0, 255, 0));
	indicator.parameters:addColor("OB_DN", "OB Down Color","", core.rgb(0, 200, 0)); 
	
	indicator.parameters:addColor("Positive_Up", "Positive Up Color","", core.rgb(0, 128, 0));
	indicator.parameters:addColor("Positive_Down", "Positive Down Color","", core.rgb(0, 75, 0)); 

	indicator.parameters:addColor("Negative_Up", "Negative Up Color","", core.rgb(128, 0, 0));
	indicator.parameters:addColor("Negative_Down", "Negative Down Color","", core.rgb(75, 0, 0)); 	
	
	indicator.parameters:addColor("OS_UP", "OS Up Color","", core.rgb(255, 0, 0));
	indicator.parameters:addColor("OS_DN", "OS Down Color","", core.rgb(200, 0, 0)); 
	
	
	indicator.parameters:addInteger("Transparency", "Transparency", "Transparency",50);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Short;
local Long;
local Signal;
local Method;
local Stochastic;
local source = nil;
local B1, B2, E1, E2;
-- Streams block
local STOCHMACD = nil;

-- Routine
function Prepare(nameOnly)
    Short = instance.parameters.Short;
    Long = instance.parameters.Long;
    Signal = instance.parameters.Signal;
	Method = instance.parameters.Method;
	Stochastic = instance.parameters.Stochastic;
	OB = instance.parameters.OB;
	OS = instance.parameters.OS;
    source = instance.source;
	
    if  nameOnly then
	return;
	end	
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Short) .. ", " .. tostring(Long) .. ", " .. tostring(Signal) .. ", " .. tostring(Method)  .. ", " .. tostring(Stochastic).. ")";
    instance:name(name);


    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
    E1 = core.indicators:create(Method, source, Short);
    E2 = core.indicators:create(Method, source, Long);
    B1= instance:addInternalStream(0, 0);
    E3 = core.indicators:create(Method, B1, Signal);
    B2= instance:addInternalStream(0, 0);
		
		
		
    STOCHMACD = instance:addInternalStream(0, 0);
    STOCHMACD:setPrecision(math.max(2, instance.source:getPrecision()));
		
		
	instance:ownerDrawn(true);		
 
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

    E1:update(mode);
    E2:update(mode);
	
    if period< math.max(E1.DATA:first(), E2.DATA:first())  then
	return;
	end
	
	B1[period]= E1.DATA[period]-E2.DATA[period];
	E3:update(mode);
	
	if period< E3.DATA:first()   then
	return;
	end
	  
 
   
    B2[period]= B1[period] - E3.DATA[period];
    B2[period]= B1[period] - E3.DATA[period];

   
    STOCHMACD[period] =100*(( B1[period]) - E3.DATA[period]  -mathex.min(B2, period -Stochastic+1, period))/(mathex.max(B2, period -Stochastic+1, period)-mathex.min(B2, period -Stochastic+1, period) );
				
    
end


local init = false;

function Draw (stage, context)

    if stage  ~= 0 then
	return;
	end 
	
   context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom());
   
    if not init then
	init =true; 
	Transparency=context:convertTransparency (instance.parameters.Transparency);
 
	context:createSolidBrush (11,  instance.parameters.OB_UP)
	context:createSolidBrush (12,  instance.parameters.OB_DN)	

	context:createSolidBrush (13,  instance.parameters.Positive_Up)
	context:createSolidBrush (14,  instance.parameters.Positive_Down)

	context:createSolidBrush (15,  instance.parameters.Negative_Up)
	context:createSolidBrush (16,  instance.parameters.Negative_Down)	

	context:createSolidBrush (17,  instance.parameters.OS_UP)
	context:createSolidBrush (18, instance.parameters.OS_DN)	
	end
	
        local first = math.max(source:first(), context:firstBar ());
        local last = math.min (context:lastBar (), source:size()-1);
		
    

	    
 
	
 
			    for i= first, last, 1 do	 
			    x0, x1, x2 = context:positionOfBar (i);	
					if STOCHMACD[i]> OB then 
					
						if STOCHMACD[i] > STOCHMACD[i-1] then
						context:drawRectangle ( -1,11, x1, context:top(), x2, context:bottom(), Transparency); 
						else
						context:drawRectangle ( -1,12, x1, context:top(), x2, context:bottom(), Transparency); 
						end
					elseif STOCHMACD[i]> 0 then 
					
						if STOCHMACD[i] > STOCHMACD[i-1] then
						context:drawRectangle ( -1,13, x1, context:top(), x2, context:bottom(), Transparency); 
						else
						context:drawRectangle ( -1,14, x1, context:top(), x2, context:bottom(), Transparency); 
						end	

					elseif STOCHMACD[i]>= OS then 
					
						if STOCHMACD[i] > STOCHMACD[i-1] then
						context:drawRectangle ( -1,15, x1, context:top(), x2, context:bottom(), Transparency); 
						else
						context:drawRectangle ( -1,16, x1, context:top(), x2, context:bottom(), Transparency); 
						end								
					
					elseif STOCHMACD[i]< OS then 
					
						if STOCHMACD[i] > STOCHMACD[i-1] then
						context:drawRectangle ( -1,17, x1, context:top(), x2, context:bottom(), Transparency); 
						else
						context:drawRectangle ( -1,18, x1, context:top(), x2, context:bottom(), Transparency); 
						end					
					
					end					

				end
end	

--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
--+------------------------------------------------------------------------------------------------+
--|  Cryptocurrency  |  Network                    |  Address                                      |
--+------------------------------------------------+-----------------------------------------------+
--|  USDT            |  ERC20 (ETH Ethereum)       |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
--|  USDT            |  TRC20 (Tron)               |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
--|  USDT            |  BEP20 (BSC BNB Smart Chain)|  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--|  USDT            |  Matic Polygon              |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--|  USDT            |  SOL Solana                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
--|  USDT            |  ARBITRUM Arbitrum One      |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--+------------------------------------------------+-----------------------------------------------+
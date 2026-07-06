-- Id: 7728

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=8964

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |  
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+


-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("WoodiesCCI");
    indicator:description("WoodiesCCI");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);


   indicator.parameters:addGroup("CCI Calculation");
    indicator.parameters:addInteger("TP", "Trend CCI Period", "", 14);
	 indicator.parameters:addInteger("EP", "Entry CCI Period", "", 6);
    indicator.parameters:addInteger("NP", "Neutral Period", "", 5, 1 , 1000);
	
	
	
	indicator.parameters:addGroup("Price MA Filter Calculation");
	 indicator.parameters:addInteger("LWP", "MA Period", "", 25);
	 
	 indicator.parameters:addString("Price", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted");	
	

	indicator.parameters:addString("Method", "MA Method", "Method" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	indicator.parameters:addStringAlternative("Method", "LSMA", "LSMA" , "LSMA");
	
	indicator.parameters:addGroup("Trend CCI Style");
	indicator.parameters:addColor("Pozitiv", "Color of Pozitiv", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Negativ", "Color of Negativ", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("Neutral", "Color of Neutral", "", core.rgb(128, 128, 128));
	
	indicator.parameters:addGroup("Entry CCI Style");
	indicator.parameters:addColor("Color", "Color of Entry CCI", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
  
	
	indicator.parameters:addGroup("Price Filter Style");
	indicator.parameters:addColor("Pozitiv1", "Color of Pozitiv", "", core.rgb(0,255, 0));
    indicator.parameters:addColor("Negativ1", "Color of Negativ", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("Neutral1", "Color of Neutral", "", core.rgb(128, 128, 128));


	
	   indicator.parameters:addGroup("Levels");
    -- Overbought/oversold level
    indicator.parameters:addDouble("overbought", "Overbought Level", "", 100, -1000, 1000);
    indicator.parameters:addDouble("oversold", "Oversold Level", "",  -100, -1000, 1000);
    indicator.parameters:addInteger("level_overboughtsold_width", "Width", "", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Style", "", core.LINE_SOLID);
	 indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addColor("level_overboughtsold_color", "Line COlor", "", core.rgb(255, 255, 0));
   
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local TP;
local EP
local NP;
local LWP;
local Method;
local first;
local source = nil;
local Price;

-- Streams block
local  Out={};
local Indicator={};
 
-- Routine
function Prepare(nameOnly)   
    TP = instance.parameters.TP;
	EP = instance.parameters.EP;
    NP = instance.parameters.NP;
	LWP = instance.parameters.LWP;
	Method = instance.parameters.Method;
	Price= instance.parameters.Price;
	
    source = instance.source;
  

    local name = profile:id() .. "(" .. source:name() .. source:barSize().. ", " .. tostring(TP)  .. ", " .. tostring(EP).. ", " .. tostring(NP).. ", " .. tostring(Price).. ", " .. tostring(LWP).. ", " .. tostring(Method) .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	 Indicator["Trend"] = core.indicators:create("CCI", source, TP);
	 Indicator["Entry"] = core.indicators:create("CCI", source, EP);

	 assert(core.indicators:findIndicator("LSMA") ~= nil, "Please, download and install LSMA.LUA indicator");
		 
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
	 Indicator["Filter"] = core.indicators:create(Method, source[Price],LWP );
	 
	 	 

	    first =  math.max(Indicator["Filter"].DATA:first(),  Indicator["Trend"].DATA:first(),  Indicator["Entry"].DATA:first() ) ;

    
        Out["Trend"] = instance:addStream("Trend", core.Bar, name .. ".Trend", "Trend", instance.parameters.Neutral, first);
    Out["Trend"]:setPrecision(math.max(2, instance.source:getPrecision()));
		
		Out["Trend"]:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
         Out["Trend"]:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    
	     Out["Filter"] = instance:addStream("Filter", core.Line, name .. ".Filter", "Filter", instance.parameters.Neutral1, first);
    Out["Filter"]:setPrecision(math.max(2, instance.source:getPrecision()));
		 Out["Filter"]:setWidth(5);
		 
		 
		  Out["Entry"] = instance:addStream("Entry", core.Line, name .. ".Entry", "Entry", instance.parameters.Color, first);
    Out["Entry"]:setPrecision(math.max(2, instance.source:getPrecision()));
		  Out["Entry"]:setWidth(instance.parameters.width);
          Out["Entry"]:setStyle(instance.parameters.style);
	 
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

    Out["Filter"][period]=0;
	
    if period < first or not  source:hasData(period) then
	return;
	end
	 
		Indicator["Trend"]:update(mode);		
		Indicator["Entry"]:update(mode);
		Indicator["Filter"]:update(mode);	
		
		
		if source.close[period] > Indicator["Filter"].DATA[period]  then
		Out["Filter"]:setColor(period, instance.parameters.Pozitiv1 );
		elseif source.close[period] < Indicator["Filter"].DATA[period]  then
		 Out["Filter"]:setColor(period, instance.parameters.Negativ1 ); 
		else
		 Out["Filter"]:setColor(period, instance.parameters.Neutral1 );
		end
     
	 	
		
		
		 Out["Trend"][period] = Indicator["Trend"].DATA[period];
	
		
		if   TEST(true, period)  then
		 	Out["Trend"]:setColor(period, instance.parameters.Pozitiv );
		elseif   TEST(false, period)  then
		     Out["Trend"]:setColor(period, instance.parameters.Negativ ); 
		else 
		    
				 Out["Trend"]:setColor(period, instance.parameters.Neutral );
					
        end  	

		
		 Out["Entry"][period] = Indicator["Entry"].DATA[period];
	
		
		
end


function TEST (Flag, period)

local FLAG = true;

  if NP <= 0 then
  FLAG = false;
  end


local i;

	
	
	
		if Flag then	
		
		    for i = period, period- NP, -1 do
			    if Out["Trend"][i] < 0 then
				    FLAG = false;
				end				
			end
			
		
		else
		      for i = period, period- NP, -1 do
			    if Out["Trend"][i] > 0 then
				    FLAG = false;
				end
				
			  end
			
		end
		
		
		
		     		       return FLAG;
		
end


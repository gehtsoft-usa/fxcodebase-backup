-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=68707


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
    indicator:name("MACD Helper");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
	
	indicator.parameters:addString("Method", "Method", "Method" , "MACD/SIGNAL");
    indicator.parameters:addStringAlternative("Method", "MACD/ZERO", "MACD/ZERO" , "MACD/ZERO");
    indicator.parameters:addStringAlternative("Method", "MACD/SIGNAL", "MACD/SIGNAL" , "MACD/SIGNAL");

	
    indicator.parameters:addInteger("P1", "Short Period", "Period", 12);
	indicator.parameters:addInteger("P2", "Long Period", "Period", 26);
	indicator.parameters:addInteger("P3", "Signal Period", "Period", 9);
 
	
	indicator.parameters:addBoolean("SH", "Show Horizontal Line", "", true);
	indicator.parameters:addBoolean("SV", "Show Vertical Line", "", true);
	indicator.parameters:addBoolean("Historical", "Historical", "", true);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up_color", "Color of Up", "Color", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down_color", "Color of Down", "Color", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local P1, P2, P3,Method;

local first;
local source = nil;
local Historical; 
-- Streams block
local MACD 
 
local SH,SV;
-- Routine
function Prepare(nameOnly)
    P1 = instance.parameters.P1;
	P2 = instance.parameters.P2;
	P3 = instance.parameters.P3;
	Method= instance.parameters.Method;
	Historical= instance.parameters.Historical;
	
	SH= instance.parameters.SH;
	SV= instance.parameters.SV;
    source = instance.source;
   
	
	 

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Method) .. ", " ..  tostring(P1) .. ", " .. tostring(P2) .. ", " .. tostring(P3).. ")";
    instance:name(name);

    if   (nameOnly) then
        return;
    end
	
       
		MACD = core.indicators:create("MACD", source, P1,P2,P3);
        first = MACD.DATA:first();		
 		
		instance:ownerDrawn(true);

	 
    
end

local init = false;
 
function Draw(stage, context)
    if stage ~= 2  then
	return;
	end
	
        if not init then
            context:createPen (1	, context:convertPenStyle (instance.parameters.style), instance.parameters.width,  instance.parameters.Up_color);
			context:createPen (2    , context:convertPenStyle (instance.parameters.style), instance.parameters.width, instance.parameters.Down_color);
            init = true;
        end

		local  HistoricalCount=0;
		
		
		if Historical then
		FirstPeriod=  source:size()-1;
		else		
		FirstPeriod=math.min(context:lastBar (), source:size()-1);
		end
		
		for period= FirstPeriod, math.max(context:firstBar () ,MACD.HISTOGRAM:first()),  -1 do
		
		  
		
		    if Method== "MACD/SIGNAL" then
			
			
			
			
			
					if MACD.MACD[period]> MACD.SIGNAL[period] 
					and MACD.MACD[period-1]<= MACD.SIGNAL[period-1]
					then
						if SV then
						x, x1, x2 = context:positionOfBar (period);
						context:drawLine (1, x, context:top (), x, context:bottom ());
						end
						
						if SH then
						x, x1, x2 = context:positionOfBar (period);
						visible, y = context:pointOfPrice (source[period] );
						context:drawLine (1, x, y, context:right (), y);
						end
						
						HistoricalCount=HistoricalCount+1;
					
					elseif MACD.MACD[period]< MACD.SIGNAL[period]
					and MACD.MACD[period-1]>= MACD.SIGNAL[period-1]
					then
						if SV then
						x, x1, x2 = context:positionOfBar (period);			
						context:drawLine (2, x, context:top (), x, context:bottom ());
						end
						
						if SH then
						x, x1, x2 = context:positionOfBar (period);
						visible, y = context:pointOfPrice (source[period] );
						context:drawLine (2, x, y, context:right (), y);
						end
						
						HistoricalCount=HistoricalCount+1;
					end
					
			elseif Method== "MACD/ZERO" then
			
			
			
			
			
					if MACD.MACD[period]> 0 
					and MACD.MACD[period-1]<= 0
					then
						if SV then
						x, x1, x2 = context:positionOfBar (period);
						context:drawLine (1, x, context:top (), x, context:bottom ());
						end
						
						if SH then
						x, x1, x2 = context:positionOfBar (period);
						visible, y = context:pointOfPrice (source[period] );
						context:drawLine (1, x, y, context:right (), y);
						end
						
						HistoricalCount=HistoricalCount+1;
					
					elseif MACD.MACD[period]< 0
					and MACD.MACD[period-1]>= 0
					then
						if SV then
						x, x1, x2 = context:positionOfBar (period);			
						context:drawLine (2, x, context:top (), x, context:bottom ());
						end
						
						if SH then
						x, x1, x2 = context:positionOfBar (period);
						visible, y = context:pointOfPrice (source[period] );
						context:drawLine (2, x, y, context:right (), y);
						end
						
						HistoricalCount=HistoricalCount+1;
					end
					
					
					
					
					
			
			end		

                     if Historical and HistoricalCount>=2 then
					 break;
		             end			

       end		
end		

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)

    if period < first or not source:hasData(period) then
	return;
	end  
	 
  
 
		
		MACD:update(mode); 
    
end 
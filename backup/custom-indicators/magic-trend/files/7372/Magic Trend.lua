
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3144

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
    indicator:name("Magic Trend");
    indicator:description("Magic Trend");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	  indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("CCIF", "CCI period", "", 50, 2, 2000);
    indicator.parameters:addInteger("ATRF", "ATR Period", "", 5, 2, 2000);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("MT_UP", "Color of Rising Magic Trend Line", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("MT_DN", "Color of Falling Magic Trend Line", "", core.rgb(255, 0, 0)); 
	
	indicator.parameters:addInteger("width", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local CCIF;
local ATRF;

local first;
local source = nil;

-- Streams block
local MT = nil;

local ATR;
local CCI;
local Last;
-- Routine
function Prepare(nameOnly) 
    CCIF = instance.parameters.CCIF;
    ATRF = instance.parameters.ATRF;
    source = instance.source;
    
	local name = profile:id() .. "(" .. source:name() .. ", " .. CCIF .. ", " .. ATRF .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	ATR = core.indicators:create("ATR", source,  ATRF );
	CCI = core.indicators:create("CCI", source,  CCIF );
	
	first = math.max(source:first(), ATR.DATA:first(),CCI.DATA:first() )+1;

    
    MT = instance:addStream("MT", core.Line, name, "MT", instance.parameters.MT_UP, first);
	MT:setWidth(instance.parameters.width);
    MT:setStyle(instance.parameters.style);
	
	Last= instance:addInternalStream(0, 0);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    ATR:update(mode);
	CCI:update(mode);
	
    if period< first or not  source:hasData(period) then
	return;
	end
	
	ATR:update(mode);
	CCI:update(mode);
 
	
	
	        if MT[period-1] == 0 then
			
					if CCI.DATA[period-1] > 0 then
						MT[period-1] =  source.low[period-1]- ATR.DATA[period-1] ; 
					else
						MT[period-1] =source.high[period-1]+ ATR.DATA[period-1] ; 
					end	
            
            end			

			if CCI.DATA[period] > 0 then
			    MT[period] = math.max(MT[period-1], source.low[period]- ATR.DATA[period] ); 
			else
			    MT[period] = math.min(MT[period-1], source.high[period]+ ATR.DATA[period] ); 
			end	
			
			    
			 if MT[period] >  MT[period-1] then			
			 Last[period]=1;			 
			 elseif MT[period] <  MT[period-1] then			 
			 Last[period]=-1;		
             else
             Last[period]=Last[period-1];			 
			 end
			 
      if  Last[period]== 1 then 
      MT:setColor(period, instance.parameters.MT_UP);
	  elseif  Last[period]== -1 then
	  MT:setColor(period, instance.parameters.MT_DN);
	  end
    
    
end


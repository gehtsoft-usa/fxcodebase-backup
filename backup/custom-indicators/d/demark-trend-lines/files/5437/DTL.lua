-- Available @ http://fxcodebase.com/code/viewtopic.php?f=17&t=2483&hilit=TD_Lines&start=50


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
    indicator:name("Demark Trend Lines");
    indicator:description("Demark Trend Lines");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

     indicator.parameters:addInteger("Length", "Length", "The minimum number of periods used to mark wave.", 30, 10, 200);
    indicator.parameters:addColor("Up_color", "Color of Up", "Color of Up", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Down_color", "Color of Down", "Color of Down", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Length;

local first;
local source = nil;

-- Streams block
local Up = nil;
local Down = nil;
local ATL;
local MaxUp, MaxDown;
local timer;

-- Routine
function Prepare(nameOnly)
    Length = instance.parameters.Length;
    source = instance.source;
    first = source:first();
	
	assert(core.indicators:findIndicator("ATL") ~= nil, "Please, download and install ATL.LUA indicator");
	
	ATL = core.indicators:create("ATL", source,Length);
	Up=instance:addInternalStream(0, 0);
	Down=instance:addInternalStream(0, 0);	

    local name = profile:id() .. "(" .. source:name() .. ", " .. Length .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
	 timer = core.host:execute("setTimer", 1, 60);
    
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
local i;
local PriceUp, PeriodUp, PriceDown, PeriodDown;
function Update(period)
    if period >= first and source:hasData(period) then
	ATL:update(core.UpdateAll );
	    
		if ATL.UTL:hasData(period) then
        Up[period] = ATL.UTL[period];
		end		
		if ATL.DTL:hasData(period) then
        Down[period] = ATL.DTL[period];	
		end
		
		PriceUp=0;
		PeriodUp=0;
		PriceDown=0;
		PeriodDown=0;
		MaxUp= 0;
		MaxDown= 0
		
		    if period  == source:size() -1 then
				for i= period-1 , first , -1 do
                     
                    MAX(i,"Up");		
					
 					if Up[i] == 0 then 
					core.host:execute("drawLine", 1, source:date(i+1), Up[i+1], source:date(period), Up[period],instance.parameters.Up_color);
					core.host:execute("drawLine", 3, source:date(PeriodUp), PriceUp -MaxUp, source:date(period), PriceUp-MaxUp, core.rgb(255, 128, 128));
					end	
                   
					if Up[i]== 0 then
					break;
					end
				end			
                for i= period-1 , first , -1 do
                     
                    MAX(i,"Down");		
					
 					if Down[i] == 0 then 
					core.host:execute("drawLine", 2, source:date(i+1), Down[i+1], source:date(period), Down[period], instance.parameters.Down_color);
					core.host:execute("drawLine", 4, source:date(PeriodDown), PriceDown +MaxDown , source:date(period), PriceDown + MaxDown, core.rgb(128, 255, 128));
					end		
					if Down[i] == 0 then
					break;
					end
				end								
			end 
    end
end

function MAX (p,mode)
	 if   mode == "Up" then 
		if Up[p] ~= nil and Up[p]~=0 then 
			if Up[p] < source.close[p] then
				if MaxUp==0 then 
				MaxUp = source.high[p] - Up[p] ;				
				end
				if MaxUp < source.high[p] - Up[p] then
				MaxUp = source.high[p] - Up[p];				
				end
			else	
			
			PriceUp=Up[p];
			PeriodUp=p;	
			end
		end
	 else    
		if Down[p] ~= nil and Down[p]~=0 then  
			if Down[p] > source.close[p] then
			
			    if MaxDown==0 then 
				MaxDown = Down[p]- source.low[p] ;				
				end 
			
				if MaxDown < Down[p]- source.low[p] then
				MaxDown = Down[p]- source.low[p] ;				
				end		
			else
			PriceDown=Down[p];
			PeriodDown=p;
			end
		end
	  end
end

function AsyncOperationFinished(cookie, success, message)

 return core.ASYNC_REDRAW;
end

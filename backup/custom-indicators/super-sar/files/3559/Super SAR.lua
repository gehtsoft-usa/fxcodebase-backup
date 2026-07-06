
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1769

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
    indicator:name("Super SAR Indicator");
    indicator:description("Super SAR Indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addDouble("Step", "Step", "The sensitivity of SAR.", 0.02, 0.001, 1);
    indicator.parameters:addDouble("MAX", "Max", "The maximum value of Step.", 0.2, 0.001, 10);
	
	indicator.parameters:addInteger("STFrame", "Super Trend Number of periods", "Super Trend Number of periods", 8);
    indicator.parameters:addDouble("Multiplier", "Super Trend Multiplier", "Super Trend Multiplier", 1.5);
	
	indicator.parameters:addBoolean("Broader", "Broader definition", "", false);

    indicator.parameters:addColor("UP", "Color of Up Trend", "Color of Up Trend", core.rgb(0, 255, 0));
	indicator.parameters:addColor("DOWN", "Color of Down Trend", "Color of Down Trend", core.rgb(255, 0, 0));
	indicator.parameters:addColor("NEUTRAL", "Color For Neutral", "Color of Neutral", core.rgb(255, 255, 255));
	
	indicator.parameters:addInteger("Size", "Arrow Size", "Size", 20);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;

-- Streams block
local up = nil;
local neutralup = nil;
local neutraldown = nil;
local down = nil;

local STEP=nil;
local MAX=nil;

local STFrame=nil;
local Multiplier=nil;	
local Broader=nil;

local STFlag=nil
local SARFlag=nil;
local FLAG=nil;

local ST=nil;
local SAR=nil;

local Size;
-- Routine
function Prepare(nameOnly) 
    source = instance.source;
   
	
	local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
	STEP=instance.parameters.Step;
	MAX=instance.parameters.MAX;
	
	Size=instance.parameters.Size;
	
    STFrame=instance.parameters.STFrame;
    Multiplier=instance.parameters.Multiplier;
	
	Broader=instance.parameters.Broader;

    assert(core.indicators:findIndicator("SUPERTREND") ~= nil, "Please, download and install SUPERTREND.LUA indicator");    
	
	ST  = core.indicators:create("SUPERTREND", source, STFrame, Multiplier);
	SAR  = core.indicators:create("SAR", source, STEP, MAX);	
	
	 first =math.max(ST.UP:first(),ST.DN:first(),SAR.UP:first(),SAR.DN:first())
	
	if Broader then	
	up = instance:createTextOutput ("UP", "Up", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.UP, 0);	
    down = instance:createTextOutput ("DOWN", "Down", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.DOWN, 0);
	 
	else	
	up = instance:createTextOutput ("UP", "Up", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.UP, 0);	
    down = instance:createTextOutput ("DOWN", "Down", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.DOWN, 0);	
	neutralup = instance:createTextOutput ("Neutral Up", "Neutral Up", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.NEUTRAL, 0);	
	neutraldown = instance:createTextOutput ("Neutral Down", "Neutral Down ", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.NEUTRAL, 0);
	
	
	end
	
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    
	down:setNoData(period);
	up:setNoData(period);
	
	if period < first+1   then
	return;
	end
	
	
				
						if Broader then
						
									SAR:update(mode);
									ST:update(mode);       
								
							      if SAR.DATA[period] < source.close[period]  and  SAR.DATA[period-1] > source.close[period-1]   then							
									SARFlag= true;
								  elseif SAR.DATA[period] > source.close[period]  and  SAR.DATA[period-1] < source.close[period-1]   then
									SARFlag= false;									
								  end	
								  
								 if  ST.UP[period] > 0 then
									STFlag= true;
						    	   elseif ST.DN[period] > 0 then
									STFlag= false;               
							   	end
								
								if SARFlag and STFlag and Flag~="Buy" then
								up:set(period, source.high[period], "\225"); 
								Flag="Buy"
								end
								
								if not SARFlag and  not STFlag and Flag~= "Sell" then
								down:set(period, source.low[period], "\226");
								Flag="Sell";
								end
								
						
						else
						 
								    SAR:update(mode);
								    ST:update(mode);
						
						            if SAR.DATA[period] < source.close[period]  and  SAR.DATA[period-1] > source.close[period-1]   and  ST.UP[period] > 0 then
							
									up:set(period, source.high[period], "\225"); 
									elseif  SAR.DATA[period] < source.close[period]  and  SAR.DATA[period-1] > source.close[period-1] then
									neutralup:set(period, source.high[period], "\225"); 
									
								    elseif SAR.DATA[period] > source.close[period]  and  SAR.DATA[period-1] < source.close[period-1]  and ST.DN[period] > 0 then	
								   
									down:set(period, source.low[period], "\226"); 	
									
									elseif SAR.DATA[period] > source.close[period]  and  SAR.DATA[period-1] < source.close[period-1]  then
									neutraldown:set(period, source.low[period], "\226"); 	
									
								  end	
					end	
						
					
			
 
end

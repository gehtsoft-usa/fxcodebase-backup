-- Id: 7273
--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("PRO GO Divergence");
    indicator:description("PRO GO Divergence");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	indicator.parameters:addGroup("Calculation");	
	indicator.parameters:addInteger("Period", "Pro Go Period", "", 14);	
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UP", "Color of Up Arrow", "Color of Up Arrow", core.rgb(0, 255, 0));
	indicator.parameters:addColor("DOWN", "Color of Down Arrow", "Color of Down Arrow", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Color", "Color of PRO GO", "Color of PRO GO", core.rgb(0, 0, 255));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Short,Long;

local first;
local source = nil;

-- Streams block
local UP = nil;
local DOWN = nil;
local PRO;
local OUT;
local U;
local D;

local UPPREV=nil;
local DOWNPREV=nil;
local PRICEUPPREV=nil;
local PRICEDOWNPREV=nil;

local i=0;

local ChartUP=nil;
local ChartDOWN=nil;
local Period;

-- Routine
function Prepare()
  
    source = instance.source;
    Period = instance.parameters.Period;
	
	Short = instance.parameters.SHORT;
    Long = instance.parameters.LONG;
	
	assert(core.indicators:findIndicator("PG1") ~= nil, "Please, download and install PG1.LUA indicator");
	
	PRO = core.indicators:create("PG1", source, Period);
	first = PRO.DATA:first();
	
	UP= instance:addInternalStream(0, 0);
	DOWN= instance:addInternalStream(0, 0);
		
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	OUT = instance:addStream("PRO", core.Line, name, "PRO GO", instance.parameters.Color, first);
    OUT:setPrecision(math.max(2, instance.source:getPrecision()));
	U = instance:createTextOutput ("Up", "Up", "Wingdings", 20, core.H_Center, core.V_Top, instance.parameters.UP, first);
    D = instance:createTextOutput ("Dn", "Dn", "Wingdings", 20, core.H_Center, core.V_Bottom, instance.parameters.DOWN, first);
    
	ChartUP = instance:addStream("ChartUP", core.Line, name, "UP", instance.parameters.UP, first);
    ChartUP:setPrecision(math.max(2, instance.source:getPrecision()));
	ChartDOWN = instance:addStream("ChartDOWN", core.Line, name, "DOWN", instance.parameters.DOWN, first);
    ChartDOWN:setPrecision(math.max(2, instance.source:getPrecision()));
	
	core.host:execute ("attachOuputToChart", "ChartUP");	
	core.host:execute ("attachOuputToChart", "ChartDOWN");
	
end

local pperiod = nil;
local pperiod1 = nil;

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)

 if period < first then
 DOWNPREV=nil;
 UPPREV=nil;
 PRICEDOWNPREV=nil;
 PRICEUPPREV=nil;
 end

  if pperiod ~= nil and pperiod > period then
        core.host:execute("removeAll");
		
    end
    
    pperiod = period;
    -- process only candles which are already closed closed.
    if pperiod1 ~= nil and pperiod1 == source:serial(period) then
        return ;
    end
    pperiod1 = source:serial(period)
    period = period - 1;


    if period >= first+2 and source:hasData(period) then
	
	--****************************************************************
	
	if  source.high[period-4]<= source.high[period-3] and source.high[period-3] <=source.high[period-2] and source.high[period-2]>= source.high[period-1] and source.high[period-1] >= source.high[period]  then
									
				        if PRICEUPPREV ~=nil and  source.high[PRICEUPPREV] <   source.high[period-2] then						
						core.drawLine(UP, core.range(PRICEUPPREV, period-2), source.high[PRICEUPPREV], PRICEUPPREV, source.high[period-2], period-2);				
									
				       
							local TESTUP = true; 
							local j;
							for j= PRICEUPPREV, period-2, 1 do
								if  source.high[j] > UP[j] then
								TESTUP = false;	
								end
							end
							if TESTUP then
							core.drawLine(ChartUP, core.range(PRICEUPPREV, period-2), source.high[PRICEUPPREV], PRICEUPPREV, source.high[period-2], period-2);
						    end
						end	
				      
					PRICEUPPREV=period-2;	
				 
				end	
				
				
				if  source.low[period-4]>= source.low[period-3] and source.low[period-3] >= source.low[period-2] and source.low[period-2]<= source.low[period-1] and source.low[period-1] <= source.low[period]  then
				
				        if PRICEDOWNPREV ~=nil and  source.low[PRICEDOWNPREV] >  source.low[period-2] then						
						core.drawLine(DOWN, core.range(PRICEDOWNPREV, period-2), source.low[PRICEDOWNPREV], PRICEDOWNPREV, source.low[period-2], period-2);				
						
						
							 local TESTDOWN = true;
							
							for j= PRICEDOWNPREV, period-2,1 do
							
								if  source.low[j] < DOWN[j] then
								TESTDOWN = false;	
								end
							
							end
							if TESTDOWN then
							core.drawLine(ChartDOWN, core.range(PRICEDOWNPREV, period-2), source.low[PRICEDOWNPREV], PRICEDOWNPREV, source.low[period-2], period-2);				
                            end
						end
											
						
				
				PRICEDOWNPREV=period-2;
				end	
	
	--********************************************************************
	           
				PRO:update(mode);
				
				OUT[period]=PRO.DATA[period];
					
				if PRO.DATA[period-2]< PRO.DATA[period-1] and PRO.DATA[period-1] > PRO.DATA[period] then
			
					
						if UPPREV ~=nil and  PRO.DATA[UPPREV] >  PRO.DATA[period-1] then	
						i=i+1;	
						core.host:execute("drawLine", i, source:date(UPPREV), PRO.DATA[UPPREV], source:date(period-1), PRO.DATA[period-1], instance.parameters.UP);
						
						if ChartUP[period-2]  ~= 0  then 
						 U:set(period-2, PRO.DATA[period-2], "\226");
						end
						
						end
						
						
				
				UPPREV=period-1;
				end	
				
				
				
				if PRO.DATA[period-2]> PRO.DATA[period-1] and PRO.DATA[period-1] < PRO.DATA[period] then
		
						if DOWNPREV ~=nil and  PRO.DATA[DOWNPREV] <  PRO.DATA[period-1]then
						i=i+1;
						core.host:execute("drawLine", i, source:date(DOWNPREV), PRO.DATA[DOWNPREV], source:date(period-1), PRO.DATA[period-1], instance.parameters.DOWN);
						
						if ChartDOWN[period-2] ~=0  then 
						 D:set(period-2, PRO.DATA[period-2], "\225");
						end
						
						end
				DOWNPREV=period-1;
				end
				
		
        
    end
end


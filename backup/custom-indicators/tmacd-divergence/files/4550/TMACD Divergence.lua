-- Id: 1671
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2190

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("TMACD Divergence");
    indicator:description("TMACD Divergence");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addInteger("SHORT", "Short TMA", "", 7);
	indicator.parameters:addInteger("LONG", "Long TMA ", "", 14);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UP", "Color of Up Arrow", "Color of Up Arrow", core.rgb(0, 255, 0));
	indicator.parameters:addColor("DOWN", "Color of Down Arrow", "Color of Down Arrow", core.rgb(255, 128, 0));
	indicator.parameters:addColor("TMACD", "Color of TMACD", "Color of TMACD", core.rgb(255, 0, 0));
	 indicator.parameters:addInteger("Size", "Size", "Size", 15);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Short,Long;

local first;
local source = nil;
local PU,PD,OU,OD,PPU,PPD,POU,POD;
local PRICEUPPREV=nil;
local PRICEDOWNPREV=nil;
local UPPREV=nil;
local DOWNPREV=nil;
local RPU,RPD;
local OUT;
local U,D;
local j;
local COUNTUP;
local COUNTDOWN;
local Size;
-- Streams block

-- Routine
function Prepare(nameOnly)
  
    source = instance.source;
    
	
	Short = instance.parameters.SHORT;
    Long = instance.parameters.LONG;
	Size = instance.parameters.Size;
    local name = profile:id() .. "(" .. source:name() .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	
	TMACD = core.indicators:create("TMACD", source.close, Short,Long);
	first = TMACD.DATA:first();
	
	
	PPU= instance:addInternalStream(0, 0);
	PPD= instance:addInternalStream(0, 0);
	
	POU= instance:addInternalStream(0, 0);
	POD= instance:addInternalStream(0, 0);
	
	RPU= instance:addInternalStream(0, 0);
	RPD= instance:addInternalStream(0, 0);
	
	COUNTUP= instance:addInternalStream(0, 0);
	COUNTDOWN= instance:addInternalStream(0, 0);
		
	
	OUT = instance:addStream("TMACD", core.Bar, name, "TMACD", instance.parameters.TMACD, first);
    OUT:setPrecision(math.max(2, instance.source:getPrecision()));
	U = instance:createTextOutput ("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.UP, first);
    D = instance:createTextOutput ("Dn", "Dn", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.DOWN, first);
    
	PU = instance:addStream("ChartUP", core.Line, name, "UP", instance.parameters.UP, first);
    PU:setPrecision(math.max(2, instance.source:getPrecision()));
	PD = instance:addStream("ChartDOWN", core.Line, name, "DOWN", instance.parameters.DOWN, first);
    PD:setPrecision(math.max(2, instance.source:getPrecision()));
	OU = instance:addStream("OSUP", core.Line, name, "UP", instance.parameters.UP, first);
    OU:setPrecision(math.max(2, instance.source:getPrecision()));
	OD = instance:addStream("OSDOWN", core.Line, name, "DOWN", instance.parameters.DOWN, first);
    OD:setPrecision(math.max(2, instance.source:getPrecision()));
	
	core.host:execute ("attachOuputToChart", "ChartUP");	
	core.host:execute ("attachOuputToChart", "ChartDOWN");
	
end

local pperiod = nil;
local pperiod1 = nil;

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)



 if period < first then
 PRICEUPPREV=1;
 PRICEDOWNPREV=1;
 UPPREV=1;
 DOWNPREV=1;
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
	
	
	
	            local curr = source.high[period - 2];
            if (curr > source.high[period - 4] and curr > source.high[period - 3] and  curr > source.high[period - 1] and curr > source.high[period]) then
			
				        if  source.high[PRICEUPPREV] <   source.high[period-2] then						
															
				                    core.drawLine(RPU, core.range(PRICEUPPREV, period-2), source.high[PRICEUPPREV], PRICEUPPREV, source.high[period-2], period-2);
									local TESTUP = true; 
									
									for j= PRICEUPPREV, period-2, 1 do
										if  source.high[j] > RPU[j] then
										TESTUP = false;	
										end
									end
									if TESTUP then
									core.drawLine(PU, core.range(PRICEUPPREV, period-2), source.high[PRICEUPPREV], PRICEUPPREV, source.high[period-2], period-2);
									core.drawLine(COUNTUP, core.range(PRICEUPPREV, period-2), 1, PRICEUPPREV, 1, period-2);
									 PPU[period-2] = period-2- PRICEUPPREV; 
									end
							 
						end	
						
					    PRICEUPPREV=period-2;	
				  
				 
				end	
				
		
				
				
				curr = source.low[period - 2];
        if (curr < source.low[period - 4] and curr < source.low[period - 3] and curr < source.low[period - 1] and curr < source.low[period]) then
				        if   source.low[PRICEDOWNPREV] >  source.low[period-2] then						
						             
									 core.drawLine(RPD, core.range(PRICEDOWNPREV, period-2), source.low[PRICEDOWNPREV], PRICEDOWNPREV, source.low[period-2], period-2);	
									 local TESTDOWN = true;
									
									for j= PRICEDOWNPREV, period-2,1 do
									
										if  source.low[j] < RPD[j] then
										TESTDOWN = false;	
										end
									
									end
									if TESTDOWN then
									core.drawLine(PD, core.range(PRICEDOWNPREV, period-2), source.low[PRICEDOWNPREV], PRICEDOWNPREV, source.low[period-2], period-2);	
                                    core.drawLine(COUNTDOWN, core.range(PRICEDOWNPREV, period-2), 1, PRICEDOWNPREV, 1, period-2);									
									PPD[period-2] = period-2-PRICEDOWNPREV; 
									end
							
							end
											
							
				            PRICEDOWNPREV=period-2;
				
				end	
				
		
	           
				TMACD:update(mode);
				
				OUT[period]=TMACD.DATA[period];
					
				 curr = TMACD.DATA[period - 2];
                 if (curr > TMACD.DATA[period - 4] and curr > TMACD.DATA[period - 3] and  curr > TMACD.DATA[period - 1] and curr > TMACD.DATA[period])  and  TMACD.DATA[period - 2] > 0 then
					
						if  TMACD.DATA[UPPREV] >  TMACD.DATA[period-1] then	
						
						core.drawLine(OU, core.range(UPPREV, period-2), TMACD.DATA[UPPREV], UPPREV,  TMACD.DATA[period-2], period-2);
						
						POU[period-2]=period-2-UPPREV; 
						 
						end
						
				 UPPREV=period-2;	
				  
				
				end	
				
	        --	PU[period]=PU[period-1];
		
				
				curr = TMACD.DATA[period - 2];
                 if (curr < TMACD.DATA[period - 4] and curr < TMACD.DATA[period - 3] and  curr < TMACD.DATA[period - 1] and curr < TMACD.DATA[period])  and  TMACD.DATA[period - 2] < 0 then
		
						if   TMACD.DATA[DOWNPREV] <  TMACD.DATA[period-1]then
						
						core.drawLine(OD, core.range(DOWNPREV, period-2), TMACD.DATA[DOWNPREV], DOWNPREV,  TMACD.DATA[period-2], period-2);		
						
						POD[period-2]=period-2-DOWNPREV; 							
						end
						
							
				    DOWNPREV=period-2;	
			
				end
		 
				 
				 
    end
	if period == source:size()-2 then
	
			for j=1, period, 1 do
			
			    if   core.sum(COUNTUP,core.range(j-POU[j],j))  > 0 and POU[j]~=0 then
						U:set(j, TMACD.DATA[j], "\226");	
						end		
					
					
					if core.sum(COUNTDOWN,core.range(j-POD[j],j))  > 0  and POD[j]~=0  then
						D:set(j, TMACD.DATA[j], "\225");
					end	
			
			end
			
	end
	
end


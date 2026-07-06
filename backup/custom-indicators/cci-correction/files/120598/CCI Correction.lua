-- Id: 22022
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66528

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
    indicator:name("CCI Correction");
    indicator:description("CCI Correction");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addInteger("L", "L", "", 130);
	indicator.parameters:addInteger("B", "B", "", 26);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color1", "Long Color", "Color", core.rgb(0,255, 0));
	indicator.parameters:addColor("color2", "Short Color", "Color", core.rgb(255,0, 0));
	indicator.parameters:addColor("color3", "Up Color", "Color", core.rgb(128,128,128));
	indicator.parameters:addColor("color4", "Down Color", "Color", core.rgb(128,128,128));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local L,B;

local first;
local source = nil;

-- Streams block
local CCL,CCS = nil;
local LASTUP,LASTDW, UP, DW,BLASTUP,BLASTDW; 
-- Routine
function Prepare(nameOnly)  
    
    source = instance.source;
   
		
	 
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	L=instance.parameters.L;
	B=instance.parameters.B;
	
	
	 first = source:first()+math.max(L,B);
	
	LASTUP= instance:addStream("LASTUP", core.Bar, name, "LASTUP", instance.parameters.color1, first);
	LASTDW= instance:addStream("LASTDW", core.Bar, name, "LASTDW", instance.parameters.color2, first);
    LASTDW:setPrecision(math.max(2, instance.source:getPrecision()));
	UP = instance:addStream("UP", core.Bar, name, "UP", instance.parameters.color3, first);
	DW = instance:addStream("DW", core.Bar, name, "DW", instance.parameters.color4, first);
	BLASTUP = instance:addInternalStream(0, 0);
	BLASTDW = instance:addInternalStream(0, 0);
	
	
	LASTUP:setPrecision(math.max(2, instance.source:getPrecision()));
	Close:setPrecision(math.max(2, instance.source:getPrecision()));
	UP:setPrecision(math.max(2, instance.source:getPrecision()));
	DW:setPrecision(math.max(2, instance.source:getPrecision()));
	
	
	
	
	CCL = core.indicators:create("CCI", source, L);
	CCS = core.indicators:create("CCI", source, B);
 
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    
	
	
	 CCL:update(mode);
	 CCS:update(mode);
	 
	 if period < first then
	return;
	end

	
		if CCL.DATA[period] > 100 then
		LASTUP[period] = 1
		LASTDW[period] = 0
		UP[period] = 0
		DW[period] = 0
		end

		if CCL.DATA[period] < -100 then
		LASTDW[period] = -1
		LASTUP[period] = 0
		UP[period] = 0
		DW[period] = 0
		end
		
		
		if  CCS.DATA[period] > 100 then
		BLASTUP[period] = 1
		BLASTDW[period] = 0
		UP[period] = 0
		end
		if CCS.DATA[period] < -100 then
		BLASTDW[period] = -1
		BLASTUP[period] = 0
		DW[period] = 0
		end
		
		
		
		if  LASTUP[period] == 1 and BLASTDW[period-1] == -1 then
				if CCS.DATA[period-1]<0 and CCS.DATA[period]>0 then
				UP[period] = 1
				DW[period] = 0
				else
				UP[period] = 0
				DW[period] = 0
				end
		end

		if LASTDW[period] == -1 and BLASTUP[period-1] == 1 then
			if CCS.DATA[period-1]>0 and CCS.DATA[period]<0 then
			DW[period] = -1
			UP[period] = 0
			else
			DW[period] = 0
			UP[period] = 0
			end
		end
    
end

 


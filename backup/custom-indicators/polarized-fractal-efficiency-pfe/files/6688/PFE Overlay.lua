-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2921


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
    indicator:name("Polarized Fractal Efficiency Indicator");
    indicator:description("Polarized Fractal Efficiency Indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	
	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("ROCLong", "ROC Long Period", "", 9);
    indicator.parameters:addInteger("ROCShort", "ROC Short Period", "", 1);
	indicator.parameters:addInteger("AVERAGEPeriod", "Average Period", "", 5);
	indicator.parameters:addInteger("PDS", "PDS", "", 10);
	
	
	indicator.parameters:addGroup("Price Overlay");
	 indicator.parameters:addInteger("N", "Average Period", "", 20, 1, 10000);
    indicator.parameters:addDouble("Dev", "Number of Standard Deviations", "", 2.0, 0.0001, 1000.0);
	 indicator.parameters:addBoolean("Show", "Show Deviation Bands", "", false);
	
	
    indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("PFE_color", "Color of S1", "Color of S1", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local ROCLongPeriod;
local ROCLongPeriod;
local AVERAGEPeriod;
local PDS;
local Show;

local first;
local source = nil;

-- Streams block
local ROCShort = nil;
local ROCLong = nil;
local PFE;
local Buffer;
local AVERAGE;
local N;
local D;
local Scale;
local FIRST;
-- Routine
function Prepare(nameOnly)
    Show = instance.parameters.Show;
     N = instance.parameters.N;
    D = instance.parameters.Dev;
    PDS= instance.parameters.PDS;
    AVERAGEPeriod = instance.parameters.AVERAGEPeriod;
    ROCLongPeriod = instance.parameters.ROCLong;
	 ROCShortPeriod = instance.parameters.ROCShort;
    source = instance.source;
    first =  source:first() + N - 1;
	
	 local name = profile:id() .. "(" .. source:name() .. ", " .. ROCShortPeriod.. ", "..  ROCLongPeriod ..", ".. AVERAGEPeriod .. ", "..  PDS ..  ")";
	instance:name(name);
	if   (nameOnly) then
        return;
    end
	
	Buffer= instance:addInternalStream (first, 0);
	
	if  Show then
	TL = instance:addStream("TL", core.Line, name, "TL", instance.parameters.PFE_color, first);
	BL = instance:addStream("BL", core.Line, name, "BL", instance.parameters.PFE_color, first);
	else
	TL= instance:addInternalStream (first, 0);
	BL= instance:addInternalStream (first, 0);
	end
	
	 ROCShort= core.indicators:create("ROC", source.close,  ROCShortPeriod);
	 ROCLong= core.indicators:create("ROC", source.close, ROCLongPeriod);
	 
	FIRST = math.max(ROCShort.DATA:first(),ROCLong.DATA:first())
	  
	 AVERAGE= core.indicators:create("EMA", Buffer, AVERAGEPeriod);

 
    
    PFE = instance:addStream("PFE", core.Line, name, "PFE", instance.parameters.PFE_color,  AVERAGE.DATA:first() );
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period >= first and source:hasData(period) then

		
		local ml = core.avg(source.close, core.range(period - N + 1, period));
        local d = core.stdev(source.close,  core.range( period - N + 1, period));
        local Dd = D * d;
        TL[period] = ml + Dd;
        BL[period] = ml - Dd;
		
		Scale = 200/((TL[period])- BL[period]);
		
		 
		
		
			ROCShort:update(mode);	
			ROCLong:update(mode);
			
			if period < FIRST then 
            return;
            end			
			
		--x=sqrt((ROC(C,9)*ROC(C,9))+100);
		local x=math.sqrt((ROCLong.DATA[period]*ROCLong.DATA[period])+100);
		
		--y=Sum(sqrt((ROC(C,1)* ROC(C,1))+1),pds);
		local y = math.sqrt((ROCShort.DATA[period]* ROCShort.DATA[period])+1)+PDS;

		local z=(x/y);
		
		
		--pfe=EMA(IIf(C>Ref(C,-9),z,-z)*100,5);
		
		if source.close[period] >  source.close[period-ROCLongPeriod] then
		Buffer[period]= z*100;
		else
		Buffer[period]= -z*100;
		end
		
		AVERAGE:update(mode);	
		
		if period<  AVERAGE.DATA:first() then
		return;
		end
		 
		PFE[period]= BL[period] + ((100+AVERAGE.DATA[period])/Scale); 
		
		 
		
		

    end
end


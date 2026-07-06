-- Id: 2601
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
    indicator:type(core.Oscillator);
	
	
	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("ROCLong", "ROC Long Period", "", 9);
    indicator.parameters:addInteger("ROCShort", "ROC Short Period", "", 1);
	indicator.parameters:addInteger("AVERAGEPeriod", "Average Period", "", 5);
	indicator.parameters:addInteger("PDS", "PDS", "", 10);
	
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

local first;
local source = nil;

-- Streams block
local ROCShort = nil;
local ROCLong = nil;
local PFE;
local Buffer;
local AVERAGE;


-- Routine
function Prepare(nameOnly)
    PDS= instance.parameters.PDS;
    AVERAGEPeriod = instance.parameters.AVERAGEPeriod;
    ROCLongPeriod = instance.parameters.ROCLong;
	 ROCShortPeriod = instance.parameters.ROCShort;
    source = instance.source;
    
	local name = profile:id() .. "(" .. source:name() .. ", " .. ROCShortPeriod.. ", "..  ROCLongPeriod ..", ".. AVERAGEPeriod .. ", "..  PDS ..  ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	Buffer= instance:addInternalStream (0, extent)
	
	 ROCShort= core.indicators:create("ROC", source.close,  ROCShortPeriod);
	 ROCLong= core.indicators:create("ROC", source.close, ROCLongPeriod);
	 
	 first = math.max(ROCShort.DATA:first(),ROCLong.DATA:first())
	 AVERAGE= core.indicators:create("EMA", Buffer, AVERAGEPeriod);

    
    PFE = instance:addStream("PFE", core.Line, name, "PFE", instance.parameters.PFE_color, AVERAGE.DATA:first());
	PFE:setPrecision(math.max(2, instance.source:getPrecision()));
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
 
        --VarA := ROC(pr, length, percent);
		--VarB := ROC(pr, length, percent);
		--VarB := if(VarB=0, 1, VarB);
		--VarC := if( Close >= ref(Close,neg(length)), VarA/VarB, neg(VarA)/VarB );
		--VarC := (VarC*100)/2+50;
		--polarized := mov(VarC,smooth,e);
		
		--pds=10; 
		
			ROCShort:update(mode);	
			ROCLong:update(mode);
			
			   if period < first   then
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
		
		 if period < AVERAGE.DATA:first() then
		 return;
		 end
		 
		 
		PFE[period]= AVERAGE.DATA[period]; 
		
		--Mov(If(C,>,Ref(C,-9),Sqr(Pwr(Roc(C,9,$),2) + Pwr(10,2)) /
		--Sum(Sqr(Pwr(Roc(C,1,$),2)+1),9),-
		--Sqr(Pwr(Roc(C,9,$),2) + Pwr(10,2)) /
		--Sum(Sqr(Pwr(Roc(C,1,$),2)+1),9))*100,5,E)
 
end


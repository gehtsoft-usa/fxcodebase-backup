-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71146

--+------------------------------------------------------------------+
--|                               Copyright © 2021, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--|                           https://AppliedMachineLearning.systems |
--|                                Patreon :  https://goo.gl/GdXWeN  |
--+------------------------------------------------------------------+
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   Dogecoin : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

-- Indicator profile initialization routine

function Init()
    indicator:name("Trend Persistence Rate");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("TPRPer", "TPR Period", "", 20, 1, 2000);
    indicator.parameters:addInteger("SMAPer", "SMA Period", "", 5, 1, 2000); 
	indicator.parameters:addDouble("Threshold", "Threshold", "", 1); 
    indicator.parameters:addInteger("MULT", "Multiplier", "", 10); 
	 indicator.parameters:addInteger("offset", "offset", "", 0); 

	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
   
local TPRPer, SMAPer, Threshold,MULT,offset;
local first;
local source = nil;
local ctrM, ctrP;
local Oscillator;  
local sma;
-- Routine
 function Prepare(nameOnly)   
 
 
    TPRPer= instance.parameters.TPRPer;
    SMAPer= instance.parameters.SMAPer;
	Threshold= instance.parameters.Threshold;
	MULT= instance.parameters.MULT;
	offset= instance.parameters.offset;
	
	
	local Parameters= TPRPer..", "..SMAPer..", "..Threshold..", "..MULT..", "..offset;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source; 
    first=source:first() +SMAPer;
	
	ctrP= instance:addInternalStream(0, 0);
	ctrM= instance:addInternalStream(0, 0);   
	sma=core.indicators:create("MVA", source, SMAPer);

 
	Oscillator = instance:addStream("Oscillator" , core.Line, " Oscillator"," Oscillator",instance.parameters.color, first + TPRPer+offset);
	Oscillator:setWidth(instance.parameters.width);
    Oscillator:setStyle(instance.parameters.style);
    Oscillator:setPrecision(math.max(2, source:getPrecision()));
	
	
end

-- Indicator calculation routine
function Update(period, mode)

    
	sma:update(mode);
 
	
	if period < first+offset
	then
	return;
	end
	 
	 
	 
	local smadiff = (sma.DATA[period-offset]-sma.DATA[period-offset-1])/(MULT*source:pipSize());
 
 
	if(smadiff> Threshold)  then 
	ctrP[period]= 1;
	else ctrP[period]= 0 
	end
	
	if(smadiff< -Threshold) then
	ctrM[period]= 1;
	else  
	ctrM[period]= 0
	end
	
	
	if period < first+  offset + TPRPer 
	then
	return;
	end
	
	
	local SumP=mathex.sum(ctrP, period -TPRPer+1,period);
	local SumM=mathex.sum(ctrM, period -TPRPer+1 ,period );
		
    Oscillator[period]=math.abs(100*(SumP-SumM)/TPRPer);
			  
end
 
 --[[
 
 //+------------------------------------------------------------------+
//| Trend Persistence Rate |
//+------------------------------------------------------------------+
double GetTPR(int joff)
{
//+------------------------------------------------------------+
// Inputs:
// joff = bar offset
// Externals:
// input int TPRPer = 20; // TPR Period
// input int SMAPer = 5; // SMA Period for TPR
// input double ThrshFixed = 1.0; // Threshold
// Globals:
// MULT = 10; _point
// Outputs:
// Trend Persistence Rate (0-100)
//+-------------------------------------------------------------+
double tpr,sma1,sma2,smadiff,thrs;
int jj,ctrT,ctrP,ctrM;
ctrT = 0;
ctrP = 0;
ctrM = 0;
for (jj=0;jj<TPRPer;jj++)
{
sma1 = iMA(_symbol,0,SMAPer,0,MODE_SMA,PRICE_
CLOSE,jj+1+joff);
sma2 = iMA(_symbol,0,SMAPer,0,MODE_SMA,PRICE_
CLOSE,jj+2+joff);
smadiff = (sma1-sma2)/(MULT*_point);
ctrT +=1;
thrs = ThrshFixed;
if(smadiff> thrs) ctrP += 1; // up trend counter
if(smadiff< -thrs) ctrM += 1; // down trend counter
}
tpr = MathAbs(100.*(ctrP-ctrM)/ctrT);
return(tpr);
}
 
 ]]
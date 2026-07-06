-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72016

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                              Support our efforts by donating   | 
--|                                                                 Paypal: https://goo.gl/9Rj74e  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+

--Your donations will allow the service to continue onward.
--+------------------------------------------------------------------------------------------------+
--|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
--|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
--|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
--|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
--|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
--|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
--+------------------------------------------------------------------------------------------------+



-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("myCandel Infos");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period1", "1. Period", "", 10, 1, 2000);
    indicator.parameters:addInteger("Period2", "2. Period", "", 20, 1, 2000);
	
	indicator.parameters:addGroup("Arrow Style");	
	indicator.parameters:addInteger("Size", "Arrow Size", "", 20); 
    indicator.parameters:addColor("clrUP", "Up Arrow", "" ,  core.COLOR_UPCANDLE);
    indicator.parameters:addColor("clrDN",  "Down Arrow", "" , core.COLOR_DOWNCANDLE);	

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Period1, Period2; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	Period1=instance.parameters.Period1;
	Period2=instance.parameters.Period2;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Period1.. "," ..  Period2  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	OBV= core.indicators:create("OBV", source  );
	MVA1= core.indicators:create("MVA", OBV.DATA , Period1  );	
	MVA2= core.indicators:create("MVA", OBV.DATA , Period2  );		
	ATR= core.indicators:create("ATR", source , Period1  );	
 
	first=math.max(OBV.DATA:first(),ATR.DATA:first(),  Period2)  ; 
	
	
	BullTrend = instance:addInternalStream(0, 0);
	BearTrend = instance:addInternalStream(0, 0);
    Trend = instance:addInternalStream(0, 0);
	
	EMA= core.indicators:create("EMA", Trend , Period2  );	
 
 
	up = instance:createTextOutput ("Up", "Up", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Top, instance.parameters.clrUP, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Bottom, instance.parameters.clrDN, 0);
end


function Update(period, mode)

    up:setNoData(period);
    down:setNoData(period);	

	OBV:update(mode); 
	ATR:update(mode); 
	
	if period <= first then
	return;	
	end
	
	local min, max=mathex.minmax(source, period-Period2+1, period);
 
 
    local BullTrend = (source.close[period] - min) / ATR.DATA[period];
    local BearTrend = (max - source.close[period]) / ATR.DATA[period];
	
	
	Trend[period]= (BullTrend - BearTrend);
	
	EMA:update(mode); 	
	MVA1:update(mode); 
	MVA2:update(mode); 	
	
	 if period <= EMA.DATA:first() then
	 return;
	 end	
	 
  
   if Trend[period] > EMA.DATA[period] and OBV.DATA[period] > MVA2.DATA[period] and OBV.DATA[period] > MVA1.DATA[period]  then
   up:set(period, source.high[period], "\217", source.high[period]);	
   elseif Trend[period] < EMA.DATA[period] and OBV.DATA[period] < MVA2.DATA[period] and OBV.DATA[period] < MVA1.DATA[period]  then
   down:set(period, source.low[period], "\218", source.low[period]);	 
   end
   
   
  

	
end


 
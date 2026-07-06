-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72184

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
    indicator:name("OnlyLong-Strategy");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period", "CCI Period", "", 21, 1, 2000);
    indicator.parameters:addInteger("Period1", "1. MA Period", "", 1, 1, 2000);
    indicator.parameters:addInteger("Period2", "2. MA Perio", "", 2, 1, 2000);
    indicator.parameters:addInteger("Period3", "3. MA Perio", "", 3, 1, 2000);	
    indicator.parameters:addDouble("ATR_Level", "ATR Triger Level", "", 4, 0, 2000000);	
    indicator.parameters:addDouble("r", "Minimum Triger Level", "", 0.1, 0, 2000000);		
 
	
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
local Period,ATR_Level,r; 
 
	
-- Routine
 function Prepare(nameOnly)   
 
    
	Period=instance.parameters.Period;
	Period1=instance.parameters.Period1;
	Period2=instance.parameters.Period2;
	Period3=instance.parameters.Period3;
	ATR_Level=instance.parameters.ATR_Level;
	r=instance.parameters.r;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Period.. "," ..  Period1.. "," ..  Period2.. "," ..  Period3 .. "," ..   ATR_Level.. "," ..   r .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	EMA1= core.indicators:create("EMA", source.close, Period1);
	EMA2= core.indicators:create("EMA", source.close, Period2);
	CCI= core.indicators:create("CCI", source, Period);	
	ATR= core.indicators:create("ATR", source, 1);		

	
	
	a = instance:addInternalStream(0, 0);
 	b = instance:addInternalStream(0, 0);
	
 	signal = instance:addInternalStream(0, 0);	
	
	EMA3= core.indicators:create("EMA", a, Period3);
	EMA4= core.indicators:create("EMA", b, Period3);	
	
	first=math.max(EMA1.DATA:first(),EMA2.DATA:first(),CCI.DATA:first(), EMA3.DATA:first()) ; 
	
 	up = instance:createTextOutput ("Up", "Up", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Bottom , instance.parameters.clrUP, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Top, instance.parameters.clrDN, 0); 
end


function Update(period, mode)

	a[period] = 100 * (3*source.close[period] - 2*source.low[period] - source.open[period]) / source.close[period]
	b[period] = 100 * (source.open[period] + 2*source.high[period] - 3*source.close[period]) / source.close[period]
	
	

	EMA1:update(mode); 
	EMA2:update(mode); 
	CCI:update(mode);
	ATR:update(mode);
	
	EMA3:update(mode); 
	EMA4:update(mode); 
	
	 if period <= first then
	 return;
	 end
	 
    
 
	if EMA1.DATA[period] >  EMA2.DATA[period] then
	c1=true;
	else
	c1=false;
	end
	
	if CCI.DATA[period] < 95 then
	c2=true;
	else
	c2=false;
	end
	
	if ATR.DATA[period]   > ATR_Level  then
	c3=true;
	else
	c3=false;
	end
	
	

	
    local c4 =EMA3.DATA[period] -  EMA4.DATA[period]; 

	

    up:setNoData(period);
    down:setNoData(period);	
 
 signal[period]=signal[period-1];
 
  if c1 and c2 and c3 then
	  if c4 > r then
	  	  --Sell

				up:set(period, source.low[period], "\217", source.low[period]);	   
				signal[period]=1;
	  end
  end
 


	if c4 < r and signal[period] == 1 then
	  -- Exit Sell
                down:set(period, source.high[period], "\218", source.high[period]);	
				signal[period] = 0;
	end
	
end

 

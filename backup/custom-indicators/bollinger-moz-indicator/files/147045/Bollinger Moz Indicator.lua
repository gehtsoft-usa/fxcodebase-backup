-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72613

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
    indicator:name("Bollinger Moz Indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

  
 	indicator.parameters:addGroup("BB Calculation");	
    indicator.parameters:addInteger("Period", "Period", "", 20, 1, 2000);
    indicator.parameters:addDouble("Deviation", "Deviation", "", 2, 1, 2000);
 
 
	
	indicator.parameters:addGroup("Arrow Style");	
	indicator.parameters:addInteger("Size", "Arrow Size", "", 40); 
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
local Period, Deviation; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	Period=instance.parameters.Period;
	Deviation=instance.parameters.Deviation; 
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Period.. "," ..  Deviation  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	Indicator= core.indicators:create("BB", source.close, Period, Deviation);  
	first= Indicator.DATA:first()   ; 
	
	
	MyBoll1 = instance:addInternalStream(0, 0);
	MyBoll2 = instance:addInternalStream(0, 0);
	MyBoll3 = instance:addInternalStream(0, 0);	
	upBoll = instance:addInternalStream(0, 0);	
	downBoll = instance:addInternalStream(0, 0);	

	up = instance:createTextOutput ("Up", "Up", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Bottom, instance.parameters.clrUP, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", instance.parameters.Size, core.H_Center,  core.V_Top, instance.parameters.clrDN, 0);	
end


function Update(period, mode)

	  Indicator:update(mode); 

	 if period <= first then
	 return;
	 end
	 
    up:setNoData(period);
    down:setNoData(period);		 
	 
	MyBoll1[period] = (source.close[period] - Indicator.BL[period])/(Indicator.TL[period] - Indicator.BL[period])*100
    MyBoll2[period] = (source.high[period] - Indicator.BL[period])/(Indicator.TL[period] - Indicator.BL[period])*100
	MyBoll3[period] = (source.low[period] - Indicator.BL[period])/(Indicator.TL[period] - Indicator.BL[period])*100
 
	
	 if period <= first+2 then
	 return;
	 end
	 
	local X = (MyBoll2[period] + MyBoll2[period-1] + MyBoll2[period-2]) /3
	local Y = (MyBoll3[period] + MyBoll3[period-1] + MyBoll3[period-2]) /3
	
	
	if MyBoll1[period] >= 50 then
		 if  X > 100 then
		 upBoll[period] =1;
		 else
		 upBoll[period] =0;	 
		 end
	 downBoll[period] = 0
	else
	
	   	if Y < 0 then
		downBoll[period] =1;
		else
		downBoll[period] =0;		
		end
	 upBoll[period] = 0 
	end
	 
	 
	local min,max=mathex.minmax(source, period-1, period); 
	
	if upBoll[period-1] > 0 and upBoll[period] == 0 then 
    down:set(period, max, "\218", source.high[period]);		
	end
	 
	if downBoll[period-1] > 0 and downBoll[period] == 0 then 
    up:set(period, min, "\217", source.low[period]);	
	end

	
end

 
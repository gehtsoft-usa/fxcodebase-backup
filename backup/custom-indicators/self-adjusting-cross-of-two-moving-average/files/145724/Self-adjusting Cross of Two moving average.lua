-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72098

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
    indicator:name("Self-adjusting Cross of Two moving average");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

  
 	indicator.parameters:addGroup("Calculation");	
     indicator.parameters:addInteger("Confirmations", "Confirmations", "", 4, 1, 2000);
     indicator.parameters:addInteger("Level1", "1. Confirmation Level", "", 2, 1, 2000);
     indicator.parameters:addInteger("Level2", "2. Confirmation Level", "", 8, 1, 2000);	 
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color1", "1. Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color2", "2. Line Color", "", core.rgb(255, 0, 0)); 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Confirmations, Level1,Level2; 
local Indicator;
local Signal={};	
-- Routine
 function Prepare(nameOnly)   
 
    
	Confirmations=instance.parameters.Confirmations;
	Level1=instance.parameters.Level1;
	Level2=instance.parameters.Level2;	
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Confirmations.. "," ..  Level1.. "," ..  Level2  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	--Indicator= core.indicators:create("AO", source, Period1, Period2);
	first=source:first() +math.max(Level1, Level2); 
	
	
	Signal[1] = instance:addInternalStream(0, 0);
 	Signal[2] = instance:addInternalStream(0, 0);
	
	
    Line1 = instance:addStream("Line1", core.Line, name, "1. Line", instance.parameters.color1, first );
    Line1:setPrecision(math.max(2, instance.source:getPrecision()));
    Line1:setWidth(instance.parameters.width);
    Line1:setStyle(instance.parameters.style);
    Line1:addLevel(0);	
 
    Line2 = instance:addStream("Line2", core.Line, name, "2. Line", instance.parameters.color2, first );
    Line2:setPrecision(math.max(2, instance.source:getPrecision()));
    Line2:setWidth(instance.parameters.width);
    Line2:setStyle(instance.parameters.style);
    Line2:addLevel(0);	 
end


function Update(period, mode)

	period = period-math.max(Level1, Level2); 

	 if period <= first then
	 return;
	 end
	 
 
	local Period1 = PeriodCalculation(period, Level1, 1);	
	local Period2 = PeriodCalculation(period, Level2, 2);		
	
 
	if period >  Period1 then 
	Line1[period]= mathex.avg(source.close, period-Period1+1, period);
	end
	
	if period >  Period2 then 	
	Line2[period]= mathex.avg(source.close, period-Period2+1, period);	
	end
	
	period = period+math.max(Level1, Level2); 
	
	
	if period == source:size()-1 then
	
	 for i=  1, math.max(Level1, Level2),  1 do
    	Line1[period -i+1 ]= mathex.avg(source.close, period -i+1-Period1, period -i+1);
	    Line2[period -i+1]= mathex.avg(source.close, period -i+1- Period2 -i+1, period -i+1);	
     end	 
	
	end
end


function PeriodCalculation(period, Level, Index)	




Signal[Index][period]=0;	


 	    local test=true;
		
       for i= 1, Level, 1 do
		
		     if  source.high[period] < source.high[period+i] or  source.high[period] < source.high[period-i] then
			 test=false;
			 end
			
		 end	
		 
		 if test then
		 Signal[Index][period]=1; 
		 end

        local test=true; 
		
        for i= 1, Level, 1 do
		
		     if  source.low[period] > source.low[period+i] or source.low[period] > source.low[period-i] then
			 test=false;
			 end
			
		 end	
	   
		 if test then
		 Signal[Index][period]=1;
		 end
		 
		 
        local  Return=1;
		
		
        local Count=0;
		for i= period, first, -1 do
			 if Signal[Index][i]==1 then
			 Count=Count+1;			 
			 end
			 
			 if Count==Confirmations then
			 Return=(period-i)/Confirmations;
			 break;
			 end
			 
			 
			 
		end
		return Return;
 
end
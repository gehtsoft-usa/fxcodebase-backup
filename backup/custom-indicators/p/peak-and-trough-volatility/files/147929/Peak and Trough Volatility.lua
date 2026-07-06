-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72844

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+
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
    indicator:name("Peak and Trough Volatility");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period", "Period", "", 50, 1, 2000);	
    indicator.parameters:addInteger("Bars", "Bars Before/After", "", 1, 0, 2000); 
	
 
 
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color1", "1. Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color2", "2. Line Color", "", core.rgb(255, 0, 0)); 
	 indicator.parameters:addColor("color3", "3. Line Color", "", core.rgb(0, 0, 255)); 	 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Bars,Period ; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    Period=instance.parameters.Period;
	Bars=instance.parameters.Bars;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," .. Period .. "," ..  Bars  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	

	first=source:first()+math.max(Period,Bars ) ; 
	
	
	sup = instance:addInternalStream(0, 0);
	res = instance:addInternalStream(0, 0);
    rsup = instance:addInternalStream(0, 0);	
    rres = instance:addInternalStream(0, 0);
    tot = instance:addInternalStream(0, 0);	
    ata = instance:addInternalStream(0, 0);	
	
	MA1= core.indicators:create("WMA", rsup, Period );
	MA2= core.indicators:create("WMA", rres, Period );
	MA3= core.indicators:create("WMA", tot, Period );

	
	
    Line1 = instance:addStream("Line1", core.Line, name, "Peak Volatility", instance.parameters.color1, first+Period  );
    Line1:setPrecision(math.max(2, instance.source:getPrecision()));
    Line1:setWidth(instance.parameters.width);
    Line1:setStyle(instance.parameters.style); 

    Line2 = instance:addStream("Line2", core.Line, name, "Trough Volatility", instance.parameters.color2, first+Period  );
    Line2:setPrecision(math.max(2, instance.source:getPrecision()));
    Line2:setWidth(instance.parameters.width);
    Line2:setStyle(instance.parameters.style); 

    Line3 = instance:addStream("Line3", core.Line, name, "Total Trough", instance.parameters.color3, first+Period  );
    Line3:setPrecision(math.max(2, instance.source:getPrecision()));
    Line3:setWidth(instance.parameters.width);
    Line3:setStyle(instance.parameters.style); 	
 
end


function Update(period, mode)

 

	 if period <= first then
	 return;
	 end

    period = period-Bars;
	
	sup[period]=sup[period-1]; 
	res[period]=res[period-1]; 	
     
 
    local test1=true; 
         for i= 1, Bars, 1 do
		
		     if  source.high[period] < source.high[period+i] or  source.high[period] < source.high[period-i] then
			 test1=false;
			 end
			
		 end	
		 
	if test1 then	 
	sup[period]=sup[period] + 1	
    end  
	
    local test2=true; 
		
        for i= 1, Bars, 1 do
		
		     if  source.low[period] > source.low[period+i] or source.low[period] > source.low[period-i] then
			 test2=false;
			 end
			
		 end		
	
 
 	if test2 then    
	res[period]=res[period] + 1		
	end
 
	  	 
	rsup[period+Bars] = (sup[period] - sup[period-Period+1]) *2
	rres[period+Bars] = (res[period] - res[period-Period+1]) *2 
	tot[period+Bars] = (rsup[period] + rres[period])/2 
	ata[period+Bars] =  ((res[period] + sup[period])/(period))*Period	
	
	
    period= period+Bars;

	MA1:update(mode);
	MA2:update(mode);
	MA3:update(mode);
	
	 if period <= first +Period then
	 return;
	 end	
	 
 
	Line1[period] = ((MA1.DATA[period]/ata[period])*100)-100
	Line2[period] = ((MA2.DATA[period]/ata[period])*100)-100
	Line3[period] =  ((MA3.DATA[period]/ata[period])*100)-100
	
end

  

--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+

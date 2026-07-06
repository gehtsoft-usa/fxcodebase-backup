-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=73374

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
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



-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Special K");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("RSI Calculation");
 
    indicator.parameters:addInteger("Period1", "1. Period", "", 10, 1, 2000);
    indicator.parameters:addInteger("Period2", "2. Period", "", 15, 1, 2000);
    indicator.parameters:addInteger("Period3", "3. Period", "", 20, 1, 2000);
    indicator.parameters:addInteger("Period4", "4. Period", "", 30, 1, 2000);
    indicator.parameters:addInteger("Period5", "5. Period", "", 40, 1, 2000);
    indicator.parameters:addInteger("Period6", "6. Period", "", 65, 1, 2000);
    indicator.parameters:addInteger("Period7", "7. Period", "", 75, 1, 2000);
    indicator.parameters:addInteger("Period8", "8. Period", "", 100, 1, 2000);
    indicator.parameters:addInteger("Period9", "9. Period", "", 195, 1, 2000);
    indicator.parameters:addInteger("Period10", "10. Period", "", 265, 1, 2000);
    indicator.parameters:addInteger("Period11", "11. Period", "", 390, 1, 2000);
    indicator.parameters:addInteger("Period12", "12. Period", "", 530, 1, 2000);
	
	indicator.parameters:addGroup("Moving Average Calculation");
 
    indicator.parameters:addInteger("MA_Period1", "1. Period", "", 10, 1, 2000);
    indicator.parameters:addInteger("MA_Period2", "2. Period", "", 10, 1, 2000);
    indicator.parameters:addInteger("MA_Period3", "3. Period", "", 10, 1, 2000);
    indicator.parameters:addInteger("MA_Period4", "4. Period", "", 15, 1, 2000);
    indicator.parameters:addInteger("MA_Period5", "5. Period", "", 50, 1, 2000);
    indicator.parameters:addInteger("MA_Period6", "6. Period", "", 65, 1, 2000);
    indicator.parameters:addInteger("MA_Period7", "7. Period", "", 75, 1, 2000);
    indicator.parameters:addInteger("MA_Period8", "8. Period", "", 100, 1, 2000);
    indicator.parameters:addInteger("MA_Period9", "9. Period", "", 130, 1, 2000);
    indicator.parameters:addInteger("MA_Period10", "10. Period", "", 130, 1, 2000);
    indicator.parameters:addInteger("MA_Period11", "11. Period", "", 130, 1, 2000);
    indicator.parameters:addInteger("MA_Period12", "12. Period", "", 195, 1, 2000);	
	
 	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("PeriodA", "1. Period", "", 10, 1, 2000);
    indicator.parameters:addInteger("PeriodB", "2.  Period", "", 100, 1, 2000);
    indicator.parameters:addInteger("PeriodC", "3.  Period", "", 100, 1, 2000);	
	
	indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("SpecialK", "SpecialK Line Color", "", core.rgb(128, 128,128)); 
	indicator.parameters:addColor("color1", "1. Line", "", core.rgb(0, 255,0)); 
	indicator.parameters:addColor("color2", "2. Line", "", core.rgb(255, 0,0)); 
	indicator.parameters:addColor("color3", "3. Line", "", core.rgb(0, 0,255)); 	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Period={};  
local MA_Period={};  
local ROC={};
local MA={};
	
-- Routine
 function Prepare(nameOnly)   
 
    for i= 1, 12, 1 do
	Period[i]=instance.parameters:getInteger("Period" .. i); 
	MA_Period[i]=instance.parameters:getInteger("MA_Period" .. i); 	
	end
	
	PeriodA=instance.parameters.PeriodA;
	PeriodB=instance.parameters.PeriodB;
	PeriodC=instance.parameters.PeriodC;
	
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
    first=source:first() ; 	
	for i= 1, 12, 1 do
	ROC[i]= core.indicators:create("ROC", source, Period[i]);
	MA[i]= core.indicators:create("MVA", ROC[i].DATA, MA_Period[i]);	
	first=math.max(first, MA[i].DATA:first()) ; 	
	end
	 
 
 
	
	
    SpecialK = instance:addStream("SpecialK", core.Line, name, "SpecialK", instance.parameters.SpecialK, first );
    SpecialK:setPrecision(math.max(2, instance.source:getPrecision()));
    SpecialK:setWidth(instance.parameters.width);
    SpecialK:setStyle(instance.parameters.style);
	
    Line1 = instance:addStream("Line1", core.Line, name, "1. Line", instance.parameters.color1, first );
    Line1:setPrecision(math.max(2, instance.source:getPrecision()));
    Line1:setWidth(instance.parameters.width);
    Line1:setStyle(instance.parameters.style);	
	
    Line2 = instance:addStream("Line2", core.Line, name, "2. Line", instance.parameters.color2, first );
    Line2:setPrecision(math.max(2, instance.source:getPrecision()));
    Line2:setWidth(instance.parameters.width);
    Line2:setStyle(instance.parameters.style);	

    Line3 = instance:addStream("Line3", core.Line, name, "3. Line", instance.parameters.color3, first );
    Line3:setPrecision(math.max(2, instance.source:getPrecision()));
    Line3:setWidth(instance.parameters.width);
    Line3:setStyle(instance.parameters.style);		
     
 
end


function Update(period, mode)
	for i= 1, 12, 1 do
	ROC[i]:update(mode); 
	MA[i]:update(mode); 
	end

	if period <= first
	or  not source:hasData(period) 
	then
	return;
	end
	  
	local a=MA[1].DATA[period]*1;
	local b=MA[2].DATA[period]*2;
	local c=MA[3].DATA[period]*3;
	local d=MA[4].DATA[period]*4;
	local e=MA[5].DATA[period]*1;
	local f=MA[6].DATA[period]*2;
	local g=MA[7].DATA[period]*3;
	local j=MA[8].DATA[period]*4;
	local k=MA[9].DATA[period]*1;
	local i=MA[10].DATA[period]*2;
	local l=MA[11].DATA[period]*3;
	local m =MA[12].DATA[period]*4;	
	SpecialK[period]= (a+b+c+d+e+f+g+j+k+i+l+m); 
	
	if period <= first + PeriodA
	or  not source:hasData(period) 
	then
	return;
	end	
	
    Line1[period]=mathex.avg(SpecialK, period-PeriodA+1, period);



	if period <= first + PeriodB
	or  not source:hasData(period) 
	then
	return;
	end	
	
    Line2[period]=mathex.avg(SpecialK, period-PeriodB+1, period);	
	
	if period <= first+ PeriodB + PeriodC
	or  not source:hasData(period) 
	then
	return;
	end	
	
    Line3[period]=mathex.avg(Line2, period-PeriodC+1, period);		
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
-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72006

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
    indicator:name("Extrapolate negative shifted TMA");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

 

 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("length1", "Fast MA", "", 15, 1, 2000);
    indicator.parameters:addInteger("length2", "Slow MA", "", 30, 1, 2000);

    indicator.parameters:addInteger("shift1", "1. Line Shift", "", -10);
    indicator.parameters:addInteger("shift2", "2. Line Shift", "", -10);
	
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
local length1, length2; 
 
	
-- Routine
 function Prepare(nameOnly)   
 
    
	length1=instance.parameters.length1;
	length2=instance.parameters.length2;
	shift1=instance.parameters.shift1;
	shift2=instance.parameters.shift2;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  length1.. "," ..  length2.. "," ..  shift1.. "," ..  shift2  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
 
	first=source:first()+math.max(math.ceil(length1 / 2),math.ceil(length2 / 2)) ; 
	
 
	Data1= instance:addInternalStream(0, math.abs(shift1));
	Data2 = instance:addInternalStream(0, math.abs(shift2));	
	
    Line1 = instance:addStream("Line1", core.Line, name, "1. Line", instance.parameters.color1, math.max(source:first(), first+shift1) , math.max(shift1, 1) );
    Line1:setPrecision(math.max(2, instance.source:getPrecision()));
    Line1:setWidth(instance.parameters.width);
    Line1:setStyle(instance.parameters.style);
    Line1:addLevel(0);	
 
    Line2 = instance:addStream("Line2", core.Line, name, "2. Line", instance.parameters.color2, math.max(source:first(), first+shift2) , math.max(shift2, 1) );
    Line2:setPrecision(math.max(2, instance.source:getPrecision()));
    Line2:setWidth(instance.parameters.width);
    Line2:setStyle(instance.parameters.style);
    Line2:addLevel(0); 
end


function Update(period, mode)
 

	 if period <= first then
	 return;
	 end
	 
 
    Data1[period]=mathex.avg(source.open, period-math.ceil(length1 / 2), period);
    Data2[period]=mathex.avg(source.close, period-math.ceil(length2 / 2), period);
	
	
	
	 if period <= first + math.max(math.floor(length1 / 2),math.floor(length1 / 2)) +1  then
	 return;
	 end
	 
	
	if  period+shift1 >=  first then
    Line1[period+shift1] = mathex.avg(Data1, period- math.floor(length1 / 2), period);
	end
	if  period+shift2 >=  first then	
    Line2[period+shift2] = mathex.avg(Data2, period-math.floor(length2 / 2), period); 
	end
	
	
 
	if shift1 < 0 and period == source:size()-1 then
	func1 (period); 
	end
 
	if shift2 < 0 and period == source:size()-1 then
	func2 (period); 	 
    end	
end

 
function func1 (Period)  



for i= 1, math.abs(shift1), 1 do

	if Period<  length1 then
	return;
	end

    Data1[Period+i]=mathex.avg(source.open, Period-math.ceil(length1-i / 2)+i, Period);
    local X= mathex.avg(Data1, Period-math.floor(length1-i / 2)+i, Period+i);	
    Line1[Period+shift1+ i] =(X * (length1-i) + source.close[Period]*i)/length1
 
 
end

end

 

 
 
function func2 (Period) 

if Period<  length2 then
return;
end


for i= 1, math.abs(shift2), 1 do
 
    Data2[Period+i]=mathex.avg(source.close, Period-math.ceil(length2-i / 2)+i, Period);
	local X = mathex.avg(Data2, Period-math.floor(length2-i / 2)+i, Period+i);
    Line2[Period+shift2+i]=(X * (length2-i) + source.close[Period]*i)/length2
end

end

 

 


 


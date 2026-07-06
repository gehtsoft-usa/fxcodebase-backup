-- More information about this indicator can be found at:
--https://fxcodebase.com/code/viewtopic.php?f=17&t=72116

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
    indicator:name("UpDownBars");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
 
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("UpDown_Period", "UpDown_Period", "", 20, 1, 2000);
    indicator.parameters:addInteger("Average_Period", "Average_Period", "", 10, 1, 2000); 
	
	indicator.parameters:addBoolean("Weight", "Use Weight", "", true);	
	indicator.parameters:addBoolean("Sqrt", "Use Sqrt", "", true);	
	
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");	
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("Up", "Up Bar Color", "", core.rgb(0, 255,0)); 
	 indicator.parameters:addColor("Down", "Down Bar Color", "", core.rgb(255, 0,0)); 
	indicator.parameters:addColor("color", "Line  Color", "", core.rgb(0, 0,255)); 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local UpDown_Period, Average_Period,Method; 
local Indicator;
local Weight,Sqrt;	
-- Routine
 function Prepare(nameOnly)   
 
    
	UpDown_Period=instance.parameters.UpDown_Period;
	Average_Period=instance.parameters.Average_Period;
	Method=instance.parameters.Method;
	Weight=instance.parameters.Weight;
	Sqrt=instance.parameters.Sqrt;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  UpDown_Period.. "," ..  Average_Period .. "," .. Method .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	

	first=source:first() ; 
	
	
	Bar = instance:addInternalStream(0, 0); 
	
	
    Bar = instance:addStream("Bar", core.Bar, name, "Bar", instance.parameters.Up, first+UpDown_Period );
    Bar:setPrecision(math.max(2, instance.source:getPrecision())); 
    Bar:addLevel(0);	
	
	Indicator= core.indicators:create(Method, Bar, Average_Period);	
 
    Line = instance:addStream("Line", core.Line, name, "Line", instance.parameters.color, first + UpDown_Period + Average_Period );
    Line:setPrecision(math.max(2, instance.source:getPrecision()));
    Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
    Line:addLevel(0);	 
end


function Update(period, mode)



	 if period <= first then
	 return;
	 end
	 
     
	Bar[period]= (source.close[period]-source.open[period])/source:pipSize();
	
	 if period <= first+UpDown_Period then
	 return;
	 end

	 
	local Up=0;
	local Down=0;
	local upCount=0;
	local downCount=0;
	
	
	for j=1, UpDown_Period, 1  do
	p=period-UpDown_Period+j;
	
	
	if Sqrt then
	
	        if Weight then
			if(Bar[p]>0) then
			Up = Up +(math.sqrt(Bar[p])*j);
			upCount=upCount+j;
			else
			Down =Down+(math.sqrt(math.abs(Bar[p]))*j);
			downCount=downCount+j;
			end
		else
			if(Bar[p]>0) then
			Up = Up +(math.sqrt(Bar[p]));
			upCount=upCount+1;
			else
			Down =Down+(math.sqrt(math.abs(Bar[p])));
			downCount=downCount+1;
			end		
		end
	
	else
	
	
	    if Weight then
			if(Bar[p]>0) then
			Up = Up +((Bar[p])*j);
			upCount=upCount+j;
			else
			Down =Down+((math.abs(Bar[p]))*j);
			downCount=downCount+j;
			end
		else
			if(Bar[p]>0) then
			Up = Up +((Bar[p]));
			upCount=upCount+1;
			else
			Down =Down+((math.abs(Bar[p])));
			downCount=downCount+1;
			end		
		end
	end
	end
	
	
	
	local upDivide=0;
	local downDivide=0;
	
	if(upCount~=0) then
         upDivide = Up/upCount;
	end	 
         
    if(downCount~=0) then
         downDivide = Down/downCount;
	end

	Bar[period]= 0;	
	
 
	Bar[period]= upDivide-downDivide; 
 
	
	
	if Bar[period]> 0 then
	Bar:setColor(period,  instance.parameters.Up);	
	else
	Bar:setColor(period,  instance.parameters.Down);	
	end
	
	
	Indicator:update(mode); 
	
	 if period <= first+UpDown_Period + Average_Period then
	 return;
	 end	
	 
	Line[period]=Indicator.DATA[period];
end

 
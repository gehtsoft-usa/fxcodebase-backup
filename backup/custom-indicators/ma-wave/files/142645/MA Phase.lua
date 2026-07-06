 
-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71307

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2021, Gehtsoft USA LLC  | 
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

--+------------------------------------------------------------------------------------------------+
--|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |
--|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C                                 |
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |                                                  |   
--+------------------------------------------------------------------------------------------------+
function Init()
    indicator:name("MA Phase");
    indicator:description("MA Phase");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("1. MA Calculation");
    indicator.parameters:addInteger("Period1", "MA Period", "Period" , 50);	
    indicator.parameters:addInteger("Extension", "Extension", "Extension" , 50);		
 
	
    indicator.parameters:addString("Method1", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addGroup("2. MA Calculation");
    indicator.parameters:addInteger("Period2", "MA Period", "Period" , 100);	 	
 
	
    indicator.parameters:addString("Method2", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA"); 
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Color", "Top Line Color", "Line Color", core.rgb(0, 255, 0)); 
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
 

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 

local first;
local source = nil; 
local Extension;
local Top, Bottom; 
local StartPeriodTop=nil;
local EndPeriodTop=nil;

local StartPeriodBottom=nil;
local EndPeriodBottom=nil;

local MA1,MA2;
function Prepare(nameOnly)
    
    source = instance.source;
	


    local name = profile:id() .. "(" .. source:name()  ..  ")";
    instance:name(name);

    if   (nameOnly)  then
	return;
	end
	
 
	
	Extension=instance.parameters.Extension;
	
	
	MA1= core.indicators:create(instance.parameters.Method1, source,  instance.parameters.Period1);	
	MA2= core.indicators:create(instance.parameters.Method2, source,  instance.parameters.Period2);	
	first=math.max(MA1.DATA:first() ,MA2.DATA:first() ); 
	
 
	
	
        Phase = instance:addStream("Phase", core.Line, name, "Phase", instance.parameters.Color, first,Extension);
        Phase:setPrecision(math.max(2, instance.source:getPrecision()));
		Phase:setWidth(instance.parameters.width);
        Phase:setStyle(instance.parameters.style);
		Phase:addLevel(0);
 
 
		StartPeriodTop=nil;
		EndPeriodTop=nil;		
 
	
	
	core.host:execute("setTimer", 1, 10);
end

function ReleaseInstance()
    core.host:execute("killTimer", 1);
end

 

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
 
 
 
 
 
    MA1:update(mode); 
	MA2:update(mode); 
    if period < source:size()-1 then
	return;
	end
 
 

    if StartPeriodTop==nil
	or  EndPeriodTop==nil
    then
	return;
	end
 
				
	PeriodTop=(EndPeriodTop-StartPeriodTop) ;
 
 
 	for i= StartPeriodTop-1, source:size()-1+Extension ,1 do	
		
		if MA1.DATA[StartPeriodTop] > MA2.DATA[StartPeriodTop] then
		Phase[i] = math.sin(math.pi * ((i-StartPeriodTop)/PeriodTop) );
		else
		Phase[i] =1- math.sin(math.pi * ((i-StartPeriodTop)/PeriodTop) )-1;	
        end		
			
	end
	
	 
end

function AsyncOperationFinished(cookie )

    if cookie== 1 then
	StartPeriodTop, EndPeriodTop= FindLast(source:size()-2)
 
	
	 if StartPeriodTop~= nil and  EndPeriodTop~= nil  
	 then
	 instance:updateFrom(0);
	 end
	 
	end
    
   
    
	 
     return core.ASYNC_REDRAW ;
   
	
end	


 


function FindLast(period)

		local Return={}; 
        local Count=0;
		for i = period, first, -1 do 
		
		    if  core.crosses (MA1.DATA,MA2.DATA, i) then 
            Count=Count+1;
			Return[Count]=i;
			 
            end			
			
			if Return[1]~=nil and Return[2]~=nil  then
			break;
			end

		end


    return Return[2],Return[1];
 
end
 
-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71217

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


-- Indicator profile initialization routine

function Init()
    indicator:name("Zig Zag Price Difference");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("P1", "Depth", "the minimal amount of bars where there will not be the second maximum", 12);
    indicator.parameters:addInteger("P2", "Deviation", "Distance in pips to eliminate the second maximum in the last Depth periods", 5);
    indicator.parameters:addInteger("P3", "Backstep", "The minimal amount of bars between maximums/minimums", 3);
	
	

   
 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255, 0, 0));
 
 
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
local Period ; 
local first;
local source = nil;
local Top, Bottom; 
local ItIsOscillator;
local Trend;

local ZigZag;
-- Routine
 function Prepare(nameOnly)   
 
 
    ItIsOscillator= instance.parameters.ItIsOscillator;
   
	
	local Parameters= "";
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	
    source = instance.source;    
	ZigZag= core.indicators:create("ZIGZAG", source, instance.parameters.P1, instance.parameters.P2,instance.parameters.P3);
	
	first=ZigZag.DATA:first() ; 
 
	Oscillator = instance:addStream("Oscillator" , core.Bar, " Oscillator"," Oscillator",instance.parameters.Up, first, Period2); 
    Oscillator:setPrecision(math.max(2, source:getPrecision()));
	
	
end
local FirstLoad=true;
local SecondLoad=true;
local Last;
-- Indicator calculation routine
function Update(period, mode)

 
	if period < source:size()-1  
	then
	return;
	end
	
	
	if Last~=source:serial(period) then
	Last=source:serial(period);	
	
	ZigZag:update(core.UpdateAll);
	end
	
	local FirstPeriod, SecondPeriod;
	
	if FirstLoad then
	FirstLoad=false;
	
	
			for i= first, source:size()-1, 1 do
			
			 
			 
				  Period= FindLast(i)
					
		          Oscillator[i]= source.close[i] -ZigZag.DATA[Period];
					
				 if  Oscillator[i] > 0 then
				 Oscillator:setColor(i, instance.parameters.Up);
				 else
				 Oscillator:setColor(i, instance.parameters.Down);
				 end	
			end
	
	else
	
 
	 
		     Period= FindLast(period)
			 for i= Period, source:size()-1, 1 do			
			 Oscillator[i]= source.close[i] -ZigZag.DATA[Period];
			 
				 if  Oscillator[i] > 0 then
				 Oscillator:setColor(i, instance.parameters.Up);
				 else
				 Oscillator:setColor(i, instance.parameters.Down);
				 end
				 
			 end
		
    end    
	
	
				
	 
	 
				  
end



function FindLast(period)

		local Return=0;

		for i = period, first, -1 do 
		
		    if ZigZag.DATA:hasData(i) then

					if Return== 0 
					and source.high[i]== ZigZag.DATA[i]
					then
					Return=i;
					end
					
					if Return== 0 
					and source.low[i]== ZigZag.DATA[i]
					then
					Return=i;
					end 

            end			
			
			if Return~=0  then
			break;
			end

		end


   return Return;

end

 
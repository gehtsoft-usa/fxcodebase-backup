-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72448

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
    indicator:name("Breakout zigzag");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("P1", "Depth", "the minimal amount of bars where there will not be the second maximum", 12);
    indicator.parameters:addInteger("P2", "Deviation", "Distance in pips to eliminate the second maximum in the last Depth periods", 5);
    indicator.parameters:addInteger("P3", "Backstep", "The minimal amount of bars between maximums/minimums", 3);
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color1", "Top Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color2", "Bottom Line Color", "", core.rgb(255, 0, 0)); 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	P1=instance.parameters.P1;
	P2=instance.parameters.P2;
	P3=instance.parameters.P3;	
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  P1.. "," ..  P2 .. "," ..  P3 .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	Indicator= core.indicators:create("ZIGZAG", source, P1, P2, P3);
	first=Indicator.DATA:first() ; 
	
	
	--Stream = instance:addInternalStream(0, 0);
 
	
	
    Top = instance:addStream("Top", core.Line, name, "Top", instance.parameters.color1, first );
    Top:setPrecision(math.max(2, instance.source:getPrecision()));
    Top:setWidth(instance.parameters.width);
    Top:setStyle(instance.parameters.style);
    Top:addLevel(0);	
 
    Bottom = instance:addStream("Bottom", core.Line, name, "Bottom", instance.parameters.color2, first );
    Bottom:setPrecision(math.max(2, instance.source:getPrecision()));
    Bottom:setWidth(instance.parameters.width);
    Bottom:setStyle(instance.parameters.style);
    Bottom:addLevel(0);	
end

local Last;
local First=false;
local FIRST=0;
local Init=false;
function Update(period, mode)


    if  not Init 
	or source:serial(1)~= FIRST 
	then
    Init= true;
	FIRST=  source:serial(1)
	First=false 
	Last=0;
	end
	
	 

    if source:serial(period)== Last
	or period < source:size()-1
	or period <= P1
	then
	return;
	end
	
	Last=source:serial(period);
	
	
	  Indicator:update(core.UpdateAll); 
	  
	if not First then 
	     First=true;
		 Historical(); 
    end

	

	 if period <= first then
	 return;
	 end
	 
 
	local LastZigZag=FindLast(period);
	
	if LastZigZag== 0 then
	return;
	end
	
 	Top[period]= Top[period-1];
	Bottom[period]= Bottom[period-1];
	
	local min,max=mathex.minmax(source, period-P1+1, period);
	
	if Indicator.DATA[LastZigZag-1] > Indicator.DATA[LastZigZag]   then
	Top[period]=max;
	end 

	 
	if Indicator.DATA[LastZigZag-1] < Indicator.DATA[LastZigZag]  then
	Bottom[period]=min;
	end 

 
	

	
end

function Historical()
   
    for period=first, source:size()-2, 1 do
	
			local LastZigZag=FindLast(period);
			
			if LastZigZag~= 0 then
			
				Top[period]= Top[period-1];
				Bottom[period]= Bottom[period-1];
				
				--local min,max=mathex.minmax(source, period-P1+1, period);
				
				if Indicator.DATA[LastZigZag-1] < Indicator.DATA[LastZigZag] and  Indicator.DATA[LastZigZag-1] > Indicator.DATA[LastZigZag-2]    then
				Top[period]=Indicator.DATA[LastZigZag];
				end 

				 
				if Indicator.DATA[LastZigZag-1] > Indicator.DATA[LastZigZag] and  Indicator.DATA[LastZigZag-1] < Indicator.DATA[LastZigZag-2] then
				Bottom[period]=Indicator.DATA[LastZigZag];
				end 
				
			end
	end
	
end

function FindLast(period)

local Return=0;
	 for i= period-1, first, -1 do
 
		 if source.high[i]== Indicator.DATA[i]
		 or source.low[i]== Indicator.DATA[i]
		 then
		 Return=i;
		 break;	 
		 end 
	 end
	 
	return Return;

end
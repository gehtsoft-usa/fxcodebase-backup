-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71306

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
    indicator:name("ZigZag Phase");
    indicator:description("ZigZag Phase");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Extension", "Extension", "Extension" , 50);		
     indicator.parameters:addInteger("P1", "Depth", "the minimal amount of bars where there will not be the second maximum", 12);
    indicator.parameters:addInteger("P2", "Deviation", "Distance in pips to eliminate the second maximum in the last Depth periods", 5);
    indicator.parameters:addInteger("P3", "Backstep", "The minimal amount of bars between maximums/minimums", 3);
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

 
function Prepare(nameOnly)
    
    source = instance.source;
	


    local name = profile:id() .. "(" .. source:name()  ..  ")";
    instance:name(name);

    if   (nameOnly)  then
	return;
	end
	
 
	
	Extension=instance.parameters.Extension;
	
	
	ZigZag= core.indicators:create("ZIGZAG", source, instance.parameters.P1, instance.parameters.P2,instance.parameters.P3);	
	first=ZigZag.DATA:first() ; 
	
 
	
	
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

 
local Last;

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
 
 
 
if period < source:size()-1 then
return;
end
 
 
if Last~= source:serial(period) then
ZigZag:update(core.UpdateAll ); 

Last= source:serial(period);
end

 
 

    if StartPeriodTop==nil
	or  EndPeriodTop==nil
    then
	return;
	end
 
				
	PeriodTop=(EndPeriodTop-StartPeriodTop) ;
 
 
 	for i= StartPeriodTop-1, source:size()-1+Extension ,1 do	
		
		if ZigZag.DATA[StartPeriodTop] > ZigZag.DATA[EndPeriodTop] then
		Phase[i] = math.cos(math.pi * ((i-StartPeriodTop)/PeriodTop) );		
		else
		Phase[i] =1- math.cos(math.pi * ((i-StartPeriodTop)/PeriodTop) )-1;			
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


		local Return1=nil;
		local Return2=nil;
		
		for i = period, first, -1 do 
		
		    if ZigZag.DATA:hasData(i)and ZigZag.DATA:hasData(i+1) then
			 
			 
			        if Return1== nil and Return2~= nil 
					and (source.high[i]== ZigZag.DATA[i]
					or source.low[i]== ZigZag.DATA[i]
					)			
					then
					Return1=i;
					end 
					
			        if   Return2 == nil 				
					and (source.high[i]== ZigZag.DATA[i]
					or source.low[i]== ZigZag.DATA[i]
					)
					then
					Return2=i;
					end 

					


            end			
			
			if Return2~=nil and Return1~=nil  then
			break;
			end

		end


    return Return1,Return2;
 
end

 
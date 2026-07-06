 
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
    indicator:name("MA Wave");
    indicator:description("MA Wave");
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
	
 
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Top_Color", "Top Line Color", "Line Color", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Bottom_Color", "Bottom Line Color", "Line Color", core.rgb(255, 0, 0));
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

local MA;
function Prepare(nameOnly)
    
    source = instance.source;
	


    local name = profile:id() .. "(" .. source:name()  ..  ")";
    instance:name(name);

    if   (nameOnly)  then
	return;
	end
	
 
	
	Extension=instance.parameters.Extension;
	
	
	MA= core.indicators:create(instance.parameters.Method1, source,  instance.parameters.Period1);	
	first=MA.DATA:first() ; 
	
 
	
	
        Top = instance:addStream("Top", core.Line, name, "Top", instance.parameters.Top_Color, first,Extension);
        Top:setPrecision(math.max(2, instance.source:getPrecision()));
		Top:setWidth(instance.parameters.width);
        Top:setStyle(instance.parameters.style);
		Top:addLevel(0);
		
		Bottom = instance:addStream("Bottom", core.Line, name, "Bottom", instance.parameters.Bottom_Color, first,Extension);
        Bottom:setPrecision(math.max(2, instance.source:getPrecision()));
		Bottom:setWidth(instance.parameters.width);
        Bottom:setStyle(instance.parameters.style);
		Bottom:addLevel(0);
 
		StartPeriodTop=nil;
		EndPeriodTop=nil;		
 	
		StartPeriodBottom=nil;
		EndPeriodBottom=nil;
	
	
	core.host:execute("setTimer", 1, 10);
end

function ReleaseInstance()
    core.host:execute("killTimer", 1);
end

 

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
 
 
 
 
 
    MA:update(mode); 
    if period < source:size()-1 then
	return;
	end
 
 

    if StartPeriodTop==nil
	or  EndPeriodTop==nil
    then
	return;
	end
	
	if StartPeriodBottom==nil 
	or 	EndPeriodBottom==nil
	then
	return;
	end
		
				
	PeriodTop=(EndPeriodTop-StartPeriodTop)/2;
	PeriodBottom=(EndPeriodBottom-StartPeriodBottom)/2;
 
 	for i= StartPeriodTop-1, source:size()-1+Extension ,1 do	
			 
		Top[i] = math.cos(math.pi * ((i-StartPeriodTop)/PeriodTop) );
					
	end
	
	for i= StartPeriodBottom-1, source:size()-1+Extension ,1 do	
		Bottom[i] =1- math.cos(math.pi * ((i-StartPeriodBottom)/PeriodBottom) )-1;		
	end
end

function AsyncOperationFinished(cookie )

    if cookie== 1 then
	StartPeriodTop, EndPeriodTop= FindTop(source:size()-2)
	StartPeriodBottom, EndPeriodBottom= FindBottom(source:size()-2)	
	
	 if StartPeriodTop~= nil and  EndPeriodTop~= nil 
	 and StartPeriodBottom~= nil and  EndPeriodBottom~= nil 
	 then
	 instance:updateFrom(0);
	 end
	 
	end
    
   
    
	 
     return core.ASYNC_REDRAW ;
   
	
end	


 


function FindTop(period)

		local Return1=nil;
		local Return2=nil;
		
		for i = period, first, -1 do 
		
		    if MA.DATA:hasData(i) and MA.DATA:hasData(i+1) then
			
			        if   Return1 ~= nil and Return2== nil 
					and MA.DATA[i]> MA.DATA[i+1]
					and MA.DATA[i]> MA.DATA[i-1]
					then
					Return2=i;
					end 

					if Return1== nil 
					and MA.DATA[i]> MA.DATA[i+1]
					and MA.DATA[i]> MA.DATA[i-1]				
					then
					Return1=i;
					end 


            end			
			
			if Return2~=nil and Return1~=nil  then
			break;
			end

		end


    return Return2,Return1;
 
end

 
 function FindBottom(period)

		local Return1=nil;
		local Return2=nil;
		
		for i = period, first, -1 do 
		
		    if MA.DATA:hasData(i)and MA.DATA:hasData(i+1) then
			
			        if   Return1 ~= nil and Return2== nil 
					and MA.DATA[i]< MA.DATA[i+1]
					and MA.DATA[i]< MA.DATA[i-1]
					then
					Return2=i;
					end 

					if Return1== nil 
					and MA.DATA[i]< MA.DATA[i+1]
					and MA.DATA[i]< MA.DATA[i-1]					
					then
					Return1=i;
					end 


            end			
			
			if Return2~=nil and Return1~=nil  then
			break;
			end

		end


    return Return2,Return1;
 
end 

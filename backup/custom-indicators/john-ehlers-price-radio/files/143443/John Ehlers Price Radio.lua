-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71469

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
    indicator:name("John Ehlers Price Radio");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("length1", "Length", "", 14, 1, 2000);
    indicator.parameters:addInteger("length2", "High/Low Length", "", 4, 1, 2000);
    indicator.parameters:addDouble("Multiplier", "Multiplier", "", 10, 0, 2000);	 
	 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color1", "Change Line Color", "", core.rgb(128, 128, 128));
	indicator.parameters:addColor("color2", "Top Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("color3", "Bottom Line Color", "", core.rgb(0, 255, 0));	
	indicator.parameters:addColor("color4", "Cental Line Color", "", core.rgb(0, 0, 255));	
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 1, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
local length1, length2; 
local first;
local source = nil;

local AbsChange;
local Envelope;
local Change;
local MaxAbs, Min, Max;
local Top, Bottom;
local HL;
local Multiplier;
-- Routine
 function Prepare(nameOnly)   
 
 
    length1= instance.parameters.length1;
    length2= instance.parameters.length2;	
	Multiplier= instance.parameters.Multiplier;
	
	local Parameters= length1.. ", " .. length2.. ", " .. Multiplier;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source; 
    first= source:first()+1+length2;
	

   
 
	Change = instance:addStream("Change" , core.Line, " Change"," Change",instance.parameters.color1, source:first()+1);
	Change:setWidth(instance.parameters.width);
    Change:setStyle(instance.parameters.style);
    Change:setPrecision(math.max(2, source:getPrecision()));
	
	AbsChange= instance:addInternalStream(0, 0);
	MaxAbs= instance:addInternalStream(0, 0);		
	Min= instance:addInternalStream(0, 0);	
	Max= instance:addInternalStream(0, 0);	
	HL= instance:addInternalStream(0, 0);	
	
	Top = instance:addStream("Top" , core.Line, " Top"," Top",instance.parameters.color2, first+length1);
	Top:setWidth(instance.parameters.width);
    Top:setStyle(instance.parameters.style);
    Top:setPrecision(math.max(2, source:getPrecision()));


	Bottom = instance:addStream("Bottom" , core.Line, " Bottom"," Bottom",instance.parameters.color3,first+length1);
	Bottom:setWidth(instance.parameters.width);
    Bottom:setStyle(instance.parameters.style);
    Bottom:setPrecision(math.max(2, source:getPrecision()));	

	Central = instance:addStream("Central" , core.Line, " Central"," Central",instance.parameters.color4, first+length1*2);
	Central:setWidth(instance.parameters.width);
    Central:setStyle(instance.parameters.style);
    Central:setPrecision(math.max(2, source:getPrecision()));		
end

-- Indicator calculation routine
function Update(period, mode)
	if period < source:first()+1
	then
	return;
	end 
    
	Change[period]= source[period]-source[period-1];
	AbsChange[period]=math.abs(Change[period]);
	
	if period < first
	then
	return;
	end
	
    MaxAbs[period]=mathex.max(AbsChange, period-length2+1, period); 

	if period < first+length1
	then
	return;
	end
	
    Top[period] = mathex.avg(MaxAbs, period-length1+1, period );	
    Bottom[period]= -Top[period]; 
	

    local min,max=mathex.minmax(Change, period-length1+1, period);	
 
	
	HL[period] = Change[period]*Multiplier;
	
	if HL[period] < min then
	HL[period]= min;
	end 
 
  	if HL[period] > max then
	HL[period]= max 
	end  

	
	if period < first+length1*2
	then
	return;
	end
	
    Central[period] = mathex.avg(HL, period-length1+1, period );	   
				  
end


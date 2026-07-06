-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71320

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
    indicator:name(" Auto dispersion bands");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation");  
	indicator.parameters:addInteger("length", "Length", "", 90, 1, 2000);
    indicator.parameters:addInteger("smooth", "Smooth", "", 140, 1, 2000);
 
 
	
	indicator.parameters:addGroup("Top Line Style"); 	
    indicator.parameters:addColor("color1", "Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 3, 1, 5);

	indicator.parameters:addGroup("Bottom Line Style"); 	
    indicator.parameters:addColor("color2", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width2", "Line Width", "", 3, 1, 5);


	indicator.parameters:addGroup("Central Line Style"); 	
    indicator.parameters:addColor("color3", "Line Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("style3", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width3", "Line Width", "", 3, 1, 5);	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
local smooth, length ; 
local first;
local source = nil;
 
local Oscillator;  
local sq,x;
-- Routine
 function Prepare(nameOnly)   
 
 
    smooth = instance.parameters.smooth ; 
	length = instance.parameters.length;
	
	
	local Parameters= smooth;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source; 
    first=source:first() ;
	
    x= instance:addInternalStream(0, 0); 
    a= instance:addInternalStream(0, 0);
	b= instance:addInternalStream(0, 0);  
    min= instance:addInternalStream(0, 0);
	max= instance:addInternalStream(0, 0);
	
	WMAA = core.indicators:create("WMA", max, length);
	WMAB = core.indicators:create("WMA", min, length);
	
	WMA2A = core.indicators:create("WMA", WMAA.DATA, smooth);
	WMA2B = core.indicators:create("WMA", WMAB.DATA, smooth);
	
	Top = instance:addStream("Top" , core.Line, " Top"," Top",instance.parameters.color1, first+length*4  +smooth );
	Top:setWidth(instance.parameters.width1);
    Top:setStyle(instance.parameters.style1);
    Top:setPrecision(math.max(2, source:getPrecision()));
	
	Bottom = instance:addStream("Bottom" , core.Line, " Bottom"," Bottom",instance.parameters.color2, first+length*4  +smooth );
	Bottom:setWidth(instance.parameters.width2);
    Bottom:setStyle(instance.parameters.style2);
    Bottom:setPrecision(math.max(2, source:getPrecision()));

	Central = instance:addStream("Central" , core.Line, " Central"," Central",instance.parameters.color3, first+length*4  +smooth );
	Central:setWidth(instance.parameters.width3);
    Central:setStyle(instance.parameters.style3);
    Central:setPrecision(math.max(2, source:getPrecision()));	
	
	
end

-- Indicator calculation routine
function Update(period, mode)

 
	if period < first+length 
	then
	return;
	end
	x[period]=source[period]-source[period-length+1]
	x[period]=x[period]*x[period];
	
	if period < first+length*2 
	then
	return;
	end
	
	local sq =math.sqrt(mathex.avg(x, period-length+1, period));
	a[period] = source[period]  +sq
	b[period] = source[period]  -sq
	
	if period < first+length*3 
	then
	return;
	end
	
	max[period]=mathex.max(a, period-length+1, period);
	min[period]=mathex.min(b, period-length+1, period ); 
	
	if period < first+length*4 
	then
	return;
	end
	WMAA:update(mode);
	WMAB:update(mode);	
	if period < first+length*4  +smooth
	then
	return;
	end
	WMA2A:update(mode);
	WMA2B:update(mode);	

    Top[period]= WMA2A.DATA[period];
	Bottom[period]= WMA2B.DATA[period];
	Central[period]=Bottom[period] +( Top[period]-Bottom[period])
end
 
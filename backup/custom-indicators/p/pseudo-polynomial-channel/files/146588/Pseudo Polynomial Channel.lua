-- More information about this indicator can be found at:
--https://fxcodebase.com/code/viewtopic.php?f=17&t=72452

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
    indicator:name("Pseudo Polynomial Channel");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

 
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("length", "length", "", 14, 1, 2000);
    indicator.parameters:addDouble("morph", "morph", "", 0.9, 0, 1);
    indicator.parameters:addDouble("mult", "mult", "", 1, 0, 1000);
    indicator.parameters:addDouble("flatten", "flatten", "", 1, 0, 1);
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color1", "Top Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color2", "Central Line Color", "", core.rgb(0, 0, 255)); 
	 indicator.parameters:addColor("color3", "Bottom Line Color", "", core.rgb(255, 0, 0)); 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local length, morph,mult,flatten; 
 
	
-- Routine
 function Prepare(nameOnly)   
 
    
	length=instance.parameters.length;
	morph=instance.parameters.morph;
	mult=instance.parameters.mult;
	flatten=instance.parameters.flatten;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  length.. "," ..  morph .. "," ..  mult.. "," ..  morph .. "," ..  flatten.. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
 
	first=source:first()+length*2 ; 
	
 
	k = instance:addInternalStream(0, 0);
	Cum = instance:addInternalStream(0, 0); 
	
	
    Top = instance:addStream("Top", core.Line, name, "Top", instance.parameters.color1, first +length);
    Top:setPrecision(math.max(2, instance.source:getPrecision()));
    Top:setWidth(instance.parameters.width);
    Top:setStyle(instance.parameters.style);
    Top:addLevel(0);	
 
 
    Central = instance:addStream("Central", core.Line, name, "Central", instance.parameters.color2, first +length);
    Central:setPrecision(math.max(2, instance.source:getPrecision()));
    Central:setWidth(instance.parameters.width);
    Central:setStyle(instance.parameters.style);
    Central:addLevel(0);	


    Bottom = instance:addStream("Bottom", core.Line, name, "Bottom", instance.parameters.color3, first+length );
    Bottom:setPrecision(math.max(2, instance.source:getPrecision()));
    Bottom:setWidth(instance.parameters.width);
    Bottom:setStyle(instance.parameters.style);
    Bottom:addLevel(0);		
end


function Update(period, mode)

 
	k[period]=source[period];
	
	 if period <= first  then
	 return;
	 end 	
	
 
	k[period] =  m(k[period-length+1], source[period] )   + (length)/( length*2 ) *   (  m(k[period-length*2+1],source[period])  -    m(k[period-length+1],source[period])  )/flatten	
	

	 if period <= first+length  then
	 return;
	 end 	
	 
	 
	Central[period] = mathex.avg(k,period-length+1, period)
	
	Cum[period]= Cum[period-1] + math.abs(source[period]-Central[period]);
    local er =Cum[period]/period * mult
	
  
 
	Top[period]=  Central[period] + er
	Bottom[period]= Central[period] - er
	
	
end

 

function m(a,b) 
   return   morph * a + (1-morph) * b
end	

 
 







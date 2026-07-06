-- More information about this indicator can be found at:
-- http://fxcodebase.com

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

function Init()
    indicator:name("Trend Exhaustion Indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Length", "Length", "", 10, 1, 2000);
 
	
	indicator.parameters:addGroup("1. Line Style"); 	
    indicator.parameters:addColor("color1", "Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 3, 1, 5);
	
	indicator.parameters:addGroup("2. Line Style"); 	
    indicator.parameters:addColor("color2", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width2", "Line Width", "", 3, 1, 5);	
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
local Length; 
local first;
local source = nil;
 
local sc; 
-- Routine
 function Prepare(nameOnly)   
 
 
    Length= instance.parameters.Length;
	
	
	local Parameters= Length;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source; 
    first=source:first()+Length+1;
	
	sc = 2 / (Length + 1);
	
	
	Close= instance:addInternalStream(0, 0);
 	High= instance:addInternalStream(0, 0);  
 
	Line1 = instance:addStream("Line1" , core.Line, " Line1"," Line1",instance.parameters.color1, first+Length );
	Line1:setWidth(instance.parameters.width1);
    Line1:setStyle(instance.parameters.style1);
    Line1:setPrecision(math.max(2, source:getPrecision()));
	
	Line2 = instance:addStream("Line2" , core.Line, " Line2"," Line2",instance.parameters.color2, first+Length*2 );
	Line2:setWidth(instance.parameters.width1);
    Line2:setStyle(instance.parameters.style1);
    Line2:setPrecision(math.max(2, source:getPrecision()));	
end

-- Indicator calculation routine
function Update(period, mode)

 
	if period <  first  
	then
	return;
	end
	 
    
	local min, max=mathex.minmax(source, period-1-Length+1, period-1);
    
	if source.close[period]> source.close[period-1] then
	Close[period]=1;
	else
	Close[period]=0;	
	end
	
	if source.high[period]> max then
	High[period]=1;
	else
	High[period]=0;	
	end	
	
	if period <  first +Length 
	then
	return;
	end
	
	local CountHigh=mathex.sum(High,period-Length+1, period );
	local CountClose=mathex.sum(Close,period-Length+1, period );
	
 
 

	local Ratio=0;
	
	if CountHigh~=0 then
	Ratio=CountHigh/CountClose; 
	end
	
    Line1[period]= Line1[period-1] + (sc * (Ratio - Line1[period-1]));
	
	if period <  first +Length *2
	then
	return;
	end
	
    Line2[period]=mathex.avg(Line1, period-Length+1, period);
	
end

 
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=70732

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+
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
    indicator:name("Trend Direction Force Index");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Length", "Length", "", 10, 1, 2000);
    indicator.parameters:addBoolean("Signal", "Signal Line", "", true);
  
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
local Length; 
local first;
local source = nil;
 
local Oscillator;  
local EMA1, EMA2;
-- Routine
 function Prepare(nameOnly)   
 
 
    Length= instance.parameters.Length;
	Signal= instance.parameters.Signal;
	
	
	local Parameters= Length;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source; 
	
	
	EMA1 = core.indicators:create("EMA", source, Length/2);
	EMA2 = core.indicators:create("EMA", EMA1.DATA, Length/2);
    first=EMA2.DATA:first();
	
	 Average= instance:addInternalStream(0, 0);
	 tdf= instance:addInternalStream(0, 0);
     tdfabs= instance:addInternalStream(0, 0);
 
    if Signal then
    tdfi= instance:addInternalStream(0, 0);
	Oscillator = instance:addStream("Oscillator" , core.Line, " Oscillator"," Oscillator",instance.parameters.color, first );
	Oscillator:setWidth(instance.parameters.width);
    Oscillator:setStyle(instance.parameters.style);
    Oscillator:setPrecision(math.max(2, source:getPrecision()));
	else
	
    Oscillator= instance:addInternalStream(0, 0);
	tdfi = instance:addStream("tdfi" , core.Line, " tdfi"," tdfi",instance.parameters.color, first );
	tdfi:setWidth(instance.parameters.width);
    tdfi:setStyle(instance.parameters.style);
    tdfi:setPrecision(math.max(2, source:getPrecision()));	
	end
	
	
end

-- Indicator calculation routine
function Update(period, mode)
  
  
    EMA1:update(mode);
	EMA2:update(mode);
	
 
	if period <= first
	then
	return;
	end
	
	
	local ema1Diff = EMA1.DATA[period] - EMA1.DATA[period-1];
	local ema2Diff = EMA2.DATA[period] - EMA2.DATA[period-1];
	local emaDiffAvg = (ema1Diff + ema2Diff) / 2;
	
	
	tdf[period] = math.abs(EMA1.DATA[period] - EMA2.DATA[period]) * math.pow(emaDiffAvg, 3);
	tdfabs[period]=math.abs(tdf[period]);
	
	if period <= Length * 3
	then
	return;
	end
	
	local tdfh = mathex.max( tdfabs, period-Length * 3+1, period)
	
 
	
	if tdfh~= 0 then
	tdfi[period]=tdf[period]/tdfh;
	else
	tdfi[period]=0;
	end
 
 
	 
	if tdfi[period] > 0 then	
    Oscillator[period ]= 1;
	else
	 Oscillator[period ]= -1;
    end	
end

--[[
ema1 = ema(src * 1000, length / 2)
ema2 = ema(ema1, length / 2)
ema1Diff = ema1 - ema1[1]
ema2Diff = ema2 - ema2[1]
emaDiffAvg = (ema1Diff + ema2Diff) / 2
tdf = abs(ema1 - ema2) * pow(emaDiffAvg, 3)
tdfh = highest(abs(tdf), length * 3)
tdfi = tdfh != 0 ? tdf / tdfh : 0
]]

 --+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+
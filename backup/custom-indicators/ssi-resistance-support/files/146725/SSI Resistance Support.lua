-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72492

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


function Init()
    indicator:name("SSI Resistance Support");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
    indicator.parameters:addGroup("Caluclation");	
    indicator.parameters:addInteger("Period", "MA Period","", 34);
 
	
	indicator.parameters:addString("Method", "Method", "Method" , "Lines");
    indicator.parameters:addStringAlternative("Method", "Lines", "Lines" , "Lines");
    indicator.parameters:addStringAlternative("Method", "Signals", "Signals" , "Signals");
	
	
    indicator.parameters:addGroup("Style");	

    indicator.parameters:addColor("color1", "Resistance Line Color", "", core.colors().Red); 
    indicator.parameters:addColor("color2", "Support Line Color", "", core.colors().Blue);	

    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);	
end

local source;
local ssi;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
	
 
    instance:name(name);
    if nameOnly then
        return ;
    end
	
	Period=instance.parameters.Period; 
	Method=instance.parameters.Method;


	assert(core.indicators:findIndicator("SSI") ~= nil, "Please, download and install SSI.BIN indicator"); 
	
    ssi = core.indicators:create("SSI", source, "SSI"); 
	
	if Method == "Lines" then
 	Resistance = instance:addStream("Resistance" , core.Line, " Resistance"," Resistance",instance.parameters.color1, source:first()); 
    Resistance:setPrecision(math.max(2, source:getPrecision()));
    Resistance:setWidth(instance.parameters.width);
    Resistance:setStyle(instance.parameters.style);	
	
	Support = instance:addStream("Support" , core.Line, " Support"," Support",instance.parameters.color2, source:first()); 
    Support:setPrecision(math.max(2, source:getPrecision()));
    Support:setWidth(instance.parameters.width);
    Support:setStyle(instance.parameters.style);		
 	else
 	Resistance = instance:addInternalStream(0, 0);
	Support  = instance:addInternalStream(0, 0);
    end
	
	SSI = instance:addInternalStream(0, 0);
	MA = instance:addInternalStream(0, 0); 
	
	if Method == "Signals" then
	Signal = instance:addStream("Signal" , core.Bar, " Signal"," Signal",instance.parameters.color1, source:first()); 
    Signal:setPrecision(math.max(2, source:getPrecision()));
	else
 	Signal = instance:addInternalStream(0, 0);	
	end
 
	
    core.host:execute ("setTimer", 3 , 3);
end

function Update(period, mode)
    ssi:update(mode); 
	
	if period < Period then
	return;
	end
	
    SSI[period]=ssi.DATA[period]
    MA[period]=mathex.avg(ssi.DATA, period- Period+1 , period)	
	
	Resistance[period]=Resistance[period-1];
	Support[period]=Support[period-1];

	
	if SSI[period] > MA[period] and SSI[period-1] <= MA[period-1] then
	Resistance[period]=source.high[period];
	elseif SSI[period] < MA[period] and SSI[period-1] >= MA[period-1] then
	Support[period]=source.low[period];
	end
	
 
	
	if source.close[period] > Resistance[period] 
	then
	Signal[period]=1;
	elseif source.close[period] < Support[period] 
	then
	Signal[period]=-1;	
	else
	Signal[period]=0;		
	end
	
	
	
	
	
end

function AsyncOperationFinished(cookie, successful, message )
    if cookie== 3 
	then
	 instance:updateFrom(0);  
	end
	
	    return core.ASYNC_REDRAW;
end
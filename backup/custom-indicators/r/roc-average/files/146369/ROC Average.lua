-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72385

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
    indicator:name("ROC Average");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
	
        indicator.parameters:addInteger("Period1" ,  "1.  ROC Periods", "", 10, 1, 300);
        indicator.parameters:addInteger("Period2" ,  "2.  ROC Periods", "", 15, 1, 300);
        indicator.parameters:addInteger("Period3" ,   "3.  ROC Periods", "", 20, 1, 300);
        indicator.parameters:addInteger("Period4",  "4.  ROC Periods", "", 30, 2, 300);		
         indicator.parameters:addInteger("Period5",  "Signal Periods", "", 9, 2, 300);		
		 
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrKST", "Oscillator Line Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthKST", "Oscillator Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleKST", "Oscillator Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleKST", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("clrSIG", "Signal Line Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("widthSIG", "Signal Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleSIG", "Signal Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleSIG", core.FLAG_LINE_STYLE);
 

end

 


local source;
local roc = {};
local mva; 

function Prepare(nameOnly)
    source = instance.source; 
    
    roc[1] = core.indicators:create("ROC", source,  instance.parameters.Period1);
    roc[2] = core.indicators:create("ROC", source,  instance.parameters.Period2);
    roc[3] = core.indicators:create("ROC", source,  instance.parameters.Period3);
    roc[4] = core.indicators:create("ROC", source,  instance.parameters.Period4);
	
	first=math.max(roc[1].DATA:first(),roc[2].DATA:first(),roc[3].DATA:first(),roc[4].DATA:first());
 
    local name = profile:id() .. ", " .. source:instrument();
    instance:name(name);
    if nameOnly then
        return;
    end
    kst = instance:addStream("KST", core.Line, name .. ".KST", "KST", instance.parameters.clrKST, first);
    kst:setPrecision(4);
    kst:addLevel(0, instance.parameters.styleLEV, instance.parameters.widthLEV, instance.parameters.clrLEV);
    kst:setWidth(instance.parameters.widthKST);
    kst:setStyle(instance.parameters.styleKST);

    mva  = core.indicators:create("MVA", kst,  instance.parameters.Period5); 
    signal = instance:addStream("SIG", core.Line, name .. ".SIG", "SIG", instance.parameters.clrSIG, mva.DATA:first());
    signal:setPrecision(math.max(2, instance.source:getPrecision()));
    signal:setWidth(instance.parameters.widthSIG);
    signal:setStyle(instance.parameters.styleSIG);
end

function Update(period, mode)
 
    for i = 1, 4, 1 do
        roc[i]:update(mode); 
    end
    if period <= first  then
	return;
	end
	
	
        kst[period] = (roc[1].DATA[period]  + roc[2].DATA[period]   +
                      roc[3].DATA[period]  + roc[4].DATA[period]) /4  ;
    
    
	mva:update(mode);
    if period <= mva.DATA:first() then
	return;
	end
        signal[period] = mva.DATA[period];
 
end






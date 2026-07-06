-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=73532

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
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

function Init()
    indicator:name("Tick Force Index");
    indicator:description("Dr. Alexander Elder's Force Index. The indicator combines price movements and volume to measure the strength of bulls and bears in the market.");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator); 
	
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addBoolean("SM", "Smooth", "Choose false to see the RAW Force Index value", true);
    indicator.parameters:addInteger("N", "Smoothing Periods", "", 13, 1, 1000);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255,0, 0));
    indicator.parameters:addInteger("widthFI", "Indicator Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleFI", "Indicator Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleFI", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addString("Method", "Presentation Method", "Method" , "Line");
    indicator.parameters:addStringAlternative("Method", "Line", "Line" , "Line");
    indicator.parameters:addStringAlternative("Method", "Channel", "Channel" , "Channel");
	indicator.parameters:addStringAlternative("Method", "Bar", "Bar" , "Bar");
	indicator.parameters:addInteger("transparency", "Channel transparency (%)", "", 70, 0, 100);
 
end

local source;
local first;
local first1;
local RawFI;
local FI;
local EMA;
local SM;
local Method;
local Zero;
function Prepare(nameOnly)
    source = instance.source;
    first1 = source:first() + 1;
    SM = instance.parameters.SM;
	Method= instance.parameters.Method; 

    local name;
    name = profile:id() .. "(" .. source:name() .. "," ;
    if SM then
        name = name .. "EMA(" .. instance.parameters.N .. "))";
    else
        name = name .. "RAW)";
    end
    instance:name(name);
    if nameOnly then
        return;
    end

    RawFI = instance:addInternalStream(first1, 0);
    if SM then
        EMA = core.indicators:create("EMA", RawFI, instance.parameters.N);
        first = EMA.DATA:first();
    else
        first = first1;
    end

	if Method=="Line" then 
    FI = instance:addStream("FI", core.Line, name, "FI", instance.parameters.Up, first);
	FI:setWidth(instance.parameters.widthFI);
    FI:setStyle(instance.parameters.styleFI);
	elseif Method=="Bar" then 
	FI = instance:addStream("FI", core.Bar, name, "FI", instance.parameters.Up, first);
	else
	FI = instance:addStream("FI", core.Line, name, "FI", instance.parameters.Up, first);
	Zero=  instance:addInternalStream(first, 0)
	instance:createChannelGroup("Channel", "Channel", FI, Zero, instance.parameters.Up, 100 - instance.parameters.transparency);

	end
	
    FI:setPrecision(5);

    FI:addLevel(0);
end

function Update(period, mode)
    if period >= first1 then
        RawFI[period] = (source[period] - source[period - 1]) ;
    end
	
	if Method=="Channel" then 
	Zero[period]=0;
	end

    if period < first then
	return;
	end
	
	
        if SM then
            EMA:update(mode);
            FI[period] = EMA.DATA[period];
        else
            FI[period] = RawFI[period];
        end
	if Method~="Line" then 
		if 	FI[period]>0 then
		FI:setColor(period, instance.parameters.Up);
		else
		FI:setColor(period, instance.parameters.Down);
		end
	end
     
end


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
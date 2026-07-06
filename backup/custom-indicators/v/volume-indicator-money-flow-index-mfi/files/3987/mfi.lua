-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1963

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

function Init()
    indicator:name("Money Flow Index");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Volume Indicators");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "Periods", "", 14, 1, 1000);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrMFI", "Indicator Line Color", "", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("widthMFI", "Indicator Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleMFI", "Indicator Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleMFI", core.FLAG_LINE_STYLE);
end

local source;
local N;
local first;
local first1;
local MFI;
local Prev;
local POS, NEG;

function Prepare(nameOnly)

      local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
    source = instance.source;
    N = instance.parameters.N;
    first = source:first() + N + 1;
    first1 = source:first() + 1;
    Prev = instance.parameters.Prev;

    assert(source:supportsVolume(), "The source must have volume");

     
    POS = instance:addInternalStream(0, 0);
    NEG = instance:addInternalStream(0, 0);
    MFI = instance:addStream("MFI", core.Line, name, "MFI", instance.parameters.clrMFI, first);
    MFI:setPrecision(2);
    MFI:setWidth(instance.parameters.widthMFI);
    MFI:setStyle(instance.parameters.styleMFI);
    MFI:addLevel(100);
    MFI:addLevel(80);
    MFI:addLevel(20);
    MFI:addLevel(0);
end

function Update(period, mode)
    POS[period] = 0;
    NEG[period] = 0;

    if period >= first1 then
        if source.typical[period] > source.typical[period - 1] then
            POS[period] = source.typical[period] * source.volume[period];
        elseif source.typical[period] < source.typical[period - 1] then
            NEG[period] = source.typical[period] * source.volume[period];
        end
    end

    if period >= first then
        local  a, b; 
        a = mathex.sum(POS, period-N+1, period);
        b = mathex.sum(NEG, period-N+1, period);
   
		
		 if b ~= 0 then          
		   MFI[period] = 100 - (100 / (1 +  a / b));
        else
            MFI[period]= 100;
        end
    end
end

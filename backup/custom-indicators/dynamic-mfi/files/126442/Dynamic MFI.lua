-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=68482

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |  
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

function Init()
    indicator:name("Dynamic Money Flow Index");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Volume Indicators");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "Periods", "", 14, 1, 1000);
	
	 indicator.parameters:addString("Type", "MFI Method", "Method" , "Regular");
    indicator.parameters:addStringAlternative("Type", "Regular", "Regular" , "Regular");
    indicator.parameters:addStringAlternative("Type", "Dynamic", "Dynamic" , "Dynamic");

	indicator.parameters:addGroup("Zone Calculation"); 
     indicator.parameters:addString("Method", "MA Method", "Method" , "WMA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
     indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
	
    indicator.parameters:addInteger("Period", "RSI Period ", "", 14, 1, 2000);
    indicator.parameters:addInteger("Lb", "LookBack Period ", "", 60, 1, 2000);
	
	indicator.parameters:addDouble("DZbuy", "Buy Zone Probability ", "", 0.1 );
	indicator.parameters:addDouble("DZsell", "Sell Zone Probability ", "", 0.1 );

    indicator.parameters:addGroup("MFI Style");
    indicator.parameters:addColor("clrMFI", "Indicator Line Color", "", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("widthMFI", "Indicator Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleMFI", "Indicator Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleMFI", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addGroup("Zone Style");
	
	indicator.parameters:addColor("color1", "Top Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_DOT );
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 1, 1, 5);
	
	indicator.parameters:addColor("color2", "Bottom Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_DOT );
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width2", "Line Width", "", 1, 1, 5);
	
	
	indicator.parameters:addColor("color3", "Cental Line Color", "", core.rgb(128, 128, 128));
	indicator.parameters:addInteger("style3", "Line Style", "", core.LINE_DOT );
    indicator.parameters:setFlag("style3", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width3", "Line Width", "", 1, 1, 5);
	
end

local source;
local N;
local first;
local first1;
local MFI;
local Prev;
local POS, NEG;
local Data;
local Lb, DZbuy, DZsell, Method,Period,Type;
local Range, Range;
local Central, Top,Bottom;

function Prepare(nameOnly)

      local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	Lb= instance.parameters.Lb;
	DZbuy= instance.parameters.DZbuy;
	DZsell= instance.parameters.DZsell;
    Method= instance.parameters.Method; 
	Period= instance.parameters.Period;
	Type= instance.parameters.Type;
	
	
    source = instance.source;
    N = instance.parameters.N;
    first = source:first() + N + 1;
    first1 = source:first() + 1;
    Prev = instance.parameters.Prev; 

    assert(source:supportsVolume(), "The source must have volume");

     
    POS = instance:addInternalStream(0, 0);
    NEG = instance:addInternalStream(0, 0);
	Data = instance:addInternalStream(0, 0);
	Range = instance:addInternalStream(0, 0);
	Low = instance:addInternalStream(0, 0);
	
	
	assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
	MA1= core.indicators:create(Method, Low, Period);
	MA2= core.indicators:create(Method, Range, Period);
	
    MFI = instance:addStream("MFI", core.Line, name, "MFI", instance.parameters.clrMFI, first);
    MFI:setPrecision(2);
    MFI:setWidth(instance.parameters.widthMFI);
    MFI:setStyle(instance.parameters.styleMFI);
    MFI:addLevel(100);
    MFI:addLevel(80);
    MFI:addLevel(20);
    MFI:addLevel(0);
	
	Central = instance:addStream("Central" , core.Line, "Central","Central",instance.parameters.color3, first);
	Central:setWidth(instance.parameters.width3);
    Central:setStyle(instance.parameters.style3);
    Central:setPrecision(math.max(2, source:getPrecision()));
	 
	
	
	Top = instance:addStream("Top" , core.Line, "Top","Top",instance.parameters.color1, first);
	Top:setWidth(instance.parameters.width1);
    Top:setStyle(instance.parameters.style1);
    Top:setPrecision(math.max(2, source:getPrecision()));
	
	Bottom = instance:addStream("Bottom" , core.Line, "Bottom","Bottom",instance.parameters.color2, first);
	Bottom:setWidth(instance.parameters.width2);
    Bottom:setStyle(instance.parameters.style2);
    Bottom:setPrecision(math.max(2, source:getPrecision()));
end

function Update(period, mode)
    POS[period] = 0;
    NEG[period] = 0;

    if period < first1 then
	return;
	end
	
        if source.typical[period] > source.typical[period - 1] then
            POS[period] = source.typical[period] * source.volume[period];
        elseif source.typical[period] < source.typical[period - 1] then
            NEG[period] = source.typical[period] * source.volume[period];
        end
 

    if period < first then
	return;
	end
	
        local  a, b; 
        a = mathex.sum(POS, period-N+1, period);
        b = mathex.sum(NEG, period-N+1, period);
   
		
		 if b ~= 0 then          
		    Data[period] = 100 - (100 / (1 +  a / b));
        else
            Data[period]= 100;
        end
    
	
	--//////////////////////////////////////////////////////////////////////////////////
	
	
	
	if period < first + Lb  then
	return;
	end 
	
	local min,max= mathex.minmax(Data , period-Lb+1, period );
    Range[period]=max-min;
	Low[period]=min;
	
	
	MA1:update(mode);
	MA2:update(mode);
	
	if period < first + Lb +Period then
	return;
	end 
	
   
		
    Central[period] = (MA2.DATA[period]*0.50)+MA1.DATA[period];
    Top[period] = max-Central[period]*DZbuy;
    Bottom[period] = min+Central[period]*DZsell;
	
    if Type == "Regular" then
	 MFI[period] =  Data[period] 	;
    else	
    MFI[period] =  ( 4 * Data[period] + 3 * Data[period-1] + 2 * Data[period-2] + Data[period-3] ) / 10	;
	end
    
	local R,G,B=0,0,0;
	
	if MFI[period] > Central[period] then 
	 R=0
	 G=255
	else
	 R=255
	 G=0
	end 
	
	MFI:setColor(period, core.rgb(R, G, B));
	
end

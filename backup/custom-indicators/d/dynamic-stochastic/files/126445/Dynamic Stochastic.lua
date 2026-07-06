-- Id: 25045
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=68483

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
    indicator:name("Dynamic Stochastic");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
 

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("K", "%K Period", "", 5, 2, 1000)
    indicator.parameters:addInteger("SD", "%D slowing periods", "", 3, 1, 1000)
    indicator.parameters:addInteger("D", "%D Period", "", 3, 1, 1000)

    indicator.parameters:addString("A1", "Smoothing method for %K", "", "MVA")
    indicator.parameters:addStringAlternative("A1", "MVA", "", "MVA")
    indicator.parameters:addStringAlternative("A1", "EMA", "", "EMA")
    indicator.parameters:addStringAlternative("A1", "MetaTrader", "", "FS")

    indicator.parameters:addString("A2", "Smoothing method for %D", "", "MVA")
    indicator.parameters:addStringAlternative("A2", "MVA", "", "MVA")
    indicator.parameters:addStringAlternative("A2", "EMA", "", "EMA")
	
	
	 
	
	
	 indicator.parameters:addString("Type", "Stochastic Method", "Method" , "Regular");
    indicator.parameters:addStringAlternative("Type", "Regular", "Regular" , "Regular");
    indicator.parameters:addStringAlternative("Type", "Dynamic", "Dynamic" , "Dynamic");
	
	indicator.parameters:addString("TypeD", "Stochastic D Method", "Method" , "Regular");
    indicator.parameters:addStringAlternative("TypeD", "Regular", "Regular" , "Regular");
    indicator.parameters:addStringAlternative("TypeD", "Dynamic", "Dynamic" , "Dynamic");
	 indicator.parameters:addStringAlternative("TypeD", "Average of K", "Average of K" , "Average of K");

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

    indicator.parameters:addGroup("Line Style");
    indicator.parameters:addColor("clrK", "K Line Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("widthK", "Indicator Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleK", "Indicator Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleK", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addColor("clrD", "D Line Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthD", "Indicator Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleD", "Indicator Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleD", core.FLAG_LINE_STYLE);
	
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
	
	indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("L1", "Overbought Level","", 80);
    indicator.parameters:addDouble("L2","Oversold Level","", 20);
		
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
	
end

local source;
local K, SD, D, A1, A2,Indicator;
local first;
local first1;
local MFI;
 
local POS, NEG;
local DataK,DataD;
local Lb, DZbuy, DZsell, Method,Period,Type;
local Range, Range;
local Central, Top,Bottom;
local TypeD;
local D_Indicator;
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
	TypeD= instance.parameters.TypeD; 
	
	
    source = instance.source;
    
	K= instance.parameters.K;
	SD= instance.parameters.SD;
	D= instance.parameters.D;
	A1= instance.parameters.A1;
	A2= instance.parameters.A2;
	
    Indicator= core.indicators:create("STOCHASTIC", source, K, SD, D, A1, A2);
	first=Indicator.DATA:first();
     

	DataK = instance:addInternalStream(0, 0);
	DataD = instance:addInternalStream(0, 0);
	Range = instance:addInternalStream(0, 0);
	Low = instance:addInternalStream(0, 0);
	
	
	assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
	MA1= core.indicators:create(Method, Low, Period);
	MA2= core.indicators:create(Method, Range, Period);
	
    K_Line = instance:addStream("K", core.Line, name, "K", instance.parameters.clrK, first);
    K_Line:setPrecision(math.max(2, instance.source:getPrecision()));
    K_Line:setWidth(instance.parameters.widthK);
    K_Line:setStyle(instance.parameters.styleK);
	
    assert(core.indicators:findIndicator(A2) ~= nil, A2 .. " indicator must be installed");
	D_Indicator= core.indicators:create(A2, K_Line, D);
	
	
	D_Line = instance:addStream("D", core.Line, name, "D ", instance.parameters.clrD , first);
    D_Line:setPrecision(math.max(2, instance.source:getPrecision()));
    D_Line :setPrecision(math.max(2, instance.source:getPrecision()));
    D_Line :setWidth(instance.parameters.widthD );
    D_Line :setStyle(instance.parameters.styleD );
    
	K_Line:addLevel(instance.parameters.L1, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	K_Line:addLevel(instance.parameters.L2, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color); 
    K_Line:addLevel(50, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color); 	
 
	
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
 
    
	Indicator:update(mode);
	
	if period < Indicator.D:first() then
	return;
	end
	
	DataK[period]= Indicator.K[period];
	DataD[period]= Indicator.D[period];
	--//////////////////////////////////////////////////////////////////////////////////
	
	
	
	if period < first + Lb  then
	return;
	end 
	
	local min,max= mathex.minmax(DataK , period-Lb+1, period );
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
	 K_Line[period] =  DataK[period] 	;
    else	
    K_Line[period] =  ( 4 * DataK[period] + 3 * DataK[period-1] + 2 * DataK[period-2] + DataK[period-3] ) / 10	;
	end
	
	
	 if TypeD == "Regular" then
	 D_Line[period] =  DataD[period] 	;
     elseif TypeD == "Dynamic" then	
	  D_Line[period] =  ( 4 * DataD[period] + 3 * DataD[period-1] + 2 * DataD[period-2] + DataD[period-3] ) / 10	;
	 else
	 
	  D_Indicator:update(mode);
	  if period > D_Indicator.DATA:first() then
	  D_Line[period] =  D_Indicator.DATA[period]	;	 
	  end
    
	 end
    
	local R,G,B=0,0,0;
	
	if K_Line[period] > Central[period] then 
	 R=0
	 G=255
	else
	 R=255
	 G=0
	end 
	
	K_Line:setColor(period, core.rgb(R, G, B));
	
end

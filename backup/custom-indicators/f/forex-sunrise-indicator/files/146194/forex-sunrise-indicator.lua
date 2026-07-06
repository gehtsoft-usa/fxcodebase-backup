-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72274

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

function Init()
    indicator:name("Forex-sunrise-indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("MA Calculation"); 
    indicator.parameters:addInteger("G_period_100", "Period", "", 30, 1, 2000);
    indicator.parameters:addInteger("Gi_124", "Period in Minutes", "", 1080, 1, 2000);	
    indicator.parameters:addDouble("Delta", "Delta in Pips", "", 10, 1, 20000000);		
 
	
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
     indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
    indicator.parameters:addGroup("Arrow Style"); 	 
	indicator.parameters:addInteger("Size", "Arrow Size", "", 20);
    indicator.parameters:addColor("Up", "Up Arrow Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Down", "Down Arrow Color", "", core.rgb(255, 0, 0));
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Method, G_period_100,Gi_124,Li_8,Delta;  
local first;
local source = nil;
 
local Line={};
local Indicator;

local Gi_176 = 10;
local Gi_180 = 10;
-- Routine
 function Prepare(nameOnly)   
 
 
    source = instance.source;

 
    Delta= instance.parameters.Delta;
    G_period_100= instance.parameters.G_period_100;
	Gi_124= instance.parameters.Gi_124;
    Method = instance.parameters.Method;
	Size = instance.parameters.Size;
	
	
	
	local s, e = core.getcandle(source:barSize(), 0, 0, 0);
	local ThePeriod=(e-s)* 1440;
	Li_8 = math.floor(Gi_124 / ThePeriod); 
	
	
	local Parameters= G_period_100 ..  ", " .. Method;
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
    Signal = instance:addInternalStream(0, 0);
    
  
    Indicator= core.indicators:create(Method, source.close , G_period_100); 
    
    first=Indicator.DATA:first()+Li_8;
	
	 
   
 
 
    for i= 1, 4 , 1 do
	Line[i] = instance:addStream("Line"..i , core.Line, i.. ". Line", i.. ". Line",instance.parameters.color, first);
	Line[i]:setWidth(instance.parameters.width);
    Line[i]:setStyle(instance.parameters.style);
    Line[i]:setPrecision(math.max(2, source:getPrecision()));
    end
 
    font = core.host:execute("createFont", "Wingdings", Size, false, false);

	
end

-- Indicator calculation routine
function Update(period, mode)

 
 
    Indicator:update(mode); 
	
	
    if period <= first  
	then
	return;
	end
	
	Signal[period]=Signal[period-1];
	
	local TheDelta=math.abs(Indicator.DATA[period]-Indicator.DATA[period-1])/source:pipSize();
 
    if TheDelta > Delta
	and Indicator.DATA[period]> Indicator.DATA[period-1]
	then
    Signal[period]=1;
    elseif TheDelta > Delta
    and Indicator.DATA[period]< Indicator.DATA[period-1]	
	then 
	Signal[period]=-1;	
	end
	
    if period < source:size()-1
	then
	return;
	end
	
    local Gd_136,Gd_128= mathex.minmax(source, period-Li_8+1 ,period)
 
	  
    local   Ld_32 = (Gd_128 - Gd_136) / 100.0;
    local   G_price_144 = Gd_128 + Gi_176 * Ld_32;
    local   G_price_152 = Gd_128 - Gi_176 * Ld_32;
    local   G_price_160 = Gd_136 + Gi_180 * Ld_32;
    local   G_price_168 = Gd_136 - Gi_180 * Ld_32;
	  
	  
  
	  core.drawLine(Line[1], core.range(first, period), G_price_144, first, G_price_144, period, instance.parameters.color)
	  core.drawLine(Line[2], core.range(first, period), G_price_152, first, G_price_152, period, instance.parameters.color)
	  core.drawLine(Line[3], core.range(first, period), G_price_160, first, G_price_160, period, instance.parameters.color)
	  core.drawLine(Line[4], core.range(first, period), G_price_168, first, G_price_168, period, instance.parameters.color)	  
	  
	  
 
	if Signal[period] == 1 then
	core.host:execute("drawLabel1",  1 , source:date(period), core.CR_CHART, G_price_160 , core.CR_CHART, core.H_Center, core.V_Bottom, font, instance.parameters.Up, "\225");
    elseif Signal[period] == -1 then 
    core.host:execute("drawLabel1",  1 , source:date(period), core.CR_CHART,  G_price_152, core.CR_CHART, core.H_Center, core.V_Top, font, instance.parameters.Down, "\226");
    else
	core.host:execute ("removeLabel", 1)
	end
	  
end

function ReleaseInstance()
       core.host:execute("deleteFont", font); 
end
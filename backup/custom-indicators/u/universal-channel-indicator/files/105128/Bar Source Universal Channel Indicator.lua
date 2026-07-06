-- Id: 15646
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63219

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

-- initializes the indicator
function Init()
    -- indicator:fail()
    indicator:name("Universal Channel Indicator")
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	
	 indicator.parameters:addGroup("Selector");
	
	indicator.parameters:addString("Method", "Method", "Method" , "Donchian");
    indicator.parameters:addStringAlternative("Method", "Donchian", "Donchian" , "Donchian");
    indicator.parameters:addStringAlternative("Method", "Pip", "Pip" , "Pip");
	indicator.parameters:addStringAlternative("Method", "Deviation", "Deviation" , "Deviation");
 
	
	indicator.parameters:addString("SM", "Show middle line", "", "no");
    indicator.parameters:addStringAlternative("SM", "no", "", "no");
    indicator.parameters:addStringAlternative("SM", "yes", "", "yes");
	indicator.parameters:addString("SC", "Show Channel line", "", "yes");
    indicator.parameters:addStringAlternative("SC", "no", "", "no");
    indicator.parameters:addStringAlternative("SC", "yes", "", "yes");
	
	indicator.parameters:addGroup("Donchian Channel");
    indicator.parameters:addInteger("Donchian_Period1", "1. Channel Period", "", 10, 2, 10000);
	indicator.parameters:addInteger("Donchian_Period2", "2. Channel Period", "", 20, 2, 10000);
	indicator.parameters:addInteger("Donchian_Period3", "3. Channel Period", "", 40, 2, 10000);	

	indicator.parameters:addString("Mode", "(High-Low)/Close ", "Method" , "High/Low");
    indicator.parameters:addStringAlternative("Mode", "High/Low", "High/Low" , "High/Low");
    indicator.parameters:addStringAlternative("Mode", "Close", "Close" , "Close");
	
	indicator.parameters:addGroup("Central Line MA");
	indicator.parameters:addInteger("MA_Period1", "1. MA Period", "Period" , 10);
	indicator.parameters:addString("MA_Method1", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("MA_Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("MA_Method1", "EMA", "EMA" , "EMA");
   indicator.parameters:addStringAlternative("MA_Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("MA_Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("MA_Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("MA_Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("MA_Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("MA_Method1", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addInteger("MA_Period2", "2. MA Period", "Period" , 20);
	indicator.parameters:addString("MA_Method2", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("MA_Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("MA_Method2", "EMA", "EMA" , "EMA");
   indicator.parameters:addStringAlternative("MA_Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("MA_Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("MA_Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("MA_Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("MA_Method2", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("MA_Method2", "WMA", "WMA" , "WMA");
	
	
	indicator.parameters:addInteger("MA_Period3", "3. MA Period", "Period" , 40);
	indicator.parameters:addString("MA_Method3", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("MA_Method3", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("MA_Method3", "EMA", "EMA" , "EMA");
   indicator.parameters:addStringAlternative("MA_Method3", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("MA_Method3", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("MA_Method3", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("MA_Method3", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("MA_Method3", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("MA_Method3", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addGroup("Pip Channel");
    indicator.parameters:addDouble("Pip1", "1. Channel Delta", "", 10, 0, 10000);
	indicator.parameters:addDouble("Pip2", "2. Channel Delta", "", 20, 0, 10000);
	indicator.parameters:addDouble("Pip3", "3. Channel Delta", "", 40, 0, 10000);
	
	
	indicator.parameters:addGroup("Deviation Channel");
	indicator.parameters:addInteger("Dev1", "1. Deviation Period", "", 10, 0, 10000);
	indicator.parameters:addDouble("Multi1", "1. Deviation Multiplier", "", 1, 0, 10000);
	indicator.parameters:addInteger("Dev2", "2. Deviation Period", "", 20, 0, 10000);
	indicator.parameters:addDouble("Multi2", "2. Deviation Multiplier", "", 2, 0, 10000);
	indicator.parameters:addInteger("Dev3", "3. Deviation Period", "", 40, 0, 10000);
	indicator.parameters:addDouble("Multi3", "3. Deviation Multiplier", "", 3, 0, 10000);
	
    indicator.parameters:addString("AC", "Analyze the current period", "", "yes");
    indicator.parameters:addStringAlternative("AC", "no", "", "no");
    indicator.parameters:addStringAlternative("AC", "yes", "", "yes");
		
	
    
	indicator.parameters:addGroup("Style");
	indicator.parameters:addInteger("width1", "Top Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Top Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    
	indicator.parameters:addInteger("width2", "Bottom Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Bottom Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
    
	indicator.parameters:addInteger("width3", "Central Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Central Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("Color1", "Color of Outer Channel", "", core.rgb(0, 0, 255));
	indicator.parameters:addColor("Color2", "Color of Outer Channel", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Color3", "Color of Outer Channel", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("clrDM", "Color of the middle line", "", core.rgb(128, 128, 128));
  

end
local Multi={};
local Dev={};
local first={};
local Donchian_Period={};
local ac;
local sm;
local sc;
local source = nil;
local dn = {};
local du = {};
local dm = {};
local FIRST;
local Color={};
local Method;
local Pip={};
local MA={};
local MA_Period={};
local MA_Method={};
local Mode;
-- initializes the instance of the indicator
function Prepare(nameOnly)
    source = instance.source;
	Method = instance.parameters.Method;
	
	Mode = instance.parameters.Mode;
	
    Donchian_Period[1] = instance.parameters.Donchian_Period1;
	Donchian_Period[2] = instance.parameters.Donchian_Period2;
	Donchian_Period[3] = instance.parameters.Donchian_Period3;
	
	Dev[1] = instance.parameters.Dev1;
	Dev[2] = instance.parameters.Dev2;
	Dev[3] = instance.parameters.Dev3;
	
	Multi[1] = instance.parameters.Multi1;
	Multi[2] = instance.parameters.Multi2;
	Multi[3] = instance.parameters.Multi3;
	
	  Donchian_Period[1] = instance.parameters.Donchian_Period1;
	Donchian_Period[2] = instance.parameters.Donchian_Period2;
	Donchian_Period[3] = instance.parameters.Donchian_Period3;
	
	Pip[1] = instance.parameters.Pip1;
	Pip[2] = instance.parameters.Pip2;
	Pip[3] = instance.parameters.Pip3;
	Color[1] = instance.parameters.Color1;
	Color[2] = instance.parameters.Color2;
	Color[3] = instance.parameters.Color3;
	MA_Period[1] = instance.parameters.MA_Period1;
	MA_Method[1] = instance.parameters.MA_Method1;
	MA_Period[2] = instance.parameters.MA_Period2;
	MA_Method[2] = instance.parameters.MA_Method2;
	MA_Period[3] = instance.parameters.MA_Period3;
	MA_Method[3] = instance.parameters.MA_Method3;

    ac = (instance.parameters.AC == "yes");
    sm = (instance.parameters.SM == "yes");
    sc = (instance.parameters.SC == "yes");
	
	
    local name = profile:id() .. "(" .. source:name() .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	if Method == "Donchian" then
	FIRST=source:first() +math.max(Donchian_Period[1],Donchian_Period[2],Donchian_Period[3]);
	elseif Method == "Pip" then
	for i= 1, 3, 1 do
    assert(core.indicators:findIndicator(MA_Method[i]) ~= nil, MA_Method[i] .. " indicator must be installed");
	MA[i] = core.indicators:create(MA_Method[i], source.close, MA_Period[i]);	
	end
	FIRST=math.max(MA[1].DATA:first(),MA[2].DATA:first(),MA[3].DATA:first());
	elseif Method == "Deviation" then
	for i= 1, 3, 1 do
	MA[i] = core.indicators:create(MA_Method[i], source.close, MA_Period[i]);	
	end
	FIRST=math.max(MA[1].DATA:first(),MA[2].DATA:first(),MA[3].DATA:first())+math.max(Dev[1],Dev[2],Dev[3]);
	end
	
    
    for i = 1, 3, 1 do
	if sc then 
	dn[i] = instance:addStream("Top"..i, core.Line, name .. ".Top", "Top", Color[i],  FIRST)
	dn[i]:setWidth(instance.parameters.width2);
    dn[i]:setStyle(instance.parameters.style2);
    du[i] = instance:addStream("Bottom"..i, core.Line, name .. ".Bottom", "Bottom", Color[i],  FIRST)
	du[i]:setWidth(instance.parameters.width1);
    du[i]:setStyle(instance.parameters.style1);
	else
	dn[i]= instance:addInternalStream(0, 0);
	du[i]= instance:addInternalStream(0, 0);
	end
    if (sm) then
        dm[i] = instance:addStream("Middle"..i, core.Line, name .. ".Middle", "Middle", Color[i],  FIRST)
		dm[i]:setWidth(instance.parameters.width3);
        dm[i]:setStyle(instance.parameters.style3);
	else
        dm[i]= instance:addInternalStream(0, 0);   	
    end
	
	end
end

-- calculate the value
function Update(period,mode)

   
	for i= 1, 3, 1 do 
		if Method == "Pip" or  Method == "Deviation" then
		MA[i]:update(mode);
		end
	end
  	
    if (period < FIRST) then
	return;
	end
	
	
	for i = 1, 3 do
	
        	if Method == "Donchian" then
				if (ac) then
				    if Mode== "Close" then
					du[i][period] =  mathex.max (source.close, period -Donchian_Period[i] +1  , period);
					dn[i][period] = mathex.min (source.close, period -Donchian_Period[i] +1  , period);
					else
					du[i][period] =  mathex.max (source.high, period -Donchian_Period[i] +1  , period);
					dn[i][period] = mathex.min (source.low, period -Donchian_Period[i] +1  , period);
					end
				else  
				     if Mode== "Close" then
					  du[i][period] =  mathex.max (source.close, period -Donchian_Period[i] +1-1  , period-1);
					 dn[i][period] = mathex.min (source.close, period -Donchian_Period[i] +1-1  , period-1);
					 else
					 du[i][period] =  mathex.max (source.high, period -Donchian_Period[i] +1-1  , period-1);
					 dn[i][period] = mathex.min (source.low, period -Donchian_Period[i] +1-1  , period-1);
					 end
				end
				
				dm[i][period] = (du[i][period] + dn[i][period]) / 2;
				
			elseif Method == "Pip" then
			    if (ac) then
					du[i][period] =  MA[i].DATA[period]+Pip[i]*source:pipSize();
					dn[i][period] =  MA[i].DATA[period]-Pip[i]*source:pipSize();
				else
					 du[i][period] =   MA[i].DATA[period-1]+Pip[i]*source:pipSize();
					 dn[i][period] =  MA[i].DATA[period-1]-Pip[i]*source:pipSize();
				end
				
			   dm[i][period] = MA[i].DATA[period];
			 elseif Method == "Deviation" then
			 
			 			    
			    if (ac) then
				    iDev=mathex.stdev(source.close, period-Dev[i]+1, period);
					du[i][period] =  MA[i].DATA[period]+Multi[i]*iDev;
					dn[i][period] =  MA[i].DATA[period]-Multi[i]*iDev;
				else 
				     iDev=mathex.stdev(source.close, period-1-Dev[i]+1, period-1);
					 du[i][period] =   MA[i].DATA[period-1]+Multi[i]*iDev;
					 dn[i][period] =  MA[i].DATA[period-1]-Multi[i]*iDev;
				end
				
			   dm[i][period] = MA[i].DATA[period];  
			end	 
					
					
			 
        
    
	end
end


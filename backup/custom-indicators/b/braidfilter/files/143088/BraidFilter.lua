-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71395

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

--+------------------------------------------------------------------------------------------------+
--|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |
--|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C                                 |
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |                                                  |   
--+------------------------------------------------------------------------------------------------+


-- Indicator profile initialization routine

function Init()
    indicator:name("BraidFilter");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
	
	indicator.parameters:addInteger("PipsMinSepPercent", "PipsMinSepPercent", "", 50, 1, 2000);
	
	indicator.parameters:addString("MaType", "MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("MaType", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("MaType", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("MaType", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("MaType", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("MaType", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("MaType", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("MaType", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("MaType", "WMA", "WMA" , "WMA");
    indicator.parameters:addStringAlternative("MaType", "ILSMA", "ILSMA" , "ILSMA");	
	
	
    indicator.parameters:addInteger("Period1", "1. Period", "", 5, 1, 2000);
    indicator.parameters:addInteger("Period2", "2. Period", "", 8, 1, 2000);	
    indicator.parameters:addInteger("Period3", "3. Period", "", 20, 1, 2000);
 
 
	
	indicator.parameters:addGroup("Filter Line Style"); 	
    indicator.parameters:addColor("color1", "Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 3, 1, 5);


	indicator.parameters:addGroup("Cross Line Style"); 	
    indicator.parameters:addColor("color2", "Up Line Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("color3", "Down Line Color", "", core.rgb(255, 0, 0));	
	indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width2", "Line Width", "", 3, 1, 5);	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
local Period1,Period2,Period3,PipsMinSepPercent,MaType; 
local first;
local source = nil;
 
local Cross,Filter ;
local fastMA, slowMA; 
local Ema5, Ema8, Ema20;
-- Routine
 function Prepare(nameOnly)   
 
 
    Period1= instance.parameters.Period1;
    Period2= instance.parameters.Period2;
	Period3= instance.parameters.Period3;
	MaType= instance.parameters.MaType;
	PipsMinSepPercent= instance.parameters.PipsMinSepPercent;
	
	
	local Parameters= PipsMinSepPercent..", "..MaType..", ".. Period1..", "..Period2..", "..Period3;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
   
    assert(core.indicators:findIndicator(MaType) ~= nil, "Please, download and install " .. MaType .. ".LUA indicator");			
    source = instance.source; 
	

   
    ATR = core.indicators:create("ATR", source, 14);
	
	
	fastMA = core.indicators:create(MaType, source.close, Period1); 
    slowMA = core.indicators:create(MaType, source.open, Period2);  
    Ema20 = core.indicators:create(MaType, source.close, Period3); 
	
    first=math.max(ATR.DATA:first(),fastMA.DATA:first(),slowMA.DATA:first(),Ema20.DATA:first()) ;
	
	Ema5= instance:addInternalStream(0, 0);
	Ema8= instance:addInternalStream(0, 0); 	
 
	Filter = instance:addStream("Filter" , core.Line, " Filter"," Filter",instance.parameters.color1, first);
	Filter:setWidth(instance.parameters.width1);
    Filter:setStyle(instance.parameters.style1);
    Filter:setPrecision(math.max(2, source:getPrecision()));

	Cross = instance:addStream("Cross" , core.Line, " Cross"," Cross",instance.parameters.color2, first);
	Cross:setWidth(instance.parameters.width2);
    Cross:setStyle(instance.parameters.style2);
    Cross:setPrecision(math.max(2, source:getPrecision()));	
	
end

-- Indicator calculation routine
function Update(period, mode)


    ATR:update(mode);
    fastMA:update(mode);
    slowMA:update(mode);
    Ema20:update(mode);
	
	if period < first
	then
	return;
	end
	
      Ema5[period] = fastMA.DATA[period];
      Ema8[period] = slowMA.DATA[period];

      Filter[period] =ATR.DATA[period]*PipsMinSepPercent/100.0;
      
      if ((fastMA.DATA[period] > slowMA.DATA[period])) then
        Cross:setColor(period, instance.parameters.color2);
        Cross[period] = GetDif(period);
    
      elseif ((fastMA.DATA[period] < slowMA.DATA[period])) then
        Cross:setColor(period, instance.parameters.color3);     
        Cross[period] = GetDif(period);
      end
  
				  
end
function GetDif (period)
 

  local ma5 = Ema5[period];
  local ma8 = Ema8[period];
  local ma20 = Ema20.DATA[period];
  local max, min;
  
  local  dif;
  
  max = math.max(ma5, ma8);
  max = math.max(max, ma20);
  min = math.min(ma5, ma8);
  min = math.min( min, ma20);
  
  dif = max - min;
  return(dif);
end


-- Id: 24853
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=68394

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


-- Indicator profile initialization routine

function Init()
    indicator:name("UNIVERSAL CHANNEL OSCILLATOR");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("UniversalPeriod", "Period", "", 14, 2, 2000);
	 indicator.parameters:addInteger("UNIVERSALFILTER", "UNIVERSAL FILTER", "", 14, 2, 2000);
    indicator.parameters:addDouble("OVERBOUGHT", "OVERBOUGHT", "", 1.5);
	 indicator.parameters:addDouble("OVERSOLD", "OVERSOLD", "", 1.5);
	 indicator.parameters:addInteger("UniAvgPeriod", "UniAvgPeriod", "", 14);
	 
	  indicator.parameters:addInteger("AveragePeriod", "AveragePeriod", "", 14);
	  indicator.parameters:addInteger("ATRperiod", "ATRperiod", "", 14);
   indicator.parameters:addInteger("TightenChannel", "TightenChannel", "", 14);
	
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
     indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
  
  
  indicator.parameters:addInteger("Transparency", "Transparency", "", 40,0,100);
	
	indicator.parameters:addGroup("1. Line Style"); 	
    indicator.parameters:addColor("color1", "Line Color", "", core.rgb(0,0,0));
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 1, 1, 5);
	
	indicator.parameters:addGroup("2. Line Style"); 	
    indicator.parameters:addColor("color2", "Line Color", "", core.rgb(0,0,0));
	indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width2", "Line Width", "", 1, 1, 5);
	
	indicator.parameters:addGroup("3. Line Style"); 	
    indicator.parameters:addColor("color3", "Line Color", "", core.rgb(0,0,0));
	indicator.parameters:addInteger("style3", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width3", "Line Width", "", 1, 1, 5);
	
	indicator.parameters:addGroup("4. Line Style"); 	
    indicator.parameters:addColor("color4", "Line Color", "", core.rgb(0,130,250));
	indicator.parameters:addInteger("style4", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style4", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width4", "Line Width", "", 1, 1, 5);
	
	
	indicator.parameters:addGroup("5. Line Style"); 	
    indicator.parameters:addColor("color5", "Line Color", "", core.rgb(128, 128,128));
	indicator.parameters:addInteger("style5", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style5", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width5", "Line Width", "", 1, 1, 5);
	
	
	indicator.parameters:addGroup("6. Line Style"); 	
    indicator.parameters:addColor("color6", "Line Color", "", core.rgb(128, 128,128));
	indicator.parameters:addInteger("style6", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style6", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width6", "Line Width", "", 1, 1, 5);
	
	indicator.parameters:addGroup("7. Line Style"); 	
    indicator.parameters:addColor("color7", "Line Color", "", core.rgb(250,150,0));
	indicator.parameters:addInteger("style7", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style7", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width7", "Line Width", "", 1, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local UniversalPeriod;
local first;
local source = nil;
local UniAvgPeriod; 
local Oscillator;  
local Indicator={};
local a1, b1, c2, c3, c1;
local whitenoise,filt,pk,result;
local UNIVERSALFILTER;
local OVERBOUGHT, OVERSOLD;
local Buffer1,Buffer2,Buffer3,Buffer4,Buffer5,Buffer6;
local UniAvgline;
local Method;
local AveragePeriod,ATRperiod;
local TightenChannel;
local Transparency;
-- Routine
 function Prepare(nameOnly)    
    UniversalPeriod= instance.parameters.UniversalPeriod;
	UNIVERSALFILTER= instance.parameters.UNIVERSALFILTER;
	OVERBOUGHT= instance.parameters.OVERBOUGHT;
	OVERSOLD= instance.parameters.OVERSOLD;
	UniAvgPeriod= instance.parameters.UniAvgPeriod;
	Method= instance.parameters.Method;
	AveragePeriod= instance.parameters.AveragePeriod;
	ATRperiod= instance.parameters.ATRperiod;
	TightenChannel= instance.parameters.TightenChannel;
	
	Transparency= instance.parameters.Transparency;
   Transparency= 100-Transparency;
   
	 a1= math.exp(-1.414 * 3.14159 / UniversalPeriod);
	 b1= 2*a1 * math.cos(1.414*180 /UniversalPeriod);
	 c2= b1;
	 c3= -a1 * a1;
	 c1= 1 - c2 - c3;
	
	local Parameters= UniversalPeriod..", "..UNIVERSALFILTER..", "..OVERBOUGHT   ..", ".. OVERSOLD  ..", ".. UniAvgPeriod  ..", ".. AveragePeriod  ..", ".. Method ..", ".. ATRperiod ..", ".. TightenChannel;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source;
    first=source:first()+math.min(UniversalPeriod,UNIVERSALFILTER);
  
  
     
    
    whitenoise = instance:addInternalStream(0, 0);
	filt= instance:addInternalStream(0, 0);
	pk= instance:addInternalStream(0, 0);
    result= instance:addInternalStream(0, 0);
 
 
    
	
	Buffer1	= instance:addStream("Buffer1" , core.Line, " 0 level"," 0 level",instance.parameters.color1, first);
	Buffer1:setPrecision(math.max(2, source:getPrecision()));
	Buffer1:setWidth(instance.parameters.width1);
    Buffer1:setStyle(instance.parameters.style1);
	
	Buffer2 = instance:addStream("Buffer2" , core.Line, " overbought level"," overbought level",instance.parameters.color2, first);
	Buffer2:setPrecision(math.max(2, source:getPrecision()));
	Buffer2:setWidth(instance.parameters.width2);
    Buffer2:setStyle(instance.parameters.style2);
	
	Buffer3 = instance:addStream("Buffer3" , core.Line, " oversold level"," oversold level",instance.parameters.color3, first);
	Buffer3:setPrecision(math.max(2, source:getPrecision()));
	Buffer3:setWidth(instance.parameters.width3);
    Buffer3:setStyle(instance.parameters.style3);
	
	Buffer4 = instance:addStream("Buffer4" , core.Line, " UNIVERSAL VALUE"," UNIVERSAL VALUE",instance.parameters.color4, first);
	Buffer4:setPrecision(math.max(2, source:getPrecision()));
	Buffer4:setWidth(instance.parameters.width4);
    Buffer4:setStyle(instance.parameters.style4);
	
	Buffer5 = instance:addStream("Buffer5" , core.Line, " +1 level"," +1 level",instance.parameters.color5, first);
	Buffer5:setPrecision(math.max(2, source:getPrecision()));
	Buffer5:setWidth(instance.parameters.width5);
    Buffer5:setStyle(instance.parameters.style5);
	
	Buffer6 = instance:addStream("Buffer6" , core.Line, " -1 level","-1 level",instance.parameters.color6, first);
	Buffer6:setPrecision(math.max(2, source:getPrecision()));
	Buffer6:setWidth(instance.parameters.width6);
    Buffer6:setStyle(instance.parameters.style6);
	
	
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
	 MA = core.indicators:create(Method, source, AveragePeriod);
	
    UniAvgline = instance:addStream("UniAvgline" , core.Line, " UniAvgline"," UniAvgline",instance.parameters.color7, first);
	UniAvgline:setPrecision(math.max(2, source:getPrecision()));
	UniAvgline:setWidth(instance.parameters.width7);
    UniAvgline:setStyle(instance.parameters.style7);
	
	instance:createChannelGroup("Group","Group" , Buffer5, Buffer6, core.rgb(128, 128,128), Transparency);
	
end

-- Indicator calculation routine
function Update(period, mode)

 
 
  
    
	
	
    if period < first then
	return;
	end
	whitenoise[period]= (source.close[period] - source.close[period-math.min(UniversalPeriod,UNIVERSALFILTER)])/2;
	
	
	 filt[period]= c1 * (whitenoise[period] + whitenoise[period-1])/2 + c2*filt[period-1] + c3*filt[period-1]

 

	 if math.abs(filt[period])>pk[period-1] then
	  pk[period] = math.abs(filt[period])
	 else
	  pk[period] = 0.991 * pk[period-1]
	 end

	 if pk[period]==0 then
	  denom = -1
	 else
	  denom = pk[period]
	 end

	 if denom == -1 then
	  result[period] = result[period-1]
	 else
	  result[period] = filt[period]/pk[period]
	 end
    
    
	
	 
	MA:update(mode);
	
	if period < source:first() +AveragePeriod then
	return;
	end
	
	if period < source:first() +ATRperiod then
	return;
	end
	
	local dTR = 0
	for i= 0, ATRperiod-1, 1 do
	 dTR=dTR+math.max(math.abs(source.high[period-i]-source.low[period-i]),math.max(math.abs(source.high[period-i]-source.close[period-1-i]),math.abs(source.low[period-i]-source.close[period-1-i])))
	end
	
	local avgRange= dTR/TightenChannel;

	
    Buffer1[period]=MA.DATA[period];
	Buffer2[period]=MA.DATA[period]+(avgRange*((OVERBOUGHT)))
	Buffer3[period]=MA.DATA[period]-(avgRange*( (OVERSOLD)))
	Buffer4[period]=MA.DATA[period]+(result[period])/1*avgRange
	Buffer5[period]=MA.DATA[period]+(avgRange*((10/10)))
	Buffer6[period]=MA.DATA[period]+(avgRange*((-10/10)))
				  
	if period < source:first()+math.max(ATRperiod,AveragePeriod )+UniAvgPeriod then
    return;
    end
	
	 UniAvgline[period]=mathex.avg(Buffer4, period-UniAvgPeriod+1, period);		


    local  R = 50+(200-result[period]*400);
    local G =50+(200+result[period]*500);
    local B=0;
	Buffer5:setColor(period, core.rgb(R, G,B));
end

 
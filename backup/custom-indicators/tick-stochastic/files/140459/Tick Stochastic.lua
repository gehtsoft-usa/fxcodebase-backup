-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=70872

--+------------------------------------------------------------------+
--|                               Copyright © 2021, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--|                           https://AppliedMachineLearning.systems |
--|                                Patreon :  https://goo.gl/GdXWeN  |
--+------------------------------------------------------------------+
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Tick Stochastic");
    indicator:description(" ");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);	

 
	
		
	indicator.parameters:addGroup(" Calculation");
    indicator.parameters:addInteger("k"  , "Number of periods for %K", "", 5, 2, 1000);
    indicator.parameters:addInteger("sd" , "%D slowing periods", "", 3, 2, 1000);
      indicator.parameters:addInteger("d" , "Number of periods for %D", "", 3, 2, 1000);

    indicator.parameters:addString("ks" , "Smoothing type for %K", "", "MVA");
    indicator.parameters:addStringAlternative("ks" , "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("ks" , "EMA","", "EMA");
    indicator.parameters:addStringAlternative("ks" , "Fast Smoothed","", "FS");
	 
	indicator.parameters:addString("ds" , "Smoothing type for %D", "", "MVA");
    indicator.parameters:addStringAlternative("ds" , "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("ds" , "EMA","", "EMA");
 

	
	indicator.parameters:addGroup("Line Style");
    
	indicator.parameters:addColor("Up", "OB Color", "",  core.rgb(255, 0, 0));
	indicator.parameters:addColor("Down", "OS Color", "",  core.rgb(0, 255, 0));	
	indicator.parameters:addColor("Neutral", "Neutral Color", "",  core.rgb(0, 0, 0));	
	 
    indicator.parameters:addInteger("width1", "K Line Width (in pixels)", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "K Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	
	indicator.parameters:addInteger("width2", "D Line Width (in pixels)", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "D Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	
	indicator.parameters:addGroup("Levels Style" ); 
    indicator.parameters:addDouble("overbought", "Overbought Level", "", 80, 0, 100);
    indicator.parameters:addDouble("oversold", "Oversold Level", "", 30, 0, 100);
	
    indicator.parameters:addInteger("level_overboughtsold_width", "Width", "", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Sryle", "", core.LINE_SOLID);
	indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addColor("level_overboughtsold_color", "Color", "", core.rgb(0, 0, 255));
	
	
end

 

 
local K;
local D;
 
local k, sd, d, ks, ds 
local source;


local first,kFirst,dFirst;
local signalLine,mva;
 local Neutral,Up, Down;
 local OB, OS;
 local isFS;
local mins, maxes, FastK;
 function Prepare(nameOnly)    
  
   k=instance.parameters.k;
   sd=instance.parameters.sd;
   d=instance.parameters.d;
   ks=instance.parameters.ks;
   ds=instance.parameters.ds;
   
   OS=instance.parameters.oversold;
   OB=instance.parameters.overbought;
   
   Neutral=instance.parameters.Neutral;
   Up=instance.parameters.Up;
   Down=instance.parameters.Down;
    
    source = instance.source;
   
    local name =  profile:id() ..", (" ..   k ..", " .. sd..", " .. d..", " .. ks..", " .. ds..")";
	
	instance:name(name);
	
	  if   (nameOnly) then
        return;
    end
	
    mins = instance:addInternalStream(source:first() + k, 0);
    maxes = instance:addInternalStream(source:first() + k, 0);
    FastK = instance:addInternalStream(mins:first(), 0);
	 
 
	first=   source:first()+k;
	
	if ks  ~= "FS" then
	  mva = core.indicators:create(ks, FastK, sd);
	   isFS = false;
	else
	   isFS = true;
	end
	
	kFirst=first+sd;
	
	K= instance:addStream("K", core.Line, "K", "K", Neutral, kFirst);
	
	
	signalLine = core.indicators:create(ds, K, d);
    dFirst =kFirst+d;
	
	
	D= instance:addStream("D", core.Line, "D", "D", Neutral, dFirst);
	    
    K:setPrecision(2);
	D:setPrecision(2);
	
	K:setWidth(instance.parameters.width1);
    K:setStyle(instance.parameters.style1);
	
	D:setWidth(instance.parameters.width2);
    D:setStyle(instance.parameters.style2);
	
	
	K:addLevel(0);
	K:addLevel(OB, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    K:addLevel(OS, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    K:addLevel(100);
	
	
	 
end


function Update(period, mode)

    
    if period < first then
	return;
	end
	
        local minLow, maxHigh = mathex.minmax(source, period - k + 1, period);
        mins[period] = source[period] - minLow;
        maxes[period] = maxHigh - minLow;
		
		
        if maxes[period] > 0 then
            FastK[period] = mins[period] / maxes[period] * 100;
        else
            FastK[period] = 50;
        end

	
	
    if isFS == false then
        mva:update(mode);
        if period >= kFirst then
            K[period] = mva.DATA[period];
        end
    else
        if period >= kFirst then
            local sumMax = mathex.sum(maxes, period - sd + 1, period);
            if sumMax == 0 then
                K[period] = 50;
            else
                local sumMin = mathex.sum(mins, period - sd + 1, period);
                K[period] = sumMin / sumMax * 100;
            end
        end
    end
	
    signalLine:update(mode);
    if period >= dFirst then
        D[period] = signalLine.DATA[period];
    end


--******************************************************************************************************
	
	if K[period] > OB then
	K:setColor(period, Up);
	elseif K[period] < OS then
	K:setColor(period, Down);
	else
	K:setColor(period, Neutral);
	end
	
	if D[period] > OB then
	D:setColor(period, Up);
	elseif K[period] < OS then
	D:setColor(period, Down);
	else
	D:setColor(period, Neutral);
	end
	
end

-- Id: 712

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1057

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
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
    indicator:name("TrendlesOS");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    
	 indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("SMA_Period", "Period of SMA", " ", 7);
    indicator.parameters:addDouble("OBLevel", "OBLevel", " ", 0.0047);
    indicator.parameters:addDouble("OSLevel", "OSLevel", " ", -0.00473);
    indicator.parameters:addString("DisplayMode", "DisplayMode", "", "line");
    indicator.parameters:addStringAlternative("DisplayMode", "line", "", "line");
    indicator.parameters:addStringAlternative("DisplayMode", "histogram", "", "histogram");
     indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color_1", "Color 1", "Color 1", core.rgb(0, 255, 0));
    indicator.parameters:addColor("color_2", "Color 2", "Color 2", core.rgb(0, 128, 0));
    indicator.parameters:addColor("color_3", "Color 3", "Color 3", core.rgb(255, 255, 0));
    indicator.parameters:addColor("color_4", "Color 4", "Color 4", core.rgb(255, 128, 0));
    indicator.parameters:addColor("color_5", "Color 5", "Color 5", core.rgb(255, 0, 0));
end

local SMA_Period;
local OBLevel;
local OSLevel;
local DisplayMode;

local MA;

local first;
local source = nil;
local buff1=nil;
local buff2=nil;
local buff3=nil;
local buff4=nil;
local buff5=nil;

function Prepare(nameOnly)
    SMA_Period = instance.parameters.SMA_Period;
    OBLevel = instance.parameters.OBLevel;
    OSLevel = instance.parameters.OSLevel;
    DisplayMode = instance.parameters.DisplayMode;
    source = instance.source;
    MA = core.indicators:create("MVA", source, SMA_Period);
    
    first = MA.DATA:first();
    local name = profile:id() .. "(" .. source:name() .. ", " .. SMA_Period .. ", " .. OBLevel .. ", " .. OSLevel .. ", " .. DisplayMode .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
     if DisplayMode=="line" then
     buff1 = instance:addStream("buff1", core.Line, name .. ".buff1", "buff1", instance.parameters.color_1, first);   
     buff1:addLevel(0.8*OSLevel);    
     buff1:addLevel(0.6*OSLevel);    
     buff1:addLevel(0.8*OBLevel);    
     buff1:addLevel(0.6*OBLevel);    
     buff1:addLevel(OBLevel);    
     buff1:addLevel(OSLevel);    
    else
     buff1 = instance:addStream("buff1", core.Bar, name .. ".buff1", "buff1", instance.parameters.color_1, first);  
     buff1:addLevel(0.8*OSLevel);    
     buff1:addLevel(0.6*OSLevel);    
     buff1:addLevel(0.8*OBLevel);    
     buff1:addLevel(0.6*OBLevel);    
     buff1:addLevel(OBLevel);    
     buff1:addLevel(OSLevel);    
    end 
	
	buff1:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)

  MA:update(mode);
  
  
 if (period<first) then
 return;
 end
 
 
   buff1[period]=source[period]-MA.DATA[period];
  
   if DisplayMode=="line" then
   return;
   end
   
  if buff1[period]>0.6*OSLevel and buff1[period]<0.6*OBLevel then
    buff1:setColor(period, instance.parameters.color_2);
  elseif (buff1[period]>0.8*OSLevel and buff1[period]<=0.6*OSLevel) or (buff1[period]>=0.6*OBLevel and buff1[period]<0.8*OBLevel) then
   buff1:setColor(period, instance.parameters.color_3);
  elseif (buff1[period]>OSLevel and buff1[period]<=0.8*OSLevel) or (buff1[period]>=0.8*OBLevel and buff1[period]<OBLevel) then
    buff1:setColor(period, instance.parameters.color_3);
  else
    buff1:setColor(period, instance.parameters.color_5);
  end
end


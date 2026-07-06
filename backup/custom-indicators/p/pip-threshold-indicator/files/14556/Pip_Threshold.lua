-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=6309
-- Id: 4543

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                   Paypal: https://goo.gl/9Rj74e  |
--|                    Patreon : https://www.patreon.com/mariojemic  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+


function Init()
 indicator:name("Pip threshold");
 indicator:description("Pip threshold(indicator)");
 indicator:requiredSource(core.Tick);
 indicator:type(core.Indicator);

 indicator.parameters:addGroup("First threshold");
 indicator.parameters:addBoolean("Thr1Enabled", "Enable first threshold?","Threshold for high price moves",true);
 indicator.parameters:addInteger("Thr1", "First threshold", "", 5);
 indicator.parameters:addGroup("Second threshold");
 indicator.parameters:addBoolean("Thr2Enabled","Enable second threshold?","Threshold for medium price moves",true);
 indicator.parameters:addInteger("Thr2", "Second threshold", "", 3);
 indicator.parameters:addGroup("Third threshold");
 indicator.parameters:addBoolean("Thr3Enabled","Enabled third threshold?", "Threshold for low price moves", true);
 indicator.parameters:addInteger("Thr3", "Third threshold", "", 1);
 indicator.parameters:addGroup("Style options");
 indicator.parameters:addInteger("FontSize","Size of markers", "", 8);
 indicator.parameters:addColor("Thr1Color","Color of marker for the first threshold","",core.rgb(255,0,0));
 indicator.parameters:addColor("Thr2Color","Color of marker for the second threshold","",core.rgb(255,255,0));
 indicator.parameters:addColor("Thr3Color","Color of marker for the third threshold","",core.rgb(0,255,0));
end

local source;
local first;
local pipSize;
local thr1;
local thr2;
local thr3;
local isThr1;
local isThr2;
local isThr3;
local dFont;
local colors;
local thr1Output;
local thr2Output;
local thr3Output;
local MaxThr;

function Prepare(nameOnly)
 source = instance.source;
 
 pipSize = source:pipSize();
 thr1 = instance.parameters.Thr1;
 thr2 = instance.parameters.Thr2;
 thr3 = instance.parameters.Thr3;
 isThr1 = instance.parameters.Thr1Enabled;
 isThr2 = instance.parameters.Thr2Enabled;
 isThr3 = instance.parameters.Thr3Enabled;
 local name = profile:id() .. "(" .. source:name() .. ", " .. thr1 .. "," .. thr2 .. "," .. thr3 .. ")";
 instance:name(name);
 if nameOnly then
  return;
 end
 colors = core.colors();
 thr1Output = instance:createTextOutput("thr1Output", "Threshold 1", "Wingdings", instance.parameters.FontSize, core.H_Center, core.V_Center, instance.parameters.Thr1Color, 0);
 thr2Output = instance:createTextOutput("thr2Output", "Threshold 2", "Wingdings", instance.parameters.FontSize, core.H_Center, core.V_Center, instance.parameters.Thr2Color, 0);
 thr3Output = instance:createTextOutput("thr3Output", "Threshold 3", "Wingdings", instance.parameters.FontSize, core.H_Center, core.V_Center, instance.parameters.Thr3Color, 0);
 MaxThr=1;
 if isThr1 then
  MaxThr=math.max(MaxThr,thr1);
 end
 if isThr2 then
  MaxThr=math.max(MaxThr,thr2);
 end
 if isThr3 then
  MaxThr=math.max(MaxThr,thr3);
 end
 
 first=source:first()+MaxThr;
end

function Update(period, mode)
 if period < first then
 return;
 end
 
 local FlThr1Up=isThr1;
 local FlThr2Up=isThr2;
 local FlThr3Up=isThr3;
 local FlThr1Dn=isThr1;
 local FlThr2Dn=isThr2;
 local FlThr3Dn=isThr3;
 local i;
 for i=1,MaxThr,1 do
  priceDiff=source[period-i+1]-source[period-i];
  if i<=thr1 and priceDiff<0 then
   FlThr1Up=false;
  end
  if i<=thr1 and priceDiff>0 then
   FlThr1Dn=false;
  end
  if i<=thr2 and priceDiff<0 then
   FlThr2Up=false;
  end
  if i<=thr2 and priceDiff>0 then
   FlThr2Dn=false;
  end
  if i<=thr3 and priceDiff<0 then
   FlThr3Up=false;
  end
  if i<=thr3 and priceDiff>0 then
   FlThr3Dn=false;
  end
 end
 if FlThr1Up or FlThr1Dn then
  thr1Output:set(period, source[period], "\108");
  thr2Output:setNoData (period); 	
    thr3Output:setNoData (period); 	
  return;
 end
 if FlThr2Up or FlThr2Dn then
  thr2Output:set(period, source[period], "\108");
    thr1Output:setNoData (period); 	
    thr3Output:setNoData (period); 	
  return;
 end
 if FlThr3Up or FlThr3Dn then
  thr3Output:set(period, source[period], "\108");
    thr2Output:setNoData (period); 	
    thr1Output:setNoData (period); 	
 end
 
 
end

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=10444

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
    indicator:name("123 patterns indicator");
    indicator:description("123 patterns indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("ZigZagDepth", "ZigZagDepth", "", 1);
    indicator.parameters:addDouble("RetraceDepthMin", "RetraceDepthMin", "", 0.4);
    indicator.parameters:addDouble("RetraceDepthMax", "RetraceDepthMax", "", 1);
    indicator.parameters:addBoolean("ShowAllLines", "ShowAllLines", "", true);
    indicator.parameters:addBoolean("ShowAllBreaks", "ShowAllBreaks", "", true);
    indicator.parameters:addBoolean("ShowAllTargets", "ShowAllTargets", "", false);
    indicator.parameters:addDouble("Target1Multiply", "Target1Multiply", "", 1.5);
    indicator.parameters:addDouble("Target2Multiply", "Target2Multiply", "", 3);
    indicator.parameters:addBoolean("HideTransitions", "HideTransitions", "", true);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UpperLineClr", "Upper Line Color", "Upper Line Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("LowerLineClr", "Lower Line Color", "Lower Line Color", core.rgb(255, 255, 0));
    indicator.parameters:addColor("Target1LineClr", "Target 1 Line Color", "Target 1 Line Color", core.rgb(0, 128, 0));
    indicator.parameters:addColor("Target2LineClr", "Target 2 Line Color", "Target 2 Line Color", core.rgb(128, 128, 0));
    indicator.parameters:addColor("BuyArrowClr", "Buy Arrow Color", "Buy Arrow Color", core.rgb(0, 255, 255));
    indicator.parameters:addColor("SellArrowClr", "Sell Arrow Color", "Sell Arrow Color", core.rgb(0, 255, 255));
    indicator.parameters:addColor("BullDotClr", "Bull Dot Color", "Bull Dot Color", core.rgb(0, 128, 128));
    indicator.parameters:addColor("BearDotClr", "Bear Dot Color", "Bear Dot Color", core.rgb(0, 128, 128));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
    indicator.parameters:addInteger("DotSize", "Dot size", "Dot size", 4, 1, 5);
	
	indicator.parameters:addInteger("Size", "Arrow Size", "", 10);
end

local first;
local source = nil;
local ZigZagDepth;
local RetraceDepthMin;
local RetraceDepthMax;
local ShowAllLines;
local ShowAllBreaks;
local ShowAllTargets;
local Target1Multiply;
local Target2Multiply;
local HideTransitions;
local UpperLine=nil;
local LowerLine=nil;
local Target1Line=nil;
local Target2Line=nil;
local ZigZag;
local BuyArrow=nil;
local SellArrow=nil;
local BullDot=nil;
local BearDot=nil;
local Size;
function Prepare(nameOnly)
    source = instance.source;
    ZigZagDepth=instance.parameters.ZigZagDepth;
    RetraceDepthMin=instance.parameters.RetraceDepthMin;
    RetraceDepthMax=instance.parameters.RetraceDepthMax;
    ShowAllLines=instance.parameters.ShowAllLines;
    ShowAllBreaks=instance.parameters.ShowAllBreaks;
    ShowAllTargets=instance.parameters.ShowAllTargets;
    Target1Multiply=instance.parameters.Target1Multiply;
    Target2Multiply=instance.parameters.Target2Multiply;
    HideTransitions=instance.parameters.HideTransitions;
    Size=instance.parameters.Size; 
    
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.ZigZagDepth .. ", " .. instance.parameters.RetraceDepthMin .. ", " .. instance.parameters.RetraceDepthMax .. ", " .. instance.parameters.Target1Multiply .. ", " .. instance.parameters.Target2Multiply .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	first = source:first()+2;
    ZigZag=core.indicators:create("ZIGZAG", source, ZigZagDepth, 5, 3);
	
	
    if ShowAllLines then
     UpperLine = instance:addStream("UpperLine", core.Line, name .. ".UpperLine", "UpperLine", instance.parameters.UpperLineClr, first);
     LowerLine = instance:addStream("LowerLine", core.Line, name .. ".LowerLine", "LowerLine", instance.parameters.LowerLineClr, first);
     UpperLine:setWidth(instance.parameters.widthLinReg);
     UpperLine:setStyle(instance.parameters.styleLinReg);
     LowerLine:setWidth(instance.parameters.widthLinReg);
     LowerLine:setStyle(instance.parameters.styleLinReg);
    else
     UpperLine = instance:addInternalStream(first, 0);
     LowerLine = instance:addInternalStream(first, 0);
    end 
    if ShowAllTargets then
     Target1Line = instance:addStream("Target1Line", core.Line, name .. ".Target1Line", "Target1Line", instance.parameters.Target1LineClr, first);
     Target2Line = instance:addStream("Target2Line", core.Line, name .. ".Target2Line", "Target2Line", instance.parameters.Target2LineClr, first);
     Target1Line:setWidth(instance.parameters.widthLinReg);
     Target1Line:setStyle(instance.parameters.styleLinReg);
     Target2Line:setWidth(instance.parameters.widthLinReg);
     Target2Line:setStyle(instance.parameters.styleLinReg);
    else
     Target1Line = instance:addInternalStream(first, 0);
     Target2Line = instance:addInternalStream(first, 0);
    end 
    BullDot = instance:addStream("BullDot", core.Dot, name .. ".BullDot", "BullDot", instance.parameters.BullDotClr, first);
    BearDot = instance:addStream("BearDot", core.Dot, name .. ".BearDot", "BearDot", instance.parameters.BearDotClr, first);
    BuyArrow = instance:createTextOutput ("Buy", "Buy", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.BuyArrowClr, first);
    SellArrow = instance:createTextOutput ("Sell", "Sell", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.SellArrowClr, first);
    BullDot:setWidth(instance.parameters.DotSize);
    BearDot:setWidth(instance.parameters.DotSize);
end

function SearchPeaks(period)
 local i=period;
 local LastHigh=nil;
 local PrevHigh=nil;
 local LastLow=nil;
 local PrevLow=nil;
 while i>first and (PrevHigh==nil or PrevLow==nil) do
  local ZZ=ZigZag.DATA[i];
  if math.abs(ZZ-source.high[i])<source:pipSize()/2 then
   if LastHigh==nil then
    LastHigh=i;
   elseif PrevHigh==nil then
    PrevHigh=i;
   end
  elseif math.abs(ZZ-source.low[i])<source:pipSize()/2 then 
   if LastLow==nil then
    LastLow=i;
   elseif PrevLow==nil then
    PrevLow=i;
   end 
  end
  i=i-1;
 end
 return PrevLow, PrevHigh, LastLow, LastHigh;
end

function Update(period, mode)
   if (period>first and period<=source:size()-1) then
    local one, onetime, two, twotime, three, threetime;
    local retracedepth=0;
    local range;
    UpperLine[period]=UpperLine[period-1];
    LowerLine[period]=LowerLine[period-1];
    Target1Line[period]=Target1Line[period-1];
    Target2Line[period]=Target2Line[period-1];
    ZigZag:update(mode);
    
    local PrevLow,PrevHigh,LastLow,LastHigh=SearchPeaks(period);
    if PrevLow==nil or PrevHigh==nil then
     return;
    end
    
    local i;
    for i=LastHigh,period,1 do
     UpperLine[i]=source.high[LastHigh];
    end
    for i=LastLow,period,1 do
     LowerLine[i]=source.low[LastLow];
    end
    
    if HideTransitions then
     if UpperLine[LastHigh]~=UpperLine[LastHigh-1] then
      UpperLine[LastHigh-1]=nil;
     end
     if LowerLine[LastLow]~=LowerLine[LastLow-1] then
      LowerLine[LastLow-1]=nil;
     end
    end
    
    one=source.low[PrevLow];
    onetime=PrevLow;
    two=source.high[LastHigh];
    twotime=LastHigh;
    if twotime==period then
     two=source.high[PrevHigh];
     twotime=PrevHigh;
    end
    three=source.low[LastLow];
    threetime=LastLow;
    if one-two~=0 then
     retracedepth=(three-two)/(one-two);
    else
     retracedepth=0; 
    end
    if source.low[period]<UpperLine[period] and source.close[period]>UpperLine[period] then
     if retracedepth>RetraceDepthMin and retracedepth<RetraceDepthMax then
      range=math.abs(two-three);
      Target1Line[period]=two+range*Target1Multiply;
      Target2Line[period]=two+range*Target2Multiply;
      BuyArrow:set(period, source.low[period]-(source.high[period]-source.low[period])/3, "\225", "Buy");
      BullDot[onetime]=one;
      BullDot[twotime]=two;
      BullDot[threetime]=three;
     end
     if ShowAllBreaks then
      range=UpperLine[period]-LowerLine[period];
      Target1Line[period]=UpperLine[period]+range*Target1Multiply;
      Target2Line[period]=UpperLine[period]+range*Target2Multiply;
      BuyArrow:set(period, source.low[period]-(source.high[period]-source.low[period])/3, "\225", "Buy");
     end
    end
    
    one=source.high[PrevHigh];
    onetime=PrevHigh;
    two=source.low[LastLow];
    twotime=LastLow;
    if twotime==period then
     two=source.low[PrevLow];
     twotime=PrevLow;
    end
    three=source.high[LastHigh];
    threetime=LastHigh;
    if one-two~=0 then
     retracedepth=(three-two)/(one-two);
    else
     retracedepth=0;
    end
    if source.high[period]>LowerLine[period] and source.close[period]<LowerLine[period] then
     if retracedepth>RetraceDepthMin and retracedepth<RetraceDepthMax then
      range=math.abs(two-three);
      Target1Line[period]=two-range*Target1Multiply;
      Target2Line[period]=two-range*Target2Multiply;
      SellArrow:set(period, source.high[period]+(source.high[period]-source.low[period])/3, "\226", "Sell");
      BearDot[onetime]=one;
      BearDot[twotime]=two;
      BearDot[threetime]=three;
     end
     if ShowAllBreaks then
      range=UpperLine[period]-LowerLine[period];
      Target1Line[period]=LowerLine[period]-range*Target1Multiply;
      Target2Line[period]=LowerLine[period]-range*Target2Multiply;
      SellArrow:set(period, source.high[period]+(source.high[period]-source.low[period])/3, "\226", "Sell");
     end
    end
    
    if HideTransitions then
     if UpperLine[period]~=UpperLine[period-1] then
      UpperLine[period-1]=nil;
     end
     if LowerLine[period]~=LowerLine[period-1] then
      LowerLine[period-1]=nil;
     end
     if Target1Line[period]~=Target1Line[period-1] then
      Target1Line[period-1]=nil;
     end
     if Target2Line[period]~=Target2Line[period-1] then
      Target2Line[period-1]=nil;
     end
    end
    
   end 
end


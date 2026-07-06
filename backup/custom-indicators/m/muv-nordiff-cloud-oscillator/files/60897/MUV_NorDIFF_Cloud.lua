-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=36270
-- Id: 9104

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("MUV_NorDIFF_Cloud oscillator");
    indicator:description("MUV_NorDIFF_Cloud oscillator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("MA_Period", "MA period", "", 14);
    indicator.parameters:addInteger("Momentum", "Momentum", "", 1);
    indicator.parameters:addInteger("K_Period", "K period", "", 14);
	
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UPclr", "UP color", "UP color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DNclr", "DN color", "DN color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("Transparency", "Transparency", "", 50,0,100);
    indicator.parameters:addColor("Levelclr", "Level color", "Level color", core.rgb(128, 128, 0));
    indicator.parameters:addInteger("Lwidth", "Level width", "Level width", 1, 1, 5);
    indicator.parameters:addInteger("Lstyle", "Level style", "Level style", core.LINE_DASH);
    indicator.parameters:setFlag("Lstyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Uclr", "Upper dot color", "Upper dot color", core.rgb(0, 128, 0));
    indicator.parameters:addColor("Lclr", "Lower dot color", "Lower dot color", core.rgb(128, 0, 0));
    indicator.parameters:addInteger("DotSize", "Dot size", "Dot size", 3, 1, 5);
end

local first;
local source = nil;
local MA_Period;
local Momentum;
local K_Period;
local MA1;
local MA2;
local Pbuff=nil;
local Mbuff=nil;
local SMA_Value={};
local EMA_Value={};
local Count={};
local count;
local Ubuff=nil;
local Lbuff=nil;

function Prepare(nameOnly)
    source = instance.source;
    MA_Period=instance.parameters.MA_Period;
    Momentum=instance.parameters.Momentum;
    K_Period=instance.parameters.K_Period;
    
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.MA_Period .. ", " .. instance.parameters.Momentum .. ", " .. instance.parameters.K_Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");  
	assert(core.indicators:findIndicator("XMUV") ~= nil, "Please, download and install XMUV.LUA indicator");  
	
    MA1 = core.indicators:create("XMUV", source, "MVA", MA_Period);
    MA2 = core.indicators:create("XMUV", source, "EMA", MA_Period);
	
	first=MA1.DATA:first();
    Pbuff = instance:addStream("Pbuff", core.Line, name .. ".Pbuff", "Pbuff", instance.parameters.UPclr, first + math.max(Momentum, K_Period));
    Pbuff:setPrecision(math.max(2, instance.source:getPrecision()));
    Mbuff = instance:addStream("Mbuff", core.Line, name .. ".Mbuff", "Mbuff", instance.parameters.UPclr, first + math.max(Momentum, K_Period));
    Mbuff:setPrecision(math.max(2, instance.source:getPrecision()));
    instance:createChannelGroup("TC","TC" , Pbuff, Mbuff, instance.parameters.UPclr, 100-instance.parameters.Transparency);
    local i;
    for i=0, K_Period, 1 do
     Count[i]=0;
     SMA_Value[i]=0;
     EMA_Value[i]=0;
    end
    count=1;
    Pbuff:addLevel(100, instance.parameters.Lstyle, instance.parameters.Lwidth, instance.parameters.Levelclr);
    Pbuff:addLevel(-100, instance.parameters.Lstyle, instance.parameters.Lwidth, instance.parameters.Levelclr);
    Ubuff = instance:addStream("Ubuff", core.Dot, name .. ".Ubuff", "Ubuff", instance.parameters.Uclr, first + math.max(Momentum, K_Period));
    Ubuff:setPrecision(math.max(2, instance.source:getPrecision()));
    Lbuff = instance:addStream("Lbuff", core.Dot, name .. ".Lbuff", "Lbuff", instance.parameters.Lclr, first + math.max(Momentum, K_Period));
    Lbuff:setPrecision(math.max(2, instance.source:getPrecision()));
    Ubuff:setWidth(instance.parameters.DotSize);
    Lbuff:setWidth(instance.parameters.DotSize);
end

function ArrayMinMax(Arr, BeginPos, EndPos)
 local i;
 local MaxV, MinV = -100000000, 10000000;
 for i=BeginPos, EndPos, 1 do
  MaxV=math.max(MaxV, Arr[i]);
  MinV=math.min(MinV, Arr[i]);
 end
 return MinV, MaxV;
end

function Update(period, mode)
 
    MA1:update(mode);
    MA2:update(mode);
	
	if period < first + math.max(Momentum, K_Period) then
	return;
	end
	
	
    SMA_Value[Count[0]]=MA1.DATA[period]-MA1.DATA[period-Momentum];
    EMA_Value[Count[0]]=MA2.DATA[period]-MA2.DATA[period-Momentum];
    local SMA_Min, SMA_Max = ArrayMinMax(SMA_Value, 0, K_Period-1);
    local EMA_Min, EMA_Max = ArrayMinMax(EMA_Value, 0, K_Period-1);
    local SMA_Range=SMA_Max-SMA_Min;
    local EMA_Range=EMA_Max-EMA_Min;
    local SMA_Res=100;
    if SMA_Range>0 then
     SMA_Res=100-200*(SMA_Max-SMA_Value[Count[0]])/SMA_Range;
    end
    local EMA_Res=100;
    if EMA_Range>0 then
     EMA_Res=100-200*(EMA_Max-EMA_Value[Count[0]])/EMA_Range;
    end
    
    Pbuff[period]=EMA_Res;
    Mbuff[period]=SMA_Res;
    
    if Pbuff[period]>Mbuff[period] then
     Pbuff:setColor(period, instance.parameters.UPclr);
     Mbuff:setColor(period, instance.parameters.UPclr);
    else
     Pbuff:setColor(period, instance.parameters.DNclr);
     Mbuff:setColor(period, instance.parameters.DNclr);
    end
    
    if SMA_Res==100 or EMA_Res==100 then
     Ubuff[period]=100;
    else
     Ubuff[period]=nil;
    end
    if SMA_Res==-100 or EMA_Res==-100 then
     Lbuff[period]=-100;
    else
     Lbuff[period]=nil;
    end
    
    if period~=source:size()-1 then
     count=count-1;
     if count<0 then
      count=K_Period-1;
     end
     local i;
     for i=0, K_Period-1, 1 do
      if i+count>K_Period-1 then
       Count[i]=i+count-K_Period;
      else
       Count[i]=i+count;
      end
     end
    end
    
   
end


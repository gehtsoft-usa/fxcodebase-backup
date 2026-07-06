-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1721

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
    indicator:name("NonLagDot with averages indicator");
    indicator:description("NonLagDot with averages indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("Method", "Method", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Method", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Method", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Method", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Method", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Method", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Method", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Method", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Method", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Method", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Method", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Method", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Method", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Method", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Method", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Method", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Method", "JSmooth", "", "JSmooth");
    indicator.parameters:addInteger("Length", "Length", "Length", 10);
    indicator.parameters:addInteger("Filter", "Filter", "Filter", 0);
    indicator.parameters:addDouble("Deviation", "Deviation", "Deviation", 0);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addString("Type", "Type", "", "Dots");
    indicator.parameters:addStringAlternative("Type", "Dots", "", "Dots");
    indicator.parameters:addStringAlternative("Type", "Line", "", "Line");
    indicator.parameters:addColor("clrUP", "UP color", "UP color", core.rgb(0, 0, 255));
    indicator.parameters:addColor("clrDN", "DN color", "DN color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width (dot size)", "Line width (dot size)", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Length;
local Filter;
local Method;
local Deviation;
local NonLagDot=nil;
local MA;
local trend;
local Coeff;
local Phase;
local Len;
local dT1, dT2, Kd, Fi;

function Prepare(nameOnly)
    source = instance.source;
    Length=instance.parameters.Length;
    Filter=instance.parameters.Filter;
    Method=instance.parameters.Method;
    Deviation=instance.parameters.Deviation;
    trend = instance:addInternalStream(0, 0);
     
	
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Length .. ", " .. instance.parameters.Filter .. ", " .. instance.parameters.Method .. ", " .. instance.parameters.Deviation .. ")";
    instance:name(name);
	
	
	if   (nameOnly) then
        return;
    end
	
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");  
	
    MA=core.indicators:create("AVERAGES", source, Method, Length, false);
   
    Coeff=3*math.pi;
    Phase=Length-1;
    Len=Length*4+Phase;
	 
	first = source:first()+Len;
    dT1=7/(4*Length-1);
    dT2=1/(Phase-1);
    Kd=1+Deviation/100;
    Fi=Filter*source:pipSize();
	
	 if instance.parameters.Type=="Dots" then
     NonLagDot = instance:addStream("NonLagDot", core.Dot, name .. ".NonLagDot", "NonLagDot", instance.parameters.clrUP, first);
    else
     NonLagDot = instance:addStream("NonLagDot", core.Line, name .. ".NonLagDot", "NonLagDot", instance.parameters.clrUP, first);
    end 
	
	
    NonLagDot:setWidth(instance.parameters.widthLinReg);
    NonLagDot:setStyle(instance.parameters.styleLinReg);
end

function Update(period, mode)
    
	
     MA:update(mode);
	 
	 if (period<first ) then
	return;
	end
	
     local Weight=0;
     local Sum=0;
     local t=0;
     for i=0,Len-1,1 do
      local g=1/(Coeff*t+1);
      if t<=0.5 then
       g=1;
      end
      local beta=math.cos(math.pi*t);
      local alpha=g*beta;
      Sum=Sum+alpha*MA.DATA[period-i];
      Weight=Weight+alpha;
      if t<1 then
       t=t+dT2;
      elseif t<Len-1 then
       t=t+dT1;
      end
     end
     if Weight>0 then
      NonLagDot[period]=Kd*Sum/Weight;
     end
     if Filter>0 then
      if math.abs(NonLagDot[period]-NonLagDot[period-1])<Fi then
       NonLagDot[period]=NonLagDot[period-1];
      end
     end
     trend[period]=trend[period-1];
     if NonLagDot[period]-NonLagDot[period-1]>Fi then
      trend[period]=1;
     end
     if NonLagDot[period-1]-NonLagDot[period]>Fi then
      trend[period]=-1;
     end
     if trend[period]>0 then
      NonLagDot:setColor(period, instance.parameters.clrUP);
     else
      NonLagDot:setColor(period, instance.parameters.clrDN);
     end

    
end

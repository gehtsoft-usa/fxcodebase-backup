-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1169

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("ASCTrend indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("RISK", "RISK", "", 3);
	
	indicator.parameters:addGroup("Style");  
    indicator.parameters:addBoolean("Signal", "Signal Mode", "Do not change this parameter when you apply the indicator on the chart. It is used by the signals only", false);
    indicator.parameters:addColor("UP_color", "Color of UP", "Color of UP", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DN_color", "Color of DN", "Color of DN", core.rgb(255, 0, 0));
end

local first;
local RISK;
local source = nil;
local buffUp=nil;
local buffDn=nil;
local buff=nil;
local Table_value2;
local SIGNAL=nil;
local value10;

function Prepare(nameOnly)
    source = instance.source;
    RISK=instance.parameters.RISK;
	SIGNAL=instance.parameters.Signal;
	
	value10=3*2*RISK;
	 
    first = source:first()+value10;
    local name = profile:id() .. "(" .. source:name() .. ", " .. RISK .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    Table_value2=instance:addInternalStream(0, 0);
	if SIGNAL then
	    buff = instance:addStream("buff", core.Line, name .. ".buff", "buff", instance.parameters.UP_color, first);
	else
    buffUp = instance:createTextOutput ("Up", "Up", "Wingdings", 10, core.H_Center, core.V_Top, instance.parameters.UP_color, first);
    buffDn = instance:createTextOutput ("Dn", "Dn", "Wingdings", 10, core.H_Center, core.V_Bottom, instance.parameters.DN_color, first);
	end
end

function Update(period,mode)
   
    if (period<first) then
	return;
	end
	
     local x1=67+RISK;
     local x2=33-RISK;
     local value11=value10;
     local Range=0.;
     local AvgRange=0.;
     for i=period-9,period,1 do
      AvgRange=AvgRange+math.abs(source.high[i]-source.low[i]);
     end
     Range=AvgRange/10.;
     local TrueCount=0;
     local Counter=period;
     while Counter>period-9 and TrueCount<1 do
      if math.abs(source.open[Counter]-source.close[Counter-1])>=Range*2. then
       TrueCount=TrueCount+1;
      end
      Counter=Counter-1;
     end
     local MRO1;
     if TrueCount>=1 then
      MRO1=Counter;
     else
      MRO1=-1;
     end
     Counter=period;
     TrueCount=0;
     while Counter>period-6 and TrueCount<1 do
      if math.abs(source.close[Counter-3]-source.close[Counter])>Range*4.6 then
       TrueCount=TrueCount+1;
      end
      Counter=Counter-1;
     end
     local MRO2;
     if TrueCount>=1 then
      MRO2=Counter;
     else
      MRO2=-1;
     end
     if MRO1>-1 then
      value11=3;
     else
      value11=value10;
     end
     if MRO2>-1 then
      value11=4;
     else
      value11=value10;
     end
     local WPR=-(core.max(source.high,core.rangeTo(period,value11))-source.close[period])*100./(core.max(source.high,core.rangeTo(period,value11))-core.min(source.low,core.rangeTo(period,value11)));
     local value2=100-math.abs(WPR);
     Table_value2[period]=value2;
     value3=0;
     local i1;
     if value2<x2 then
      i1=1;
      while Table_value2[period-i1]>=x2 and Table_value2[period-i1]<=x1 do
       i1=i1+1;
      end
 	  
	 if Table_value2[period-i1]>x1 then
       value3=source.high[period]+Range*0.5;
			   if SIGNAL then
			   buff[period]=1;
			   else	  
			   buffUp:set(period, value3, "\226", "");
			   end
      end
     end
	 	 
     if value2>x1 then
      i1=1;
      while Table_value2[period-i1]>=x2 and Table_value2[period-i1]<=x1 do
       i1=i1+1;
      end
      if Table_value2[period-i1]<x2 then
       value3=source.low[period]-Range*0.5;
	         if SIGNAL then	   
			 buff[period]=-1;
             else			 
             buffDn:set(period, value3, "\225", "");
			 end
      end
     end

    
end


-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=32537
-- Id: 8609

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
    indicator:name("Linear_Sinus_FT indicator");
    indicator:description("Linear_Sinus_FT indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Hours", "Hours", "", 100);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("SinClr", "Sin Color", "Sin Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("OutClr", "Out Color", "Out Color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Period;
local Hours;
local Sin=nil;
local Out=nil;
local n, n2;

function Prepare(nameOnly)
    source = instance.source;
    Hours=instance.parameters.Hours;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Hours .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    Sin = instance:addStream("Sin", core.Line, name .. ".Sin", "Sin", instance.parameters.SinClr, first);
    Out = instance:addStream("Out", core.Line, name .. ".Out", "Out", instance.parameters.OutClr, first);
    Sin:setWidth(instance.parameters.widthLinReg);
    Sin:setStyle(instance.parameters.styleLinReg);
    Out:setWidth(instance.parameters.widthLinReg);
    Out:setStyle(instance.parameters.styleLinReg);
end
local Last;
function Update(period, mode)

   if period==source:first() then
   Last=nil;
   end
   

   if period~=source:size()-1 then
   return;
   end
   
    period=period-1;
	
	if  Last== source:serial(period) then
	return;
	end
	
	
	
	Last= source:serial(period);
	
   
    local HBar=core.findDate(source, source:date(period)-Hours/24, false);
	
	if HBar== -1 then
	return;
	end
	
	
	
    Period=period-HBar+1;
    n=math.floor(Period/2);
		
    n2=n*2;
	
	if period < n2*2 then
	return;
	end
	
    local i, j;
    local Num;
    local Den;
    for j=n2,0,-1 do
     Num=0;
     Den=0;
     for i=n2,0,-1 do
      Num=Num+math.sin(i*math.pi/n2)*source[period-i-j];
      Den=Den+math.sin(i*math.pi/n2);
     end
     Sin[period-j-n]=Num/Den;
     for i=n,0,-1 do
      Sin[period-i]=Sin[period-n]+(Sin[period-n]-Sin[period-n-1])*(n-i);
     end
    end
    
    local t=n2+1;
    local t2=math.floor(t/2);
    local stti=(t*t*t-t)/12;
    local stttti=(3*t*t*t*t*t-10*t*t*t+7*t)/240;
    local sOuti=0;
    local si=0;
    local sOutti=0;
    local sOuttti=0;
    for i=n2,0,-1 do
     sOuti=sOuti+Sin[period-i];
     si=si+(t2-i);
     sOutti=sOutti+(Sin[period-i]*(t2-i));
     sOuttti=sOuttti+(Sin[period-i]*(t2-i)*(t2-i));
    end
    local b=sOutti/stti;
    local c=-((sOuti/t)-(sOuttti/stti))/math.abs((stti/t)-(stttti/stti));
    local a=(sOuti-stti*c)/t;
    for i=n2,0,-1 do
     Out[period-i]=a+b*(-i+(t/2))+c*(-i+(t/2))*(-i+(t/2));
    end

end


-- Id: 8365
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=31129

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
    indicator:name("Spectrometr_Separate indicator");
    indicator:description("Spectrometr_Separate indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addInteger("Length", "Period for Evaluation", "The number of last candles that will be expanded into the spectrum", 30, 20, 1000);
	
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr1", "Color 1", "Color 1", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clr2", "Color 2", "Color 2", core.rgb(255, 0, 0));
    indicator.parameters:addColor("clr3", "Color 3", "Color 3", core.rgb(0, 0, 255));
    indicator.parameters:addColor("clr4", "Color 4", "Color 4", core.rgb(0, 128, 255));
    indicator.parameters:addColor("clr5", "Color 5", "Color 5", core.rgb(0, 255, 255));
    indicator.parameters:addColor("clr6", "Color 6", "Color 6", core.rgb(128, 0, 255));
    indicator.parameters:addColor("clr7", "Color 7", "Color 7", core.rgb(128, 128, 0));
    indicator.parameters:addColor("clr8", "Color 8", "Color 8", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Period;
local Wave1=nil;
local Wave2=nil;
local Wave3=nil;
local Wave4=nil;
local Wave5=nil;
local Wave6=nil;
local Wave7=nil;
local Wave8=nil;

 function Prepare(nameOnly) 
    source = instance.source;
    first = source:first();
    local name = profile:id() .. "(" .. source:name() .. ")";
	Period = instance.parameters.Length;		
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
    Wave1 = instance:addStream("Wave1", core.Line, name .. ".Wave1", "Wave1", instance.parameters.clr1, first);
    Wave1:setPrecision(math.max(2, instance.source:getPrecision()));
    Wave2 = instance:addStream("Wave2", core.Line, name .. ".Wave2", "Wave2", instance.parameters.clr2, first);
    Wave2:setPrecision(math.max(2, instance.source:getPrecision()));
    Wave3 = instance:addStream("Wave3", core.Line, name .. ".Wave3", "Wave3", instance.parameters.clr3, first);
    Wave3:setPrecision(math.max(2, instance.source:getPrecision()));
    Wave4 = instance:addStream("Wave4", core.Line, name .. ".Wave4", "Wave4", instance.parameters.clr4, first);
    Wave4:setPrecision(math.max(2, instance.source:getPrecision()));
    Wave5 = instance:addStream("Wave5", core.Line, name .. ".Wave5", "Wave5", instance.parameters.clr5, first);
    Wave5:setPrecision(math.max(2, instance.source:getPrecision()));
    Wave6 = instance:addStream("Wave6", core.Line, name .. ".Wave6", "Wave6", instance.parameters.clr6, first);
    Wave6:setPrecision(math.max(2, instance.source:getPrecision()));
    Wave7 = instance:addStream("Wave7", core.Line, name .. ".Wave7", "Wave7", instance.parameters.clr7, first);
    Wave7:setPrecision(math.max(2, instance.source:getPrecision()));
    Wave8 = instance:addStream("Wave8", core.Line, name .. ".Wave8", "Wave8", instance.parameters.clr8, first);
    Wave8:setPrecision(math.max(2, instance.source:getPrecision()));
    Wave1:setWidth(instance.parameters.widthLinReg);
    Wave1:setStyle(instance.parameters.styleLinReg);
    Wave2:setWidth(instance.parameters.widthLinReg);
    Wave2:setStyle(instance.parameters.styleLinReg);
    Wave3:setWidth(instance.parameters.widthLinReg);
    Wave3:setStyle(instance.parameters.styleLinReg);
    Wave4:setWidth(instance.parameters.widthLinReg);
    Wave4:setStyle(instance.parameters.styleLinReg);
    Wave5:setWidth(instance.parameters.widthLinReg);
    Wave5:setStyle(instance.parameters.styleLinReg);
    Wave6:setWidth(instance.parameters.widthLinReg);
    Wave6:setStyle(instance.parameters.styleLinReg);
    Wave7:setWidth(instance.parameters.widthLinReg);
    Wave7:setStyle(instance.parameters.styleLinReg);
    Wave8:setWidth(instance.parameters.widthLinReg);
    Wave8:setStyle(instance.parameters.styleLinReg);
end

function Update(period, mode)
   if (period==source:size()-1) then
    local i;
    local x, y;
    local sumx, sumy, sumx2, sumy2 = 0, 0, 0, 0;
    local sumx22, sumy22;
    local sumxy=0;
    local div1, div2;
    local aB, aVal_0, aVal_1;
    local rRetError=0;
    local aMaxDev, aStdError;
    local y1, y2;
    local aArr={};
    --Period=math.floor((source:date(period)-source:date(period-1))*1440+0.5);

	
	if period < Period  then
	return;
	end
	
    for i=0,Period-1,1 do
     y=source[period-i];
     x=i;
     sumy=sumy+y;
     sumxy=sumxy+y*x;
     sumx=sumx+x;
     sumx2=sumx2+x*x;
     sumy2=sumy2+y*y;
    end
    sumx22=sumx*sumx;
    sumy22=sumy*sumy;
    div1=sumx2*Period-sumx22;
    div2=math.sqrt((Period*sumx2-sumx22)*(Period*sumy2-sumy22));
    if div1~=0 then
     aB=(sumxy*Period-sumx*sumy)/div1;
     aVal_0=(sumy-sumx*aB)/Period;
     aVal_1=aVal_0+aB*(Period-1);
     rRetError=rRetError-1;
    else
     rRetError=rRetError-1;
    end
    aMaxDev=0; 
    aStdError=0;
    for i=0,Period-1,1 do
     y1=source[period-i];
     y2=aVal_0+aB*i;
     aMaxDev=math.max(math.abs(y1-y2),aMaxDev);
     aStdError=aStdError+(y1-y2)*(y1-y2);
    end
    aStdError=math.sqrt(aStdError/Period);
    if div2~=0 then
     aRSquared=math.pow((Period*sumxy-sumx*sumy)/div2,2);
    else
     rRetError=rRetError-2;
    end
    for i=0,Period-1,1 do
     y=source[period-i];
     x=aVal_0+i*(aVal_1-aVal_0)/Period;
     aArr[i]=y-x;
    end
    
    local aA={};
    local aB={};
    local aR={};
    local aF={};
    local i2;
    
    local tM=math.max(Period/2,1);
    for i=1,tM-1,1 do
     aA[i]=0;
     aB[i]=0;
     for i2=0,Period-1,1 do
      aA[i]=aA[i]+aArr[i2]*math.sin(i*2*math.pi*i2/Period);
      aB[i]=aB[i]+aArr[i2]*math.cos(i*2*math.pi*i2/Period);
     end
     aA[i]=2*aA[i]/Period;
     aB[i]=2*aB[i]/Period;
     aR[i]=math.sqrt(aA[i]*aA[i]+aB[i]*aB[i]);
     aF[i]=math.atan2(aB[i],aA[i]);
    end
    
    for i=0,Period-1,1 do
     Wave1[period-i]=aA[1]*math.sin(2*math.pi*i/(Period-1))+aB[1]*math.cos(2*math.pi*i/(Period-1));
     Wave2[period-i]=aA[2]*math.sin(4*math.pi*i/(Period-1))+aB[2]*math.cos(4*math.pi*i/(Period-1));
     Wave3[period-i]=aA[3]*math.sin(6*math.pi*i/(Period-1))+aB[3]*math.cos(6*math.pi*i/(Period-1));
     Wave4[period-i]=aA[4]*math.sin(8*math.pi*i/(Period-1))+aB[4]*math.cos(8*math.pi*i/(Period-1));
     Wave5[period-i]=aA[5]*math.sin(10*math.pi*i/(Period-1))+aB[5]*math.cos(10*math.pi*i/(Period-1));
     Wave6[period-i]=aA[6]*math.sin(12*math.pi*i/(Period-1))+aB[6]*math.cos(12*math.pi*i/(Period-1));
     Wave7[period-i]=aA[7]*math.sin(14*math.pi*i/(Period-1))+aB[7]*math.cos(14*math.pi*i/(Period-1));
     Wave8[period-i]=aA[8]*math.sin(16*math.pi*i/(Period-1))+aB[8]*math.cos(16*math.pi*i/(Period-1));
    end
    
   end 

end


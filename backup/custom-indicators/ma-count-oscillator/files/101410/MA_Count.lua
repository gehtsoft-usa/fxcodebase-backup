-- Id: 14442

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62423


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
    indicator:name("MA Count Oscillator");
    indicator:description("MA Count Oscillator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 10);
    
    indicator.parameters:addString("Method" , "Type of Moving Average", "", "EMA");
    indicator.parameters:addStringAlternative("Method" , "Exponential Moving Average", "", "EMA");
    indicator.parameters:addStringAlternative("Method" , "Simple Moving Average", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "Smoothed Moving Average", "", "SMMA");
    indicator.parameters:addStringAlternative("Method" , "Linear Weighted Moving Average", "", "LWMA");

    
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Up Color", "Up Color", core.rgb(60, 121, 196));
    indicator.parameters:addColor("clr1", "Down Color", "Down Color", core.rgb(202, 242, 13));

    
    
end

local first;
local source = nil;
local Period;
local Buff;
local Ind;
local Method;
local clr, clr1;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    
    Method=instance.parameters.Method;
    clr=instance.parameters.clr;
    clr1=instance.parameters.clr1;


    local name = profile:id() .. "(" .. source:name().. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end

  
    

    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
    Ind=core.indicators:create(Method, source, Period);
    first = Ind.DATA:first(); 
	
	  Buff = instance:addStream("buff", core.Bar, name .. ".buff", "buff", instance.parameters.clr, first);
      Buff:setPrecision(math.max(2, instance.source:getPrecision()));  
end

function Update(period, mode)
     Ind:update(mode);
    if period==source:size()-1 then
    
    local i;

        for i=Period+first+1, period, 1 do 
            
           
            if source[i]>Ind.DATA[i]  then
            Buff[i]=Buff[i-1]+1; 
            
                if source[i-1]<Ind.DATA[i-1] then
                Buff[i]=1; 
                end 
            end

            if source[i]<Ind.DATA[i]  then
            Buff:setColor(i,clr1);    
            Buff[i]=Buff[i-1]-1; 
            
            
                if source[i-1]>Ind.DATA[i-1] then
                Buff[i]=-1; 
                end 
            end
        end 

    end
  
 
end


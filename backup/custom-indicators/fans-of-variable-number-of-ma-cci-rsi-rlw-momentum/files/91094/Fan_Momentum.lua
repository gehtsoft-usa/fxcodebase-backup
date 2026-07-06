-- Id: 10492
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1102

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
    indicator:name("FAN of Momentum");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addInteger("Period_1", "First period", "No description", 5);
    indicator.parameters:addString("Method", "Method", "", "Add");
    indicator.parameters:addStringAlternative("Method", "Add", "", "Add");
    indicator.parameters:addStringAlternative("Method", "Mult", "", "Mult");

    indicator.parameters:addInteger("K", "K", "K", 2);
    indicator.parameters:addInteger("N", "Count of Momentum", "Count of Momentum", 5);
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);

end

local Period1;
local K;
local N;
local Method;

local first;
local source = nil;
local buffs={};

local Inds={};

function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" .. instance.source:name() .. ", " .. Period1 .. ", " .. K .. ", " .. N .. ", " .. Method .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
    Period1 = instance.parameters.Period_1;
    K = instance.parameters.K;
    N = instance.parameters.N;
    Method = instance.parameters.Method;
    source = instance.source;
    local Period=Period1;
	
	assert(core.indicators:findIndicator("MOMENTUM") ~= nil, "Please, download and install MOMENTUM.LUA indicator");   
	
	
    for i=1,N,1 do
     Ind=core.indicators:create("MOMENTUM", source, Period);
     Inds[i]=Ind;
     if Method=="Mult" then
      Period=Period*K;
     else
      Period=Period+K;
     end 
    end
    
    first = Inds[N].DATA:first()+2;
   
    
    for i=1,N,1 do
     if i<N/3 then
      Color=core.rgb(i*155*3/N+100,0,0);
     elseif i>=N/3 and i<2*N/3 then
      Color=core.rgb(0,(i-N/3)*155/N+100,0);
     else
      Color=core.rgb(0,0,(i-N*2/3)*155/N+100);
     end 
     buffs[i] = instance:addStream("buff" .. i, core.Line, name .. ".buff" .. i, "buff" .. i, Color, first);
    buffs[i]:setPrecision(math.max(2, instance.source:getPrecision()));
     buffs[i]:setWidth(instance.parameters.widthLinReg);
     buffs[i]:setStyle(instance.parameters.styleLinReg);
    end
end

function Update(period, mode)
 if (period>first) then
  for i=1,N,1 do
   Inds[i]:update(mode);
   buffs[i][period]=Inds[i].DATA[period];
  end
  
 end 
end


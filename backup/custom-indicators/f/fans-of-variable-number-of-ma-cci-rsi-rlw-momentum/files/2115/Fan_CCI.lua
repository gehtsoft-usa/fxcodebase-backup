-- Id: 744
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
    indicator:name("FAN of CCI");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    
	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period_1", "First period", "First period", 5);
    indicator.parameters:addString("Method", "Method", "", "Add");
    indicator.parameters:addStringAlternative("Method", "Add", "", "Add");
    indicator.parameters:addStringAlternative("Method", "Mult", "", "Mult");

    indicator.parameters:addInteger("K", "K", "K", 2);
    indicator.parameters:addInteger("N", "Count of CCI", "Count of CCI", 5);
	
	
	indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 100);
    indicator.parameters:addDouble("oversold","Oversold Level","", -100);
	indicator.parameters:addDouble("zero","Central Line Level","", 0);
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);

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
    for i=1,N,1 do
     Ind=core.indicators:create("CCI", source, Period);
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
	 buffs[1]:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	 buffs[1]:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	 buffs[1]:addLevel(instance.parameters.zero, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
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


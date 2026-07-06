-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2342

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
    indicator:name("Regression color indicator");
    indicator:description("Regression color indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "Number of periods", "Number of periods", 14, 2, 1000);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrLinRegUP", "Line color UP", "Line color UP", core.rgb(255, 0, 0));
    indicator.parameters:addColor("clrLinRegDN", "Line color DN", "Line color DN", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local n;
local Regression;
local BuffUP=nil;
local BuffDN=nil;

function Prepare(nameOnly)   
    source = instance.source;
    n = instance.parameters.N;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.N .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	
	assert(core.indicators:findIndicator("REGRESSION") ~= nil, "Please, download and install REGRESSION.LUA indicator"); 
    Regression = core.indicators:create("REGRESSION", source, n);
    first = Regression.DATA:first()+2;
    BuffUP = instance:addStream("BuffUP", core.Line, name .. ".UP", "UP", instance.parameters.clrLinRegUP, first);
    BuffDN = instance:addStream("BuffDN", core.Line, name .. ".DN", "DN", instance.parameters.clrLinRegDN, first);
    BuffUP:setWidth(instance.parameters.widthLinReg);
    BuffUP:setStyle(instance.parameters.styleLinReg);
    BuffDN:setWidth(instance.parameters.widthLinReg);
    BuffDN:setStyle(instance.parameters.styleLinReg);
    
end

function Update(period, mode)
   Regression:update(mode);
   if (period>first) then
    if Regression.DATA[period]>Regression.DATA[period-1] then
     BuffUP[period]=Regression.DATA[period];
     if Regression.DATA[period-1]<Regression.DATA[period-2] then
      BuffUP[period-1]=Regression.DATA[period-1];
     end
    else
     BuffDN[period]=Regression.DATA[period];
     if Regression.DATA[period-1]>Regression.DATA[period-2] then
      BuffDN[period-1]=Regression.DATA[period-1];
     end
    end
   end 
    
end


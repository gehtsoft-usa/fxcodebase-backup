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
    indicator:name("Regression color indicator (Dot version)");
    indicator:description("Regression color indicator (Dot version)");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "Number of periods", "Number of periods", 14, 2, 1000);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrLine", "Color Line", "Color Line", core.rgb(0, 0, 255));
    indicator.parameters:addColor("clrUP", "Color UP", "Color UP", core.rgb(255, 0, 0));
    indicator.parameters:addColor("clrDN", "Color DN", "Color DN", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local n;
local Regression;
local BuffLine=nil;
local BuffUP=nil;
local BuffDN=nil;

function Prepare(nameOnly)   
    source = instance.source;
    n = instance.parameters.N;
   
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.N .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	assert(core.indicators:findIndicator("REGRESSION") ~= nil, "Please, download and install REGRESSION.LUA indicator"); 
	Regression = core.indicators:create("REGRESSION", source, n);
    first = Regression.DATA:first()+2;
	
	
    BuffLine = instance:addStream("BuffLine", core.Line, name .. ".Line", "Line", instance.parameters.clrLine, first);
    BuffUP = instance:addStream("BuffUP", core.Dot, name .. ".UP", "UP", instance.parameters.clrUP, first);
    BuffDN = instance:addStream("BuffDN", core.Dot, name .. ".DN", "DN", instance.parameters.clrDN, first);
    BuffLine:setWidth(instance.parameters.widthLinReg);
    BuffLine:setStyle(instance.parameters.styleLinReg);
    BuffUP:setWidth(instance.parameters.widthLinReg);
    BuffDN:setWidth(instance.parameters.widthLinReg);
    
end

function Update(period, mode)
   Regression:update(mode);
   if (period>first) then
    BuffLine[period]=Regression.DATA[period];
    if Regression.DATA[period]>Regression.DATA[period-1] then
     BuffUP[period]=Regression.DATA[period];
    else
     BuffDN[period]=Regression.DATA[period];
    end
   end 
    
end


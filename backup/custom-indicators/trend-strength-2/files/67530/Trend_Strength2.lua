-- Id: 9339

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=41303

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
    indicator:name("Trend Strength 2 oscillator");
    indicator:description("Trend Strength 2 oscillator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 14);
    indicator.parameters:addInteger("Smooth", "Smooth", "", 5);
    indicator.parameters:addDouble("K", "K", "", 4.236);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("MainClr", "Main color", "Main color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("UPclr", "UP color", "UP color", core.rgb(0, 0, 255));
    indicator.parameters:addColor("DNclr", "DN color", "DN color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Period;
local Smooth;
local K;
local delta1, delta2, upband, loband, trend;
local RSI;
local alpha;
local TS=nil;
local UP=nil;
local DN=nil;

function Prepare(nameOnly) 
    source = instance.source;
    Period=instance.parameters.Period;
    Smooth=instance.parameters.Smooth;
    K=instance.parameters.K;
    first = source:first()+Period;
    
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.Smooth .. ", " .. instance.parameters.K .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	RSI = core.indicators:create("RSI", source, Period);
    delta1 = instance:addInternalStream(first, 0);
    delta2 = instance:addInternalStream(first, 0);
    upband = instance:addInternalStream(first, 0);
    loband = instance:addInternalStream(first, 0);
    trend = instance:addInternalStream(first, 0);
	
	
    TS = instance:addStream("TS", core.Line, name .. ".TS", "TS", instance.parameters.MainClr, first);
    UP = instance:addStream("UP", core.Line, name .. ".UP", "UP", instance.parameters.UPclr, first);
    DN = instance:addStream("DN", core.Line, name .. ".DN", "DN", instance.parameters.DNclr, first);
    TS:setWidth(instance.parameters.widthLinReg);
    TS:setStyle(instance.parameters.styleLinReg);
    UP:setWidth(instance.parameters.widthLinReg);
    UP:setStyle(instance.parameters.styleLinReg);
    DN:setWidth(instance.parameters.widthLinReg);
    DN:setStyle(instance.parameters.styleLinReg);
    alpha=1/Period;
	
	TS:setPrecision(math.max(2, instance.source:getPrecision()));
	UP:setPrecision(math.max(2, instance.source:getPrecision()));
	DN:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)
   if period>first then
    RSI:update(mode);
    TS[period]=TS[period-1]+2/(Smooth+1)*(RSI.DATA[period]-TS[period-1]);
    local hiRSI, loRSI = math.max(TS[period], TS[period-1]), math.min(TS[period], TS[period-1]);
    local rangeRSI = hiRSI-loRSI;
    delta1[period]=delta1[period-1]+alpha*(rangeRSI-delta1[period-1]);
    delta2[period]=delta2[period-1]+alpha*(delta1[period]-delta2[period-1]);
    upband[period]=TS[period]+K*delta2[period];
    loband[period]=TS[period]-K*delta2[period];
    trend[period]=trend[period-1];
    if TS[period]>upband[period-1] then
     trend[period]=1;
    elseif TS[period]<loband[period-1] then
     trend[period]=-1;
    end
    if trend[period]==1 then
     if loband[period]<loband[period-1] then
      loband[period]=loband[period-1];
     end
     UP[period]=loband[period];
     DN[period]=nil;
    else
     if upband[period]>upband[period-1] then
      upband[period]=upband[period-1];
     end
     DN[period]=upband[period];
     UP[period]=nil;
    end 
   end 
end


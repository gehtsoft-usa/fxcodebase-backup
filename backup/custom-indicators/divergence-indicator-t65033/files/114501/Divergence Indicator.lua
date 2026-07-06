-- Id: 18913

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65033&p=114501#p114501

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
    indicator:name("Divergence Indicator");
    indicator:description("Divergence Indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");	
	indicator.parameters:addString("INDICATOR", "Indicator", "", "RSI");
    indicator.parameters:setFlag("INDICATOR",core.FLAG_INDICATOR);
    indicator.parameters:addColor("BullishColor", "Color of Bullish", "Color of Line", core.rgb(0, 255, 0));
    indicator.parameters:addColor("BearishColor", "Color of Bearish", "Color of Line", core.rgb(255, 0, 0));
end

local Source;
local IndiInstance;
local First;
local BullishPrice;
local BearishPrice;
local OBD = nil;
local NBD, HBD
local Bullish = {};
local Bearish = {};

-- initializes the instance of the indicator
function Prepare(nameOnly)

    local name =  profile:id();
    name = name..", ("  ..  instance.parameters:getString("INDICATOR") .. ")";  	
	instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
    Source = instance.source;   
    local tmpprofile = core.indicators:findIndicator(instance.parameters:getString("INDICATOR"));
    local tmpparams = instance.parameters:getCustomParameters("INDICATOR");

    IndiInstance = tmpprofile:createInstance(Source, tmpparams);

    First = IndiInstance.DATA:first();    
       
    BullishPrice = Source.low;
    BearishPrice = Source.high;
        
    NBullishD = instance:addStream("NBullD", core.Bar, "Normal Bullish Divergence", "NormalBullD", instance.parameters.BullishColor, First);
    NBullishD:setPrecision(math.max(2, instance.source:getPrecision()));
    NBullishD:setWidth(300)

    HBullishD = instance:addStream("HBullD", core.Bar, "Hidden Bullish Divergence", "HiddenBullD", instance.parameters.BullishColor, First);    
    HBullishD:setPrecision(math.max(2, instance.source:getPrecision()));
    HBullishD:setWidth(100);

    NBearishD = instance:addStream("NBearD", core.Bar, "Normal Bearish Divergence", "NormalBearD", instance.parameters.BearishColor, First);
    NBearishD:setPrecision(math.max(2, instance.source:getPrecision()));
    NBearishD:setWidth(300)

    HBearishD = instance:addStream("HBearD", core.Bar, "Hidden Bearish Divergence", "HiddenBearD", instance.parameters.BearishColor, First);    
    HBearishD:setPrecision(math.max(2, instance.source:getPrecision()));
    HBearishD:setWidth(100);
    
    initBullish();
    initBearish();
end

function Update(period)
	if period < First +1 then
        return;
	end
	
    IndiInstance:update(mode);
    
    BullishAnalyze(period);
    BearishAnalyze(period);
end

function initBullish()
    Bullish.CurrentPriceMin = {};
    Bullish.LastPriceMin = {};
    Bullish.TempPriceMin = {};
    Bullish.CurrentOSCMin = {};
    Bullish.TempOSCMin = {};
    Bullish.LastOSCMin = {};
end

function initBearish()
    Bearish.CurrentPriceMax = {};
    Bearish.LastPriceMax = {};
    Bearish.TempPriceMax = {};
    Bearish.CurrentOSCMax = {};
    Bearish.TempOSCMax = {};
    Bearish.LastOSCMax = {};
end
    
function BullishAnalyze(period)

    if (BullishPrice[period] > BullishPrice[period -1]) and (BullishPrice[period - 1] < BullishPrice[period -2]) then
            
        if Bullish.TempPriceMin.Left == nil then
            Bullish.TempPriceMin.Left = BullishPrice[period];
            Bullish.TempOSCMin.Left = IndiInstance.DATA[period];
        else    
            Bullish.TempPriceMin.Right = BullishPrice[period];
            Bullish.TempOSCMin.Right = IndiInstance.DATA[period];
        end
            
        if Bullish.TempPriceMin.Left ~= nil and Bullish.TempPriceMin.Right ~= nil then
            Bullish.LastPriceMin = Bullish.CurrentPriceMin;
            Bullish.CurrentPriceMin = Bullish.TempPriceMin;
            
            Bullish.LastOSCMin = Bullish.CurrentOSCMin;
            Bullish.CurrentOSCMin = Bullish.TempOSCMin;
            Bullish.TempPriceMin = {};
        end 
        
        if Bullish.CurrentPriceMin.Left ~= nil and Bullish.CurrentPriceMin.Right then
            if Bullish.LastPriceMin.Left ~= nil and Bullish.LastPriceMin.Right then
                local bullishNDivCurrent = Bullish.CurrentPriceMin.Left > Bullish.CurrentPriceMin.Right and Bullish.CurrentOSCMin.Left < Bullish.CurrentOSCMin.Right
                local bullishNDivLast = Bullish.LastPriceMin.Left > Bullish.LastPriceMin.Right and Bullish.LastOSCMin.Left < Bullish.LastOSCMin.Right
                
                local bullishHDivCurrent = Bullish.CurrentPriceMin.Left < Bullish.CurrentPriceMin.Right and Bullish.CurrentOSCMin.Left > Bullish.CurrentOSCMin.Right
                local bullishHDivLast = Bullish.LastPriceMin.Left < Bullish.LastPriceMin.Right and Bullish.LastOSCMin.Left > Bullish.LastOSCMin.Right
                
                bullishNSig = bullishNDivCurrent and not bullishNDivLast and BullishPrice[period -1] < BullishPrice[period]
                bullishHSig = bullishHDivCurrent and not bullishHDivLast and BullishPrice[period -1] > BullishPrice[period]
                
                NBullishD[period] = bullishNSig == true and 1 or 0;
                HBullishD[period] = bullishHSig == true and 1 or 0;
            end
        end
    end
end 

function BearishAnalyze(period)
    if (BearishPrice[period] < BearishPrice[period -1]) and (BearishPrice[period - 1] < BearishPrice[period -2]) then
                
            if Bearish.TempPriceMax.Left == nil then
                Bearish.TempPriceMax.Left = BearishPrice[period];
                Bearish.TempOSCMax.Left = IndiInstance.DATA[period];
            else    
                Bearish.TempPriceMax.Right = BearishPrice[period];
                Bearish.TempOSCMax.Right = IndiInstance.DATA[period];
            end
                
            if Bearish.TempPriceMax.Left ~= nil and Bearish.TempPriceMax.Right ~= nil then
                Bearish.LastPriceMax = Bearish.CurrentPriceMax;
                Bearish.CurrentPriceMax = Bearish.TempPriceMax;
                
                Bearish.LastOSCMax = Bearish.CurrentOSCMax;
                Bearish.CurrentOSCMax = Bearish.TempOSCMax;
                Bearish.TempPriceMax = {};
            end 
            
            if Bearish.CurrentPriceMax.Left ~= nil and Bearish.CurrentPriceMax.Right then
                if Bearish.LastPriceMax.Left ~= nil and Bearish.LastPriceMax.Right then
                    local bearishNDivCurrent = Bearish.CurrentPriceMax.Left < Bearish.CurrentPriceMax.Right and Bearish.CurrentOSCMax.Left > Bearish.CurrentOSCMax.Right
                    local bearishNDivLast = Bearish.LastPriceMax.Left < Bearish.LastPriceMax.Right and Bearish.LastOSCMax.Left > Bearish.LastOSCMax.Right
                    
                    local bearishHDivCurrent = Bearish.CurrentPriceMax.Left > Bearish.CurrentPriceMax.Right and Bearish.CurrentOSCMax.Left < Bearish.CurrentOSCMax.Right
                    local bearishHDivLast = Bearish.LastPriceMax.Left > Bearish.LastPriceMax.Right and Bearish.LastOSCMax.Left < Bearish.LastOSCMax.Right
                    
                    bearishNSig = bearishNDivCurrent and not bearishNDivLast and BearishPrice[period -1] < BearishPrice[period]
                    bearishHSig = bearishHDivCurrent and not bearishHDivLast and BearishPrice[period -1] > BearishPrice[period]
                    
                    NBearishD[period] = bearishNSig == true and 1 or 0;
                    HBearishD[period] = bearishHSig == true and 1 or 0;
                end
            end
        end
end


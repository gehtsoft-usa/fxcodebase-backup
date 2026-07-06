-- Id: 14499

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62412

--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
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
    indicator:name("Laguerre volume oscillator with Real volume/Transactions");
    indicator:description("Laguerre volume oscillator with Real volume/Transactions");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("Ind", "Type of indicator", "", "Volume");
    indicator.parameters:addStringAlternative("Ind", "Volume", "", "Volume");
    indicator.parameters:addStringAlternative("Ind", "Transactions", "", "Transactions");
    indicator.parameters:addDouble("gamma", "gamma", "", 0.618);
    indicator.parameters:addDouble("HighLevel", "HighLevel", "", 0.75);
    indicator.parameters:addDouble("MiddleLevel", "MiddleLevel", "", 0.5);
    indicator.parameters:addDouble("LowLevel", "LowLevel", "", 0.25);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(255, 255, 0));
    indicator.parameters:addColor("Lclr", "Level color", "Level color", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local gamma;
local HighLevel;
local MiddleLevel;
local LowLevel;
local L0, L1, L2, L3;
local LV=nil;
local Ind;

local FirstStart;
local LastTime;

function Prepare(nameOnly)
    source = instance.source;
    gamma=instance.parameters.gamma;
    HighLevel=instance.parameters.HighLevel;
    MiddleLevel=instance.parameters.MiddleLevel;
    LowLevel=instance.parameters.LowLevel;
	
	 local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.gamma .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end	
	
	
    first = source:first()+5;
     if instance.parameters.Ind=="Volume" then
      Ind=core.indicators:create("REAL VOLUME", source);
     else
      Ind=core.indicators:create("TRANSACTIONS", source);
     end
    L0=instance:addInternalStream(first, 0);
    L1=instance:addInternalStream(first, 0);
    L2=instance:addInternalStream(first, 0);
    L3=instance:addInternalStream(first, 0);
   
	
    LV = instance:addStream("LV", core.Line, name .. ".LV", "LV", instance.parameters.clr, first);
    LV:setPrecision(math.max(2, instance.source:getPrecision()));
    LV:setWidth(instance.parameters.widthLinReg);
    LV:setStyle(instance.parameters.styleLinReg);
    LV:addLevel(HighLevel, core.LINE_DASH, 1, instance.parameters.Lclr);
    LV:addLevel(MiddleLevel, core.LINE_DASH, 1, instance.parameters.Lclr);
    LV:addLevel(LowLevel, core.LINE_DASH, 1, instance.parameters.Lclr);
    FirstStart=true;
    LastTime=0;
end

function Update(period, mode)
   if period>first then
        Ind:update(mode);
        if not(Ind.DATA:hasData(period)) then
            if period==first+1 then
                FirstStart=true;
            end    
            return;
        elseif FirstStart then
            FirstStart=false;
            instance:updateFrom(first);    
        elseif LastTime~=source:date(period) and period==source:size()-1 then
            LastTime=source:date(period);
            instance:updateFrom(period-2);
        end
    L0[period]=(1-gamma)*Ind.DATA[period]+gamma*L0[period-1];
    L1[period]=L0[period-1]+gamma*(L1[period-1]-L0[period]);
    L2[period]=L1[period-1]+gamma*(L2[period-1]-L1[period]);
    L3[period]=L2[period-1]+gamma*(L3[period-1]-L2[period]);
    local CU, CD = 0, 0;
    if L0[period]>=L1[period] then
     CU=L0[period]-L1[period];
    else
     CD=L1[period]-L0[period];
    end
    if L1[period]>=L2[period] then
     CU=CU+L1[period]-L2[period];
    else
     CD=CD+L2[period]-L1[period];
    end
    if L2[period]>=L3[period] then
     CU=CU+L2[period]-L3[period];
    else
     CD=CD+L3[period]-L2[period];
    end
    if CU+CD~=0 then
     LV[period]=CU/(CU+CD);
    else
     LV[period]=0;
    end
   elseif period==first then
    L0[period]=0; 
    L1[period]=0; 
    L2[period]=0; 
    L3[period]=0; 
   end 
end

function AsyncOperationFinished(cookie, success, message)

end

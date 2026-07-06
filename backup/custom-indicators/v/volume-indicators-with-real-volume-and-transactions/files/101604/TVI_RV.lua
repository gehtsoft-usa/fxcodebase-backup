-- Id: 14582

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
    indicator:name("Tick volume indicator with Real volume/Transactions");
    indicator:description("Tick volume indicator with Real volume/Transactions");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("Ind", "Type of indicator", "", "Volume");
    indicator.parameters:addStringAlternative("Ind", "Volume", "", "Volume");
    indicator.parameters:addStringAlternative("Ind", "Transactions", "", "Transactions");
    indicator.parameters:addInteger("Period1", "Period 1", "", 12);
    indicator.parameters:addInteger("Period2", "Period 2", "", 12);
    indicator.parameters:addInteger("Period3", "Period 3", "", 5);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Period1;
local Period2;
local Period3;
local UpTicks, DnTicks;
local EMA_Up1, EMA_Dn1;
local EMA_Up2, EMA_Dn2;
local TV;
local EMA_TV;
local TVI=nil;
local pipSize;
local Ind;

local FirstStart;
local LastTime;

function Prepare(nameOnly)
    source = instance.source;
    Period1=instance.parameters.Period1;
    Period2=instance.parameters.Period2;
    Period3=instance.parameters.Period3;
    first = source:first()+2;
	
	
	 local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period1 .. ", " .. instance.parameters.Period2 .. ", " .. instance.parameters.Period3 .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
     if instance.parameters.Ind=="Volume" then
      Ind=core.indicators:create("REAL VOLUME", source);
     else
      Ind=core.indicators:create("TRANSACTIONS", source);
     end
     FirstStart=true;
     LastTime=0;
    UpTicks = instance:addInternalStream(first, 0);
    DnTicks = instance:addInternalStream(first, 0);
    TV = instance:addInternalStream(first, 0);
    EMA_Up1 = core.indicators:create("EMA", UpTicks, Period1);
    EMA_Dn1 = core.indicators:create("EMA", DnTicks, Period1);
    EMA_Up2 = core.indicators:create("EMA", EMA_Up1.DATA, Period2);
    EMA_Dn2 = core.indicators:create("EMA", EMA_Dn1.DATA, Period2);
    EMA_TV = core.indicators:create("EMA", TV, Period3);
   
	
    TVI = instance:addStream("TVI", core.Line, name .. ".TVI", "TVI", instance.parameters.clr, first);
    TVI:setPrecision(math.max(2, instance.source:getPrecision()));
    TVI:setWidth(instance.parameters.widthLinReg);
    TVI:setStyle(instance.parameters.styleLinReg);
    pipSize=source:pipSize();
end

function AsyncOperationFinished(cookie, success, message)

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
            instance:updateFrom(period-10);
        end
    UpTicks[period]=(Ind.DATA[period]+(source.close[period]-source.open[period])/pipSize)/2;
    DnTicks[period]=Ind.DATA[period]-UpTicks[period];
    EMA_Up1:update(mode);
    EMA_Dn1:update(mode);
    EMA_Up2:update(mode);
    EMA_Dn2:update(mode);
    local sum=EMA_Up2.DATA[period]+EMA_Dn2.DATA[period];
    if sum~=0 then
     TV[period]=100*(EMA_Up2.DATA[period]-EMA_Dn2.DATA[period])/sum;
    end 
    EMA_TV:update(mode);
    TVI[period]=EMA_TV.DATA[period];
   end 
end


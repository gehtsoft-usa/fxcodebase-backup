-- Id: 14562
--                                 Symphonie Extreme Indicator v3.0 
--                                         Copyright � William Blau 
--                           Originally coded � 2006 by Profitrader 



-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62412

--+------------------------------------------------------------------+
--|                               Copyright � 2017, Gehtsoft USA LLC | 
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
    indicator:name("Symphonie Extreme indicator with Real volume/Transactions");
    indicator:description("Symphonie Extreme indicator with Real volume/Transactions");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("Ind", "Type of indicator", "", "Volume");
    indicator.parameters:addStringAlternative("Ind", "Volume", "", "Volume");
    indicator.parameters:addStringAlternative("Ind", "Transactions", "", "Transactions");
    indicator.parameters:addInteger("r", "r", "", 12);
    indicator.parameters:addInteger("s", "s", "", 12);
    indicator.parameters:addInteger("u", "u", "", 5);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UpPosClr", "Up Positive Color", "Up Positive Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("UpNegClr", "Up Negative Color", "Up Negative Color", core.rgb(0, 128, 0));
    indicator.parameters:addColor("DnPosClr", "Dn Positive Color", "Dn Positive Color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("DnNegClr", "Dn Negative Color", "Dn Negative Color", core.rgb(128, 0, 0));
end

local first;
local source = nil;
local r, s, u;
local UpTicks, DnTicks;
local UpEMA, DnEMA;
local UpDEMA, DnDEMA;
local TVI;
local pipSize;
local Symp_Extreme=nil;
local Ind;

local FirstStart;
local LastTime;

function Prepare(nameOnly)
    source = instance.source;
    r=instance.parameters.r;
    s=instance.parameters.s;
    u=instance.parameters.u;
	
	local name = profile:id() .. "(" .. source:name() .. ", " .. r .. ", " .. s .. ", " .. u .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
    first = source:first()+2;
    UpTicks=instance:addInternalStream(first, 0);
    DnTicks=instance:addInternalStream(first, 0);
    UpEMA=core.indicators:create("EMA", UpTicks, r);
    DnEMA=core.indicators:create("EMA", DnTicks, r);
    UpDEMA=core.indicators:create("EMA", UpEMA.DATA, s);
    DnDEMA=core.indicators:create("EMA", DnEMA.DATA, s);
     if instance.parameters.Ind=="Volume" then
      Ind=core.indicators:create("REAL VOLUME", source);
     else
      Ind=core.indicators:create("TRANSACTIONS", source);
     end
     FirstStart=true;
     LastTime=0;
    TVI_Raw=instance:addInternalStream(first, 0);
    TVI=core.indicators:create("EMA", TVI_Raw, u);
    
    Symp_Extreme = instance:addStream("Symp_Extreme", core.Bar, name .. ".Symp_Extreme", "Symp_Extreme", instance.parameters.UpPosClr, first);
    Symp_Extreme:setPrecision(math.max(2, instance.source:getPrecision()));
    pipSize=source:pipSize();
end

function AsyncOperationFinished(cookie, success, message)

end

function Update(period, mode)
   if (period>first) then
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
    UpEMA:update(mode);
    DnEMA:update(mode);
    UpDEMA:update(mode);
    DnDEMA:update(mode);
    if UpDEMA.DATA[period]+DnDEMA.DATA[period]~=0 then
     TVI_Raw[period]=100*(UpDEMA.DATA[period]-DnDEMA.DATA[period])/(UpDEMA.DATA[period]+DnDEMA.DATA[period]);
    else
     TVI_Raw[period]=0;
    end 
    TVI:update(mode);
    Symp_Extreme[period]=TVI.DATA[period];
    if TVI.DATA[period]>TVI.DATA[period-1] then
     if TVI.DATA[period]>=0 then
      Symp_Extreme:setColor(period,instance.parameters.UpPosClr);
     else
      Symp_Extreme:setColor(period,instance.parameters.UpNegClr);
     end
    else
     if TVI.DATA[period]>=0 then
      Symp_Extreme:setColor(period,instance.parameters.DnPosClr);
     else
      Symp_Extreme:setColor(period,instance.parameters.DnNegClr);
     end
    end
   end 
end


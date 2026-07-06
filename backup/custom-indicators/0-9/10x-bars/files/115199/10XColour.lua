-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65137

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
       indicator:name("10X Bars indicator");
       indicator:description("Interpretation of John Carter's 10X Bars");
       indicator:requiredSource(core.Bar);
       indicator:type(core.Indicator);
	   
	   indicator.parameters:addGroup("Calculation");
	   indicator.parameters:addInteger("MVAVPeriod", "Periods of Volume SMA", "", 20, 1, 300);
       indicator.parameters:addDouble("VPercent","Percentage of Volume above the SMA", "",50, 1, 100);
       
       indicator.parameters:addInteger("ADXPeriod", "Period ADX", "Number of Periods", 14);
       indicator.parameters:addDouble("ADXLevel", "ADX Strength level", "Minimum level ADX needs to be above", 20);
       
       indicator.parameters:addInteger("DMIPeriod", "Period DMI", "Number of Periods", 14);
	   
	   
       indicator.parameters:addGroup("Style");  
       indicator.parameters:addColor("clrA", "Ascending color", "", core.rgb(0, 255, 0));
       indicator.parameters:addColor("clrD", "Descending color", "", core.rgb(255, 0, 0));
       indicator.parameters:addColor("clrAC", "Ascending conviction color", "", core.rgb(128, 255, 255));
       indicator.parameters:addColor("clrDC", "Descending conviction color", "", core.rgb(255, 128, 255));
       indicator.parameters:addColor("clrR", "Range color", "", core.rgb(255, 255, 0));
       

       
       
   end
 
   local source;
   local o, h, l, c, v;
   local MVAV, ADX, DMI;
   local n;
   local first;
 
function Prepare(nameOnly)
        n = math.max(instance.parameters.MVAVPeriod, instance.parameters.ADXPeriod, instance.parameters.DMIPeriod);
        source = instance.source;
        first = source:first() + n - 1;
        local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.MVAVPeriod..", "..instance.parameters.ADXPeriod..", "..instance.parameters.DMIPeriod .. ")";
        instance:name(name);
		
		if   (nameOnly) then
        return;
    end

        o =  instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first)
        h =  instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first)
        l  =  instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
        c =  instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first)
        v  =  instance:addStream("volume", core.Line, name, "volume", core.rgb(0, 0, 0), first)
        instance:createCandleGroup(source:name(), source:name(), o, h, l, c, v);
 
        ADX = core.indicators:create("ADX", source, ADXPeriod);
        DMI = core.indicators:create("DMI", source, DMIPeriod);
        MVAV = instance:addInternalStream(first + 1, 0);
        
   end
 
   function Update(period, mode)
        local volpercent = 0;
        
        if period >= first then
            MVAV[period] = mathex.avg(source.volume, period - n + 1, period);
            
            if MVAV[period] < source.volume[period] then
                volpercent = source.volume[period] - MVAV[period]
                volpercent = (volpercent / MVAV[period]) * 100
            else
                local volpercent = 0
            end
            
            ADX:update(mode);
            DMI:update(mode);
           
            if period >= first + 1 then
                o[period] = source.open[period];
                c[period] = source.close[period];
                h[period] = source.high[period];
                l[period] = source.low[period];
                v[period] = source.volume[period];
                if ADX.DATA[period] <= instance.parameters.ADXLevel then
                    o:setColor(period, instance.parameters.clrR);
                else
                    if DMI.DIP[period] > DMI.DIM[period] then
                        if volpercent > instance.parameters.VPercent then
                            o:setColor(period, instance.parameters.clrAC);
                        else
                            o:setColor(period, instance.parameters.clrA);
                        end
                    else
                        if volpercent > instance.parameters.VPercent then
                            o:setColor(period, instance.parameters.clrDC);
                        else
                            o:setColor(period, instance.parameters.clrD);
                        end    
                    end
                end
            end
        end
   end
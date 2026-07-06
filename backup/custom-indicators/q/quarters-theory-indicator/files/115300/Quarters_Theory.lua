-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65158

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
    indicator:name("Quarters Theory");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	indicator.parameters:addColor("LRclr", "Round numbers Label Color", "", core.rgb(200, 0, 0)); 
    indicator.parameters:addColor("Rclr", "Round numbers Line Color", "", core.rgb(255, 0, 0)); 
    indicator.parameters:addInteger("Rstyle", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Rstyle", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("LQclr", "Quarter points Label Color", "", core.rgb(200, 200, 0)); 
    indicator.parameters:addColor("Qclr", "Quarter points Line Color", "", core.rgb(255, 255, 0)); 
    indicator.parameters:addInteger("Qstyle", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Qstyle", core.FLAG_LINE_STYLE);
	
	
	
	indicator.parameters:addColor("LHclr", "Half points Label Color", "", core.rgb(0, 200, 0)); 
    indicator.parameters:addColor("Hclr", "Half points Line Color", "", core.rgb(0, 255, 0)); 
    indicator.parameters:addInteger("Hstyle", "Line style", "", core.LINE_DASH);
    indicator.parameters:setFlag("Hstyle", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("LEclr", "Hesitation points Label Color", "", core.rgb(0, 0, 200)); 
    indicator.parameters:addColor("Eclr", "Hesitation points Line Color", "", core.rgb(0, 0, 255)); 
    indicator.parameters:addInteger("Estyle", "Line style", "", core.LINE_DASH);
    indicator.parameters:setFlag("Estyle", core.FLAG_LINE_STYLE);
	
	
    indicator.parameters:addInteger("Rwidth", "Round numbers size", "", 3);
    indicator.parameters:addInteger("Qwidth", "Quarter points size", "", 2);
    indicator.parameters:addInteger("Hwidth", "Half points size", "", 1);
    indicator.parameters:addInteger("Ewidth", "Hesitation points size", "", 1);

    indicator.parameters:addDouble("PS", "Manual pip value (0 - Autocalculation)", "", 0);
end

local source = nil;
local first;
local PS;
local LastSize;
local Rarr={};
local Rcount=0;
local Qarr={};
local Qcount=0;
local Harr={};
local Hcount=0;
local Earr={};
local Ecount=0;
local Precision;

 function Prepare(nameOnly)   
    source = instance.source;
    first=source:first();
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end


    instance:ownerDrawn(true);
    
    PS = instance.parameters.PS;
    if PS<=0 then
        PS=source:pipSize();
    end
    Precision=source:getPrecision();
    instance:setLabelColor(instance.parameters.Rclr);
end

function FindLevel(Val, Arr, Count)
    local i;
    for i=1, Count, 1 do
        if math.abs(Val-Arr[i])<=PS then
            return true;
        end
    end
    return false;
end

function Update(period)
    if period==source:size()-1 then
        if LastSize~=source:size()-1 then
            LastSize=source:size()-1;

            local Min, Max=mathex.minmax(source, first, period);
            local Rmin=math.floor(Min/(1000*PS))*PS*1000;
            local Rmax=math.ceil(Max/(1000*PS))*PS*1000;

            Rcount=0;
            Rarr={};
            Qcount=0;
            Qarr={};
            Hcount=0;
            Harr={};
            Ecount=0;
            Earr={};
            local Rcurr=Rmin;
            while Rcurr<=Rmax do
                Rcount=Rcount+1;
                Rarr[Rcount]=Rcurr;
                Rcurr=Rcurr+PS*1000;
            end

            Rcurr=Rmin;
            while Rcurr<=Rmax do
                if not(FindLevel(Rcurr, Rarr, Rcount)) then
                    Qcount=Qcount+1;
                    Qarr[Qcount]=Rcurr;
                end
                Rcurr=Rcurr+PS*250;
            end

            Rcurr=Rmin;
            while Rcurr<=Rmax do
                if not(FindLevel(Rcurr, Rarr, Rcount)) and not(FindLevel(Rcurr, Qarr, Qcount)) then
                    Hcount=Hcount+1;
                    Harr[Hcount]=Rcurr;

                    Ecount=Ecount+1;
                    Earr[Ecount]=Rcurr-PS*50;
                    Ecount=Ecount+1;
                    Earr[Ecount]=Rcurr+PS*50;
                end
                Rcurr=Rcurr+PS*125;
            end

        end
    end
end

local init = false;

function Draw(stage, context)
    if stage == 0 then
    
        if not init then
            context:createPen(1, context:convertPenStyle ( instance.parameters.Rstyle ), instance.parameters.Rwidth, instance.parameters.Rclr);--S
            context:createPen(2, context:convertPenStyle ( instance.parameters.Qstyle ), instance.parameters.Qwidth, instance.parameters.Qclr);--S
            context:createPen(3, context:convertPenStyle (instance.parameters.Hstyle  ), instance.parameters.Hwidth, instance.parameters.Hclr);--D
            context:createPen(4, context:convertPenStyle (instance.parameters.Estyle  ), instance.parameters.Ewidth, instance.parameters.Eclr);--D

            context:createFont(5, "Arial", 0, context:pointsToPixels(10), 0);
            init = true;
        end

        local top, bottom, left, right=context:top(), context:bottom(), context:left(), context:right();
        local i;
        local v, y;
        local Str;
        local w, h;

        if Rcount>0 then
            for i=1, Rcount, 1 do
                v, y=context:pointOfPrice(Rarr[i]);
                context:drawLine(1, left, y, right, y);
                Str="" .. win32.formatNumber(Rarr[i], false, Precision);
                w, h=context:measureText(5, Str, context.LEFT);
                context:drawText(5, Str, instance.parameters.LRclr, -1, right-w, y, right, y+h, context.LEFT);
            end

            for i=1, Qcount, 1 do
                v, y=context:pointOfPrice(Qarr[i]);
                context:drawLine(2, left, y, right, y);
                Str="" .. win32.formatNumber(Qarr[i], false, Precision);
                w, h=context:measureText(5, Str, context.LEFT);
                context:drawText(5, Str, instance.parameters.LQclr, -1, right-w, y, right, y+h, context.LEFT);
            end

            for i=1, Hcount, 1 do
                v, y=context:pointOfPrice(Harr[i]);
                context:drawLine(3, left, y, right, y);
                Str="" .. win32.formatNumber(Harr[i], false, Precision);
                w, h=context:measureText(5, Str, context.LEFT);
                context:drawText(5, Str, instance.parameters.LHclr, -1, right-w, y, right, y+h, context.LEFT);
            end

            for i=1, Ecount, 1 do
                v, y=context:pointOfPrice(Earr[i]);
                context:drawLine(4, left, y, right, y);
				
				
				  Str="" .. win32.formatNumber(Earr[i], false, Precision);
                w, h=context:measureText(5, Str, context.LEFT);
                context:drawText(5, Str, instance.parameters.LEclr, -1, right-w, y, right, y+h, context.LEFT);
            end

        end


    end
end




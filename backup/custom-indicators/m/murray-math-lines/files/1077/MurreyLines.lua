-- Id: 341
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=608

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Murrey Math Lines");
    indicator:description("Shows harmonic support and resistance lines");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("P", "Number of periods", "", 64, 2, 10000);
    indicator.parameters:addInteger("N", "Size of the period in minutes", "", 60, 2, 10000);
   
	indicator.parameters:addGroup("Selector");
	indicator.parameters:addBoolean("V", "Draw vertical lines", "", true);
    indicator.parameters:addBoolean("EL", "Exended labels", "", false);
	indicator.parameters:addBoolean("ON", "Show Price Levels", "", false);
	
	indicator.parameters:addGroup("Line Selector");
	indicator.parameters:addBoolean("Show" .. 1, "Show [-2/8] Line ", "", true);
	indicator.parameters:addBoolean("Show" .. 2, "Show [-2/8] Line ", "", true);
	indicator.parameters:addBoolean("Show" .. 3, "Show [0/8] Line ", "", true);
	indicator.parameters:addBoolean("Show" .. 4, "Show [1/8] Line ", "", true);
	indicator.parameters:addBoolean("Show" .. 5, "Show [2/8] Line ", "", true);
	indicator.parameters:addBoolean("Show" .. 6, "Show [3/8] Line ", "", true);
	indicator.parameters:addBoolean("Show" .. 7, "Show [4/8] Line ", "", true);
	indicator.parameters:addBoolean("Show" .. 8, "Show [5/8] Line ", "", true);
	indicator.parameters:addBoolean("Show" .. 9, "Show [6/8] Line ", "", true);
	indicator.parameters:addBoolean("Show" .. 10, "Show [7/8] Line ", "", true);
	indicator.parameters:addBoolean("Show" .. 11, "Show [8/8] Line ", "", true);
	indicator.parameters:addBoolean("Show" .. 12, "Show [+1/8] Line ", "", true);
	indicator.parameters:addBoolean("Show" .. 13, "Show [+2/8] Line ", "", true);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrM28", "Color of the [-2/8] line", "", core.rgb(255, 255, 255));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("clrM18", "Color of the [-1/8] line", "", core.rgb(255, 0, 255));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("clr08",  "Color of the [0/8] line", "", core.rgb(0, 128, 192));
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("clr18",  "Color of the [1/8] line", "", core.rgb(255, 255, 0));
	indicator.parameters:addInteger("width4", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style4", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style4", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("clr28",  "Color of the [2/8] line", "", core.rgb(255, 128, 0));
	indicator.parameters:addInteger("width5", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style5", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style5", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("clr38",  "Color of the [3/8] line", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width6", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style6", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style6", core.FLAG_LINE_STYLE);
	
	
    indicator.parameters:addColor("clr48",  "Color of the [4/8] line", "", core.rgb(0, 255, 255));
	indicator.parameters:addInteger("width7", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style7", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style7", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("clr58",  "Color of the [5/8] line", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width8", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style8", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style8", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("clr68",  "Color of the [6/8] line", "", core.rgb(255, 128, 0));
	indicator.parameters:addInteger("width9", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style9", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style9", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("clr78",  "Color of the [7/8] line", "", core.rgb(255, 255, 0));
	indicator.parameters:addInteger("width10", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style10", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style10", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("clr88",  "Color of the [8/8] line", "", core.rgb(0, 128, 192));
	indicator.parameters:addInteger("width11", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style11", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style11", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("clrP18", "Color of the [+1/8] line", "", core.rgb(255, 0, 255));
	indicator.parameters:addInteger("width12", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style12", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style12", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("clrP28", "Color of the [+2/8] line", "", core.rgb(255, 255, 255));
	indicator.parameters:addInteger("width13", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style13", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style13", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("clrT", "Color of the time line", "", core.rgb(127, 0, 0));
	indicator.parameters:addColor("clrLabel", "Color of label", "", core.rgb(0, 0, 0));
	indicator.parameters:addInteger("widthT", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleT", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleT", core.FLAG_LINE_STYLE);
	
end

local P, N, EL, V;  -- indicator parameters
local source;       -- the price source
local barsize;      -- the size of the bar in minutes
local depth;        -- depth for finding the data
local labels = {};  -- line labels
local colors = {};  -- line colors
local dummy = nil;  -- dummy output
local clrT;
local clrLabel;
local font;
local Show={};
local ON;
local style={};
local width={};
local styleT,  widthT;
function ReleaseInstance()
       core.host:execute("deleteFont", font);      
 end


function Prepare(nameOnly)
     clrLabel= instance.parameters.clrLabel;
    P = instance.parameters.P;
    N = instance.parameters.N;
    V = instance.parameters.V;
    EL = instance.parameters.EL;
    clrT = instance.parameters.clrT;
	ON = instance.parameters.ON;
	styleT = instance.parameters.styleT;
      widthT = instance.parameters.widthT;
    source = instance.source;
    local s, e;
    s, e = core.getcandle(source:barSize(), core.now(), 0);
    barsize = math.floor(((e - s) * 1440) + 0.5);

    depth = P * math.ceil(N / barsize);
    if (depth == 0) then
        depth = P;
    end
	
	for i = 0, 12, 1 do
	style[i]=instance.parameters:getDouble("style" .. i+1);
    width[i]=instance.parameters:getDouble("width" .. i+1);
	end

    colors[0] = instance.parameters.clrM28;
    colors[1] = instance.parameters.clrM18;
    colors[2] = instance.parameters.clr08;
    colors[3] = instance.parameters.clr18;
    colors[4] = instance.parameters.clr28;
    colors[5] = instance.parameters.clr38;
    colors[6] = instance.parameters.clr48;
    colors[7] = instance.parameters.clr58;
    colors[8] = instance.parameters.clr68;
    colors[9] = instance.parameters.clr78;
    colors[10] = instance.parameters.clr88;
    colors[11] = instance.parameters.clrP18;
    colors[12] = instance.parameters.clrP28;
	
	Show[0] = instance.parameters.Show1;
	Show[1] = instance.parameters.Show2;
	Show[2] = instance.parameters.Show3;
	Show[3] = instance.parameters.Show4;
	Show[4] = instance.parameters.Show5;
	Show[5] = instance.parameters.Show6;
	Show[6] = instance.parameters.Show7;
	Show[7] = instance.parameters.Show8;
	Show[8] = instance.parameters.Show9;
	Show[9] = instance.parameters.Show10;
	Show[10] = instance.parameters.Show11;
	Show[11] = instance.parameters.Show12;
	Show[12] = instance.parameters.Show13;

    if EL then
        labels[0]  = "[-2/8] (Extreme Overshoot)";
        labels[1]  = "[-1/8] (Overshoot)";
        labels[2]  = "[0/8] (Ultimate Support - Extremely Oversold)";
        labels[3]  = "[1/8] (Weak, Place to Stop and Reverse)";
        labels[4]  = "[2/8] (Strong, Pivot, Reverse)";
        labels[5]  = "[3/8] (Bottom of Trading Range)";
        labels[6]  = "[4/8] (Major Support/Resistance Pivotal Point)";
        labels[7]  = "[5/8] (Top of Trading Range)";
        labels[8]  = "[6/8] (Strong, Pivot, Reverse)";
        labels[9]  = "[7/8] (Weak, Place to Stop and Reverse)";
        labels[10]  = "[8/8] (Ultimate Resistance - Extremely Overbought)";
        labels[11]  = "[+1/8] (Overshoot)";
        labels[12]  = "[+2/8] (Extreme Overshoot)";
    else
        labels[0]  = "[-2/8]";
        labels[1]  = "[-1/8]";
        labels[2]  = "[0/8]";
        labels[3]  = "[1/8]";
        labels[4]  = "[2/8]";
        labels[5]  = "[3/8]";
        labels[6]  = "[4/8]";
        labels[7]  = "[5/8]";
        labels[8]  = "[6/8]";
        labels[9]  = "[7/8]";
        labels[10]  = "[8/8]";
        labels[11]  = "[+1/8]";
        labels[12]  = "[+2/8]";
    end
	
    local name = profile:id() .. "(" .. source:name() .. ",[" .. P .. "," .. N .. ":=" .. depth .. " periods])";
    instance:name(name);
    if nameOnly then
        return;
    end
	font = core.host:execute("createFont", "Ariel", 10, false, false);
    dummy = instance:addStream("D", core.Line, name, "D", instance.parameters.clr48, source:first());
end

function Update(period, mode)
    if period == source:size() - 1 and source:size() > depth + source:first() then
        local min, max, minp, maxp, fractal, range, octave, sum, mn, mx;
        min, max, minp, maxp = core.minmax(source, core.rangeTo(period, depth));
        if max <= 250000 and max > 25000 then
            fractal = 100000;
        elseif  max <= 25000 and max > 2500 then
            fractal = 10000;
        elseif max <= 2500 and max > 250 then
            fractal = 1000;
        elseif max <= 250 and max > 25 then
            fractal = 100;
        elseif max <= 25 and max > 12.5 then
            fractal = 12.5;
        elseif max <= 12.5 and max > 6.25 then
            fractal = 12.5;
        elseif max <= 6.25 and max > 3.125 then
            fractal = 6.25;
        elseif max <= 3.125 and max > 1.5625 then
            fractal = 3.125;
        elseif max <= 1.5625 and max > 0.390625 then
            fractal = 1.5625;
        elseif max <= 0.390625 and max > 0 then
             fractal = 0.1953125;
        else
            assert(false, "The price is out of range");
        end
        range = max - min;
        sum = math.floor(math.log(fractal / range) / math.log(2));
        octave = fractal * (math.pow(0.5, sum));
        mn = math.floor(min / octave) * octave;
        if mn + octave > max then
            mx = mn + octave;
        else
            mx = mn + (2 * octave);
        end

        local x1, x2, x3, x4, x5, x6;
        local y1, y2, y3, y4, y5, y6;
        local finalH, finalL;

        if (min >= (3 * (mx - mn) / 16 + mn)) and (max <= (9 * (mx - mn) / 16 + mn)) then
            x2 = mn + (mx - mn) / 2;
        else
            x2 = 0;
        end

        if (min >= (mn - (mx - mn) / 8)) and (max <= (5 * (mx - mn) / 8 + mn)) and (x2 == 0) then
            x1 = mn + (mx - mn) / 2;
        else
            x1 = 0;
        end


        if (min >= (mn + 7 * (mx - mn) / 16)) and (max <= (13 * (mx - mn) / 16 + mn)) then
            x4 = mn + 3 * (mx - mn) / 4;
        else
            x4 = 0;
        end


        if (min >= (mn + 3 * (mx - mn) / 8)) and (max <= (9 * (mx - mn) / 8 + mn)) and (x4 == 0) then
            x5 = mx;
        else
            x5 = 0;
        end


        if (min >= (mn + (mx - mn) / 8)) and (max <= (7 * (mx - mn) / 8 + mn)) and (x1 == 0) and (x2 == 0) and (x4 == 0) and (x5 == 0) then
            x3 = mn + 3 * (mx - mn) / 4;
        else
            x3 = 0;
        end

        if (x1 + x2 + x3 + x4 + x5) == 0 then
            x6 = mx;
        else
            x6 = 0;
        end

        finalH = x1 + x2 + x3 + x4 + x5 + x6;

        if x1 > 0 then
            y1 = mn;
        else
            y1 = 0;
        end


        if x2 > 0 then
            y2 = mn + (mx - mn) / 4;
        else
            y2 = 0;
        end


        if x3 > 0 then
            y3 = mn + (mx - mn) / 4;
        else
            y3 = 0;
        end


        if x4 > 0 then
            y4 = mn + (mx - mn) / 2;
        else
            y4 = 0;
        end

        if x5 > 0 then
            y5 = mn + (mx - mn) / 2;
        else
            y5 = 0;
        end


        if (finalH > 0) and ((y1 + y2 + y3 + y4 + y5) == 0) then
            y6 = mn;
        else
            y6 = 0;
        end

        finalL = y1 + y2 + y3 + y4 + y5 + y6;

        local dmml, price, i, d1, d2, price0, pricel;
        dmml = (finalH - finalL) / 8;

        price = finalL - dmml * 2;

        d1 = source:date(source:first());
        d2 = source:date(period);
        price0 = price;

        for i = 0, 12, 1 do
		
		
		 if Show[i] then
            core.host:execute("drawLine", i, d1, price, d2, price, colors[i], style[i], width[i]); 
			
			if not ON then
			core.host:execute("drawLabel1", i, d2+((barsize*2)/1440), core.CR_CHART, price, core.CR_CHART, core.H_Right, core.V_Bottom, font, clrLabel, labels[i]	);	
			else
		    core.host:execute("drawLabel1", i, d2+((barsize*2)/1440), core.CR_CHART, price, core.CR_CHART, core.H_Right, core.V_Bottom, font, clrLabel, labels[i] .. " (" .. string.format("%." .. source:getPrecision() .. "f", price ) ..")"	);	
		    end
		 end    
            price = price + dmml;
        end
        pricel = price - dmml;

        -- verical lines
        if V then
            local delta, base;
            -- distance between high and low in days
            delta = math.abs(source:date(minp) - source:date(maxp));
            if (minp > maxp) then
                base = source:date(minp);
            else
                base = source:date(maxp);
            end

            for i = 0, 8, 1 do
                core.host:execute("drawLine", 100 + i, base, price0, base, pricel, clrT, styleT,  widthT);
                base = base + delta;
            end
        end
    end
end

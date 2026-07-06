
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=706

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

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("Belkhayate's Center Of Gravity");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addInteger("N", "Number of bars", "", 180);
    indicator.parameters:addInteger("O", "Order", "", 3);
    indicator.parameters:addDouble("E", "Eccart value", "", 1.61803399);
	
	
	indicator.parameters:addColor("L1_color_Up", "Color of L1 Up", "Color of L1",  core.rgb(0, 0, 255));
	
    indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("L2_color_Up", "Color of L2 Up", "Color of L2",  core.rgb(127, 127, 127));
 
	
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("L3_color_Up", "Color of L3 Up", "Color of L3", core.rgb(255, 0, 0));
 
	
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("L4_color_Up", "Color of L4 Up", "Color of L4", core.rgb(255, 0, 0));
 
	
	indicator.parameters:addInteger("width4", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style4", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style4", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("L5_color_Up", "Color of L5 Up", "Color of L5",core.rgb(127, 127, 127));
 
	
	indicator.parameters:addInteger("width5", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style5", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style5", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("L6_color_Up", "Color of L6 Up", "Color of L6", core.rgb(0, 192, 0));
 
	
	indicator.parameters:addInteger("width6", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style6", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style6", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("L7_color_Up", "Color of L7 Up", "Color of L7",   core.rgb(0, 192, 0));
 
	
	indicator.parameters:addInteger("width7", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style7", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style7", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local N;
local O;
local E;

local first;
local source = nil;

-- Streams block
local L1 = nil;
local L2 = nil;
local L3 = nil;
local L4 = nil;
local L5 = nil;
local L6 = nil;
local L7 = nil;

-- Routine
function Prepare(nameOnly)  
    N = instance.parameters.N;
    O = instance.parameters.O;
    E = instance.parameters.E;

    source = instance.source;

    first = source:first();

    local name = profile:id() .. "(" .. source:name() .. ", " .. N .. ", " .. O .. ", " .. E .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
    L1 = instance:addStream("L1", core.Line, name .. ".L1", "L1", instance.parameters.L1_color_Up, first);
	L1:setWidth(instance.parameters.width1);
    L1:setStyle(instance.parameters.style1);
	
    L2 = instance:addStream("L2", core.Line, name .. ".L2", "L2", instance.parameters.L2_color_Up, first);
	L2:setWidth(instance.parameters.width2);
    L2:setStyle(instance.parameters.style2);
	
    L3 = instance:addStream("L3", core.Line, name .. ".L3", "L3", instance.parameters.L3_color_Up, first);
	L3:setWidth(instance.parameters.width3);
    L3:setStyle(instance.parameters.style3);
	
    L4 = instance:addStream("L4", core.Line, name .. ".L4", "L4", instance.parameters.L4_color_Up, first);
	L4:setWidth(instance.parameters.width4);
    L4:setStyle(instance.parameters.style4);
	
    L5 = instance:addStream("L5", core.Line, name .. ".L5", "L5", instance.parameters.L5_color_Up, first);
	L5:setWidth(instance.parameters.width5);
    L5:setStyle(instance.parameters.style5);
	
    L6 = instance:addStream("L6", core.Line, name .. ".L6", "L6", instance.parameters.L6_color_Up, first);
	L6:setWidth(instance.parameters.width6);
    L6:setStyle(instance.parameters.style6);
	
    L7 = instance:addStream("L7", core.Line, name .. ".L7", "L7", instance.parameters.L7_color_Up, first);
	L7:setWidth(instance.parameters.width7);
    L7:setStyle(instance.parameters.style7);
end

local prevCandle = nil;

-- Indicator calculation routine
function Update(period)
    if prevCandle ~= nil and source:serial(period) == prevCandle then
        return ;
    else
        prevCandle = source:serial(period);
    end

    if source:size() > 0 and (source:size() - source:first()) > N and period == source:size() - 1 then
        local s, i, j, k, a1, a2, a3, a4, v1, si, t;

        s = O + 1;

        -- init arrays
        a1 = {};
        for i = 0, s, 1 do
            a1[i] = {};
        end
        a2 = {};
        a3 = {};
        a4 = {};

        a2[1] = N + 1;
        for i = 1, (s - 1) * 2, 1 do
            v1 = 0;
            for j = 0, N, 1 do
                v1 = v1 + (math.pow(j, i));
            end
            a2[i + 1] = v1;
        end

        for j = 1, s, 1 do
            v1 = 0;
            for i = 0, N, 1 do
                if j == 1 then
                    v1 = v1 + (source.high[period - i] + source.low[period - i]) / 2;
                else
                    v1 = v1 + (source.high[period - i] + source.low[period - i]) / 2 * (math.pow(i, j - 1));
                end
            end
            a3[j] = v1;
        end

        for j = 1, s, 1 do
           for i = 1, s, 1 do
              a1[i][j] = a2[i + j - 1];
           end
        end

        for i = 1, s - 1, 1 do
            si = 0;
            v1 = 0;
            for j = i, s, 1 do
                if math.abs(a1[j][i]) > v1 then
                    v1 = math.abs(a1[j][i]);
                    si = j;
                end
            end
            if si == 0 then
                return ;
            end

            if si ~= i then
                for j = 1, s, 1 do
                    t = a1[i][j];
                    a1[i][j] = a1[si][j];
                    a1[si][j] = t;
                end
                t = a3[i];
                a3[i] = a3[si];
                a3[si] = t;
            end

            for j = i + 1, s, 1 do
                v1 = a1[j][i] / a1[i][i];
                for k = 1, s, 1 do
                    if k == i then
                        a1[j][k] = 0;
                    else
                        a1[j][k] = a1[j][k] - v1 * a1[i][k];
                    end
                end
                a3[j] = a3[j] - v1 * a3[i];
            end
        end

        a4[s] = a3[s] / a1[s][s];

        for i = s - 1, 1, -1 do
            v1 = 0;
            for j = 1, s - i, 1 do
                v1 = v1 + (a1[i][i + j]) * (a4[i + j]);
                a4[i] = 1 / a1[i][i] * (a3[i] - v1);
            end
        end

        for i = 0, N, 1 do
            v1 = 0;
            for j = 1, O, 1 do
                v1 = v1 + (a4[j + 1]) * (math.pow(i, j));
            end
            L1[period - i] = a4[1] + v1;
        end

        v2 = core.stdev(source.high, core.rangeTo(period, N)) * E;

        for i = 0, N, 1 do
            L4[period - i] = L1[period - i] + v2;
            L3[period - i] = L1[period - i] + (L4[period - i] - L1[period - i]) / 1.382;
            L2[period - i] = L1[period - i] + (L3[period - i] - L1[period - i]) / 1.618;
            L7[period - i] = L1[period - i] - v2;
            L6[period - i] = L1[period - i] - (L1[period - i] - L7[period - i]) / 1.382;
            L5[period - i] = L1[period - i] - (L1[period - i] - L6[period - i]) / 1.618;
        end
        for i = N + 1, N + 10, 1 do
            j = period - i;
            if j > source:first() then
                L1[j] = nil;
                L2[j] = nil;
                L3[j] = nil;
                L4[j] = nil;
                L5[j] = nil;
                L6[j] = nil;
                L7[j] = nil;
            end
        end
    end
end


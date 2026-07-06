-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=70683

--+------------------------------------------------------------------+
--|                               Copyright © 2020, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                           mario.jemic@gmail.com  |
--|                          https://AppliedMachineLearning.systems  |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                   Paypal: https://goo.gl/9Rj74e  |
--|                                  Patreon: https://goo.gl/GdXWeN  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Kalman");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    
    indicator.parameters:addInteger("Samples", "Samples", "", 120);
    indicator.parameters:addDouble("DevLevel1", "Dev Level 1", "", 1);
    indicator.parameters:addDouble("DevLevel2", "Dev Level 2", "", 2);
    indicator.parameters:addDouble("ZGain", "Z Gain", "", 0);
    indicator.parameters:addDouble("AccDeGain", "AccDeGain", "", 0);
    
    indicator.parameters:addColor("KalmanBuffer_color", "KalmanBuffer Color", "Color", core.colors().Yellow);
    indicator.parameters:addInteger("KalmanBuffer_width", "KalmanBuffer Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("KalmanBuffer_style", "KalmanBuffer Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("KalmanBuffer_style", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("KalmanBufferPlus1_color", "KalmanBufferPlus1 Color", "Color", core.colors().Yellow);
    indicator.parameters:addInteger("KalmanBufferPlus1_width", "KalmanBufferPlus1 Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("KalmanBufferPlus1_style", "KalmanBufferPlus1 Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("KalmanBufferPlus1_style", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("KalmanBufferNeg1_color", "KalmanBufferNeg1 Color", "Color", core.colors().Yellow);
    indicator.parameters:addInteger("KalmanBufferNeg1_width", "KalmanBufferNeg1 Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("KalmanBufferNeg1_style", "KalmanBufferNeg1 Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("KalmanBufferNeg1_style", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("KalmanBufferPlus2_color", "KalmanBufferPlus2 Color", "Color", core.colors().Red);
    indicator.parameters:addInteger("KalmanBufferPlus2_width", "KalmanBufferPlus2 Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("KalmanBufferPlus2_style", "KalmanBufferPlus2 Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("KalmanBufferPlus2_style", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("KalmanBufferNeg2_color", "KalmanBufferNeg2 Color", "Color", core.colors().Red);
    indicator.parameters:addInteger("KalmanBufferNeg2_width", "KalmanBufferNeg2 Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("KalmanBufferNeg2_style", "KalmanBufferNeg2 Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("KalmanBufferNeg2_style", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("KalmanBufferPlus3_color", "KalmanBufferPlus3 Color", "Color", core.colors().Red);
    indicator.parameters:addInteger("KalmanBufferPlus3_width", "KalmanBufferPlus3 Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("KalmanBufferPlus3_style", "KalmanBufferPlus3 Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("KalmanBufferPlus3_style", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("KalmanBufferNeg3_color", "KalmanBufferNeg3 Color", "Color", core.colors().Red);
    indicator.parameters:addInteger("KalmanBufferNeg3_width", "KalmanBufferNeg3 Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("KalmanBufferNeg3_style", "KalmanBufferNeg3 Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("KalmanBufferNeg3_style", core.FLAG_LINE_STYLE);
end

local xkk = {};
local xkk1 = {};
local yk = {};
local zk = {};
local Pkk = {};
local Pkk1 = {};
local Pk1k1 = {};
local Qkk = {};
local Hk = {};
local Hk_t = {};
local Sk = {};
local Sk_inv = {};
local Rk = {};
local Kk = {};
local Fk = {};
local Fk_t = {};
local GGT = {};
local Eye = {};
local temp22 = {};
local temp21 = {};
local temp12 = {};
local temp11 = {};

local c0;
local c0_above=0;
local c0_below = 0;
local c1_above=0
local c1_below = 0;
local acc_sigma2;
local z_sigma2;
local working_samples;
local z,diff;
local ts = {};
local dev_level1,dev_level2;
local source;
local Samples, DevLevel1, DevLevel2, ZGain, AccDeGain
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
    Samples = instance.parameters.Samples;
    DevLevel1 = instance.parameters.DevLevel1;
    DevLevel2 = instance.parameters.DevLevel2;
    ZGain = instance.parameters.ZGain;
    AccDeGain = instance.parameters.AccDeGain;
    KalmanBuffer = instance:addStream("KalmanBuffer", core.Line, "Kalman Trend", "Kalman Trend", instance.parameters.KalmanBuffer_color, 0, 0);
    KalmanBuffer:setWidth(instance.parameters.KalmanBuffer_width);
    KalmanBuffer:setStyle(instance.parameters.KalmanBuffer_style);
    KalmanBufferPlus1 = instance:addStream("KalmanBufferPlus1", core.Line, "Kalman +" .. DevLevel1 .. " STD", "Kalman +" .. DevLevel1 .. " STD", instance.parameters.KalmanBufferPlus1_color, 0, 0);
    KalmanBufferPlus1:setWidth(instance.parameters.KalmanBufferPlus1_width);
    KalmanBufferPlus1:setStyle(instance.parameters.KalmanBufferPlus1_style);
    KalmanBufferNeg1 = instance:addStream("KalmanBufferNeg1", core.Line, "Kalman -" .. DevLevel1 .. " STD", "Kalman -" .. DevLevel1 .. " STD", instance.parameters.KalmanBufferNeg1_color, 0, 0);
    KalmanBufferNeg1:setWidth(instance.parameters.KalmanBufferNeg1_width);
    KalmanBufferNeg1:setStyle(instance.parameters.KalmanBufferNeg1_style);
    KalmanBufferPlus2 = instance:addStream("KalmanBufferPlus2", core.Line, "Kalman +" .. DevLevel2 .. " STD", "Kalman +" .. DevLevel2 .. " STD", instance.parameters.KalmanBufferPlus2_color, 0, 0);
    KalmanBufferPlus2:setWidth(instance.parameters.KalmanBufferPlus2_width);
    KalmanBufferPlus2:setStyle(instance.parameters.KalmanBufferPlus2_style);
    KalmanBufferNeg2 = instance:addStream("KalmanBufferNeg2", core.Line, "Kalman -" .. DevLevel2 ..  " STD", "Kalman -" .. DevLevel2 ..  " STD", instance.parameters.KalmanBufferNeg2_color, 0, 0);
    KalmanBufferNeg2:setWidth(instance.parameters.KalmanBufferNeg2_width);
    KalmanBufferNeg2:setStyle(instance.parameters.KalmanBufferNeg2_style);
    KalmanBufferPlus3 = instance:addStream("KalmanBufferPlus3", core.Line, "Kalman High +" .. DevLevel2 ..  " STD", "Kalman High +" .. DevLevel2 ..  " STD", instance.parameters.KalmanBufferPlus3_color, 0, 0);
    KalmanBufferPlus3:setWidth(instance.parameters.KalmanBufferPlus3_width);
    KalmanBufferPlus3:setStyle(instance.parameters.KalmanBufferPlus3_style);
    KalmanBufferNeg3 = instance:addStream("KalmanBufferNeg3", core.Line, "Kalman Low -" .. DevLevel2 ..  " STD", "Kalman Low -" .. DevLevel2 ..  " STD", instance.parameters.KalmanBufferNeg3_color, 0, 0);
    KalmanBufferNeg3:setWidth(instance.parameters.KalmanBufferNeg3_width);
    KalmanBufferNeg3:setStyle(instance.parameters.KalmanBufferNeg3_style);
end

local init = false;
function Update(period, mode)
    if period < 15 then
        return;
    end
    if not init then
        init = true;    
        dev_level1 = DevLevel1 * math.sqrt(2);
        dev_level2 = DevLevel2 * math.sqrt(2);
        yk = CreateMatrix(1, 1);
        zk = CreateMatrix(1, 1);
        xkk = CreateMatrix(2, 1);
        xkk1 = CreateMatrix(2, 1);
        xkk[1][1] = get_avg(0);
        xkk[2][1] = get_avg(0) - get_avg(15);
        Pkk = CreateMatrix(2, 2);
        Pkk1 = CreateMatrix(2, 2);
        Pk1k1 = CreateMatrix(2, 2);
        Pkk:Eye();
        Fk = CreateMatrix(2, 2);
        Fk[1][1] = 1;
        Fk[1][2] = 1;
        Fk[2][1] = 0;
        Fk[2][2] = 1;
        Fk_t = Fk:Transpose();
        Qkk = CreateMatrix(2, 2);
        Qkk[1][1] = 1;
        Qkk[1][2] = 0;
        Qkk[2][1] = 0;
        Qkk[2][2] = 1;
        GGT = CreateMatrix(2, 2);
        GGT[1][1] = 0.25;
        GGT[2][1] = 0.5;
        GGT[1][2] = 0.5;
        GGT[2][2] = 1;
        Sk = CreateMatrix(1, 1);
        Sk_inv = CreateMatrix(1, 1);
        Hk = CreateMatrix(1, 2);
        Hk[1][1] = 1;
        Hk[1][2] = 0;
        Hk_t = Hk:Transpose();

        temp11 = CreateMatrix(1, 1);
        Rk = CreateMatrix(1, 1);
        Kk = CreateMatrix(1, 1);
        temp22 = CreateMatrix(2, 2);
        temp21 = CreateMatrix(2, 1);
        temp12 = CreateMatrix(1, 2);
        Eye = CreateMatrix(2, 2);
        Rk[1][1] = .1;
        Eye:Eye(Eye);
        z_sigma2 = math.pow(10, -ZGain);
        acc_sigma2 = source:pipSize() * math.pow(10, -AccDeGain) * 1;
        working_samples = Samples / 1;
        acc_sigma2 = acc_sigma2 * acc_sigma2;
        Pkk:ScalarMul(acc_sigma2);
    end
    Pk1k1 = Pkk:Clone();
    xkk1 = Fk:Mul(xkk);
    temp22 = Fk:Mul(Pk1k1);
    Pk1k1 = temp22:Mul(Fk_t);
    Pkk1 = Pk1k1:Add(Qkk, 1);
    KalmanBuffer[period] = (xkk1[1][1] * source:pipSize());
    yk:Zero();
    zk[1][1] = get_avg(period - 1);

    diff = (zk[1][1] * source:pipSize() - KalmanBuffer[period - 1]);
    if (diff >= 0) then
        diff = diff * diff;
        c0_above = (c0_above * (working_samples - 1) + math.pow(get_avg(period - 1) * source:pipSize() - KalmanBuffer[period - 1], 2)) / working_samples;
        c0_below = c0_below * (working_samples - 1) / working_samples;
        c1_above = (c1_above * (working_samples - 1) + math.pow(source.high[period - 1] - KalmanBuffer[period - 1], 2)) / working_samples;
        c1_below = c1_below * (working_samples - 1) / working_samples;
    else
        diff = diff * diff;
        c0_below = (c0_below * (working_samples - 1) + math.pow(get_avg(period - 1) * source:pipSize() - KalmanBuffer[period - 1], 2)) / working_samples;
        c0_above = c0_above * (working_samples - 1) / working_samples;
        c1_below = (c1_below * (working_samples - 1) + math.pow(source.low[period - 1] - KalmanBuffer[period - 1], 2)) / working_samples;
        c1_above = c1_above * (working_samples - 1) / working_samples;
    end
    if (math.abs(DevLevel1) > 0) then
        KalmanBufferPlus1[period] = KalmanBuffer[period - 1] + dev_level1 * math.sqrt(c0_above);
        KalmanBufferNeg1[period] = KalmanBuffer[period - 1] - dev_level1 * math.sqrt(c0_below);
    end
    if (math.abs(DevLevel2) > 0) then
        KalmanBufferPlus2[period] = KalmanBuffer[period - 1] + dev_level2 * math.sqrt(c0_above);
        KalmanBufferNeg2[period] = KalmanBuffer[period - 1] - dev_level2 * math.sqrt(c0_below);
        KalmanBufferPlus3[period] = KalmanBuffer[period - 1] + dev_level2 * math.sqrt(c1_above);
        KalmanBufferNeg3[period] = KalmanBuffer[period - 1] - dev_level2 * math.sqrt(c1_below);
    end
    zk[1][1] = get_avg(period - 1) - get_avg(period - 2);
    Rk[1][1] = z_sigma2;

    Qkk = GGT:Clone();
    Qkk:ScalarMul(acc_sigma2);
    temp11 = Hk:Mul(xkk1);
    yk = zk:Add(temp11, -1);
    temp12 = Hk:Mul(Pkk1);
    temp11 = temp12:Mul(Hk_t);
    Sk = temp11:Add(Rk, 1);
    Sk_inv = Sk:Invert();
    temp21 = Pkk1:Mul(Hk_t);
    Kk = temp21:Mul(Sk_inv);
    temp21 = Kk:Mul(yk);
    xkk = temp21:Add(xkk1, 1);

    temp22 = Kk:Mul(Hk);
    temp22 = Eye:Add(temp22, -1);
    Pkk = temp22:Mul(Pkk1);
end

function get_avg(k)
    return (math.pow((source.high[k] * source.low[k] * source.close[k] * source.close[k]), 1 / 4.) / source:pipSize());
end

function CreateMatrix(x, y)
    local matrix = {};
    for i = 1, x do
        matrix[i] = {};
        for ii = 1, y do
            matrix[i][ii] = 0;
        end
    end
    function matrix:Determinant(k)
        if k == nil then
            k = #self
        else
            if #self ~= #self[1] then
                return 0;
            end
        end
        if k == 1 then
            return self[1][1];
        end
        if k == 2 then
            return self[1][1] * self[2][2] - self[2][1] * self[1][2];
        end
        if k == 3 then
            return self[1][1] * self[2][2] * self[3][3] 
                + self[1][2] * self[2][3] * self[3][1] 
                + self[1][3] * self[2][1] * self[3][2] 
                - (self[3][1] * self[2][2] * self[1][3] 
                + self[2][1] * self[1][2] * self[3][3] 
                + self[1][1] * self[3][2] * self[2][3]);
        end
        return 0;
    end
    function matrix:Add(b, w)
        local c = CreateMatrix(#self, #self[1]);
        for i = 1, #self do
            for j = 1, #self[1] do
                c[i][j] = self[i][j] + w * b[i][j];
            end
        end
        return c;
    end
    function matrix:Mul(b)
        if #self[1] ~= #b then
            return nil;
        end
        local c = CreateMatrix(#self, #b[1]);
        for i = 1, #self do
            for j = 1, #b[1] do
                c[i][j] = 0;
                for k = 1, #self[1] do
                    c[i][j] = c[i][j] + self[i][k] * b[k][j];
                end
            end
        end
        return c;
    end
    function matrix:ScalarMul(b)
        for i = 1, #self do
            for j = 1, #self[1] do
                self[i][j] = self[i][j] * b;
            end
        end
    end
    function matrix:Zero()
        for i, v in ipairs(self) do
            for ii, v2 in ipairs(v) do
                self[i][ii] = 0;
            end
        end
    end
    function matrix:Clone()
        local clone = CreateMatrix(#self, #self[1]);
        for i, v in ipairs(self) do
            for ii, v2 in ipairs(v) do
                clone[i][ii] = v2;
            end
        end
        return clone;
    end
    function matrix:Transpose()
        local b = CreateMatrix(#self[1], #self);
        for i = 1, #self do
            for j = 1, #self[1] do
                b[j][i] = self[i][j];
            end
        end
        return b;
    end
    function matrix:Invert()
        if #self ~= #self[1] then
            return nil;
        end
        if #self[1] > 3 then
            return nil
        end
        k = #self;
        d = self:Determinant();
        local temp1 = CreateMatrix(4, 4);
        for i1 = 1, k do
            for j1 = 1, k do
                temp1[i1][j1] = self[i1][j1];
            end
        end
        local b = CreateMatrix(1, 1);
        for i = 1, k do
            for j = 1, k do
                temp2 = temp1:Clone();
                for j1 = 1, k do
                    if j1 == j then
                        temp2[i][j1] = 1;
                    else
                        temp2[i][j1] = 0;
                    end
                end
                b[i][j] = temp2:Determinant(k) / d;
            end
        end
        return b;
    end
    function matrix:Eye()
        for i = 1, #self do
            for j = 1, #self[1] do
                self[i][j] = 0;
                if (i == j) then
                    self[i][j] = 1;
                end
            end
        end
    end
    return matrix;
end

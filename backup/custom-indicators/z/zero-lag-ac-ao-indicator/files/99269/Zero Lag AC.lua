-- Id: 13790
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

-- Available @ http://fxcodebase.com/code/viewtopic.php?f=17&t=62000

function Init()
    indicator:name("Zero Lag AC");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator); 

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("FM","Fast MA periods","", 5, 2, 10000);
    indicator.parameters:addInteger("SM", "Slow MA periods","", 35, 2, 10000);
    indicator.parameters:addInteger("M", "MA periods for Acceleration/Deceleration","", 5, 2, 10000);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("GO_color", "Up Color","", core.rgb(0, 255, 0));
    indicator.parameters:addColor("RO_color", "Down Color","", core.rgb(255, 0, 0));
end

local FM;
local SM;
local M;

local first;
local source = nil;

-- Streams block
local CL = nil;
local GO = nil;
local RO = nil;

local AO = nil;
local MVA1 = nil;
local MVA2 = nil;
function Prepare(nameOnly)
    FM = instance.parameters.FM;
    SM = instance.parameters.SM;
    M = instance.parameters.M;

    source = instance.source;
	
	local name = profile:id() .. "(" .. source:name() .. ", " .. FM .. ", " .. SM .. ", " .. M .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end

    AO = core.indicators:create("AO", source, FM, SM);
    MVA1 = core.indicators:create("EMA", AO.DATA, M);
	MVA2 = core.indicators:create("EMA", MVA1.DATA, M);
    first = MVA2.DATA:first();

    
	
	
    CL = instance:addStream("AC", core.Bar, name .. ".AC", "AC", instance.parameters.GO_color, first);
    CL:addLevel(0);
    GO = instance.parameters.GO_color;
    RO = instance.parameters.RO_color;
	
 
	CL:setPrecision(math.max(2, source:getPrecision()));
end

function Update(period, mode)
    AO:update(mode);
    MVA1:update(mode);
	MVA2:update(mode);

    if (period >= first) then
        CL[period] = AO.DATA[period] -  MVA1.DATA[period]+(MVA1.DATA[period]-MVA2.DATA[period]); 
    end
    
    if (period >= first + 1) then
        local curr, prev;
        curr = CL[period];
        prev = CL[period - 1];
        if (curr > prev) then
            CL:setColor(period, GO);
        elseif (curr < prev) then
            CL:setColor(period, RO);
        else
            CL:setColor(period, CL:colorI(period - 1));
        end
    end
end


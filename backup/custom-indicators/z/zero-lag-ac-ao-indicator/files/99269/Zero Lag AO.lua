-- Id: 13791
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
    indicator:name("Zero Lag AO");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
 

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("FM","Fast MA Period","", 5, 2, 10000);
    indicator.parameters:addInteger("SM", "Slow MA Period","", 35, 2, 10000);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("GO_color", "Up Color","", core.rgb(0, 255, 0));
    indicator.parameters:addColor("RO_color", "Down Color","", core.rgb(255, 0, 0));
end

local FM;
local SM;
local SC;

local first;
local source = nil;

-- Streams block
local CL = nil;

local FMVA1 = nil;
local SMVA1 = nil;
local FMVA2 = nil;
local SMVA2 = nil;
local GO, RO;

function Prepare(nameOnly)
    FM = instance.parameters.FM;
    SM = instance.parameters.SM;
    SC = instance.parameters.SC;

    assert(FM < SM, "umber of periods for the fast MA must be less than for the slow MA.");

    source = instance.source;
   
    local name = profile:id() .. "(" .. source:name() .. ", " .. FM .. ", " .. SM .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
    -- Create the median stream
    FMVA1 = core.indicators:create("EMA", source.median, FM);
	FMVA2 = core.indicators:create("EMA",FMVA1.DATA, FM);
    SMVA1 = core.indicators:create("EMA", source.median, SM);
	SMVA2 = core.indicators:create("EMA", SMVA1.DATA, SM);
	
	 first = math.max( SMVA2.DATA:first(), FMVA2.DATA:first());

    
	
	
    CL = instance:addStream("AO", core.Bar, name .. ".AO", "AO", instance.parameters.GO_color, first);
    CL:addLevel(0);
	
	CL:setPrecision(math.max(2, source:getPrecision()));
    GO = instance.parameters.GO_color;
    RO = instance.parameters.RO_color;
end

function Update(period, mode)
    FMVA1:update(mode);
	FMVA2:update(mode);
	SMVA1:update(mode);
    SMVA2:update(mode);

    if (period <  first) then
	return;
	end
	
	local Fast= FMVA1.DATA[period]+(FMVA1.DATA[period]-FMVA2.DATA[period]);
	local Slow= SMVA1.DATA[period]+(SMVA1.DATA[period]-SMVA2.DATA[period]);
	
        CL[period] = Fast - Slow;
   

    if (period >= first + 1) then
        if (CL[period] > CL[period - 1]) then
            CL:setColor(period, GO);
        elseif (CL[period] < CL[period - 1]) then
            CL:setColor(period, RO);
        else
            CL:setColor(period, CL:colorI(period - 1));
        end
    end
end


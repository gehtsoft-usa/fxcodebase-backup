-- Id: 3699
--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Directional Movement Index (VTTrader version)");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "Number of periods", "", 14, 1, 1000);	
    indicator.parameters:addGroup("Style");
	
	 indicator.parameters:addGroup("DI+ Line Style");
    indicator.parameters:addColor("clrDIP", "Color of DI+", "", core.rgb(0, 183, 183));
	 indicator.parameters:addInteger("widthP", "Width of DI+", "Width of DI+", 1, 1, 5);	 
    indicator.parameters:addInteger("styleP", "Style of DI+", "Style of DI+", core.LINE_SOLID);
    indicator.parameters:setFlag("styleP", core.FLAG_LINE_STYLE);
	indicator.parameters:addGroup("DI- Line Style");
    indicator.parameters:addColor("clrDIM", "Color of DI-", "", core.rgb(219, 64, 0));
	 indicator.parameters:addInteger("widthM", "Width of DI-", "Width of DI-", 1, 1, 5);
    indicator.parameters:addInteger("styleM", "Style of DI-", "Style of DI-", core.LINE_SOLID);
    indicator.parameters:setFlag("styleM", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addGroup("Background Style");
	  indicator.parameters:addInteger("Transparency", "Transparency", "", 80,0,100);
	 

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local N;
local Transparency = nil;

local first;
local firstTR;
local source = nil;

-- Streams block
local TR = nil;
local TR_W = nil;
local PlusDM = nil;
local PlusDM_W = nil;
local PlusDI = nil;
local MinusDM = nil;
local MinusDM_W = nil;
local MinusDI = nil;
local H, L, C;
local DIP = nil;
local DIM = nil;

local UP,DN;


-- Routine
function Prepare()
    Transparency = instance.parameters.Transparency;
	Transparency= 100-Transparency;	
	
    UP = instance.parameters.clrDIP;
	DN = instance.parameters.clrDIM;
    N = instance.parameters.N;
    source = instance.source;
    firstTR = source:first() + 1;
    H = source.high;
    L = source.low;
    C = source.close;

    TR = instance:addInternalStream(firstTR, 0);
    PlusDM = instance:addInternalStream(firstTR, 0);
    MinusDM = instance:addInternalStream(firstTR, 0);
	
    TR_W = core.indicators:create("WMA", TR, N);
    PlusDM_W = core.indicators:create("WMA", PlusDM, N);
    MinusDM_W = core.indicators:create("WMA", MinusDM, N);

    first = TR_W.DATA:first();

    local name = profile:id() .. "(" .. source:name() .. ", " .. N .. ")";
    instance:name(name);
	
    DIP = instance:addStream("DIP", core.Line, name .. ".DIP", "DI+", instance.parameters.clrDIP, first)
    DIP:setPrecision(math.max(2, instance.source:getPrecision()));
	DIP:setWidth(instance.parameters.widthP);
    DIP:setStyle(instance.parameters.styleP);
	
    DIM = instance:addStream("DIM", core.Line, name .. ".DIM", "DI-", instance.parameters.clrDIM, first)
    DIM:setPrecision(math.max(2, instance.source:getPrecision()));
	DIM:setWidth(instance.parameters.widthM);
    DIM:setStyle(instance.parameters.styleM);
	
	 
	 instance:createChannelGroup("Group","Group" , DIP, DIM, UP, Transparency);
	
end

-- Indicator calculation routine
function Update(p, mode)
    if p >= firstTR then
        local th, tl;

        if C[p - 1] > H[p] then
            th = C[p - 1];
        else
            th = H[p];
        end

        if C[p - 1] < L[p] then
            tl = C[p - 1];
        else
            tl = L[p];
        end

        TR[p] = th - tl;

        if H[p] > H[p - 1] and L[p] >= L[p - 1] then
            PlusDM[p] = H[p] - H[p - 1];
        elseif  H[p] > H[p - 1] and L[p] < L[p - 1] and ((H[p] - H[p - 1]) > (L[p - 1] - L[p])) then
            PlusDM[p] = H[p] - H[p - 1];
        else
            PlusDM[p] = 0;
        end
        if L[p] < L[p - 1] and H[p] <= H[p - 1] then
            MinusDM[p] = L[p - 1] - L[p];
        elseif  L[p] < L[p - 1] and H[p] > H[p - 1] and ((H[p] - H[p - 1]) < (L[p - 1] - L[p])) then
            MinusDM[p] = L[p - 1] - L[p];
        else
            MinusDM[p] = 0;
        end
    end

    TR_W:update(mode);
    PlusDM_W:update(mode);
    MinusDM_W:update(mode);

    if p >= first then
        DIP[p] = 100 * PlusDM_W.DATA[p] / TR_W.DATA[p]
        DIM[p] = 100 * MinusDM_W.DATA[p] / TR_W.DATA[p]

		if  DIP[p] >  DIM[p] then
		DIP:setColor(p,UP)
		else
		DIP:setColor(p,DN)
		end
		
    end
end


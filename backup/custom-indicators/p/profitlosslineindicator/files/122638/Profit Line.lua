-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2236

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("Shows breakeven/profit price level for the current instrument");
    indicator:description("The indicator shows the price at which the currently held positions will have zero profit");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
 
    
	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addDouble("Profit", "Profit (in Pips)", "", 100);
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("LC", "Long Positions Level color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("SC", "Short positions level color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("BC", "Break Even positions level color", "", core.rgb(0, 0, 55));
	
	indicator.parameters:addColor("PC", "Profit Level color", "", core.rgb( 212, 175, 55));
	
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_DOT);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local LC;
local SC;
local BC;
local PC;

local style;
local width;

local Profit;

local instrument;
local first;
local source = nil;
local format;

-- Streams block

local sellA;
local sellP=0;
local BreakEven=0;
local buyA;
local buyP=0;
		

local timer;

-- Routine
function Prepare(onlyName)
    source = instance.source;
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);

    if onlyName then
        return ;
    end
	

    sellP=0;
    BreakEven=0;
    buyP=0;

    BC = instance.parameters.BC;
	LC = instance.parameters.LC;
    SC = instance.parameters.SC;
	PC = instance.parameters.PC;
    style = instance.parameters.style;
    width = instance.parameters.width;
	
	
	Profit = instance.parameters.Profit;
	
    instrument = source:instrument();
    format = "%s:%." .. source:getPrecision() .. "f";

 
    timer = core.host:execute("setTimer", 1, 1);
	
	
	instance:ownerDrawn(true);
end


local init = false;
 
function Draw(stage, context)
    if stage ~= 2 then
	return;
	end
	
	
        if not init then
            context:createPen (1, context:convertPenStyle (style), width, LC)
			context:createPen (2, context:convertPenStyle (style), width, SC)
			context:createPen (3, context:convertPenStyle (style), width, BC)
			context:createPen (4, context:convertPenStyle (style), width, PC)
            init = true;
        end
 
    if buyP~=0 then
    visible, y1 = context:pointOfPrice (buyP);
    context:drawLine (1, context:left (), y1, context:right (), y1);
	end
	if sellP~=0 then
	visible, y2 = context:pointOfPrice (sellP);
	context:drawLine (2, context:left (), y2, context:right (), y2)
	end
	
	if BreakEven~=0 and buyA > 0.00001  and  sellA > 0.00001 then
	visible, y3=  context:pointOfPrice (BreakEven)
	context:drawLine (3, context:left (), y3, context:right (), y3)
	end
	
	
	if BreakEven~=0  then
	if buyA== 0  then
	visible, y4=  context:pointOfPrice (BreakEven - source:pipSize ()*Profit*sellA);
	elseif sellA== 0  then
	visible, y4=  context:pointOfPrice (BreakEven + source:pipSize ()*Profit*buyA);
	elseif buyA~=sellA then
	
			if sellA > buyA then
			visible, y4=  context:pointOfPrice (BreakEven - source:pipSize ()*Profit*math.abs(sellA-buyA));	
			else
			visible, y4=  context:pointOfPrice (BreakEven + source:pipSize ()*Profit*math.abs(sellA-buyA));	
			end
	else
	y4=0;
	end
		if y4~=0 then
		context:drawLine (4, context:left (), y4, context:right (), y4)
		end
	end
 end

-- Indicator calculation routine
function Update(period, mode)
   
end

local _sellP = -1;
local _buyP = -1;

function AsyncOperationFinished(cookie, success, message)
    if cookie == 1 and source:size() > source:first() then
      
        local table, enum, row;
        

        table = core.host:findTable("summary");
        if table == nil then
            return ;
        end
        enum = table:enumerator();
        row = enum:next();
        sellA = 0;
        sellP = 0;
        buyA = 0;
        buyP = 0;
        while row ~= nil do
            if row.Instrument == instrument then
                sellA = sellA + row.SellAmountK;
                sellP = sellP + row.SellAvgOpen * sellA;
                buyA = buyA + row.BuyAmountK;
                buyP = buyP + row.BuyAvgOpen * buyA;
            end
            row = enum:next();
        end

        if sellA > 0.00001 then
            sellP = sellP / sellA;
        end
        if buyA > 0.00001 then
            buyP = buyP / buyA;
        end
		
		if buyA > 0.00001  or sellA > 0.00001 then
            BreakEven = (buyP*buyA+sellP*sellA) / (buyA+sellA);
        end
		

        
        return core.ASYNC_REDRAW;
    end
end

function ReleaseInstance()
    core.host:execute("killTimer", timer);
end

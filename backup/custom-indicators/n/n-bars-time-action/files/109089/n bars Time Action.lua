-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64101&p=109089#p109089

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("n bars Time Action");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);


	
	indicator.parameters:addGroup("Placement");	
    indicator.parameters:addInteger("Shift", "Shift","" , 10);
	
	indicator.parameters:addString("CustomID", "Custom Identifier", "The identifier that can be used to distinguish strategy instances", "CustomID");	

    indicator.parameters:addBoolean("InstrumentFilter", "Use Position Instrument as Filter ", "", true);
	indicator.parameters:addBoolean("CustomIDFilter", "Use Position CustomID as Filter ", "", false);
	indicator.parameters:addBoolean("TradeFilter", "Use Trade as Filter ", "", false);
	indicator.parameters:addString("Trade", "Choose Trade", "", "");
    indicator.parameters:setFlag("Trade", core.FLAG_TRADE);
 
	
	indicator.parameters:addGroup("Style");
   indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 0, 0)); 
   indicator.parameters:addColor("selected", "Selected Position Color", "", core.rgb(0, 0, 255)); 
   
   indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
    
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;
local Shift;
local InstrumentFilter, CustomIDFilter, CustomID;
local Offer;
local Trade;
local TradeFilter;
-- Routine
function Prepare(onlyName)


    source = instance.source;
    first=source:first();
    Trade=instance.parameters.Trade;
	Shift=instance.parameters.Shift;
	InstrumentFilter=instance.parameters.InstrumentFilter;
	CustomIDFilter=instance.parameters.CustomIDFilter;
	CustomID=instance.parameters.CustomID;
	TradeFilter=instance.parameters.TradeFilter;
    local name = profile:id() .. "(" .. source:name() .. ")";
	instance:name(name);
	if onlyName then
		return;
	end
	Offer = core.host:findTable("offers"):find("Instrument", source:instrument()).OfferID;
   
	
   	
    instance:ownerDrawn(true);

	
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
 
function Update(period)   

  
end
 
local init = false;
 
function Draw(stage, context)
 
	  if stage~= 2 then
	  return;
	  end
	
        if not init then 
		   context:createPen (1, context:convertPenStyle (instance.parameters.style), instance.parameters.width, instance.parameters.color);
           context:createPen (2, context:convertPenStyle (instance.parameters.style), instance.parameters.width, instance.parameters.selected);		   		   
            init = true;
        end
		
 
	
	local enum, row;
    local count = 0;
    enum = core.host:findTable("trades"):enumerator();
    row = enum:next();
    while row ~= nil do
        if (not InstrumentFilter or (row.OfferID == Offer and InstrumentFilter))
		and ( not CustomIDFilter or ( row.QTXT == CustomID  and CapCustomIDFilter))
		and ( not TradeFilter or ( row.TradeID == Trade  and TradeFilter))
		
		
		then       
				p= core.findDate (source, row.Time, false);
				if p~= -1 then
				x1, d1, d2 = context:positionOfBar (p);
				 Delta=(d2-d1)*Shift;
					 if row.TradeID == Trade then
					 context:drawLine (2, x1, context:top (), x1, context:bottom () );  
					 context:drawLine (2, x1+Delta, context:top (), x1+Delta, context:bottom () ); 
					 else
					 context:drawLine (1, x1, context:top (), x1, context:bottom () );  
					 context:drawLine (1, x1+Delta, context:top (), x1+Delta, context:bottom () ); 
					 end				 
				end 	   
        end

        row = enum:next();
    end 
 
end		




 
 
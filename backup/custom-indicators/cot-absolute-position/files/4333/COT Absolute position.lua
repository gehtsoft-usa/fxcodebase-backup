-- Id: 3777

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2103

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




local labels = {
  ["!090741"] = "CANADIAN DOLLAR",
  ["!092741"] = "SWISS FRANC",
  ["!095741"] = "MEXICAN PESO",
  ["!096742"] = "BRITISH POUND",
  ["!097741"] = "JAPANESE YEN",
  ["!098662"] = "U.S. DOLLAR INDEX",
  ["!099741"] = "EURO FX",
  ["!112741"] = "NEW ZEALAND DOLLAR",
  ["!232741"] = "AUSTRALIAN DOLLAR",
 	["!089741"] = "RUSSIAN RUBLE",
	["!102741"] = "BRAZILIAN REAL - CHICAGO MERCANTILE EXCHANGE",
	
 	["!1170E1"] = "VIX FUTURES",   		
  ["!042601"] = "2-YEAR U.S. TREASURY NOTES",   
  ["!043602"] = "10-YEAR U.S. TREASURY NOTES",   
  ["!044601"] = "5-YEAR U.S. TREASURY NOTES",   
 
 	["!33874A"] = "E-MINI S&P 400 STOCK INDEX",   
  ["!23977A"] = "RUSSELL 2000 MINI INDEX FUTURE",   
   ["!240741"] = "NIKKEI STOCK AVERAGE - CHICAGO MERCANTILE EXCHANGE", 
  ["!209742"] = "NASDAQ-100 STOCK INDEX (MINI)",     
  ["!138741"] = "S&P 500 STOCK INDEX - CHICAGO MERCANTILE EXCHANGE",   
  
	["!088691"] = "GOLD",
 	["!085692"] = "COPPER",   
  ["!084691"] = "SILVER",  
  ["!075651"] = "PALLADIUM",   
 	["!076651"] = "PLATINUM",
	["!067411"] = "CRUDE OIL, LIGHT SWEET - ICE FUTURES EUROPE",
	["!067651"] = "CRUDE OIL, LIGHT SWEET - NEW YORK MERCANTILE EXCHANGE",
	["!06765T"] = "BRENT CRUDE OIL LAST DAY - NEW YORK MERCANTILE EXCHANGE",
}


local currencies = {
    ["CAD"] = "!090741",
    ["CHF"] = "!092741",
    ["MXN"] = "!095741",
    ["GBP"] = "!096742",
    ["JPY"] = "!097741",
    ["USD"] = "!098662",
    ["EUR"] = "!099741",
    ["NZD"] = "!112741",
    ["AUD"] = "!232741",
	["RUB"] = "!089741", 

}

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("COT Absolute position");
    indicator:description("COT Absolute position");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
    indicator.parameters:addGroup("Selector");
	indicator.parameters:addBoolean("Noncommercial", "Show Noncommercial", "" ,  true);
	indicator.parameters:addBoolean("Commercial", "Show Commercial", "" ,  true);
	indicator.parameters:addBoolean("Difference", "Show Difference", "" ,  true);
	
    indicator.parameters:addGroup("Calcultion");
    indicator.parameters:addGroup("Auto or Instrument Selection");
    indicator.parameters:addBoolean("AUTO", "Auto", "Auto" ,  true);

	 indicator.parameters:addString("Instrument", "Instrument", " Instrument Selection" , "!098662");
    for k,v in pairs(labels) do
     indicator.parameters:addStringAlternative("Instrument", v, "Select " .. v, k);
    end
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Absolute_Color", "Absolute Line Color for Noncommercial", "Absolute Line Colorfor Noncommercial", core.rgb(255, 0, 0));	
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("Absolute_Color1", "Absolute Line Color for Commercial", "Absolute Line Colorfor Commercial", core.rgb(0, 255, 0));	
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("Absolute_Color2", "Line Color for Difference", "Line Color for Difference", core.rgb(0, 0, 255));	
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local COT;
local COT1;
local Noncommercial, Commercial,Difference;
local UseNoncommercial, UseCommercial,UseDifference;
local Instrument;

local instrument1;
local instrument2;

 
local AUTO;

local first;
local source = nil;

local Absolute_Color;
local Absolute_Color1;
local Absolute_Color2;
local pauto =  "(%a%a%a)/(%a%a%a)";
local name;
-- Routine
function Prepare(nameOnly) 
    
    AUTO = instance.parameters.AUTO;
    Absolute_Color = instance.parameters.Absolute_Color;
	Absolute_Color1 = instance.parameters.Absolute_Color1;
	Absolute_Color2 = instance.parameters.Absolute_Color2;
	Instrument = instance.parameters.Instrument;
	UseDifference= instance.parameters. Difference;
	UseCommercial= instance.parameters. Commercial;
	UseNoncommercial= instance.parameters. Noncommercial;
    	
    source = instance.source;
	
	assert(core.indicators:findIndicator("COTA") ~= nil, "Please, download and install COTA.LUA indicator");    
	assert(core.indicators:findIndicator("COTA") ~= nil, "Please, download and install COTA.LUA indicator");    
    
	
	 local label=instrument or "undefined";

    if labels[Instrument] ~= nil then
        label = labels[Instrument];
    end

   
    if AUTO then  
	
			local crncy1, crncy2 = string.match(source:name(), pauto);
					
			if crncy1 == nil and crncy2 == nil then
			error("Unsupported instrument.");
			end
				
				
				
			COT = core.indicators:create("COTA", source, false, false, "Noncommercial");	
			COT1 = core.indicators:create("COTA", source,false, false, "Commercial");
			name = profile:id() .. "(" .. crncy1 .."/" .. crncy2.. ")";
            instance:name(name);
			
		 
	else
    assert(core.indicators:findIndicator("COT") ~= nil, "COT" .. " indicator must be installed");
	        COT = core.indicators:create("COT", source,  Instrument, false, false, "Noncommercial");
			COT1 = core.indicators:create("COT", source, Instrument, false, false, "Commercial");
	        name = profile:id() .. "(" .. label..")";
            instance:name(name);
			
			
	end  
	
	
	
	
	        first = math.max(source:first(),COT.DATA:first(),COT1.DATA:first() );    
			
			
	if   (nameOnly) then
        return;
    end
	
			
			if UseNoncommercial then
			Noncommercial = instance:addStream("Noncommercial", core.Line, name .. "Absolute Noncommercial", "Absolute Noncommercial",  Absolute_Color, first);
			Noncommercial:setWidth(instance.parameters.width1);
            Noncommercial:setStyle(instance.parameters.style1);
		    Noncommercial:addLevel(0.5);
			else
			Noncommercial= instance:addInternalStream(first, 0);			
			end
			if UseCommercial then 
			Commercial = instance:addStream("Commercial", core.Line, name .. "Absolute Commercial", "Absolute Commercial",  Absolute_Color1, first);
			Commercial:setWidth(instance.parameters.width2);
            Commercial:setStyle(instance.parameters.style2);
			Commercial:addLevel(0.5);
			else
			Commercial= instance:addInternalStream(first, 0)
			end
			
			if UseDifference then
			Difference= instance:addStream("Difference", core.Line, name .. "Difference", "Difference",  Absolute_Color2, first);
			Difference:setWidth(instance.parameters.width3);
            Difference:setStyle(instance.parameters.style3);
			Difference:addLevel(0.5);
			else
			Difference= instance:addInternalStream(first, 0);
			end     
   
   
            Noncommercial:setPrecision(math.max(2, instance.source:getPrecision()));
			Commercial:setPrecision(math.max(2, instance.source:getPrecision()));
			Difference:setPrecision(math.max(2, instance.source:getPrecision()));			
        
   
        
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
   
    if period < first or not source:hasData(period) then	
	return;
	end   
   
	if COT ~= nil then COT:update(mode); end
	if COT1 ~= nil then COT1:update(mode); end
	
			
		   
		 Noncommercial[period]=math.abs(COT.COTLong[period])/(math.abs(COT.COTLong[period])+math.abs(COT.COTShort[period]));
		 Commercial[period]=math.abs(COT1.COTLong[period])/(math.abs(COT1.COTLong[period])+math.abs(COT1.COTShort[period]));
		 Difference[period]=(math.max(Commercial[period], Noncommercial[period]) -  math.min (Commercial[period], Noncommercial[period])) /2 +  math.min (Commercial[period], Noncommercial[period]);	
		
		
end



-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72417

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                              Support our efforts by donating   | 
--|                                                                 Paypal: https://goo.gl/9Rj74e  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+

--Your donations will allow the service to continue onward.
--+------------------------------------------------------------------------------------------------+
--|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
--|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
--|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
--|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
--|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
--|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
--+------------------------------------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("ZigZag Median")
    indicator:description("")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Indicator) 
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addBoolean("ShowZZ", "Show ZigZag Lines", "", true);
    indicator.parameters:addColor("color1", "Top Line Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("color2", "Bottom Line Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("color3", "Central Line Color", "", core.rgb(0, 0, 255));
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local source = nil
local ZigZag
local first

-- Routine
function Prepare(nameOnly)
    source = instance.source

local name = profile:id() .. "(" .. source:name() .. ")"
instance:name(name)

if (nameOnly) then
	return
end

	-- Parametres	
	ZigZag = core.indicators:create("ZIGZAG", source, 12, 5, 3, core.rgb(0, 255, 0), core.rgb(255, 0, 0))
    
	first = ZigZag.DATA:first()

instance:ownerDrawn(true)
end

-- Indicator calculation routine
function Update(period)
    if period < source:size() - 1 then
        return
    end

    ZigZag:update(core.UpdateAll)
end

local init = false

function Draw(stage, context)
    if stage ~= 2 then
        return
    end

    if not init then
        context:createPen(
            1,
            context:convertPenStyle(core.LINE_SOLID),
            context:pointsToPixels(1),
            core.rgb(0, 255, 0)
        )
        context:createSolidBrush(2, core.rgb(0, 255, 0))
        context:createPen(
            3,
            context:convertPenStyle(core.LINE_SOLID),
            context:pointsToPixels(1),
            core.rgb(255, 0, 0)
        )
        context:createSolidBrush(4, core.rgb(255, 0, 0))
        init = true
    end

    local Last = math.min(context:lastBar(), (ZigZag.DATA:size() - 1)) - 1
    local First = math.max(context:firstBar(), first) + 1

    local min = math.huge;
	local max = 0;
	local count=0;
	local Start=nil;
    for i =   Last ,  First, - 1 do


      
        if
            ZigZag.DATA:colorI(i) == core.rgb(0, 255, 0) and ZigZag.DATA:colorI(i - 1) ~= core.rgb(0, 255, 0) or
            ZigZag.DATA:colorI(i) == core.rgb(0, 255, 0) and ZigZag.DATA[i + 1] == nil
         then 
		    max=math.max(max,ZigZag.DATA[i]);
			count=count+1;
			if instance.parameters.ShowZZ then
				core.host:execute("drawLine", 1, source:date(i), source.low[i], source:date(source:size()-1), source.low[i],  instance.parameters.color1);
			 
			end
			Start=i;
        end
        
		if
            ZigZag.DATA:colorI(i) == core.rgb(255, 0, 0) and ZigZag.DATA:colorI(i - 1) ~= core.rgb(255, 0, 0) or
                ZigZag.DATA:colorI(i) == core.rgb(255, 0, 0) and ZigZag.DATA[i + 1] == nil 
         then
		    min=math.min(min,ZigZag.DATA[i]);
            count=count+1; 
			
			if instance.parameters.ShowZZ then
				core.host:execute("drawLine", 2, source:date(i), source.high[i], source:date(source:size()-1), source.high[i], instance.parameters.color2);
			 
			end
			Start=i;			
        end

    
			

        if count == 2 then 
        break;
        end		
	end
	
	
	if instance.parameters.ShowZZ and Start~= nil then
				local middle = min+(max-min)/2
				core.host:execute("drawLine", 3, source:date(Start), middle, source:date(source:size()-1), middle,  instance.parameters.color3);
			 
    end
         	
			
			
end

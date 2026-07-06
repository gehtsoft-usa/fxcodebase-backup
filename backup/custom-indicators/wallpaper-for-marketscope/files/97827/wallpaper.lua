-- Id: 13300
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61623

--+------------------------------------------------------------------+
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

-- Wallpaper
-- Copyright (c) 2014 Steven Dickinson
-- http://robocod.blogspot.co.uk/
--
-- Notes:
-- Version 1 - First version

-- Local variables
local source;
local host;
local useOwnerDrawn;
local fileName;
local width;
local height;
local colour;

-- Create the indicator's profile
function Init()
    indicator:name("Wall Paper");
    indicator:description("Wall Paper");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    --indicator:setTag("group", "TBD");
    --indicator:setTag("replaceSource", "t"); 

    local colour = core.colors();
	indicator.parameters:addString("fileName", "File name", "", "");
    indicator.parameters:addInteger("width", "Width (in pixels)", "", 100);
    indicator.parameters:addInteger("height", "Height (in pixels)", "", 100);
	
    indicator.parameters:addString("vPos", "Vertical position", "", "Middle");
    indicator.parameters:addStringAlternative("vPos", "Top", "", "Top");
    indicator.parameters:addStringAlternative("vPos", "Middle", "", "Middle");
    indicator.parameters:addStringAlternative("vPos", "Bottom", "", "Bottom");
	
    indicator.parameters:addString("hPos", "Horizontal position", "", "Centre");
    indicator.parameters:addStringAlternative("hPos", "Left", "", "Left");
    indicator.parameters:addStringAlternative("hPos", "Centre", "", "Centre");
    indicator.parameters:addStringAlternative("hPos", "Right", "", "Right");
	
	indicator.parameters:addBoolean("transparent", "Select transparent colour", "", true);
    indicator.parameters:addColor("colour", "Transparent colour", "", colour.White);
    indicator.parameters:addInteger("transparency", "Transparency percentage", "", 50, 0, 100);
end

-- Create a new instance of the indicator
function Prepare(nameOnly)
    -- Create locals for these commonly used variables
    source = instance.source;
    host = core.host;
	
	-- Set the indicator name
    local name = string.format("%s(%s)", profile:id(), instance.parameters.fileName);
    instance:name(name);

    if nameOnly then
        return
    end
	
	-- Initialize variables
	fileName = instance.parameters.fileName;
	width = instance.parameters.width;
	height = instance.parameters.height;
	colour = instance.parameters.colour;
	transparent = instance.parameters.transparent;
	
	-- Owner drawn indicator
	useOwnerDrawn = true;
	instance:ownerDrawn(true);
end

-- Update the indicator
function Update(period, mode)
	-- Nothing to do yet
end

-- Release the indicator
function ReleaseInstance()
    -- Nothing to do yet
end

-- Handle asynchronous events
function AsyncOperationFinished(cookie, success, message)
    -- Nothing to do yet
end

-- OwnerDrawn Draw routine
local init = false;
local transparency;
local vpos;
local hpos;
function Draw(stage, context)
    -- Exit immediately if nothing to do
    if not useOwnerDrawn then
        return;
    end
    
    if stage == 0 then
        if not init then
			context:loadPicture(0, fileName);
			hpos = instance.parameters.hPos;
			vpos = instance.parameters.vPos;
			transparency = context:convertTransparency(instance.parameters.transparency);
            init = true;
        end
		
		local x;
		if hpos == "Left" then
			x = context:left();
		elseif hpos == "Centre" then
			x = (context:left() + context:right() - width) / 2;
		elseif hpos == "Right" then
			x = context:right() - width;
		end
		
		local y;
		if vpos == "Top" then
			y = context:top();
		elseif vpos == "Middle" then
			y = (context:top() + context:bottom() - height) / 2;
		elseif vpos == "Bottom" then
			y = context:bottom() - height;
		end
		
		if transparent then
			context:drawPictureTransparentBackground(0, x, y, colour, transparency);
		else
			context:drawPicture(0, x, y, transparency);
		end
    end
end
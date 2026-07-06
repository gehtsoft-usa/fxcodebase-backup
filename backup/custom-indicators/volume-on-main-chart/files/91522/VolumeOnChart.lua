-- Id: 10696

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=58824

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Volume on chart");
    indicator:description("Shows volume in the main chart.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	
    indicator.parameters:addGroup("Style");
    indicator.parameters:addString("Position", "Position", "", "1");
    indicator.parameters:addStringAlternative("Position", "Top", "", "0");
    indicator.parameters:addStringAlternative("Position", "Bottom", "", "1");
    indicator.parameters:addInteger("Height", "Height (% of chart height)", "", 20);
    indicator.parameters:addColor("color", "Fill Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("transparency", "Fill Transparency", "0 - opaque, 100 - transparent", 75, 0, 100);
end

local source = nil;
local first;
local color;
local transparency;
local Position;
local Height;


-- initializes the instance of the indicator
function Prepare(onlyName)
    source = instance.source;
    first = source:first();
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);

    if onlyName then
        return ;
    end
	
	local Instrument=source:instrument();

    instance:ownerDrawn(true);
    
    Position = tonumber(instance.parameters.Position)
    Height = instance.parameters.Height/100; 
    color = instance.parameters.color;

    instance:setLabelColor(color);
end
 


function Update(period)
end

local init = false;

function Draw(stage, context)
    if stage == 2 then
    
        if not init then
            context:createSolidBrush(2, color);
            context:createPen(1, context.SOLID, 1, color);
            transparency = context:convertTransparency(instance.parameters.transparency);
            init = true;
        end
        
     
        
        local firstBar, lastBar = context:firstBar(), context:lastBar();
        firstBar=math.max(firstBar, first);
        lastBar=math.min(lastBar, source:size()-1);
        local firstBarSrc = core.findDate(source, source:date(firstBar), false);
        local lastBarSrc = core.findDate(source, source:date(lastBar), false);
        local MaxVolume=mathex.max(source.volume, firstBarSrc, lastBarSrc);
        
        if MaxVolume==0 then
         return;
        end
        
        local top, bottom = context:top(), context:bottom();
        local HeightCoeff=(bottom-top)*Height/MaxVolume;
        
        local BarHeight;
        local barSrc;
        local y1, y2;

        context:startEnumeration();
        while true do
            index, x, x1, x2, c1, c2 = context:nextBar();
            if index == nil then
                break;
            end
            
            barSrc=core.findDate(source, source:date(index), true);
            if barSrc==-1 then
             BarHeight=0;
            else
             BarHeight=HeightCoeff*source.volume[barSrc];
            end

            if Position==0 then
             y1=top;
             y2=top+BarHeight;
            else
             y1=bottom-BarHeight;
             y2=bottom;
            end

            context:drawRectangle(1, 2, c1, y1, c2, y2, transparency);
            
        end

    end
end




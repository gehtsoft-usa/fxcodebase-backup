-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64414

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

function Init()
    indicator:name("Custom grid");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");

    indicator.parameters:addDouble("Price", "Price", "", 1);
    indicator.parameters:addInteger("Pip_count", "Pip count", "", 5);

    indicator.parameters:addGroup("Style"); 
    indicator.parameters:addColor("height", "Text height", "", 10);
    indicator.parameters:addColor("color", "Price Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("color1", "Up Color", "", core.rgb(0, 0, 255));
    indicator.parameters:addColor("color2", "Down Color", "", core.rgb(255, 0, 0));

    indicator.parameters:addInteger("Transparency", "Price Line Transparency", "", 0, 0, 255);
    indicator.parameters:addInteger("line_width", "Price Line Width", "", 1);
    indicator.parameters:addInteger("line_style", "Price Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("line_style", core.FLAG_LINE_STYLE);
    indicator.parameters:addInteger("Transparency1", "Up Lines Transparency", "", 0, 0, 255);
    indicator.parameters:addInteger("line_width1", "Up Lines Width", "", 1);
    indicator.parameters:addInteger("line_style1", "Up Lines Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("line_style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addInteger("Transparency2", "Down Lines Transparency", "", 0, 0, 255);
    indicator.parameters:addInteger("line_width2", "Down Lines Width", "", 1);
    indicator.parameters:addInteger("line_style2", "Down Lines Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("line_style2", core.FLAG_LINE_STYLE);

end

local source = nil;
local color, color1, color2, Transparency, Transparency1, Transparency2, line_width, line_width1, line_width2, line_style, line_style1, line_style2;
local Price, Pip_count;
local height;
function Prepare(nameOnly)

    source = instance.source;
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end

    instance:ownerDrawn(true);

    height=instance.parameters.height;
    Price=instance.parameters.Price;
    Pip_count=instance.parameters.Pip_count;
    color = instance.parameters.color;
    color1 = instance.parameters.color1;
    color2 = instance.parameters.color2;
    Transparency=instance.parameters.Transparency;
    line_width=instance.parameters.line_width;
    line_style=instance.parameters.line_style;
    Transparency1=instance.parameters.Transparency1;
    line_width1=instance.parameters.line_width1;
    line_style1=instance.parameters.line_style1;
    Transparency2=instance.parameters.Transparency2;
    line_width2=instance.parameters.line_width2;
    line_style2=instance.parameters.line_style2;

end

function Update(period)

end

local init = false;

function Draw(stage, context)
    if stage == 1 then
    
        if not init then
            
            context:createPen(11, context:convertPenStyle(line_style), line_width, color);
            context:createPen(22, context:convertPenStyle(line_style1), line_width1, color1);
            context:createPen(33, context:convertPenStyle(line_style2), line_width2, color2);
			
			context:createFont (10, "Arial", context:pointsToPixels (height), context:pointsToPixels (height), 0);
            
            init = true;

        end

        local visible, y = context:pointOfPrice (Price);
        local x_l = context:left ();
        local x_r = context:right ();

        if y<=context:bottom () and y>=context:top () then
            context:drawLine (11, x_l, y, x_r, y, Transparency);
        end

        local N = 1;
        while true do
            visible, y1 = context:pointOfPrice (Price+source:pipSize()*Pip_count*N);
            if y1<=context:bottom () then
                context:drawLine (22, x_l, y1, x_r, y1, Transparency1);
				
				Value=Price+source:pipSize()*Pip_count*N;
				text= win32.formatNumber(Value, false, source:getPrecision());
				tw, th = context:measureText (10, text, 0);
				context:drawText (10, text, color, -1, x_r-tw, y1-th, x_r, y1, 0, 0);				
				
            end
            N=N+1;
            if y1<context:top () then
                break;
            end
        end
        local M = 1;
        while true do
            visible, y2 = context:pointOfPrice (Price-source:pipSize()*Pip_count*M);
            if y2>=context:top () then
                context:drawLine (33, x_l, y2, x_r, y2, Transparency2);
				
				Value=Price-source:pipSize()*Pip_count*M;
				text= win32.formatNumber(Value, false, source:getPrecision());
				tw, th = context:measureText (10, text, 0);
				context:drawText (10, text, color2, -1, x_r-tw, y1-th, x_r, y1, 0, 0);
				
            end
            M=M+1;
            if y2>context:bottom () then
                break;
            end
        end
    end
end




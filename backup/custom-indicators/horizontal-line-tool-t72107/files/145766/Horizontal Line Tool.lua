-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72107

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
    indicator:name("Horizontal Line Tool");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
 

   Add(1, true, core.rgb(0, 0, 255),3,core.LINE_SOLID);
   Add(2, false, core.rgb(0, 255, 0),3,core.LINE_SOLID);
   Add(3, false, core.rgb(255, 0, 0),3,core.LINE_SOLID);
   Add(4, false, core.rgb(0, 0, 255),3,core.LINE_DASH);
   Add(5, false, core.rgb(0, 255, 0),3,core.LINE_DASH);
   Add(6, false, core.rgb(255, 0, 0),3,core.LINE_DASH);
   Add(7, false, core.rgb(0, 0, 255),3,core.LINE_DOT);
   Add(8, false, core.rgb(0, 255, 0),3,core.LINE_DOT);
   Add(9, false, core.rgb(255, 0, 0),3,core.LINE_DOT);
   Add(10, false, core.rgb(0, 255, 0),3,core.LINE_DASHDOT);
   
  indicator.parameters:addGroup( "Label Style");  
  indicator.parameters:addInteger("Size" , "Font Size", "", 10); 
  indicator.parameters:addColor("LabelColor"  , "Labe Color", "", core.COLOR_LABEL ); 
   
end

function Add(id, On, Color, Width, Style)

indicator.parameters:addGroup(id ..". Line");
indicator.parameters:addBoolean("On"..id , "Show  This Line", "", On);
indicator.parameters:addBoolean("Onward"..id , "Onward Only", "", false);
indicator.parameters:addDouble("Price"..id , "Line Price Level", "", 0);

indicator.parameters:addBoolean("Show1"..id , "Show on m1", "", false);
indicator.parameters:addBoolean("Show2"..id , "Show on m5", "", false);
indicator.parameters:addBoolean("Show3"..id , "Show on m15", "", false);
indicator.parameters:addBoolean("Show4"..id , "Show on m30", "", false);
indicator.parameters:addBoolean("Show5"..id , "Show on H1", "", false);
indicator.parameters:addBoolean("Show6"..id , "Show on H2", "", false);
indicator.parameters:addBoolean("Show7"..id , "Show on H3", "", false);
indicator.parameters:addBoolean("Show8"..id , "Show on H4", "", false);
indicator.parameters:addBoolean("Show9"..id , "Show on H6", "", false);
indicator.parameters:addBoolean("Show10"..id , "Show on H8", "", false);
indicator.parameters:addBoolean("Show11"..id , "Show on D1", "", false);
indicator.parameters:addBoolean("Show12"..id , "Show on W1", "", false);
indicator.parameters:addBoolean("Show13"..id , "Show on M1", "", false);

indicator.parameters:addString("Label"..id , id.. ". Line Label", "",  id.. ". Line");

indicator.parameters:addColor("color"..id , "Line Color", "", Color);
indicator.parameters:addInteger("width"..id , "Line Width", "", Width, 1, 5);
indicator.parameters:addInteger("style"..id , "Line Style", "", Style);
indicator.parameters:setFlag("style"..id , core.FLAG_LINE_STYLE);
 
end
 
local color={};
local style={};
local width={};
 
local Price={};
local Label={};
local first;
local source;
local Size;
local LabelColor;
local Onward= {};
local On={};
function Prepare(onlyName)
     
	source = instance.source; 
	first=source:first();
    local name;
    name = profile:id() .. "(" .. instance.source:name()  .. ")";
    instance:name(name);

    if onlyName then
        return ;
    end 
	
    Size=instance.parameters.Size;
	LabelColor=instance.parameters.LabelColor;
	
	for i= 1, 10 , 1 do
	On[i]=instance.parameters:getBoolean("On" .. i);
	Onward[i]=instance.parameters:getBoolean("Onward" .. i);
	color[i]=instance.parameters:getColor("color" .. i);
	width[i]=instance.parameters:getInteger("width" .. i);
    style[i]=instance.parameters:getInteger("style" .. i);
	Price[i]=instance.parameters:getDouble("Price" .. i);	
	Label[i]=instance.parameters:getString("Label" .. i);	
	
		 
	end
	
	local Array={};
	Array["m1"]=1;
	Array["m5"]=2;
	Array["m15"]=3;
	Array["m30"]=4;
	Array["H1"]=5;
	Array["H2"]=6;
	Array["H3"]=7;
	Array["H4"]=8;
	Array["H6"]=9;
	Array["H8"]=10;
	Array["D1"]=11;
	Array["W1"]=12;
	Array["M1"]=13;
	
	
	local TF= Array[source:barSize()];
	
	
	for i= 1, 10 , 1 do	
		if On[i] and not instance.parameters:getBoolean("Show" .. TF.. i) then	
		On[i]=false;
		end	
	end
	
   instance:ownerDrawn(true);

end


function Update(period)     
end 


local init = false;
function Draw(stage, context)
    if stage ~= 2  
	then
	return;
	
	
	end
        if not init then
		    for i=1, 10 , 1 do
            context:createPen (i, context:convertPenStyle (style[i]), width[i], color[i]);
			end
            init = true;
			
			context:createFont (11, "Arial", context:pointsToPixels (Size), context:pointsToPixels (Size), 0);
         end

	
	local visible, y;
	
	for i=1, 10 , 1 do
		if On[i]  then		 
		visible, y = context:pointOfPrice (Price[i]);	
        if Onward[i] then
		x, X, X= context:positionOfBar (source:size()-1);
		context:drawLine (i, x, y, context:right (), y);		
        else		
		context:drawLine (i, context:left (), y, context:right (), y);
		end
		
		width, height = context:measureText (11, Label[i], 0);
		context:drawText (11, Label[i], LabelColor,-1, context:right () -width , y-height, context:right (), y, 0);
		
		end
    end
	
end
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=28&t=61403

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+

-- Local variables
local source;
local host;
local font1;
local font2;
local lastSerial = nil;

-- Create the indicator's profile
function Init()
    indicator:name("Watermark With Placement");
    indicator:description(" ");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    --indicator:setTag("group", "MyCode");
    
    local colour = core.colors();
    
    -- Display options
    indicator.parameters:addGroup("Display options");
	
	
	indicator.parameters:addGroup("Placement");
	indicator.parameters:addString("Y", " Y Placement","" , "Bottom");
    indicator.parameters:addStringAlternative("Y", "Top", "Top" , "Top");
    indicator.parameters:addStringAlternative("Y", "Bottom", "Bottom" , "Bottom"); 
	
	indicator.parameters:addString("X", " X Placement","" , "Left");
    indicator.parameters:addStringAlternative("X", "Right", "Right" , "Right");
    indicator.parameters:addStringAlternative("X", "Left", "Left" , "Left"); 
	
	indicator.parameters:addInteger("W", "Placement","" , 0);
    indicator.parameters:addIntegerAlternative("W", "Above", "Above" , 2);
    indicator.parameters:addIntegerAlternative("W", "Below", "Below" , 0); 
	
	indicator.parameters:addInteger("ShiftY", "Shift","" , 0);
	
    indicator.parameters:addString("Mode", "Mode", "", "Instrument2");
    indicator.parameters:addStringAlternative("Mode", "Instrument", "", "Instrument1");
    indicator.parameters:addStringAlternative("Mode", "Instrument and time-frame", "", "Instrument2"); 
	indicator.parameters:addStringAlternative("Mode", "Off", "", "Off")
	
    indicator.parameters:addString("Text1", "Watermark text", "", "@mariojemic");
	 indicator.parameters:addString("Text2", "Watermark text", "", "Fxcodebase.com");
	
	indicator.parameters:addBoolean("Watermark", "Show Watermark", "", true);
    indicator.parameters:addString("Format", "Date format", "", "DDMMYYYY");   
    indicator.parameters:addStringAlternative("Format", "DD/MM/YYYY", "", "DDMMYYYY");
    indicator.parameters:addStringAlternative("Format", "MM/DD/YYYY", "", "MMDDYYYY");
	indicator.parameters:addStringAlternative("Format", "Off", "", "Off");
    
    -- Colours and effects
    indicator.parameters:addGroup("Colours and effects");
    indicator.parameters:addColor("Color", "Color", "", core.rgb(220, 220, 220));
    indicator.parameters:addString("fontName", "Font", "", "Arial Black");
	indicator.parameters:addDouble("Size", "Size as % of Chart", "", 10)
 
	
end
local ShiftY;
local Watermark;
local Size;
local Color;
local Mode;
local Format; 
local Text1, Text2;
local X, Y,W;
-- Create a new instance of the indicator
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	ShiftY=instance.parameters.ShiftY;
	X=instance.parameters.X;
	Y=instance.parameters.Y;
	W=instance.parameters.W;	
    Size=instance.parameters.Size;
	Color=instance.parameters.Color;
	Mode=instance.parameters.Mode;
	Format=instance.parameters.Format;
	Text1=instance.parameters.Text1;
	Text2=instance.parameters.Text2;
    source = instance.source;
	Watermark=instance.parameters.Watermark;
		
    
	instance:ownerDrawn(true);
    
end

local init= false;


function Draw(stage, context)

    if stage ~= W then
	return;
	end
	
	if not init then
	init= true; 
	end
	
	local bottom= context:bottom ();
	local top= context:top ();
	local left= context:left ();
	local right =context:right ();

	local Height=((bottom-top)/100)*Size;
	local Width=(((right-left)/(100*7))*Size);
	
    context:createFont (1, "Arial", Width, Height, 0);
	
	

	local Text3="";
    local Text4=""; 	
	
	local Count=0;
	
	 
		  
       
		
		 
        
        if Mode == "Instrument1" then
            Text3 = string.format("%s", source:instrument());
        elseif Mode == "Instrument2" then  
            Text3 = string.format("%s (%s)", source:instrument(), source:barSize());
        end
        
        local date = core.dateToTable(core.now());
        if Format == "DDMMYYYY" then
            Text4 = string.format("%d/%d/%d", date.day, date.month, date.year); 
        elseif Format == "MMDDYYYY" then 
            Text4 = string.format("%d/%d/%d", date.month, date.day, date.year); 
        end
 
	
		
		  
		  
		  if Text4~=""   then
		   Count=Count+1;		
		  width, height = context:measureText (1, Text4, 0); 
          context:drawText (1,  Text4, Color, -1,  iX(context,width,0,1) ,  iY(context,height,Count,0) ,iX(context,width,0,2),iY(context,height,Count,1), 0 );	
		  end
		  
		  
		    if Text3~="" then
		  Count=Count+1;
	 	  width, height = context:measureText (1, Text3, 0); 
          context:drawText (1,  Text3, Color, -1,  iX(context,width,0,1) ,  iY(context,height,Count,0) ,iX(context,width,0,2),iY(context,height,Count,1), 0 );	
		  end
		  
		  		  
		  if Text2~="" and Watermark then
		   Count=Count+1;		
		  width, height = context:measureText (1, Text2, 0); 
          context:drawText (1,  Text2, Color, -1,  iX(context,width,0,1) ,  iY(context,height,Count,0) ,iX(context,width,0,2),iY(context,height,Count,1), 0 );	
		  end
		  
		  
		  
		  if Text1~=""  and Watermark then
		  Count=Count+1;
	 	  width, height = context:measureText (1, Text1, 0); 
          context:drawText (1,  Text1, Color, -1,  iX(context,width,0,1) ,  iY(context,height,Count,0) ,iX(context,width,0,2),iY(context,height,Count,1), 0 );	
		  end
		  
     
    
end


 

function iX(context, width,Shift,x)

	if X== "Left" then
	return  context:left()+ Shift*width +  width*(x-1) ;
	else
	return context:right() - width*Shift -  width*(1-(x-1));
	end
end



function iY(context, height,Index , Line)

	if Y== "Top" then
		return context:top()+Index*height +ShiftY*height + Line *height;
	else
		if Line== 1 then
		return context:bottom()-(Index+1)*height -ShiftY*height + height;
		else
		return context:bottom()-(Index+1)*height -ShiftY*height;
		end
	end
end


function Update(period)   
end

--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+

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
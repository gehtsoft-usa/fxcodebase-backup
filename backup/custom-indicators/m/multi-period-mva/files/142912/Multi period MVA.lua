-- More information about this indicator can be found at:
-- http://fxcodebase.com 

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2021, Gehtsoft USA LLC  | 
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

--+------------------------------------------------------------------------------------------------+
--|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |
--|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C                                 |
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |                                                  |   
--+------------------------------------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Multi period MVA");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Placement");
    indicator.parameters:addInteger("Line", "Line","" , 1, 1 , 5);
	indicator.parameters:addInteger("Shift", "Vertical Shift","" , 1, 0 , 5);
	indicator.parameters:addString("Placement", " Y Placement","" , "Top");
    indicator.parameters:addStringAlternative("Placement", "Top", "Top" , "Top");
    indicator.parameters:addStringAlternative("Placement", "Bottom", "Bottom" , "Bottom"); 
    indicator.parameters:addStringAlternative("Placement", "Left", "Left" , "Left"); 	
    indicator.parameters:addStringAlternative("Placement", "Right", "Right" , "Right"); 
	
	

    indicator.parameters:addGroup("Calculation");
	for i= 1, 10, 1 do
	AddIndicator(i, i*5);
	end
	

 
	
	indicator.parameters:addGroup("Style");
   indicator.parameters:addColor("LabelColor", "Label Color", "", core.COLOR_LABEL ); 
   indicator.parameters:addColor("UpLabelColor", "Up Label Color", "",core.COLOR_UPCANDLE ); 
   indicator.parameters:addColor("DownLabelColor", "Down Label Color", "", core.COLOR_DOWNCANDLE  );    
   indicator.parameters:addColor("NeutralLabelColor", "Neutral Label Color", "", core.rgb (128, 128, 128)  );     
end

function AddIndicator(id, Period)
indicator.parameters:addBoolean("Slot"..id, "Use " .. id.. " Slot", "", true);
indicator.parameters:addString("LabelText"..id, "Indicator Label" .. id.. " Slot", "", "MVA");
indicator.parameters:addInteger("Period"..id, "Indicator Period" , "", Period);
end


-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
local first;
local source = nil;
local Placement;
local font;
local LabelColor;
local UpLabelColor, DownLabelColor,NeutralLabelColor;
local Shift;
local Line;
 
local Number;
local Array={};
local Period={};
local MA={};


local Sign=1;
local Label=2;
local Probability=3;
local Signal=4;
local Cumulative=4;
-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end 
	Placement=instance.parameters.Placement;  
	Line=instance.parameters.Line*3;
	Shift=-instance.parameters.Shift;
    LabelColor=instance.parameters.LabelColor;   
	UpLabelColor=instance.parameters.UpLabelColor;
	DownLabelColor=instance.parameters.DownLabelColor;
	NeutralLabelColor=instance.parameters.NeutralLabelColor;
	
	source = instance.source;
 
	Number=0;
	
    for i = 1, 10, 1 do
		if instance.parameters:getBoolean("Slot" .. i ) then
		Number=Number+1;
		Period[Number]=instance.parameters:getInteger("Period" .. i); 	
		Array[Number]={};		
	    Array[Number][Sign]="\108";
		Array[Number][Label]=instance.parameters:getString("LabelText" .. i); 	
		Array[Number][Probability]=Period[Number];
		Array[Number][Signal]=0;

		end
	end
	
	Array[Number+1]={};	
    Array[Number+1][Sign]="\108";
    

    first=source:first();
	
	for i= 1,Number, 1 do
	MA[i] = core.indicators:create("MVA", source, Period[i]);
	first=math.max(first, MA[i].DATA:first());
	end

 
    instance:ownerDrawn(true);

	
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
 
function Update(period)   

if period < first then
return;
end

local CountOf=0;

    for i= 1,Number, 1 do 
	MA[i]:update(mode);
	if source [period]> MA[i].DATA[period] then
	   Array[i][Signal]=1;
	   CountOf=CountOf+1;
	   elseif source [period]< MA[i].DATA[period] then
	   Array[i][Signal]=-1;
	   CountOf=CountOf-1;
	   else
	   Array[i][Signal]=0;	   
	   end
    end
	
	if CountOf== Number then
	Array[Number+1][Cumulative]=1;
	elseif CountOf== -Number then
	Array[Number+1][Cumulative]=-1;
	else
	Array[Number+1][Cumulative]=0;
	end
  
end
 
 
local X_Shift;
local Y_Shift;
local init=false;
function Draw(stage, context)
 
	  if stage~= 2 then
	  return;
	  end
	X_Shift= (context:right()-context:left())/(#Array+2);
    Y_Shift= (context:bottom()-context:top())/(#Array+2);
     
	if not init then
	       if Placement== "Top" or "Bottom" then
		   context:createFont (1, "Wingdings", X_Shift/5,X_Shift/5, 0);
           context:createFont (2, "Arial",  X_Shift/5, X_Shift/5, 0);
		   context:createFont (3, "Arial",  X_Shift/5,X_Shift/5, 0);
		   else
		   context:createFont (1, "Wingdings", Y_Shift/10,Y_Shift/10, 0);
           context:createFont (2, "Arial",  Y_Shift/10, Y_Shift/10, 0);
		   context:createFont (3, "Arial",  Y_Shift/10,Y_Shift/10, 0);
		   end
		   
            init = true;
    end

local Color;
	

	
    if Placement =="Top" then
	Top(context );
    elseif Placement =="Bottom" then	
	Bottom(context );
    elseif Placement =="Left" then	
    Left(context);	
    elseif Placement =="Right" then	 
	Right(context );	
    end	

end		
 
 

function Top(context) 

	X_Shift= (context:right()-context:left())/(#Array+1);
    Y_Shift= (context:bottom()-context:top())/(#Array*3+2); 

    for i= 1, #Array, 1 do
	
	if  Array[i][Signal] == 1 then
	Color=UpLabelColor;
	elseif  Array[i][Signal] == -1 then
	Color=DownLabelColor;
	else
	Color=NeutralLabelColor;
	end
	
    width, height = context:measureText (1, tostring( Array[i][Sign]), context.CENTER );	
    context:drawText (1, tostring( Array[i][Sign]), Color, -1,   context:left() +  X_Shift*(i)  ,    context:top()+Y_Shift*(Line) -Y_Shift*(2 + Shift)   ,context:left() +  X_Shift*(i+1 ) , context:top()+Y_Shift*(Line ) -Y_Shift*(2 + Shift)+height, context.CENTER );	
		
		if i ~= #Array then
		width, height = context:measureText (2, Array[i][2], 0);
		context:drawText (2,  Array[i][2], LabelColor, -1,   context:left() +  X_Shift*(i  ) ,    context:top()+Y_Shift*(Line+1) -Y_Shift*(2 + Shift)   ,context:left() +  X_Shift*(i+1) , context:top()+Y_Shift*(Line+1) -Y_Shift*(2 + Shift)+height, 0 );	
		
		width, height = context:measureText (3, Array[i][3],  context.CENTER);
		context:drawText (3,  Array[i][3], LabelColor, -1,   context:left() +  X_Shift*(i  ) ,    context:top()+Y_Shift*(Line+2) -Y_Shift*(2 + Shift)    ,context:left() +  X_Shift*(i +1) , context:top()+Y_Shift*(Line+2) -Y_Shift*(2 + Shift)+height,  context.CENTER );	
		end
	end
	
	
 

end



function Bottom(context )
    X_Shift= (context:right()-context:left())/(#Array+1);
    Y_Shift= (context:bottom()-context:top())/(#Array*3+2); 

    for i= 1, #Array, 1 do
	
		
	if  Array[i][Signal] == 1 then
	Color=UpLabelColor;
	elseif  Array[i][Signal] == -1 then
	Color=DownLabelColor;
	else
	Color=NeutralLabelColor;
	end
	
    width, height = context:measureText (1,tostring( Array[i][Sign]), context.CENTER );	
    context:drawText (1, tostring( Array[i][Sign]), Color, -1,   context:left() +  X_Shift*(i  ) ,    context:bottom()-Y_Shift*(Line+3)+ Y_Shift*(2 + Shift)    ,context:left() +  X_Shift*(i+1 ) , context:bottom()-Y_Shift*(Line+3)+ Y_Shift*(2 + Shift) +height, context.CENTER );		
    
			if i ~= #Array then
			 width, height = context:measureText (2, Array[i][2], 0);
			context:drawText (2,  Array[i][2], LabelColor, -1,   context:left() +  X_Shift*(i  ) ,    context:bottom()-Y_Shift*(Line+2)+ Y_Shift*(2 + Shift)     ,context:left() +  X_Shift*(i+1 ) , context:bottom()-Y_Shift*(Line+2)+ Y_Shift*(2 + Shift) +height,0);	
			
			 width, height = context:measureText (3, Array[i][3],  context.CENTER);
			context:drawText (3,  Array[i][3], LabelColor, -1,   context:left() +  X_Shift*(i  ) ,    context:bottom()-Y_Shift*(Line+1)+ Y_Shift*(2 + Shift)    ,context:left() +  X_Shift*(i+1 ) , context:bottom()-Y_Shift*(Line+1 )+ Y_Shift*(2 + Shift) +height,  context.CENTER );	
			end
	end
end


function Left(context ) 
    
    Y_Shift= (context:bottom()-context:top())/(#Array*3+6);
	X_Shift= (context:right()-context:left())/(10);
	
	for i= 1, #Array, 1 do
	
		
	if  Array[i][Signal] == 1 then
	Color=UpLabelColor;
	elseif  Array[i][Signal] == -1 then
	Color=DownLabelColor;
	else
	Color=NeutralLabelColor;
	end
 
	width, height = context:measureText (1, tostring( Array[i][Sign]), context.CENTER );	
     context:drawText (1,  tostring( Array[i][Sign]), Color, -1,   context:left() + X_Shift*(Line-3  ),    context:top()+Y_Shift*(i*3-3)+Y_Shift*(Shift-3)*-1     , context:left() + X_Shift*(Line-2),context:top()+Y_Shift*(i*3-3)+Y_Shift*(Shift-3)*-1 +height, context.CENTER );	
 
				if i ~= #Array then
				width, height = context:measureText (2, Array[i][2],   context.CENTER);
				context:drawText (2,  Array[i][2], LabelColor, -1,   context:left() + X_Shift*(Line-3 ) ,    context:top()+Y_Shift*(i*3-2  ) +Y_Shift*(Shift-3)*-1      , context:left() + X_Shift*(Line-2 ) ,     context:top()+Y_Shift*(i*3-2 ) +Y_Shift*(Shift-3)*-1 +height,   context.CENTER );	
				
				width, height = context:measureText (3, Array[i][3],  context.CENTER);
				context:drawText (3,  Array[i][3], LabelColor, -1,   context:left() + X_Shift*(Line-3 ) ,    context:top()+Y_Shift*(i*3-1 ) +Y_Shift*(Shift-3)*-1      ,context:left() + X_Shift*(Line-2 )  ,    context:top()+Y_Shift*(i*3-1 ) +Y_Shift*(Shift-3)*-1 +height ,  context.CENTER );	
				end
	end
 
end



function Right(context  ) 

    Y_Shift= (context:bottom()-context:top())/(#Array*3+6);
	X_Shift= (context:right()-context:left())/(10);
	
	for i= 1, #Array, 1 do
	
		
	if  Array[i][Signal] == 1 then
	Color=UpLabelColor;
	elseif  Array[i][Signal] == -1 then
	Color=DownLabelColor;
	else
	Color=NeutralLabelColor;
	end
 
	width, height = context:measureText (1, tostring( Array[i][Sign]), context.CENTER );	
     context:drawText (1,  tostring( Array[i][Sign]), Color, -1,   context:right() - X_Shift*(Line-3  ),    context:top()+Y_Shift*(i*3-3)+Y_Shift*(Shift-3)*-1     , context:right() - X_Shift*(Line-2),context:top()+Y_Shift*(i*3-3)+Y_Shift*(Shift-3)*-1 +height, context.CENTER );	
 
				if i ~= #Array then
				width, height = context:measureText (2, Array[i][2],   context.CENTER);
				context:drawText (2,  Array[i][2], LabelColor, -1,   context:right() - X_Shift*(Line-3 ) ,    context:top()+Y_Shift*(i*3-2  ) +Y_Shift*(Shift-3)*-1      , context:right() - X_Shift*(Line-2 ) ,     context:top()+Y_Shift*(i*3-2 ) +Y_Shift*(Shift-3)*-1 +height,   context.CENTER );	
				
				width, height = context:measureText (3, Array[i][3],  context.CENTER);
				context:drawText (3,  Array[i][3], LabelColor, -1,   context:right() - X_Shift*(Line-3 ) ,    context:top()+Y_Shift*(i*3-1 ) +Y_Shift*(Shift-3)*-1      ,context:right() - X_Shift*(Line-2 )  ,    context:top()+Y_Shift*(i*3-1 ) +Y_Shift*(Shift-3)*-1 +height ,  context.CENTER );	
				end
	end
 
end
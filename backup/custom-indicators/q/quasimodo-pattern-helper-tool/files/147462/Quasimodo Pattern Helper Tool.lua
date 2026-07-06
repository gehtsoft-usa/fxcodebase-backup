 -- More information about this indicator can be found at:
 -- https://fxcodebase.com/code/viewtopic.php?f=17&t=72717

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
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
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Quasimodo Pattern Helper Tool");
    indicator:description(" ");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Frame", "Number of fractals)", "Number of fractals", 2, 1,99);	
	
	indicator.parameters:addGroup("Entry Line Style");
 	indicator.parameters:addColor("color_entry", "Line Color", "",core.rgb(0, 0, 255));    
    indicator.parameters:addInteger("width_entry", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style_entry", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style_entry", core.FLAG_LINE_STYLE);	
	
	indicator.parameters:addGroup("Stop Line Style");
	indicator.parameters:addColor("color_stop", "Line Color", "",core.rgb(255, 0, 0));    
    indicator.parameters:addInteger("width_stop", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style_stop", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style_stop", core.FLAG_LINE_STYLE);	
	
	
	
	indicator.parameters:addGroup("Limit Line Style");
	indicator.parameters:addColor("color_limit", "Line Color", "",core.rgb(0, 255, 0));    
    indicator.parameters:addInteger("width_limit", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style_limit", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style_limit", core.FLAG_LINE_STYLE);	
 
	
	indicator.parameters:addGroup("Style");
	 indicator.parameters:addColor("Label", "Label Color", "Color of Label",core.COLOR_LABEL );
     indicator.parameters:addInteger("Size", "Font Size", "Font Size",10);
	  indicator.parameters:addInteger("transparency", "Fill Transparency", "0 - opaque, 100 - transparent", 75, 0, 100);
 
end
 
 

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Size, Label;
local first;
local source = nil;
 
local transparency;
local  Label_Text={"Entry",  "Stop" , "Limit"};

local Level;
function Prepare(nameOnly)
    source = instance.source; 
	Size=  instance.parameters.Size;
    Label=  instance.parameters.Label;	

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	if   (nameOnly) then
        return;
    end
	
	Frame = instance.parameters.Frame;
    source = instance.source;
	first=source:first()+Frame*2;		
 
	
	Direction = instance:addInternalStream(0, 0);
	Fractal = instance:addInternalStream(0, 0);
	Entry = instance:addInternalStream(0, 0);
    Level={};
  
	 
	instance:ownerDrawn(true);
 
	
	
end


 
-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)



    Fractal[period]=0; 
 
 
	period = period-Frame;

 
    
    if (period < first) then
	return;
	end
	 

	    local test=true;
  
		
         for i= 1, Frame, 1 do
		
		     if  source.high[period] < source.high[period+i] or  source.high[period] < source.high[period-i] then
			 test=false;
			 end
			
		 end	
		 
		 if test then
		   Fractal[period]=1; 
		 end

        test=true; 
		
        for i= 1, Frame, 1 do
		
		     if  source.low[period] > source.low[period+i] or source.low[period] > source.low[period-i] then
			 test=false;
			 end
			
		 end	
	   
	      if test then
		  Fractal[period]=-1; 	  
		  end 
		  
		  

		  
    
	
         FindLevels(period);	
end


local init = false;
local Flag=false;
function Draw (stage, context)

    if stage  ~= 2 then
	return;
	end
 
 
	 
  
      context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom());
   
    if not init then
		init =true;
		
		context:createPen (1, context:convertPenStyle ( instance.parameters.style_entry), context:pixelsToPoints ( instance.parameters.width_entry), instance.parameters.color_entry);
		context:createSolidBrush (11, instance.parameters.color_entry);
		context:createPen (3, context:convertPenStyle ( instance.parameters.style_stop), context:pixelsToPoints ( instance.parameters.width_stop), instance.parameters.color_stop);
		context:createSolidBrush (13, instance.parameters.color_stop);
 
		context:createPen (2, context:convertPenStyle ( instance.parameters.style_limit), context:pixelsToPoints ( instance.parameters.width_limit), instance.parameters.color_limit);
		context:createSolidBrush (12, instance.parameters.color_limit);


 	
	
		 context:createFont (10, "Arial", context:pointsToPixels (Size), context:pointsToPixels (Size), 0);
	 
		
		transparency = context:convertTransparency(instance.parameters.transparency); 
	end
 
   

	

	
 
	      X , x, x = context:positionOfBar (source:size()-1);		
	      local y={};
	    
        local first = math.max(source:first(), context:firstBar ());
        local last = math.min (context:lastBar (), source:size()-1);

        Flag=false;

		for i=  last, first, -1 do	

				
				if  Direction[i]==1   or Direction[i]==-1 
				then	
				
				
				 Flag=true; 
				 x1 , x, x = context:positionOfBar (i);	
						  
						  for L=1 , 3,1 do
						  
						  if Level[L]~= nil then
								  itis, y[L]= context:pointOfPrice (Level[L]);
								  
									  
									  
								   
								
								 context:drawLine (i, x, y[L],X, y[L]); 
										 
												 
										Text= Label_Text[L] .. " : " .. string.format("%." .. source:getPrecision() .. "f", Level[L]);
									 
										Width, Height = context:measureText (10, Text, 0);
										
										context:drawText (10, Text, Label, -1, x+100, y[L]-Height,x+100+Width, y[L], 0);
										
										if L==3 then
												if y[2]~=nil and  y[1]~=nil then 
												context:drawRectangle (2, 12, x, y[1], X, y[3], transparency); 
												end
												
												if y[1]~=nil and  y[3]~=nil then 
												context:drawRectangle (3, 13, x, y[1], X,  y[2], transparency); 
												end
										end
								end		
						end
		 
				
				end
			
		if Flag== true then
        break;
        end
		
		end
		
		 
end	

function FindLevels(period)


Level={};
local Count=0;
local ItIs= false;
local FractalDirection={};
local FractalLevel={};
local ThePeriod={};

for i=period, first, -1 do
        Direction[i]=0;
 
		if Fractal[i]== 1 then
		Count=Count+1;
		FractalLevel[Count]=source.high[i];
		FractalDirection[Count]=1; 
        ThePeriod[Count]=i;		
		end
		
		if Fractal[i]== -1 then
		Count=Count+1;	
		FractalLevel[Count]=source.low[i];	
		FractalDirection[Count]=-1;		 
        ThePeriod[Count]=i;			
		end
		
		if Count==100 then
		break;
		end
	 
end


		for i= 0, Count-5, 1 do 

			  if
			  FractalDirection[i+1]==-1 and 
			  FractalDirection[i+2]==1 and 
			  FractalDirection[i+3]==-1 and
			  FractalDirection[i+4]==1 and
			  FractalDirection[i+5]==-1 and
			  
			  FractalLevel[i+1]<FractalLevel[i+2] and
			  FractalLevel[i+1]>FractalLevel[i+3] and
			  FractalLevel[i+1]<FractalLevel[i+4] and
			  FractalLevel[i+1]>FractalLevel[i+5] and
			  
			  FractalLevel[i+2]>FractalLevel[i+3] and
			  FractalLevel[i+2]>FractalLevel[i+4] and
			  FractalLevel[i+2]>FractalLevel[i+5]
			  then
			  Direction[ThePeriod[i+1]]=1; 
			  Level[1]=FractalLevel[i+1];
			  Level[2]=FractalLevel[i+3];	
			  Level[3]=FractalLevel[i+2];	
			  break;
			  end
			  
			  
			 
			  if
			  FractalDirection[i+1]==1 and 
			  FractalDirection[i+2]==-1 and 
			  FractalDirection[i+3]==1 and
			  FractalDirection[i+4]==-1 and
			  FractalDirection[i+5]==1 and
			  
			  FractalLevel[i+1]>FractalLevel[i+2] and
			  FractalLevel[i+1]<FractalLevel[i+3] and
			  FractalLevel[i+1]>FractalLevel[i+4] and
			  FractalLevel[i+1]<FractalLevel[i+5] and
			  
			  FractalLevel[i+2]<FractalLevel[i+3] and
			  FractalLevel[i+2]<FractalLevel[i+4] and
			  FractalLevel[i+2]<FractalLevel[i+5] 	  
			  then
			  
			  Direction[ThePeriod[i+1]]=-1; 
			   Level[1]=FractalLevel[i+1];
			   Level[2]=FractalLevel[i+3];	
			   Level[3]=FractalLevel[i+2];	
			  break;			   
			  end
		 
		 end		  

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
 


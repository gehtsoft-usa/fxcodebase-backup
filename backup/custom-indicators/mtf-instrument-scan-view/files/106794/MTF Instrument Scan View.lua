
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63603

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

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("MTF Instrument Scan View");
    indicator:description("MTF Instrument Scan View");
    indicator:requiredSource(core.Bar);
    indicator:type(core.View); 
	
    indicator.parameters:addGroup("Calculation");	 
    indicator.parameters:addString("Pair", "Pair", "", "EUR/USD");
    indicator.parameters:setFlag("Pair" , core.FLAG_INSTRUMENTS);
  
  
--	indicator.parameters:addInteger("CountX", "Count X", "", 10  );
--	indicator.parameters:addInteger("CountY", "Count Y", "", 10  );
	
	indicator.parameters:addGroup("Style");	 
	indicator.parameters:addColor("Color", "Label Color", "Label Color", core.rgb(0, 0, 0));
	indicator.parameters:addColor("Up", "Up Color", "Up Color", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Color", "Down Color", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral Color", "Neutral Color", core.rgb(128, 128, 128));
	indicator.parameters:addInteger("transparency", "Fill Transparency", "0 - opaque, 100 - transparent", 0, 0, 100);

    indicator.parameters:addDouble("minusY", "Vertical spacing", "", 10 , 0, 50);
	indicator.parameters:addDouble("minusX", "Horizontal spacing", "", 10 , 0, 50);
 
 
	indicator.parameters:addInteger("Size1", "Font Size (As % of Cell)", "", 70 , 0, 100);
	--indicator.parameters:addInteger("Size2", "Circle Size (As % of Cell)", "", 90 , 0, 100);
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local Size1, Size2;
local transparency;  
local  CountX=60
local  CountY=24;  
local Pair;
local Color ;
local minusX, minusY;   
local Height;
local HISTORY_LOADING_ID = 1000; 
local loading;
local Source=nil;

--local xLabel={};
--local yLabel={};

local open;
local Up, Down,Neutral;
local Label={};
local minute;
-- Routine
function Prepare(nameOnly)
   Pair= instance.parameters.Pair;
   Color= instance.parameters.Color; 
   Size1= instance.parameters.Size1; 
  -- Size2= instance.parameters.Size2; 
   Up= instance.parameters.Up;
   Down= instance.parameters.Down;
   Neutral= instance.parameters.Neutral;   
	 
	minusX= (instance.parameters.minusX/100);
	minusY= (instance.parameters.minusY/100);

    local name = profile:id();
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end

    instance:ownerDrawn(true); 
    instance:initView("Dashboard", 0, 1, false, true);
	
   
   local ID=1;
   --Source = core.host:execute("getHistory", HISTORY_LOADING_ID + ID, Pair, "m1", 0, 0, false);
   Source = core.host:execute ("getHistory1", HISTORY_LOADING_ID + ID, Pair, "m1", 24*60, 0, false);
   loading = true;
   
   open = instance:addStream("open", core.Dot, "open", "open", 0, 0, 0);
    open:setVisible(false); 
	
 

end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
 
          if cookie == (HISTORY_LOADING_ID + 1) then
                    loading = false;
					
			
				for i = 0, Source:size() - 1 do
					instance:addViewBar(Source:date(i));
				   
				end
    
 
         end  
 
end



local top, bottom;
local left, right;
local xGap;	 
local yGap;

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode) 
 

end

local init = false; 
function Draw(stage, context)
	if stage ~= 2
    or loading 
	then
        return;
	end
	
 
	

    if not init then   
		transparency = context:convertTransparency(instance.parameters.transparency);                        
        init = true;
    end
		
	    
    
    top, bottom = context:top(), context:bottom();
    left, right = context:left(), context:right(); 
   
   
    xGap=  (right-left)/(CountX+2);	 
    yGap=  (bottom-top)/(CountY+2);
            
  
    
    
    for i= 1, CountY,1 do 	
        for j= 1, CountX,1 do       		
         Calculate (context,i, j); 
        end
    end

end	
 
 

 function Calculate (context,i, j )
   
      
	
	    y1=top +(i)*yGap; 
		
 
		
		x1=left +(j+1)*xGap;
		x2=left +(j )*xGap; 
		
		
		iwidth = ((xGap/2)/100)*Size1 ;
		iheight=  (yGap/100)*Size1; 
	
		context:createFont (7, "Arial",iwidth, iheight , 0);
		 
 
		
	 	if j== 1 then 
		width, height = context:measureText (7,tostring(i), context.CENTER  ); 
		context:drawText (7, tostring(i), Color, -1, x1-xGap, y1 , x1-xGap+width, y1+height, context.CENTER, 0);
		end
		
		
 	  
	    if i== 1 then 
		width, height = context:measureText (7, tostring(j), 0); 
		context:drawText (7,  tostring(j), Color, -1, x1+xGap  , y1-yGap ,x2+xGap ,  y1-yGap+height , context.CENTER   );	 
		end 
   
       
	    local iColor;
	    local Shift;
		local dateTable= core.dateToTable (core.now());
	 
	    if i== 1 then
           if dateTable.min >= j then 
		   iColor, Number=Decode(i,j);
		   else
		   Number=0;
		   end
		else
		iColor, Number=Decode(i,j);
		end
		 
	  
		
		if Number~= 0 then 
		width, height = context:measureText (7, Number, context.CENTER  ); 
		context:drawText (7, Number , Color, iColor, x1, y1 , x1+width, y1+height, context.CENTER, 0);
		 end
 end
 
 
 function Decode(i,j)
 local iColor;
 local table= core.dateToTable (core.now());
 local Last= Source.close:size()-1;
 local Index=  (Last-(table.min)) - ((i-1)*60)  + (j);
 local Number=0;
  
    if Source.close[Index]>  Source.open[Index] then		
	iColor=Up;
	elseif Source.close[Index]<  Source.open[Index] then
	iColor=Down;
	else
	iColor= Neutral ;
	
	end
	
	
	if iColor==Up then
	Number= Count(Index, 1);
	elseif iColor==Down then
	Number= Count(Index, -1);
	else
	Number=1;
	end
	
	return iColor, Number;
end		


function Count(Index, Flag)

iCount=1;
local p;
   for p= (Index-1), Source:first(), -1 do
   
		   if   Flag== 1 then
			 if Source.close[p]>  Source.open[p] then 
			 
			 iCount=iCount+1;
			 else
			 break;
			 end	 
		   elseif  Flag==-1 then
			 if Source.close[p]<  Source.open[p] then 
			 
			 iCount=iCount+1;
			 else
			 break;
			 end	 
		   end
   
   end

   
   return iCount;
end
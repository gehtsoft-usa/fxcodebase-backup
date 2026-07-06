
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62894

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
function Init()
    indicator:name("SweetSpots");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator); 

 
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("NumLinesAboveBelow", "Num of Lines Above/Below","", 100);
	indicator.parameters:addInteger("SweetSpotMainLevels", "SweetSpot MainLevels","", 1000);
	indicator.parameters:addBoolean("ShowSubLevels", "Show SubLevels","", true);
	indicator.parameters:addInteger("sublevels", "sublevels","", 250);
	
	
	indicator.parameters:addColor("ColorMain", "Main Level Color","", core.rgb(0, 0, 0));
    indicator.parameters:addInteger("StyleMain", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("StyleMain", core.FLAG_LINE_STYLE); 
	
    indicator.parameters:addColor("ColorSub", "Sub Level Color","", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("StyleSub", "Line style", "", core.LINE_DOT );
    indicator.parameters:setFlag("StyleSub", core.FLAG_LINE_STYLE); 
 
end

 

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
 
local source = nil;
local NumLinesAboveBelow; 
local SweetSpotMainLevels;
local ShowSubLevels;
local sublevels;
local ssp1=nil;
-- Routine
function Prepare(nameOnly)
    NumLinesAboveBelow= instance.parameters.NumLinesAboveBelow;
	SweetSpotMainLevels= instance.parameters.SweetSpotMainLevels;
	ShowSubLevels= instance.parameters.ShowSubLevels;
	sublevels= instance.parameters.sublevels;
    
    source = instance.source;
	
	 if ShowSubLevels then
      sublevels=sublevels* 2;
    end


    local name = profile:id() .. "(" .. source:name()  ..")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
 
    
    instance:ownerDrawn(true);      
    
	
 end

-- Indicator calculation routine
function Update(period,mode)
 
end

 
	

local init= true;
function Draw(stage, context)
    if stage ~= 2  
	then
        return ;
    end
	
	if init then	
	init=false;
	context:createPen (11, context:convertPenStyle (instance.parameters.StyleMain), 1, instance.parameters.ColorMain);
	context:createPen (12, context:convertPenStyle (instance.parameters.StyleMain), 3, instance.parameters.ColorMain)
	context:createPen (13, context:convertPenStyle (instance.parameters.StyleMain), 5, instance.parameters.ColorMain)
	
	context:createPen (21, context:convertPenStyle (instance.parameters.StyleSub), 1, instance.parameters.ColorSub);
	context:createPen (22, context:convertPenStyle (instance.parameters.StyleSub), 3, instance.parameters.ColorSub)
	context:createPen (23, context:convertPenStyle (instance.parameters.StyleSub), 5, instance.parameters.ColorSub)
	end
	
	if ssp1== nil then	
    ssp1= (source[source:size() - 1]) / source:pipSize();	
    ssp1= ssp1 - ssp1%sublevels;
	end
	
	local ssp;
	local Pen;
    local ds1;
	local Top=context:maxPrice ();
	local Bottom=context:minPrice ();
	
	
	for i= -NumLinesAboveBelow, NumLinesAboveBelow, 1 do
	ssp= ssp1+(i*sublevels); 
	ds1= ssp*source:pipSize();
	
	if ds1 < Top and ds1 > Bottom then
	
	          if (ssp%SweetSpotMainLevels==0) then	 
 
				   if (ssp%(SweetSpotMainLevels*10)==0) then
				   Pen=12;
				   elseif (ssp%(SweetSpotMainLevels*100)==0) then
				   Pen=13;
				   else
				   Pen=11;
				   end
				 
				
			 
			  else 
				 if (ssp%(SweetSpotMainLevels*10)==0) then
				   Pen=22;
				   elseif (ssp%(SweetSpotMainLevels*100)==0) then
				   Pen=23;
				   else
				   Pen=21;
				   end
				  
			  end
			  
			  
			  
			   visible, y1 =context:pointOfPrice ( ds1);
			   context:drawLine (Pen, context:right(), y1, context:left(), y1, 0);
	   end
	   
	end
	
 
 
		
		
	 
		
end



-- Id: 11117

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60294

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+
 
function Init()
    indicator:name("Genesis System Heat Map");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	
	indicator.parameters:addGroup("CCI Calculation"); 
	
	indicator.parameters:addInteger("CCI_Period", "CCI Period", "", 45);
	indicator.parameters:addString("Type", "Signal Type", "", "CCI Trigger Level");
    indicator.parameters:addStringAlternative("Type", "CCI Trigger Level", "", "CCI Trigger Level");
    indicator.parameters:addStringAlternative("Type", "CCI MA", "", "CCI MA");

    indicator.parameters:addInteger("CCI_Trigger_Level",  "CCI Trigger Level", "", 0);
	
	indicator.parameters:addInteger("MA_Period", "MA Period", "Period" , 14);
	
	indicator.parameters:addString("MA_Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("MA_Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("MA_Method", "EMA", "EMA" , "EMA");
   indicator.parameters:addStringAlternative("MA_Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("MA_Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("MA_Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("MA_Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("MA_Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("MA_Method", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addGroup("GannHiLo Calculation");
 
	indicator.parameters:addInteger("Period", "Period", "Period", 10);
   	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addGroup("TVI Calculation"); 
	indicator.parameters:addInteger("r", "First Smoothing", "r", 12);
    indicator.parameters:addInteger("s",  "Second Smoothing", "s", 12);
	
	
	indicator.parameters:addGroup("T3 Calculation"); 
	indicator.parameters:addInteger("a", "Period", "", 8, 1 , 2000);
    indicator.parameters:addDouble("b", "b", "", 0.618);
 
     indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Color", "Label Color","", core.rgb(0, 0, 0));
 

   indicator.parameters:addDouble("VSpace", "Vertical Spacing (%)","",5, 0, 50);
   indicator.parameters:addDouble("HSpace", "Horizontal Spacing (%)","",5, 0, 50);
   indicator.parameters:addDouble("Size", "Font Size (%)","",90, 50, 200);
   
   
end

local source;
local day_offset, week_offset;
 
local Type, CCI_Trigger_Level, MA_Period; 
local VSpace,HSpace;
local Color;
local Size;
 
local Number=4;
local host;
 
local Instrument={};

local Index = {"CCI_HISTOGRAM", "T3_MA_HISTOGRAM", "TVI_HISTOGRAM", "GANNHILO HISTOGRAM"};
local Indicator = {} ;
 


 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
 
    source = instance.source;	
	VSpace=(instance.parameters.VSpace/100);
	HSpace=(instance.parameters.HSpace/100);	
	 
	 host = core.host;
	Size=instance.parameters.Size;
    Color=instance.parameters.Color;
   instance:setLabelColor(Color);
   instance:ownerDrawn(true);
  
   

 	
		
		for i = 1, 4, 1 do 			 
		
		       assert(core.indicators:findIndicator(Index[i]) ~= nil, "Please, download and install " .. Index[i].. " indicator");
		 
        end
		
	CCI_Period= instance.parameters.CCI_Period;
	Type= instance.parameters.Type;
	MA_Period= instance.parameters.MA_Period;
	MA_Method= instance.parameters.MA_Method;
	CCI_Trigger_Level= instance.parameters.CCI_Trigger_Level; 
	Period= instance.parameters.Period;
	Method= instance.parameters.Method;
	r= instance.parameters.r;
	s= instance.parameters.s;
	a= instance.parameters.a;
	b= instance.parameters.b;
	
	 
    assert(core.indicators:findIndicator("CCI_HISTOGRAM") ~= nil, "CCI_HISTOGRAM" .. " indicator must be installed");
    Indicator[1] =   core.indicators:create("CCI_HISTOGRAM", source, CCI_Period,Type, CCI_Trigger_Level, MA_Period,MA_Method,core.rgb(0, 255, 0),core.rgb(255, 0, 0));	
    assert(core.indicators:findIndicator("GANNHILO HISTOGRAM") ~= nil, "GANNHILO HISTOGRAM" .. " indicator must be installed");
	Indicator[2] = core.indicators:create("GANNHILO HISTOGRAM", source.close, Period, Method,core.rgb(0, 255, 0),core.rgb(255, 0, 0));
    assert(core.indicators:findIndicator("TVI_HISTOGRAM") ~= nil, "TVI_HISTOGRAM" .. " indicator must be installed");
	Indicator[3] = core.indicators:create("TVI_HISTOGRAM", source, r,s,core.rgb(0, 255, 0),core.rgb(255, 0, 0));
    assert(core.indicators:findIndicator("T3_MA_HISTOGRAM") ~= nil, "T3_MA_HISTOGRAM" .. " indicator must be installed");
	Indicator[4] = core.indicators:create("T3_MA_HISTOGRAM",source.close, a,b,core.rgb(0, 255, 0),core.rgb(255, 0, 0));
 
	first=math.max(Indicator[1].DATA:first(),Indicator[2].DATA:first(),Indicator[3].DATA:first(),Indicator[4].DATA:first()); 
	
	  
		
end

  

function Update(period, mode)
        
end

local init = false;

function Draw (stage, context)

    if stage  ~= 2 then
	return;
	end
	 
	 
	 
 
	   for i= 1, Number , 1 do
	  Indicator[i]:update(core.UpdateLast );
	  end
	 
 
   
    local style = context.SINGLELINE + context.CENTER + context.VCENTER;
	 
  
   context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom());
   
        if not init then
		     context:createPen (1, context.SOLID, 1, Color)       
			context:createSolidBrush(2, Color); 		  
            init = true;
        end
		 
     
        
        local first = math.max(source:first(), context:firstBar ());
        local last = math.min (context:lastBar (), source:size()-1);
		
    
	    X0, X1, X2 = context:positionOfBar (source:size()-1); 
		 HCellSize =((X2-X1)/100)*HSpace; 
		 VCellSize =((context:bottom() -context:top())/ (Number+1)); 
	
       
			    for i= first, last, 1 do	 
			   x0, x1, x2 = context:positionOfBar (i);
			   
			    for j= 1, Number , 1 do
				   
				  
				  if i~= false then
				    
								
										if Indicator[j].DATA:hasData(i) and Indicator[j].DATA:hasData(i-1) then 
										
												 	     		
																	local iColor= Indicator[j].DATA:colorI(i);
																	if iColor== nil then
																	iColor=Color;		
																	end
																	context:createPen (3, context.SOLID, 1, iColor)       
			                                                        context:createSolidBrush(4, iColor); 
																	C1=3; C2=4;								 
																	  
												 
												     
									   else		
									   C1=1; C2=2;										   
									   end 
									   
						 
				 else
                   
					 C1=1; C2=2;		
										
				end						
				   context:drawRectangle (C1, C2, x1+HCellSize, context:top()+  VCellSize/2+VCellSize * (j-1) +VCellSize* VSpace, x2-HCellSize, context:top()+VCellSize/2 + VCellSize * (j )-VCellSize* VSpace);
				   
				   
					 if i== first then			 	 
					 local width, height; 
					 context:createFont(3, "Arial", ((X2-X1)/100)*Size, (VCellSize/100)*Size, context.NORMAL);
					 Value= tostring( Index[j]);
					 width, height = context:measureText (3,  Value , style)	 
					 context:drawText(3,  Value , Color, -1, X2 +(X2-X1), context:top()+  VCellSize/2+VCellSize * (j-1) +VCellSize* VSpace ,X2+(X2-X1)+width, context:top()+  VCellSize/2 + VCellSize * (j )-VCellSize* VSpace, style);
					 
					 
									

					 end  				 
				 
				 
			 
			 end
			 
	   end
	   
	
end


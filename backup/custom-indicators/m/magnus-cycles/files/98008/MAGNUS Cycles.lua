-- Id: 13364
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61669


--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+



 
 
function Init()
    indicator:name("MAGNUS Cycles");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addInteger("length", "Williams %R Length","", 92);
	indicator.parameters:addInteger("len0", "EMA Length","", 21);
	indicator.parameters:addInteger("len1", "SMA  Length","", 96);
	
	
	indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", -20);
    indicator.parameters:addDouble("oversold","Oversold Level","", -80);
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
	

    indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("L1", "1. Line Color","", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 2, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	indicator.parameters:addColor("L2", "2. Line Color","", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 2, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	indicator.parameters:addColor("L3", "3. Line Color","", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width3", "Line width", "", 2, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
 
   indicator.parameters:addGroup("Background Style"); 
   indicator.parameters:addDouble("HSpace", "Horizontal Spacing (%)","",0, 0, 50); 
   indicator.parameters:addDouble("Transparency", "Transparency","",75, 0, 100); 
   indicator.parameters:addColor("Up", "Up Color","", core.rgb(0, 255, 0));
   indicator.parameters:addColor("Down", "Down Color","", core.rgb(255, 0, 0));
   indicator.parameters:addColor("Neutral", "Neutral Color","", core.rgb(128, 128, 128));
   
   
end 

local HSpace;
local UpUp, UpDown, DownUp,DownDown,Neutral;
local length;
local len0, len1;
local EMA,SMA;
local L1,L2,L3;
local first;
local out1, out2,out3;
local Up, Down, Neutral;
local Transparency;
function Prepare(nameOnly)
 
    Up=instance.parameters.Up;
	Down=instance.parameters.Down;
	Neutral=instance.parameters.Neutral;
    source = instance.source;	
	length=instance.parameters.length;
	len0=instance.parameters.len0;
	len1=instance.parameters.len1; 
	
	first= source:first()+length;
	
	HSpace=(instance.parameters.HSpace/100);
	L1=instance.parameters.L1;
	L2=instance.parameters.L2;
	L3=instance.parameters.L3;
 
   
   
   

    local name = profile:id() .. " " .. source:name()  .. " : " .. source:barSize();
	 instance:name(name );
	 
	if nameOnly then
		return;
	end
	
	out1= instance:addStream("out1", core.Line, "out1", "out1", L1, first); 
    out1:setWidth(instance.parameters.width1);
    out1:setStyle(instance.parameters.style1);
	out1:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    out1:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
	
	SMA = core.indicators:create("MVA", out1, len1);
	EMA = core.indicators:create("EMA", out1, len0);
	
    out2= instance:addStream("out2", core.Line, "out2", "out2", L2, SMA.DATA:first()); 	
	out2:setWidth(instance.parameters.width2);
    out2:setStyle(instance.parameters.style2);
	
    out3= instance:addStream("out3", core.Line, "out3", "out3", L3, EMA.DATA:first()); 	
	out3:setWidth(instance.parameters.width3);
    out3:setStyle(instance.parameters.style3);
	
	out1:setPrecision(math.max(2, instance.source:getPrecision()));
	out2:setPrecision(math.max(2, instance.source:getPrecision()));
	out3:setPrecision(math.max(2, instance.source:getPrecision()));
	
	instance:setLabelColor(L1);
    instance:ownerDrawn(true);
		
end



function Update(period, mode)

    if period < first then
	return;
	end
    lower, upper = mathex.minmax(source, period-length+1, period);
    out1[period] = 100 * (source.close[period] - upper) / (upper - lower);

    SMA:update(mode);
	
	if period >= SMA.DATA:first() then 
	out2[period]= SMA.DATA[period];
	end
	
	
	
	EMA:update(mode);
	if period >= EMA.DATA:first() then 
	out3[period]= EMA.DATA[period];
	end
	
	
end


local init = false;

function Draw (stage, context)

    if stage  ~= 0 then
	return;
	end
	 
    

    local style = context.SINGLELINE + context.CENTER + context.VCENTER;
	 
  
   context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom());
   
        if not init then
		     context:createPen (1, context.SOLID, 1, Up)       
			context:createSolidBrush(2, Up);
			
			 context:createPen (3, context.SOLID, 1, Down)       
			context:createSolidBrush(4, Down);
			
			context:createPen (5, context.SOLID, 1, Neutral)       
			context:createSolidBrush(6, Neutral);
			 
		   Transparency= context:convertTransparency (instance.parameters.Transparency)
            init = true;
        end
     
         
        local First =math.max(first, EMA.DATA:first(), SMA.DATA:first());
        local Last = math.min (context:lastBar (), source:size()-1);
		
    
	    X0, X1, X2 = context:positionOfBar (source:size()-1); 
		 HCellSize =((X2-X1)/100)*HSpace;
		 
	
        local period;
		
			 for period=First,  Last, 1 do	   
			   x0, x1, x2 = context:positionOfBar (period);
			   
			
						
								
									 
										
												 
									         	     if EMA.DATA[period] > SMA.DATA[period] then		 
																 
																C2=2;
																C1=1;
													  elseif EMA.DATA[period] < SMA.DATA[period] then
																C2=4;
																C1=3;
													  else	
                                                      C2=6;
													  C1=5;													  
													  end		 
										 
									   
			          	X1= x1+HCellSize;
                        X2= x2-HCellSize;
						
						if X1> x0 then
						X1= x0; 
						end
						
						if X2< x0 then
						X2= x0; 
						end
						
			           context:drawRectangle (C1, C2, X1, context:top(), X2, context:bottom() , Transparency );
			end					
				 
			 
	
end


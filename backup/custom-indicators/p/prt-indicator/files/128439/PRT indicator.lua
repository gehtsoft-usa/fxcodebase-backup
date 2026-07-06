-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=68886
--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC | 
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

function Init()
    indicator:name("PRT indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period", "Period", "", 0, 0, 2000);
     indicator.parameters:addBoolean("Show", "Show Pivot Lines","", false);
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color1", "1. Monthly Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("color2", "2. Weekly Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("color3", "3. Dayly Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
	
	
	 indicator.parameters:addColor("EliteUp", "Elite Color Up", "", core.rgb(255, 0, 0));
	 indicator.parameters:addColor("EliteDown", "Elite Color Down", "", core.rgb(255, 0, 0));
	 
	indicator.parameters:addColor("PremiumUp", "Premium Color Up", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("PremiumDown", "Premium Color Down", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Neutral", "Neutral Color", "", core.rgb(128, 128, 128));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
local Period; 
local first;
local source = nil;
local Show;
local Monthly, Weekly, Dayly;  
local Signal;
local Source={};
local loading={}
local TF={"M1", "W1", "D1"};
local dayoffset, weekoffset;
local Indicator={};
-- Routine
 function Prepare(nameOnly)   
 
 
    Period = instance.parameters.Period ;
    Show= instance.parameters.Show;
	
	
	local Parameters= Period;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

     dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");
			
    source = instance.source; 
    first=source:first() ;
	
 
   
    local s1, e1, s2, e2;
    s1, e1 = core.getcandle(source:barSize(),0, 0, 0);
	
   
 
	for i= 1, 3, 1 do
	
	s2, e2 = core.getcandle(TF[i], 0, 0, 0);
    assert ((e1 - s1) <= (e2 - s2), "The chosen time frame must be equal to or bigger than the chart time frame!");
	
--	Source[i]= core.host:execute("getSyncHistory", source:instrument(), TF[i], source:isBid(), math.min(300,Period+1), 100+(i-1), 200+(i-1));
	--loading[i]=true;
    
	end
	
	if Show then
	Monthly = instance:addStream("Monthly" , core.Line, " Monthly"," Monthly",instance.parameters.color1, first );
	Monthly:setWidth(instance.parameters.width);
    Monthly:setStyle(instance.parameters.style);
    Monthly:setPrecision(math.max(2, source:getPrecision()));
	
	
	Weekly = instance:addStream("Weekly" , core.Line, " Weekly"," Weekly",instance.parameters.color2, first );
	Weekly:setWidth(instance.parameters.width);
    Weekly:setStyle(instance.parameters.style);
    Weekly:setPrecision(math.max(2, source:getPrecision()));
	
	
	Dayly = instance:addStream("Dayly" , core.Line, " Dayly"," Dayly",instance.parameters.color3, first );
	Dayly:setWidth(instance.parameters.width);
    Dayly:setStyle(instance.parameters.style);
    Dayly:setPrecision(math.max(2, source:getPrecision()));
	
	
	else
	Monthly = instance:addInternalStream(0, 0);
	Weekly = instance:addInternalStream(0, 0);
	Dayly = instance:addInternalStream(0, 0);
	end
	
	
	instance:setLabelColor(instance.parameters.EliteUp);
   instance:ownerDrawn(true);
	
	Signal = instance:addInternalStream(0, 0);
	
	
	Indicator[1]= core.indicators:create("PIVOT", source, TF[1],  "Pivot" , "HIST"  );
	Indicator[2]= core.indicators:create("PIVOT", source, TF[2],  "Pivot" , "HIST"  );
	Indicator[3]= core.indicators:create("PIVOT", source, TF[3],  "Pivot" , "HIST"  );
end

-- Indicator calculation routine
function Update(period, mode)

 
	if period < source:first() 
	then
	return;
	end 
	
	Indicator[1]:update(mode);
	Indicator[2]:update(mode);
	Indicator[3]:update(mode);
	
 
	 
     Monthly[period ]= Indicator[1].DATA[period];
	 Weekly[period ]=Indicator[2].DATA[period];
	 Dayly[period ]= Indicator[3].DATA[period];
	 
 
	 
	 Signal[period]=0;
	 
	 
	 if source.close[period]>Monthly[period ] and source.close[period]>Weekly[period ] and source.close[period]>Dayly[period ] then 
	 Signal[period]=1;
	 elseif source.close[period]<Monthly[period ] and source.close[period]<Weekly[period ] and source.close[period]<Dayly[period ] then 
	  Signal[period]=-1;
     end
	 
	 if source.close[period]>Monthly[period ] and source.close[period]<Weekly[period ] and source.close[period]<Dayly[period ] then 
	 Signal[period]=2;
	 elseif source.close[period]<Monthly[period ] and source.close[period]>Weekly[period ] and source.close[period]>Dayly[period ] then 
	  Signal[period]=-2;
     end
				  
end
 

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
 
	instance:updateFrom(0);
 
	
	  return core.ASYNC_REDRAW ;
end


local init = false;

function Draw (stage, context)

    if stage  ~= 0 then
	return;
	end
	 
    

    local style = context.SINGLELINE + context.CENTER + context.VCENTER;
	 
  
   context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom());
   
        if not init then
		     context:createPen (1, context.SOLID, 1, instance.parameters.PremiumUp)       
			context:createSolidBrush(2, instance.parameters.PremiumUp);
			
			
			context:createPen (3, context.SOLID, 1, instance.parameters.PremiumDown)       
			context:createSolidBrush(4, instance.parameters.PremiumDown);
			
			context:createPen (11, context.SOLID, 1, instance.parameters.EliteUp)       
			context:createSolidBrush(12, instance.parameters.EliteUp);
			
			
			context:createPen (13, context.SOLID, 1, instance.parameters.EliteDown)       
			context:createSolidBrush(14, instance.parameters.EliteDown);
			 
			
			 context:createPen (5, context.SOLID, 1, instance.parameters.Neutral)       
			context:createSolidBrush(6, instance.parameters.Neutral); 
            init = true;
        end
     
        
        local first = math.max(source:first(), context:firstBar ());
        local last = math.min (context:lastBar (), source:size()-1);
		
    
	 --   X0, X1, X2 = context:positionOfBar (source:size()-1); 
 
		 
	
        local period;
		
			 for period= first, last, 1 do	   
			   x0, x1, x2 = context:positionOfBar (period);
			   
			            
													 
									   if  Signal[period]== 1  then	
									    C1=1; C2=2;	
									   elseif  Signal[period]== -1  then	
									    C1=3; C2=4;		
										
										elseif  Signal[period]== 2  then	
									    C1=11; C2=12;	
									   elseif  Signal[period]== -2  then	
									    C1=13; C2=14;	
                                       	 									   
									   else		
									   C1=5; C2=6;										   
									   end 
									   
			          	X1= x1;
                        X2= x2;
						
						 
						
			           context:drawRectangle (C1, C2, X1, context:top(), X2, context:bottom()  );
			end					
				 
				
	
end


 
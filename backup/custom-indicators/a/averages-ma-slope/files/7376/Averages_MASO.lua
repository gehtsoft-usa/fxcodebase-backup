-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3145

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
    indicator:name("Averages_MASO");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	
	indicator.parameters:addGroup("First MA Slope Parameters ");
	
    indicator.parameters:addString("First_Method", "Method", "", "MVA");
    indicator.parameters:addStringAlternative("First_Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("First_Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("First_Method", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("First_Method", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("First_Method", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("First_Method", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("First_Method", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("First_Method", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("First_Method", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("First_Method", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("First_Method", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("First_Method", "T3", "", "T3");
    indicator.parameters:addStringAlternative("First_Method", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("First_Method", "Median", "", "Median");
    indicator.parameters:addStringAlternative("First_Method", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("First_Method", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("First_Method", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("First_Method", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("First_Method", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("First_Method", "JSmooth", "", "JSmooth");
 
    indicator.parameters:addInteger("First_Period", "Period", "", 20);    
    indicator.parameters:addDouble("First_Slope", "Slope", "pip/minute", 0.01);
    indicator.parameters:addInteger("First_Bars", "Bars", "", 1);
	
	
	
	indicator.parameters:addGroup("Second MA Slope Parameters ");
	
	indicator.parameters:addString("Second_Method", "Method", "", "MVA");
    indicator.parameters:addStringAlternative("Second_Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Second_Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Second_Method", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Second_Method", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Second_Method", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Second_Method", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Second_Method", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Second_Method", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Second_Method", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Second_Method", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Second_Method", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Second_Method", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Second_Method", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Second_Method", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Second_Method", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Second_Method", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Second_Method", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Second_Method", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Second_Method", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Second_Method", "JSmooth", "", "JSmooth");
 
    indicator.parameters:addInteger("Second_Period", "Period", "", 50);    
    indicator.parameters:addDouble("Second_Slope", "Slope", "pip/minute", 0.01);
    indicator.parameters:addInteger("Second_Bars", "Bars", "", 1);
	

    indicator.parameters:addGroup("Style");
	 indicator.parameters:addColor("Up_color", "Color of Up", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Down_color", "Color of Down", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("Contradictory_color", "Color of Contradictory", "", core.rgb(255, 128, 0));
	indicator.parameters:addColor("Flat_color", "Color of Flat", "", core.rgb(128, 128, 128));
   indicator.parameters:addDouble("HSpace", "Horizontal Spacing (%)","",5, 0, 50); 
   
   
end 

local HSpace;

local First_Period,First_Method,First_Slope,First_Bars, Second_Period,Second_Method,Second_Slope,Second_Bars;

local first;
local source = nil;

-- Streams block
local OUT = nil;
local indicator1;
local indicator2;

 function Prepare(nameOnly)  
 
    source = instance.source;	
	HSpace=(instance.parameters.HSpace/100);
	
  
    First_Period = instance.parameters.First_Period;
    First_Method = instance.parameters.First_Method;
    First_Slope = instance.parameters.First_Slope;
    First_Bars = instance.parameters.First_Bars;
	
	Second_Period = instance.parameters.Second_Period;
    Second_Method = instance.parameters.Second_Method;
    Second_Slope = instance.parameters.Second_Slope;
    Second_Bars = instance.parameters.Second_Bars;
	
	
	Up_color= instance.parameters.Up_color;
	Down_color= instance.parameters.Down_color;
	Contradictory_color= instance.parameters.Contradictory_color;
	Flat_color= instance.parameters.Flat_color;
	
	  local name = profile:id() .. "(" .. source:name() .. ", " .. First_Period .. ", "..First_Method.. ", "..First_Slope.. ", "..First_Bars.. ", ".. Second_Period ..", ".. Second_Method .. ", "..  Second_Slope..", " .. Second_Bars.. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end

	
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES indicator");	
  
   
   instance:setLabelColor(Flat_color);
   instance:ownerDrawn(true);
   

 
	
	indicator1=core.indicators:create("AVERAGES", source, First_Method, First_Period, false);
	indicator2=core.indicators:create("AVERAGES", source, Second_Method, Second_Period, false);
	
	first = source:first() + math.max(Second_Bars, First_Bars, indicator1.DATA:first() , indicator2.DATA:first());
	
    OUT  = instance:addInternalStream(0, 0);
	
		
end



function Update(period, mode)

     indicator1:update(mode);
	 indicator2:update(mode);
					   
	OUT[period] = 100;	
	
	if period < first  or not  source:hasData(period) then
	return;
	end
	
	
	
					   indicator1:update(mode);
					   indicator2:update(mode);
					   
					 
					   
					   if not indicator1.DATA:hasData(period) or not indicator2.DATA:hasData(period) or  not indicator1.DATA:hasData(period-First_Bars) or not indicator2.DATA:hasData(period-Second_Bars) then
						OUT[period] = 100;	
					   return;
					   end
					   
					 
					   
					   
								 local d,t,d1,t1;
								 d,t=source:date(period);
								 d1,t1=source:date(period-1);
								 local TimeSize=(d-d1)*1440;
					   
					   
					   
						
					local S1=(indicator1.DATA[period]-indicator1.DATA[period-First_Bars])/(source:pipSize()*TimeSize);					
					local S2=(indicator2.DATA[period]-indicator2.DATA[period-Second_Bars])/(source:pipSize()*TimeSize);	
					
					
					
					if S1 == nil or S2== nil  or    First_Slope== nil   or  Second_Slope == nil  then
					OUT[period] = 100;		
					return;
					end							 
							   
					   
								 if S1>First_Slope  and S2>Second_Slope then
								 OUT[period] = 1;	
								 elseif S1<-First_Slope  and S2<-Second_Slope then
								 OUT[period] = -1;	
								 else
								 OUT[period] = 0;	
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
		     context:createPen (1, context.SOLID, 1, Up_color)       
			context:createSolidBrush(2, Up_color);
			
			 context:createPen (3, context.SOLID, 1, Down_color)       
			context:createSolidBrush(4, Down_color);
			
			context:createPen (5, context.SOLID, 1, Contradictory_color)       
			context:createSolidBrush(6, Contradictory_color);
			

			
			context:createPen (9, context.SOLID, 1, Flat_color)       
			context:createSolidBrush(10, Flat_color);
			 
		  
            init = true;
        end
     
        
        local first = math.max(source:first(), context:firstBar ());
        local last = math.min (context:lastBar (), source:size()-1);
		
    
	    X0, X1, X2 = context:positionOfBar (source:size()-1); 
		 HCellSize =((X2-X1)/100)*HSpace;
		 
	
        local period;
		
			 for period= first, last, 1 do	   
			   x0, x1, x2 = context:positionOfBar (period);
			   
			
						
								
										 
										
												 
									         	     if OUT[period] ==1  then		 
														 
																C2=2;
																C1=1;
															 
													 
														elseif OUT[period] ==-1  then		 
																C2=4;
																C1=3;
														elseif OUT[period] ==0  then		 
																C2=6;
																C1=5;		 
														 else
					   
																 C1=9; C2=10;		
																					
														end		 
															
													 
												     
									 
									   
			          	X1= x1+HCellSize;
                        X2= x2-HCellSize;
						
						if X1> x0 then
						X1= x0; 
						end
						
						if X2< x0 then
						X2= x0; 
						end
						
			           context:drawRectangle (C1, C2, X1, context:top(), X2, context:bottom()  );
			end					
				 
				
	
end


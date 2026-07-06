-- More information about this indicator can be found at:
-- http://fxcodebase.com

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
    indicator:name("ElderImpulseBar With Pivot Filter Oscillator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	
	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("EMA", "EMA periods for study", "", 13, 1, 100);
    indicator.parameters:addInteger("MACDF", "MACD periods fast", "", 12, 1, 100);
    indicator.parameters:addInteger("MACDS", "MACD periods slow", "", 26, 1, 100);
    indicator.parameters:addString("app_price", "app_price", "", "close");
    indicator.parameters:addStringAlternative("app_price", "close", "", "close");
    indicator.parameters:addStringAlternative("app_price", "open", "", "open");
    indicator.parameters:addStringAlternative("app_price", "high", "", "high");
    indicator.parameters:addStringAlternative("app_price", "low", "", "low");
    indicator.parameters:addStringAlternative("app_price", "median", "", "median");
    indicator.parameters:addStringAlternative("app_price", "typical", "", "typical");
    indicator.parameters:addStringAlternative("app_price", "weighted", "", "weighted");
	
	
	indicator.parameters:addGroup("Pivot Calculation");	
	indicator.parameters:addBoolean("Filter", "Use Pivot Filter", "Use Pivot Filter", true);
	indicator.parameters:addString("TF","Time Frame", "", "D1");
    indicator.parameters:setFlag("TF", core.FLAG_BARPERIODS);

    indicator.parameters:addString("CalcMode", "Calculation Mode", "", "Pivot");
    indicator.parameters:addStringAlternative("CalcMode", "Pivot", "", "Pivot");
    indicator.parameters:addStringAlternative("CalcMode", "Camarilla", "", "Camarilla");
    indicator.parameters:addStringAlternative("CalcMode", "Woodie", "", "Woodie");
    indicator.parameters:addStringAlternative("CalcMode", "Fibonacci", "", "Fibonacci");
    indicator.parameters:addStringAlternative("CalcMode", "Floor", "", "Floor");
    indicator.parameters:addStringAlternative("CalcMode", "FibonacciR", "", "FibonacciR")

	

    indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("UpUp", "Up in Up Trend Color","", core.rgb(0, 255, 0));
	indicator.parameters:addColor("UpDown", "Down in Up Trend Color","", core.rgb(0, 200, 0));
	indicator.parameters:addColor("DownUp", "Up in Down Trend Color","", core.rgb(200, 0, 0));
	indicator.parameters:addColor("DownDown", "Down in Down Trend Color","", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral Color","", core.rgb(0, 0, 0));
 
   indicator.parameters:addDouble("HSpace", "Horizontal Spacing (%)","",5, 0, 50); 
   
   
end 

local HSpace;
local UpUp, UpDown, DownUp,DownDown,Neutral;
local Indicator;

local Pivot, TF, CalcMode;
local source = nil;
local EMA;
local MACDF;
local MACDS;
local app_price;
local EIS;
local Signal;

function Prepare(nameOnly)
 
    source = instance.source;	
	HSpace=(instance.parameters.HSpace/100);	
	
	EMA=instance.parameters.EMA;
    MACDF=instance.parameters.MACDF;
    MACDS=instance.parameters.MACDS;
	Filter=instance.parameters.Filter;
    app_price=instance.parameters.app_price; 
   
    Pivot=instance.parameters.Pivot;
    TF=instance.parameters.TF
    CalcMode=instance.parameters.CalcMode;
	
    local name = profile:id() .. " " .. source:name()  .. " : " .. source:barSize();
	instance:name(name);
    if (nameOnly) then
        return;
    end
	 assert(core.indicators:findIndicator("ELDER_IMPULSE_SYSTEM") ~= nil, "Please, download and install ELDER_IMPULSE_SYSTEM.LUA indicator");
   
    EIS = core.indicators:create("ELDER_IMPULSE_SYSTEM", source[app_price], EMA, MACDF, MACDS);
    Pivot= core.indicators:create("PIVOT", source, TF, CalcMode, "HIST");	
	
    first = math.max( EIS.UP:first(), EIS.DN:first(),EIS.NE:first(), Pivot.DATA:first()) +1;	
	
   UpUp=instance.parameters.UpUp;
   UpDown=instance.parameters.UpDown;
   
   DownUp=instance.parameters.DownUp;
   DownDown=instance.parameters.DownDown;
   
   Neutral=instance.parameters.Neutral;
   
   instance:setLabelColor(Neutral);
   instance:ownerDrawn(true);
   
   
   Signal = instance:addInternalStream(0, 0);
   
end



function Update(period, mode)

   EIS:update(mode);
   Pivot:update(mode);
   
   if (period<first) then
   Signal[period]=0;
   return;
   end
   
   
    if EIS.UP[period]~= nil and EIS.UP[period]==100 
	and (source.close[period] > Pivot.DATA[period] or not Filter)
	then
    Signal[period]=1;
    elseif   EIS.DN[period]~= nil and EIS.DN[period]==100
	and (source.close[period] < Pivot.DATA[period] or not Filter)
	then
    Signal[period]=-1;
    elseif   EIS.NE[period]~= nil and EIS.NE[period]==100 then
	Signal[period]=0;
	else
	Signal[period]=0;
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
		     context:createPen (1, context.SOLID, 1, UpUp)       
			context:createSolidBrush(2, UpUp);
			
			 context:createPen (3, context.SOLID, 1, UpDown)       
			context:createSolidBrush(4, UpDown);
			
			context:createPen (5, context.SOLID, 1, DownUp)       
			context:createSolidBrush(6, DownUp);
			
			 context:createPen (7, context.SOLID, 1, DownDown)       
			context:createSolidBrush(8, DownDown);
			
			context:createPen (9, context.SOLID, 1, Neutral)       
			context:createSolidBrush(10, Neutral);
			 
		  
            init = true;
        end
     
        
        local first = math.max(source:first(), context:firstBar ());
        local last = math.min (context:lastBar (), source:size()-1);
		
    
	    X0, X1, X2 = context:positionOfBar (source:size()-1); 
		 HCellSize =((X2-X1)/100)*HSpace;
		 
	
        local period;
		
			 for period= first, last, 1 do	   
			   x0, x1, x2 = context:positionOfBar (period);
			   
			
						
								
										if Signal:hasData(period) then 
										
												 
									         	     if Signal[period]==1 then		 
																if source.close[period] >  source.open[period-1] then	
																C2=2;
																C1=1;
																else
																C2=4;
																C1=3;
																end		
													 
														elseif  Signal[period]==-1 then	
																if source.close[period] >  source.open[period-1] then	
																C2=6;
																C1=5;
																else
																C2=8;
																C1=7;
																end		
														 else
					   
																 C1=9; C2=10;		
																					
														 end		 
															
													 
												     
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


-- Id: 1124
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1638

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Bar Template");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Up", "1. Color","", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "2. Color","", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "3. Color","", core.rgb(128, 128, 128));
 
   indicator.parameters:addDouble("HSpace", "Horizontal Spacing (%)","",5, 0, 50); 
   
   
end 

local HSpace;
local Up, Down, Neutral;

local first;
local source = nil;
local MA;
local buff4;
local buff5;
local buff6;
local buff1={};
local buff2={};
local buff3={};
local var1;


function Prepare(nameOnly)
 
    source = instance.source;	
	HSpace=(instance.parameters.HSpace/100);
	
   Up=instance.parameters.Up;
   Down=instance.parameters.Down;
   
   Neutral=instance.parameters.Neutral;
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name); 
    if nameOnly then
        return;
    end
   
   instance:setLabelColor(Neutral);
   instance:ownerDrawn(true); 
    var1 = instance:addInternalStream(0, 0);
    buff4 = instance:addInternalStream(0, 0);
    buff5 = instance:addInternalStream(0, 0);
    buff6 = instance:addInternalStream(0, 0);
    MA = core.indicators:create("EMA", source.close, 34);
    first = MA.DATA:first()+2;
		
end



function Update(period, mode)

     MA:update(mode);
	 
     if (period<first) then
	 return;
	 end
     local var3=0;
     local var2;
     for i=1,25,1 do
      var2=26-i;
      var3=var3+(var2-8)*source.close[period-i+1];
     end
     buff6[period]=6.*var3/650.;
     buff4[period]=MA.DATA[period];
     buff5[period]=buff6[period];
     local var4=(source.close[period-1]+source.high[period-1]+source.low[period-1])/3.;
     local var5=25./(core.max(source.high,core.rangeTo(period,30))-core.min(source.low,core.rangeTo(period,30)))*core.min(source.low,core.rangeTo(period,30));
     local var6=(buff4[period-1]-buff4[period])/var4*var5;
     local var7=math.sqrt(1.+var6*var6);
     local var8=math.ceil(180.*math.acos(1./var7)/math.pi);
     if var6>0. then
      var8=-1.*var8;
     end
     local var9=(buff5[period-1]-buff5[period])/var4*var5;
     local var10=math.sqrt(1.+var9*var9);
     local var11=math.ceil(180.*math.acos(1./var10)/math.pi);
     if var9>0. then
      var11=-1.*var11;
     end
      var1[period]=0;
     if (var8<10. and var8>=0. and var11+var8>=10.) or (var11<10. and var11>=0. and var11+var8>=10.) then
      var1[period]=1;
     elseif (var8>-10. and var8<=0. and var11+var8<=-10.) or (var11>-10. and var11<=0. and var11+var8<=-10.) then
      var1[period]=1;
     elseif var8<=-10. and var11<=-10. then
      var1[period]=2;
     elseif var8>=10. and var11>=10. then
      var1[period]=2;
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
		 
			 
		  
            init = true;
        end
     
        
        local first = math.max(source:first(), context:firstBar ());
        local last = math.min (context:lastBar (), source:size()-1);
		
    
	    X0, X1, X2 = context:positionOfBar (source:size()-1); 
		 HCellSize =((X2-X1)/100)*HSpace;
		 
	
        local period;
		
			 for period= first, last, 1 do	   
			   x0, x1, x2 = context:positionOfBar (period);
			   
			
						
								
									 
										
												 
									         	     if var1[period]== 2 then		 
															 
																C2=2;
																C1=1;
																 
													 
														elseif  var1[period] == 1  then	
																 
																C2=6;
																C1=5;
																 
														 else
					   
																 C1=3; C2=4;		
																					
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


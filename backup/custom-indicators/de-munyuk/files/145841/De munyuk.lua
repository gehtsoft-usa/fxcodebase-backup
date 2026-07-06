-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72131

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
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

--Your donations will allow the service to continue onward.
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
 
function Init()
    indicator:name("De munyuk");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
    indicator.parameters:addGroup("Calculation");
	indicator.parameters:addInteger("G_period_104", "1. Period","", 13);	
	indicator.parameters:addInteger("G_period_108", "2. Period","", 34);	
	indicator.parameters:addInteger("G_period_112", "3. Period","", 8);	
		
    indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Up", "Up Trend Color","", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Trend Color","", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral Color","", core.rgb(128, 128, 128)); 
    indicator.parameters:addDouble("HSpace", "Horizontal Spacing (%)","",5, 0, 49); 
 
end 

local HSpace;
local Up, Down,Neutral;
local G_period_104, G_period_108,G_period_112;
local Indicator;
local first;
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

 
    source = instance.source;	
	HSpace=(instance.parameters.HSpace );
	
   Up=instance.parameters.Up;
   Down=instance.parameters.Down;      
   Neutral=instance.parameters.Neutral;
   
   G_period_104=instance.parameters.G_period_104;
   G_period_108=instance.parameters.G_period_108;
   G_period_112=instance.parameters.G_period_112;
   
   instance:setLabelColor(Neutral);
   instance:ownerDrawn(true);

	
	Indicator1 = core.indicators:create("EMA", source.close ,  G_period_104);
	Indicator2 = core.indicators:create("EMA", source.close ,  G_period_108);

	first=math.max(Indicator1.DATA:first(),Indicator2.DATA:first());	
	
	
	G_ibuf_116 = instance:addInternalStream(0, 0);
	Signal = instance:addInternalStream(0, 0);
	
	Indicator3 = core.indicators:create("MVA", G_ibuf_116 ,  G_period_112);	 
end



function Update(period, mode)

    Indicator1:update(mode);
    Indicator2:update(mode);

	
	Signal[period]=0;
	
	if period <= first then
	return;
	end
	
	G_ibuf_116[period]= Indicator1.DATA[period]-Indicator2.DATA[period];
	
	
    Indicator3:update(mode);		
	
	if period <= Indicator3.DATA:first() then
	return;
	end	
	
	if  Indicator3.DATA[period] > G_ibuf_116[period] then
	Signal[period]=1;
	else
	Signal[period]=-1;	
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

			
			context:createPen (9, context.SOLID, 1, Neutral)       
			context:createSolidBrush(10, Neutral);
			 
		  
            init = true;
        end
     
        
        local first = math.max(source:first(), context:firstBar ());
        local last = math.min (context:lastBar (), source:size()-1);
		
        -- Will be used to place a label to the last candle of the chart.
	    X0, X1, X2 = context:positionOfBar (source:size()-1); 
		 HCellSize =((X2-X1)/100)*HSpace;
		 
	
        local period;
		
			 for period= first, last, 1 do	   
			   x0, x1, x2 = context:positionOfBar (period); 
												 
									         	    if Signal[period] == -1 then		 
													 		 
																C2=2;
																C1=1;
															 
													 
													elseif Signal[period] == 1 then		  
																C2=4;
																C1=3; 
												     
													else		
													            C1=9; 
																C2=10;										   
													end 
									   
			          	X1= x1+HCellSize;
                        X2= x2-HCellSize; 
						
			           context:drawRectangle (C1, C2, X1, context:top(), X2, context:bottom()  );
			end					
				 
				
	
end


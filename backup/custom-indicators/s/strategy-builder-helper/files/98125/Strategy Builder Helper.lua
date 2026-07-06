
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61711

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


function Init()
    indicator:name("Strategy Builder Helper");
    indicator:description("");
	indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    
	indicator.parameters:addGroup(" Strategy Builder Parametars");
	indicator.parameters:addInteger("LEVEL",  "Strategy Builder Threshold", "", 1,0, 24);	
    local i;	
    for   i= 1, 3 , 1 do	
	
local SUPPORTED = 	 {"TSI", "RSI", "EMA" , "MVA", "KAMA", "PPMA", "TMA", "ADX", "DMI", "AROON",
                  "ARSI", "HA", "ICH", "MD", "SAR", "CCI", "MACD", "RLW", "SFK", "ROC", "SSD",
				  "STOCHASTIC", "KRI", "TMACD", "ZZZCOMPOSITE", "PERCENTAGE PRICE FOLLOWER", "FIBOAVERAGES", "RB_CLEAR", "ITREND", "AC", "AO", "PIVOT","STOCHRSI",
				  "HASM", "DSS", "SMMA", "REGRESSION", "TRENDSTOP","SUPERTREND", "HMA", "QQE", "LRS","LAGUERRE_RSI","LAGUERRE_FILTER"
				  };
				  
	
	indicator.parameters:addGroup(i .. " Indicator Parametars");
		if i == 1 then 
		indicator.parameters:addBoolean("ON"..i,  "Indicator", "", true);	
		else
		indicator.parameters:addBoolean("ON"..i,  "Indicator", "", false);	
		end
	indicator.parameters:addString("IN"..i, "Indicator", "", "");
    indicator.parameters:setFlag("IN"..i,core.FLAG_INDICATOR);
	indicator.parameters:addBoolean("Inverse"..i,  "Inverse Indicator", "", false);	
	end
	
   
   indicator.parameters:addGroup(" Style Parameters");
   indicator.parameters:addInteger("Size",  "Label Size", "", 10);	
   indicator.parameters:addColor("Up", "Color Up", "Color Up", core.rgb(0, 255, 0));
   indicator.parameters:addColor("Down", "Color Down", "Color v", core.rgb(255, 0, 0));
end


local LEVEL;
local ON={};
local TEST;
local Flag;
local Inverse={};
local source = nil;
local indicator = {};
local STREAMS={};
local source;
local Size;
local Up,Down;
local SUPPORTED = {"TSI", "RSI", "EMA" , "MVA", "KAMA", "PPMA", "TMA", "ADX", "DMI", "AROON",
                  "ARSI", "HA", "ICH", "MD", "SAR", "CCI", "MACD", "RLW", "SFK", "ROC", "SSD",
				  "STOCHASTIC", "KRI", "TMACD", "ZZZCOMPOSITE", "PERCENTAGE PRICE FOLLOWER", "FIBOAVERAGES", "RB_CLEAR", "ITREND", "AC", "AO", "PIVOT","STOCHRSI",
				  "HASM", "DSS", "SMMA", "REGRESSION", "TRENDSTOP","SUPERTREND", "HMA", "QQE", "LRS","LAGUERRE_RSI","LAGUERRE_FILTER"
				  };


function Prepare(nameOnly)

    Up=  instance.parameters.Up;
	Down=  instance.parameters.Down;
    source = instance.source;
	
	
	local name;
    name = profile:id() .. "(" .. source:name()  .. ")";
    instance:name(name);

	if   (nameOnly) then
        return;
    end
	
	
	
    LEVEL=  instance.parameters.LEVEL;
	Size=  instance.parameters.Size;
	font = core.host:execute("createFont", "Wingdings", Size, false, false);
    Flag=  instance:addInternalStream(0, 0);
    local i;	
	for i=1,3 ,1 do
	ON[i]=  instance.parameters:getBoolean ("ON"..i); 
	Inverse[i]=  instance.parameters:getBoolean ("Inverse"..i);
			if ON[i] then
			
		           	local j;

                    for j = 1, #SUPPORTED, 1 do
						if instance.parameters:getString("IN"..i) == SUPPORTED[j] then
						break;
						elseif j== #SUPPORTED then
						assert(false,  instance.parameters:getString("IN"..i) .. " Indicator Is not supported, Contact Apprentice on FxCodeBase.com");		
						end       					
                    end					 
					
					if  instance.parameters:getString("IN"..i) == "FIBOAVERAGES"
					then
				    assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download  AVERAGES Indicator");
                    end				   
			
			assert(core.indicators:findIndicator(instance.parameters:getString("IN"..i)) ~= nil, "Please, download Indicator");			
			end
	end  
   
	 
   
	
	
	local  iprofile = {};
        local iparams =  {};		
		
		for i = 1, 3, 1 do
		    if ON[i] then
			
			   iprofile[i] = core.indicators:findIndicator(instance.parameters:getString("IN"..i));
			   iparams[i] = instance.parameters:getCustomParameters("IN"..i);
			   if  iprofile[i]:requiredSource() == core.Tick then
			   indicator[i] = iprofile[i]:createInstance(source.close, iparams[i]);
			   else
			   indicator[i] = iprofile[i]:createInstance(source, iparams[i]);
			   end
			   
			   
            end		
        end
	
	 
	
end

 function ReleaseInstance()
       core.host:execute("deleteFont", font);
end


function Update(period, mode)


     if period < 1 then    
		return;				
     end  
	   
	    RESET();
	   
	   

	   
	   for i =1,3 , 1 do
			   if ON[i] then
			   indicator[i]:update(mode);
			   end
			   
			   
			   	if ON[i] then		     
					
				     if instance.parameters:getString("IN"..i) ~= "SAR"
					 and instance.parameters:getString("IN"..i) ~= "RB_CLEAR" 
					 and instance.parameters:getString("IN"..i) ~= "SUPERTREND"
					 then
						if not indicator[i].DATA:hasData(period) then
						return;
						end
					end	
						 
						 
					    EVALUATION(i,period);	
						
						
		        end
       end
			
				if TEST  >= LEVEL and Flag[period-1]~=1 then
				Flag[period]=1;				
				core.host:execute("drawLabel1", source:serial(period), source:date(period),core.CR_CHART, source.low[period], core.CR_CHART, core.H_Center, core.V_Bottom,  font, Up, "\221");	
				elseif TEST  <=  (0-LEVEL)  and Flag[period-1]~=-1  then
                Flag[period]=-1;	      
				core.host:execute("drawLabel1", source:serial(period), source:date(period),core.CR_CHART, source.high[period], core.CR_CHART, core.H_Center, core.V_Top,  font, Down, "\222");	
				else
				Flag[period]=Flag[period-1];	
				end
		
				
  
    
end


function EVALUATION(i,p)      
	     
	   
		if instance.parameters:getString("IN"..i) == "TSI" then
		
				if indicator[i].DATA[p] > 0  then
				PLUS(i);
				elseif indicator[i].DATA[p] < 0 then  
				MINUS(i);
				end
				
       elseif instance.parameters:getString("IN"..i) == "RSI" then
		
				if indicator[i].DATA[p] > 50  then
				PLUS(i);
				elseif indicator[i].DATA[p] < 50 then  
				MINUS(i);
				end
		elseif instance.parameters:getString("IN"..i) == "EMA" then
		
				if  source.close[p] > indicator[i].DATA[p]   then
				PLUS(i);
				elseif  source.close[p] < indicator[i].DATA[p]  then  
				MINUS(i);
				end
		elseif instance.parameters:getString("IN"..i) == "MVA" then
		
				if  source.close[p] > indicator[i].DATA[p]   then
				PLUS(i);
				elseif  source.close[p] < indicator[i].DATA[p]  then  
				MINUS(i);
				end		
		elseif instance.parameters:getString("IN"..i) == "KAMA" then
		
				if  source.close[p] > indicator[i].DATA[p]   then
				PLUS(i);
				elseif  source.close[p] < indicator[i].DATA[p]  then  
				MINUS(i);
				end				
		 elseif instance.parameters:getString("IN"..i) == "MVA" then
		
				if  source.close[p] > indicator[i].DATA[p]   then
				PLUS(i);
				elseif  source.close[p] < indicator[i].DATA[p]  then  
				MINUS(i);
				end			    
		elseif instance.parameters:getString("IN"..i) == "PPMA" then
		
				if  source.close[p] > indicator[i].DATA[p]   then
				PLUS(i);
				elseif  source.close[p] < indicator[i].DATA[p]  then  
				MINUS(i);
				end		
		elseif instance.parameters:getString("IN"..i) == "TMA" then
		
				if  source.close[p] > indicator[i].DATA[p]   then
				PLUS(i);
				elseif  source.close[p] < indicator[i].DATA[p]  then  
				MINUS(i);
				end			

        elseif instance.parameters:getString("IN"..i) == "ADX" then
		
				if   indicator[i].DATA[p] > 25  then
				PLUS(i);
				else 
				MINUS(i);
				end	
        elseif instance.parameters:getString("IN"..i) == "DMI" then
		
		        STREAMS[0]=indicator[i]:getStream(0);
				STREAMS[1]=indicator[i]:getStream(1);
		
				if  STREAMS[0][p] > STREAMS[1][p]   then
				PLUS(i);
				elseif  STREAMS[0][p] < STREAMS[1][p]   then  
				MINUS(i);
				end	
		 elseif instance.parameters:getString("IN"..i) == "AROON" then
		
		        STREAMS[0]=indicator[i]:getStream(0);
				STREAMS[1]=indicator[i]:getStream(1);
		
				if  STREAMS[0][p] > STREAMS[1][p]   then
				PLUS(i);
				elseif  STREAMS[0][p] < STREAMS[1][p]   then  
				MINUS(i);
				end		
				
		 elseif instance.parameters:getString("IN"..i) == "ARSI" then
		
		         STREAMS[0]=nil;				
		        STREAMS[0]=indicator[i]:getStream(0);
				
		
				if source.close[p] > STREAMS[0][p]    then
				PLUS(i);
				elseif  source.close[p]  < STREAMS[0][p]    then  
				MINUS(i);
				end	
		elseif instance.parameters:getString("IN"..i) == "HA" then
		
		         
		        STREAMS[0]=indicator[i]:getStream(0);
				STREAMS[3]=indicator[i]:getStream(3);
				
				if  STREAMS[0][p] < STREAMS[3][p]   then
				PLUS(i);
				elseif  STREAMS[0][p] > STREAMS[3][p]   then  
				MINUS(i);
				end		
		elseif instance.parameters:getString("IN"..i) == "ICH" then
		
		        STREAMS[0]=indicator[i]:getStream(0);
				STREAMS[1]=indicator[i]:getStream(1);
		
				if  STREAMS[0][p] > STREAMS[1][p]   then
				PLUS(i);
				elseif  STREAMS[0][p] < STREAMS[1][p]   then  
				MINUS(i);
				end		
		 elseif instance.parameters:getString("IN"..i) == "MD" then
		
		         STREAMS[0]=nil;				
		        STREAMS[0]=indicator[i]:getStream(0);
				
		
				if source.close[p] > STREAMS[0][p]    then
				PLUS(i);
				elseif  source.close[p]  < STREAMS[0][p]    then  
				MINUS(i);
				end	
		elseif instance.parameters:getString("IN"..i) == "SAR" then
		
		        STREAMS[0]=indicator[i]:getStream(0);
				STREAMS[1]=indicator[i]:getStream(1);
										
										
				
						if   STREAMS[0]:hasData(p)    then  
				        MINUS(i);
				        elseif STREAMS[1]:hasData(p)    then  
						PLUS(i);
						end
        	
		
		elseif instance.parameters:getString("IN"..i) == "CCI" then
		
		        STREAMS[0]=indicator[i]:getStream(0);
						
						 if STREAMS[0][p] > 0 then
						 PLUS(i);
						 elseif STREAMS[0][p]  < 0 then
						 MINUS(i);
						 end
		elseif instance.parameters:getString("IN"..i) == "MACD" then
		
		        STREAMS[0]=indicator[i]:getStream(0);
				 STREAMS[1]=indicator[i]:getStream(1);
						
						 if STREAMS[0][p] > STREAMS[1][p] then
						 PLUS(i);
						 elseif STREAMS[0][p] < STREAMS[1][p] then
						 MINUS(i);
						 end				 
		elseif instance.parameters:getString("IN"..i) == "RLW" then
		
		        STREAMS[0]=indicator[i]:getStream(0);
				
						
						 if STREAMS[0][p] > 50 then
						 PLUS(i);
						 elseif STREAMS[0][p] < 50 then
						 MINUS(i);
						 end
		elseif instance.parameters:getString("IN"..i) == "ROC" then
		
		        STREAMS[0]=indicator[i]:getStream(0);
				
						
						 if STREAMS[0][p] > 0 then
						 PLUS(i);
						 elseif STREAMS[0][p] < 0 then
						 MINUS(i);
						 end	
		elseif instance.parameters:getString("IN"..i) == "SFK" then
		
		        STREAMS[0]=indicator[i]:getStream(0);
				STREAMS[1]=indicator[i]:getStream(1);
						
						 if STREAMS[0][p] > STREAMS[1][p] then
						 PLUS(i);
						 elseif STREAMS[0][p] < STREAMS[1][p] then
						 MINUS(i);
						 end
		elseif instance.parameters:getString("IN"..i) == "SSD" then
		
		        STREAMS[0]=indicator[i]:getStream(0);
				STREAMS[1]=indicator[i]:getStream(1);
						
						 if STREAMS[0][p] > STREAMS[1][p] then
						 PLUS(i);
						 elseif STREAMS[0][p] < STREAMS[1][p] then
						 MINUS(i);
						 end
        elseif instance.parameters:getString("IN"..i) == "STOCHASTIC" then
		
		        STREAMS[0]=indicator[i]:getStream(0);
				STREAMS[1]=indicator[i]:getStream(1);
						
						 if STREAMS[0][p] > STREAMS[1][p] then
						 PLUS(i);
						 elseif STREAMS[0][p] < STREAMS[1][p] then
						 MINUS(i);
						 end
		elseif instance.parameters:getString("IN"..i) == "KRI" then
		
		        STREAMS[0]=indicator[i]:getStream(0);				
						
						 if STREAMS[0][p] > 0 then
						 PLUS(i);
						 elseif STREAMS[0][p] < 0 then
						 MINUS(i);
						 end	
		elseif instance.parameters:getString("IN"..i) == "TMACD" then
		
		        STREAMS[0]=indicator[i]:getStream(0);				
						
						 if STREAMS[0][p] > 0 then
						 PLUS(i);
						 elseif STREAMS[0][p] < 0 then
						 MINUS(i);
						 end
	    elseif instance.parameters:getString("IN"..i) == "ZZZCOMPOSITE" then
		
		        STREAMS[0]=indicator[i]:getStream(0);				
						
						 if STREAMS[0][p] > 0 then
						 PLUS(i);
						 elseif STREAMS[0][p] < 0 then
						 MINUS(i);
						 end		
         elseif instance.parameters:getString("IN"..i) == "PERCENTAGE PRICE FOLLOWER" then
		
		        STREAMS[0]=indicator[i]:getStream(0);				
						
						 if source.close[p] > STREAMS[0][p]  then
						 PLUS(i);
						 elseif source.close[p] < STREAMS[0][p]then
						 MINUS(i);
						 end     	
          elseif instance.parameters:getString("IN"..i) == "FIBOAVERAGES" then
		
		        STREAMS[0]=indicator[i]:getStream(0);				
						
						 if source.close[p] > STREAMS[0][p]  then
						 PLUS(i);
						 elseif source.close[p] < STREAMS[0][p]then
						 MINUS(i);
						 end     	 
         elseif instance.parameters:getString("IN"..i) == "RB_CLEAR" then
		
		        STREAMS[0]=indicator[i]:getStream(0);	
                STREAMS[1]=indicator[i]:getStream(1);					

						 if STREAMS[0]:hasData(p) then
                            PLUS(i);
						 elseif  STREAMS[1]:hasData(p) then
                            MINUS(i);
						 end   
         elseif instance.parameters:getString("IN"..i) == "ITREND" then
		
		        STREAMS[0]=indicator[i]:getStream(0);				
				STREAMS[1]=indicator[i]:getStream(1);		
						 if  STREAMS[0][p] > STREAMS[1][p] then
						 PLUS(i);
						 elseif  STREAMS[0][p] < STREAMS[1][p] then
						 MINUS(i);
						 end 
						 
 		elseif instance.parameters:getString("IN"..i) == "AC" then
		
		        STREAMS[0]=indicator[i]:getStream(0);				
					
						 if  STREAMS[0][p] > 0 then
						 PLUS(i);
						 elseif  STREAMS[0][p] < 0 then
						 MINUS(i);
						 end   
        elseif instance.parameters:getString("IN"..i) == "AO" then
		
		        STREAMS[0]=indicator[i]:getStream(0);				
						
						 if  STREAMS[0][p] > 0 then
						 PLUS(i);
						 elseif  STREAMS[0][p] < 0 then
						 MINUS(i);
						 end   
         elseif instance.parameters:getString("IN"..i) == "SUPERTREND" then
		
		        STREAMS[0]=indicator[i]:getStream(0);
                STREAMS[1]=indicator[i]:getStream(0);					
						
						 if  STREAMS[0]:hasData(p)  then
						 PLUS(i);
						 elseif  STREAMS[1]:hasData(p)  then
						 MINUS(i);
						 end   		 				
          elseif instance.parameters:getString("IN"..i) == "PIVOT" then
		
		        STREAMS[0]=indicator[i]:getStream(0);
              			
						
						 if   source.close[p] >  STREAMS[0][p]    then
						 PLUS(i);
						 elseif   source.close[p] <  STREAMS[0][p]   then
						 MINUS(i);
						 end   		 	
          elseif instance.parameters:getString("IN"..i) == "STOCHRSI" then
		
		        STREAMS[0]=indicator[i]:getStream(0);
                STREAMS[1]=indicator[i]:getStream(1);	
              			
						
						 if   STREAMS[0][p]  >  STREAMS[1][p]  then
						 PLUS(i);
						 elseif  STREAMS[0][p]  <  STREAMS[1][p]  then
						 MINUS(i);
						 end 
          elseif instance.parameters:getString("IN"..i) == "HASM" then
		
		        STREAMS[0]=indicator[i]:getStream(0);
                STREAMS[1]=indicator[i]:getStream(3);	
              			
						
						 if   STREAMS[0][p]  <  STREAMS[1][p]  then
						 PLUS(i);
						 elseif  STREAMS[0][p]  >  STREAMS[1][p]  then
						 MINUS(i);
						 end   		
        elseif instance.parameters:getString("IN"..i) == "DSS" then
		
		        STREAMS[0]=indicator[i]:getStream(0);
                STREAMS[1]=indicator[i]:getStream(1);	
              			
						
						 if   STREAMS[0][p]  >  STREAMS[1][p]  then
						 PLUS(i);
						 elseif  STREAMS[0][p]  <  STREAMS[1][p]  then
						 MINUS(i);
						 end   		
         elseif instance.parameters:getString("IN"..i) == "SMMA" then
		
		        STREAMS[0]=indicator[i]:getStream(0);
              
              			
						
						 if     source.close[p] >  STREAMS[0][p]  then
						 PLUS(i);
						 elseif  source.close[p] <  STREAMS[0][p]  then
						 MINUS(i);
						 end   		
        elseif instance.parameters:getString("IN"..i) == "REGRESSION" then
		
		        STREAMS[0]=indicator[i]:getStream(0);
               
						
						 if   source.close[p] >  STREAMS[0][p]  then
						 PLUS(i);
						 elseif  source.close[p] <  STREAMS[0][p]  then
						 MINUS(i);
						 end   	
         elseif instance.parameters:getString("IN"..i) == "TRENDSTOP" then
		
		        STREAMS[0]=indicator[i]:getStream(0);
               
						
						 if   source.close[p] >  STREAMS[0][p]  then
						 PLUS(i);
						 elseif  source.close[p] <  STREAMS[0][p]  then
						 MINUS(i);
						 end   								 
       	
         elseif instance.parameters:getString("IN"..i) == "HMA" then
		
		        STREAMS[0]=indicator[i]:getStream(0);
               
						
						 if   source.close[p] >  STREAMS[0][p]  then
						 PLUS(i);
						 elseif  source.close[p] <  STREAMS[0][p]  then
						 MINUS(i);
						 end   	
        elseif instance.parameters:getString("IN"..i) == "QQE" then
		
		         STREAMS[0]=indicator[i]:getStream(0);
                STREAMS[1]=indicator[i]:getStream(1);	
              			
						
						 if   STREAMS[0][p]  >  STREAMS[1][p]  then
						 PLUS(i);
						 elseif  STREAMS[0][p]  <  STREAMS[1][p]  then
						 MINUS(i);
						 end   		
         elseif instance.parameters:getString("IN"..i) == "LRS" then
		
		         STREAMS[0]=indicator[i]:getStream(0);
               
              			
						
						 if   STREAMS[0][p]  > 0  then
						 PLUS(i);
						 elseif  STREAMS[0][p]  <  0  then
						 MINUS(i);
						 end   		
         elseif instance.parameters:getString("IN"..i) == "LAGUERRE_RSI" then
		
		         STREAMS[0]=indicator[i]:getStream(0);
               
              			
						
						 if   STREAMS[0][p]  > 0.5  then
						 PLUS(i);
						 elseif  STREAMS[0][p]  <  0.5  then
						 MINUS(i);
						 end   								 
		elseif instance.parameters:getString("IN"..i) == "LAGUERRE_FILTER" then
		
		         STREAMS[0]=indicator[i]:getStream(0);
               
              			
						
						 if     source.close[p] >  STREAMS[0][p]  then
						 PLUS(i);
						 elseif  source.close[p] <  STREAMS[0][p]  then
						 MINUS(i);
						 end   			 
				
        else	
		
            assert(false,  instance.parameters:getString("IN"..i) .. " Indicator Is not supported, Contact Apprentice on FxCodeBase.com");		
        end   		
		
end

function PLUS (j)
	if Inverse[j] then
	TEST=TEST-1;
	else
	TEST=TEST+1;
	end
end

function MINUS (j)
    if Inverse[j] then
	TEST=TEST+1;
	else
    TEST=TEST-1; 
    end
end
function RESET (j)
TEST=0;
end

		
		
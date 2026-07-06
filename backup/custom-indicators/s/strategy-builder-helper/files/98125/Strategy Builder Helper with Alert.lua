
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
	
	
	indicator.parameters:addGroup("Mode");  
	indicator.parameters:addString("Live", "End of Turn / Live", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
	indicator.parameters:addStringAlternative("Live", "Live", "", "Live");   
    
	indicator.parameters:addGroup(" Strategy Builder Parametars");
	indicator.parameters:addInteger("LEVEL",  "Strategy Builder Threshold", "", 1,0, 24);	
    local i;	
    for   i= 1, 3 , 1 do	
	indicator.parameters:addGroup(i .. " Indicator Parametars");
		if i == 1 then 
		indicator.parameters:addBoolean("iON"..i,  "Indicator", "", true);	
		else
		indicator.parameters:addBoolean("iON"..i,  "Indicator", "", false);	
		end
	indicator.parameters:addString("IN"..i, "Indicator", "", "");
    indicator.parameters:setFlag("IN"..i,core.FLAG_INDICATOR);
	indicator.parameters:addBoolean("Inverse"..i,  "Inverse Indicator", "", false);	
	end
	

   
   	indicator.parameters:addGroup("Alert Style");
    indicator.parameters:addColor("UpTrendColor", "Up Trend Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addColor("DownTrendColor", "Down Trend Color", "", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("Size",  "Label Size", "", 10);	
	
	indicator.parameters:addGroup("Alerts Sound");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", true);	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);
	indicator.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
	
	indicator.parameters:addGroup("Alerts Email");   
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", true);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);
	indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true);
	 indicator.parameters:addBoolean("OnlyOnce", "Alert Once", "Subsequent Alert will be ignored.", false);	
	
	
	Parameters (1, "Trend")
end

function Parameters ( id, Label )
  
  
   indicator.parameters:addGroup(Label .. " Alert");
  
    indicator.parameters:addBoolean("ON"..id , "Show " .. Label .." Alert" , "", true);
   

    indicator.parameters:addFile("Up"..id, Label .. " Cross Over Sound", "", "");
    indicator.parameters:setFlag("Up"..id, core.FLAG_SOUND);
	
	indicator.parameters:addFile("Down"..id, Label .. " Cross Under Sound", "", "");
    indicator.parameters:setFlag("Down"..id, core.FLAG_SOUND);
	
	 indicator.parameters:addString("Label"..id, "Label", "", Label);

end 

local 	Number = 1;


local LEVEL;
local iON={};
local TEST;
local Flag;
local Inverse={};
local source = nil;
local indicator = {};
local STREAMS={};
local source;
local Size;
local UpColor,DownColor;


local Up={};
local Down={};
local Label={};
local ON={}; 
local Email;
local SendEmail;
local  RecurrentSound ,SoundFile  ;
local Show;
local Alert;
local PlaySound;
local Live;
local FIRST=true;
local OnlyOnce;
local U={};
local D={};
local UpTrendColor, DownTrendColor;
local OnlyOnceFlag;
local font;
local ShowAlert;

local SUPPORTED = {"TSI", "RSI", "EMA" , "MVA", "KAMA", "PPMA", "TMA", "ADX", "DMI", "AROON",
                  "ARSI", "HA", "ICH", "MD", "SAR", "CCI", "MACD", "RLW", "SFK", "ROC", "SSD",
				  "STOCHASTIC", "KRI", "TMACD", "ZZZCOMPOSITE", "PERCENTAGE PRICE FOLLOWER", "FIBOAVERAGES", "RB_CLEAR", "ITREND", "AC", "AO", "PIVOT","STOCHRSI",
				  "HASM", "DSS", "SMMA", "REGRESSION", "TRENDSTOP","SUPERTREND", "HMA", "QQE", "LRS","LAGUERRE_RSI","LAGUERRE_FILTER"
				  };


function Prepare(nameOnly)

    OnlyOnceFlag=true;
	FIRST=true;
	OnlyOnce = instance.parameters.OnlyOnce;
	ShowAlert = instance.parameters.ShowAlert;
	Show = instance.parameters.Show;
	Live = instance.parameters.Live;
	UpTrendColor = instance.parameters.UpTrendColor;
	DownTrendColor = instance.parameters.DownTrendColor;
	Size=instance.parameters.Size;
 
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
	iON[i]=  instance.parameters:getBoolean ("iON"..i); --ON
	Inverse[i]=  instance.parameters:getBoolean ("Inverse"..i);
			if iON[i] then
			
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
		    if iON[i] then
			
			   iprofile[i] = core.indicators:findIndicator(instance.parameters:getString("IN"..i));
			   iparams[i] = instance.parameters:getCustomParameters("IN"..i);
			   if  iprofile[i]:requiredSource() == core.Tick then
			   indicator[i] = iprofile[i]:createInstance(source.close, iparams[i]);
			   else
			   indicator[i] = iprofile[i]:createInstance(source, iparams[i]);
			   end
			   
			   
            end		
        end
	
	
	
	if nameOnly then
        return ;
    end
	
	 Initialization ()
end


function  Initialization ()
    
	 SendEmail = instance.parameters.SendEmail;
	 
	 local i;
	 for i = 1, Number , 1 do 
	  Label[i]=instance.parameters:getString("Label" .. i);
	  ON[i]=instance.parameters:getBoolean("ON" .. i);
	 end
	 
	 
	 

    if SendEmail then
        Email = instance.parameters.Email;
    else
        Email = nil;
    end
    assert(not(SendEmail) or (SendEmail and Email ~= ""), "E-mail address must be specified");
	
	
	 PlaySound = instance.parameters.PlaySound;
    if PlaySound then
    
	  for i = 1, Number , 1 do 
	  Up[i]=instance.parameters:getString("Up" .. i);
	  Down[i]=instance.parameters:getString("Down" .. i);
	  end
	
    else 
	
	  for i = 1, Number , 1 do 
       Up[i]=nil;
	  Down[i]=nil;
	  end
		
    end
    
        for i = 1, Number , 1 do 
	  assert(not(PlaySound) or (PlaySound and Up[i] ~= "") or (PlaySound and Up[i] ~= ""), "Sound file must be chosen"); 
	 assert(not(PlaySound) or (PlaySound and Down[i] ~= "") or (PlaySound and Down[i] ~= ""), "Sound file must be chosen");
	end
	 
    RecurrentSound = instance.parameters.RecurrentSound;
	
	for i = 1, Number , 1 do 
	U[i] = nil;
	D[i] = nil;	 
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
			   if iON[i] then
			   indicator[i]:update(mode);
			   end
			   
			   --ON
			   	if iON[i] then		     
					
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
				--core.host:execute("drawLabel1", source:serial(period), source:date(period),core.CR_CHART, source.low[period], core.CR_CHART, core.H_Center, core.V_Bottom,  font, UpColor, "\221");	
				elseif TEST  <=  (0-LEVEL)  and Flag[period-1]~=-1  then
                Flag[period]=-1;	      
				--core.host:execute("drawLabel1", source:serial(period), source:date(period),core.CR_CHART, source.high[period], core.CR_CHART, core.H_Center, core.V_Top,  font, DownColor, "\222");	
				else
				Flag[period]=Flag[period-1];	
				end
		
				
                 Activate (1, period);
    
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


function Activate (id, period)

   local Shift=0;
   

   if Live~= "Live" then
	period=period-1;
	Shift=1;
	end
 
	  if id == 1  and ON[id]  then
	  
	       
			if  Flag[period]==1
			and   Flag[period-1]~=1
			then
			           
						    
             core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, source.low[period], core.CR_CHART, core.H_Center, core.V_Bottom, font, UpTrendColor, "\225");

 						 
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  then
							  OnlyOnceFlag=false;
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Cross Over", period);
							  SendAlert("Crossed over");  
							        
									Pop(Label[id], " Cross Over " );  	
								    
								 
							  end
			elseif  Flag[period]==-1
			and   Flag[period-1]~=-1
            then			
			
			            			 
			               core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, source.high[period], core.CR_CHART, core.H_Center, core.V_Top, font, DownTrendColor, "\226");						   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 then
							 OnlyOnceFlag=false;
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " Cross Under", period);	
								 
									Pop(Label[id], " Cross Under " );  	
								    SendAlert("Crossed under");
							 
			                  end			   
	         end
			
	  
	 
	  end
	  
		   
        if FIRST then
        FIRST=false;      
        end		

end


function AsyncOperationFinished (cookie, success, message)
end


function Pop(label , note)
  
   if not Show then
   return;
   end
    
   core.host:execute ("prompt", 1, label ,   " ( " .. source:instrument() .. " : " .. source:barSize() .. " ) "  ..   label .. " : " .. note );
  
end


function SendAlert(message)
    if not ShowAlert then
        return;
    end
 
   
   terminal:alertMessage(source:instrument(), source[NOW], message, source:date(NOW));
end

function SoundAlert(Sound)
 if not PlaySound then
 return;
 end

  if OnlyOnce and OnlyOnceFlag== false then
 return;
 end

 
   terminal:alertSound(Sound, RecurrentSound);
end

 


function EmailAlert( label , Subject, period)

if not SendEmail then
return
end

 if OnlyOnce and OnlyOnceFlag== false then
 return;
 end

 
    local date = source:date(period);
	local DATA = core.dateToTable (date);
	
    
   local delim = "\013\010";  
   local Note=  profile:id().. delim.. " Label : " ..label  .. delim .. " Alert : " .. Subject ;   
   local Symbol= "Instrument : " .. source:instrument() ;
   local Time =  " Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec;  
   
    
    local TF= "Time Frame : " .. source:barSize();       
    local text = Note  .. delim ..  Symbol .. delim .. TF  .. delim .. Time;
	 
	
 
   terminal:alertEmail(Email, profile:id(), text);
end
	 

		
		
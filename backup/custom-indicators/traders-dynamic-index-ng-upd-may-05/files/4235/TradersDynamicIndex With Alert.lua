-- Id: 12431
-- Available @ http://fxcodebase.com/code/viewtopic.php?f=17&t=2069


--+------------------------------------------------------------------+
--|                               Copyright � 2018, Gehtsoft USA LLC | 
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
 

-- original indicator:
-- Traders Dynamic Index.mq4
-- Copyright � 2006, Dean Malone
-- www.compassfx.com


function Init()
    indicator:name("Traders Dynamic Index Indicator");
    indicator:description("This hybrid indicator is developed to assist traders in their ability to decipher and monitor market conditions related to trend direction, market strength, and market volatility.");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	
	indicator.parameters:addGroup("Mode");  
	indicator.parameters:addString("Live", "End of Turn / Live", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
	indicator.parameters:addStringAlternative("Live", "Live", "", "Live");
	
	
    indicator.parameters:addGroup("Calculation");

    indicator.parameters:addInteger("RSI_N", "RSI Periods", "Recommended values are in 8-25 range", 13, 2, 1000);
    indicator.parameters:addInteger("VB_N", "Volatility Band", "Number of periods to find volatility band. Recommended value is 20-40", 34, 2, 1000);
    indicator.parameters:addDouble("VB_W", "Volatility Band Width", "", 1.6185, 0, 100);

    indicator.parameters:addInteger("RSI_P_N", "RSI Price Line Periods", "", 2, 1, 1000);
    indicator.parameters:addString("RSI_P_M", "RSI Price Line Smoothing Method", "", "MVA");
    indicator.parameters:addStringAlternative("RSI_P_M", "MVA(SMA)", "", "MVA");
    indicator.parameters:addStringAlternative("RSI_P_M", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("RSI_P_M", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("RSI_P_M", "LSMA(Regression)", "", "REGRESSION");
    indicator.parameters:addStringAlternative("RSI_P_M", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("RSI_P_M", "WMA(Wilders)", "", "WMA");
    indicator.parameters:addStringAlternative("RSI_P_M", "KAMA(Kaufman)", "", "KAMA");
	indicator.parameters:addStringAlternative("RSI_P_M", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("RSI_P_M", "VIDYA", "VIDYA" , "VIDYA");

    indicator.parameters:addInteger("TS_N", "Trade Signal Line Periods", "", 7, 1, 1000);
    indicator.parameters:addString("TS_M", "Trade Signal Line Smoothing Method", "", "MVA");
    indicator.parameters:addStringAlternative("TS_M", "MVA(SMA)", "", "MVA");
    indicator.parameters:addStringAlternative("TS_M", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("TS_M", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("TS_M", "LSMA(Regression)", "", "REGRESSION");
    indicator.parameters:addStringAlternative("TS_M", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("TS_M", "WMA(Wilders)", "", "WMA");
    indicator.parameters:addStringAlternative("TS_M", "KAMA(Kaufman)", "", "KAMA");
	indicator.parameters:addStringAlternative("TS_M", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("TS_M", "VIDYA", "VIDYA" , "VIDYA");

    local colors = core.colors();

    indicator.parameters:addGroup("Line Style");
    indicator.parameters:addColor("RSI_P_C", "RSI Price Line Color", "", colors.Green);
    indicator.parameters:addInteger("RSI_P_W", "RSI Price Line Width", "", 2, 1, 5);
    indicator.parameters:addInteger("RSI_P_S", "RSI Price Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("RSI_P_S", core.FLAG_LEVEL_STYLE);

    indicator.parameters:addColor("TS_C", "Trade Signal Line Color", "", colors.Red);
    indicator.parameters:addInteger("TS_W", "Trade Signal Line Width", "", 2, 1, 5);
    indicator.parameters:addInteger("TS_S", "Trade Signal Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("TS_S", core.FLAG_LEVEL_STYLE);

    indicator.parameters:addColor("VB_C", "Volatility Band Line Color", "", colors.Blue);
    indicator.parameters:addInteger("VB_Wi", "Volatility Band Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("VB_S", "Volatility Band Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("VB_S", core.FLAG_LEVEL_STYLE);

    indicator.parameters:addColor("MB_C", "Market Base Line Color", "", colors.SandyBrown);
    indicator.parameters:addInteger("MB_W", "Market Base Line Width", "", 2, 1, 5);
    indicator.parameters:addInteger("MB_S", "Market Base Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("MB_S", core.FLAG_LEVEL_STYLE);

    indicator.parameters:addGroup("Levels");
    indicator.parameters:addInteger("L1", "Low Level", "", 32, 0, 100);
    indicator.parameters:addInteger("L2", "Middle Level", "", 50, 0, 100);
    indicator.parameters:addInteger("L3", "High Level", "", 68, 0, 100);
	
 
	
    indicator.parameters:addColor("L_C", "Level Line Color", "", core.COLOR_CUSTOMLEVEL);
    indicator.parameters:addInteger("L_W", "Market Base Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("L_S", "Market Base Line Style", "", core.LINE_DOT);
    indicator.parameters:setFlag("L_S", core.FLAG_LEVEL_STYLE);
	
	
	indicator.parameters:addGroup("Alert Style");
    indicator.parameters:addColor("Up", "Up Trend Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addColor("Down", "Down Trend Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("Size", "Label Size", "", 10, 1 , 100);
	
	indicator.parameters:addGroup("Alerts Sound");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", true);	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);
	
	indicator.parameters:addGroup("Alerts Email");   
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", true);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);
	indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true);
	
	indicator.parameters:addBoolean("OnlyOnce", "Alert Once", "Subsequent Alert will be ignored.", false);	
	
	Parameters (1, "RSI Price/ Trade Signal Line");
	Parameters (2, "RSI Price/Market Base Line");
	Parameters (3, "RSI Price/Volatility Lines Up");
	Parameters (4, "RSI Price/Volatility Lines Down");
   
    Parameters (5, "RSI Price/Low Level");
	Parameters (6, "RSI Price/Middle Level");
	Parameters (7, "RSI Price/High Level");
end

function Parameters ( id, Label )
  
  
   indicator.parameters:addGroup(Label .. ". Alert");
  
    indicator.parameters:addBoolean("ON"..id , "Show " .. Label .." Alert" , "", true);


    indicator.parameters:addFile("Up_"..id, Label .. " Cross Over Sound", "", "");
    indicator.parameters:setFlag("Up_"..id, core.FLAG_SOUND);
	
	indicator.parameters:addFile("Down_"..id, Label .. " Cross Under Sound", "", "");
    indicator.parameters:setFlag("Down_"..id, core.FLAG_SOUND);
	
	 indicator.parameters:addString("Label"..id, "Label", "", Label);

end 

local 	Number = 7;

local iRSI, iPMA, iTSMA;
local P, VBU, VBD, TS, MB;

local VB_N, VB_W, L1, L2, L3;
local fP, fVB, fTS;

-- Parameters block
local Up={};
local Down={};
local Label={};
local ON={};
local first;
local source = nil;
local Line;
local up={};
local down={};
local Size;
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
local OnlyOnceFlag;

function Prepare(onlyName)

    OnlyOnceFlag=true;
	FIRST=true;
	OnlyOnce = instance.parameters.OnlyOnce;
	Show = instance.parameters.Show;
	Live = instance.parameters.Live;
	
    local name = profile:id() .. "(" .. instance.source:name() .. "," ..
                                        instance.parameters.RSI_N .. "," ..
                                        instance.parameters.VB_N .. "," .. instance.parameters.VB_W .. "," ..
                                        instance.parameters.RSI_P_N .. "," .. instance.parameters.RSI_P_M .. "," ..
                                        instance.parameters.TS_N .. "," .. instance.parameters.TS_M .. ")";
    instance:name(name);
    if onlyName then
        return ;
    end
	
	source = instance.source; 

    VB_N = instance.parameters.VB_N;
    VB_W = instance.parameters.VB_W;
    L1 = instance.parameters.L1;
    L2 = instance.parameters.L2;
    L3 = instance.parameters.L3;

    iRSI = core.indicators:create("RSI", instance.source, instance.parameters.RSI_N);
    assert(core.indicators:findIndicator(instance.parameters.RSI_P_M) ~= nil, instance.parameters.RSI_P_M .. " indicator must be installed");
    iPMA = core.indicators:create(instance.parameters.RSI_P_M, iRSI.DATA, instance.parameters.RSI_P_N);
    fP = iPMA.DATA:first();
    assert(core.indicators:findIndicator(instance.parameters.TS_M) ~= nil, instance.parameters.TS_M .. " indicator must be installed");
    iTSMA = core.indicators:create(instance.parameters.TS_M, iRSI.DATA, instance.parameters.TS_N);
    fTS = iTSMA.DATA:first();

    fVB = iRSI.DATA:first() + instance.parameters.VB_N - 1;

    P = instance:addStream("RSI_P", core.Line, name .. ".RSI_P", "PriceLine", instance.parameters.RSI_P_C, fP);
    P:setPrecision(math.max(2, instance.source:getPrecision()));
    P:setWidth(instance.parameters.RSI_P_W);
    P:setStyle(instance.parameters.RSI_P_S);

    P:addLevel(L1, instance.parameters.L_S, instance.parameters.L_W, instance.parameters.L_C);
    P:addLevel(L2, instance.parameters.L_S, instance.parameters.L_W, instance.parameters.L_C);
    P:addLevel(L3, instance.parameters.L_S, instance.parameters.L_W, instance.parameters.L_C);

    VBU = instance:addStream("VBU", core.Line, name .. ".VBU", "VolBandUp", instance.parameters.VB_C, fVB);
    VBU:setPrecision(math.max(2, instance.source:getPrecision()));
    VBU:setWidth(instance.parameters.VB_Wi);
    VBU:setStyle(instance.parameters.VB_S);

    VBD = instance:addStream("VBD", core.Line, name .. ".VBD", "VolBandDn", instance.parameters.VB_C, fVB);
    VBD:setPrecision(math.max(2, instance.source:getPrecision()));
    VBD:setWidth(instance.parameters.VB_Wi);
    VBD:setStyle(instance.parameters.VB_S);

    MB = instance:addStream("MB", core.Line, name .. ".MB", "MktBase", instance.parameters.MB_C, fVB);
    MB:setPrecision(math.max(2, instance.source:getPrecision()));
    MB:setWidth(instance.parameters.MB_W);
    MB:setStyle(instance.parameters.MB_S);

    TS = instance:addStream("TS", core.Line, name .. ".TS", "TrdSig", instance.parameters.TS_C, fTS);
    TS:setPrecision(math.max(2, instance.source:getPrecision()));
    TS:setWidth(instance.parameters.TS_W);
    TS:setStyle(instance.parameters.TS_S);
	
	Initialization();
	
	first=math.max(fTS,fVB,fP);
end


function  Initialization ()
     Size=instance.parameters.Size;
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
	  Up[i]=instance.parameters:getString("Up_" .. i);
	  Down[i]=instance.parameters:getString("Down_" .. i);
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
	
		if ON[i] then
		up[i] = instance:createTextOutput ("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Center, instance.parameters.Up, 0);
		down[i] = instance:createTextOutput ("Dn", "Dn", "Wingdings", Size, core.H_Center, core.V_Center, instance.parameters.Down, 0);
		end
	end
		
	

	
end	

function Update(period, mode)
    Calculation (period, mode);
	
	if period < first then
	return;
	end
	
	 Activate (1, period);
	 Activate (2, period);
	 Activate (3, period);
	 Activate (4, period);
	 Activate (5, period);
	 Activate (6, period);
	 Activate (7, period);
end



function Activate (id, period)

   local Shift=0;
   

   if Live~= "Live" then
	period=period-1;
	Shift=1;
	end
 
	  if id == 1  and ON[id]  then
	  
	       
			if P[period] > TS[period]
			and P[period-1] <= TS[period-1]
			then
			           
						     up[id]:set(period , TS[period], "\108");	
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  then
							  OnlyOnceFlag=false;
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Cross Over", period);
							    
							        if Show then
									Pop(Label[id], " Cross Over " );  	
								    end
								 
							  end
			elseif  P[period] < TS[period]
			and P[period-1] >= TS[period-1]
            then			
			
			            			 
			               down[id]:set(period , TS[period], "\108");	  						   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 then
							 OnlyOnceFlag=false;
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " Cross Under", period);	
								 if Show then
									Pop(Label[id], " Cross Under " );  	
								 end
							 
			                  end			   
	         end
			
	  
	 
	  end
	  
		 if id == 2  and ON[id]  then
	  
	       
			if P[period] > MB[period]
			and P[period-1] <= MB[period-1]
			then
			           
						     up[id]:set(period , MB[period], "\108");	
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  then
							  OnlyOnceFlag=false;
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Cross Over", period);
							    
							        if Show then
									Pop(Label[id], " Cross Over " );  	
								    end
								 
							  end
			elseif  P[period] < MB[period]
			and P[period-1] >= MB[period-1]
            then			
			
			            			 
			               down[id]:set(period , MB[period], "\108");	  						   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 then
							 OnlyOnceFlag=false;
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " Cross Under", period);	
								 if Show then
									Pop(Label[id], " Cross Under " );  	
								 end
							 
			                  end			   
	         end
			
	  
	 
	  end   
	  
	    --VBU VBD
	  if id == 3  and ON[id]  then
	  
	       
			if P[period] > VBU[period]
			and P[period-1] <= VBU[period-1]
			then
			           
						     up[id]:set(period , VBU[period], "\108");	
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  then
							  OnlyOnceFlag=false;
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Cross Over", period);
							    
							        if Show then
									Pop(Label[id], " Cross Over " );  	
								    end
								 
							  end
			elseif  P[period] < VBU[period]
			and P[period-1] >= VBU[period-1]
            then			
			
			            			 
			               down[id]:set(period , VBU[period], "\108");	  						   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 then
							 OnlyOnceFlag=false;
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " Cross Under", period);	
								 if Show then
									Pop(Label[id], " Cross Under " );  	
								 end
							 
			                  end			   
	         end
			
	  
	 
	  end   
	  
	  if id == 4  and ON[id]  then
	  
	       
			if P[period] > VBD[period]
			and P[period-1] <= VBD[period-1]
			then
			           
						     up[id]:set(period , VBD[period], "\108");	
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  then
							  OnlyOnceFlag=false;
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Cross Over", period);
							    
							        if Show then
									Pop(Label[id], " Cross Over " );  	
								    end
								 
							  end
			elseif  P[period] < VBD[period]
			and P[period-1] >= VBD[period-1]
            then			
			
			            			 
			               down[id]:set(period , VBD[period], "\108");	  						   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 then
							 OnlyOnceFlag=false;
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " Cross Under", period);	
								 if Show then
									Pop(Label[id], " Cross Under " );  	
								 end
							 
			                  end			   
	         end
			
	  
	 
	  end   
	  
	  
	  
	  if id == 5  and ON[id]  then
	  
	       
			if P[period] > L1
			and P[period-1] <= L1
			then
			           
						     up[id]:set(period , L1, "\108");	
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  then
							  OnlyOnceFlag=false;
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Cross Over", period);
							    
							        if Show then
									Pop(Label[id], " Cross Over " );  	
								    end
								 
							  end
			elseif  P[period] < L1
			and P[period-1] >= L1
            then			
			
			            			 
			               down[id]:set(period , L1, "\108");	  						   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 then
							 OnlyOnceFlag=false;
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " Cross Under", period);	
								 if Show then
									Pop(Label[id], " Cross Under " );  	
								 end
							 
			                  end			   
	         end
			
	  
	 
	  end   
	  
	  
	  if id == 6  and ON[id]  then
	  
	       
			if P[period] > L2
			and P[period-1] <= L2
			then
			           
						     up[id]:set(period , L2, "\108");	
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  then
							  OnlyOnceFlag=false;
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Cross Over", period);
							    
							        if Show then
									Pop(Label[id], " Cross Over " );  	
								    end
								 
							  end
			elseif  P[period] < L2
			and P[period-1] >= L2
            then			
			
			            			 
			               down[id]:set(period , L2, "\108");	  						   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 then
							 OnlyOnceFlag=false;
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " Cross Under", period);	
								 if Show then
									Pop(Label[id], " Cross Under " );  	
								 end
							 
			                  end			   
	         end
			
	  
	 
	  end   
	  
	  
	  
	  if id == 7  and ON[id]  then
	  
	       
			if P[period] > L3
			and P[period-1] <= L3
			then
			           
						     up[id]:set(period , L3, "\108");	
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  then
							  OnlyOnceFlag=false;
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Cross Over", period);
							    
							        if Show then
									Pop(Label[id], " Cross Over " );  	
								    end
								 
							  end
			elseif  P[period] < L3
			and P[period-1] >= L3
            then			
			
			            			 
			               down[id]:set(period , L3, "\108");	  						   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 then
							 OnlyOnceFlag=false;
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " Cross Under", period);	
								 if Show then
									Pop(Label[id], " Cross Under " );  	
								 end
							 
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

   core.host:execute ("prompt", 1, label ,
   " ( " .. source:instrument() .. " ) "  ..   label .. " : " .. note );


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
   
     local text = Note  .. delim ..  Symbol  .. delim .. Time;
 
  terminal:alertEmail(Email, profile:id(), text);
end
	 




function Calculation(period, mode)

iRSI:update(mode);
    iPMA:update(mode);
    iTSMA:update(mode);

    if period >= fP then
        P[period] = iPMA.DATA[period];
    end

    if period >= fTS then
        TS[period] = iTSMA.DATA[period];
    end

    if period >= fVB then
        local stdev, ma;
        stdev = core.stdev(iRSI.DATA, period - VB_N + 1, period);
        ma = core.avg(iRSI.DATA, period - VB_N + 1, period);
        VBU[period] = ma + VB_W * stdev;
        VBD[period] = ma - VB_W * stdev;
        MB[period] = ma;
    end

end

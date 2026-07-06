-- More information about this indicator can be found at:
--https://fxcodebase.com/code/viewtopic.php?f=17&t=72852

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+
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

-- This indicator will provides Audio / Email Alerts if and when Stochastic K Line cross given level.

-- Up to five signals can be selected.
-- 1. K/D Line Cross
-- 2. K/OB Line Cross
-- 3. K/OS Line
-- 4. K/Central Line Cross
-- 5. In Zone K/D Line Cross
-- 6. D/OB Line Cross
-- 7. D/OS Line
-- 8. D/Central Line Cross

 
-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams


--//////////////////////////////////////////////////////////////////////////////
--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

 
	
local Number = 16;
local Symbols={"\225","\226", "\225","\226","\225","\226","\225","\226","\225","\226", "\225","\226","\225","\226","\225","\226"};
local Font={"Wingdings", "Wingdings","Wingdings", "Wingdings","Wingdings", "Wingdings","Wingdings", "Wingdings","Wingdings", "Wingdings","Wingdings", "Wingdings","Wingdings", "Wingdings","Wingdings", "Wingdings"};
local Alert_Name={ "K/D" ,"K/D","K/OB" ,"K/OB","K/OS" ,"K/OS","K/Central" ,"K/Central","In Zone K/D" ,"In Zone K/D","D/OB" ,"D/OB","D/OS","D/OS"  ,"D/Central" ,"D/Central"};
local Signal_Name={"Cross Over", "Cross Under", "Cross Over", "Cross Under", "Cross Over", "Cross Under", "Cross Over", "Cross Under","Cross Over", "Cross Under", "Cross Over", "Cross Under", "Cross Over", "Cross Under", "Cross Over", "Cross Under"};
--//////////////////////////////////////////////////////////////////////////////
--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\


function Init()
    indicator:name("Stochastic  with Alert");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Mode");
    indicator.parameters:addString("Live", "End of Turn / Live", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
    indicator.parameters:addStringAlternative("Live", "Live", "", "Live");
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("K", "Number of periods for %K", "", 5, 2, 1000);
    indicator.parameters:addInteger("SD", "%D slowing periods", "", 3, 2, 1000);
    indicator.parameters:addInteger("D", "Number of periods for %D", "", 3, 2, 1000);

    indicator.parameters:addString("averageTypeK", "The type of smoothing algorithm for %K", "", "MVA");
    indicator.parameters:addStringAlternative("averageTypeK", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("averageTypeK", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("averageTypeK", "Fast Smoothed", "", "FS");	

    indicator.parameters:addString("averageTypeD", "The type of smoothing algorithm for %D", "", "MVA");
    indicator.parameters:addStringAlternative("averageTypeD", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("averageTypeD", "EMA", "", "EMA");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrFirst", "K Line Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("widthFirst", "K Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleFirst", "K Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleFirst", core.FLAG_LEVEL_STYLE);

    indicator.parameters:addColor("clrSecond", "D Line Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthSecond", "D Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleSecond", "D Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleSecond", core.FLAG_LEVEL_STYLE);

    indicator.parameters:addGroup("Levels");
    -- Overbought/oversold level
    indicator.parameters:addInteger("overbought", "Overbought Level", "", 80, 0, 100);
    indicator.parameters:addInteger("oversold", "Oversold Level", "", 20, 0, 100);
    indicator.parameters:addInteger("level_overboughtsold_width", "OverboughtSold Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "OverboughtSold Line Style", "", core.LINE_SOLID);
    indicator.parameters:addColor("level_overboughtsold_color", "OverboughtSold Line Color", "", core.FLAG_LEVEL_STYLE);
    
	
 
--\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
 
    indicator.parameters:addGroup("Alert Parameters");  
	indicator.parameters:addString("Signal_Execution", "Signal Execution", "", "End of Turn");
    indicator.parameters:addStringAlternative("Signal_Execution", "End of Turn", "", "End of Turn");
	indicator.parameters:addStringAlternative("Signal_Execution", "Live", "", "Live");  
	
 
	indicator.parameters:addString("Alert_Execution", "Alert Execution", "", "Live");
    indicator.parameters:addStringAlternative("Alert_Execution", "End of Turn", "", "End of Turn");
	indicator.parameters:addStringAlternative("Alert_Execution", "Live", "", "Live");  

   
   	indicator.parameters:addString("Alert_Triger", "Alert Triger", "", "Both");
    indicator.parameters:addStringAlternative("Alert_Triger", "Timer", "", "Timer");
	indicator.parameters:addStringAlternative("Alert_Triger", "Price", "", "Price");
    indicator.parameters:addStringAlternative("Alert_Triger", "Both", "", "Both");
	
    indicator.parameters:addInteger("Timer", "Execution Timer (in seconds)", "", 1, 0, 1000);
 
   
    
 
	 
	indicator.parameters:addInteger("ToTime", "Convert the date to", "", 6);
    indicator.parameters:addIntegerAlternative("ToTime", "EST", "", 1);
    indicator.parameters:addIntegerAlternative("ToTime", "UTC", "", 2);
    indicator.parameters:addIntegerAlternative("ToTime", "Local", "", 3);
    indicator.parameters:addIntegerAlternative("ToTime", "Server", "", 4);
    indicator.parameters:addIntegerAlternative("ToTime", "Financial", "", 5);
	indicator.parameters:addIntegerAlternative("ToTime", "Display", "", 6);	

	indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true);
	indicator.parameters:addBoolean("OnlyOnce", "Alert Once", "Subsequent Alert will be ignored.", false);	
	indicator.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
 
 
  
	
	indicator.parameters:addGroup("Alerts Sound");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", true);	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);

	
	indicator.parameters:addGroup("Alerts Email");   
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", false);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);

	
	local Color={};
	Color[1]= core.rgb(0, 255, 0);
	Color[2]= core.rgb(255, 0, 0);
	Color[3]= core.rgb(0, 255, 0);
	Color[4]= core.rgb(255, 0, 0);
	Color[5]= core.rgb(0, 255, 0);
	Color[6]= core.rgb(255, 0, 0);
	Color[7]= core.rgb(0, 255, 0);
	Color[8]= core.rgb(255, 0, 0);	
	Color[9]= core.rgb(0, 255, 0);
	Color[10]= core.rgb(255, 0, 0);
	Color[11]= core.rgb(0, 255, 0);
	Color[12]= core.rgb(255, 0, 0);
	Color[13]= core.rgb(0, 255, 0);
	Color[14]= core.rgb(255, 0, 0);
	Color[15]= core.rgb(0, 255, 0);
	Color[16]= core.rgb(255, 0, 0);	
	
	for i= 1, Number, 1 do
	Parameters (i, Alert_Name[i], Signal_Name[i],Color[i]);	 
 	end
 
	 
end




function Parameters ( id, Label1,Label2,internal_color )
  
  
   indicator.parameters:addGroup(Label1 .. " Alert");
  
    indicator.parameters:addBoolean("Alert_ON"..id , "Show " .. Label2 .." Alert" , "", true);
    indicator.parameters:addBoolean("Signal_ON"..id , "Show " .. Label2 .." Signal" , "", true); 
	

    indicator.parameters:addFile("Sound"..id, Label2 .. " Sound", "", "");
    indicator.parameters:setFlag("Sound"..id, core.FLAG_SOUND);

    indicator.parameters:addString("Alert_Label1"..id, "Alert Label", "", Label1);
	 indicator.parameters:addString("Alert_Label2"..id, "Alert Signal", "", Label2);
	 
	 
	 indicator.parameters:addColor("Color"..id, "Label Color", "",internal_color); 
	indicator.parameters:addInteger("Size"..id, "Label Size", "", 10, 1 , 100);

end 



local Sound={};
local Label1={};
local Label2={};
local Signal_ON={}; 
local Alert_ON={}; 
local Email;
local SendEmail;
local  RecurrentSound ,SoundFile  ;
local Show;
 
local PlaySound; 
local OnlyOnce;
local ItIs={};
local Color={};
local Size={};
local OnlyOnceFlag;
local ShowAlert;
local Alert={}; 
local AlertLevel={};
local ToTime;
local Shift=0; 
local Timer; 
local Signal_Execution, Alert_Execution,Alert_Triger;
local Alignment={};
--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
 
-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;

local k;
local d;
local sd;
local averageTypeK = nil;
local averageTypeD = nil;


local Indicator;
-- Streams block
local kLine = nil;
local dLine = nil;
local OB, OS;

-- Routine
function Prepare(nameOnly)
 
    OB = instance.parameters.overbought;
    OS = instance.parameters.oversold;

    averageTypeK = instance.parameters.averageTypeK;
    averageTypeD = instance.parameters.averageTypeD;

    assert(instance.parameters.oversold < instance.parameters.overbought, "OverSold is bigger then OverBought");

    k = instance.parameters.K;
    d = instance.parameters.D;
    sd = instance.parameters.SD;
    source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. ", " .. k .. ", " .. d .. ", " .. sd .. ", " .. averageTypeK .. ", " .. averageTypeD .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    Indicator = core.indicators:create("STOCHASTIC", source, k, d, sd, averageTypeK, averageTypeD);

    kLine = instance:addStream("K", core.Line, name .. ".K", "K", instance.parameters.clrFirst, Indicator.K:first());
    kLine:setWidth(instance.parameters.widthFirst);
    kLine:setStyle(instance.parameters.styleFirst);
    kLine:setPrecision(2);

    dLine = instance:addStream("D", core.Line, name .. ".D", "D", instance.parameters.clrSecond, Indicator.D:first());
    dLine:setWidth(instance.parameters.widthSecond);
    dLine:setStyle(instance.parameters.styleSecond);
    dLine:setPrecision(2);

    first = math.max(Indicator.D:first(), Indicator.K:first());

    kLine:addLevel(OB, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    kLine:addLevel(OS, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);

    
--\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\

   
   	Alert_Triger= instance.parameters.Alert_Triger;
	
	 
 
    if Alert_Triger ~= "Timer" then
    core.host:execute("subscribeTradeEvents", 1, "offers");
    end
	

	
	Timer= instance.parameters.Timer 
	Initialization();	
	instance:ownerDrawn(true);	
	
	if Alert_Triger ~= "Price" then-- this will work for Timer and Both
    core.host:execute ("setTimer", 3 , Timer);
	end
			
end 

function ReleaseInstance()
core.host:execute ("killTimer", 3 );
end 
 
 
--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
 

 

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)


    Indicator:update(mode);
    if period <= first then
        return;
    end

    dLine[period] = Indicator.D[period];
    kLine[period] = Indicator.K[period];


	if Signal_Execution~= "Live" then-- if Signal_Execution is NOT a Live shift period by 1 
	period=period-1;	 
	end
	

    for id=1, Number, 1 do
    Signal_Logic (id, period);
	end


--\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
	
	if Signal_Execution~= "Live" then-- if Signal_Execution is NOT a Live shift period by 1 
	period=period-1;	 
	end
	

    for id=1, Number, 1 do
    Signal_Logic (id, period);
	end
end




 

function  Initialization ()


    ToTime=instance.parameters.ToTime;
	
	if ToTime == 1 then
	ToTime=core.TZ_EST;
	elseif ToTime == 2 then
	ToTime=core.TZ_UTC;
	elseif ToTime == 3 then
	ToTime=core.TZ_LOCAL;
	elseif ToTime == 4 then
	ToTime=core.TZ_SERVER;
	elseif ToTime == 5 then
	ToTime=core.TZ_FINANCIAL;
	elseif ToTime == 6 then
	ToTime=core.TZ_TS;
	end
	
    
	OnlyOnceFlag=true;
	
	Signal_Execution = instance.parameters.Signal_Execution;
	Alert_Execution = instance.parameters.Alert_Execution;

	 
	OnlyOnce = instance.parameters.OnlyOnce;
	ShowAlert = instance.parameters.ShowAlert;
	Show = instance.parameters.Show;
	--Live = instance.parameters.Live;
	Show_Unconfirmed= instance.parameters.Show_Unconfirmed;

     for i= 1, Number , 1 do
		Alert[i]=instance:addInternalStream(0, 0);
		AlertLevel[i]=instance:addInternalStream(0, 0);
		Alignment[i]= instance:addInternalStream(0, 0);
     end
	 
	 
    
	 SendEmail = instance.parameters.SendEmail;
	 
	 local i;
	 for i = 1, Number , 1 do 
	  Label1[i]=instance.parameters:getString("Alert_Label1" .. i);
	  Label2[i]=instance.parameters:getString("Alert_Label2" .. i);
	  Signal_ON[i]=instance.parameters:getBoolean("Signal_ON" .. i);
	  Alert_ON[i]=instance.parameters:getBoolean("Alert_ON" .. i);
	 end
	 
	 
	 

    if SendEmail then
        Email = instance.parameters.Email;
    else
        Email = nil;
    end
	
    assert(not (SendEmail and (Email == "" or Email == nil )), "E-mail address must be specified");
	
	
	for i = 1, Number , 1 do 
	  Color[i]=instance.parameters:getColor("Color" .. i);
	  Size[i]=instance.parameters:getInteger("Size" .. i);
	end  
	
	 PlaySound = instance.parameters.PlaySound;
    if PlaySound then
    
	  for i = 1, Number , 1 do 
	  Sound[i]=instance.parameters:getString("Sound" .. i);
	 
	  end
	
    else 
	
	  for i = 1, Number , 1 do 
       Sound[i]=nil; 
	  end
		
    end
    
        for i = 1, Number , 1 do 
	  	 assert( not(PlaySound  and (Sound[i] == "" or Sound[i] == nil ) ), "Sound file must be chosen");
    
	end
	 
    RecurrentSound = instance.parameters.RecurrentSound;
	
	for i = 1, Number , 1 do 
	ItIs[i] = nil; 
	end
		 
end	

 


function Signal_Logic (id, period)
 

	
	
	
	    
	    if id== 1  then   
			if  kLine[period] > dLine[period] 
			and   kLine[period-1] <= dLine[period-1] 
			then
			           
						    
         
                Alert[id][period]= 1;	
 				AlertLevel[id][period]= dLine[period] 
				Alignment[id][period]= -1;		   
					
						   							  
			elseif  kLine[period] < dLine[period] 
			and   kLine[period-1] >= dLine[period-1] 
            then			
			--We will reset CrossOver Alert 
						   
		  
		     Alert[id][period]= 0;
			                
	         end
			
	    end
		
		
	    if id== 2  then   
			if  kLine[period] < dLine[period] 
			and   kLine[period-1] >= dLine[period-1] 
			then
			           
						    
         
                Alert[id][period]= 1;	
 				AlertLevel[id][period]= dLine[period] 
				Alignment[id][period]= -1;		   
					
						   							  
			elseif  kLine[period] > dLine[period] 
			and   kLine[period-1] <= dLine[period-1] 
            then			
			--We will reset CrossOver Alert 
						   
		  
		     Alert[id][period]= 0;
			                
	         end
			
	    end
		
		
	-------------------------------------------------------------------	
 	
		if id== 3   then  
			if  kLine[period] >  OB
			and   kLine[period-1] <= OB
			then
			           
						    
         
                Alert[id][period]= 1;	
 				AlertLevel[id][period]= OB
				Alignment[id][period]= 1;		   
			
						   
							  							  
			elseif  kLine[period] < OB
			and   kLine[period-1] >= OB
            then			
			 --We will reset CrossUnder Alert  
		 
		     Alert[id][period]= 0;
			                
	         end
			
	    end
		
		
		if id== 4   then  
			if  kLine[period] <  OB
			and   kLine[period-1] >= OB
			then
			           
						    
         
                Alert[id][period]= 1;	
 				AlertLevel[id][period]= OB
				Alignment[id][period]= 1;		   
			
						   
							  							  
			elseif  kLine[period] > OB
			and   kLine[period-1] <= OB
            then			
			 --We will reset CrossUnder Alert  
		 
		     Alert[id][period]= 0;
			                
	         end
			
	    end		
-------------------------------------------------------------------
	    	
		if id== 5   then  
			if  kLine[period] >  OS
			and   kLine[period-1] <= OS
			then
			           
						    
         
                Alert[id][period]= 1;	
 				AlertLevel[id][period]= OS
				Alignment[id][period]= 1;		   
			
						   
							  							  
			elseif  kLine[period] < OS
			and   kLine[period-1] >= OS
            then			
			 --We will reset CrossUnder Alert  
		 
		     Alert[id][period]= 0;
			                
	         end
			
	    end

		if id== 6   then  
			if  kLine[period] <  OS
			and   kLine[period-1] >= OS
			then
			           
						    
         
                Alert[id][period]= 1;	
 				AlertLevel[id][period]= OS
				Alignment[id][period]= 1;		   
			
						   
							  							  
			elseif  kLine[period] > OS
			and   kLine[period-1] <= OS
            then			
			 --We will reset CrossUnder Alert  
		 
		     Alert[id][period]= 0;
			                
	         end
			
	    end		
-------------------------------------------------------------------		
		
		if id== 7   then  
			if  kLine[period] >  50
			and   kLine[period-1] <= 50
			then
			           
						    
         
                Alert[id][period]= 1;	
 				AlertLevel[id][period]= 50
				Alignment[id][period]= 1;		   
			
						   
							  							  
			elseif  kLine[period] < 50
			and   kLine[period-1] >= 50
            then			
			 --We will reset CrossUnder Alert  
		 
		     Alert[id][period]= 0;
			                
	         end
			
	    end		
		
		if id== 8   then  
			if  kLine[period] <  50
			and   kLine[period-1] >= 50
			then
			           
						    
         
                Alert[id][period]= 1;	
 				AlertLevel[id][period]= 50
				Alignment[id][period]= 1;		   
			
						   
							  							  
			elseif  kLine[period] > 50
			and   kLine[period-1] <= 50
            then			
			 --We will reset CrossUnder Alert  
		 
		     Alert[id][period]= 0;
			                
	         end
			
	    end			
-------------------------------------------------------------------	
	
	
	    if id== 9  then   
			if  kLine[period] > dLine[period]   and (dLine[period] > OB or dLine[period] < OS)
			and   kLine[period-1] <= dLine[period-1]   and (dLine[period] > OB or dLine[period] < OS)
			then
			           
						    
         
                Alert[id][period]= 1;	
 				AlertLevel[id][period]= dLine[period] 
				Alignment[id][period]= -1;		   
					
						   							  
			elseif  kLine[period] < dLine[period]   and (dLine[period] > OB or dLine[period] < OS)
			and   kLine[period-1] >= dLine[period-1]   and (dLine[period] > OB or dLine[period] < OS)
            then			
			--We will reset CrossOver Alert 
						   
		  
		     Alert[id][period]= 0;
			                
	         end
			
	    end
		
		
		
	    if id== 10  then   
			if  kLine[period] < dLine[period]   and (dLine[period] > OB or dLine[period] < OS)
			and   kLine[period-1] >= dLine[period-1]   and (dLine[period] > OB or dLine[period] < OS)
			then
			           
						    
         
                Alert[id][period]= 1;	
 				AlertLevel[id][period]= dLine[period] 
				Alignment[id][period]= -1;		   
					
						   							  
			elseif  kLine[period] > dLine[period]   and (dLine[period] > OB or dLine[period] < OS)
			and   kLine[period-1] <= dLine[period-1]   and (dLine[period] > OB or dLine[period] < OS)
            then			
			--We will reset CrossOver Alert 
						   
		  
		     Alert[id][period]= 0;
			                
	         end
			
	    end
		
		
-------------------------------------------------------------------		
		if id== 11   then  
			if  dLine[period] >  OB
			and   dLine[period-1] <= OB
			then
			           
						    
         
                Alert[id][period]= 1;	
 				AlertLevel[id][period]= OB
				Alignment[id][period]= 1;		   
			
						   
							  							  
			elseif  dLine[period] < OB
			and   dLine[period-1] >= OB
            then			
			 --We will reset CrossUnder Alert  
		 
		     Alert[id][period]= 0;
			                
	         end
			
	    end


		if id== 12   then  
			if  dLine[period] <  OB
			and   dLine[period-1] >= OB
			then
			           
						    
         
                Alert[id][period]= 1;	
 				AlertLevel[id][period]= OB
				Alignment[id][period]= 1;		   
			
						   
							  							  
			elseif  dLine[period] > OB
			and   dLine[period-1] <= OB
            then			
			 --We will reset CrossUnder Alert  
		 
		     Alert[id][period]= 0;
			                
	         end
			
	    end
		
		
-------------------------------------------------------------------		


	    	
		if id== 13   then  
			if  dLine[period] >  OS
			and   dLine[period-1] <= OS
			then
			           
						    
         
                Alert[id][period]= 1;	
 				AlertLevel[id][period]= OS
				Alignment[id][period]= 1;		   
			
						   
							  							  
			elseif  dLine[period] < OS
			and   dLine[period-1] >= OS
            then			
			 --We will reset CrossUnder Alert  
		 
		     Alert[id][period]= 0;
			                
	         end
			
	    end
		
		if id== 14   then  
			if  dLine[period] >  OS
			and   dLine[period-1] <= OS
			then
			           
						    
         
                Alert[id][period]= 1;	
 				AlertLevel[id][period]= OS
				Alignment[id][period]= 1;		   
			
						   
							  							  
			elseif  dLine[period] < OS
			and   dLine[period-1] >= OS
            then			
			 --We will reset CrossUnder Alert  
		 
		     Alert[id][period]= 0;
			                
	         end
			
	    end		
		
-------------------------------------------------------------------		
		
		
		if id== 15  then  
			if  dLine[period] >  50
			and   dLine[period-1] <= 50
			then
			           
						    
         
                Alert[id][period]= 1;	
 				AlertLevel[id][period]= 50
				Alignment[id][period]= 1;		   
			
						   
							  							  
			elseif  dLine[period] < 50
			and   dLine[period-1] >= 50
            then			
			 --We will reset CrossUnder Alert  
		 
		     Alert[id][period]= 0;
			                
	         end
			
	    end		
		
		if id== 16  then  
			if  dLine[period] <  50
			and   dLine[period-1] >= 50
			then
			           
						    
         
                Alert[id][period]= 1;	
 				AlertLevel[id][period]= 50
				Alignment[id][period]= 1;		   
			
						   
							  							  
			elseif  dLine[period] > 50
			and   dLine[period-1] <= 50
            then			
			 --We will reset CrossUnder Alert  
		 
		     Alert[id][period]= 0;
			                
	         end
			
	    end			
end
 





function AsyncOperationFinished (cookie, success, message)

    if cookie~=1--subscribeTradeEvents
	and cookie~= 3 --Timer
	then
	return;
	end
	
 
	
    local Last_Period=source:size()-1;
	
	
	if Signal_Execution~= "Live" then
	Last_Period=Last_Period-1;	 
	end
	
    if Alert_Execution~= "Live" then
	Last_Period=Last_Period-1;	 
	end
	
	
     if Last_Period < first 
	 then
	 return;
	 end
	
	
	for i=1, Number, 1 do
    Alert_Logic (i, Last_Period);
    end
	
	
	

end




 

function Alert_Logic (id, period)



   
   
  
  
	if not  Alert_ON[id]  then
	return;
	end
	
	
	
	
	  
	    if   Alert[id][period]== 1  then   
		 
			           
  	   
							  if ItIs[id]~=source:serial(period)  
							  --and not FIRST 
							  and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag~= false))
							  --and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag== true))
							  then
							  
							  ItIs[id]=source:serial(period);
							  SoundAlert(Sound[id]);
							  EmailAlert( Label1[id], Label2[id]);
							  SendAlert( Label1[id],Label2[id],period); 
							  Pop(Label1[id], Label2[id], period );  
							  OnlyOnceFlag=false;
							  end 
		else
		
							   ItIs[id]=nil;
			 
			
	    end
		
 

end

 

function SoundAlert(internal_sound)
 if not PlaySound then
 return;
 end

  terminal:alertSound(internal_sound, RecurrentSound);
end

 


function EmailAlert( label1,label2 )

if not SendEmail then
return
end
 
   local now = core.host:execute("getServerTime");
	now = core.host:execute ("convertTime",  core.TZ_EST, ToTime, now);
	local DATA = core.dateToTable (now);
    
   --delim == djelim == new line	
   local delim = "\013\010";  
   local Note=  profile:id().. delim.. " Label : " ..label1  .. delim .. "Alert : " .. label2 ;   
   local Symbol= "Instrument : " .. source:instrument() ;
   local Time =  "Date : " .. DATA.month.." / ".. DATA.day .."Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec;  
   
   
    local TF= "Time Frame : " .. source:barSize();       
    local text = Note  .. delim ..  Symbol .. delim .. TF  .. delim .. Time;
	
	
 
   terminal:alertEmail(Email, profile:id(), text);
end
	 
	 
	 
	 
function Pop(label1,label2 , period)
 
 
 if not Show then
   return;
   end
 
   local now = core.host:execute("getServerTime");
	now = core.host:execute ("convertTime",  core.TZ_EST, ToTime, now);
	local DATA = core.dateToTable (now);
   
   local delim = "\013\010";   
	
   local Symbol= "Instrument : " .. source:instrument() ;
   local TF= "Time Frame : " .. source:barSize();   
    local Time =  "Date : " .. DATA.month.." / ".. DATA.day .. delim .. "Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec; 
    local Text= Symbol .. delim ..  TF .. delim ..  Time.. delim ..  label1 .. ":" ..    label2     
   core.host:execute ("prompt", 1, profile:id(),  Text );


end

function SoundAlert(sound_file)
 if not PlaySound then
 return;
 end
 
 terminal:alertSound(sound_file, RecurrentSound);
end

 
function SendAlert(label1,label2, period)
    if not ShowAlert then
        return;
    end
	
	local delim = "\013\010";  
	
	 local now = core.host:execute("getServerTime");
	now = core.host:execute ("convertTime",  core.TZ_EST, ToTime, now);
	local DATA = core.dateToTable (now);
	
   local Symbol= "Instrument : " .. source:instrument() ;
   local TF= "Time Frame : " .. source:barSize();   
    local Time =  "Date : " .. DATA.month.." / ".. DATA.day .. delim ..  "Time :"   .. DATA.hour  .. " / ".. DATA.min .." / ".. DATA.sec; 
  
    local Text= Symbol .. delim ..  TF .. delim ..  Time.. delim ..  label1 .. ":" ..    label2  
	
 
    terminal:alertMessage(source:instrument(), source[NOW], Text, source:date(NOW));
end



local init = false;
 
function Draw(stage, context)
 
	 if stage~= 2 then
	  return;
	  end
	  
	  
	
        if not init then
		   for Level = 1 , Number ,  1 do
           context:createFont (Level, Font[Level], context:pointsToPixels (Size[Level]), context:pointsToPixels (Size[Level]), 0);
		   end
            init = true;
        end
		
		

		
		for period= math.max(context:firstBar (),source:first()), math.min( context:lastBar (), source:size()-1), 1 do
		
		 
		
		 x, x1, x2= context:positionOfBar (period);
		 
				 for Level = 1 , Number ,  1 do
					   if Alert[Level]:hasData(period) and Signal_ON[Level] then
						 
							if Alert[Level][period]== 1
							and Alert[Level][period-1]~= 1
							then
							visible, y = context:pointOfPrice (AlertLevel[Level][period]);
							
							  width, height = context:measureText (1,  Symbols[Level], 0);

                              if Alignment[Level][period]==-1 then
							   context:drawText (Level,  Symbols[Level], Color[Level], -1,  x-width/2 ,  y , x+width/2 , y+height, 0 );	--low
							  else
							   context:drawText (Level,  Symbols[Level], Color[Level], -1,  x-width/2 ,  y-height , x+width/2 , y, 0 );	--high, have my arrow above the high
							  end
							  
				   
							 end
					  end
						
				 
				end
		end
		
  
end		
 
 --^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
 


--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+

-- Id: 14030
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62135

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("CCI Flow Signals");
    indicator:description("CCI Flow Signals");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
 
	indicator.parameters:addGroup("Selector");
	indicator.parameters:addBoolean("Use_OB", "Use OB Line Cross", "", true);
	indicator.parameters:addBoolean("Use_OS", "Use OS Line Cross", "", true);
	indicator.parameters:addBoolean("Use_Zero", "Use Zero Line Cross", "", true);
	
    indicator.parameters:addGroup("CCI Calculation");
	indicator.parameters:addString("Price", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted");	
    indicator.parameters:addInteger("CCI_Period", "Period","", 14, 2, 1000);
	indicator.parameters:addDouble("OB", "OB Level","", 100);
	indicator.parameters:addDouble("OS", "OS Level","", -100);
	
	indicator.parameters:addGroup("Super Trend Calculation");
    indicator.parameters:addInteger("N", "Number of periods", "", 10);
    indicator.parameters:addDouble("M", "Multiplier", "", 1.5);
	
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up_Color_Confirmed", "Color of Up", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down_Color_Confirmed", "Color of Down", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Up_Color_Unconfirmed", "Color of Up", "", core.rgb(0, 0, 255));
	indicator.parameters:addColor("Down_Color_Unconfirmed", "Color of Down", "", core.rgb(0, 0, 255));
     indicator.parameters:addInteger("Size", "Size", "", 10);
	 
	indicator.parameters:addGroup("Mode");  
	indicator.parameters:addString("Live", "End of Turn / Live", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
	indicator.parameters:addStringAlternative("Live", "Live", "", "Live");   
	
	
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
	
	Parameters (1, "OB Line");
	Parameters (2, "OS Line");
    Parameters (3, "Central Line");	
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

local 	Number = 3;

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
local first;
local source = nil;
local N, M;
-- Streams block
local  CCI = nil;
local Up_Color_Confirmed, Down_Color_Confirmed;
local Up_Color_Unconfirmed, Down_Color_Unconfirmed;
local CCI_Period;
local Size;
local over={};
local under={};
local OB,OS;
local Price;
local SuperTrend;
local Use={};



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
local OnlyOnceFlag;
local ShowAlert;
-- Routine
function Prepare(nameOnly)

    OnlyOnceFlag=true;
	FIRST=true;
	OnlyOnce = instance.parameters.OnlyOnce;
	ShowAlert = instance.parameters.ShowAlert;
	Show = instance.parameters.Show;
	Live = instance.parameters.Live;

    Up_Color_Confirmed = instance.parameters.Up_Color_Confirmed;
	Down_Color_Confirmed  = instance.parameters.Down_Color_Confirmed;
	N  = instance.parameters.N;
	M  = instance.parameters.M;
	Up_Color_Unconfirmed = instance.parameters.Up_Color_Confirmed;
	Down_Color_Unconfirmed  = instance.parameters.Down_Color_Unconfirmed;
	Use["OB"] = instance.parameters.Use_OB;
	Use["OS"] = instance.parameters.Use_OS;
	Use["Zero"]= instance.parameters.Use_Zero;
	
	CCI_Period  = instance.parameters.CCI_Period;
	Size  = instance.parameters.Size;
	Price = instance.parameters.Price;
	OB = instance.parameters.OB;
	OS = instance.parameters.OS;
    source = instance.source;
	local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Price).. ", " .. tostring(CCI_Period) .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
   
	
	assert(core.indicators:findIndicator("TBCCI") ~= nil, "Please, download and install TBCCI.LUA indicator");
	assert(core.indicators:findIndicator("SUPERTREND") ~= nil, "Please, download and install SUPERTREND.LUA indicator");
	
	SuperTrend= core.indicators:create("SUPERTREND", source , N,M,Up_Color_Confirmed , Down_Color_Confirmed);
	CCI= core.indicators:create("TBCCI", source[Price], CCI_Period);
	
	 first = math.max(CCI.DATA:first(), SuperTrend.DATA:first())+1;
	
	 

    if (not (nameOnly)) then
    over["OBU"] = instance:createTextOutput ("OBU", "OBU", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.Up_Color_Unconfirmed, first);
    under["OBU"] = instance:createTextOutput ("OBU", "OBU", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.Down_Color_Unconfirmed, first);
	over["ZU"] = instance:createTextOutput ("ZU", "ZU", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.Up_Color_Unconfirmed, first);
    under["ZU"] = instance:createTextOutput ("ZU", "ZU", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.Down_Color_Unconfirmed, first);
	over["OSU"] = instance:createTextOutput ("OSU", "OSU", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.Up_Color_Unconfirmed, first);
    under["OSU"] = instance:createTextOutput ("OSU", "OSU", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.Down_Color_Unconfirmed, first);
	
	over["OBC"] = instance:createTextOutput ("OBC", "OBC", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.Up_Color_Confirmed, first);
    under["OBC"] = instance:createTextOutput ("OBC", "OBC", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.Down_Color_Confirmed, first);
	over["ZC"] = instance:createTextOutput ("ZC", "ZC", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.Up_Color_Confirmed, first);
    under["ZC"] = instance:createTextOutput ("ZC", "ZC", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.Down_Color_Confirmed, first);
	over["OSC"] = instance:createTextOutput ("OSC", "OSC", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.Up_Color_Confirmed, first);
    under["OSC"] = instance:createTextOutput ("OSC", "OSC", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.Down_Color_Confirmed, first);
	
    end
	
    Initialization();
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



-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)
SuperTrend:update(mode);
CCI:update(mode);


    if Live~= "Live" then
	period=period-1; 
	end
	

  core.host:execute ("removeLabel", source:serial(period)); 

if period < first then
return;
end

over["OBU"]:setNoData (period);
over["OSU"]:setNoData (period);
over["ZU"]:setNoData (period);

under["OBU"]:setNoData (period);
under["OSU"]:setNoData (period);
under["ZU"]:setNoData (period);

over["OBC"]:setNoData (period);
over["OSC"]:setNoData (period);
over["ZC"]:setNoData (period);

under["OBC"]:setNoData (period);
under["OSC"]:setNoData (period);
under["ZC"]:setNoData (period);

local Trend=0;

if SuperTrend.DATA:colorI(period)  == Up_Color_Confirmed then
Trend=1;
elseif SuperTrend.DATA:colorI(period)  == Down_Color_Confirmed then
Trend=-1;
end


if Use["OB"] then
	if core.crossesOver (CCI.DATA, OB, period) then
		
		if Trend== 1 then
		over["OBC"]:set(period, source.low[period] , "\217" ,"OB Line CrossOver Confirmed" );
		Alert(period, "OB Line CrossOver Confirmed",1, true );
		else	
		over["OBU"]:set(period, source.low[period] , "\217" ,"OB Line CrossOver Unconfirmed" );
		Alert(period, "OB Line CrossOver Unconfirmed",1 , true);
		end
	elseif core.crossesUnder (CCI.DATA, OB, period) then
	   
		if Trend== -1 then
		under["OBC"]:set(period, source.high[period] , "\218" ,"OB Line CrossUnder Confirmed" );
		Alert(period, "OB Line CrossUnder Confirmed" ,1, false );
		else	
		 under["OBU"]:set(period, source.high[period] , "\218" ,"OB Line CrossUnder Unconfirmed" );
		 Alert(period, "OB Line CrossUnder Unconfirmed",1, false );
		end
	end
end


if Use["OS"] then
	if core.crossesOver (CCI.DATA, OS, period) then
		   
		if Trend== 1 then
		over["OSC"]:set(period, source.low[period] , "\217" ,"OS Line CrossOver Confirmed"  );  
		 Alert(period, "OS Line CrossOver Confirmed",2 , true);
		else	
		over["OSU"]:set(period, source.low[period] , "\217" ,"OS Line CrossOver Unconfirmed"  );  
		 Alert(period, "OS Line CrossOver Unconfirmed",2, true );
		end
	elseif core.crossesUnder (CCI.DATA, OS, period) then

		if Trend== -1 then
		under["OSC"]:set(period, source.high[period] , "\218" ,"OS Line CrossUnder Confirmed"  );
		 Alert(period, "OS Line CrossUnder Confirmed",2 , false );
		else	
		under["OSU"]:set(period, source.high[period] , "\218" ,"OS Line CrossUnder Unconfirmed"  );
		 Alert(period, "OS Line CrossUnder Unconfirmed",2, false );
		end
	end
end

if Use["Zero"] then
	if core.crossesOver (CCI.DATA, 0, period) then
		 
		if Trend== 1 then
		over["ZC"]:set(period, source.low[period] , "\217","Zero Line CrossOver Confirmed"  );
		Alert(period, "Zero Line CrossOver Confirmed",3 , true);
		else	
		over["ZU"]:set(period, source.low[period] , "\217","Zero Line CrossOver Unconfirmed"  );
		Alert(period, "Zero Line CrossOver Unconfirmed",3, true );
		end
	elseif core.crossesUnder (CCI.DATA, 0, period) then
	   
		if Trend== -1 then
		under["ZC"]:set(period, source.high[period] , "\218","Zero Line CrossUnder Confirmed" );
		Alert(period, "Zero Line CrossUnder Confirmed",3, false );
		else	
		under["ZU"]:set(period, source.high[period] , "\218","Zero Line CrossUnder Unconfirmed" );
		Alert(period, "Zero Line CrossUnder Unconfirmed",3, false );
		end
	end

end
    
end

function Alert(period, iLabel, id,Flag )

local Shift=0;
   

   if Live~= "Live" then
	Shift=1;
	end


        if Flag then
      D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  then
							  OnlyOnceFlag=false;
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], iLabel, period);
							  SendAlert(iLabel);
							  Pop(Label[id], iLabel );  	
								    
								 
							  end
					
			
			elseif not Flag then 				   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 then
							 OnlyOnceFlag=false;
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , iLabel, period);	
							 Pop(Label[id], iLabel );  	
							 SendAlert(iLabel);
							 
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
	 



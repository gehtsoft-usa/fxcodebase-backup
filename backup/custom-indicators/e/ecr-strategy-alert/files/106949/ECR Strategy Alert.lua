
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63633

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
    indicator:name("ECR Strategy Alert");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    
	indicator.parameters:addString("Price", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted");	
	
	indicator.parameters:addGroup("EMA Calculation");
    indicator.parameters:addInteger("EP", "EMA Period", "", 34);
	 
	
	indicator.parameters:addGroup("RSI Calculation");
    indicator.parameters:addInteger("RP", "RSI Period", "", 14);
	indicator.parameters:addDouble("RBL", "RSI Buy Level", "", 50);
	indicator.parameters:addDouble("RSL", "RSI Sell Level", "", 50);
	
	 indicator.parameters:addGroup("CCI Calculation");
	 indicator.parameters:addInteger("CP", "CCI Period", "", 14);	 
	 indicator.parameters:addDouble("CBL", "RSI Buy Level", "", -100);
	 indicator.parameters:addDouble("CSL", "RSI Sell Level", "", 100);
	
	
	
	
	
	 indicator.parameters:addGroup("Mode");  
	indicator.parameters:addString("Live", "End of Turn / Live", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
	indicator.parameters:addStringAlternative("Live", "Live", "", "Live");
	
	
	
	indicator.parameters:addGroup("Alert Style");
    indicator.parameters:addColor("UpColor1", "Long Alert Color", "", core.rgb(0, 255,0));
	indicator.parameters:addColor("DownColor1", "Short Alert Color", "", core.rgb(255, 0, 0));

	
	
	indicator.parameters:addInteger("Size", "Label Size", "", 10, 1 , 100);
	
	indicator.parameters:addGroup("Alerts Sound");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", true);	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);
	
	indicator.parameters:addGroup("Alerts Email");   
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", true);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);
	indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true);
	
	
	Parameters (1, "Trade Signal");
 
end

local first;
local source = nil;
local EP, RP, RBL,RSL, CP, CBL, CSL;

function Parameters ( id, Label )
  
  
   indicator.parameters:addGroup(Label .. " Alert");
  
    indicator.parameters:addBoolean("ON"..id , "Show " .. Label .." Alert" , "", true);
    indicator.parameters:addBoolean("Over"..id , "Show " .. Label .." CrossOver Alert" , "", true);
	 indicator.parameters:addBoolean("Under"..id , "Show " .. Label .." CrossUnder Alert" , "", true);
    
    indicator.parameters:addFile("Up"..id, Label .. " Cross Over Sound", "", "");
    indicator.parameters:setFlag("Up"..id, core.FLAG_SOUND);
	
	indicator.parameters:addFile("Down"..id, Label .. " Cross Under Sound", "", "");
    indicator.parameters:setFlag("Down"..id, core.FLAG_SOUND);
	
	 indicator.parameters:addString("Label"..id, "Label", "", Label);

end 

local 	Number = 1;
local Over={};
local Under={};
local Up={};
local Down={};
local Label={};
local ON={};
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
local U={};
local D={};
local UpColor={};
local DownColor={};

local EP, RP, RBL,RSL, CP, CBL, CSL,Price;
local Indicator={};
local Short={};

function Prepare(nameOnly)
      FIRST=true;
	  Show = instance.parameters.Show;
	Live = instance.parameters.Live;
	
	 
	EP= instance.parameters.EP;
	RP= instance.parameters.RP;
	RBL= instance.parameters.RBL;
	RSL= instance.parameters.RSL;
	CP= instance.parameters.CP;
	CBL= instance.parameters.CBL;
	CSL= instance.parameters.CSL;
	Price= instance.parameters.Price;
	  
     
    source = instance.source;
	
	local name = profile:id() .. ", " .. source:name() ;
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	 
 
	Indicator["EMA"] = core.indicators:create("EMA", source[Price], EP );
	Short["EMA"] = Indicator["EMA"]:getStream(0);
	
	Indicator["RSI"] = core.indicators:create("RSI", source[Price], RP );
	Short["RSI"] = Indicator["RSI"]:getStream(0);
	
		Indicator["CCI"] = core.indicators:create("CCI", source, CP );
	Short["CCI"] = Indicator["CCI"]:getStream(0);
	
	first=math.max(Short["EMA"]:first(), Short["CCI"]:first(), Short["RSI"]:first() );
    
    
	
	Initialization();
    
end


function  Initialization ()
     Size=instance.parameters.Size;
	 SendEmail = instance.parameters.SendEmail;
	 
	 local i;
	 for i = 1, Number , 1 do 
	  Label[i]=instance.parameters:getString("Label" .. i);
	  ON[i]=instance.parameters:getBoolean("ON" .. i);
	  Over[i]=instance.parameters:getBoolean("Over" .. i);
	  Under[i]=instance.parameters:getBoolean("Under" .. i);
	  UpColor[i]=instance.parameters:getDouble("UpColor" .. i);
      DownColor[i]=instance.parameters:getDouble("DownColor" .. i);
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
	
		if ON[i] then
		up[i] = instance:createTextOutput ("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Center, UpColor[i], 0);
		down[i] = instance:createTextOutput ("Dn", "Dn", "Wingdings", Size, core.H_Center, core.V_Center, DownColor[i], 0);
		end
	end
		
	

	
end	





function Update(period, mode)


   if period<first then
   return;
   end

   
    Indicator["EMA"]:update(mode);
	Indicator["CCI"]:update(mode);
	Indicator["RSI"]:update(mode);
	
 
	
	local i;
	for i = 1, Number , 1 do
		  if ON[i] then
		 down[i]:setNoData (period); 
		 up[i]:setNoData (period);
		 end
   end	 
   

	
    Activate (1, period);
	
	   
end


function Activate (id, period,Range)

   local Shift=0;
   

   if Live~= "Live" then
	period=period-1;
	Shift=1;
	end
 
	  if id == 1  and ON[id]  then
	  
	       
			 if  core.crossesOver(source.close, Short["EMA"] ,period) 
		     and Short["CCI"][period] < CBL
		     and Short["RSI"][period] < RBL
			 then 
			
			 D[id] = nil;           
						          up[id]:set(period ,source.low[period], "\108");	
						           
							      
								  if U[id]~=source:serial(period) 
								  and period == source:size()-1-Shift
								  and not FIRST 								    
								  then
								  U[id]=source:serial(period);
								  
									  if Over[id]  then
									  SoundAlert(Up[id]);
									  EmailAlert(  Label[id], " Long Trade", period);
									 
											if Show then
											Pop(Label[id], " Long Trade " );  	
											end
										end	
									 
								  end
			elseif core.crossesUnder(source.close, Short["EMA"] ,period) 
		    and Short["CCI"][period] > CSL
		    and Short["RSI"][period] > RSL	
            then			
			 
		     U[id] = nil;
			                
									  down[id]:set(period , source.high[period], "\108");	
							  
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 then
							     D[id]=source:serial(period);
								 
							       if Under[id] then 
								  SoundAlert(Down[id]);			 
								  EmailAlert( Label[id] , " Short Trade ", period);	
									 if Show then
										Pop(Label[id], " Short Trade " );  	
									 end
								 
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
   " ( " .. source:instrument() .. " : " .. source:barSize() .. " ) "  ..   label .. " : " .. note );


end

function SoundAlert(Sound)
 if not PlaySound then
 return;
 end

 
 terminal:alertSound(Sound, RecurrentSound);
end

 

function EmailAlert( label , Subject, period)

if not SendEmail then
return
end

  
    local date = source:date(period);
	local DATA = core.dateToTable (date);
	
    
   local delim = "\013\010";  
   local Note=  profile:id().. delim.. " Label : " ..label  .. delim .. " Alert : " .. Subject ;   
   local Symbol= "Instrument : " .. source:instrument() ;
   local TF= "Time Frame : " .. source:barSize();    
   local Time =  " Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec; 
   
     local text = Note  .. delim ..  Symbol .. delim .. TF  .. delim .. Time;
	

   terminal:alertEmail(Email, profile:id(), text);
end
	 




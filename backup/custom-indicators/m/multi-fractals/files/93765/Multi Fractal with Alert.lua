-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60616

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
    indicator:name("Multi Fractal with Alert");
    indicator:description("Shows multiple types of Fractal");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator:setTag("group", "Bill Williams");
	
	
	
    indicator.parameters:addGroup("Mode");  
	indicator.parameters:addString("Live", "End of Turn / Live", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
	indicator.parameters:addStringAlternative("Live", "Live", "", "Live");
    indicator.parameters:addGroup("Fractal Indicator Parameters"); 
    indicator.parameters:addColor("clrUP", "Up fractal", "", core.COLOR_UPCANDLE);
    indicator.parameters:addColor("clrDN", "Down Fractal", "", core.COLOR_DOWNCANDLE);
    indicator.parameters:addBoolean("ShowPrice", "Show Fractal Price", "", false);
	indicator.parameters:addBoolean("ShowType", "Show Fractal Type", "", true);
    indicator.parameters:addColor("clrPrice", "Price color", "", core.rgb(128, 128, 128));
	
 
	
	indicator.parameters:addGroup("Alerts Sound");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", true);	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);
	
	indicator.parameters:addGroup("Alerts Email");   
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", true);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);
	indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true);
	indicator.parameters:addBoolean("OnlyOnce", "Alert Once", "Subsequent Alert will be ignored.", false);	
	
	
	Parameters (1, "Ideal");
	Parameters (2, "Flat bottom");
	Parameters (3, "Flat top");
	Parameters (4, "Uptrend");
	Parameters (5, "Downtrend");
	
 
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

local 	Number = 5;

local Text= {"Ideal", "Flat bottom", "Flat top", "Uptrend", "Downtrend"};

local source;
local up0, down0;
local up1, down1;
local itype;


local Up={};
local Down={};
local Label={};
local ON={}; 
  
local Line; 
 
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
function Prepare(nameOnly)
    OnlyOnceFlag=true;
	FIRST=true;
	OnlyOnce = instance.parameters.OnlyOnce;
	Show = instance.parameters.Show;
	Live = instance.parameters.Live;
	
	
    source = instance.source;
    local name = profile:id() .. "(" .. source:name() .. ")";
	
	if   (nameOnly) then
        return;
    end
	
	
    instance:name(name);
    up0 = instance:createTextOutput ("Up", "Up", "Wingdings", 9, core.H_Center, core.V_Top, instance.parameters.clrUP, 0);
    down0 = instance:createTextOutput ("Dn", "Dn", "Wingdings", 9, core.H_Center, core.V_Bottom, instance.parameters.clrDN, 0);
    up1 = instance:createTextOutput ("", "UpL", "Verdana", 7, core.H_Right, core.V_Top, instance.parameters.clrPrice, 0);
    down1 = instance:createTextOutput ("", "DnL", "Verdana", 7, core.H_Right, core.V_Bottom, instance.parameters.clrPrice, 0);
	
	itype= instance:addInternalStream(0, 0);
	
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


function Update(period )

 if period < 6 then
return;
end


   Calculation (period)
	
    Activate (1, period );
	Activate (2, period );
	Activate (3, period );
	Activate (4, period );
	Activate (5, period );
end


function Activate (id, period)

   local Shift=0;
   

   if Live~= "Live" then
	period=period-1;
	Shift=1;
	end
 
	  if    ON[id]  and  math.abs(itype[period-2])== id and itype[period-2] > 0   then
			            
			
			 D[id] = nil;
						   
								  if U[id]~=source:serial(period) 
								  and period == source:size()-1-Shift
								  and not FIRST 
								  then
								  OnlyOnceFlag=false;
								  U[id]=source:serial(period);
								  SoundAlert(Up[id]);
								  EmailAlert(  Label[id], "Top " .. Text[id], period);
									
										if Show then
										Pop(Label[id], "Top " .. Text[id] );  	
										end
									 
								  end
								  
	elseif    ON[id]  and  math.abs(itype[period-2])== id and itype[period-2]< 0   then
			
			
                             	
			        	   
						   
		                   U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 then
							 OnlyOnceFlag=false;
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , "Bottom " .. Text[id], period);	
								 if Show then
									Pop(Label[id],  "Bottom " .. Text[id] );  	
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
   local TF= "Time Frame : " .. source:barSize();    
   local Time =  " Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec; 
   
     local text = Note  .. delim ..  Symbol .. delim .. TF  .. delim .. Time;
 
 terminal:alertEmail(Email, profile:id(), text);
end
	 



function Calculation (period)
  		local fractalHi = source.high[period - 2]; 
		local fractalLo = source.low[period - 2];
-- FRACTALS
-- Ideal
--	  |
--	 | |
--	|	|
		if source.high[period - 3] > source.high[period - 4]
		and fractalHi > source.high[period - 3]
		and fractalHi > source.high[period - 1]
		and source.high[period - 1] > source.high[period]
		and source.high[period - 1] > source.high[period - 4]
		and source.high[period - 3] > source.high[period]
		and source.low[period - 3] > source.low[period - 4]
		and fractalLo > source.low[period - 3]
		and fractalLo > source.low[period - 1]
		and source.low[period - 1] > source.low[period]
		and source.low[period - 1] > source.low[period - 4]
		and source.low[period - 3] > source.low[period]
		then 		
		itype[period-2]=1;
            up0:set(period - 2, source.high[period - 2], "\217", source.high[period - 2]);
            if instance.parameters.ShowPrice then
                up1:set(period - 2, source.high[period - 2], "  " .. source.high[period - 2]);
            end
			if instance.parameters.ShowType then
                up1:set(period - 2, source.high[period - 2], "   Ideal");
            end
-- Flat bottom
--	  |
--	 |||
--	|||||		
		elseif source.high[period - 3] > source.high[period - 4]
		and fractalHi > source.high[period - 3]
		and fractalHi > source.high[period - 1]
		and source.high[period - 1] > source.high[period]
		and source.high[period - 1] > source.high[period - 4]
		and source.high[period - 3] > source.high[period]
		and source.low[period - 3] >= source.low[period - 4]
		and fractalLo >= source.low[period - 3]
		and fractalLo >= source.low[period - 1]
		and source.low[period - 1] >= source.low[period]
		and source.low[period - 1] >= source.low[period - 4]
		and source.low[period - 3] >= source.low[period]
		then 
		itype[period-2]=2;
            up0:set(period - 2, source.high[period - 2], "\217", source.high[period - 2]);
            if instance.parameters.ShowPrice then
                up1:set(period - 2, source.high[period - 2], "  " .. source.high[period - 2]);
            end
			if instance.parameters.ShowType then
                up1:set(period - 2, source.high[period - 2], "   Flat bottom");
            end
-- Flat top
--	|||||
--	|| ||
--	|   |
		elseif source.high[period - 3] >= source.high[period - 4]
		and fractalHi >= source.high[period - 3]
		and fractalHi >= source.high[period - 1]
		and source.high[period - 1] >= source.high[period]
		and source.high[period - 1] >= source.high[period - 4]
		and source.high[period - 3] >= source.high[period]
		and source.low[period - 3] > source.low[period - 4]
		and fractalLo > source.low[period - 3]
		and fractalLo > source.low[period - 1]
		and source.low[period - 1] > source.low[period]
		and source.low[period - 1] > source.low[period - 4]
		and source.low[period - 3] > source.low[period]
		then 
		itype[period-2]=3;
            up0:set(period - 2, source.high[period - 2], "\217", source.high[period - 2]);
            if instance.parameters.ShowPrice then
                up1:set(period - 2, source.high[period - 2], "  " .. source.high[period - 2]);
            end
			if instance.parameters.ShowType then
                up1:set(period - 2, source.high[period - 2], "   Flat top");
            end
-- Uptrend
--	  ||
--	 |  |
--	|
		elseif source.high[period - 3] > source.high[period - 4]
		and fractalHi > source.high[period - 3]
		and fractalHi >= source.high[period - 1]
		and source.high[period - 1] >= source.high[period]
		and source.high[period - 1] > source.high[period - 4]
		and source.low[period - 3] > source.low[period - 4]
		and fractalLo > source.low[period - 3]
		and source.low[period - 1] > source.low[period - 3]
		and source.low[period] > source.low[period - 3]
		then
		itype[period-2]=4;
			up0:set(period - 2, source.high[period - 2], "\217", source.high[period - 2]);
            if instance.parameters.ShowPrice then
                up1:set(period - 2, source.high[period - 2], "  " .. source.high[period - 2]);
            end
			if instance.parameters.ShowType then
                up1:set(period - 2, source.high[period - 2], "   Uptrend");
            end
-- Downtrend
--	 ||
--	|  |
--		|
		elseif source.high[period - 1] > source.high[period]
		and fractalHi > source.high[period - 1]
		and fractalHi >= source.high[period - 3]
		and source.high[period - 3] >= source.high[period - 4]
		and source.high[period - 3] > source.high[period]
		and source.low[period - 1] > source.low[period]
		and fractalLo > source.low[period - 1]
		and source.low[period - 3] > source.low[period - 1]
		and source.low[period - 3] > source.low[period]
		then
		itype[period-2]=5;
			up0:set(period - 2, source.high[period - 2], "\217", source.high[period - 2]);
            if instance.parameters.ShowPrice then
                up1:set(period - 2, source.high[period - 2], "  " .. source.high[period - 2]);
            end
			if instance.parameters.ShowType then
                up1:set(period - 2, source.high[period - 2], "   Downtrend");
            end
        else
		itype[period-2]=0;
            up0:setNoData(period - 2);
            up1:setNoData(period - 2);
		end
-- Ideal
--	|   |
--	 | |
--	  |
		if source.low[period - 3] < source.low[period - 4]
		and fractalLo < source.low[period - 3]
		and fractalLo < source.low[period - 1]
		and source.low[period - 1] < source.low[period]
		and source.low[period - 1] < source.low[period - 4]
		and source.low[period - 3] < source.low[period]
		and source.high[period - 3] < source.high[period - 4]
		and fractalHi < source.high[period - 3]
		and fractalHi < source.high[period - 1]
		and source.high[period - 1] < source.high[period]
		and source.high[period - 1] < source.high[period - 4]
		and source.high[period - 3] < source.high[period]
		then
		itype[period-2]=-1;
            down0:set(period - 2, source.low[period - 2], "\218", source.low[period - 2]);
            if instance.parameters.ShowPrice then
                down1:set(period - 2, source.low[period - 2], "  " .. source.low[period - 2]);
            end
			if instance.parameters.ShowType then
                down1:set(period - 2, source.low[period - 2], "   Ideal");
            end
-- Flat top
-- |||||
--	|||
-- 	 |
		elseif source.low[period - 3] < source.low[period - 4]
		and fractalLo < source.low[period - 3]
		and fractalLo < source.low[period - 1]
		and source.low[period - 1] < source.low[period]
		and source.low[period - 1] < source.low[period - 4]
		and source.low[period - 3] < source.low[period]
		and source.high[period - 3] <= source.high[period - 4]
		and fractalHi <= source.high[period - 3]
		and fractalHi <= source.high[period - 1]
		and source.high[period - 1] <= source.high[period]
		and source.high[period - 1] <= source.high[period - 4]
		and source.high[period - 3] <= source.high[period]
		then
		itype[period-2]=-3;
            down0:set(period - 2, source.low[period - 2], "\218", source.low[period - 2]);
            if instance.parameters.ShowPrice then
                down1:set(period - 2, source.low[period - 2], "  " .. source.low[period - 2]);
            end
			if instance.parameters.ShowType then
                down1:set(period - 2, source.low[period - 2], "   Flat Top");
            end
-- Flat bottom
--	|	|
--	|| ||
--	|||||
		elseif source.low[period - 3] <= source.low[period - 4]
		and fractalLo <= source.low[period - 3]
		and fractalLo <= source.low[period - 1]
		and source.low[period - 1] <= source.low[period]
		and source.low[period - 1] <= source.low[period - 4]
		and source.low[period - 3] <= source.low[period]
		and source.high[period - 3] < source.high[period - 4]
		and fractalHi < source.high[period - 3]
		and fractalHi < source.high[period - 1]
		and source.high[period - 1] < source.high[period]
		and source.high[period - 1] < source.high[period - 4]
		and source.high[period - 3] < source.high[period]
		then
		itype[period-2]=-2;
            down0:set(period - 2, source.low[period - 2], "\218", source.low[period - 2]);
            if instance.parameters.ShowPrice then
                down1:set(period - 2, source.low[period - 2], "  " .. source.low[period - 2]);
            end
			if instance.parameters.ShowType then
                down1:set(period - 2, source.low[period - 2], "   Flat Bottom");
            end
-- Uptrend
--	    |
--	|  |
--	 ||
		elseif source.low[period - 1] < source.low[period]
		and fractalLo < source.low[period - 1]
		and fractalLo <= source.low[period - 3]
		and source.low[period - 3] <= source.low[period - 4]
		and source.low[period - 3] < source.low[period]
		and source.high[period - 1] < source.high[period]
		and fractalHi < source.high[period - 1]
		and source.high[period - 3] < source.high[period - 1]
		and source.high[period - 3] < source.high[period]		
		then
		itype[period-2]=-4;
			down0:set(period - 2, source.low[period - 2], "\218", source.low[period - 2]);
            if instance.parameters.ShowPrice then
                down1:set(period - 2, source.low[period - 2], "  " .. source.low[period - 2]);
            end
			if instance.parameters.ShowType then
                down1:set(period - 2, source.low[period - 2], "   Uptrend");
            end
		elseif source.low[period - 3] < source.low[period - 4]
		and fractalLo < source.low[period - 3]
		and fractalLo <= source.low[period - 1]
		and source.low[period - 1] <= source.low[period]
		and source.low[period - 1] < source.low[period - 4]
		and source.high[period - 3] < source.high[period - 4]
		and fractalHi < source.high[period - 3]
		and source.high[period - 1] < source.high[period - 3]
		and source.high[period] < source.high[period - 3]
		then 
		itype[period-2]=-5;
			down0:set(period - 2, source.low[period - 2], "\218", source.low[period - 2]);
            if instance.parameters.ShowPrice then
                down1:set(period - 2, source.low[period - 2], "  " .. source.low[period - 2]);
            end
			if instance.parameters.ShowType then
                down1:set(period - 2, source.low[period - 2], "   Downtrend");
            end
        else
		itype[period-2]=0;
            down0:setNoData(period - 2);
            down1:setNoData(period - 2);
        end		
 

end

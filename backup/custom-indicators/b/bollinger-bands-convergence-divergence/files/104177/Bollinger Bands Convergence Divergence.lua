
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63020

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
    indicator:name("Bollinger Bands Convergence Divergence");
    indicator:description("Provides a relative definition of high and low based on standard deviations and a simple moving average.");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    indicator:setTag("group", "Bollinger");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "Number of periods", "", 20, 1, 10000);
    indicator.parameters:addDouble("Dev", "Number of standard deviations", "", 2.0, 0.0001, 1000.0);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrCU", "Up Color of Central Line", "", core.rgb(0, 0, 255));
    indicator.parameters:addColor("clrCD", "Up Color of Central Line", "", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("widthC", "Width of Central Line", "", 1, 1, 5);
    indicator.parameters:addInteger("styleC", "Style of Central Line", "", core.LINE_DOT);
    indicator.parameters:setFlag("styleC", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addColor("clrBU", "Up Color of Band Line", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clrBD", "Up Color of Central Line", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthB", "Width of Central Line", "", 2, 1, 5);
    indicator.parameters:addInteger("styleB", "Style of Central Line", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleB", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addBoolean("fill", "Fill Bands", "", true);
    indicator.parameters:addColor("clrF", "Band Fill Color", "", core.rgb(255, 0, 255));
    indicator.parameters:addInteger("trF", "Fill Transparency", "0% (solid) - 100% (transparent)", 80, 0, 100);
	
	
	indicator.parameters:addGroup("Alert Parameters");  
	indicator.parameters:addString("Live", "End of Turn / Live", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
	indicator.parameters:addStringAlternative("Live", "Live", "", "Live");   

	indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true);
	indicator.parameters:addBoolean("OnlyOnce", "Alert Once", "Subsequent Alert will be ignored.", false);	
	indicator.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
	
	indicator.parameters:addGroup("Alert Style");
    indicator.parameters:addColor("UpTrendColor", "Up Trend Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addColor("DownTrendColor", "Down Trend Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("Size", "Label Size", "", 10, 1 , 100);
	
	indicator.parameters:addGroup("Alerts Sound");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", true);	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);

	
	indicator.parameters:addGroup("Alerts Email");   
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", true);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);

	
	Parameters (1, "Top Line");	
	Parameters (2, "Bottom Line");
	Parameters (3, "Central Line");
	Parameters (4, "Convergence / Divergence");
	
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

local 	Number = 4;

local Up={};
local Down={};
local Label={};
local ON={};
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
local UpTrendColor, DownTrendColor;
local OnlyOnceFlag;
local font;
local ShowAlert;

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local N;
local Dev;

local firstPeriod;
local source = nil;
local Db;
-- Streams block
local M = nil;
local iU = nil;
local iL = nil;
local U1 = nil;
local L1 = nil;
local clrCU, clrCD, clrBU, clrBD, fill;
local Arial;
-- Routine
function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	
    N = instance.parameters.N;
    Dev = instance.parameters.Dev;
    source = instance.source;
    firstPeriod = source:first() + N - 1;
    clrCU = instance.parameters.clrCU;
    clrCD = instance.parameters.clrCD;
    clrBU = instance.parameters.clrBU;
    clrBD = instance.parameters.clrBD;
    fill = instance.parameters.fill;
	
	
	OnlyOnceFlag=true;
	FIRST=true;
	OnlyOnce = instance.parameters.OnlyOnce;
	ShowAlert = instance.parameters.ShowAlert;
	Show = instance.parameters.Show;
	Live = instance.parameters.Live;
	UpTrendColor = instance.parameters.UpTrendColor;
	DownTrendColor = instance.parameters.DownTrendColor;
	Size=instance.parameters.Size;
	font = core.host:execute("createFont", "Wingdings", Size, false, false);
	Arial= core.host:execute("createFont", "Arial", Size, false, false);
	
	Db = instance:addInternalStream(0, 0);

   
    iU = instance:addStream("U", core.Line, name .. ".U", "TL", instance.parameters.clrBU, firstPeriod)
    iU:setWidth(instance.parameters.widthB);
    iU:setStyle(instance.parameters.styleB);
    iL = instance:addStream("L", core.Line, name .. ".L", "BL", instance.parameters.clrBU, firstPeriod)
    iL:setWidth(instance.parameters.widthB);
    iL:setStyle(instance.parameters.styleB);
    M = instance:addStream("M", core.Line, name .. ".M", "M", instance.parameters.clrCU, firstPeriod)
    M:setWidth(instance.parameters.widthC);
    M:setStyle(instance.parameters.styleC);

    if fill then
        U1 = instance:addInternalStream(firstPeriod, 0);
        L1 = instance:addInternalStream(firstPeriod, 0);
        instance:createChannelGroup("F", "F", U1, L1, instance.parameters.clrF, 100 - instance.parameters.trF);
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
function Update(period)
    if period < firstPeriod then
	return;
	end
	
        local ml = mathex.avg(source, period - N + 1, period);
        local d = mathex.stdev(source, period - N + 1, period);
        Db[period] = Dev * d;
        iU[period] = ml + Db[period];
        iL[period] = ml - Db[period];
        M[period] = ml;
        if fill then
            U1[period] = ml + Db[period];
            L1[period] = ml - Db[period];
        end
         
            if iU[period] >= iU[period - 1] then
                iU:setColor(period, clrBU);
            else
                iU:setColor(period, clrBD);
            end
            if iL[period] >= iL[period - 1] then
                iL:setColor(period, clrBU);
            else
                iL:setColor(period, clrBD);
            end
            if M[period] >= M[period - 1] then
                M:setColor(period, clrCU);
            else
                M:setColor(period, clrCD);
            end
 
    core.host:execute ("removeLabel", source:serial(period)); 
   
     
	
    Activate (1, period);
	Activate (2, period);
	Activate (3, period);
   	Activate (4, period);
end



function ReleaseInstance()
       core.host:execute("deleteFont", font);
	   core.host:execute("deleteFont", Arial);
end	   

function Activate (id, period)

   local Shift=0;
   

   if Live~= "Live" then
	period=period-1;
	Shift=1;
	end
 
	  if id == 1  and ON[id]  then
	  
	       
			if  iU[period] > iU[period-1] 
			and   iU[period-1] <= iU[period-2] 
			then
			           
						    
             core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, iU[period], core.CR_CHART, core.H_Center, core.V_Bottom, font, UpTrendColor, "\225");

 						 
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  then
							  OnlyOnceFlag=false;
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Slope Up ", period);
							  SendAlert(" Slope Up ");  
							        
									Pop(Label[id], " Slope Up " );  	
								    
								 
							  end
							  
			elseif  iU[period] < iU[period-1] 
			and   iU[period-1] >= iU[period-2] 
            then			
			
			            			 
			               core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, iU[period], core.CR_CHART, core.H_Center, core.V_Top, font, DownTrendColor, "\226");						   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 then
							 OnlyOnceFlag=false;
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " Slope Down ", period);	
								 
									Pop(Label[id], " Slope Down ");  	
								    SendAlert(" Slope Down ");
							 
			                  end			   
	         end
			
	  
	 
	  end
	  
	  if id == 2  and ON[id]  then
	  
	       
			if iL[period] > iL[period-1] 
			and   iL[period-1] <= iL[period-2] 
			then
			           
						    
             core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, iL[period], core.CR_CHART, core.H_Center, core.V_Bottom, font, UpTrendColor, "\225");

 						 
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  then
							  OnlyOnceFlag=false;
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Slope Up ", period);
							  SendAlert(" Slope Up ");  
							        
									Pop(Label[id], " Slope Up " );  	
								    
								 
							  end
			elseif  iL[period]  < iL[period-1] 
			and   iL[period-1] >= iL[period-2] 
            then			
			
			            			 
			               core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, iL[period], core.CR_CHART, core.H_Center, core.V_Top, font, DownTrendColor, "\226");						   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 then
							 OnlyOnceFlag=false;
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " Slope Down ", period);	
								 
									Pop(Label[id], " Slope Down " );  	
								    SendAlert(" Slope Down ");
							 
			                  end			   
	         end
			
	  
	 
	  end
	  
	  
	  
	  if id == 3  and ON[id]  then
	  
	       
			if  M[period] > M[period-1] 
			and   M[period-1] <= M[period-2] 
			then
			           
						    
             core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, M[period], core.CR_CHART, core.H_Center, core.V_Bottom, font, UpTrendColor, "\225");

 						 
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  then
							  OnlyOnceFlag=false;
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Slope Up ", period);
							  SendAlert(" Slope Up ");  
							        
									Pop(Label[id], " Slope Up " );  	
								    
								 
							  end
			elseif  M[period] < M[period-1] 
			and   M[period-1] >= M[period-2] 
            then			
			
			            			 
			               core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, M[period], core.CR_CHART, core.H_Center, core.V_Top, font, DownTrendColor, "\226");						   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 then
							 OnlyOnceFlag=false;
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " Slope Down ", period);	
								 
									Pop(Label[id], " Slope Down " );  	
								    SendAlert(" Slope Down ");
							 
			                  end			   
	         end
			
	  
	 
	  end
	  
	  --Convergence Divergence
	   if id == 4  and ON[id]  then
	  
	       
			if  Db[period] > Db[period-1]
			and  Db[period-1] <= Db[period-2]
			then
			           
						    
             core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, M[period], core.CR_CHART, core.H_Center, core.V_Bottom, Arial, UpTrendColor, "D");

 						 
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  then
							  OnlyOnceFlag=false;
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Divergence ", period);
							  SendAlert(" Divergence ");  
							        
									Pop(Label[id], " Divergence " );  	
								    
								 
							  end
			elseif  Db[period] < Db[period-1]
			and  Db[period-1] >= Db[period-2]
            then			
			
			            			 
			               core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, M[period], core.CR_CHART, core.H_Center, core.V_Top, Arial, DownTrendColor, "C");						   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 then
							 OnlyOnceFlag=false;
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " Convergence ", period);	
								 
									Pop(Label[id], " Convergence " );  	
								    SendAlert(" Convergence ");
							 
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
   
  core.host:execute ("prompt", 1, label ,   " ( " .. source:instrument() .. " ) "  ..   label .. " : " .. note );
  

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
   
   
    local Time =  " Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec;    
    local text = Note  .. delim ..  Symbol   .. delim .. Time;
	 
	
 
   terminal:alertEmail(Email, profile:id(), text);
end
	 





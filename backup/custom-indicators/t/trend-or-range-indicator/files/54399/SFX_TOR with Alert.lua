-- Id: 8479
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=5270

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
    indicator:name("SFX Trend Or Range with Alert");
    indicator:description("SFX Trend Or Range Indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("ATRPeriod", "ATRPeriod", "", 12);
    indicator.parameters:addInteger("StdDevPeriod", "StdDevPeriod", "", 12);
    indicator.parameters:addString("StdDevPrice", "StdDevPrice", "", "close");
    indicator.parameters:addStringAlternative("StdDevPrice", "close", "", "close");
    indicator.parameters:addStringAlternative("StdDevPrice", "open", "", "open");
    indicator.parameters:addStringAlternative("StdDevPrice", "high", "", "high");
    indicator.parameters:addStringAlternative("StdDevPrice", "low", "", "low");
    indicator.parameters:addStringAlternative("StdDevPrice", "median", "", "median");
    indicator.parameters:addStringAlternative("StdDevPrice", "typical", "", "typical");
    indicator.parameters:addStringAlternative("StdDevPrice", "weighted", "", "weighted");
    indicator.parameters:addInteger("MAPeriod", "MAPeriod", "", 3);
    indicator.parameters:addString("MAMethod", "MAMethod", "", "MVA");
    indicator.parameters:addStringAlternative("MAMethod", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MAMethod", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("MAMethod", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("MAMethod", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("MAMethod", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("MAMethod", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("MAMethod", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("MAMethod", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("MAMethod", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("MAMethod", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("MAMethod", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("MAMethod", "T3", "", "T3");
    indicator.parameters:addStringAlternative("MAMethod", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("MAMethod", "Median", "", "Median");
    indicator.parameters:addStringAlternative("MAMethod", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("MAMethod", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("MAMethod", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("MAMethod", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("MAMethod", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("MAMethod", "JSmooth", "", "JSmooth");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("ATR_clr", "ATR Color", "ATR Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("StdDev_clr", "StdDev Color", "StdDev Color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("MA_clr", "MA Color", "MA Color", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addGroup("Alert Style");
    indicator.parameters:addColor("Up", "Up Trend Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addColor("Down", "Down Trend Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("Size", "Label Size", "", 10, 1 , 100);
	
	
	indicator.parameters:addGroup("Alerts Sound");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", false);	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);
	
	indicator.parameters:addGroup("Alerts Email");   
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", false);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);
	
	
	Parameters (1, "ATR / StdDev")
	Parameters (2, "StdDev / MA")
	Parameters (3, "ATR / MA")
end



function Parameters ( id, Label )
  
  
   indicator.parameters:addGroup(Label .. " Alert");
  
    indicator.parameters:addBoolean("ON"..id , "Show " .. Label .." Alert" , "", false);


    indicator.parameters:addFile("Up"..id, Label .. " Cross Over Sound", "", "");
    indicator.parameters:setFlag("Up"..id, core.FLAG_SOUND);
	
	indicator.parameters:addFile("Down"..id, Label .. " Cross Under Sound", "", "");
    indicator.parameters:setFlag("Down"..id, core.FLAG_SOUND);
	
	 indicator.parameters:addString("Label"..id, "Label", "", Label);

end 

local 	Number = 3;


local first;
local source = nil;
local ATRPeriod;
local StdDevPeriod;
local StdDevPrice;
local MAPeriod;
local MAMethod;
local ATR;
local StdDev;
local MA;
local BuffATR=nil;
local BuffStdDev=nil;
local BuffMA=nil;


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
local RecurrentSound ,SoundFile;

local Alert;
local Indicator;
local PlaySound;

local FIRST=true;

local U={};
local D={};

function Prepare(nameOnly)

    FIRST=true;
    source = instance.source;
    ATRPeriod=instance.parameters.ATRPeriod;
    StdDevPeriod=instance.parameters.StdDevPeriod;
    StdDevPrice=instance.parameters.StdDevPrice;
    MAPeriod=instance.parameters.MAPeriod;
    MAMethod=instance.parameters.MAMethod;  
	
	
	local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.ATRPeriod .. ", " .. instance.parameters.StdDevPeriod .. ", " .. instance.parameters.StdDevPrice .. ", " .. instance.parameters.MAMethod .. ", " .. instance.parameters.MAPeriod .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
	assert(core.indicators:findIndicator("STDDEV") ~= nil, "Please, download and install STDDEV.LUA indicator");
    assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");
	
    ATR = core.indicators:create("ATR", source, ATRPeriod);	
	StdDev = core.indicators:create("STDDEV", source[StdDevPrice], StdDevPeriod);
    MA = core.indicators:create("AVERAGES", StdDev.DATA, MAMethod, MAPeriod, false);
	
	first = MA.DATA:first()
	
    
	
    BuffATR = instance:addStream("BuffATR", core.Line, name .. ".ATR", "ATR", instance.parameters.ATR_clr, ATR.DATA:first());
    BuffStdDev = instance:addStream("BuffStdDev", core.Line, name .. ".StdDev", "StdDev", instance.parameters.StdDev_clr, StdDev.DATA:first());
    BuffMA = instance:addStream("BuffMA", core.Line, name .. ".MA", "MA", instance.parameters.MA_clr, first);
    BuffATR:setWidth(instance.parameters.widthLinReg);
    BuffATR:setStyle(instance.parameters.styleLinReg);
    BuffStdDev:setWidth(instance.parameters.widthLinReg);
    BuffStdDev:setStyle(instance.parameters.styleLinReg);
    BuffMA:setWidth(instance.parameters.widthLinReg);
    BuffMA:setStyle(instance.parameters.styleLinReg);
	
	BuffATR:setPrecision(math.max(2, instance.source:getPrecision()));
	BuffStdDev:setPrecision(math.max(2, instance.source:getPrecision()));
	BuffMA:setPrecision(math.max(2, instance.source:getPrecision()));
		
	Initialization();
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
		up[i] = instance:createTextOutput ("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Center, instance.parameters.Up, 0);
		down[i] = instance:createTextOutput ("Dn", "Dn", "Wingdings", Size, core.H_Center, core.V_Center, instance.parameters.Down, 0);
		end
	end
		
	

	
end	

 function Calculate(period, mode)
     ATR:update(mode);
	
	if period  > ATR.DATA:first() then
	BuffATR[period]=ATR.DATA[period];
	end	
    
	
    StdDev:update(mode);
	
	if period > StdDev.DATA:first() then
	 BuffStdDev[period]=StdDev.DATA[period];
	end
	    
     MA:update(mode);
	 if period < first then
	 return;
	 end
	 
     BuffMA[period]=MA.DATA[period];
 
 end

function Update(period, mode)

if period < first then
return;
end
   
   Calculate(period, mode);
   
   
   local i;
	for i = 1, Number , 1 do
		  if ON[i] then
		 down[i]:setNoData (period); 
		 up[i]:setNoData (period);
		 end
   end	 
	
    Activate (1, period);
	Activate (2, period);
	Activate (3, period);
   
   
end



function Activate (id, period)


    -- BuffATR
	---BuffMA
	--BuffStdDev
	--Parameters (1, "ATR / StdDev")	
	--Parameters (2, "StdDev / MA")
	--Parameters (3, "ATR / MA")
		
	  if id == 1  and ON[id]  then
	  
	       
			if 	BuffATR[period-1] < BuffStdDev[period-1]
			and BuffATR[period] >  BuffStdDev[period]
			then
			           
						     up[id]:set(period , BuffStdDev[period], "\108");	
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1
							  then
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id] .." Cross Over");
							  end
			elseif 	BuffATR[period-1] > BuffStdDev[period-1]
			and BuffATR[period] <  BuffStdDev[period]		
            then			
			
			            			 
			               down[id]:set(period , BuffStdDev[period], "\108");	  						   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1
							 then
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] .. " Cross Under");								   
			                     end			   
	         end
			
	  
	  elseif id == 2  and ON[id] then
	  
	        if 	BuffStdDev[period-1] < BuffMA[period-1]
			and BuffStdDev[period] >  BuffMA[period]
			then
			           
						     up[id]:set(period , BuffMA[period], "\108");	
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1
							  then
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id] .." Cross Over");
							  end
			elseif 	BuffStdDev[period-1] > BuffMA[period-1]
			and BuffStdDev[period] <  BuffMA[period]		
            then			
			
			            			 
			               down[id]:set(period , BuffMA[period], "\108");	  						   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1
							 then
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] .. " Cross Under");								   
			                     end			   
	         end
	       
	  elseif id == 3  and ON[id] then	  	

            if 	BuffATR[period-1] < BuffMA[period-1]
			and BuffATR[period] >  BuffMA[period]
			then
			           
						     up[id]:set(period , BuffMA[period], "\108");	
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1
							  then
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id] .." Cross Over");
							  end
			elseif 	BuffATR[period-1] > BuffMA[period-1]
			and BuffATR[period] <  BuffMA[period]		
            then			
			
			            			 
			               down[id]:set(period , BuffMA[period], "\108");	  						   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1
							 then
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] .. " Cross Under");								   
			                     end			   
	         end
           	  
	  end
	  
end



function SoundAlert(Sound)


 if FIRST then
 FIRST= false;
 return;
 end
 
 
  terminal:alertSound(Sound, RecurrentSound);
end

 


function EmailAlert( Subject)

if not SendEmail then
return
end
 
    local date = source:date(NOW);
	local DATA = core.dateToTable (date);
	
    local LABEL =  DATA.month..", ".. DATA.day ..", ".. DATA.hour  ..", ".. DATA.min ..", ".. DATA.sec;
 
 
 terminal:alertEmail(Email,Subject,  profile:id() .. "(" .. source:instrument() .. ")"  .. Subject..", " .. LABEL);
end
	 


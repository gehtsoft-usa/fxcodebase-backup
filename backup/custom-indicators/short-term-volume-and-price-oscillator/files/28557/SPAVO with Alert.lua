-- Id: 11046
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=15080

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
    indicator:name("Short-term Volume and Price Oscillator with Alert");
    indicator:description("Short-term Volume and Price Oscillator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	
	 indicator.parameters:addGroup("Mode");  
	indicator.parameters:addString("Live", "End of Turn / Live", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
	indicator.parameters:addStringAlternative("Live", "Live", "", "Live");
	
indicator.parameters:addGroup("Calculation");
  indicator.parameters:addInteger("period", "Period", "", 8);
  indicator.parameters:addDouble("cutoff", "Cutoff", "", 1);
 indicator.parameters:addDouble("devH", "Standard Deviation High", "", 1.5);
  indicator.parameters:addDouble("devL", "Standard Deviation Low", "", 1.3);
 indicator.parameters:addInteger("stdevper", "Standard Deviation Period", "",100);

    indicator.parameters:addGroup("SPAVO Line Style Options");	 
	indicator.parameters:addInteger("widthS", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleS", "Style", " ", core.LINE_SOLID);
	 indicator.parameters:setFlag("styleS", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("SPAVO_color", "Color of SPAVO Line", "", core.rgb(255, 0, 0));
	
	indicator.parameters:addGroup("Bands Lines Style Options");	 
	indicator.parameters:addBoolean("ShowLine", "Show Bands", "", true);
	indicator.parameters:addInteger("widthB", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleB", "Style", " ", core.LINE_SOLID);
	 indicator.parameters:setFlag("styleB", core.FLAG_LINE_STYLE);
	 indicator.parameters:addColor("Up_color", "Color of upper SD Line", "", core.rgb(0, 255, 0));
	  indicator.parameters:addColor("Down_color", "Color of  lower SD Line", "", core.rgb(0, 255, 0));
	  
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
	indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true);
	
	
	
	 Parameters (1, "Line Cross");

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local period,cutoff,devH,devL,stdevper;
local haopen,haclose,LinReg;
local first;
local source = nil;
local EMA1, EMA2, EMA3,AVG;
local EMAA, EMAB, EMAC;
local EMAX, EMAY, EMAZ;
local haC,vtr, calc1; 
local  SVAPOBase;
-- Streams block
local SPAVO = nil;
local ShowLine;
local upperSDLine, lowerSDLine;
--//////////////////////////////////////
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

local Method1, Period1;
local Method2, Period2;
local  slow, Slow;
local Fast, fast;

--/////////////////////////////////////

function Parameters ( id, Label )
  
  
   indicator.parameters:addGroup(Label .. " Alert");
  
    indicator.parameters:addBoolean("ON"..id , "Show " .. Label .." Alert" , "", false);


    indicator.parameters:addFile("Up"..id, Label .. " Cross Over Sound", "", "");
    indicator.parameters:setFlag("Up"..id, core.FLAG_SOUND);
	
	indicator.parameters:addFile("Down"..id, Label .. " Cross Under Sound", "", "");
    indicator.parameters:setFlag("Down"..id, core.FLAG_SOUND);
	
	 indicator.parameters:addString("Label"..id, "Label", "", Label);

end 

local 	Number = 1;

-- Routine
function Prepare(nameOnly)

    FIRST=true;	
	Show = instance.parameters.Show;
	Live = instance.parameters.Live;
	
    stdevper = instance.parameters.stdevper;
    devH = instance.parameters.devH;
	devL = instance.parameters.devL;
    cutoff = instance.parameters.cutoff;
    period = instance.parameters.period;
    source = instance.source;
	ShowLine = instance.parameters.ShowLine;
    

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(period).. ", " .. tostring( cutoff) .. ", " .. tostring(devH).. ", " .. tostring( devL).. ", " .. tostring( stdevper).. ")";
    instance:name(name);

    if (not (nameOnly)) then
		haopen =  instance:addInternalStream(0, 0);
		haclose =instance:addInternalStream(0, 0);
		LinReg =instance:addInternalStream(0, 0);
		haC =instance:addInternalStream(0, 0);
		vtr =instance:addInternalStream(0, 0);
		calc1 =instance:addInternalStream(0, 0);
		SVAPOBase =instance:addInternalStream(0, 0);
		
		EMA1 = core.indicators:create("EMA", haclose,  period/1.6);
		EMA2 = core.indicators:create("EMA", EMA1.DATA,  period/1.6);
		EMA3 = core.indicators:create("EMA", EMA2.DATA,  period/1.6);
		
		EMAA = core.indicators:create("EMA", LinReg,  period);
		EMAB = core.indicators:create("EMA", EMAA.DATA,  period);
		EMAC = core.indicators:create("EMA", EMAB.DATA,  period);
		
		EMAX = core.indicators:create("EMA", SVAPOBase,  period);
		EMAY = core.indicators:create("EMA", EMAA.DATA,  period);
		EMAZ = core.indicators:create("EMA", EMAB.DATA,  period);
		
		
		AVG = core.indicators:create("MVA", source.volume,  period * 5);
		
		first = math.max(EMA3.DATA:first(), AVG.DATA:first()+1, EMAZ.DATA:first(), EMAC.DATA:first());
        SPAVO = instance:addStream("SPAVO", core.Line, name, "SPAVO", instance.parameters.SPAVO_color, EMAZ.DATA:first() );
    SPAVO:setPrecision(math.max(2, instance.source:getPrecision()));
		SPAVO:setWidth(instance.parameters.widthS);
	    SPAVO:setStyle(instance.parameters.styleS);
		if ShowLine then
		upperSDLine = instance:addStream("UPSD", core.Line, name, "upperSD", instance.parameters.Up_color, EMAZ.DATA:first() + stdevper);
    upperSDLine:setPrecision(math.max(2, instance.source:getPrecision()));
		lowerSDLine = instance:addStream("DOWNSD", core.Line, name, "upperSD", instance.parameters.Down_color, EMAZ.DATA:first() + stdevper);
    lowerSDLine:setPrecision(math.max(2, instance.source:getPrecision()));
		upperSDLine:setWidth(instance.parameters.widthB);
	    upperSDLine:setStyle(instance.parameters.styleB);
		lowerSDLine:setWidth(instance.parameters.widthB);
	    lowerSDLine:setStyle(instance.parameters.styleB);
		else
		upperSDLine=instance:addInternalStream(0, 0);
		lowerSDLine=instance:addInternalStream(0, 0);
		end
    end
	
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

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
  
	Calculation (period, mode);
	
		
	local i;
	for i = 1, Number , 1 do
		  if ON[i] then
		 down[i]:setNoData (period); 
		 up[i]:setNoData (period);
		 end
   end	 
   
   if period < first then
return;
end
	
    Activate (1, period);
    Activate (2, period); 
end

function Calculation (p, mode)

	haopen[p] = ((source.open[p-1] + source.high[p-1] + source.low[p-1] + source.close[p-1]) / 4 + haopen[p-1]) / 2;
	haclose[p] = ((source.open[p] + source.high[p] + source.low[p] + source.close[p]) / 4 + haopen[p] + math.max(source.high[p], haopen[p]) + math.min(source.low[p], haopen[p])) / 4;
	
	 EMA1:update(mode);
	 EMA2:update(mode);
     EMA3:update(mode);
	 AVG:update(mode);
	 
    if p < EMA3.DATA:first()
	or p < (AVG.DATA:first() + 1)
	then
    return;
	end		 
	 
	haC[p] = 3 * EMA1.DATA[p] - 3 * EMA2.DATA[p] + EMA3.DATA[p];
	
	local vave = AVG.DATA[p-1];
	local vmax = vave * 2;
	
	local  vc; 
	
	if source.volume[p] < vmax
	then 
	vc=  source.volume[p];
	else 
	vc= vmax 
	end
	
	LinReg[p] =  LinRegSlope(p, source.volume);	 
	
   
	
	EMAA:update(mode);
	EMAB:update(mode);
    EMAC:update(mode);
	
	if p < EMAC.DATA:first()
	then
    return;
	end		 
	
	vtr[p]=  3 * EMAA.DATA[p] - 3 * EMAB.DATA[p] + EMAC.DATA[p];
	
	-- SPAVO[p] = vtr[p]
	
	if vc== nil then
	vc=0;
	end
 
  if haC[p] > haC[p-1]*(1+cutoff/1000) and vtr[p] >= vtr[p-1] and vtr[p-1] > vtr[p-2] then
  calc1[p]= vc 
 elseif haC[p] < haC[p-1]*(1-cutoff/1000) and vtr[p] >= vtr[p-1] and vtr[p-1] > vtr[p-2] then
  calc1[p]= -vc
 else 
 calc1[p]=0;
 end
	
   SVAPOBase[p] = mathex.sum (calc1,p-period+1, p) /(vave+1);	
   
    EMAX:update(mode);
	EMAY:update(mode);
    EMAZ:update(mode);
	
	if p < EMAZ.DATA:first()
	then
    return;
	end		
   
  SPAVO[p] = 3 * EMAX.DATA[p] - 3 * EMAY.DATA[p] + EMAZ.DATA[p];
  
	 
			   if p < EMAZ.DATA:first() + stdevper
				then
				return;
				end		
			  
			   upperSDLine[p] = devH*mathex.stdev (SPAVO,p-stdevper+1, p);
			   lowerSDLine[p] = -devL*mathex.stdev (SPAVO,p-stdevper+1, p); 
	     
end

function LinRegSlope(p,data)

local b =0;
local c =0;
local petlja =0;
local test=0;
local y=0;
local xy=0;
local x=0;
local x2=0;
										
								for petlja = (p-period), p, 1 do
								
									if petlja == (p-period) then
									test=1;
									y = data[petlja];
									xy=data[petlja]*test;
									x=test;
									x2=test*test;
									else
									test=test+1;													
								    y = y + data[petlja];
								    xy=xy+(data[petlja]*test);
								    x=x+test;
								    x2=x2+(test*test);
									end
							
					   end
    		                  
            c=x2*(test)-x*x;
		    b=(xy*(test)-x*y)/c;			
	        return b;
	
	  
 end

 --//////////////////////////////////////////////////////////
 
 
 
function Activate (id, period)

   local Shift=0;
   

   if Live~= "Live" then
	period=period-1;
	Shift=1;
	end
 
	  if id == 1  and ON[id]  then
	  
	       
			if SPAVO[period] > upperSDLine[period]
			and SPAVO[period-1] <= upperSDLine[period-1]
			then
			           
						     up[id]:set(period , upperSDLine[period], "\108");	
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  then
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Cross Over", period);
							    
							        if Show then
									Pop(Label[id], " Cross Over " );  	
								    end
								 
							  end
			elseif  SPAVO[period] < lowerSDLine[period]
			and SPAVO[period-1] >= lowerSDLine[period-1]
            then			
			
			            			 
			               down[id]:set(period , lowerSDLine[period], "\108");	  						   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 then
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
   
     local text = Note  .. delim ..  Symbol .. delim .. TF   .. delim .. Time;
	

 
 terminal:alertEmail(Email, profile:id(), text);
end
	 
 
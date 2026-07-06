--+------------------------------------------------------------------+
--|                               Copyright © 2015, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--|                                 Support our efforts by donating  | 
--|                                    Paypal: http://goo.gl/cEP5h5  |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--|                    BitCoin : 1MfUHS3h86MBTeonJzWdszdzF2iuKESCKU  |  
--+------------------------------------------------------------------+

function Init()
    indicator:name("Compare Indexes indicator with Alert");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");  
    indicator.parameters:addString("Index1", "Index1", "No description", "EUR/USD");
    indicator.parameters:addString("Index2", "Index2", "No description", "GBP/USD");
    indicator.parameters:addDouble("Coeff1", "Cotff1", "No description", 1);
    indicator.parameters:addDouble("Coeff2", "Cotff2", "No description", -1);
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("color", "Line color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "Line style", core.LINE_SOLID);
	indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
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
	
	
	Parameters (1, "1.Level", 0)
	Parameters (2, "2.Level", 0)
 

	 
end


function Parameters ( id, Label, Level )
  
  
   indicator.parameters:addGroup(Label .. " Alert");
  
    indicator.parameters:addBoolean("ON"..id , "Show " .. Label .." Alert" , "", false);

    indicator.parameters:addDouble("Level"..id , id.. ". Level" , "", Level);
    indicator.parameters:addFile("Up"..id, Label .. " Cross Over Sound", "", "");
    indicator.parameters:setFlag("Up"..id, core.FLAG_SOUND);
	
	indicator.parameters:addFile("Down"..id, Label .. " Cross Under Sound", "", "");
    indicator.parameters:setFlag("Down"..id, core.FLAG_SOUND);
	
	 indicator.parameters:addString("Label"..id, "Label", "", Label);
	 
	indicator.parameters:addColor("LC"..id, id..". Level Line Color", " ", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("LW"..id, "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("LS"..id, "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("LS"..id, core.FLAG_LINE_STYLE);

end 

local 	Number = 2;
local Level={}; 

local first=nil;
local source = nil;
local barSize;
local usdx;
local loading = false;
local offset;
local weekoffset;
local Comp = nil;
local Index1;
local Index2;
local Coeff1;
local Coeff2;
local IndData1=1;
local IndData2=2;
local last=nil;
local data = {};
local LC={};
local LS={};
local LW={};

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

local Alert;
local Indicator;
local PlaySound;

local FIRST=true;
local U={};
local D={};

function AddCollectionItem(index, instrument, weight)
    local t, coll, from, to, tmp;
    t = {};
    t.instrument = instrument;
    t.data = nil;
    t.loading = false;
    t.weight = weight;
    t.rqfrom = nil;
    t.rqto = nil;
    data[index] = t;

    if first == nil or first > index then
        first = index;
    end
    if last == nil or last < index then
        last = index;
    end
end

function InitCollection()
    -- sum of absolute values of the weights must be 1. negative sign is for the
    -- instrument which has USD as counter currency.
    AddCollectionItem(IndData1, Index1, Coeff1);
    AddCollectionItem(IndData2, Index2, Coeff2);
end



function Prepare()
    FIRST=true;

		
		
    source = instance.source;
    Index1=instance.parameters.Index1;
    Index2=instance.parameters.Index2;
    Coeff1=instance.parameters.Coeff1;
    Coeff2=instance.parameters.Coeff2;
    host = core.host;
    barSize = source:barSize();
    offset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");
    
    InitCollection();
    local name = profile:id() .. "(" .. source:name() .. ", (" .. Coeff1 .. ")*" .. Index1 .. "+(" .. Coeff2 .. ")*" .. Index2 .. " )";
    instance:name(name);
    Comp = instance:addStream("Compare", core.Line, name, "Compare", instance.parameters.color, first)
	Comp:setWidth(instance.parameters.width);
    Comp:setStyle(instance.parameters.style);
	Comp:setPrecision (5);
		Initialization();

end


function  Initialization ()
     Size=instance.parameters.Size;
	 SendEmail = instance.parameters.SendEmail;
	 
	 local i;
	 for i = 1, Number , 1 do 
	  Label[i]=instance.parameters:getString("Label" .. i);
	  ON[i]=instance.parameters:getBoolean("ON" .. i);
	  Level[i]=instance.parameters:getDouble("Level" .. i);
	  LC[i]=instance.parameters:getDouble("LC" .. i);
	  LS[i]=instance.parameters:getDouble("LS" .. i);
	  LW[i]=instance.parameters:getDouble("LW" .. i);
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


local p = {};
local w = {};

function GetPrice(index, date)
    local t;

    local from, to, tmp;

    t = data[index];

    assert(t ~= nil, "internal error!");

    if t.data == nil then
        -- data is not loaded yet at all
        if source:isAlive() then
            to = 0;
        else
            to = source:date(source:size() - 1);
        end
        from = source:date(source:first());
        t.data = host:execute("getHistory", index, t.instrument, barSize, from, to, source:isBid());
        t.rqfrom = from;
        t.rqto = to;
        t.loading = true;
        loading = true;
        return 0, 0;
    elseif date < t.rqfrom then
        -- requested date is before the first item of the collection
        -- we have ever requested
        from = date;
        to = t.data:date(0);
        host:execute("extendHistory", index, t.data, from, to);
        t.rqfrom = from;
        t.loading = true;
        loading = true;
        return 0, 0;
    elseif not(source:isAlive()) and date > t.rqto then
        -- requested date is after the last item of the collection
        -- we have ever requested
        to = date;
        from = t.data:date(t.data:size() - 1);
        host:execute("extendHistory", index, t.data, from, to);
        t.rqto = to;
        t.loading = true;
        loading = true;
        return 0, 0;
    end

    local p;
    p = core.findDate (t.data, date, false);
    if p < 0 then
        return 0, 0;
    end
    return t.data.close[p], t.weight;
end

local lastdate = nil;

 function Calculate(period, mode)
 


    lastdate = source:date(period);

    local i, x, absent, a, b;
    absent = false;
    for i = first, last, 1 do
        a, b = GetPrice(i, lastdate);
        if a == 0 then
            absent = true;
        end
        p[i] = a;
        w[i] = b;
    end

    if loading then
        Comp:setBookmark(1, period);
        return ;
    end

    if absent then
        if Comp:hasData(period - 1) then
            Comp[period] = Comp[period - 1];
        end
    else
        x = 0;
        for i = first, last, 1 do
            x = x + p[i]*w[i];
        end
        Comp[period] = x;
    end

    period = period + 1;

    if period > 0 and period == source:size() - 1 then
        Comp[period] = Comp[period - 1];
    end
 
 
 end

function Update(period, mode)

  if loading or period <= source:first() then
        return ;
    end

    -- do not calculate for the floating candle
    period = period - 1;

    if lastdate ~= nil and source:date(period) == lastdate then
        return ;
    end
 

    Calculate(period, mode);
	
	
		local i;
	for i = 1, Number , 1 do
		  if ON[i] then
		 down[i]:setNoData (period); 
		 up[i]:setNoData (period);
		 end
   end	 
	
    Activate (1, period)
	Activate (2, period)
   

end

function AsyncOperationFinished(cookie)

    local t;
    t = data[cookie];
    t.loading = false;
    for i = first, last, 1 do
        if data[i].loading then
            return ;
        end
    end
    loading = false;

    local period;
    period = Comp:getBookmark(1);

    if (period < 0) then
        period = 0;
    end
    instance:updateFrom(period);
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
 

  local text=  profile:id() .. "(" .. source:instrument() .. ")"  .. Subject..", " .. LABEL ;

  terminal:alertEmail(Email, Subject, text);
   
end
	 

function Activate (id, period)


		
	  if id == 1  and ON[id]  then
	  
	   core.host:execute("drawLine", id, source:date(first), Level[id], source:date(source:size()-1),  Level[id],  LC[id], LS[id], LW[id]);     
			if 	Comp[period-1] < Level[id]
			and Comp[period] > Level[id]
			then
			           
						     up[id]:set(period ,  Level[id], "\108");	
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-2
							  then
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id] .." Cross Over");
							  end
			elseif 	Comp[period-1] > Level[id]
			and Comp[period] < Level[id]	
            then			
			
			            			 
			               down[id]:set(period ,  Level[id], "\108");	  						   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-2
							 then
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] .. " Cross Under");								   
			                     end			   
	         end
		 elseif id == 2  and ON[id]  then
		 
	    core.host:execute("drawLine", id, source:date(first), Level[id], source:date(source:size()-1),  Level[id],  LC[id], LS[id], LW[id]);     

	       
			if 	Comp[period-1] < Level[id]
			and Comp[period] > Level[id]
			then
			           
						     up[id]:set(period ,  Level[id], "\108");	
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-2
							  then
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id] .." Cross Over");
							  end
			elseif 	Comp[period-1] > Level[id]
			and Comp[period] < Level[id]		
            then			
			
			            			 
			               down[id]:set(period ,  Level[id], "\108");	  						   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-2
							 then
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] .. " Cross Under");								   
			                     end			   
	         end	
        end
end

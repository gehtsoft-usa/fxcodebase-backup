-- Id: 25401
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=68604

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
    indicator:name("Currency strength comparison");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);	   

 
	indicator.parameters:addGroup("Selector");	
	indicator.parameters:addBoolean("Components", "Show Components", "", false);
	indicator.parameters:addBoolean("Compact", "Show Compact", "", true);
	indicator.parameters:addGroup("Calculation");	
	indicator.parameters:addInteger("Period", "Period", "", 14);
	
    local i;
	local Default={"USD", "EUR", "GBP","JPY", "CHF",  "AUD", "NZD", "CAD"};
	indicator.parameters:addString("Default", "Index  Default", "", "AUD");
	for i= 1, 8, 1 do
    indicator.parameters:addStringAlternative("Default", Default[i], Default[i],Default[i]);
    end
	
	 

	
	
	Parameters (1 , "AUD/USD" );
	Parameters (2 , "AUD/JPY" );
 
 
	
	indicator.parameters:addGroup("Style");		
	indicator.parameters:addColor("color1", "1. Component Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("color2", "2. Component Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("color3", "Line Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addColor("color4", "Compact Line Color", "", core.rgb(128, 128, 128));
	
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end


function Parameters (id , Instrument )
    indicator.parameters:addGroup(id ..". Instruments");
	 

	indicator.parameters:addString("Instrument"..id, "Instruments", "", Instrument);
    indicator.parameters:setFlag("Instrument"..id, core.FLAG_INSTRUMENTS );
	
end

local loading={};
local SourceData={};
local Instrument={};
local Color;
local Num;
local Index={};
 
local ScaleFactor;
local Default;
local pdate = "(%a%a%a)/(%a%a%a)";
 
local Inverse={};
local First={};
local Second={};
local Color={};
local Period;
local dayoffset,weekoffset;
local Generic={};	

local Components,Compact;
	
function Prepare(nameOnly)      
	
    source = instance.source;
	Default = instance.parameters.Default;
	Period = instance.parameters.Period;
	Components = instance.parameters.Components;
	Compact = instance.parameters.Compact;
	 
	
    local name =  "(" .. profile:id() .. ","  .. instance.source:name().. ","  .. source:barSize().. ")"
	instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");	
		
	Color[1] = instance.parameters.color1;	
	Color[2] = instance.parameters.color2;	
	Color[3] = instance.parameters.color3;	
	Color[4] = instance.parameters.color4;	
	
	Num=0;
 
	for i = 1 , 2 , 1 do   
	
	 
	   
	         First[i], Second[i]= string.match( instance.parameters:getString ("Instrument"..i), pdate);
	   
	  
			  if First[i]== Default or Second[i]== Default then
			  Num = Num+1;	  			  
			  Instrument[Num]=  instance.parameters:getString ("Instrument"..i);  
			  
			  
			  if First[i]== Default then
			   Inverse[i]=0;
			  else
			  Inverse[i] =1;
			  end
		 
			  
			  else
			  error( i.. ". Instrument " ..instance.parameters:getString ("Instrument"..i) .. " does not contain ".. Default); 	
			  end
	 
	end	
	
	for i= 1, 2, 1 do   

            if 	Inverse[i]==0 then
			Generic[i]= Second[i];
			else
			Generic[i]= First[i];
			end
	end
	
	
	if  core.host:findTable("offers"):find("Instrument",Generic[1].."/".. Generic[2])== nil and  core.host:findTable("offers"):find("Instrument",Generic[2].."/".. Generic[1])== nil then
	  error("Required instrument is not available.");
	return;
	end
	
	
	if  core.host:findTable("offers"):find("Instrument", Generic[1].."/".. Generic[2]).Instrument~= nil then
	Num=Num+1;
	Instrument[Num]= Generic[1].."/".. Generic[2];
	
	if Generic[1] == Second[1] then 
	Inverse[1]=1;
	elseif Generic[1] == Second[2]then
	Inverse[2]=1
	end
	

	
	elseif  core.host:findTable("offers"):find("Instrument", Generic[2].."/".. Generic[1]).Instrument~= nil then
	Num=Num+1;
	Instrument[Num]= Generic[2].."/".. Generic[1];
	end
		
	local i;
			 
		 for i = 1, Num, 1 do	
		 
			   SourceData[i] = core.host:execute("getSyncHistory", Instrument[i], source:barSize(), source:isBid(), 0  ,20000 +i , 10000 + i);
			   loading[i] = true;  
			  
			  

		end
		 
	
		
	    for i=1, 2, 1 do
				
                if Components then				
				Index[i] = instance:addStream( Instrument[i], core.Line,  Instrument[i],   Instrument[i], Color[i], source:first());
    Index[i]:setPrecision(math.max(2, instance.source:getPrecision()));
				else
				Index[i] = instance:addInternalStream(0, 0);
                end				
        end 
		
		
		Index[3] = instance:addStream(Instrument[Num], core.Line, Instrument[Num],  Instrument[Num], Color[3], source:first());
    Index[3]:setPrecision(math.max(2, instance.source:getPrecision()));
		
		if Compact then
		Index[4] = instance:addStream(Instrument[Num].."Compact", core.Line, Instrument[Num].."+ Compact",  Instrument[Num].."+ Compact", Color[4], source:first());
    Index[4]:setPrecision(math.max(2, instance.source:getPrecision()));
		else
		Index[4] = instance:addInternalStream(0, 0);
		end
		
		for i=1, 4, 1 do
		Index[i]:setWidth(instance.parameters.width);
        Index[i]:setStyle(instance.parameters.style);
		end
end



function   Initialization(period,id)

    local Candle;
    Candle = core.getcandle(source:barSize(), source:date(period), dayoffset, weekoffset);
  
    if loading[id] or SourceData[id]:size() == 0  then
        return -1;
    end

    
    if period < source:first() then
        return -1;
    end

    local P = core.findDate(SourceData [id], Candle, false);
	 

    -- candle is not found
    if P < 0    then
        return -1;
	else return P;	
    end
			
end	

function Update(period)

 if period < source:first() then
 return
 end
 
     
    local FLAG=false;	
	local i;
	
		 for i = 1, Num, 1 do	

                 if loading[i] then
				 FLAG= true;				
				 end         	
         end
	
	if FLAG then 
	return;
	end
	
	
	local p;
	local min,max;					
                			  for i = 1, Num, 1 do 
							    p= Initialization(period,i); 
								
								if p > Period and p>0 then
									min,max=mathex.minmax(SourceData[i], p-Period+1, p);
									
									 
									if Inverse[i]==0 or Inverse[i]==nil then
									Index[i][period]= (SourceData[i].close[p]-SourceData[i].open[p-Period+1])/(math.abs(max-min)/100);
									else
									Index[i][period]= -(SourceData[i].close[p]-SourceData[i].open[p-Period+1])/(math.abs(max-min)/100);
								    end
									
									if i== 2 then
									Index[4][period]= Index[1][period] +Index[2][period] ;  
									end
								end	 
							  end
							  
							  
	 		 
                        							  
			             					 
					
	
end


-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)


 local i;
 

		 for i = 1, Num, 1 do	
			  if cookie == ( 10000 +  i) then
			  loading[i] = true;
		      elseif  cookie == (20000+ i) then
			  loading[i] = false;   
			  
			  end
		       
          end
	
	
	
    local FLAG=false; 
	local Number=0;
	
	
		 for i = 1, Num, 1 do	

                 if loading[i] then
				 FLAG= true;
				 Number=Number+1;
				 end
		 
         end  	
    
	
	if FLAG then
	 core.host:execute ("setStatus", "  Loading "..((Num - Number) .. " / " .. (Num) ));	 
	else
	core.host:execute ("setStatus", "Loaded")
	instance:updateFrom(0);
	end
   
        
    return core.ASYNC_REDRAW ;
end





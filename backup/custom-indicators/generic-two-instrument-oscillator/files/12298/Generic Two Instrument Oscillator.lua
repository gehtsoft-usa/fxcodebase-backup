-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=4980

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
    indicator:name("Generic Two Instrument Oscillator");
    indicator:description("Generic Two Instrument Oscillator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);	    
	indicator.parameters:addGroup("Calculation");

	indicator.parameters:addString("INDICATOR", "Indicator", "", "");
    indicator.parameters:setFlag("INDICATOR",core.FLAG_ONLYOSCILLATORS);
	

	indicator.parameters:addInteger("Number", "Data Stream Number", "", 0);
		
	Parameters (1  );
	Parameters (2  );
	
	
	indicator.parameters:addGroup("First Line Style");
	indicator.parameters:addColor("first", "First Line Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("firstwidth", "Line Width (in pixels)", "", 1, 1, 5);
    indicator.parameters:addInteger("firststyle", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("firststyle", core.FLAG_LEVEL_STYLE);
	
	indicator.parameters:addGroup("Second Line Style");
	indicator.parameters:addColor("second", "Second Line Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("secondwidth", "Line Width (in pixels)", "", 1, 1, 5);
    indicator.parameters:addInteger("secondstyle", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("secondstyle", core.FLAG_LEVEL_STYLE);
	
	
	
	
end

function Parameters (id )

   
	indicator.parameters:addGroup(id..". Line Instrument");
	indicator.parameters:addString("INSTRUMENT"..id, "Instrumet", "", "");
    indicator.parameters:setFlag("INSTRUMENT"..id, core.FLAG_INSTRUMENTS );
   
 
end

local Number;
local INDICATOR;
local out={};
local source;
local Indicator={};
local day_offset, week_offset;
local host;
--local alive;
local first;
 
 

local INSTRUMENT={}; 

local Count; 
local Source={};
local loading={};
	

function Prepare(nameOnly)   
   INDICATOR=instance.parameters.INDICATOR;
   Number=instance.parameters.Number;
  
	

 assert(core.indicators:findIndicator(INDICATOR) ~= nil, "Please, download and install" .. INDICATOR .. "indicator");	
    
    source = instance.source;
	first= source:first();
    host = core.host;	
	
   
    local name =  profile:id()  ;
	
	local i;

	for i = 1 , 2 , 1 do    
	
	  
	       INSTRUMENT[i] = instance.parameters:getString ("INSTRUMENT"..i);
	       
	  
      name = name..", ("  .. INSTRUMENT[i]    ..", "..  INDICATOR .. ")";      
	end	
	
	instance:name(name);
	if nameOnly then
		return;
	end
	
    day_offset = host:execute("getTradingDayOffset");
    week_offset = host:execute("getTradingWeekOffset"); 


	
 
	
	
	local tmpiprofile = core.indicators:findIndicator(instance.parameters:getString("INDICATOR"));
	local tmpiparams = instance.parameters:getCustomParameters("INDICATOR");
			   
    local TEMP    
	if  tmpiprofile:requiredSource() == core.Tick then
	TEMP= core.indicators:create(INDICATOR, source.close, tmpiparams);	
    else
	TEMP= core.indicators:create(INDICATOR, source, tmpiparams);	
    end	
	
	
	
	
	 Count= TEMP:getStreamCount ();
	if Number >  Count then
	error(INDICATOR .. " Only Have " .. (Count) .." Output Streams" );
    Number =0;
    end
	
	
	first= TEMP:getStream (Number):first();
	
	
 
						  
						  
						   
						   Source[1] = core.host:execute("getSyncHistory",INSTRUMENT[1], source:barSize(), source:isBid(), first*2, 200+1, 100+1);
						   Source[2] = core.host:execute("getSyncHistory",INSTRUMENT[2], source:barSize(), source:isBid(), first*2, 200+2, 100+2);
							
						   loading[1]=true;	  
						    loading[2]=true;	
						  
						   local iprofile1 = core.indicators:findIndicator(instance.parameters:getString("INDICATOR"));
		                   local iparams1 = instance.parameters:getCustomParameters("INDICATOR");
						  
						   local iprofile2 = core.indicators:findIndicator(instance.parameters:getString("INDICATOR"));
		                   local iparams2 = instance.parameters:getCustomParameters("INDICATOR");
							
							  if  iprofile1:requiredSource() == core.Tick then
							   Indicator[1] = iprofile1:createInstance(Source[1].close, iparams1);
							   else
							   Indicator[1] = iprofile1:createInstance(Source[1], iparams1);
							   end
						
							
                             	if  iprofile2:requiredSource() == core.Tick then
							   Indicator[2] = iprofile2:createInstance(Source[2].close, iparams2);
							   else
							   Indicator[2] = iprofile2:createInstance(Source[2], iparams2);
							   end
			
			
			
		
	out[1] = instance:addStream("out1", core.Line, "", INSTRUMENT[1], instance.parameters.first, source:first());
	out[2] = instance:addStream("out2", core.Line, "", INSTRUMENT[2] , instance.parameters.second, source:first());
	
   
    out[1]:setWidth(instance.parameters.firstwidth);
    out[1]:setStyle(instance.parameters.firststyle);
    out[1]:setPrecision(2);
	
	out[2]:setWidth(instance.parameters.secondwidth);
    out[2]:setStyle(instance.parameters.secondstyle);
    out[2]:setPrecision(2);
end

 


function Update(period, mode)

	
if loading[1] 
or loading[2] 
then
return;
end

Indicator[1]:update(mode);
Indicator[2]:update(mode);

local p={};
p[1]=Initialization(period,1);
p[2]=Initialization(period,2);

				      
					 for  i = 1 , 2 , 1 do 			
						 
					 	
						                  if p[i]~= false then					 					
										 out[i][period]= Indicator[i]:getStream (Number)[p[i]];										
										 end
								
								
					
					end	
	
end

function   Initialization(period,id)

    local Candle;
    Candle = core.getcandle(source:barSize(), source:date(period), day_offset, week_offset);
  
    if loading[id] or Source[id]:size() == 0  then
        return false;
    end

    
    if period < source:first() then
        return false;
    end

    local P = core.findDate(Source[id], Candle, false);
	 

    -- candle is not found
    if P < 0    then
        return false;
	else return P;	
    end
			
end	




-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
     local j;	 
	local Flag = true;	
	local iCount=0;	
	
	
	    local id=0;
		
    for j = 1, 2, 1 do
		id=id+1;
			  if cookie == (100+id) then
			  loading[j] = true;
		      elseif  cookie == (200+id) then
			  loading[j] = false;			  		 
              end
			  
		if loading[j] then
		iCount=iCount+1;
		Flag=false;
		end	 

		  
		
	end    
	
	    if Flag then
		core.host:execute ("setStatus", " Loaded ");
		instance:updateFrom(0);
		else
		core.host:execute ("setStatus", " Loading ".. (2-iCount) .."/" .. 2);
		end
			     
        
		return core.ASYNC_REDRAW ;
end


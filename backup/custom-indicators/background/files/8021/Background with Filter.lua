-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3351

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

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Background");
    indicator:description("Background");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
	indicator.parameters:addInteger("Stream1", "Number Of Indicator Stream", "", 0,0,100);	 
	indicator.parameters:addString("IN1", "Indicator", "", "");
    indicator.parameters:setFlag("IN1",core.FLAG_INDICATOR);
	
	
	indicator.parameters:addGroup("Filter ");
	indicator.parameters:addBoolean("Filter", "Use Filter", "", true);
	
	indicator.parameters:addString("TF", "Filter Time Frame", "", "D1");
	indicator.parameters:setFlag("TF", core.FLAG_PERIODS);
	
	indicator.parameters:addInteger("Stream2", "Number Of Indicator Stream", "", 0,0,100);	 
	indicator.parameters:addString("IN2", "Indicator", "", "");
    indicator.parameters:setFlag("IN2",core.FLAG_INDICATOR);
	 
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("up_color", "Up Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("dn_color", "Down Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("no_color", "Neutral Color", "", core.COLOR_BACKGROUND );
	indicator.parameters:addInteger("Transparency", "Transparency", "", 80,0,100);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local TF;
local first;
local source = nil;
local Filter;
-- Streams block
local Transparency = nil;
local Indicator1, Indicator2;
local MIN,MAX;
local min,max;
local up_color,dn_color,no_color;
local Stream1, Stream2;
local DATA;

local SourceData;
local loading = false;  
local dayoffset;
local weekoffset; 

-- Routine
function Prepare(nameOnly)  
    TF= instance.parameters.TF;
    Filter= instance.parameters.Filter;
    no_color = instance.parameters.no_color;
    Stream1 = instance.parameters.Stream1;
	Stream2 = instance.parameters.Stream2;
    Transparency = instance.parameters.Transparency;
	up_color = instance.parameters.up_color;
	dn_color  = instance.parameters.dn_color;
	Transparency= 100-Transparency;
	
	dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");
	
	
    source = instance.source;
    
	
	 local name;
 	
	if Filter then
	name= profile:id() .. "(" .. source:name()  ..", ".. instance.parameters:getString("IN1") ..", ".. instance.parameters:getString("IN2") ..")";
	else
	name= profile:id() .. "(" .. source:name()  ..", ".. instance.parameters:getString("IN1") ..")";
	end
	
    instance:name(name);
	
	
	if   (nameOnly) then
        return;
    end
	
	local  iprofile1;
    local iparams1;		
	iprofile1 = core.indicators:findIndicator(instance.parameters:getString("IN1"));
	iparams1 = instance.parameters:getCustomParameters("IN1");
	
	if  iprofile1:requiredSource() == core.Tick then
	Indicator1 = iprofile1:createInstance(source.close, iparams1);
	else
	Indicator1 = iprofile1:createInstance(source, iparams1);
	end   
	
	first =Indicator1.DATA:first();
	
	local COUNT1=Indicator1:getStreamCount ();
	
	if COUNT1> Stream1 then
	DATA1=Indicator1:getStream (Stream1);
	else
	 error(instance.parameters:getString("IN1") .. " Have Only "..COUNT1 .. " Data Streams" );
	end

   
	  
	 MAX=instance:addInternalStream(first, 0);	 
	 MIN=instance:addInternalStream(first, 0);
    
	
	instance:createChannelGroup("Group","Group" , MIN, MAX, up_color, Transparency);
	
	if Filter then
	
	local s1, e1, s2, e2;
    s1, e1 = core.getcandle(source:barSize(),0, 0, 0);
    s2, e2 = core.getcandle(TF, 0, 0, 0);
    assert ((e1 - s1) <= (e2 - s2), "The chosen time frame must be equal to or bigger than the chart time frame!");	
 
	SourceData = core.host:execute("getSyncHistory", source:instrument(), TF, source:isBid(), 300, 100, 101);
	loading=true;
	
	
	local  iprofile2;
    local iparams2;		
	iprofile2 = core.indicators:findIndicator(instance.parameters:getString("IN2"));
	iparams2 = instance.parameters:getCustomParameters("IN2");
	
	if  iprofile2:requiredSource() == core.Tick then
	Indicator2 = iprofile2:createInstance(SourceData.close, iparams2);
	else
	Indicator2 = iprofile2:createInstance(SourceData, iparams2);
	end   
	
	 
	
	local COUNT2=Indicator2:getStreamCount ();
	
	if COUNT2> Stream2 then
	DATA2=Indicator2:getStream (Stream2);
	else
	 error(instance.parameters:getString("IN2") .. " Have Only "..COUNT2 .. " Data Streams" );
	end
    
	end
	
end

function   Initialization(period)

    local Candle;
    Candle = core.getcandle(TF, source:date(period), dayoffset, weekoffset);

  
    if loading or SourceData:size() == 0 then
        return false ;
    end

    
    if period < source:first() then
        return false;
    end

    local p = core.findDate(SourceData, Candle, false);

    -- candle is not found
    if p < 0 then
        return false;
	else return p;	
    end
	
end	

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)

    if period < first or not source:hasData(period) then
	MIN:setColor(period,core.rgb( 255, 255, 255))
	return;
	end		
	
	if period == source:size()-1 then
	
	local i,p,FilterFlag;
	
	Indicator1:update(mode);
	if Filter then
	Indicator2:update(mode)
	end	
	
	
	min,max= mathex.minmax(source,first, source:size()-1);
	min=0;
	max= max*2;
			for i=first, source:size()-1,1 do
			
			MAX[i] = max;
			MIN[i] = min;
			
--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			
			
	FilterFlag=nil;
	
	if Filter then
	
	FilterFlag=0;	
		
		p =  Initialization(i) 
		 
		if not p then
		return;
		end
		  
		  if  DATA2:hasData(p) and  DATA2:hasData(p-1)  then
			  if  DATA2[p]> DATA2[p-1] then
			  FilterFlag=1;
			  elseif DATA2[p]< DATA2[p-1] then
			  FilterFlag=-1; 
			  end 
		  end
	end
		 
--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			
			    if  DATA1:hasData(i) and  DATA1:hasData(i-1) then					
					if DATA1[i]> DATA1[i-1]
					and(FilterFlag==nil or FilterFlag==1)
					then
					MIN:setColor(i,up_color);	
					elseif DATA1[i]< DATA1[i-1]
					and(FilterFlag==nil or FilterFlag==-1)
					then
					MIN:setColor(i,dn_color);
					else
					MIN:setColor(i,no_color)
					end
				end	
			end
	
	end    		

       
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    if cookie == 100 then
        loading = false;
        instance:updateFrom(0);
    elseif cookie == 101 then
        loading = true;
    end
end

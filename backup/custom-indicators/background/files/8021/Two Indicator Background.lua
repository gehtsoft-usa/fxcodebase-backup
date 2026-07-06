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
    indicator:name("Two Indicator Background");
    indicator:description("Two Indicator Background");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

     indicator.parameters:addInteger("Transparency", "Transparency", "", 80,0,100);
	 
	 
	 indicator.parameters:addString("IN1", "1. Indicator", "", "");
     indicator.parameters:setFlag("IN1",core.FLAG_INDICATOR);
	 
	  indicator.parameters:addInteger("Stream1", "Number Of Indicator Stream", "", 0,0,100);
	 
	 indicator.parameters:addString("IN2", "2. Indicator", "", "");
     indicator.parameters:setFlag("IN2",core.FLAG_INDICATOR);
	 
	   indicator.parameters:addInteger("Stream2", "Number Of Indicator Stream", "", 0,0,100);
	 
    indicator.parameters:addColor("up_color", "Up Color", "", core.rgb(0, 255, 0));
	 indicator.parameters:addColor("dn_color", "Down Color", "", core.rgb(255, 0, 0));
	 indicator.parameters:addColor("no_color", "Down Color", "", core.rgb(128, 128, 128));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block


local first;
local source = nil;

-- Streams block
local Transparency = nil;
local Indicator1, Indicator2;
local MIN,MAX;
local min,max;
local up_color,dn_color,no_color;
local Stream1, Stream2;
local DATA1,DATA2;

-- Routine
function Prepare(nameOnly)  
    no_color = instance.parameters.no_color;
    Stream1 = instance.parameters.Stream1;
	Stream2 = instance.parameters.Stream2;
    Transparency = instance.parameters.Transparency;
	up_color = instance.parameters.up_color;
	dn_color  = instance.parameters.dn_color;
	Transparency= 100-Transparency;
	
    source = instance.source;
	
	
	 local name = profile:id() .. "(" .. source:name()  ..", ".. instance.parameters:getString("IN1") ..", ".. instance.parameters:getString("IN2") ..")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
    
	local first2, first1;
	
	local  iprofile1;
    local iparams1;		
	iprofile1 = core.indicators:findIndicator(instance.parameters:getString("IN1"));
	iparams1 = instance.parameters:getCustomParameters("IN1");
	
	if  iprofile1:requiredSource() == core.Tick then
	Indicator1 = iprofile1:createInstance(source.close, iparams1);
	else
	Indicator1 = iprofile1:createInstance(source, iparams1);
	end   
	
	first1 =Indicator1.DATA:first();
	
	local COUNT=Indicator1:getStreamCount ();
	
	if COUNT> Stream1 then
	DATA1=Indicator1:getStream (Stream1);
	else
	 error(instance.parameters:getString("IN1") .. " Have Only "..COUNT .. " Data Streams" );
	end
 
 
 
     
	 local  iprofile2;
    local iparams2;		
	iprofile2 = core.indicators:findIndicator(instance.parameters:getString("IN2"));
	iparams2 = instance.parameters:getCustomParameters("IN2");
	
	if  iprofile2:requiredSource() == core.Tick then
	Indicator2 = iprofile2:createInstance(source.close, iparams2);
	else
	Indicator2 = iprofile2:createInstance(source, iparams2);
	end   
	
	first2 =Indicator2.DATA:first();
	
	local COUNT=Indicator2:getStreamCount ();
	
	if COUNT> Stream2 then
	DATA2=Indicator2:getStream (Stream2);
	else
	 error(instance.parameters:getString("IN2") .. " Have Only "..COUNT .. " Data Streams" );
	end
	
	
	first=math.max(first1,first2);
	
	 MAX=instance:addInternalStream(first, 0);
	 MIN=instance:addInternalStream(first, 0);
    
	
	instance:createChannelGroup("Group","Group" , MIN, MAX, up_color, Transparency);
    
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)
    if period < first or not source:hasData(period) then
	MIN:setColor(period,core.rgb( 255, 255, 255))
	return;
	end		
	
	if period == source:size()-1 then
	
	local i;
	
	Indicator1:update(mode);
	Indicator2:update(mode);
	
	min,max= mathex.minmax(source,first, source:size()-1);
	min=0;
	max= max*2;
			for i=first, source:size()-1,1 do
			
			MAX[i] = max;
			MIN[i] = min;
			
			    if  DATA1:hasData(i) and  DATA2:hasData(i) then					
					if DATA1[i]> DATA2[i] then
					MIN:setColor(i,up_color);	
					elseif DATA1[i]< DATA2[i] then
					MIN:setColor(i,dn_color);
					else
					MIN:setColor(i,no_color)
					end
				end	
			end
	
	end    		

       
end


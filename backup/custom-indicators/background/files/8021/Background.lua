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

     indicator.parameters:addInteger("Transparency", "Transparency", "", 80,0,100);
	  indicator.parameters:addInteger("Stream", "Number Of Indicator Stream", "", 0,0,100);
	 
	 indicator.parameters:addString("IN", "Indicator", "", "");
     indicator.parameters:setFlag("IN",core.FLAG_INDICATOR);
	 
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
local Indicator;
local MIN,MAX;
local min,max;
local up_color,dn_color,no_color;
local Stream;
local DATA;

-- Routine
function Prepare(nameOnly)  
    no_color = instance.parameters.no_color;
    Stream = instance.parameters.Stream;
    Transparency = instance.parameters.Transparency;
	up_color = instance.parameters.up_color;
	dn_color  = instance.parameters.dn_color;
	Transparency= 100-Transparency;
	
    source = instance.source;
	
	
	 local name = profile:id() .. "(" .. source:name()  ..", ".. instance.parameters:getString("IN") ..")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
    
	
	local  iprofile;
    local iparams;		
	iprofile = core.indicators:findIndicator(instance.parameters:getString("IN"));
	iparams = instance.parameters:getCustomParameters("IN");
	
	if  iprofile:requiredSource() == core.Tick then
	Indicator = iprofile:createInstance(source.close, iparams);
	else
	Indicator = iprofile:createInstance(source, iparams);
	end   
	
	first =Indicator.DATA:first();
	
	local COUNT=Indicator:getStreamCount ();
	
	if COUNT> Stream then
	DATA=Indicator:getStream (Stream);
	else
	 error(instance.parameters:getString("IN") .. " Have Only "..COUNT .. " Data Streams" );
	end

   
	
	--MAX=instance:addStream("MAX", core.Line, name, "", core.rgb( 128, 128, 128), first);
	--MIN=instance:addStream("MIN", core.Line, name, "", core.rgb( 128, 128, 128), first);
	
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
	
	Indicator:update(mode);
	min,max= mathex.minmax(source,first, source:size()-1);
	min=0;
	max= max*2;
			for i=first, source:size()-1,1 do
			
			MAX[i] = max;
			MIN[i] = min;
			
			    if  DATA:hasData(i) and  DATA:hasData(i-1) then					
					if DATA[i]> DATA[i-1] then
					MIN:setColor(i,up_color);	
					elseif DATA[i]< DATA[i-1] then
					MIN:setColor(i,dn_color);
					else
					MIN:setColor(i,no_color)
					end
				end	
			end
	
	end    		

       
end


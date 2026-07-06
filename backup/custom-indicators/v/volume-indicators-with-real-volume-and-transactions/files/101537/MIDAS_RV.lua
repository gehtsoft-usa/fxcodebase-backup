
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62412

--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
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
    indicator:name("MIDAS with Real volume/Transactions");
    indicator:description("MIDAS with Real volume/Transactions");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation"); 
    --indicator.parameters:addInteger("TopFinderVolumeNumBars", "Top Finder Volume Num Bars", "Top Finder Volume Num Bars", 30);
    indicator.parameters:addString("Ind", "Type of indicator", "", "Volume");
    indicator.parameters:addStringAlternative("Ind", "Volume", "", "Volume");
    indicator.parameters:addStringAlternative("Ind", "Transactions", "", "Transactions");
    indicator.parameters:addInteger("shift", "Shift", "Shift", 20);
    indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addColor("VWAP_color", "Color of VWAP", "Color of VWAP", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	indicator.parameters:addBoolean("Show", "Show VWAP Shift", "", false);

    indicator.parameters:addColor("VWAPShift_color", "Color of VWAPShift", "Color of VWAPShift", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);


end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
--local TopFinderVolumeNumBars;
local shift;
local Show;
local first;
local source = nil;

-- Streams block
local VWAP = nil;
local VWAPShift = nil;
local TopFinder = nil;
local AvgPrice = nil;
local CumVol;
local CumPVol;
--local db;
 local Date, Level;
  local CumPVol_J;
 local CumVol_J;
local Ind;

local FirstStart;
local LastTime;
-- Routine
function Prepare(nameOnly)
    --TopFinderVolumeNumBars = instance.parameters.TopFinderVolumeNumBars;
    shift = instance.parameters.shift;
    source = instance.source;
    first = source:first();
    Show = instance.parameters.Show;
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(shift) .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end	
	
     if instance.parameters.Ind=="Volume" then
      Ind=core.indicators:create("REAL VOLUME", source);
     else
      Ind=core.indicators:create("TRANSACTIONS", source);
     end
     FirstStart=true;
     LastTime=0;

    if (not (nameOnly)) then       
	AvgPrice= instance:addInternalStream(0, 0);
        VWAP = instance:addStream("VWAP", core.Line, name .. ".VWAP", "VWAP", instance.parameters.VWAP_color, first);
		VWAP:setWidth(instance.parameters.width1);
        VWAP:setStyle(instance.parameters.style1);
        if Show then
		VWAPShift = instance:addStream("VWAPShift", core.Line, name .. ".VWAPShift", "VWAPShift", instance.parameters.VWAPShift_color, first);     
        VWAPShift:setWidth(instance.parameters.width2);
        VWAPShift:setStyle(instance.parameters.style2); 		
		else
		VWAPShift= instance:addInternalStream(0, 0);
		end

    Date=0;
   	
	core.host:execute("addCommand", 1000, "Start From First Period", "");
    core.host:execute("addCommand", 1001, "Start From Selected Period", "");	
        
	CumVol= instance:addInternalStream(0, 0);
    CumPVol= instance:addInternalStream(0, 0);
    end
    
    CumPVol_J = -1
    CumVol_J = -1
end



local pattern = "([^;]*);([^;]*)";

function Parse(message)
    local level, date;
    level, date = string.match(message, pattern, 0);
	
    if level == nil or date == nil then
        return 0, 0;
    end
	
    return tonumber(date),tonumber(level) ;
end

function AsyncOperationFinished(cookie, success, message)

    local D,L;
	
	D,L  = Parse(message);

    if cookie == 1001 then
	
	          if L~= 0 then 
		      Date = D; 	   
    	      end
			  
			   CumPVol_J = -1
			   CumVol_J = -1     
     		   
    elseif cookie == 1000 then
    
			   CumPVol_J = -1
               CumVol_J = -1 
			    Date = 0;
    			
    end
    
     
    
end    

-- Indicator calculation routine
-- TODO: Add your code for calculation output values


 
function Update(period, mode)


    if period < first+1  then
    return;
    end        
   
        Ind:update(mode);
        if not(Ind.DATA:hasData(period)) then
            if period==first+1 then
                FirstStart=true;
            end    
            return;
        elseif FirstStart then
            FirstStart=false;
            instance:updateFrom(first);    
        elseif LastTime~=source:date(period) and period==source:size()-1 then
            LastTime=source:date(period);
            instance:updateFrom(period-10);
        end
    
			AvgPrice[period] = source.median[period];    			
			CumVol[period]=CumVol[period-1]+Ind.DATA[period];
			 CumPVol[period]=CumPVol[period-1]+Ind.DATA[period]*AvgPrice[period];  
				 
			 
	if 	(Date < source:date(period) and Date ~= 0  ) or  Date == 0   then	
	
	                 
			 
			 if  ( CumPVol_J == -1 and  CumVol_J == -1 and period == first and Date == 0 ) or  ( CumPVol_J == -1 and  CumVol_J == -1 and Date ~= 0   ) then 
			 
			    CumPVol_J = CumPVol[period];
			    CumVol_J = CumVol[period];          
			    VWAP[period]=AvgPrice[period];                              
			    VWAPShift[period]=VWAP[period]+VWAP[period]*shift/10000;      
			    
			  else
				  
			    VWAP[period]=( CumPVol[period] - CumPVol_J ) / ( CumVol[period] - CumVol_J );             
			    VWAPShift[period]=VWAP[period]+VWAP[period]*shift/10000;
			    
			  end
			  
	else
      
		CumPVol_J = -1;
		CumVol_J = -1;
		VWAP[period] = nil ;
		VWAPShift[period]=nil;
              	 	
        end
end

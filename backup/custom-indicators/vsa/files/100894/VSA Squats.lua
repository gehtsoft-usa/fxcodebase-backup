-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62307

--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("VSA Squats");
    indicator:description("VSA Squats");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addInteger("NumberofTicks", "Number of Ticks", "Number of Ticks", 0);
	
	indicator.parameters:addInteger("Size", "Label Size", "", 10, 1 , 100);
    indicator.parameters:addColor("UpLabelColor", "Color of Squat Up", "Color of Label", core.rgb(0, 255, 0));
	indicator.parameters:addColor("DownLabelColor", "Color of Squat Down", "Color of Label", core.rgb(255,0 , 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local NumberofTicks;

local first;
local source = nil;
local Size, UpLabelColor, DownLabelColor, font;
-- Streams block

 local O,L,H,C,Vol;
 local HV, SHV, UHV, EHV;

 local HT1,HT2,HT3,HT4;
 local LT1,LT2,LT3,LT4;
 
 function ReleaseInstance()
       core.host:execute("deleteFont", font);
end	   


-- Routine
function Prepare(nameOnly)
    NumberofTicks = instance.parameters.NumberofTicks;
    source = instance.source;
    first = source:first()+30;
	Size = instance.parameters.Size;
	UpLabelColor = instance.parameters.UpLabelColor;
	DownLabelColor = instance.parameters.DownLabelColor;
	
	font = core.host:execute("createFont", "Wingdings", Size, false, false);
 
	HT1 = instance:addInternalStream(first, 0);
	LT1 = instance:addInternalStream(first, 0);
	HT2 = instance:addInternalStream(first, 0);
	LT2 = instance:addInternalStream(first, 0);
	HT3 = instance:addInternalStream(first, 0);
	LT3 = instance:addInternalStream(first, 0);
	HT4 = instance:addInternalStream(first, 0);
	LT4 = instance:addInternalStream(first, 0);
	
	
	HV = instance:addInternalStream(first, 0);
	SHV = instance:addInternalStream(first, 0);
	UHV = instance:addInternalStream(first, 0);
	EHV = instance:addInternalStream(first, 0);	
	
	H=source.high;
    L=source.low;
	O=source.open;
	C=source.close;
	Vol=source.volume;
	

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(NumberofTicks) .. ")";
    instance:name(name);
 
end

 function Plot(Data, period, Label)
	 if Data[period]>= LT1[period] then
	 core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, Data[period], core.CR_CHART, core.H_Center, core.V_Top, font, UpLabelColor,  "\108");
	 else
	 core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, Data[period], core.CR_CHART, core.H_Center, core.V_Bottom, font, DownLabelColor,  "\108");
	 end
 end;



-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first or not source:hasData(period) then
	return;
	end
	
	local AvgVol= mathex.avg(Vol,period-30+1, period);
	local StandardDev= mathex.stdev(Vol,period-30+1, period);
	
	HV[period] =  AvgVol+(1.0*StandardDev);
	SHV[period] = AvgVol+(2.0*StandardDev);
	UHV[period] = AvgVol+(3.0*StandardDev);
	EHV[period] = AvgVol+(4.0*StandardDev);
    
	HT1[period]=L[period] - NumberofTicks*source:pipSize();
    LT1[period]=H[period] + NumberofTicks*source:pipSize();
	
	HT2[period]=L[period] - 2*NumberofTicks*source:pipSize();
    LT2[period]=H[period] + 2*NumberofTicks*source:pipSize();
	
	HT3[period]=L[period] - 3*NumberofTicks*source:pipSize();
    LT3[period]=H[period] + 3*NumberofTicks*source:pipSize();
	
	HT4[period]=L[period] - 4*NumberofTicks*source:pipSize();
    LT4[period]=H[period] + 4*NumberofTicks*source:pipSize();
	
	core.host:execute ("removeLabel", source:serial(period));
 

if H[period]>H[period-1] and L[period]>=L[period-1] and (H[period]-L[period])<(H[period-1]-L[period-1]) and Vol[period]>Vol[period-1] and Vol[period]>=EHV[period] then  	
	Plot(LT1,period,"SquatU");	 
end;

if L[period]<L[period-1] and H[period]<=H[period-1] and (H[period]-L[period])<(H[period-1]-L[period-1]) and Vol[period]>Vol[period-1] and Vol[period]>=EHV[period] then 
	Plot(HT1,period,"SquatD");
end;


if H[period]>H[period-1] and L[period]>=L[period-1] and (H[period]-L[period])==(H[period-1]-L[period-1]) and C[period]== O[period] and Vol[period]>Vol[period-1] and Vol[period]>=EHV[period] then  
	Plot(LT1,period,"SquatU");
end;


if L[period]<L[period-1] and H[period]<=H[period-1] and (H[period]-L[period])==(H[period-1]-L[period-1]) and C[period]== O[period] and Vol[period]>Vol[period-1] and Vol[period]>=EHV[period] then  
	Plot(HT1,period,"SquatD");
end;


if H[period]>H[period-1] and L[period]>=L[period-1] and (H[period]-L[period])==(H[period-1]-L[period-1]) and C[period]~= O[period] and C[period]== H[period] and Vol[period]>Vol[period-1] and Vol[period]>=EHV[period] then  
	Plot(LT1,period,"SquatU");
end;

if L[period]<L[period-1] and H[period]<=H[period-1] and (H[period]-L[period])==(H[period-1]-L[period-1]) and C[period]~= O[period] and C[period]== L[period] and Vol[period]>Vol[period-1] and Vol[period]>=EHV[period] then  
	Plot(HT1,period,"SquatD");
end;


if H[period]>H[period-1] and L[period]>=L[period-1] and (H[period]-L[period])==(H[period-1]-L[period-1]) and C[period]~= O[period] and C[period]==((H[period]-L[period])*0.5)+L[period] and Vol[period]>Vol[period-1] and Vol[period]>=EHV[period] then  
	Plot(LT1,period,"SquatU");
end;

if L[period]<L[period-1] and H[period]<=H[period-1] and (H[period]-L[period])==(H[period-1]-L[period-1]) and C[period]~= O[period] and C[period]==((H[period]-L[period])*0.5)+L[period] and Vol[period]>Vol[period-1] and Vol[period]>=EHV[period] then  
	Plot(HT1,period,"SquatD");
end;


if H[period]>H[period-1] and L[period]>=L[period-1] and (H[period]-L[period])==(H[period-1]-L[period-1]) and C[period]~= O[period] and C[period]== L[period] and Vol[period]>Vol[period-1] and Vol[period]>=EHV[period] then  
	Plot(LT1,period,"SquatU"); 
end;

if L[period]<L[period-1] and H[period]<=H[period-1] and (H[period]-L[period])==(H[period-1]-L[period-1]) and C[period]~= O[period] and C[period]== H[period] and Vol[period]>Vol[period-1] and Vol[period]>=EHV[period] then  
	Plot(HT1,period,"SquatD");
end;


if H[period-1]>H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]>C[period] and H[period-1]>=H[period] and Vol[period-1]>Vol[period-2] and Vol[period-1]<EHV[period-1] and Vol[period-1]>=UHV[period-1] then  
	Plot(LT2,period ,"SquatU");
end;

if L[period-1]<L[period-2] and H[period-1]<=H[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]<C[period] and L[period-1]<=L[period] and Vol[period-1]>Vol[period-2] and Vol[period-1]<EHV[period-1] and Vol[period-1]>=UHV[period-1] then  
	Plot(HT2,period ,"SquatD");
end;


if H[period-1]>H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])==(H[period-2]-L[period-2]) and C[period-1]==O[period-1] and C[period-1]>C[period] and H[period-1]>=H[period] and Vol[period-1]>Vol[period-2] and Vol[period-1]<EHV[period-1] and Vol[period-1]>=UHV[period-1] then  
	Plot(LT2,period ,"SquatU");
end;

if L[period-1]<L[period-2] and H[period-1]<=H[period-2] and (H[period-1]-L[period-1])==(H[period-2]-L[period-1]) and C[period-1]==O[period-1] and C[period-1]<C[period] and L[period-1]<=L[period] and Vol[period-1]>Vol[period-2] and Vol[period-1]<EHV[period-1] and Vol[period-1]>=UHV[period-1] then  
		Plot(HT2,period ,"SquatD");
end;


if H[period-1]>H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])==(H[period-2]-L[period-2]) and C[period-1]~=O[period-1] and C[period-1]==H[period-1] and C[period-1]>C[period] and H[period-1]>=H[period] and Vol[period-1]>Vol[period-2] and Vol[period-1]<EHV[period-1] and Vol[period-1]>=UHV[period-1] then  
	Plot(LT2,period ,"SquatU");
end;

if L[period-1]<L[period-2] and H[period-1]<=H[period-2] and (H[period-1]-L[period-1])==(H[period-2]-L[period-2]) and C[period-1]~=O[period-1] and C[period-1]==L[period-1] and C[period-1]<C[period] and L[period-1]<=L[period] and Vol[period-1]>Vol[period-2] and Vol[period-1]<EHV[period-1] and Vol[period-1]>=UHV[period-1] then  
		Plot2(HT,period ,"SquatD");
end;


if H[period-1]>H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])==(H[period-2]-L[period-2]) and C[period-1]~=O[period-1] and C[period-1]==((H[period-1]-L[period-1])*0.5)+L[period-1] and C[period-1]>C[period] and H[period-1]>=H[period] and Vol[period-1]>Vol[period-2] and Vol[period-1]<EHV[period-1] and Vol[period-1]>=UHV[period-1] then  
	Plot(LT2,period ,"SquatU");
end;

if L[period-1]<L[period-2] and H[period-1]<=H[period-2] and (H[period-1]-L[period-1])==(H[period-2]-L[period-2]) and C[period-1]~=O[period-1] and C[period-1]==((H[period-1]-L[period-1])*0.5)+L[period-1] and C[period-1]<C[period] and L[period-1]<=L[period] and Vol[period-1]>Vol[period-2] and Vol[period-1]<EHV[period-1] and Vol[period-1]>=UHV[period-1] then  
		Plot(HT2,period ,"SquatD");
end;


if H[period-1]>H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])==(H[period-2]-L[period-2]) and C[period-1]~=O[period-1] and C[period-1]==L[period-1] and C[period-1]>C[period] and H[period-1]>=H[period] and Vol[period-1]>Vol[period-2] and Vol[period-1]<EHV[period-1] and Vol[period-1]>=UHV[period-1] then  
	Plot(LT2,period ,"SquatU");
end;

if L[period-1]<L[period-2] and H[period-1]<=H[period-2] and (H[period-1]-L[period-1])==(H[period-2]-L[period-2]) and C[period-1]~=O[period-1] and C[period-1]==H[period-1] and C[period-1]<C[period] and L[period-1]<=L[period] and Vol[period-1]>Vol[period-2] and Vol[period-1]<EHV[period-1] and Vol[period-1]>=UHV[period-1] then  
		Plot(HT2,period ,"SquatD");
end;


if H[period-1]>H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]==O[period-1] and C[period-1]>C[period] and H[period-1]>=H[period] and Vol[period-1]>Vol[period-2] and Vol[period-1]<UHV[period-1] and Vol[period-1]>=SHV[period-1] then  
	Plot(LT2,period ,"SquatU");
end;

if L[period-1]<L[period-2] and H[period-1]<=H[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]==O[period-1] and C[period-1]<C[period] and L[period-1]<=L[period] and Vol[period-1]>Vol[period-2] and Vol[period-1]<UHV[period-1] and Vol[period-1]>=SHV[period-1] then  
		Plot(HT2,period ,"SquatD");
end;


if H[period-1]>H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]~=O[period-1] and C[period-1]==H[period-1] and C[period-1]>C[period] and H[period-1]>=H[period] and Vol[period-1]>Vol[period-2] and Vol[period-1]<UHV[period-1] and Vol[period-1]>=SHV[period-1] then  
	Plot(LT2,period ,"SquatU");
end;

if L[period-1]<L[period-2] and H[period-1]<=H[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]~=O[period-1] and C[period-1]==L[period-1] and C[period-1]<C[period] and L[period-1]<=L[period] and Vol[period-1]>Vol[period-2] and Vol[period-1]<UHV[period-1] and Vol[period-1]>=SHV[period-1] then  
		Plot(HT2,period ,"SquatD");
end;


if H[period-1]>H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]~=O[period-1] and C[period-1]==((H[period-1]-L[period-1])*0.5)+L[period-1] and C[period-1]>C[period] and H[period-1]>=H[period] and Vol[period-1]>Vol[period-2] and Vol[period-1]<UHV[period-1] and Vol[period-1]>=SHV[period-1] then  
	Plot(LT2,period ,"SquatU");
end;

if L[period-1]<L[period-2] and H[period-1]<=H[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]~=O[period-1] and C[period-1]==((H[period-1]-L[period-1])*0.5)+L[period-1] and C[period-1]<C[period] and L[period-1]<=L[period] and Vol[period-1]>Vol[period-2] and Vol[period-1]<UHV[period-1] and Vol[period-1]>=SHV[period-1] then  
		Plot(HT2,period ,"SquatD");
end;


if H[period-1]>H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]~=O[period-1] and C[period-1]==L[period-1] and C[period-1]>C[period] and H[period-1]>=H[period] and Vol[period-1]>Vol[period-2] and Vol[period-1]<UHV[period-1] and Vol[period-1]>=SHV[period-1] then  
	Plot(LT2,period ,"SquatU");
end;

if L[period-1]<L[period-2] and H[period-1]<=H[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]~=O[period-1] and C[period-1]==H[period-1] and C[period-1]<C[period] and L[period-1]<=L[period] and Vol[period-1]>Vol[period-2] and Vol[period-1]<UHV[period-1] and Vol[period-1]>=SHV[period-1] then  
		Plot(HT2,period ,"SquatD");
end;


if H[period-1]>H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])==(H[period-2]-L[period-2]) and C[period-1]==O[period-1] and C[period-1]==H[period-1] and C[period-1]>C[period] and H[period-1]>=H[period] and Vol[period-1]>Vol[period-2] and Vol[period-1]<UHV[period-1] and Vol[period-1]>=SHV[period-1] then  
	Plot(LT2,period ,"SquatU");
end;

if L[period-1]<L[period-2] and H[period-1]<=H[period-2] and (H[period-1]-L[period-1])==(H[period-2]-L[period-2]) and C[period-1]==O[period-1] and C[period-1]==L[period-1] and C[period-1]<C[period] and L[period-1]<=L[period] and Vol[period-1]>Vol[period-2] and Vol[period-1]<UHV[period-1] and Vol[period-1]>=SHV[period-1] then  
		Plot(HT2,period ,"SquatD");
end;


if H[period-1]>H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])==(H[period-2]-L[period-2]) and C[period-1]==O[period-1] and C[period-1]==((H[period-1]-L[period-1])*0.5)+L[period-1] and C[period-1]>C[period] and H[period-1]>=H[period] and Vol[period-1]>Vol[period-2] and Vol[period-1]<UHV[period-1] and Vol[period-1]>=SHV[period-1] then  
	Plot(LT2,period ,"SquatU"); 
end;

if L[period-1]<L[period-2] and H[period-1]<=H[period-2] and (H[period-1]-L[period-1])==(H[period-2]-L[period-2]) and C[period-1]==O[period-1] and C[period-1]==((H[period-1]-L[period-1])*0.5)+L[period-1] and C[period-1]<C[period] and L[period-1]<=L[period] and Vol[period-1]>Vol[period-2] and Vol[period-1]<UHV[period-1] and Vol[period-1]>=SHV[period-1]  then  
		Plot(HT2,period ,"SquatD");
end;


if H[period-1]>H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])==(H[period-2]-L[period-2]) and C[period-1]==O[period-1] and C[period-1]==L[period-1] and C[period-1]>C[period] and H[period-1]>=H[period] and Vol[period-1]>Vol[period-2] and Vol[period-1]<UHV[period-1] and Vol[period-1]>=SHV[period-1]  then  
	Plot(LT2,period ,"SquatU");
end;

if L[period-1]<L[period-2] and H[period-1]<=H[period-2] and (H[period-1]-L[period-1])==(H[period-2]-L[period-2]) and C[period-1]==O[period-1] and C[period-1]==H[period-1] and C[period-1]<C[period] and L[period-1]<=L[period] and Vol[period-1]>Vol[period-2] and Vol[period-1]<UHV[period-1] and Vol[period-1]>=SHV[period-1]  then  
		Plot(HT2,period ,"SquatD");
end;


if H[period-1]>H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]==O[period-1] and C[period-1]>C[period] and H[period-1]>=H[period] and Vol[period-1]>Vol[period-2] and Vol[period-1]<SHV[period-1] and Vol[period-1]>=HV[period-1] then  
	Plot(LT2,period ,"SquatU"); 
end;

if L[period-1]<L[period-2] and H[period-1]<=H[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]==O[period-1] and C[period-1]<C[period] and L[period-1]<=L[period] and Vol[period-1]>Vol[period-2] and Vol[period-1]<SHV[period-1] and Vol[period-1]>=HV[period-1] then  
		Plot(HT2,period ,"SquatD");
end;


if H[period-1]>H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]==O[period-1] and C[period-1]==H[period-1] and C[period-1]>C[period] and H[period-1]>=H[period] and Vol[period-1]>Vol[period-2] and Vol[period-1]<HV[period-1] then  
	Plot(LT2,period ,"SquatU");
end;

if L[period-1]<L[period-2] and H[period-1]<=H[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]==O[period-1] and C[period-1]==L[period-1] and C[period-1]<C[period] and L[period-1]<=L[period] and Vol[period-1]>Vol[period-2] and Vol[period-1]<HV[period-1] then  
		Plot(HT2,period ,"SquatD");
end;


if H[period-1]>H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]==O[period-1] and C[period-1]==((H[period-1]-L[period-1])*0.5)+L[period-1] and C[period-1]>C[period] and H[period-1]>=H[period] and Vol[period-1]>Vol[period-2] and Vol[period-1]<HV[period-1]  then  
	Plot(LT2,period ,"SquatU"); 
end;

if L[period-1]<L[period-2] and H[period-1]<=H[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]==O[period-1] and C[period-1]==((H[period-1]-L[period-1])*0.5)+L[period-1] and C[period-1]<C[period] and L[period-1]<=L[period] and Vol[period-1]>Vol[period-2] and Vol[period-1]<HV[period-1]  then  
		Plot(HT2,period ,"SquatD");
end;


if H[period-1]>H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]==O[period-1] and C[period-1]==L[period-1] and C[period-1]>C[period] and H[period-1]>=H[period] and Vol[period-1]>Vol[period-2] and Vol[period-1]<HV[period-1]   then  
	Plot(LT2,period ,"SquatU"); 
end;

if L[period-1]<L[period-2] and H[period-1]<=H[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]==O[period-1] and C[period-1]==H[period-1] and C[period-1]<C[period] and L[period-1]<=L[period] and Vol[period-1]>Vol[period-2] and Vol[period-1]<HV[period-1] then  
		Plot(HT2,period ,"SquatD");
end;


if H[period]<=H[period-1] and L[period]>=L[period-1] and (H[period]-L[period])<(H[period-1]-L[period-1]) and C[period]== O[period] and Vol[period]>Vol[period-1] and Vol[period]>=EHV[period] and C[period-1]>C[period-2] then  
	Plot(LT1,period,"SquatU");  
end;

if H[period]<=H[period-1] and L[period]>=L[period-1] and (H[period]-L[period])<(H[period-1]-L[period-1]) and C[period]== O[period] and Vol[period]>Vol[period-1] and Vol[period]>=EHV[period] and C[period-1]<C[period-2] then  
	Plot(HT1,period,"SquatD");
end;


if H[period]<=H[period-1] and L[period]>=L[period-1] and (H[period]-L[period])<(H[period-1]-L[period-1]) and C[period]~= O[period] and C[period]== H[period] and Vol[period]>Vol[period-1] and Vol[period]>=EHV[period] and C[period-1]>C[period-2] then  
	Plot(LT1,period,"SquatU"); 
end;

if H[period]<=H[period-1] and L[period]>=L[period-1] and (H[period]-L[period])<(H[period-1]-L[period-1]) and C[period]~= O[period] and C[period]== L[period] and Vol[period]>Vol[period-1] and Vol[period]>=EHV[period] and C[period-1]<C[period-2] then  
	Plot(HT1,period,"SquatD"); 
end;


if H[period]<=H[period-1] and L[period]>=L[period-1] and (H[period]-L[period])<(H[period-1]-L[period-1]) and C[period]~= O[period] and C[period]==((H[period]-L[period])*0.5)+L[period] and Vol[period]>Vol[period-1] and Vol[period]>=EHV[period] and C[period-1]>C[period-2] then  
	Plot(LT1,period,"SquatU");
end;

if H[period]<=H[period-1] and L[period]>=L[period-1] and (H[period]-L[period])<(H[period-1]-L[period-1]) and C[period]~= O[period] and C[period]==((H[period]-L[period])*0.5)+L[period] and Vol[period]>Vol[period-1] and Vol[period]>=EHV[period] and C[period-1]<C[period-2] then  
	Plot(HT1,period,"SquatD");
end;


if H[period]<=H[period-1] and L[period]>=L[period-1] and (H[period]-L[period])<(H[period-1]-L[period-1]) and C[period]~= O[period] and C[period]== L[period] and Vol[period]>Vol[period-1] and Vol[period]>=EHV[period] and C[period-1]>C[period-2] then  
	Plot(LT1,period,"SquatU");
end;

if H[period]<=H[period-1] and L[period]>=L[period-1] and (H[period]-L[period])<(H[period-1]-L[period-1]) and C[period]~= O[period] and C[period]== H[period] and Vol[period]>Vol[period-1] and Vol[period]>=EHV[period] and C[period-1]<C[period-2] then  
	Plot(HT1,period,"SquatD");
end;


if H[period-1]<=H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]==O[period-1] and C[period-1]>C[period] and H[period-1]>=H[period] and Vol[period-1]>Vol[period-2] and Vol[period-1]<EHV[period-1] and Vol[period-1]>=UHV[period-1] and C[period-2]>C[period-3] then  
	Plot(LT2,period ,"SquatU");
end;

if H[period-1]<=H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]==O[period-1] and C[period-1]<C[period] and L[period-1]<=L[period] and Vol[period-1]>Vol[period-2] and Vol[period-1]<EHV[period-1] and Vol[period-1]>=UHV[period-1] and C[period-2]<C[period-3] then  
		Plot(HT2,period ,"SquatD");
end;


if H[period-1]<=H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]~=O[period-1] and C[period-1]==H[period-1] and C[period-1]>C[period] and H[period-1]>=H[period] and Vol[period-1]>Vol[period-2] and Vol[period-1]<EHV[period-1] and Vol[period-1]>=UHV[period-1] and C[period-2]>C[period-3] then  
	Plot(LT2,period ,"SquatU");
end;

if H[period-1]<=H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]~=O[period-1] and C[period-1]==L[period-1] and C[period-1]<C[period] and L[period-1]<=L[period] and Vol[period-1]>Vol[period-2] and Vol[period-1]<EHV[period-1] and Vol[period-1]>=UHV[period-1] and C[period-2]<C[period-3] then  
		Plot(HT2,period ,"SquatD");
end;


if H[period-1]<=H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]~=O[period-1] and C[period-1]==((H[period-1]-L[period-1])*0.5)+L[period-1] and C[period-1]>C[period]and H[period-1]>=H[period] and Vol[period-1]>Vol[period-2] and Vol[period-1]<EHV[period-1] and Vol[period-1]>=UHV[period-1] and C[period-2]>C[period-3] then  
	Plot(LT2,period ,"SquatU"); 
end;

if H[period-1]<=H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]~=O[period-1] and C[period-1]==((H[period-1]-L[period-1])*0.5)+L[period-1] and C[period-1]<C[period] and L[period-1]<=L[period] and Vol[period-1]>Vol[period-2] and Vol[period-1]<EHV[period-1] and Vol[period-1]>=UHV[period-1] and C[period-2]<C[period-3] then  
		Plot(HT2,period ,"SquatD");
end;


if H[period-1]<=H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]~=O[period-1] and C[period-1]==L[period-1] and C[period-1]>C[period] and H[period-1]>=H[period] and Vol[period-1]>Vol[period-2] and Vol[period-1]<EHV[period-1] and Vol[period-1]>=UHV[period-1] and C[period-2]>C[period-3] then  
	Plot(LT2,period ,"SquatU");
end;

if H[period-1]<=H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]~=O[period-1] and C[period-1]==H[period-1] and C[period-1]<C[period] and L[period-1]<=L[period] and Vol[period-1]>Vol[period-2] and Vol[period-1]<EHV[period-1] and Vol[period-1]>=UHV[period-1] and C[period-2]<C[period-3] then  
		Plot(HT2,period ,"SquatD");
end;


if H[period-1]<=H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]==O[period-1] and C[period-1]>C[period] and H[period-1]>=H[period] and Vol[period-1]>Vol[period-2] and Vol[period-1]<UHV[period-1] and Vol[period-1]>=SHV[period-1] and C[period-2]>C[period-3] then  
	Plot(LT2,period ,"SquatU");
end;

if H[period-1]<=H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]==O[period-1] and C[period-1]<C[period] and L[period-1]<=L[period] and Vol[period-1]>Vol[period-2] and Vol[period-1]<UHV[period-1] and Vol[period-1]>=SHV[period-1] and C[period-2]<C[period-3] then  
		Plot(HT2,period ,"SquatD");
end;


if H[period-1]<=H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]==O[period-1] and C[period-1]==H[period-1] and C[period-1]>C[period] and H[period-1]>=H[period] and Vol[period-1]>Vol[period-2] and Vol[period-1]<UHV[period-1] and Vol[period-1]>=SHV[period-1] and C[period-2]>C[period-3] then  
	Plot(LT2,period ,"SquatU");
end;

if H[period-1]<=H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]==O[period-1] and C[period-1]==L[period-1] and C[period-1]<C[period] and L[period-1]<=L[period] and Vol[period-1]>Vol[period-2] and Vol[period-1]<UHV[period-1] and Vol[period-1]>=SHV[period-1] and C[period-2]<C[period-3] then  
		Plot(HT2,period ,"SquatD");
end;


if H[period-1]<=H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]==O[period-1] and C[period-1]==((H[period-1]-L[period-1])*0.5)+L[period-1] and C[period-1]>C[period] and H[period-1]>=H[period] and Vol[period-1]>Vol[period-2] and Vol[period-1]<UHV[period-1] and Vol[period-1]>=SHV[period-1] and C[period-2]>C[period-3]  then  
	Plot(LT2,period ,"SquatU");
end;

if H[period-1]<=H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]==O[period-1] and C[period-1]==((H[period-1]-L[period-1])*0.5)+L[period-1] and C[period-1]<C[period] and L[period-1]<=L[period] and Vol[period-1]>Vol[period-2] and Vol[period-1]<UHV[period-1] and Vol[period-1]>=SHV[period-1] and C[period-2]<C[period-3]   then  
		Plot(HT2,period ,"SquatD");
end;


if H[period-1]<=H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]==O[period-1] and C[period-1]==L[period-1] and C[period-1]>C[period] and H[period-1]>=H[period] and Vol[period-1]>Vol[period-2] and Vol[period-1]<UHV[period-1] and Vol[period-1]>=SHV[period-1] and C[period-2]>C[period-3]   then  
	Plot(LT2,period ,"SquatU");
end;

if H[period-1]<=H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]==O[period-1] and C[period-1]==H[period-1] and C[period-1]<C[period] and L[period-1]<=L[period] and Vol[period-1]>Vol[period-2] and Vol[period-1]<UHV[period-1] and Vol[period-1]>=SHV[period-1] and C[period-2]<C[period-3]  then  
		Plot(HT2,period ,"SquatD");
end;


if H[period-1]<=H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]==O[period-1] and C[period-1]==H[period-1] and C[period-1]>C[period-2] and C[period-1]>C[period] and H[period-1]>=H[period] and Vol[period-1]>Vol[period-2] and Vol[period-1]<UHV[period-1] and Vol[period-1]>=SHV[period-1] and C[period-2]>C[period-3] then  
	Plot(LT2,period ,"SquatU");
end;

if H[period-1]<=H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]==O[period-1] and C[period-1]==L[period-1] and C[period-1]<C[period-2] and C[period-1]<C[period] and L[period-1]<=L[period] and Vol[period-1]>Vol[period-2] and Vol[period-1]<UHV[period-1] and Vol[period-1]>=SHV[period-1] and C[period-2]<C[period-3] then  
		Plot(HT2,period ,"SquatD");
end;


if H[period-1]<=H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]==O[period-1] and C[period-1]==((H[period-1]-L[period-1])*0.5)+L[period-1] and C[period-1]>C[period-2] and C[period-1]>C[period] and H[period-1]>=H[period] and Vol[period-1]>Vol[period-2] and Vol[period-1]<UHV[period-1] and Vol[period-1]>=SHV[period-1] and C[period-2]>C[period-3]   then  
	Plot(LT2,period ,"SquatU");
end;

if H[period-1]<=H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]==O[period-1] and C[period-1]==((H[period-1]-L[period-1])*0.5)+L[period-1] and C[period-1]<C[period-2] and C[period-1]<C[period] and L[period-1]<=L[period] and Vol[period-1]>Vol[period-2] and Vol[period-1]<UHV[period-1] and Vol[period-1]>=SHV[period-1] and C[period-2]<C[period-3] then  
		Plot(HT ,period ,"SquatD");
end;


if H[period-1]<=H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]==O[period-1] and C[period-1]==L[period-1] and C[period-1]>C[period-2] and C[period-1]>C[period] and H[period-1]>=H[period] and Vol[period-1]>Vol[period-2] and Vol[period-1]<UHV[period-1] and Vol[period-1]>=SHV[period-1] and C[period-2]>C[period-3]   then 
	Plot(LT2,period ,"SquatU");
end;

if H[period-1]<=H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]==O[period-1] and C[period-1]==H[period-1] and C[period-1]<C[period-2] and C[period-1]<C[period] and L[period-1]<=L[period] and Vol[period-1]>Vol[period-2] and Vol[period-1]<UHV[period-1] and Vol[period-1]>=SHV[period-1] and C[period-2]<C[period-3]  then  
		Plot(HT2,period ,"SquatD");
end;
 
	
end


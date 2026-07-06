function Init()
    indicator:name("VSA No Demand No Supply");
    indicator:description("VSA No Demand No Supply");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addInteger("NumberofTicks", "Number of Ticks", "Number of Ticks", 0);
	
	indicator.parameters:addInteger("Size", "Label Size", "", 10, 1 , 100);
    indicator.parameters:addColor("NSLabelColor", "Color of NoSupply", "Color of Label", core.rgb(0, 255, 0));
	indicator.parameters:addColor("NDLabelColor", "Color of NoDemand", "Color of Label", core.rgb(255,0 , 0));
end

local NumberofTicks;

local first;
local source = nil;
local Size, NSLabelColor, NDLabelColor, font;

 local O,L,H,C,Vol;
 local open;
 
 local HT1,HT2,HT3,HT4;
 local LT1,LT2,LT3,LT4;
 
 function ReleaseInstance()
       core.host:execute("deleteFont", font);
end	   


function Prepare(nameOnly)
    NumberofTicks = instance.parameters.NumberofTicks;
    source = instance.source;
    first = source:first()+5;
	Size = instance.parameters.Size;
	NSLabelColor = instance.parameters.NSLabelColor;
	NDLabelColor = instance.parameters.NDLabelColor;
	
	font = core.host:execute("createFont", "Wingdings", Size, false, false);
 
	HT1 = instance:addInternalStream(first, 0);
	LT1 = instance:addInternalStream(first, 0);
	HT2 = instance:addInternalStream(first, 0);
	LT2 = instance:addInternalStream(first, 0);
	HT3 = instance:addInternalStream(first, 0);
	LT3 = instance:addInternalStream(first, 0);
	HT4 = instance:addInternalStream(first, 0);
	LT4 = instance:addInternalStream(first, 0);
	
	H=source.high;
    L=source.low;
	O=source.open;
	C=source.close;
	Vol=source.volume;
	

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(NumberofTicks) .. ")";
    instance:name(name); 
	
end

 function Plot(Data, period, Label)
 
    
	core.host:execute ("removeLabel", source:serial(period));

	
	 if Data[period]>= LT1[period] then
	 core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, Data[period], core.CR_CHART, core.H_Center, core.V_Top, font, NDLabelColor,  "\108");
	 else
	 core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, Data[period], core.CR_CHART, core.H_Center, core.V_Bottom, font, NSLabelColor,  "\108");
	 end 
	 
 end;

function Update(period)
    if period < first or not source:hasData(period) then
	return;
	end
	 
	HT1[period]=L[period] - NumberofTicks*source:pipSize();
    LT1[period]=H[period] + NumberofTicks*source:pipSize();
	
	HT2[period]=L[period] - 2*NumberofTicks*source:pipSize();
    LT2[period]=H[period] + 2*NumberofTicks*source:pipSize();
	
	HT3[period]=L[period] - 3*NumberofTicks*source:pipSize();
    LT3[period]=H[period] + 3*NumberofTicks*source:pipSize();
	
	HT4[period]=L[period] - 4*NumberofTicks*source:pipSize();
    LT4[period]=H[period] + 4*NumberofTicks*source:pipSize();

    core.host:execute("removeLabel", source:serial(period));
	
if H[period]>H[period-1] and L[period]>=L[period-1] and (H[period]-L[period])<(H[period-1]-L[period-1]) and C[period]==O[period] and C[period]==H[period] and C[period]>C[period-1] and Vol[period]<Vol[period-1]and Vol[period]<Vol[period-2] then  
	Plot(LT1,period,"NoDemand");	 
end; 


if L[period]<L[period-1] and H[period]<=H[period-1] and (H[period]-L[period])<(H[period-1]-L[period-1]) and C[period]==O[period] and C[period]==L[period] and C[period]<C[period-1] and Vol[period]<Vol[period-1]and Vol[period]<Vol[period-2] then  
	Plot(HT1,period,"NoSupply");	 
end; 


if H[period]>H[period-1] and L[period]>=L[period-1] and (H[period]-L[period])<(H[period-1]-L[period-1]) and C[period]==O[period] and C[period]==(((H[period]-L[period])*0.5)+L[period]) and C[period]>C[period-1] and Vol[period]<Vol[period-1] and Vol[period]<Vol[period-2]   then  
	Plot(LT1,period,"NoDemand"); 
end;


if L[period]<L[period-1] and H[period]<=H[period-1] and (H[period]-L[period])<(H[period-1]-L[period-1]) and C[period]==O[period] and C[period]==(((H[period]-L[period])*0.5)+L[period]) and C[period]<C[period-1] and Vol[period]<Vol[period-1] and Vol[period]<Vol[period-2]  then  
	Plot(HT1,period,"NoSupply"); 
end;



if H[period]>H[period-1] and L[period]>=L[period-1] and (H[period]-L[period])<(H[period-1]-L[period-1]) and C[period]==O[period] and C[period]==L[period] and C[period]>C[period-1] and Vol[period]<Vol[period-1] and Vol[period]<Vol[period-2]   then  
	Plot(LT1,period,"NoDemand"); 
end;

if L[period]<L[period-1] and H[period]<=H[period-1] and (H[period]-L[period])<(H[period-1]-L[period-1]) and C[period]==O[period] and C[period]==H[period] and C[period]<C[period-1] and Vol[period]<Vol[period-1] and Vol[period]<Vol[period-2]  then  
	Plot(HT1,period,"NoSupply"); 
end;


if H[period-1]>H[period-2] and L[period-1]>=L[period-2] and C[period-1]>C[period] and H[period-1]>=H[period] and Vol[period-1]<Vol[period-2] and Vol[period-1]<Vol[period-3] then  
	Plot(LT2,period,"NoDemand"); 
end;

if L[period-1]<L[period-2] and H[period-1]<=H[period-2] and C[period-1]<C[period] and L[period-1]<=L[period] and Vol[period-1]<Vol[period-2] and Vol[period-1]<Vol[period-3] then  
	Plot(HT2,period,"NoSupply"); 
end;


 

if H[period-2]>H[period-3] and L[period-2]>=L[period-3] and (H[period-2]-L[period-2])<(H[period-3]-L[period-3]) and C[period-2]==O[period-2] and C[period-2]>C[period-3] and C[period-2]==C[period-1] and C[period-2]>C[period] and H[period-2]>=H[period-1] and H[period-2]>=H[period] and Vol[period-2]<Vol[period-3] and Vol[period-2]<Vol[period-4] then  
	Plot(LT3,period,"NoDemand"); 
end;

if L[period-2]<L[period-3] and H[period-2]<=H[period-3] and (H[period-2]-L[period-2])<(H[period-3]-L[period-3]) and C[period-2]==O[period-2] and C[period-2]<C[period-3] and C[period-2]==C[period-1] and C[period-2]<C[period] and L[period-2]<=L[period-1] and L[period-2]<=L[period] and Vol[period-2]<Vol[period-3] and Vol[period-2]<Vol[period-4]   then  
	Plot(HT3,period,"NoSupply"); 
end;


if H[period-2]>H[period-3] and L[period-2]>=L[period-3] and (H[period-2]-L[period-2])<(H[period-3]-L[period-3]) and C[period-2]~=O[period-2] and C[period-2]==H[period-2] and C[period-2]>C[period-3] and C[period-2]==C[period-1] and C[period-2]>C[period] and H[period-2]>=H[period-1] and H[period-2]>=H[period] and Vol[period-2]<Vol[period-3] and Vol[period-2]<Vol[period-4] then   
	Plot(LT3,period,"NoDemand"); 
end;

if L[period-2]<L[period-3] and H[period-2]<=H[period-3] and (H[period-2]-L[period-2])<(H[period-3]-L[period-3]) and C[period-2]~=O[period-2] and C[period-2]==L[period-2] and C[period-2]<C[period-3] and C[period-2]==C[period-1] and C[period-2]<C[period] and L[period-2]<=L[period-1] and L[period-2]<=L[period] and Vol[period-2]<Vol[period-3] and Vol[period-2]<Vol[period-4] then  
	Plot(HT3,period,"NoSupply"); 
end;


if H[period-2]>H[period-3] and L[period-2]>=L[period-3] and (H[period-2]-L[period-2])<(H[period-3]-L[period-3]) and C[period-2]~=O[period-2] and C[period-2]==((H[period-2]-L[period-2])*0.5)+L[period-2] and C[period-2]>C[period-3] and C[period-2]==C[period-1] and C[period-2]>C[period] and H[period-2]>=H[period-1] and H[period-2]>=H[period] and Vol[period-2]<Vol[period-3] and Vol[period-2]<Vol[period-4] then  
	Plot(LT3,period,"NoDemand"); 
end;

if L[period-2]<L[period-3] and H[period-2]<=H[period-3] and (H[period-2]-L[period-2])<(H[period-3]-L[period-3]) and C[period-2]~=O[period-2] and C[period-2]==((H[period-2]-L[period-2])*0.5)+L[period-2] and C[period-2]<C[period-3] and C[period-2]==C[period-1] and C[period-2]<C[period] and L[period-2]<=L[period-1] and L[period-2]<=L[period] and Vol[period-2]<Vol[period-3] and Vol[period-2]<Vol[period-4] then  
	Plot(HT3,period,"NoSupply"); 
end;


if H[period-2]>H[period-3] and L[period-2]>=L[period-3] and (H[period-2]-L[period-2])<(H[period-3]-L[period-3]) and C[period-2]~=O[period-2] and C[period-2]==L[period-2] and C[period-2]>C[period-3] and C[period-2]==C[period-1] and C[period-2]>C[period] and H[period-2]>=H[period-1] and H[period-2]>=H[period] and Vol[period-2]<Vol[period-3] and Vol[period-2]<Vol[period-4] then  
	Plot(LT3,period,"NoDemand"); 
end;

if L[period-2]<L[period-3] and H[period-2]<=H[period-3] and (H[period-2]-L[period-2])<(H[period-3]-L[period-3]) and C[period-2]~=O[period-2] and C[period-2]==H[period-2] and C[period-2]<C[period-3] and C[period-2]==C[period-1] and C[period-2]<C[period] and L[period-2]<=L[period-1] and L[period-2]<=L[period] and Vol[period-2]<Vol[period-3] and Vol[period-2]<Vol[period-4] then  
	Plot(HT3,period,"NoSupply"); 
end;


if H[period-3]>H[period-4] and L[period-3]>=L[period-4] and (H[period-3]-L[period-3])<(H[period-4]-L[period-4]) and C[period-3]==O[period-3] and C[period-3]==H[period-3] and C[period-3]>C[period-4] and C[period-3]==C[period-2] and C[period-3]==C[period-1] and C[period-3]>C[period] and H[period-3]>=H[period-2] and H[period-3]>=H[period-1] and H[period-3]>=H[period] and Vol[period-3]<Vol[period-4] and Vol[period-3]<Vol[period-5] then  
	Plot(LT4,period,"NoDemand"); 
end;

if L[period-3]<L[period-4] and H[period-3]<=H[period-4] and (H[period-3]-L[period-3])<(H[period-4]-L[period-4]) and C[period-3]==O[period-3] and C[period-3]==L[period-3] and C[period-3]<C[period-4] and C[period-3]==C[period-2] and C[period-3]==C[period-1] and C[period-3]<C[period] and L[period-3]<=L[period-2] and L[period-3]<=L[period-1] and L[period-3]<=L[period] and Vol[period-3]<Vol[period-4] and Vol[period-3]<Vol[period-5]  then  
	Plot(HT4,period,"NoSupply"); 
end;


if H[period-3]>H[period-4] and L[period-3]>=L[period-4] and (H[period-3]-L[period-3])<(H[period-4]-L[period-4]) and C[period-3]==O[period-3] and C[period-3]==((H[period-3]-L[period-3])*0.5)+L[period-3] and C[period-3]>C[period-4] and C[period-3]==C[period-2] and C[period-3]==C[period-1] and C[period-3]>C[period] and H[period-3]>=H[period-2] and H[period-3]>=H[period-1] and H[period-3]>=H[period] and Vol[period-3]<Vol[period-4] and Vol[period-3]<Vol[period-5]  then  
	Plot(LT4,period,"NoDemand"); 
end;

if L[period-3]<L[period-4] and H[period-3]<=H[period-4] and (H[period-3]-L[period-3])<(H[period-4]-L[period-4]) and C[period-3]==O[period-3] and C[period-3]==((H[period-3]-L[period-3])*0.5)+L[period-3] and C[period-3]<C[period-4] and C[period-3]==C[period-2] and C[period-3]==C[period-1] and C[period-3]<C[period] and L[period-3]<=L[period-2] and L[period-3]<=L[period-1] and L[period-3]<=L[period] and Vol[period-3]<Vol[period-4] and Vol[period-3]<Vol[period-5]  then  
	Plot(HT4,period,"NoSupply"); 
end;


if H[period-3]>H[period-4] and L[period-3]>=L[period-4] and (H[period-3]-L[period-3])<(H[period-3]-L[period-3]) and C[period-3]==O[period-3] and C[period-3]==L[period-3] and C[period-3]>C[period-4] and C[period-3]==C[period-2] and C[period-3]==C[period-1] and C[period-3]>C[period] and H[period-3]>=H[period-2] and H[period-3]>=H[period-1] and H[period-3]>=H[period] and Vol[period-3]<Vol[period-4] and Vol[period-3]<Vol[period-5] then  
	Plot(LT4,period,"NoDemand"); 
end;

if L[period-3]<L[period-4] and H[period-3]<=H[period-4] and (H[period-3]-L[period-3])<(H[period-3]-L[period-3]) and C[period-3]==O[period-3] and C[period-3]==H[period-3] and C[period-3]<C[period-4] and C[period-3]==C[period-2] and C[period-3]==C[period-1] and C[period-3]<C[period] and L[period-3]<=L[period-2] and L[period-3]<=L[period-1] and L[period-3]<=L[period] and Vol[period-3]<Vol[period-4] and Vol[period-3]<Vol[period-5]   then  
	Plot(HT4,period,"NoSupply"); 
end;


if H[period]<=H[period-1] and L[period]>=L[period-1] and (H[period]-L[period])<(H[period-1]-L[period-1]) and C[period]==O[period] and C[period]==H[period] and C[period]>C[period-1] and Vol[period]<Vol[period-1] and Vol[period]<Vol[period-2] then  
	Plot(LT1,period,"NoDemand"); 
end;

if H[period]<=H[period-1] and L[period]>=L[period-1] and (H[period]-L[period])<(H[period-1]-L[period-1]) and C[period]==O[period] and C[period]==L[period] and C[period]<C[period-1] and Vol[period]<Vol[period-1] and Vol[period]<Vol[period-2] then  
	Plot(HT1,period,"NoSupply"); 
end;


if H[period]<=H[period-1] and L[period]>=L[period-1] and (H[period]-L[period])<(H[period-1]-L[period-1]) and C[period]==O[period] and C[period]==((H[period]-L[period])*0.5)+L[period] and C[period]>C[period-1] and Vol[period]<Vol[period-1] and Vol[period]<Vol[period-2]  then  
	Plot(LT1,period,"NoDemand"); 
end;

if H[period]<=H[period-1] and L[period]>=L[period-1] and (H[period]-L[period])<(H[period-1]-L[period-1]) and C[period]==O[period] and C[period]==((H[period]-L[period])*0.5)+L[period] and C[period]<C[period-1] and Vol[period]<Vol[period-1] and Vol[period]<Vol[period-2] then  
	Plot(HT1,period,"NoSupply"); 
end;


if H[period]<=H[period-1] and L[period]>=L[period-1] and (H[period]-L[period])<(H[period-1]-L[period-1]) and C[period]==O[period] and C[period]==L[period] and C[period]>C[period-1] and Vol[period]<Vol[period-1] and Vol[period]<Vol[period-2]   then  
	Plot(LT1,period,"NoDemand"); 
end;

if H[period]<=H[period-1] and L[period]>=L[period-1] and (H[period]-L[period])<(H[period-1]-L[period-1]) and C[period]==O[period] and C[period]==H[period] and C[period]<C[period-1] and Vol[period]<Vol[period-1] and Vol[period]<Vol[period-2]  then  
	Plot(HT1,period,"NoSupply"); 
end;


if H[period-1]<=H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]>C[period-2] and C[period-1]>C[period] and H[period-1]>=H[period] and Vol[period-1]<Vol[period-2] and Vol[period-1]<Vol[period-3] then  
	Plot(LT2,period,"NoDemand"); 
end;

if H[period-1]<=H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]<C[period-2] and C[period-1]<C[period] and L[period-1]<=L[period] and Vol[period-1]<Vol[period-2] and Vol[period-1]<Vol[period-3] then  
	Plot(HT2,period,"NoSupply"); 
end;


if H[period-2]<=H[period-3] and L[period-2]>=L[period-3] and (H[period-2]-L[period-2])<(H[period-3]-L[period-3]) and C[period-2]==O[period-2] and C[period-2]>C[period-3] and C[period-2]==C[period-1] and C[period-2]>C[period] and H[period-2]>=H[period-1] and H[period-2]>=H[period] and Vol[period-2]<Vol[period-3] and Vol[period-2]<Vol[period-4]  then  
	Plot(LT3,period,"NoDemand"); 
end;

if H[period-2]<=H[period-3] and L[period-2]>=L[period-3] and (H[period-2]-L[period-2])<(H[period-3]-L[period-3]) and C[period-2]==O[period-2] and C[period-2]<C[period-3] and C[period-2]==C[period-1] and C[period-2]<C[period] and L[period-2]<=L[period-1] and L[period-2]<=L[period] and Vol[period-2]<Vol[period-3] and Vol[period-2]<Vol[period-4]  then  
	Plot(HT3,period,"NoSupply"); 
end;


if H[period-2]<=H[period-3] and L[period-2]>=L[period-3] and (H[period-2]-L[period-2])<(H[period-3]-L[period-3]) and C[period-2]~=O[period-2] and C[period-2]==H[period-2] and C[period-2]>C[period-3] and C[period-2]==C[period-1] and C[period-2]>C[period] and H[period-2]>=H[period-1] and H[period-2]>=H[period] and Vol[period-2]<Vol[period-3] and Vol[period-2]<Vol[period-4] then  
	Plot(LT3,period,"NoDemand"); 
end;

if H[period-2]<=H[period-3] and L[period-2]>=L[period-3] and (H[period-2]-L[period-2])<(H[period-3]-L[period-3]) and C[period-2]~=O[period-2] and C[period-2]==L[period-2] and C[period-2]<C[period-3] and C[period-2]==C[period-1] and C[period-2]<C[period] and L[period-2]<=L[period-1] and L[period-2]<=L[period] and Vol[period-2]<Vol[period-3] and Vol[period-2]<Vol[period-4] then  
	Plot(HT3,period,"NoSupply"); 
end;


if H[period-2]<=H[period-3] and L[period-2]>=L[period-3] and (H[period-2]-L[period-2])<(H[period-3]-L[period-3]) and C[period-2]~=O[period-2] and C[period-2]==((H[period-2]-L[period-2])*0.5)+L[period-2] and C[period-2]>C[period-3] and C[period-2]==C[period-1] and C[period-2]>C[period] and H[period-2]>=H[period-1] and H[period-2]>=H[period] and Vol[period-2]<Vol[period-3] and Vol[period-2]<Vol[period-4] then  
	Plot(LT3,period,"NoDemand"); 
end;

if H[period-2]<=H[period-3] and L[period-2]>=L[period-3] and (H[period-2]-L[period-2])<(H[period-3]-L[period-3]) and C[period-2]~=O[period-2] and C[period-2]==((H[period-2]-L[period-2])*0.5)+L[period-2] and C[period-2]<C[period-3] and C[period-2]==C[period-1] and C[period-2]<C[period] and L[period-2]<=L[period-1] and L[period-2]<=L[period] and Vol[period-2]<Vol[period-3] and Vol[period-2]<Vol[period-4] then  
	Plot(HT3,period,"NoSupply"); 
end;


if H[period-2]<=H[period-3] and L[period-2]>=L[period-3] and (H[period-2]-L[period-2])<(H[period-3]-L[period-3]) and C[period-2]~=O[period-2] and C[period-2]==L[period-2] and C[period-2]>C[period-3] and C[period-2]==C[period-1] and C[period-2]>C[period] and H[period-2]>=H[period-1] and H[period-2]>=H[period] and Vol[period-2]<Vol[period-3] and Vol[period-2]<Vol[period-4] then  
	Plot(LT3,period,"NoDemand"); 
end;

if H[period-2]<=H[period-3] and L[period-2]>=L[period-3] and (H[period-2]-L[period-2])<(H[period-3]-L[period-3]) and C[period-2]~=O[period-2] and C[period-2]==H[period-2] and C[period-2]<C[period-3] and C[period-2]==C[period-1] and C[period-2]<C[period] and L[period-2]<=L[period-1] and L[period-2]<=L[period] and Vol[period-2]<Vol[period-3] and Vol[period-2]<Vol[period-4] then  
	Plot(HT3,period,"NoSupply"); 
end;


if H[period-3]<=H[period-4] and L[period-3]>=L[period-4] and (H[period-3]-L[period-3])<(H[period-4]-L[period-4]) and C[period-3]==O[period-3] and C[period-3]==H[period-3] and C[period-3]>C[period-4] and C[period-3]==C[period-2] and C[period-3]==C[period-1] and C[period-3]>C[period] and H[period-3]>=H[period-2] and H[period-3]>=H[period-1] and H[period-3]>=H[period] and Vol[period-3]<Vol[period-4] and Vol[period-3]<Vol[period-5]  then  
	Plot(LT4,period,"NoDemand"); 
end;

if H[period-3]<=H[period-4] and L[period-3]>=L[period-4] and (H[period-3]-L[period-3])<(H[period-4]-L[period-4]) and C[period-3]==O[period-3] and C[period-3]==L[period-3] and C[period-3]<C[period-4] and C[period-3]==C[period-2] and C[period-3]==C[period-1] and C[period-3]<C[period] and L[period-3]<=L[period-2] and L[period-3]<=L[period-1] and L[period-3]<=L[period] and Vol[period-3]<Vol[period-4] and Vol[period-3]<Vol[period-5]   then  
	Plot(HT4,period,"NoSupply"); 
end;


if H[period-3]<=H[period-4] and L[period-3]>=L[period-4] and (H[period-3]-L[period-3])<(H[period-4]-L[period-4]) and C[period-3]==O[period-3] and C[period-3]==((H[period-3]-L[period-3])*0.5)+L[period-3] and C[period-3]>C[period-4] and C[period-3]==C[period-2] and C[period-3]==C[period-1] and C[period-3]>C[period] and H[period-3]>=H[period-2] and H[period-3]>=H[period-1] and H[period-3]>=H[period] and Vol[period-3]<Vol[period-4] and Vol[period-3]<Vol[period-5]  then  
	Plot(LT4,period,"NoDemand"); 
end;

if H[period-3]<=H[period-4] and L[period-3]>=L[period-4] and (H[period-3]-L[period-3])<(H[period-4]-L[period-4]) and C[period-3]==O[period-3] and C[period-3]==((H[period-3]-L[period-3])*0.5)+L[period-3] and C[period-3]<C[period-4] and C[period-3]==C[period-2] and C[period-3]==C[period-1] and C[period-3]<C[period] and L[period-3]<=L[period-2] and L[period-3]<=L[period-1] and L[period-3]<=L[period] and Vol[period-3]<Vol[period-4] and Vol[period-3]<Vol[period-5]  then  
	Plot(HT4,period,"NoSupply"); 
end;


if H[period-3]<=H[period-4] and L[period-3]>=L[period-4] and (H[period-3]-L[period-3])<(H[period-4]-L[period-4]) and C[period-3]==O[period-3] and C[period-3]==L[period-3] and C[period-3]>C[period-4] and C[period-3]==C[period-2] and C[period-3]==C[period-1] and C[period-3]>C[period] and H[period-3]>=H[period-2] and H[period-3]>=H[period-1] and H[period-3]>=H[period] and Vol[period-3]<Vol[period-4] and Vol[period-3]<Vol[period-5]  then  
	Plot(LT4,period,"NoDemand"); 
end;

if H[period-3]<=H[period-4] and L[period-3]>=L[period-4] and (H[period-3]-L[period-3])<(H[period-4]-L[period-4]) and C[period-3]==O[period-3] and C[period-3]==H[period-3] and C[period-3]<C[period-4] and C[period-3]==C[period-2] and C[period-3]==C[period-1] and C[period-3]<C[period] and L[period-3]<=L[period-2] and L[period-3]<=L[period-1] and L[period-3]<=L[period] and Vol[period-3]<Vol[period-4] and Vol[period-3]<Vol[period-5]   then  
	Plot(HT4,period,"NoSupply"); 
end;


if H[period-1]<=H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])==(H[period-2]-L[period-2]) and C[period-1]==O[period-1] and C[period-1]>C[period-2] and C[period-1]>C[period] and H[period-1]>=H[period] and Vol[period-1]<Vol[period-2] and Vol[period-1]<Vol[period-3] then  
	Plot(LT2,period,"NoDemand"); 
end;

if H[period-1]<=H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])==(H[period-2]-L[period-2]) and C[period-1]==O[period-1] and C[period-1]<C[period-2] and C[period-1]<C[period] and L[period-1]<=L[period] and Vol[period-1]<Vol[period-2] and Vol[period-1]<Vol[period-3] then  
	Plot(HT2,period,"NoSupply"); 
end;


if H[period-1]<=H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])==(H[period-2]-L[period-2]) and C[period-1]~=O[period-1] and C[period-1]==H[period-1] and C[period-1]>C[period-2] and C[period-1]>C[period] and H[period-1]>=H[period] and Vol[period-1]<Vol[period-2] and Vol[period-1]<Vol[period-3] then  
	Plot(LT2,period,"NoDemand"); 
end;

if H[period-1]<=H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])==(H[period-2]-L[period-2]) and C[period-1]~=O[period-1] and C[period-1]==L[period-1] and C[period-1]<C[period-2] and C[period-1]<C[period] and L[period-1]<=L[period] and Vol[period-1]<Vol[period-2] and Vol[period-1]<Vol[period-3] then  
	Plot(HT2,period,"NoSupply"); 
end;


if H[period-1]<=H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])==(H[period-2]-L[period-2]) and C[period-1]~=O[period-1] and C[period-1]==((H[period-1]-L[period-1])*0.5)+L[period-1] and C[period-1]>C[period-2] and C[period-1]>C[period] and H[period-1]>=H[period] and Vol[period-1]<Vol[period-2] and Vol[period-1]<Vol[period-3] then  
	Plot(LT2,period,"NoDemand"); 
end;

if H[period-1]<=H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])==(H[period-2]-L[period-2]) and C[period-1]~=O[period-1] and C[period-1]==((H[period-1]-L[period-1])*0.5)+L[period-1] and C[period-1]<C[period-2] and C[period-1]<C[period] and L[period-1]<=L[period] and Vol[period-1]<Vol[period-2] and Vol[period-1]<Vol[period-3] then  
	Plot(HT2,period,"NoSupply"); 
end;


if H[period-2]<=H[period-3] and L[period-2]>=L[period-3] and (H[period-2]-L[period-2])==(H[period-3]-L[period-3]) and C[period-2]==O[period-2] and C[period-2]==H[period-2] and C[period-2]>C[period-3] and C[period-2]==C[period-1] and C[period-2]>C[period] and H[period-2]>=H[period-1] and H[period-2]>=H[period] and Vol[period-2]<Vol[period-3] and Vol[period-2]<Vol[period-4] then  
	Plot(LT3,period,"NoDemand"); 
end;

if H[period-2]<=H[period-3] and L[period-2]>=L[period-3] and (H[period-2]-L[period-2])==(H[period-3]-L[period-3]) and C[period-2]==O[period-2] and C[period-2]==L[period-2] and C[period-2]<C[period-3] and C[period-2]==C[period-1] and C[period-2]<C[period] and L[period-2]<=L[period-1] and L[period-2]<=L[period] and Vol[period-2]<Vol[period-3] and Vol[period-2]<Vol[period-4] then  
	Plot(HT3,period,"NoSupply"); 
end;


if H[period-2]<=H[period-3] and L[period-2]>=L[period-3] and (H[period-2]-L[period-2])==(H[period-3]-L[period-3]) and C[period-2]==O[period-2] and C[period-2]==((H[period-2]-L[period-2])*0.5)+L[period-2] and C[period-2]>C[period-3] and C[period-2]==C[period-1] and C[period-2]>C[period] and H[period-2]>=H[period-1] and H[period-2]>=H[period] and Vol[period-2]<Vol[period-3] and Vol[period-2]<Vol[period-4]   then  
	Plot(LT3,period,"NoDemand"); 
end;

if H[period-2]<=H[period-3] and L[period-2]>=L[period-3] and (H[period-2]-L[period-2])==(H[period-3]-L[period-3]) and C[period-2]==O[period-2] and C[period-2]==((H[period-2]-L[period-2])*0.5)+L[period-2] and C[period-2]<C[period-3] and C[period-2]==C[period-1] and C[period-2]<C[period] and L[period-2]<=L[period-1] and L[period-2]<=L[period] and Vol[period-2]<Vol[period-3] and Vol[period-2]<Vol[period-4]  then  
	Plot(HT3,period,"NoSupply"); 
end;


if H[period-1]<=H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]==O[period-1] and C[period-1]==C[period-2] and C[period-1]>C[period] and H[period-1]>=H[period] and Vol[period-1]<Vol[period-2] and Vol[period-1]<Vol[period-3] and C[period-2]>C[period-3] then  
	Plot(LT2,period,"NoDemand"); 
end;

if H[period-1]<=H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]==O[period-1] and C[period-1]==C[period-2] and C[period-1]<C[period] and L[period-1]<=L[period] and Vol[period-1]<Vol[period-2] and Vol[period-1]<Vol[period-3] and C[period-2]<C[period-3] then  
	Plot(HT2,period,"NoSupply"); 
end;


if H[period-1]<=H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]~=O[period-1] and C[period-1]==H[period-1] and C[period-1]==C[period-2] and C[period-1]>C[period] and H[period-1]>=H[period] and Vol[period-1]<Vol[period-2] and Vol[period-1]<Vol[period-3] and C[period-2]>C[period-3] then  
	Plot(LT2,period,"NoDemand"); 
end;

if H[period-1]<=H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]~=O[period-1] and C[period-1]==L[period-1] and C[period-1]==C[period-2] and C[period-1]<C[period] and L[period-1]<=L[period] and Vol[period-1]<Vol[period-2] and Vol[period-1]<Vol[period-3] and C[period-2]<C[period-3] then  
	Plot(HT2,period,"NoSupply"); 
end;


if H[period-1]<=H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]~=O[period-1] and C[period-1]==((H[period-1]-L[period-1])*0.5)+L[period-1] and C[period-1]==C[period-2] and C[period-1]>C[period] and H[period-1]>=H[period] and Vol[period-1]<Vol[period-2] and Vol[period-1]<Vol[period-3] and C[period-2]>C[period-3] then  
	Plot(LT2,period,"NoDemand"); 
end;

if H[period-1]<=H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1] ~=O[period-1] and C[period-1]==((H[period-1]-L[period-1])*0.5)+L[period-1] and C[period-1]==C[period-2] and C[period-1]<C[period] and L[period-1]<=L[period] and Vol[period-1]<Vol[period-2] and Vol[period-1]<Vol[period-3] and C[period-2]<C[period-3] then  
	Plot(HT2,period,"NoSupply"); 
end;


if H[period-1]<=H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]~=O[period-1] and C[period-1]==L[period-1] and C[period-1]==C[period-2] and C[period-1]>C[period] and H[period-1]>=H[period] and Vol[period-1]<Vol[period-2] and Vol[period-1]<Vol[period-3] and C[period-2]>C[period-3] then  
	Plot(LT2,period,"NoDemand"); 
end;

if H[period-1]<=H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]~=O[period-1] and C[period-1]==H[period-1] and C[period-1]==C[period-2] and C[period-1]<C[period] and L[period-1]<=L[period] and Vol[period-1]<Vol[period-2] and Vol[period-1]<Vol[period-3] and C[period-2]<C[period-3] then  
	Plot(HT2,period,"NoSupply"); 
end;


if H[period-2]<=H[period-3] and L[period-2]>=L[period-3] and (H[period-2]-L[period-2])<(H[period-3]-L[period-3]) and C[period-2]==O[period-2] and C[period-2]==((H[period-2]-L[period-2])*0.5)+L[period-2] and C[period-2]==C[period-3] and C[period-2]==C[period-1] and C[period-2]>C[period] and H[period-2]>=H[period-1] and H[period-2]>=H[period] and Vol[period-2]<Vol[period-3] and Vol[period-2]<Vol[period-4] and C[period-3]>C[period-4] then  
	Plot(LT3,period,"NoDemand"); 
end;

if H[period-2]<=H[period-3] and L[period-2]>=L[period-3] and (H[period-2]-L[period-2])<(H[period-3]-L[period-3]) and C[period-2]==O[period-2] and C[period-2]==((H[period-2]-L[period-2])*0.5)+L[period-2] and C[period-2]==C[period-3] and C[period-2]==C[period-1] and C[period-2]<C[period] and L[period-2]<=L[period-1] and L[period-2]<=L[period] and Vol[period-2]<Vol[period-3] and Vol[period-2]<Vol[period-4] and C[period-3]<C[period-4] then  
	Plot(HT3,period,"NoSupply"); 
end;


if H[period-2]<=H[period-3] and L[period-2]>=L[period-3] and (H[period-2]-L[period-2])<(H[period-3]-L[period-3]) and C[period-2]==O[period-2] and C[period-2]==L[period-2] and C[period-2]==C[period-3] and C[period-2]==C[period-1] and C[period-2]>C[period] and H[period-2]>=H[period-1] and H[period-2]>=H[period] and Vol[period-2]<Vol[period-3] and Vol[period-2]<Vol[period-4] and C[period-3]>C[period-4]   then  
	Plot(LT3,period,"NoDemand"); 
end;

if H[period-2]<=H[period-3] and L[period-2]>=L[period-3] and (H[period-2]-L[period-2])<(H[period-3]-L[period-3]) and C[period-2]==O[period-2] and C[period-2]==H[period-2] and C[period-2]==C[period-3] and C[period-2]==C[period-1] and C[period-2]<C[period] and L[period-2]<=L[period-1] and L[period-2]<=L[period] and Vol[period-2]<Vol[period-3] and Vol[period-2]<Vol[period-4] and C[period-3]<C[period-4]  then  
	Plot(HT3,period,"NoSupply"); 
end;


if H[period-1]<=H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])==(H[period-2]-L[period-2]) and C[period-1]==O[period-1] and C[period-1]==H[period-1] and C[period-1]==C[period-2] and C[period-1]>C[period] and H[period-1]>=H[period] and Vol[period-1]<Vol[period-2] and Vol[period-1]<Vol[period-3] and C[period-2]>C[period-3] then  
	Plot(LT2,period,"NoDemand"); 
end;

if H[period-1]<=H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])==(H[period-2]-L[period-2]) and C[period-1]==O[period-1] and C[period-1]==L[period-1] and C[period-1]==C[period-2] and C[period-1]<C[period] and L[period-1]<=L[period] and Vol[period-1]<Vol[period-2] and Vol[period-1]<Vol[period-3] and C[period-2]<C[period-3] then  
	Plot(HT2,period,"NoSupply"); 
end;


if H[period-1]<=H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])==(H[period-2]-L[period-2]) and C[period-1]==O[period-1] and C[period-1]==((H[period-1]-L[period-1])*0.5)+L[period-1] and C[period-1]==C[period-2] and C[period-1]>C[period] and H[period-1]>=H[period] and Vol[period-1]<Vol[period-2] and Vol[period-1]<Vol[period-3] and C[period-2]>C[period-3]  then  
	Plot(LT2,period,"NoDemand"); 
end;

if H[period-1]<=H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])==(H[period-2]-L[period-2]) and C[period-1]==O[period-1] and C[period-1]==((H[period-1]-L[period-1])*0.5)+L[period-1] and C[period-1]==C[period-2] and C[period-1]<C[period] and L[period-1]<=L[period] and Vol[period-1]<Vol[period-2] and Vol[period-1]<Vol[period-3] and C[period-2]<C[period-3]   then  
	Plot(HT2,period,"NoSupply"); 
end;


if H[period-1]<=H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])==(H[period-2]-L[period-2]) and C[period-1]==O[period-1] and C[period-1]==L[period-1] and C[period-1]==C[period-2] and C[period-1]>C[period] and H[period-1]>=H[period] and Vol[period-1]<Vol[period-2] and Vol[period-1]<Vol[period-3] and C[period-2]>C[period-3]   then  
	Plot(LT2,period,"NoDemand"); 
end;

if H[period-1]<=H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])==(H[period-2]-L[period-2]) and C[period-1]==O[period-1] and C[period-1]==H[period-1] and C[period-1]==C[period-2] and C[period-1]<C[period] and L[period-1]<=L[period] and Vol[period-1]<Vol[period-2] and Vol[period-1]<Vol[period-3] and C[period-2]<C[period-3]   then  
	Plot(HT2,period,"NoSupply"); 
end;


if H[period-1]>H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]==O[period-1] and C[period-1]>C[period-2] and C[period-1]>C[period] and H[period-1]>=H[period] and Vol[period-1]==Vol[period-2] and Vol[period-1]<=Vol[period-3] then  
	Plot(LT2,period,"NoDemand"); 
end;

if L[period-1]<L[period-2] and H[period-1]<=H[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]==O[period-1] and C[period-1]<C[period-2] and C[period-1]<C[period] and L[period-1]<=L[period] and Vol[period-1]==Vol[period-2] and Vol[period-1]<=Vol[period-3] then  
	Plot(HT2,period,"NoSupply"); 
end;


if H[period-1]>H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]~=O[period-1] and C[period-1]==H[period-1] and C[period-1]>C[period-2] and C[period-1]>C[period] and H[period-1]>=H[period] and Vol[period-1]==Vol[period-2] and Vol[period-1]<=Vol[period-3] then  
	Plot(LT2,period,"NoDemand"); 
end;

 

if L[period-1]<L[period-2] and H[period-1]<=H[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]~=O[period-1] and C[period-1]==L[period-1] and C[period-1]<C[period-2] and C[period-1]<C[period] and L[period-1]<=L[period] and Vol[period-1]==Vol[period-2] and Vol[period-1]<=Vol[period-3] then  
	Plot(HT2,period,"NoSupply"); 
end; 

if H[period-1]>H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]~=O[period-1] and C[period-1]==((H[period-1]-L[period-1])*0.5)+L[period-1] and C[period-1]>C[period-2] and C[period-1]>C[period] and H[period-1]>=H[period] and Vol[period-1]==Vol[period-2] and Vol[period-1]<=Vol[period-3] then   
	Plot(LT2,period,"NoDemand"); 
end;

if L[period-1]<L[period-2] and H[period-1]<=H[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]~=O[period-1] and C[period-1]==((H[period-1]-L[period-1])*0.5)+L[period-1] and C[period-1]<C[period-2] and C[period-1]<C[period] and L[period-1]<=L[period] and Vol[period-1]==Vol[period-2] and Vol[period-1]<=Vol[period-3] then  
	Plot(HT2,period,"NoSupply"); 
end;


if H[period-1]>H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]~=O[period-1] and C[period-1]==L[period-1] and C[period-1]>C[period-2] and C[period-1]>C[period] and H[period-1]>=H[period] and Vol[period-1]==Vol[period-2] and Vol[period-1]<=Vol[period-3] then  
	Plot(LT2,period,"NoDemand"); 
end;

if L[period-1]<L[period-2] and H[period-1]<=H[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]~=O[period-1] and C[period-1]==H[period-1] and C[period-1]<C[period-2] and C[period-1]<C[period] and L[period-1]<=L[period] and Vol[period-1]==Vol[period-2] and Vol[period-1]<=Vol[period-3] then  
	Plot(HT2,period,"NoSupply"); 
end;


if H[period-1]>H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]==O[period-1] and C[period-1]>C[period-2] and C[period-1]>C[period] and H[period-1]>=H[period] and Vol[period-1]<Vol[period-2] and Vol[period-1]==Vol[period-3] then  
	Plot(LT2,period,"NoDemand"); 
end;

if L[period-1]<L[period-2] and H[period-1]<=H[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]==O[period-1] and C[period-1]<C[period-2] and C[period-1]<C[period] and L[period-1]<=L[period] and Vol[period-1]<Vol[period-2] and Vol[period-1]==Vol[period-3] then  
	Plot(HT2,period,"NoSupply"); 
end;


if H[period-1]>H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]~=O[period-1] and C[period-1]==H[period-1] and C[period-1]>C[period-2] and C[period-1]>C[period] and H[period-1]>=H[period] and Vol[period-1]<Vol[period-2] and Vol[period-1]==Vol[period-3] then  
	Plot(LT2,period,"NoDemand"); 
end;

if L[period-1]<L[period-2] and H[period-1]<=H[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]~=O[period-1] and C[period-1]==L[period-1] and C[period-1]<C[period-2] and C[period-1]<C[period] and L[period-1]<=L[period] and Vol[period-1]<Vol[period-2] and Vol[period-1]==Vol[period-3] then  
	Plot(HT2,period,"NoSupply"); 
end;


if H[period-1]>H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]~=O[period-1] and C[period-1]==((H[period-1]-L[period-1])*0.5)+L[period-1] and C[period-1]>C[period-2] and C[period-1]>C[period] and H[period-1]>=H[period] and Vol[period-1]<Vol[period-2] and Vol[period-1]==Vol[period-3] then  
	Plot(LT2,period,"NoDemand"); 
end;

if L[period-1]<L[period-2] and H[period-1]<=H[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]~=O[period-1] and C[period-1]==((H[period-1]-L[period-1])*0.5)+L[period-1] and C[period-1]<C[period-2] and C[period-1]<C[period] and L[period-1]<=L[period] and Vol[period-1]<Vol[period-2] and Vol[period-1]==Vol[period-3] then  
	Plot(HT2,period,"NoSupply"); 
end;


if H[period-1]>H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]~=O[period-1] and C[period-1]==L[period-1] and C[period-1]>C[period-2] and C[period-1]>C[period] and H[period-1]>=H[period] and Vol[period-1]<Vol[period-2] and Vol[period-1]==Vol[period-3] then 
	Plot(LT2,period,"NoDemand"); 
end;

if L[period-1]<L[period-2] and H[period-1]<=H[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]~=O[period-1] and C[period-1]==H[period-1] and C[period-1]<C[period-2] and C[period-1]<C[period] and L[period-1]<=L[period] and Vol[period-1]<Vol[period-2] and Vol[period-1]==Vol[period-3] then  
	Plot(HT2,period,"NoSupply");
end;
 
	
end


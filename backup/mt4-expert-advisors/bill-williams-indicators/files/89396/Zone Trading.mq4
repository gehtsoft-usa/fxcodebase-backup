// Id: 9976
//+------------------------------------------------------------------+
//|                                                 Zone Trading.mq4 |
//|                                    Copyright � 2012, Mario Jemic |
//|                                           mario.jemic@gmail.com  |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2013, Mario Jemic"
#property link      "mario.jemic@gmail.com"

//#property indicator_chart_window
#property indicator_separate_window
#property indicator_buffers 2

extern color Bullish = Green;
extern color Bearish = Red;
extern color Neutral = Gray;

extern int  Filter=1;


extern int  Fast_MA_periods=5;
extern int  Slow_MA_periods=35;
extern int  Acceleration_Deceleration=5;

extern int  MA_Mode = 0;
extern int  Price_Mode = 4;

double PrH[], PrL[];
int MAX=0;
double AO[],AC[];
double aoi[], aci[],Final[];

string IndicatorName;
string IndicatorObjPrefix;

string GenerateIndicatorName(const string target)
{
   string name = target;
   int try = 2;
   while (WindowFind(name) != -1)
   {
      name = target + " #" + IntegerToString(try++);
   }
   return name;
}

 
void DrawCandle(datetime T, double O, double C, double H, double L, int pos)
{
 
  string ObjName=IndicatorObjPrefix + ""+T;
 
   color CandleColor =Neutral;
 

    if(Final[pos]  == 2 ) CandleColor=Bullish; 
   if (Final[pos]  == 1 ) CandleColor=Bearish; 
   if (Final[pos]  == 0 ) CandleColor=Neutral; 

   


int Window=WindowFind(IndicatorName); 
 // int Window=0;
 if (Window==-1) return;
 
 if (ObjectFind(ObjName+"R")!=-1)
 {
  ObjectSet(ObjName+"R", OBJPROP_TIME1, T);
  ObjectSet(ObjName+"R", OBJPROP_TIME2, T);
  ObjectSet(ObjName+"R", OBJPROP_PRICE1, O);
  ObjectSet(ObjName+"R", OBJPROP_PRICE2, C);
 }
 else
 {
  ObjectCreate(ObjName+"R", OBJ_TREND, Window, T, O, T, C);  
 } 
 
 if (ObjectFind(ObjName+"S")!=-1)
 {
  ObjectSet(ObjName+"S", OBJPROP_TIME1, T);
  ObjectSet(ObjName+"S", OBJPROP_TIME2, T);
  ObjectSet(ObjName+"S", OBJPROP_PRICE1, H);
  ObjectSet(ObjName+"S", OBJPROP_PRICE2, L);
 }
 else
 {
 ObjectCreate(ObjName+"S", OBJ_TREND, Window, T, H, T, L);
 }
 ObjectSet(ObjName+"R", OBJPROP_COLOR, CandleColor);
 ObjectSet(ObjName+"R", OBJPROP_RAY, false);
 ObjectSet(ObjName+"R", OBJPROP_WIDTH, 3);
 
 ObjectSet(ObjName+"S", OBJPROP_COLOR, CandleColor);
 ObjectSet(ObjName+"S", OBJPROP_RAY, false);
 ObjectSet(ObjName+"S", OBJPROP_WIDTH, 1);
 
 return;
}  


int init()
  {
  
   
   IndicatorName = GenerateIndicatorName("Zone");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   IndicatorDigits(Digits);
   
   IndicatorBuffers(7);
   
   
    if(! (Price_Mode >= 0 && Price_Mode <= 5  )  ) 
   {
   Alert("Permitted Price_Modes are between 0 and 5");

   return(-1);
   }
   
   
   if(! (Price_Mode >= 0 && Price_Mode <= 5  )  ) 
   {
   Alert("Permitted Price_Modes are between 0 and 5");

   return(-1);
   }
   
   if(! (MA_Mode >= 0 && MA_Mode <= 3  )  ) 
   {
   Alert("Permitted MA_Modes are between 0 and 3");

   return(-1);
   }
   
   if(Filter!= 1 && Filter!= 2 && Filter!= 3  ) 
   {
   Alert("Permitted Filter Methods are 1, 2 or 3");
  // Comment("Permitted methods are 1, 2 or 3");
   return(-1);
   }
       SetIndexStyle(0,DRAW_NONE);
   SetIndexBuffer(0,PrL);
   SetIndexStyle(1,DRAW_NONE);
   SetIndexBuffer(1,PrH);
   
   SetIndexStyle(2,DRAW_NONE);
   SetIndexBuffer(2,AO);
   SetIndexStyle(3,DRAW_NONE);
   SetIndexBuffer(3,AC);
   
   SetIndexStyle(4,DRAW_NONE);
   SetIndexBuffer(4,aoi);
   SetIndexStyle(5,DRAW_NONE);
   SetIndexBuffer(5,aci);
   
   SetIndexStyle(6,DRAW_NONE);
   SetIndexBuffer(6,Final);
   
 
   
   MAX =MathMax( MAX,Fast_MA_periods);
   MAX =MathMax( MAX,Slow_MA_periods);
   MAX =MathMax( MAX,Acceleration_Deceleration);
   return(0);
  }

int deinit()
  {
    ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);


   return(0);
  }

 int ACC(int i)
{ 
   
  AC[i] = AO[i] - iMAOnArray(AO,0,Acceleration_Deceleration,0,MA_Mode,i);
  
 
 }
 
  
  
int AOC(int i)
{

 double Fast = iMA (NULL,0,Fast_MA_periods,0,MA_Mode,Price_Mode,i);
 double Slow = iMA (NULL,0,Slow_MA_periods,0,MA_Mode,Price_Mode,i);
 
 AO[i]= Fast-Slow;
 
  return(0);
}

  
  
int start()
{
 if(Bars<=MAX) return(0); 
 
 

 int pos;
 int limit=Bars-MAX;
 
 pos=limit;
 
 while(pos>=0)
 {
 
  PrH[pos]=High[pos];
  PrL[pos]=Low[pos];
  
   AOC(pos);  
    
  
   
   pos--;
 } 
 
 
  pos=limit;
 
 while(pos>=0)
 {
 
 ACC(pos); 
 
    pos--;
 } 
 
 
  pos=limit;
 
 while(pos>=0)
 {
 
   Signal(pos);
   
   pos--;
 } 
   
  pos=limit;
 
 while(pos>=0)
 {
 
  DrawCandle(Time[pos],Close[pos],Open[pos],High[pos],Low[pos], pos );

pos--;
 }

 return(0);
}


 
int Signal(int i) 
{


Final[i]= 0;
aoi[i]=aoi[i+1];
if (AO[i] > AO[i+1]) aoi[i]=2;
if (AO[i] < AO[i+1]) aoi[i]=1;

aci[i]=aci[i+1];
if (AC[i] > AC[i+1]) aci[i]=2;
if (AC[i] < AC[i+1]) aci[i]=1;



  if (Filter== 1 ) 
  {
         if ((aoi[i]== 2 ) && (aci[i]== 2)  ) Final[i] =2;
		 if ((aoi[i]== 1) &&  (aci[i]== 1)  ) Final[i] =1;		 
  }
 
    if (Filter== 2 )  
	{  
	if (aoi[i]== 2   ) Final[i] =2;
	if (aoi[i]== 1    ) Final[i] =1;	
	}
			  
	if (Filter== 3 )  
	{
	if (aci[i]== 2 ) Final[i] =2;
	if (aci[i]== 1 ) Final[i] =1;					  
	} 
      
  
  
  return (0);
}
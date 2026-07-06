//+------------------------------------------------------------------+
//|                               Copyright © 2020, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  | 
//|                                    Paypal: https://goo.gl/9Rj74e |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                           https://AppliedMachineLearning.systems |
//|                                Patreon :  https://goo.gl/GdXWeN  |  
//+------------------------------------------------------------------+

#property copyright "Copyright © 2020, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.1"
#property indicator_separate_window
#property indicator_buffers 4

extern color Bullish = MediumSeaGreen;
extern color Bearish = Orange;

extern int  MA_Period=14;
extern int  MA_Type=0;

int Window;

double PrH[], PrL[],PrO[], PrC[];


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
 
void DrawCandle(datetime T, double O, double C, double H, double L)
{
   string ObjName= "ss" + T;
   color CandleColor;
   if (C>=O) 
      CandleColor=Bullish; 
   else 
      CandleColor=Bearish;
   
   Window=WindowFind(IndicatorName);
   if (Window==-1)
   {
      return;
   }
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
   IndicatorName = GenerateIndicatorName("DPO Bar");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,PrH);
   SetIndexStyle(1,DRAW_NONE);
   SetIndexBuffer(1,PrL);
   
   SetIndexStyle(2,DRAW_NONE);
   SetIndexBuffer(2,PrO);
   SetIndexStyle(3,DRAW_NONE);
   SetIndexBuffer(3,PrC);
 
   return(0);
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);

   return(0);
}

int start()
{
   if(Bars<=MA_Period) return(0);
   int ExtCountedBars=IndicatorCounted();
   if (ExtCountedBars<0) return(-1);
   int pos;
   int limit=Bars-MA_Period;
   if(ExtCountedBars>MA_Period) limit=Bars-MA_Period-1;

   pos=limit;
   
   while(pos>=0)
   {
      PrH[pos]=High[pos]-iMA(NULL,0,MA_Period,0,MA_Type,2,pos);
      PrL[pos]=Low[pos]-iMA(NULL,0,MA_Period,0,MA_Type,3,pos);
      PrO[pos]=Open[pos]-iMA(NULL,0,MA_Period,0,MA_Type,1,pos);
      PrC[pos]=Close[pos]-iMA(NULL,0,MA_Period,0,MA_Type,0,pos);
      
      DrawCandle(Time[pos],PrC[pos],PrO[pos],PrH[pos],PrL[pos] );
      
      pos--;
   } 

   return(0);
}



//+------------------------------------------------------------------+
//|                                         Volatility Ratio: VR.mq4 |
//|                             Copyright (c) 2016, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                         Donate / Support:  http://goo.gl/cEP5h5  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                     BitCoin: 1MfUHS3h86MBTeonJzWdszdzF2iuKESCKU  |
//+------------------------------------------------------------------+

#property indicator_buffers 1
#property indicator_separate_window
#property indicator_levelcolor clrYellow

extern int   EMA_Period  = 14;
extern color VR_Color  = clrRed;
extern bool  Alert_ON  = true;

double VR[];
double TR[];
double EMATR[];

datetime LastAlert;

int init(){
   
   IndicatorShortName("VolatilityRatio");
   IndicatorBuffers(3);
   
   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,1,VR_Color);
   SetIndexBuffer(0,VR);
   SetIndexLabel(0,"VR");
   SetIndexStyle(1,DRAW_NONE);
   SetIndexBuffer(1,TR);
   SetIndexStyle(2,DRAW_NONE);
   SetIndexBuffer(2,EMATR);
   
   SetLevelValue(0,2);
   SetLevelStyle(STYLE_SOLID,2);
   
   return(0);
}

int start()
  {
   
   int i;
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;
   
   for(i=limit; i>=0; i--){
      
      TR[i]=MathMax(MathMax(High[i]-Low[i],MathAbs(High[i]-Close[i+1])),MathAbs(Close[i+1]-Low[i]));
      
      EMATR[i]=EMA(TR[i],EMATR[i+1],EMA_Period,i); // EMA of True Range
      
      VR[i] = TR[i]/EMATR[i];
         
   }
   
   if (Alert_ON && i==0 && Time[0] > LastAlert && VR[0]>2){
      Alert(Symbol() + "," + TFToStr(Period()) + ": Volatility Ratio > 2");
      LastAlert = TimeCurrent();
   }
   
//----
   return(0);
}
  
//+------------------------------------------------------------------+
//| EMA                                                              |
//+------------------------------------------------------------------+
double EMA(double price,double prev,int per,int bar)
{
   if(bar >= Bars - 2) double ema = price;
   else 
   ema = prev + 2.0/(1+per)*(price - prev); 
   
   return(ema);
}

//+------------------------------------------------------------------+                                                                          //
string TFToStr(int tf)   {                                                                                                                      //
//+------------------------------------------------------------------+                                                                          //
  if (tf == 0)        tf = Period();                                                                                                            //
  if (tf >= 43200)    return("MN");                                                                                                             //
  if (tf >= 10080)    return("W1");                                                                                                             //
  if (tf >=  1440)    return("D1");                                                                                                             //
  if (tf >=   240)    return("H4");                                                                                                             //
  if (tf >=    60)    return("H1");                                                                                                             //
  if (tf >=    30)    return("M30");                                                                                                            //
  if (tf >=    15)    return("M15");                                                                                                            //
  if (tf >=     5)    return("M5");                                                                                                             //
  if (tf >=     1)    return("M1");                                                                                                             //
  return("");                                                                                                                                   //
}
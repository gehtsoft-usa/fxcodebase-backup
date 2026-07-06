2//+------------------------------------------------------------------+
//|                               Copyright © 2021, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                           mario.jemic@gmail.com  |
//|                          https://AppliedMachineLearning.systems  |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//|                                 Patreon : https://goo.gl/GdXWeN  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2021, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"

// based on Dariuske
#property description "ZZDSV gives the Delta pip swing volume based on the zigzag indicator."
#property description "You need the TSVDiff and ZigZag indicator in the indicator map to be able to use this indicator."
#property description " "
#property description "This indicator is free for everybody to use!"

#property indicator_chart_window

input int varExtDepth=12;
input int varExtDeviation=5;
input int varExtBackstep=3;
input int History = 500;
input color FontColor=Yellow;

double Pip;

int init()
  {
    if(Digits==3 || Digits==5) Pip = 10*Point;
    else Pip = Point;
    IndicatorDigits(Digits+1);   
    return(0);
  }

int deinit()
  {
   string ObjName;
   for(int i=ObjectsTotal()-1; i>=0; i--)
   {
     ObjName = ObjectName(i);
     if(StringFind(ObjName,"ZZLabel",0)>=0)
       ObjectDelete(ObjName);
   }
   return(0);
  }

int start()
  {
   int i, k, limit, counted_bars=IndicatorCounted();
   limit = MathMin(History,Bars-counted_bars-1);
   double zz,count1=0;
   color ObjColor;
   for(i=History; i>=1; i--)
   {
     k = i;
     double d1=0,d2=0,d3=0,TSV;
     zz = iCustom(NULL,0,"ZigZag",varExtDepth,varExtDeviation,varExtBackstep,0,i);
     TSV = iCustom(NULL,0,"TSVDiff",0,i);
     if (zz!=0) 
       { 
         count1 = count1 + TSV;
         double LabelPos;    
         LabelPos = NormalizeDouble(zz+0.4*iATR(NULL,0,10,i),Digits);
         string ObjName = "ZZLabel"+i;
         ObjectCreate(ObjName,OBJ_TEXT,0,Time[i],LabelPos);
         ObjectSetText(ObjName,DoubleToStr(count1,0),8,"Arial",FontColor);
         count1 = 0;
       }
     if (zz==0) 
       {
       count1 = count1 + TSV;
       }
   }
   return(0);
  }
//+------------------------------------------------------------------+
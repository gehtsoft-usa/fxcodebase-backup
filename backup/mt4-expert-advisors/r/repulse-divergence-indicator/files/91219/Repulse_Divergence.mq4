//+------------------------------------------------------------------+
//|                                           Repulse_Divergence.mq4 |
//|                               Copyright � 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Green
#property indicator_color2 Red

extern color Bullish = MediumSeaGreen;
extern color Bearish = Orange;

extern int Length1=5;
extern int Length2=15;
extern int RepulseLine=1;

double Repulse1[], Repulse2[], RepulseOut[];

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

int init()
  {
       double temp = iCustom(NULL, 0, "Repulse", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'Repulse' indicator");
       return INIT_FAILED;
   }
   IndicatorName = GenerateIndicatorName("Repulse Divergence");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,Repulse1);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,Repulse2);
   SetIndexStyle(2,DRAW_NONE);
   SetIndexBuffer(2,RepulseOut);
   return(0);
  }

int deinit()
  {
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return(0);
  }
 
void DrawLine(int First, int Second, bool BullFl)
{
 string ObjName=IndicatorObjPrefix + Time[First]+"_"+Time[Second];
 int WindowNumber;
 if (ObjectFind(ObjName)==-1)
 {
  WindowNumber=WindowFind(IndicatorName);
  if (WindowNumber!=-1)
  {
   ObjectCreate(ObjName, OBJ_TREND, WindowNumber, Time[First], RepulseOut[First], Time[Second], RepulseOut[Second]);
   ObjectSet(ObjName, OBJPROP_RAY, false);
   ObjectCreate(ObjName+"A", OBJ_ARROW, WindowNumber, Time[Second], RepulseOut[Second]);
   if (BullFl)
   {
    ObjectSet(ObjName, OBJPROP_COLOR, Bullish);
    ObjectCreate(ObjName+"~", OBJ_TREND, 0, Time[First], Low[First], Time[Second], Low[Second]);
    ObjectSet(ObjName+"~", OBJPROP_COLOR, Bullish);
    ObjectCreate(ObjName+"~A", OBJ_ARROW, 0, Time[Second], Low[Second]);
    ObjectSet(ObjName+"~A", OBJPROP_COLOR, Bullish);
    ObjectSet(ObjName+"~A", OBJPROP_ARROWCODE, 241);
    ObjectSet(ObjName+"A", OBJPROP_COLOR, Bullish);
    ObjectSet(ObjName+"A", OBJPROP_ARROWCODE, 241);
   }
   else
   {
    ObjectSet(ObjName, OBJPROP_COLOR, Bearish);
    ObjectCreate(ObjName+"~", OBJ_TREND, 0, Time[First], High[First], Time[Second], High[Second]);
    ObjectSet(ObjName+"~", OBJPROP_COLOR, Bearish);
    ObjectCreate(ObjName+"~A", OBJ_ARROW, 0, Time[Second], High[Second]);
    ObjectSet(ObjName+"~A", OBJPROP_COLOR, Bearish);
    ObjectSet(ObjName+"~A", OBJPROP_ARROWCODE, 242);
    ObjectSet(ObjName+"A", OBJPROP_COLOR, Bearish);
    ObjectSet(ObjName+"A", OBJPROP_ARROWCODE, 242);
   } 
   ObjectSet(ObjName+"~", OBJPROP_RAY, false);
  } 
 }
} 

bool isTrough(int bar)
{
 int i;
 if (RepulseOut[bar]<0 && RepulseOut[bar]<RepulseOut[bar+1] && RepulseOut[bar]<RepulseOut[bar-1])
 {
  for (i=bar+1;i<=Bars;i++)
  {
   if (RepulseOut[i]>0)
   {
    return (true);
   }
   else
   {
    if (RepulseOut[bar]>RepulseOut[i])
    {
     return (false);
    }
   }
  }
 }
} 

int prevTrough(int bar)
{
 int i;
 for (i=bar+5;i<=Bars;i++)
 {
  if (RepulseOut[i]<=RepulseOut[i+1] && RepulseOut[i]<RepulseOut[i+2] && RepulseOut[i]<=RepulseOut[i-1] && RepulseOut[i]<RepulseOut[i-2])
  {
   return (i);
  }
 }
 return (EMPTY_VALUE);
}

void processBullish(int bar)
{
 if (isTrough(bar))
 {
  int curr, prev;
  curr=bar;
  prev=prevTrough(bar);
  if (prev!=EMPTY_VALUE)
  {
   if (RepulseOut[curr]>RepulseOut[prev] && Low[curr]<Low[prev])
   {
    DrawLine(prev, curr, true);
   }
   else
   {
    if (RepulseOut[curr]<RepulseOut[prev] && Low[curr]>Low[prev])
    {
     DrawLine(prev, curr, true);
    }
   }
  }
 }
}  

bool isPeak(int bar)
{
 int i;
 if (RepulseOut[bar]>0&& RepulseOut[bar]>RepulseOut[bar+1] && RepulseOut[bar]>RepulseOut[bar-1])
 {
  for (i=bar+1;i<=Bars;i++)
  {
   if (RepulseOut[i]<0)
   {
    return (true);
   }
   else
   {
    if (RepulseOut[bar]<RepulseOut[i])
    {
     return (false);
    }
   }
  }
 }
} 

int prevPeak(int bar)
{
 int i;
 for (i=bar+5;i<=Bars;i++)
 {
  if (RepulseOut[i]>=RepulseOut[i+1] && RepulseOut[i]>RepulseOut[i+2] && RepulseOut[i]>=RepulseOut[i-1] && RepulseOut[i]>RepulseOut[i-2])
  {
   return (i);
  }
 }
 return (EMPTY_VALUE);
}

void processBearish(int bar)
{
 if (isPeak(bar))
 {
  int curr, prev;
  curr=bar;
  prev=prevPeak(bar);
  if (prev!=EMPTY_VALUE)
  {
   if (RepulseOut[curr]<RepulseOut[prev] && High[curr]>High[prev])
   {
    DrawLine(prev, curr, false);
   }
   else
   {
    if (RepulseOut[curr]>RepulseOut[prev] && High[curr]<High[prev])
    {
     DrawLine(prev, curr, false);
    }
   }
  }
 }
}  

int start()
{
 if(Bars<=3) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int pos;
 int i;
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 pos=limit;
 while(pos>=0)
 {
  Repulse1[pos]=iCustom(NULL, 0, "Repulse", Length1, Length2, 0, pos);
  Repulse2[pos]=iCustom(NULL, 0, "Repulse", Length1, Length2, 1, pos);
  if (RepulseLine==1)
  {
   RepulseOut[pos]=Repulse1[pos];
  }
  else
  {
   RepulseOut[pos]=Repulse2[pos];
  }
  
  processBullish(pos+2);
  processBearish(pos+2);
  pos--;
 }
 return(0);
}


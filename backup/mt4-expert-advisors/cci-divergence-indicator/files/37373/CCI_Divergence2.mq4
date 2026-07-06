// Id: 7079
//+------------------------------------------------------------------+
//|                                               CCI_Divergence.mq4 |
//|                               Copyright � 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Green

extern int MaxBars=50;
extern color Bullish = MediumSeaGreen;
extern color Bearish = Orange;

extern int Length=14;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double CCI[];

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
   IndicatorName = GenerateIndicatorName("CCI Divergence");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,CCI);

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
  WindowNumber=WindowFind("CCI Divergence");
  if (WindowNumber!=-1)
  {
   ObjectCreate(ObjName, OBJ_TREND, WindowNumber, Time[First], CCI[First], Time[Second], CCI[Second]);
   ObjectSet(ObjName, OBJPROP_RAY, false);
   ObjectCreate(ObjName+"A", OBJ_ARROW, WindowNumber, Time[Second], CCI[Second]);
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
 if (CCI[bar]<0 && CCI[bar]<CCI[bar+1] && CCI[bar]<CCI[bar-1])
 {
  for (i=bar+1;i<=Bars;i++)
  {
   if (CCI[i]>0)
   {
    return (true);
   }
   else
   {
    if (CCI[bar]>CCI[i])
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
  if (CCI[i]<=CCI[i+1] && CCI[i]<CCI[i+2] && CCI[i]<=CCI[i-1] && CCI[i]<CCI[i-2])
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
   if (CCI[curr]>CCI[prev] && Low[curr]<Low[prev])
   {
    DrawLine(prev, curr, true);
   }
   else
   {
    if (CCI[curr]<CCI[prev] && Low[curr]>Low[prev])
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
 if (CCI[bar]>0 && CCI[bar]>CCI[bar+1] && CCI[bar]>CCI[bar-1])
 {
  for (i=bar+1;i<=Bars;i++)
  {
   if (CCI[i]<0)
   {
    return (true);
   }
   else
   {
    if (CCI[bar]<CCI[i])
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
  if (CCI[i]>=CCI[i+1] && CCI[i]>CCI[i+2] && CCI[i]>=CCI[i-1] && CCI[i]>CCI[i-2])
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
   if (CCI[curr]<CCI[prev] && High[curr]>High[prev])
   {
    DrawLine(prev, curr, false);
   }
   else
   {
    if (CCI[curr]>CCI[prev] && High[curr]<High[prev])
    {
     DrawLine(prev, curr, false);
    }
   }
  }
 }
}  

int start()
{
 if(Bars<=Length) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int pos;
 int i;
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 limit=MathMin(limit, MaxBars);
 pos=limit;
 while(pos>=0)
 {
  CCI[pos]=iCCI(NULL, 0, Length, Price, pos);
  processBullish(pos+2);
  processBearish(pos+2);
  pos--;
 }
 return(0);
}


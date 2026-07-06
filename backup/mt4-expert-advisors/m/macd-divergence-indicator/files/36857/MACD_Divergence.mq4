// Id: 7020
//+------------------------------------------------------------------+
//|                                              MACD_Divergence.mq4 |
//|                               Copyright � 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Green

extern color Bullish = MediumSeaGreen;
extern color Bearish = Orange;

extern int Fast=12;
extern int Slow=26;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double MACD[];

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
    IndicatorName = GenerateIndicatorName("MACD Divergence");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,MACD);

   return(0);
  }

int deinit()
  {
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return(0);
  }
  
void DrawLine(int First, int Second, bool BullFl)
{
 string ObjName=Time[First]+"_"+Time[Second];
 int WindowNumber;
 if (ObjectFind(ObjName)==-1)
 {
  WindowNumber=WindowFind(IndicatorName);
  if (WindowNumber!=-1)
  {
   ObjectCreate(IndicatorObjPrefix + ObjName, OBJ_TREND, WindowNumber, Time[First], MACD[First], Time[Second], MACD[Second]);
   ObjectSet(IndicatorObjPrefix + ObjName, OBJPROP_RAY, false);
   ObjectCreate(IndicatorObjPrefix + ObjName+"A", OBJ_ARROW, WindowNumber, Time[Second], MACD[Second]);
   if (BullFl)
   {
    ObjectSet(IndicatorObjPrefix + ObjName, OBJPROP_COLOR, Bullish);
    ObjectCreate(IndicatorObjPrefix + ObjName+"~", OBJ_TREND, 0, Time[First], Low[First], Time[Second], Low[Second]);
    ObjectSet(IndicatorObjPrefix + ObjName+"~", OBJPROP_COLOR, Bullish);
    ObjectCreate(IndicatorObjPrefix + ObjName+"~A", OBJ_ARROW, 0, Time[Second], Low[Second]);
    ObjectSet(IndicatorObjPrefix + ObjName+"~A", OBJPROP_COLOR, Bullish);
    ObjectSet(IndicatorObjPrefix + ObjName+"~A", OBJPROP_ARROWCODE, 241);
    ObjectSet(IndicatorObjPrefix + ObjName+"A", OBJPROP_COLOR, Bullish);
    ObjectSet(IndicatorObjPrefix + ObjName+"A", OBJPROP_ARROWCODE, 241);
   }
   else
   {
    ObjectSet(IndicatorObjPrefix + ObjName, OBJPROP_COLOR, Bearish);
    ObjectCreate(IndicatorObjPrefix + ObjName+"~", OBJ_TREND, 0, Time[First], High[First], Time[Second], High[Second]);
    ObjectSet(IndicatorObjPrefix + ObjName+"~", OBJPROP_COLOR, Bearish);
    ObjectCreate(IndicatorObjPrefix + ObjName+"~A", OBJ_ARROW, 0, Time[Second], High[Second]);
    ObjectSet(IndicatorObjPrefix + ObjName+"~A", OBJPROP_COLOR, Bearish);
    ObjectSet(IndicatorObjPrefix + ObjName+"~A", OBJPROP_ARROWCODE, 242);
    ObjectSet(IndicatorObjPrefix + ObjName+"A", OBJPROP_COLOR, Bearish);
    ObjectSet(IndicatorObjPrefix + ObjName+"A", OBJPROP_ARROWCODE, 242);
   } 
   ObjectSet(IndicatorObjPrefix + ObjName+"~", OBJPROP_RAY, false);
  } 
 }
} 
  
bool isTrough(int bar)
{
 int i;
 if (MACD[bar]<0 && MACD[bar]<MACD[bar+1] && MACD[bar]<MACD[bar-1])
 {
  for (i=bar+1;i<=Bars;i++)
  {
   if (MACD[i]>0)
   {
    return (true);
   }
   else
   {
    if (MACD[bar]>MACD[i])
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
  if (MACD[i]<=MACD[i+1] && MACD[i]<MACD[i+2] && MACD[i]<=MACD[i-1] && MACD[i]<MACD[i-2])
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
   if (MACD[curr]>MACD[prev] && Low[curr]<Low[prev])
   {
    DrawLine(prev, curr, true);
   }
   else
   {
    if (MACD[curr]<MACD[prev] && Low[curr]>Low[prev])
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
 if (MACD[bar]>0 && MACD[bar]>MACD[bar+1] && MACD[bar]>MACD[bar-1])
 {
  for (i=bar+1;i<=Bars;i++)
  {
   if (MACD[i]<0)
   {
    return (true);
   }
   else
   {
    if (MACD[bar]<MACD[i])
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
  if (MACD[i]>=MACD[i+1] && MACD[i]>MACD[i+2] && MACD[i]>=MACD[i-1] && MACD[i]>MACD[i-2])
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
   if (MACD[curr]<MACD[prev] && High[curr]>High[prev])
   {
    DrawLine(prev, curr, false);
   }
   else
   {
    if (MACD[curr]>MACD[prev] && High[curr]<High[prev])
    {
     DrawLine(prev, curr, false);
    }
   }
  }
 }
}  

int start()
{
 if(Bars<=Slow) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int pos;
 int i;
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 pos=limit;
 while(pos>=0)
 {
  MACD[pos]=iMACD(NULL, 0, Fast, Slow, 2, Price, MODE_MAIN, pos);
  processBullish(pos+2);
  processBearish(pos+2);
  pos--;
 }
 return(0);
}


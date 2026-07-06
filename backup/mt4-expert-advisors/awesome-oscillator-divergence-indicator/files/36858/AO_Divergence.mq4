// Id: 7021
// More information about this indicator can be found at:
// http://fxcodebase.com/

//+------------------------------------------------------------------+
//|                               Copyright © 2019, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------+
//|                                Patreon :  https://goo.gl/GdXWeN  |
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
//+------------------------------------------------------------------+

#property copyright "Copyright � 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Green

extern color Bullish = MediumSeaGreen;
extern color Bearish = Orange;

extern int ShortMA=5;
extern int LongMA=34;

double AO[];

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
    IndicatorName = GenerateIndicatorName("AO Divergence");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,AO);

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
   ObjectCreate(IndicatorObjPrefix + ObjName, OBJ_TREND, WindowNumber, Time[First], AO[First], Time[Second], AO[Second]);
   ObjectSet(IndicatorObjPrefix + ObjName, OBJPROP_RAY, false);
   ObjectCreate(IndicatorObjPrefix + ObjName+"A", OBJ_ARROW, WindowNumber, Time[Second], AO[Second]);
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
 if (AO[bar]<0 && AO[bar]<AO[bar+1] && AO[bar]<AO[bar-1])
 {
  for (i=bar+1;i<=Bars;i++)
  {
   if (AO[i]>0)
   {
    return (true);
   }
   else
   {
    if (AO[bar]>AO[i])
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
  if (AO[i]<=AO[i+1] && AO[i]<AO[i+2] && AO[i]<=AO[i-1] && AO[i]<AO[i-2])
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
   if (AO[curr]>AO[prev] && Low[curr]<Low[prev])
   {
    DrawLine(prev, curr, true);
   }
   else
   {
    if (AO[curr]<AO[prev] && Low[curr]>Low[prev])
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
 if (AO[bar]>0 && AO[bar]>AO[bar+1] && AO[bar]>AO[bar-1])
 {
  for (i=bar+1;i<=Bars;i++)
  {
   if (AO[i]<0)
   {
    return (true);
   }
   else
   {
    if (AO[bar]<AO[i])
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
  if (AO[i]>=AO[i+1] && AO[i]>AO[i+2] && AO[i]>=AO[i-1] && AO[i]>AO[i-2])
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
   if (AO[curr]<AO[prev] && High[curr]>High[prev])
   {
    DrawLine(prev, curr, false);
   }
   else
   {
    if (AO[curr]>AO[prev] && High[curr]<High[prev])
    {
     DrawLine(prev, curr, false);
    }
   }
  }
 }
}  

int start()
{
 if(Bars<=LongMA) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int pos;
 int i;
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 pos=limit;
 while(pos>=0)
 {
  AO[pos]=iMA(NULL, 0, ShortMA, 0, MODE_SMA, PRICE_MEDIAN, pos)-iMA(NULL, 0, LongMA, 0, MODE_SMA, PRICE_MEDIAN, pos);
  processBullish(pos+2);
  processBearish(pos+2);
  pos--;
 }
 return(0);
}


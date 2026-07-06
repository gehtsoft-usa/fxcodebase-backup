// Id: 23315
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

#property copyright "Copyright © 2018, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com" 

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Green

extern color Bullish = MediumSeaGreen;
extern color Bearish = Orange;

extern int Length=14;
extern ENUM_APPLIED_PRICE Price=PRICE_CLOSE;
extern int OverBought=70;
extern int OverSold=30;

double ADX[];

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
   IndicatorName = GenerateIndicatorName("ADX Divergence");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ADX);
   SetLevelValue(1,OverSold);
   SetLevelValue(2,OverBought);
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
 if (ObjectFind(IndicatorObjPrefix + ObjName)==-1)
 {
  WindowNumber=WindowFind("ADX Divergence");
  if (WindowNumber!=-1)
  {
   ObjectCreate(IndicatorObjPrefix + ObjName, OBJ_TREND, WindowNumber, Time[First], ADX[First], Time[Second], ADX[Second]);
   ObjectSet(IndicatorObjPrefix + ObjName, OBJPROP_RAY, false);
   ObjectCreate(IndicatorObjPrefix + ObjName+"A", OBJ_ARROW, WindowNumber, Time[Second], ADX[Second]);
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
 if (ADX[bar]<OverSold && ADX[bar]<ADX[bar+1] && ADX[bar]<ADX[bar-1])
 {
  for (i=bar+1;i<=Bars;i++)
  {
   if (ADX[i]>OverSold)
   {
    return (true);
   }
   else
   {
    if (ADX[bar]>ADX[i])
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
  if (ADX[i]<=ADX[i+1] && ADX[i]<ADX[i+2] && ADX[i]<=ADX[i-1] && ADX[i]<ADX[i-2])
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
   if (ADX[curr]>ADX[prev] && Low[curr]<Low[prev])
   {
    DrawLine(prev, curr, true);
   }
   else
   {
    if (ADX[curr]<ADX[prev] && Low[curr]>Low[prev])
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
 if (ADX[bar]>OverBought && ADX[bar]>ADX[bar+1] && ADX[bar]>ADX[bar-1])
 {
  for (i=bar+1;i<=Bars;i++)
  {
   if (ADX[i]<OverBought)
   {
    return (true);
   }
   else
   {
    if (ADX[bar]<ADX[i])
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
  if (ADX[i]>=ADX[i+1] && ADX[i]>ADX[i+2] && ADX[i]>=ADX[i-1] && ADX[i]>ADX[i-2])
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
   if (ADX[curr]<ADX[prev] && High[curr]>High[prev])
   {
    DrawLine(prev, curr, false);
   }
   else
   {
    if (ADX[curr]>ADX[prev] && High[curr]<High[prev])
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
 pos=limit;
 while(pos>=0)
 {
  ADX[pos]=iADX(NULL, 0, Length, Price, MODE_MAIN, pos);
  processBullish(pos+2);
  processBearish(pos+2);
  pos--;
 }
 return(0);
}


// Id: 9280
//+------------------------------------------------------------------+
//|                                                Interpolation.mq4 |
//|                               Copyright � 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Yellow

#define ArrowName "Interpolation"

extern int Forward=2;
extern int ArrowSize=3;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double Buff[];

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

void DrawArrows()
{
 int FirstWBar=WindowFirstVisibleBar();
 int LastWBar=FirstWBar-WindowBarsPerChart();
 int MiddleWBar=(FirstWBar+LastWBar)/2;
 if (ObjectFind(IndicatorObjPrefix + ArrowName+"S")==-1)
 {
  ObjectCreate(IndicatorObjPrefix + ArrowName+"S", OBJ_ARROW, 0, Time[MiddleWBar+2], Close[MiddleWBar+2]);
  ObjectSet(IndicatorObjPrefix + ArrowName+"S", OBJPROP_ARROWCODE, 251);
  ObjectSet(IndicatorObjPrefix + ArrowName+"S", OBJPROP_WIDTH, ArrowSize);
 }
 if (ObjectFind(IndicatorObjPrefix + ArrowName+"E")==-1)
 {
  ObjectCreate(IndicatorObjPrefix + ArrowName+"E", OBJ_ARROW, 0, Time[MiddleWBar-2], Close[MiddleWBar-2]);
  ObjectSet(IndicatorObjPrefix + ArrowName+"E", OBJPROP_ARROWCODE, 251);
  ObjectSet(IndicatorObjPrefix + ArrowName+"E", OBJPROP_WIDTH, ArrowSize);
 }
 return;
}

int GetStartPoint()
{
 if (ObjectFind(IndicatorObjPrefix + ArrowName+"S")!=-1)
 {
  datetime StartPointTime=ObjectGet(IndicatorObjPrefix + ArrowName+"S", OBJPROP_TIME1);
  return (iBarShift(NULL, 0, StartPointTime));
 }
 else
 {
  return (-1);
 }
}

int GetEndPoint()
{
 if (ObjectFind(IndicatorObjPrefix + ArrowName+"E")!=-1)
 {
  datetime StartPointTime=ObjectGet(IndicatorObjPrefix + ArrowName+"E", OBJPROP_TIME1);
  return (iBarShift(NULL, 0, StartPointTime));
 }
 else
 {
  return (-1);
 }
}


int init()
  {
   SetIndexBuffer(0,Buff);
   SetIndexStyle(0,DRAW_LINE);
   IndicatorDigits(Digits);
   IndicatorName = GenerateIndicatorName("Interpolation");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   
   DrawArrows();

   return(0);
  }

int deinit()
  {
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return(0);
  }

int start()
  {
   DrawArrows();
   ArrayInitialize(Buff, EMPTY_VALUE);
   
   int StartBar=GetStartPoint();
   int EndBar=GetEndPoint();
   if (StartBar<EndBar)
   {
    int A=StartBar;
    StartBar=EndBar;
    EndBar=A;
   }
   
   int i1, i2, i3;
   for (i1=StartBar;i1>=EndBar-Forward;i1--)
   {
    double v1=0;
    for (i2=StartBar;i2>=EndBar;i2--)
    {
     double v2=1;
     double v3=1;
     for (i3=StartBar;i3>=EndBar;i3--)
     {
      if (i2!=i3)
      {
       v2=v2*(i1-i3);
       v3=v3*(i2-i3);
      }
     }
     v1=v1+iMA(NULL, 0, 1, 0, MODE_SMA, Price, i2)*v2/v3;
    }
    Buff[i1]=v1;
   }
   

   return(0);
  }


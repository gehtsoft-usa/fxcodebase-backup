// Id: 7568
//+------------------------------------------------------------------+
//|                                                    SerialMA2.mq4 |
//|                               Copyright � 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Red

#define StartPointName "SerialMA_Point2"

extern int StartPointSize=3;

double ExtMapBuffer1[];

void DrawStartPoint()
{
 if (ObjectFind(IndicatorObjPrefix + StartPointName)==-1)
 {
  ObjectCreate(IndicatorObjPrefix + StartPointName, OBJ_ARROW, 0, Time[10], Close[10]);
  ObjectSet(IndicatorObjPrefix + StartPointName, OBJPROP_ARROWCODE, 251);
  ObjectSet(IndicatorObjPrefix + StartPointName, OBJPROP_WIDTH, StartPointSize);
 }
 return;
}

int GetStartPoint()
{
 if (ObjectFind(IndicatorObjPrefix + StartPointName)!=-1)
 {
  datetime StartPointTime=ObjectGet(IndicatorObjPrefix + StartPointName, OBJPROP_TIME1);
  return (iBarShift(NULL, 0, StartPointTime));
 }
 else
 {
  return (-1);
 }
 
}

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
    IndicatorName = GenerateIndicatorName("SerialMA2");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexStyle(0,DRAW_LINE);
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));
   
   DrawStartPoint();
   return(0);
  }

int deinit()
  {
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return(0);
  }

int start()
  {
   DrawStartPoint();
   int StartPoint=GetStartPoint();
   int pos=Bars+1;
   
   double Sum=0;
   int MA_Period=1;
   
   while(pos>=0)
   {
    if (pos>StartPoint)
    {
     ExtMapBuffer1[pos]=EMPTY_VALUE;
    }
    else
    {
     Sum=Sum+Close[pos];
     ExtMapBuffer1[pos]=Sum/MA_Period;
     MA_Period++;
    } 
    pos--;
   }
   return(0);
  }



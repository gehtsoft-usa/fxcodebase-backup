// Id: 7569
//+------------------------------------------------------------------+
//|                                                    SerialMA3.mq4 |
//|                               Copyright � 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Magenta

#define StartPointName "SerialMA_Point3"

extern int StartPointSize=3;

double ExtMapBuffer1[], ExtMapBuffer2[];

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

int init()
  {
    IndicatorName = GenerateIndicatorName("SerialMA3");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexStyle(0,DRAW_LINE);
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexStyle(1,DRAW_LINE);
   
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
   
   double SumU=0;
   double SumD=0;
   int MA_Period=1;
   double PriceU, PriceD;
   
   while(pos>=0)
   {
    if (pos>StartPoint)
    {
     ExtMapBuffer1[pos]=EMPTY_VALUE;
     ExtMapBuffer2[pos]=EMPTY_VALUE;
    }
    else
    {
     if (pos==StartPoint)
     {
      SumU=Close[pos];
      SumD=Close[pos];
      ExtMapBuffer1[pos]=Close[pos];
      ExtMapBuffer2[pos]=Close[pos];
     }
     else
     {
      MA_Period++;
     
      if (Close[pos]>Open[pos])
      {
       PriceU=Close[pos];
       PriceD=ExtMapBuffer2[pos+1];
      }
      else
      {
       PriceU=ExtMapBuffer1[pos+1];
       if (Close[pos]<Open[pos])
       {
        PriceD=Close[pos];
       }
       else
       {
        PriceD=ExtMapBuffer2[pos+1];
       }
      } 
     } 
     SumU=SumU+PriceU;
     SumD=SumD+PriceD;
     
     ExtMapBuffer1[pos]=SumU/MA_Period;
     ExtMapBuffer2[pos]=SumD/MA_Period;
    } 
    pos--;
   }
   return(0);
  }




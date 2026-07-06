//+------------------------------------------------------------------+
//|                               Copyright © 2020, Gehtsoft USA LLC |
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

#property copyright "Copyright © 2020, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"

#property indicator_chart_window

input int      NumOfDays             = 10;
input int mult = 3; // Multiplicator
input string   FontName              = "Courier New";
input int      FontSize              = 10;
input color    FontColor             = White;
input int      Window                = 0;
input int      Corner                = 0;
input int      HorizPos              = 5;
input int      VertPos               = 20;

double pnt;
int    dig;
string objname = "*DRPE";

//+------------------------------------------------------------------+
int init()  {
//+------------------------------------------------------------------+
  pnt = MarketInfo(Symbol(),MODE_POINT);
  dig = MarketInfo(Symbol(),MODE_DIGITS);
  if (dig == 3 || dig == 5) {
    pnt *= 10;
  }  
  ObjectCreate(objname,OBJ_LABEL,Window,0,0);
  return(0);
}

//+------------------------------------------------------------------+
int deinit()  {
//+------------------------------------------------------------------+
  ObjectDelete(objname);
  return(0);
}

//+------------------------------------------------------------------+
int start()  {
//+------------------------------------------------------------------+
  int c=0;
  double sum=0;
  for (int i=1; i<Bars-1; i++)  {
    double hi = iHigh(NULL,PERIOD_D1,i);
    double lo = iLow(NULL,PERIOD_D1,i);
    datetime dt = iTime(NULL,PERIOD_D1,i);
    if (TimeDayOfWeek(dt) > 0 && TimeDayOfWeek(dt) < 6)  {
      sum += hi - lo;
      c++;
      if (c>=NumOfDays) break;
  } }
  hi = iHigh(NULL,PERIOD_D1,0);
  lo = iLow(NULL,PERIOD_D1,0);
  if (i>0 && pnt>0)  {
    string objtext = IntegerToString(mult) + "xADR = " + DoubleToStr((sum / c / pnt) * mult, 1) + "  (" + c + " days)     Today = " + DoubleToStr((hi - lo) * mult / pnt,1);
    ObjectSet(objname,OBJPROP_CORNER,Corner);
    ObjectSet(objname,OBJPROP_XDISTANCE,HorizPos);
    ObjectSet(objname,OBJPROP_YDISTANCE,VertPos);
    ObjectSetText(objname,objtext,FontSize,FontName,FontColor);
  }  
  return(0);
}


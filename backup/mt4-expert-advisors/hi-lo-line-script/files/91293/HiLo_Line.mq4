// Id: 10616
//+------------------------------------------------------------------+
//|                                                    HiLo_Line.mq4 |
//|                               Copyright � 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property show_inputs

extern int Hi_Line_Price=2;      // Applied price
                                 // 0 - Close
                                 // 1 - Open
                                 // 2 - High
                                 // 3 - Low
extern int Lo_Line_Price=3;      // Applied price
                                 // 0 - Close
                                 // 1 - Open
                                 // 2 - High
                                 // 3 - Low
extern bool Use_Only_Visible_Data=true;  // false - use all history data
extern bool Show_Distance=true;
extern bool Show_Distance_On_Top=true;  // false - on bottom
extern color Hi_Line_Color=Red;
extern color Lo_Line_Color=Red;
extern color Distance_Color=Yellow;
extern int Distance_Size=10;

int ConvertType(int T)
{
 if (T==PRICE_CLOSE) return (MODE_CLOSE);
 if (T==PRICE_OPEN) return (MODE_OPEN);
 if (T==PRICE_HIGH) return (MODE_HIGH);
 return (MODE_LOW);
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
   IndicatorName = GenerateIndicatorName("HiLo_Line");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   return 0;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
}

void CheckLine(string _Name, double _Price, color _Color)
{
 if (ObjectFind(_Name)==-1)
 {
  ObjectCreate(_Name, OBJ_HLINE, 0, 0, _Price); 
 }
 else
 {
  if (ObjectGet(_Name, OBJPROP_PRICE1)!=_Price)
  {
   ObjectSet(_Name, OBJPROP_PRICE1, _Price);
  }
  if (ObjectGet(_Name, OBJPROP_COLOR)!=_Color)
  {
   ObjectSet(_Name, OBJPROP_COLOR, _Color);
  }
 }
 
 
 return;
}

int start()
{
 double Min, Max;
 int FirstBar, CountBars, LastBar;
 string Distance;
 double Text_Price;
 int Text_Bar;
 while (true)
 {
  if (Use_Only_Visible_Data)
  {
   FirstBar=WindowFirstVisibleBar();
   CountBars=WindowBarsPerChart();
  }
  else
  {
   FirstBar=Bars-1;
   CountBars=Bars;
  }
  LastBar=FirstBar-CountBars+1;
  LastBar=MathMax(LastBar, 0);
  CountBars=MathMin(CountBars, FirstBar);

  Min=iMA(NULL, 0, 1, 0, MODE_SMA, Lo_Line_Price, iLowest(NULL, 0, ConvertType(Lo_Line_Price), CountBars, LastBar));
  Max=iMA(NULL, 0, 1, 0, MODE_SMA, Hi_Line_Price, iHighest(NULL, 0, ConvertType(Hi_Line_Price), CountBars, LastBar));
  
  CheckLine(IndicatorObjPrefix + "HiLo_Line_Hi", Max, Hi_Line_Color);
  CheckLine(IndicatorObjPrefix + "HiLo_Line_Lo", Min, Lo_Line_Color);
  
  if (Show_Distance)
  {
   Distance=DoubleToStr((Max-Min)/Point, 0)+" pips                                   .";
   Text_Bar=WindowFirstVisibleBar()-WindowBarsPerChart();
   Text_Bar=MathMax(Text_Bar, 0);
   if (Show_Distance_On_Top)
   {
    Text_Price=Max;
   }
   else
   {
    Text_Price=Min;
   }
   if (ObjectFind(IndicatorObjPrefix + "HiLo_Line_Distance")==-1)
   {
    ObjectCreate(IndicatorObjPrefix + "HiLo_Line_Distance", OBJ_TEXT, 0, Time[Text_Bar], Text_Price);
   }
   else
   {
    if (ObjectGet(IndicatorObjPrefix + "HiLo_Line_Distance", OBJPROP_TIME1)!=Time[Text_Bar])
    {
     ObjectSet(IndicatorObjPrefix + "HiLo_Line_Distance", OBJPROP_TIME1, Time[Text_Bar]);
    }
    if (ObjectGet(IndicatorObjPrefix + "HiLo_Line_Distance", OBJPROP_PRICE1)!=Text_Price)
    {
     ObjectSet(IndicatorObjPrefix + "HiLo_Line_Distance", OBJPROP_PRICE1, Text_Price);
    }
   } 
   if (ObjectDescription(IndicatorObjPrefix + "HiLo_Line_Distance")!=Distance)
   {
    ObjectSetText(IndicatorObjPrefix + "HiLo_Line_Distance", Distance, Distance_Size, "Times New Roman", Distance_Color);
   }
  }
  
  WindowRedraw();
  if (IsStopped())
  {
   break;
  }
  else
  {
   Sleep(100);
  } 
 } 
 
 return(0);
}


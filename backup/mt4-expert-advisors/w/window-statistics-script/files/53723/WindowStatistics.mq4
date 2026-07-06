// Id: 8431
//+------------------------------------------------------------------+
//|                                             WindowStatistics.mq4 |
//|                               Copyright � 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property show_inputs
extern color TextColor=Yellow;
extern int Corner=1;
extern int VOffset=5;
extern int HOffset=15;
extern int HStep=15;
extern int TextSize=12;
extern int RefreshTime=1;

string ObjName="WindowStatistics";
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
    IndicatorName = GenerateIndicatorName("WindowStatistics");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   return(0);
  }

int deinit()
  {
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return(0);
  }
  
void DrawRow(int Num, string Text)
{
 string ON=IndicatorObjPrefix + ObjName+DoubleToStr(Num,0);
 if (ObjectFind(ON)==-1) ObjectCreate(ON, OBJ_LABEL, 0, 0, 0);
 ObjectSetText(ON, Text, TextSize);
 ObjectSet(ON, OBJPROP_COLOR, TextColor);
 ObjectSet(ON, OBJPROP_XDISTANCE, VOffset);
 ObjectSet(ON, OBJPROP_YDISTANCE, HOffset+(Num-1)*HStep);
 ObjectSet(ON, OBJPROP_CORNER, Corner);
 return;
}
  
int start()
{
 while (true)
 {
  int BeginBar=WindowFirstVisibleBar();
  int EndBar=BeginBar-WindowBarsPerChart();
  string BeginTime=TimeToStr(Time[BeginBar], TIME_DATE|TIME_MINUTES);
  string EndTime=TimeToStr(Time[EndBar], TIME_DATE|TIME_MINUTES);
  int CountBars=BeginBar-EndBar+1;
  double MinPrice=Low[ArrayMinimum(Low, CountBars, EndBar)];
  double MaxPrice=High[ArrayMaximum(High, CountBars, EndBar)];
  double MinBarSize=100000;
  double MaxBarSize=0;
  double SumBarSize=0;
  for (int i=BeginBar;i>=EndBar;i--)
  {
   MinBarSize=MathMin(MinBarSize, High[i]-Low[i]);
   MaxBarSize=MathMax(MinBarSize, High[i]-Low[i]);
   SumBarSize+=High[i]-Low[i];
  }
  double AverageBarSize;
  if (CountBars>0) AverageBarSize=SumBarSize/CountBars; else AverageBarSize=0;
  DrawRow(1, "Window statistics:");
  DrawRow(2, "Begin time: "+BeginTime);
  DrawRow(3, "End time: "+EndTime);
  DrawRow(4, "Max. price: "+DoubleToStr(MaxPrice, Digits));
  DrawRow(5, "Mim. price: "+DoubleToStr(MinPrice, Digits));
  DrawRow(6, "Count of bars: "+DoubleToStr(CountBars, 0));
  DrawRow(7, "Max. bar size: "+DoubleToStr(MaxBarSize, Digits)+" ("+DoubleToStr(MaxBarSize/Point, 0)+" pips)");
  DrawRow(8, "Min. bar size: "+DoubleToStr(MinBarSize, Digits)+" ("+DoubleToStr(MinBarSize/Point, 0)+" pips)");
  DrawRow(9, "Average bar size: "+DoubleToStr(AverageBarSize, Digits)+" ("+DoubleToStr(AverageBarSize/Point, 0)+" pips)");
  if (IsStopped())
  {
   break;
  }
  else
  {
   Sleep(1000*RefreshTime);
  } 
 } 
 return(0);
}


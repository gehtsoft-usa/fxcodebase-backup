//+------------------------------------------------------------------+
//|                                             ProfitCalculator.mq4 |
//|                               Copyright � 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window

extern color TextColor=Gray;
extern color ProfitColor=Green;
extern color LossColor=Red;
extern int Corner=4;
extern int VOffset=5;
extern int HOffset=15;
extern int VStep=200;
extern int HStep=15;
extern int TextSize=12;

string ObjCurrName="PC1";
string ObjDayName="PC2";
string ObjWeekName="PC3";
string ObjMonthName="PC4";
string ObjYearName="PC5";

datetime BeginDay, BeginWeek, BeginMonth, BeginYear;

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
IndicatorName = GenerateIndicatorName("ProfitCalculator");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   return(0);
  }

int deinit()
  {
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return(0);
  }
  
double CalcProfit(bool Current, datetime Time1, datetime Time2)
{
 double Profit=0;
 int i;
 if (Current)
 {
  for(i=0;i<OrdersTotal();i++)
  {
   if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
   {
    if(OrderType()==OP_BUY || OrderType()==OP_SELL)
    {
     Profit+=OrderProfit();
    } 
   }
  }
 }
 else
 {
  for(i=0;i<OrdersHistoryTotal();i++)
  {
   if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))
   {
    if(OrderType()==OP_BUY || OrderType()==OP_SELL)
    {
     if(OrderCloseTime()>=Time1 && OrderCloseTime()<=Time2)
     {
      Profit+=OrderProfit();
     } 
    }
   }
  }
 }
 return (Profit);
}  

void DrawRow(string ObjName, string Text, double Profit, int Y)
{
 if (ObjectFind(IndicatorObjPrefix + ObjName+"1")==-1) ObjectCreate(IndicatorObjPrefix + ObjName+"1", OBJ_LABEL, 0, 0, 0);
 if (ObjectFind(IndicatorObjPrefix + ObjName+"2")==-1) ObjectCreate(IndicatorObjPrefix + ObjName+"2", OBJ_LABEL, 0, 0, 0);
 ObjectSetText(IndicatorObjPrefix + ObjName+"1", Text, TextSize);
 ObjectSet(IndicatorObjPrefix + ObjName+"1", OBJPROP_COLOR, TextColor);
 ObjectSet(IndicatorObjPrefix + ObjName+"1", OBJPROP_XDISTANCE, VOffset);
 ObjectSet(IndicatorObjPrefix + ObjName+"1", OBJPROP_YDISTANCE, HOffset+(Y-1)*HStep);
 ObjectSet(IndicatorObjPrefix + ObjName+"1", OBJPROP_CORNER, Corner);
 ObjectSetText(IndicatorObjPrefix + ObjName+"2", DoubleToStr(Profit,2), TextSize);
 if (Profit>=0) ObjectSet(IndicatorObjPrefix + ObjName+"2", OBJPROP_COLOR, ProfitColor); else ObjectSet(IndicatorObjPrefix + ObjName+"2", OBJPROP_COLOR, LossColor);
 ObjectSet(IndicatorObjPrefix + ObjName+"2", OBJPROP_XDISTANCE, VOffset+VStep);
 ObjectSet(IndicatorObjPrefix + ObjName+"2", OBJPROP_YDISTANCE, HOffset+(Y-1)*HStep);
 ObjectSet(IndicatorObjPrefix + ObjName+"2", OBJPROP_CORNER, Corner);
 return;
}

int start()
  {
   int D=Day();
   int M=Month();
   int Y=Year();
   int DW=DayOfWeek();
   BeginDay=StrToTime(DoubleToStr(Y,0)+"."+DoubleToStr(M,0)+"."+DoubleToStr(D,0));
   BeginMonth=StrToTime(DoubleToStr(Y,0)+"."+DoubleToStr(M,0)+".1");
   BeginYear=StrToTime(DoubleToStr(Y,0)+".1.1");
   BeginWeek=BeginDay-DW*86400;
   DrawRow(ObjCurrName, "Current profit:", CalcProfit(true, 0, 0), 1);
   DrawRow(ObjDayName, "Current day profit:", CalcProfit(false, BeginDay, TimeCurrent( ) ), 2);
   DrawRow(ObjWeekName, "Current week profit:", CalcProfit(false, BeginWeek, TimeCurrent( ) ), 3);
   DrawRow(ObjMonthName, "Current month profit:", CalcProfit(false, BeginMonth, TimeCurrent( ) ), 4);
   DrawRow(ObjYearName, "Current year profit:", CalcProfit(false, BeginYear, TimeCurrent( ) ), 5);
   

   return(0);
  }


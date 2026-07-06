// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=31491


//+------------------------------------------------------------------+
//|                               Copyright © 2021, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  | 
//|                                    Paypal: https://goo.gl/9Rj74e |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                           https://AppliedMachineLearning.systems |
//|                                Patreon :  https://goo.gl/GdXWeN  |  
//+------------------------------------------------------------------+
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
//+------------------------------------------------------------------+


#property copyright "Copyright © 2021, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"

#property strict

#property indicator_chart_window

input color TextColor=Gray;
input color ProfitColor=Green;
input color LossColor=Red;
input int Corner=4;
input int VOffset=5;
input int HOffset=15;
input int VStep=200;
input int HStep=15;
input int TextSize=12;

string IndicatorObjPrefix;

bool NamesCollision(const string name)
{
   for (int k = ObjectsTotal(0); k >= 0; k--)
   {
      if (StringFind(ObjectName(0, k), name) == 0)
      {
         return true;
      }
   }
   return false;
}

string GenerateIndicatorPrefix(const string target)
{
   for (int i = 0; i < 1000; ++i)
   {
      string prefix = target + "_" + IntegerToString(i);
      if (!NamesCollision(prefix))
      {
         return prefix;
      }
   }
   return target;
}

double out[];

void OnInit()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("ProfitCalculator");
   IndicatorSetString(INDICATOR_SHORTNAME, "ProfitCalculator");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());
}

void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, IndicatorObjPrefix);
}

double CalcProfit(bool Current, datetime Time1, datetime Time2)
{
   double Profit = 0;
   if (Current)
   {
      for (int i = PositionsTotal() - 1; i >= 0; i--)
      {
         ulong ticket = PositionGetTicket(i);
         if (PositionSelectByTicket(ticket))
         {
            Profit += PositionGetDouble(POSITION_PROFIT);
         }
      }
   }
   else
   {
      bool res = HistorySelect(0, TimeCurrent());
      for (int i = 0; i < HistoryDealsTotal(); i++)
      {
         int ticket = HistoryDealGetTicket(i);
         if (HistoryDealGetInteger(ticket, DEAL_TIME) >= Time1 && HistoryDealGetInteger(ticket, DEAL_ENTRY) == DEAL_ENTRY_OUT)
         {
            Profit += HistoryDealGetDouble(ticket, DEAL_PROFIT);
         }
      }
   }
   return Profit;
}  

void ObjectSetText(string id, string text, int fontSize)
{
   ObjectSetString(0, id, OBJPROP_TEXT, text);
   ObjectSetInteger(0, id, OBJPROP_FONTSIZE, fontSize);
}

void DrawRow(string ObjName, string Text, double Profit, int Y)
{
   if (ObjectFind(0, IndicatorObjPrefix + ObjName+"1")==-1)
   {
      ObjectCreate(0, IndicatorObjPrefix + ObjName+"1", OBJ_LABEL, 0, 0, 0);
   }
   if (ObjectFind(0, IndicatorObjPrefix + ObjName+"2")==-1)
   {
      ObjectCreate(0, IndicatorObjPrefix + ObjName+"2", OBJ_LABEL, 0, 0, 0);
   }
   ObjectSetText(IndicatorObjPrefix + ObjName+"1", Text, TextSize);
   ObjectSetInteger(0, IndicatorObjPrefix + ObjName+"1", OBJPROP_COLOR, TextColor);
   ObjectSetInteger(0, IndicatorObjPrefix + ObjName+"1", OBJPROP_XDISTANCE, VOffset);
   ObjectSetInteger(0, IndicatorObjPrefix + ObjName+"1", OBJPROP_YDISTANCE, HOffset+(Y-1)*HStep);
   ObjectSetInteger(0, IndicatorObjPrefix + ObjName+"1", OBJPROP_CORNER, Corner);
   ObjectSetText(IndicatorObjPrefix + ObjName+"2", DoubleToString(Profit,2), TextSize);
   if (Profit >= 0)
   {
      ObjectSetInteger(0, IndicatorObjPrefix + ObjName+"2", OBJPROP_COLOR, ProfitColor);
   }
   else
   {
      ObjectSetInteger(0, IndicatorObjPrefix + ObjName+"2", OBJPROP_COLOR, LossColor);
   }
   ObjectSetInteger(0, IndicatorObjPrefix + ObjName+"2", OBJPROP_XDISTANCE, VOffset+VStep);
   ObjectSetInteger(0, IndicatorObjPrefix + ObjName+"2", OBJPROP_YDISTANCE, HOffset+(Y-1)*HStep);
   ObjectSetInteger(0, IndicatorObjPrefix + ObjName+"2", OBJPROP_CORNER, Corner);
}

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   DrawRow("C", "Current profit:", CalcProfit(true, 0, 0), 1);
   DrawRow("D1", "Current day profit:", CalcProfit(false, iTime(_Symbol, PERIOD_D1, 0), TimeCurrent()), 2);
   DrawRow("W1", "Current week profit:", CalcProfit(false, iTime(_Symbol, PERIOD_W1, 0), TimeCurrent()), 3);
   DrawRow("MN1", "Current month profit:", CalcProfit(false, iTime(_Symbol, PERIOD_MN1, 0), TimeCurrent()), 4);

   return rates_total;
}
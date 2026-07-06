// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=70650

//+------------------------------------------------------------------+
//|                               Copyright © 2020, Gehtsoft USA LLC |
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

#property copyright "Copyright © 2020, Gehtsoft USA LLC"
#property link "http://fxcodebase.com"
#property version "1.0"

#property strict
#property indicator_chart_window

enum TriggerType
{
   TriggerDate, // By date and time
   TriggerBalance, // By Balance
   TriggerEquity, // By Equity
   TriggerMargin, // By Margin
   TriggerTotalPL, // By Total Profit/Loss
   TriggerTradePL, // By Trade Profit/Loss
};

input TriggerType trigger_type = TriggerDate; // Trigger type
input string TemaplateName = "";             // Tmeplate Name
input datetime dt = 0; // Date/time
input double value = 0; // Equity/Balance/PL
input int order_id = 0; // Order

string file_ext = ".tpl";
string template_path = "\\templates\\";

int OnInit()
{
   template_path = TerminalInfoString(TERMINAL_DATA_PATH) + template_path;

   return (INIT_SUCCEEDED);
}

datetime _time;
bool triggered = false;

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
   if (triggered)
   {
      return rates_total;
   }
   switch (trigger_type)
   {
      case TriggerDate:
         if (time[rates_total - 1] >= dt)
         {
            ApplyTemaplte(TemaplateName);
            triggered = true;
         }
         break;
      case TriggerBalance:
         if (AccountBalance() >= value)
         {
            ApplyTemaplte(TemaplateName);
            triggered = true;
         }
         break;
      case TriggerEquity:
         if (AccountEquity() >= value)
         {
            ApplyTemaplte(TemaplateName);
            triggered = true;
         }
         break;
      case TriggerMargin:
         if (AccountMargin() >= value)
         {
            ApplyTemaplte(TemaplateName);
            triggered = true;
         }
         break;
      case TriggerTotalPL:
         if (AccountEquity() - AccountBalance() >= value)
         {
            ApplyTemaplte(TemaplateName);
            triggered = true;
         }
         break;
      case TriggerTradePL:
         {
            if (OrderSelect(order_id, SELECT_BY_TICKET, MODE_TRADES))
            {
               int orderType = OrderType();
               double point = MarketInfo(_Symbol, MODE_POINT);
               int digits = (int)MarketInfo(_Symbol, MODE_DIGITS);
               int mult = digits == 3 || digits == 5 ? 10 : 1;
               double pipSize = point * mult;
               double pl = 0;
               if (orderType == OP_BUY)
               {
                  pl = (OrderClosePrice() - OrderOpenPrice()) / pipSize;
               }
               else
               {
                  pl = (OrderOpenPrice() - OrderClosePrice()) / pipSize;
               }
               double unitCost = MarketInfo(_Symbol, MODE_TICKVALUE);
               double tickSize = MarketInfo(_Symbol, MODE_TICKSIZE);
               double profit = (pl / tickSize) * unitCost * OrderLots();
               if (profit > value)
               {
                  ApplyTemaplte(TemaplateName);
                  triggered = true;
               }
            }
         }
         break;
   }
   return (rates_total);
}
//+------------------------------------------------------------------+

void ApplyTemaplte(string name)
{
   if (ChartApplyTemplate(0, name + file_ext))
   {
      Comment("Template " + name + " successfully loaded");
   }
   else
      Comment("Template load error ", GetLastError());
}

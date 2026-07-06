// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=71371

//+------------------------------------------------------------------------+
//|                                    Copyright © 2021, Gehtsoft USA LLC  |
//|                                                 http://fxcodebase.com  |
//+------------------------------------------------------------------------+
//|                                      Support our efforts by donating   |
//|                                         Paypal: https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------------+
//|                                           Developed by : Mario Jemic   |
//|                                               mario.jemic@gmail.com    |
//|                                https://AppliedMachineLearning.systems  |
//|                                     Patreon :  https://goo.gl/GdXWeN   |
//+------------------------------------------------------------------------+
//|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF         |
//|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D |
//|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C         |
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c |
//|Binance Address (BEP2 only): bnb136ns6lfw4zs5hg4n85vdthaad7hq5m4gtkgf23 |
//|Binance MEMO (BEP2 only)   : 107152697                                  |
//|LiteCoin Address           : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD         |
//+------------------------------------------------------------------------+

#property copyright "Copyright © 2021, Gehtsoft USA LLC"
#property link "http://fxcodebase.com"
#property version "1.0"
#property strict
//based on 2009, Jason Muchow (airforcemook@hotmail.com)"

#property indicator_chart_window

input bool only_this_symbol = true;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   //---- indicators
   run();
   //----
   return (0);
}
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
{
   //----
   deleteIcons();
   //----
   return (0);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
   //----
   run();
   //----
   return (0);
}
//+------------------------------------------------------------------+

void deleteIcons()
{
   for (int i = 0; i <= ObjectsTotal(); i++)
   {
      string name = ObjectName(i);
      if (StringFind(name, "pt_", 0) != -1)
      {
         ObjectDelete(name);
      }
   }
}

void run()
{

   double profit_current, profit_hour, profit_day, profit_week, profit_month;

   profit_current = 0;
   profit_hour = 0;
   profit_day = 0;
   profit_week = 0;
   profit_month = 0;

   int start_hour = iTime(Symbol(), PERIOD_H1, 0);
   int start_day = iTime(Symbol(), PERIOD_D1, 0);
   int start_week = iTime(Symbol(), PERIOD_W1, 0);
   int start_month = iTime(Symbol(), PERIOD_MN1, 0);

   int time_hour = 60 * 60;
   int time_day = time_hour * 24;
   int time_week = time_day * 7;
   int time_month = time_day * 31; //todo fix it so that 30 day months, etc work properly

   int now = TimeCurrent();

   int iter_max = OrdersHistoryTotal();
   double order_profit;
   for (int i = 0; i <= iter_max; i++)
   {
      if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))
      {
         int order_start = OrderOpenTime();
         order_profit = OrderProfit() + OrderSwap();

         if (OrderSymbol() != Symbol() && only_this_symbol)
         {
            // do nothing
         }
         else
         {

            if (order_start >= start_hour)
            {
               profit_hour += order_profit;
            }
            if (order_start >= start_day)
            {
               profit_day += order_profit;
            }
            if (order_start >= start_week)
            {
               profit_week += order_profit;
            }
            if (order_start >= start_month)
            {
               profit_month += order_profit;
            }
         }
      }
   }

   for (int i = 0; i <= OrdersTotal(); i++)
   {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         order_profit = OrderProfit() + OrderSwap() + OrderCommission();

         if (OrderSymbol() != Symbol() && only_this_symbol)
         {
            // do nothing
         }
         else
         {

            profit_current += order_profit;
         }
      }
   }

   // create labels
   string font = "arial";
   string name;

   name = "pt_name";
   ObjectCreate(name, OBJ_LABEL, 200, 200, 200);
   ObjectSetText(name, "Beneficios", 19, font, Black);
   prepare_label(name, 3, 45, 155);

   name = "pt_month";
   ObjectCreate(name, OBJ_LABEL, 200, 200, 200);
   ObjectSetText(name, "Mes", 15, font, Gray);
   prepare_label(name, 3, 55, 135);

   name = "pt_week";
   ObjectCreate(name, OBJ_LABEL, 200, 200, 200);
   ObjectSetText(name, "Semana", 15, font, Gray);
   prepare_label(name, 3, 22, 115);

   name = "pt_day";
   ObjectCreate(name, OBJ_LABEL, 200, 200, 200);
   ObjectSetText(name, "Dia", 15, font, Gray);
   prepare_label(name, 3, 66, 95);

   name = "pt_hour";
   ObjectCreate(name, OBJ_LABEL, 200, 200, 200);
   ObjectSetText(name, "Hora", 15, font, Gray);
   prepare_label(name, 3, 54, 75);

   name = "pt_l1";
   ObjectCreate(name, OBJ_LABEL, 0, 0, 0);
   ObjectSetText(name, "_____________", 15, font, Gray);
   prepare_label(name, 3, 20, 68);

   name = "pt_now";
   ObjectCreate(name, OBJ_LABEL, 0, 0, 0);
   ObjectSetText(name, "%", 19, font, Black);
   prepare_label(name, 3, 28, 40);

   name = "pt_l2";
   ObjectCreate(name, OBJ_LABEL, 0, 0, 0);
   ObjectSetText(name, "__________________", 15, font, Gray);
   prepare_label(name, 3, 0, 33);

   /////////////////
   // Now set prices
   /////////////////
   name = "pt_m$";
   ObjectCreate(name, OBJ_LABEL, 200, 200, 200);
   ObjectSetText(name, money(profit_month), 15, font, SteelBlue);
   if (profit_month <= 0)
   {
      ObjectSet(name, OBJPROP_COLOR, Red);
   }
   prepare_label(name, 3, 100, 135);

   name = "pt_w$";
   ObjectCreate(name, OBJ_LABEL, 200, 200, 200);
   ObjectSetText(name, money(profit_week), 15, font, SteelBlue);
   if (profit_week <= 0)
   {
      ObjectSet(name, OBJPROP_COLOR, Red);
   }
   prepare_label(name, 3, 100, 115);

   name = "pt_d$";
   ObjectCreate(name, OBJ_LABEL, 200, 200, 200);
   ObjectSetText(name, money(profit_day), 15, font, SteelBlue);
   if (profit_day <= 0)
   {
      ObjectSet(name, OBJPROP_COLOR, Red);
   }
   prepare_label(name, 3, 100, 95);

   name = "pt_h$";
   ObjectCreate(name, OBJ_LABEL, 200, 200, 200);
   ObjectSetText(name, money(profit_hour), 15, font, SteelBlue);
   if (profit_hour <= 0)
   {
      ObjectSet(name, OBJPROP_COLOR, Red);
   }
   prepare_label(name, 3, 100, 75);

   name = "pt_n$";
   ObjectCreate(name, OBJ_LABEL, 0, 0, 0);
   ObjectSetText(name, money(profit_current), 19, font, SteelBlue);
   if (profit_current <= 0)
   {
      ObjectSet(name, OBJPROP_COLOR, Red);
   }
   prepare_label(name, 3, 100, 40);
}

void prepare_label(string name, int corner, int x, int y)
{
   ObjectSet(name, OBJPROP_CORNER, corner);
   ObjectSet(name, OBJPROP_XDISTANCE, x);
   ObjectSet(name, OBJPROP_YDISTANCE, y);
}

string money(double value)
{
   double equity = AccountEquity();
   if (equity == 0)
   {
      return "";
   }
   return DoubleToStr(100 * value / equity, 2);
}

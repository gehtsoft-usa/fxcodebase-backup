// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=67234


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

//+------------------------------------------------------------------------------------------------+
//|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |
//|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |
//|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
//|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C                                 |
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |                                                  |   
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2021, Gehtsoft USA LLC"
#property link "http://fxcodebase.com"
#property version "1.0"

#property description " Displays the quotes of another symbol"
#property strict

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots 3
#property indicator_color1 clrBlue

#property indicator_color2 clrOrange
#property indicator_color3 clrOrange
#property indicator_label2 "BUY"
#property indicator_label3 "SELL"

#property indicator_width1 1

input int font_size = 8;
input color ColorBull = DeepSkyBlue;
input color ColorBeer = DeepSkyBlue;
input string font_name = "Arial";
input int BuyFirstAngle = -30;  // First angle
input int BuySecondAngle = -20; // Second angle
input int BuyThirdAngle = -10;  // Third angle
input int SellFirstAngle = 30;  // First angle
input int SellSecondAngle = 20; // Second angle
input int SellThirdAngle = 10;  // Third angle

#define Pi 3.141592653589793238462643

double buy[], sell[], out[];

input string i_symbol = "EURUSD";                   // Symbol
input ENUM_TIMEFRAMES i_tf = PERIOD_CURRENT;        // Timeframe
input ENUM_APPLIED_PRICE i_priceType = PRICE_CLOSE; // Price
input int bars_limit = 10000;                   // Number of bars to display
input bool Inverse = false;
bool g_activate;

double g_point,
    g_delta;

#define ERROR_UNKNOWN_SYMBOL 4301
#define ERROR_SYMBOL_NOT_SELECT 4302
#define ERROR_SYMBOL_PARAMETER 4303
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_MESSAGE_CODE
{
   MESSAGE_CODE_WRONG_SYMBOL,
   MESSAGE_CODE_TERMINAL_FATAL_ERROR1,
   MESSAGE_CODE_BIND_ERROR
};

double g_buffer[];
int ma;
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Custom indicator initialization function                                                                                                                                                          |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
int OnInit()
{
   g_activate = false;
   ma = iMA(i_symbol, i_tf, 1, 0, MODE_SMA, i_priceType);

   if (!TuningParameters())
      return INIT_FAILED;

   if (!BuffersBind())
      return INIT_FAILED;

   g_activate = true;

   return INIT_SUCCEEDED;
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Checking the correctness of values of tuning parameters                                                                                                                                           |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool TuningParameters()
{
   SymbolInfoDouble(i_symbol, SYMBOL_BID);
   int error = GetLastError();
   if (error >= ERROR_UNKNOWN_SYMBOL && error <= ERROR_SYMBOL_PARAMETER)
   {
      Alert(GetStringByMessageCode(MESSAGE_CODE_WRONG_SYMBOL));
      return false;
   }

   g_point = SymbolInfoDouble(Symbol(), SYMBOL_POINT);
   g_delta = -g_point / 10;
   if (g_point == 0)
   {
      Alert(GetStringByMessageCode(MESSAGE_CODE_TERMINAL_FATAL_ERROR1));
      return false;
   }

   return true;
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Custom indicator deinitialization function                                                                                                                                                        |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   IndicatorRelease(ma);
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Binding of array and the indicator buffers                                                                                                                                                        |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool BuffersBind()
{
   int id = 0;
   SetIndexBuffer(id, out, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_LINE);
   ++id;

   SetIndexBuffer(id, buy, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_ARROW);
   PlotIndexSetInteger(id, PLOT_ARROW, 159);
   PlotIndexSetInteger(id, PLOT_ARROW_SHIFT, 5);
   ++id;
   
   SetIndexBuffer(id, sell, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_ARROW);
   PlotIndexSetInteger(id, PLOT_ARROW, 159);
   PlotIndexSetInteger(id, PLOT_ARROW_SHIFT, 5);
   ++id;

   SetIndexBuffer(id, g_buffer, INDICATOR_CALCULATIONS);
   ++id;

   return true;
}

#define ENTER_BUY_SIGNAL 1
#define ENTER_SELL_SIGNAL -1

int GetDirection(const int period)
{
   if (out[period] < BuyFirstAngle && out[period - 1] < BuySecondAngle && out[period - 2] < BuyThirdAngle)
      return ENTER_BUY_SIGNAL;
   if (out[period] > SellFirstAngle && out[period - 1] > SellSecondAngle && out[period - 2] > SellThirdAngle)
      return ENTER_SELL_SIGNAL;

   return 0;
}

//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Custom indicator iteration function                                                                                                                                                               |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
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
   if (prev_calculated <= 0 || prev_calculated > rates_total)
   {
      ArrayInitialize(out, EMPTY_VALUE);
   }
   int first = 1;
   for (int pos = MathMax(rates_total - 1 - bars_limit, MathMax(first, prev_calculated - 1)); pos < rates_total; ++pos)
   {
      double buffer[1];
      if (CopyBuffer(ma, 0, rates_total - 1 - pos, 1, buffer) != 1)
      {
         continue;
      }
      g_buffer[pos] = buffer[0];
      if (Inverse && g_buffer[pos] != 0)
      {
         g_buffer[pos] = 1 / g_buffer[pos];
      }

      double val = g_buffer[pos];
      double val1 = g_buffer[pos - 1];
      double A = val1 - val;
      double C = 5;
      double H = MathSqrt(MathPow(A, 2) + MathPow(C, 2));
      out[pos] = (MathArctan(A / C) * 180.0 / Pi) * (-1);

      int direction = GetDirection(pos);
      switch (direction)
      {
      case ENTER_BUY_SIGNAL:
         buy[pos] = low[pos];
         sell[pos] = EMPTY_VALUE;
         break;
      case ENTER_SELL_SIGNAL:
         buy[pos] = EMPTY_VALUE;
         sell[pos] = high[pos];
         break;
      }
   }

   return rates_total;
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Getting string by code of message and terminal language                                                                                                                                           |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
string GetStringByMessageCode(ENUM_MESSAGE_CODE messageCode)
{

   return GetEnglishMessage(messageCode);
}

//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Getting string by code of message for english language                                                                                                                                            |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
string GetEnglishMessage(ENUM_MESSAGE_CODE messageCode)
{
   switch (messageCode)
   {
   case MESSAGE_CODE_WRONG_SYMBOL:
      return ": unable to find data for specified symbol. The indicator is turned off.";
   case MESSAGE_CODE_TERMINAL_FATAL_ERROR1:
      return ": terminal fatal error - point equals to zero. The indicator is turned off.";
   case MESSAGE_CODE_BIND_ERROR:
      return ": error of binding of the arrays and the indicator buffers. Error N";
   }

   return "";
}
//+------------------------------------------------------------------+
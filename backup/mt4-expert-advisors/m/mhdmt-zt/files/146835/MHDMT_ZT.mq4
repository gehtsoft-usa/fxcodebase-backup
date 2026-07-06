// More information about this indicator can be found at:
// http://fxcodebase.com/ 

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                              Support our efforts by donating   | 
//|                                                                 Paypal: https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+

//Your donations will allow the service to continue onward.
//+------------------------------------------------------------------------------------------------+
//|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
//|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
//|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
//|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
//|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
//|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
//|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
//|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
//+------------------------------------------------------------------------------------------------+




#property copyright "Copyright © 2022, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

#property indicator_chart_window
#property indicator_buffers 8
#property indicator_color1 Red
#property indicator_color2 Lime
#property indicator_color3 Red
#property indicator_color4 Lime
#property indicator_color5 White
#property indicator_color6 Fuchsia
#property indicator_color7 White
#property indicator_color8 Fuchsia

input string T1                    = "== Notifications ==";  // Notifications
input bool   notifications         = false;                  // Notifications On?
input bool   desktop_notifications = false;                  // Desktop MT4 Notifications
input bool   email_notifications   = false;                  // Email Notifications
input bool   push_notifications    = false;                  // Push Mobile Notifications

double g_ibuf_76[];
double g_ibuf_80[];
double g_ibuf_84[];
double g_ibuf_88[];
double g_ibuf_92[];
double g_ibuf_96[];
double g_ibuf_100[];
double g_ibuf_104[];
int gi_108;
string gs_112 = "MHDMT_KDJ_ZT";
string gs_120 = "MHDMT_XMA";
double gd_128 = 2022.0;
double gd_unused_136 = 12.0;
double gd_unused_144 = 31.0;
double gd_unused_152 = 24.0;

class CNewCandle
{
  private:
   int    _initialCandles;
   string _symbol;
   int    _tf;

  public:
   CNewCandle(string symbol, int tf) : _symbol(symbol), _tf(tf), _initialCandles(iBars(symbol, tf)) {}
   CNewCandle()
   {
      // toma los valores del chart actual
      _initialCandles = iBars(Symbol(), Period());
      _symbol         = Symbol();
      _tf             = Period();
   }
   ~CNewCandle() { ; }

   bool IsNewCandle()
   {
      int _currentCandles = iBars(_symbol, _tf);
      if (_currentCandles > _initialCandles)
      {
         _initialCandles = _currentCandles;
         return true;
      }

      return false;
   }
};
CNewCandle newCandle();

int init() {
   IndicatorBuffers(8);
   SetIndexStyle(0, DRAW_HISTOGRAM);
   SetIndexBuffer(0, g_ibuf_76);
   SetIndexStyle(1, DRAW_HISTOGRAM);
   SetIndexBuffer(1, g_ibuf_80);
   SetIndexStyle(2, DRAW_HISTOGRAM, STYLE_SOLID, 3);
   SetIndexBuffer(2, g_ibuf_84);
   SetIndexStyle(3, DRAW_HISTOGRAM, STYLE_SOLID, 3);
   SetIndexBuffer(3, g_ibuf_88);
   SetIndexStyle(4, DRAW_HISTOGRAM);
   SetIndexBuffer(4, g_ibuf_92);
   SetIndexStyle(5, DRAW_HISTOGRAM);
   SetIndexBuffer(5, g_ibuf_96);
   SetIndexStyle(6, DRAW_HISTOGRAM, STYLE_SOLID, 3);
   SetIndexBuffer(6, g_ibuf_100);
   SetIndexStyle(7, DRAW_HISTOGRAM, STYLE_SOLID, 3);
   SetIndexBuffer(7, g_ibuf_104);
   return (0);
}

int start() {
   gi_108 = Bars - IndicatorCounted();
   showKS();
   return (0);
}

void showKS() {
   double icustom_0;
   double icustom_8;
   double ld_16;
   double ld_24;
   double ld_32;
   double ld_40;
   int li_unused_48 = 1;
   if (Year() <= gd_128) {
      for (int i = gi_108; i >= 0; i--) {
         icustom_0 = iCustom(NULL, 0, gs_112, 9, 3, 3, 4, i);
         icustom_8 = iCustom(NULL, 0, gs_112, 9, 3, 3, 4, i + 1);
         ld_16 = MathMax(Open[i], Close[i]);
         ld_24 = MathMin(Open[i], Close[i]);
         ld_32 = 2.0 * iCustom(NULL, 0, gs_120, 25, 25, 3, 1, i) - iCustom(NULL, 0, gs_120, 25, 25, 2, 1, i);
         ld_40 = 2.0 * iCustom(NULL, 0, gs_120, 25, 25, 2, 1, i) - iCustom(NULL, 0, gs_120, 25, 25, 3, 1, i);
         if (icustom_0 >= icustom_8) {
            g_ibuf_76[i] = High[i];
            g_ibuf_80[i] = Low[i];
            g_ibuf_84[i] = ld_16;
            g_ibuf_88[i] = ld_24;
         }
         if (icustom_0 <= icustom_8) {
            g_ibuf_76[i] = Low[i];
            g_ibuf_80[i] = High[i];
            g_ibuf_84[i] = ld_24;
            g_ibuf_88[i] = ld_16;
         }
         if (Low[i] < ld_32 && High[i] > ld_32) {
            g_ibuf_92[i] = ld_32;
            g_ibuf_96[i] = Low[i];
            g_ibuf_100[i] = ld_32;
            g_ibuf_104[i] = Low[i];
         }
         if (High[i] < ld_32) {
            g_ibuf_92[i] = High[i];
            g_ibuf_96[i] = Low[i];
            g_ibuf_100[i] = ld_16;
            g_ibuf_104[i] = ld_24;
         }
         if (Low[i] < ld_32 && High[i] > ld_32 && icustom_0 > icustom_8) {
            g_ibuf_92[i] = Low[i];
            g_ibuf_96[i] = ld_32;
            g_ibuf_100[i] = Low[i];
            g_ibuf_104[i] = ld_32;
         }
         if (High[i] < ld_32 && icustom_0 > icustom_8) {
            g_ibuf_92[i] = Low[i];
            g_ibuf_96[i] = High[i];
            g_ibuf_100[i] = ld_24;
            g_ibuf_104[i] = ld_16;
         }
         if (Low[i] < ld_40 && High[i] > ld_40) {
            g_ibuf_92[i] = High[i];
            g_ibuf_96[i] = ld_40;
            g_ibuf_100[i] = High[i];
            g_ibuf_104[i] = ld_40;
         }
         if (Low[i] > ld_40) {
            g_ibuf_92[i] = High[i];
            g_ibuf_96[i] = Low[i];
            g_ibuf_100[i] = ld_16;
            g_ibuf_104[i] = ld_24;
         }
         if (Low[i] < ld_40 && High[i] > ld_40 && icustom_0 < icustom_8) {
            g_ibuf_92[i] = ld_40;
            g_ibuf_96[i] = High[i];
            g_ibuf_100[i] = ld_40;
            g_ibuf_104[i] = High[i];
         }
         if (Low[i] > ld_40 && icustom_0 < icustom_8) {
            g_ibuf_92[i] = Low[i];
            g_ibuf_96[i] = High[i];
            g_ibuf_100[i] = ld_24;
            g_ibuf_104[i] = ld_16;
         }

         if (newCandle.IsNewCandle()){ 
					 if(g_ibuf_92[1] != g_ibuf_104[1]) Notifications(0);
				 }
      }
   }
}

void Notifications(int type)
{
   string text = "";
   if (type == 0)
      text += _Symbol + " " + GetTimeFrame(_Period) + " ALERT ";
   else
      text += _Symbol + " " + GetTimeFrame(_Period) + " SELL ";

   text += " ";

   if (!notifications)
      return;
   if (desktop_notifications)
      Alert(text);
   if (push_notifications)
      SendNotification(text);
   if (email_notifications)
      SendMail("MetaTrader Notification", text);
}

string GetTimeFrame(int lPeriod)
{
   switch (lPeriod)
   {
      case PERIOD_M1:
         return ("M1");
      case PERIOD_M5:
         return ("M5");
      case PERIOD_M15:
         return ("M15");
      case PERIOD_M30:
         return ("M30");
      case PERIOD_H1:
         return ("H1");
      case PERIOD_H4:
         return ("H4");
      case PERIOD_D1:
         return ("D1");
      case PERIOD_W1:
         return ("W1");
      case PERIOD_MN1:
         return ("MN1");
   }
   return IntegerToString(lPeriod);
}

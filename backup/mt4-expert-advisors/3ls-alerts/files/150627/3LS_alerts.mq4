//Available @ http://fxcodebase.com

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                                       https://mario-jemic.com/ |
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+


#property copyright "Copyright © 2023, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict
#property indicator_chart_window

#property indicator_buffers 2
#property indicator_type1   DRAW_ARROW
#property indicator_width1  1
#property indicator_color1  clrDarkSeaGreen
#property indicator_type2   DRAW_ARROW
#property indicator_width2  1
#property indicator_color2  clrTomato

input bool showBear3LS = true; //Show Bearish 3 Line Strike
input bool showBull3LS = true; //Show Bullish 3 Line Strike
//--- 
input string T1                    = "== Notifications ==";  // ————————————
input bool   notifications         = false;                  // Notifications On?
input bool   desktop_notifications = false;                  // Desktop MT4 Notifications
input bool   email_notifications   = false;                  // Email Notifications
input bool   push_notifications    = false;                  // Push Mobile Notifications
//--- 
double up[], dn[];
string obj_prefix = "3LS_";

// ------------------------------------------------------------------
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
// ------------------------------------------------------------------

int OnInit() 
{
   IndicatorDigits(Digits);
   SetIndexLabel(0, "up");
   SetIndexBuffer(0, up);
   SetIndexArrow(0, 233);
   SetIndexLabel(1, "dn");
   SetIndexBuffer(1, dn);
   SetIndexArrow(1, 234);

   return(INIT_SUCCEEDED);
}

int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[],
                const double &low[], const double &close[], const long &tick_volume[], const long &volume[], const int &spread[]) {

   int startPos = rates_total-prev_calculated-4;
   if (startPos <= 1) { startPos = 1; }
   
   for(int pos=startPos; pos>=0; pos--) {
      up[pos]  = is3LSBull(pos) ?  Low[pos] : EMPTY_VALUE;
      dn[pos]  = is3LSBear(pos) ? High[pos] : EMPTY_VALUE;
			
			if (newCandle.IsNewCandle()&& up[pos+1]!= EMPTY_VALUE) Notifications(0);
			if (newCandle.IsNewCandle()&& dn[pos+1]!= EMPTY_VALUE) Notifications(1);
   }

   return(rates_total);
}

void OnDeinit(const int reason) {
   ObjectsDeleteAll(0, obj_prefix);
}

int price_diff(double price1, double price2, string _pair = "", bool abs = true) {
   if (_pair == "") { _pair = Symbol(); }
   double _point = MarketInfo(_pair, MODE_POINT);
   
   double p = price1-price2;
   if (abs == true) { p = MathAbs(p); }
   p = NormalizeDouble(p/_point, 0);
   string s = DoubleToStr(p, 0);
   int diff = (int) StringToInteger(s);
   
   return diff;
}

int getCandleColorIndex(int pos) {
   return (Close[pos] > Open[pos]) ? 1 : (Close[pos] < Open[pos]) ? -1 : 0;
}

bool isEngulfing(int pos, bool checkBearish) {
   bool ret = false;
   int sizePrevCandle = price_diff(Close[pos+1], Open[pos+1]);
   int sizeCurrentCandle = price_diff(Close[pos], Open[pos]);
   bool isCurrentLagerThanPrevious = sizeCurrentCandle > sizePrevCandle ? true : false;
   
   if (checkBearish == true) {
      bool isGreenToRed = getCandleColorIndex(pos) < 0 && getCandleColorIndex(pos+1) > 0 ? true : false;
      ret = isCurrentLagerThanPrevious == true && isGreenToRed == true ? true : false;
   }
   else {
      bool isRedToGreen = getCandleColorIndex(pos) > 0 && getCandleColorIndex(pos+1) < 0 ? true : false;
      ret = isCurrentLagerThanPrevious == true && isRedToGreen == true ? true : false;
   }
   
   return ret;
}

bool isBearishEngulfuing(int pos) {
   return isEngulfing(pos, true);
}

bool isBullishEngulfuing(int pos) {
   return isEngulfing(pos, false);
}

bool is3LSBear(int pos) {
   bool ret = false;
   
   bool is3LineSetup = ((getCandleColorIndex(pos+1) > 0) && (getCandleColorIndex(pos+2) > 0) && (getCandleColorIndex(pos+3) > 0)) ? true : false;
   ret = (is3LineSetup == true && isBearishEngulfuing(pos)) ? true : false;
   
   return ret;
}

bool is3LSBull(int pos) {
   bool ret = false;
   
   bool is3LineSetup = ((getCandleColorIndex(pos+1) < 0) && (getCandleColorIndex(pos+2) < 0) && (getCandleColorIndex(pos+3) < 0)) ? true : false;
   ret = (is3LineSetup == true && isBullishEngulfuing(pos)) ? true : false;
   
   return ret;
}

void Notifications(int type)
{
   string text = "";
   if (type == 0)
      text += _Symbol + " " + GetTimeFrame(_Period) + " BUY ";
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
//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                                       https://mario-jemic.com/ |
//+------------------------------------------------------------------------------------------------+

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
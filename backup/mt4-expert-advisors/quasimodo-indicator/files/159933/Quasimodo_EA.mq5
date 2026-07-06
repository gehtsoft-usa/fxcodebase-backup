//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=72707&p=159933#p159933

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC   | 
// |                                                                         http://fxcodebase.com   |
// |                                                               PayPal: https://goo.gl/9Rj74e     |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by: Mario Jemic     |                    
// |                                                                     mario.jemic@gmail.com       |
// |                                                                 https://mario-jemic.com/        | 
// |                                                             Patreon: http://tiny.cc/1ybwxz      |   
// |                                                      Buy Me a Coffee: http://tiny.cc/bj7vxz     |  
// +-----------------+----------------------+---------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                                |
// +-----------------+----------------------+---------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                     | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2           | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// +-----------------+----------------------+---------------------------------------------------------+


#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"


#include <Trade/Trade.mqh>
CTrade trade;

input string IND_PARAM = "---- Indicator Settings ----";
input int FractalBars = 100; // Số nến phân tích fractal
input color LongColor = clrLimeGreen; // Màu lệnh mua
input color ShortColor = clrDarkOrange; // Màu lệnh bán

input string TRADE_PARAM = "---- Trade Settings ----";
input double LotSize = 0.1;
input int MaxSpread = 15; // Spread tối đa (point)
input int StopLoss = 50; // Điểm SL
input int TakeProfit = 150; // Điểm TP
input bool UseTrailingStop = true;
input int TrailingStep = 30; // Bước trailing (point)
input int MagicNumber           = 5050;
input bool Use_reverse = false;             // Đảo ngược tín hiệu giao dịch
input bool Use_close_on_reverse = false;    // Đóng lệnh đối lập khi đảo chiều
input int max_trades = 1;                   // Số lệnh tối đa mỗi hướng
input int bars_between_trades = 1;          // Số nến tối thiểu giữa các lệnh
input int seconds_between_trades = 120;     // Thời gian tối thiểu giữa các lệnh (giây)
input bool Use_acct_pct_for_lots = false;    // Sử dụng % tài khoản để tính lot
input double lot_acct_multi = 0.5;           // Hệ số nhân % tài khoản

// Biến toàn cục
datetime lastBar;
int fractalHandle;
double highs[], lows[], closes[];
bool patternDetected = false;
ENUM_POSITION_TYPE lastSignal;
// Biến quản lý lệnh
int buys = 0, sells = 0;
datetime LastBuyTime = 0, LastSellTime = 0;
int buy_candle = 0, sell_candle = 0;

//+------------------------------------------------------------------+
int OnInit() {
   fractalHandle = iFractals(_Symbol, _Period);
   ArraySetAsSeries(highs, true);
   ArraySetAsSeries(lows, true);
   ArraySetAsSeries(closes, true);
   trade.SetExpertMagicNumber(MagicNumber);
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
   IndicatorRelease(fractalHandle);
}

//+------------------------------------------------------------------+
void OnTick() {
   if(!isNewBar()) return;
   
   // Kiểm tra spread
   if(GetSpread() > MaxSpread) return;
   
   // Cập nhật dữ liệu
   CopyClose(_Symbol, _Period, 0, FractalBars, closes);
   CopyHigh(_Symbol, _Period, 0, FractalBars, highs);
   CopyLow(_Symbol, _Period, 0, FractalBars, lows);
   
   // Cập nhật số lệnh hiện tại
   CountCurrentPositions();
   
   // Cập nhật số nến hiện tại
   int current_bar = Bars(_Symbol, _Period);
   
   // Tìm mẫu fractal
   CheckFractalPattern();
   
   // Áp dụng đảo ngược tín hiệu nếu cần
   if(Use_reverse && patternDetected) {
      lastSignal = (lastSignal == POSITION_TYPE_BUY) ? POSITION_TYPE_SELL : POSITION_TYPE_BUY;
   }
   
   // Quản lý lệnh
   ManagePositions(current_bar);
}

//+------------------------------------------------------------------+
bool CheckFractalPattern() {
   patternDetected = false;
   double upper[], lower[];
   ArraySetAsSeries(upper, true);
   ArraySetAsSeries(lower, true);
   
   if(CopyBuffer(fractalHandle, 0, 0, FractalBars, upper) < 0 ||
      CopyBuffer(fractalHandle, 1, 0, FractalBars, lower) < 0) return false;
   int totalFractals = 0;
   double fractals[];
   int directions[];
   ArrayResize(fractals, FractalBars*2);
   ArrayResize(directions, FractalBars*2);
   
   for(int i=0; i<FractalBars; i++) {
      if(upper[i] != EMPTY_VALUE) {
         fractals[totalFractals] = upper[i];
         directions[totalFractals] = 1;
         totalFractals++;
      }
      if(lower[i] != EMPTY_VALUE) {
         fractals[totalFractals] = lower[i];
         directions[totalFractals] = -1;
         totalFractals++;
      }
   }
   
   // Kiểm tra ít nhất 4 fractal
   if(totalFractals >= 4) {
      // Mẫu mua: 1, -1, 1, -1
      if(directions[0]==1 && directions[1]==-1 && directions[2]==1 && directions[3]==-1 &&
         closes[0] < fractals[0] && closes[0] > fractals[1] && closes[0] < fractals[2] && closes[0] > fractals[3] &&
         fractals[0] > fractals[1] && fractals[0] > fractals[2] && fractals[0] > fractals[3] &&
         fractals[1] < fractals[2] && fractals[1] < fractals[3]) {
         patternDetected = true;
         lastSignal = POSITION_TYPE_BUY;
      }
      // Mẫu bán: -1, 1, -1, 1
      else if(directions[0]==-1 && directions[1]==1 && directions[2]==-1 && directions[3]==1 &&
              closes[0] > fractals[0] && closes[0] < fractals[1] && closes[0] > fractals[2] && closes[0] < fractals[3] &&
              fractals[0] < fractals[1] && fractals[0] < fractals[2] && fractals[0] < fractals[3] &&
              fractals[1] > fractals[2] && fractals[1] > fractals[3]) {
         patternDetected = true;
         lastSignal = POSITION_TYPE_SELL;
      }
   }
   return patternDetected;
}

//+------------------------------------------------------------------+
void ManagePositions(int current_bar) {
   if(!patternDetected) return;
   
   // Kiểm tra điều kiện đóng lệnh đối lập
   if(Use_close_on_reverse) {
      if(lastSignal == POSITION_TYPE_BUY && sells > 0) {
         CloseAllPositionsOfType(POSITION_TYPE_SELL);
      }
      else if(lastSignal == POSITION_TYPE_SELL && buys > 0) {
         CloseAllPositionsOfType(POSITION_TYPE_BUY);
      }
   }
   
   // Tính toán khối lượng
   double volume = CalculateLotSize();
   if(volume <= 0) return;
   
   // Kiểm tra điều kiện thời gian
   datetime current_time = TimeCurrent();
   bool time_ok = true;
   
   if(lastSignal == POSITION_TYPE_BUY) {
      time_ok = (current_time - LastBuyTime >= seconds_between_trades);
   }
   else {
      time_ok = (current_time - LastSellTime >= seconds_between_trades);
   }
   
   // Kiểm tra điều kiện giao dịch
   bool trade_allowed = false;
   if(lastSignal == POSITION_TYPE_BUY) {
      trade_allowed = (buys < max_trades) && 
                     (current_bar - buy_candle >= bars_between_trades) && 
                     time_ok;
   }
   else {
      trade_allowed = (sells < max_trades) && 
                     (current_bar - sell_candle >= bars_between_trades) && 
                     time_ok;
   }
   
   if(!trade_allowed) return;
   
   double sl = 0, tp = 0;
   double price = SymbolInfoDouble(_Symbol, lastSignal==POSITION_TYPE_BUY ? SYMBOL_ASK : SYMBOL_BID);
   
   // Tính SL/TP
   if(lastSignal == POSITION_TYPE_BUY) {
      sl = price - StopLoss * _Point;
      tp = price + TakeProfit * _Point;
   } else {
      sl = price + StopLoss * _Point;
      tp = price - TakeProfit * _Point;
   }
   
   bool trade_success = false;
   // Vào lệnh
   if(lastSignal == POSITION_TYPE_BUY) {
      trade_success = trade.Buy(volume, _Symbol, price, sl, tp);
   } else {
      trade_success = trade.Sell(volume, _Symbol, price, sl, tp);
   }
   
   // Cập nhật thời gian và nến sau khi vào lệnh
   if(trade_success) {
      if(lastSignal == POSITION_TYPE_BUY) {
         LastBuyTime = current_time;
         buy_candle = current_bar;
      }
      else {
         LastSellTime = current_time;
         sell_candle = current_bar;
      }
   }
   
   // Trailing stop
   if(UseTrailingStop) ApplyTrailingStop(TrailingStep);
}

//+------------------------------------------------------------------+
bool isNewBar() {
   datetime currentBar = iTime(_Symbol, _Period, 0);
   if(currentBar != lastBar) {
      lastBar = currentBar;
      return true;
   }
   return false;
}

//+------------------------------------------------------------------+
int GetSpread() {
   return (int)SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
}

//+------------------------------------------------------------------+
void ApplyTrailingStop(int step) {
   for(int i=PositionsTotal()-1; i>=0; i--) {
      if(PositionGetSymbol(i) == _Symbol) {
         ulong ticket = PositionGetTicket(i);
         double currentSl = PositionGetDouble(POSITION_SL);
         double currentPrice = PositionGetDouble(POSITION_PRICE_CURRENT);
         
         if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) {
            double newSl = currentPrice - step * _Point;
            if(newSl > currentSl) trade.PositionModify(ticket, newSl, 0);
         }
         else {
            double newSl = currentPrice + step * _Point;
            if(newSl < currentSl) trade.PositionModify(ticket, newSl, 0);
         }
      }
   }
}

void CloseAllPositionsOfType(ENUM_POSITION_TYPE type) {
   
   for(int i = PositionsTotal()-1; i >= 0; i--) {
      ulong ticket = PositionGetTicket(i);
      if(PositionGetString(POSITION_SYMBOL) == _Symbol && 
         PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
         PositionGetInteger(POSITION_TYPE) == type)
      {
         trade.PositionClose(ticket);
      }
   }
}
double CalculateLotSize() {
   double lot = LotSize;
   
   if(Use_acct_pct_for_lots) {
      double balance = AccountInfoDouble(ACCOUNT_BALANCE);
      lot = NormalizeDouble(balance * lot_acct_multi / 1000.0, 2);
   }
   
   // Kiểm tra lot tối thiểu/tối đa
   double min_lot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double max_lot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   
   lot = fmax(lot, min_lot);
   lot = fmin(lot, max_lot);
   
   return lot;
}

void CountCurrentPositions() {
   buys = 0;
   sells = 0;
   
   for(int i = PositionsTotal()-1; i >= 0; i--) {
      ulong ticket = PositionGetTicket(i);
      if(PositionGetString(POSITION_SYMBOL) == _Symbol && 
         PositionGetInteger(POSITION_MAGIC) == MagicNumber) 
      {
         ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
         if(type == POSITION_TYPE_BUY) buys++;
         if(type == POSITION_TYPE_SELL) sells++;
      }
   }
}
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=72707&p=159933#p159933

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC   | 
// |                                                                         http://fxcodebase.com   |
// |                                                               PayPal: https://goo.gl/9Rj74e     |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by: Mario Jemic     |                    
// |                                                                     mario.jemic@gmail.com       |
// |                                                                 https://mario-jemic.com/        | 
// |                                                             Patreon: http://tiny.cc/1ybwxz      |   
// |                                                      Buy Me a Coffee: http://tiny.cc/bj7vxz     |  
// +-----------------+----------------------+---------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                                |
// +-----------------+----------------------+---------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                     | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2           | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// +-----------------+----------------------+---------------------------------------------------------+
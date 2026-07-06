// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=76196

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

#property description "FEAST_MINI BAND"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2

#property indicator_label1  "UP"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

#property indicator_label2  "DOWN"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

input string Stochastic = "Configure Stochastic Settings";
input int KPeriod = 5;
input int DPeriod = 3;
input int Slowing = 3;
input int OverBought = 80;
input int OverSold = 20;
input string Alerts  = "Configure Alerts";
input bool PopUpAlert = false;    //Popup Alert
input bool EmailAlert = false;   //Email Alert
input bool PushAlert  = false;  //Push Notifications Alert

double UP[];
double DOWN[];
int distance = 3;
double MyPoint;
datetime CTime;

int stoch_handle;

int OnInit()
{
   SetIndexBuffer(0, UP, INDICATOR_DATA);
   SetIndexBuffer(1, DOWN, INDICATOR_DATA);
   
   PlotIndexSetInteger(0, PLOT_ARROW, 225);
   PlotIndexSetInteger(1, PLOT_ARROW, 226);
   
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, 0.0);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, 0.0);
   
   PlotIndexSetInteger(0, PLOT_ARROW_SHIFT, -distance);
   PlotIndexSetInteger(1, PLOT_ARROW_SHIFT, distance);
   
   if (_Digits == 5 || _Digits == 3) {
      MyPoint = _Point * 10;
   } else {
      MyPoint = _Point;
   }
   
   stoch_handle = iStochastic(_Symbol, _Period, KPeriod, DPeriod, Slowing, MODE_SMA, STO_LOWHIGH);
   if(stoch_handle == INVALID_HANDLE) {
      Print("Error creating Stochastic handle");
      return(INIT_FAILED);
   }
   
   CTime = 0;
   
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   if(stoch_handle != INVALID_HANDLE)
      IndicatorRelease(stoch_handle);
   
   Comment("");
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
   int calculated = BarsCalculated(stoch_handle);
   if(calculated < rates_total) {
      return(0);
   }
   
   double stoch_main[];
   ArraySetAsSeries(stoch_main, true);
   
   ArraySetAsSeries(UP, true);
   ArraySetAsSeries(DOWN, true);
   ArraySetAsSeries(time, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   
   int limit;
   if(prev_calculated < 1) {
      limit = rates_total - 2;
      ArrayInitialize(UP, 0.0);
      ArrayInitialize(DOWN, 0.0);
   } else {
      limit = rates_total - prev_calculated + 1;
   }
   
   if(CopyBuffer(stoch_handle, 0, 0, limit + 2, stoch_main) < 0) {
      return(0);
   }
   
   for(int i = limit; i >= 0; i--) {
      double Stoch1 = stoch_main[i];
      double Stoch2 = stoch_main[i + 1];
      
      UP[i] = 0.0;
      DOWN[i] = 0.0;
      
      if(Stoch1 > OverSold && Stoch2 < OverSold) {
         UP[i] = low[i] - distance * MyPoint;
         
         if(i == 0 && CTime != time[0]) {
            if(PopUpAlert) Alert(_Symbol, " ", "Mini Buy");
            if(EmailAlert) SendMail(_Symbol + " Mini Buy", "Mini Buy Signal");
            if(PushAlert) SendNotification(_Symbol + " Mini Buy");
            CTime = time[0];
         }
      }
      
      if(Stoch1 < OverBought && Stoch2 > OverBought) {
         DOWN[i] = high[i] + distance * MyPoint;
         
         if(i == 0 && CTime != time[0]) {
            if(PopUpAlert) Alert(_Symbol, " ", "Mini Sell");
            if(EmailAlert) SendMail(_Symbol + " Mini Sell", "Mini Sell");
            if(PushAlert) SendNotification(_Symbol + " Mini Sell");
            CTime = time[0];
         }
      }
   }
   
   return(rates_total);
}
// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=76196

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

//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75678

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC  | 
// |                                                                         http://fxcodebase.com  |
// |                                                               Paypal:  https://goo.gl/9Rj74e   |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by : Mario Jemic   |                    
// |                                                                       mario.jemic@gmail.com    |
// |                                                                       https://mario-jemic.com/ | 
// |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
// |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
// +-----------------+----------------------+-------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                              |
// +-----------------+----------------------+-------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// +-----------------+----------------------+-------------------------------------------------------+ 


#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red
//---- input parameters
extern int       NumBars = 500;
extern int       EnableAlerts = 1;
extern int       EnablePushAlerts = 1;
extern int       SignalID = 0;
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double spread;
static    double    tsig = 0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0, DRAW_ARROW);
   SetIndexBuffer(0, ExtMapBuffer1);
   SetIndexArrow(0, 233);
   SetIndexEmptyValue(0, 0.0);
   SetIndexStyle(1, DRAW_ARROW);
   SetIndexBuffer(1, ExtMapBuffer2);
   SetIndexArrow(1, 234);
   SetIndexEmptyValue(1, 0.0);
   spread = MarketInfo(Symbol(), MODE_SPREAD) * Point;
   SetIndexDrawBegin(0, 0);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars = IndicatorCounted();
//----
   int       artp = 7;
   double    dartp = 7.0;
   double    cecf = 0.7;
   int       satb = 0;
   int       Shift = 0;
   bool      river = True;
   double    Emaxtra = 0;
   double    widcha = 0;
   double    TR = 0;
   double    Values[100];
   int       glava = 0;
   double    ATR = 0;
   int       J = 0;
   double    Weight = 0;
   double    r = 0;
   double    r1 = 0;
   int       p = 0;
   int       Curr = 0;
   double    Range1 = 0;
   double    s = 2;
   double    f = 10;
   double    val1 = 0;
   double    val2 = 0;
   double    h11 = 0;
   double    h12 = 0;
   double    h13 = 0;
   double    const1 = 0;
   double    orig = 0;
   double    st = 0;
   double    h2 = 0;
   double    h1 = 0;
   double    h10 = 0;
   double    sxs = 0;
   double    sms = 0;
   double    temp = 0;
   double    h5 = 0;
   double    r1s = 0;
   double    r2s = 0;
   double    r3s = 0;
   double    r4s = 0;
   double    pt = 0;
   double    pts = 0;
   double    r2 = 0;
   double    r3 = 0;
   double    r4 = 0;
   double    tt = 0;
   if(Bars < NumBars)
      satb = Bars;
   else
      satb = NumBars;
   if(Close[satb - 2] > Close[satb - 1])
      river = True;
   else
      river = False;
   Emaxtra = Close[satb - 2];
   Shift = satb - 3;
   while(Shift >= 0)
     {
      TR = spread + High[Shift] - Low[Shift];
      if(MathAbs(spread + High[Shift] - Close[Shift + 1]) > TR)
         TR = MathAbs(spread + High[Shift] - Close[Shift + 1]);
      if(MathAbs(Low[Shift] - Close[Shift + 1]) > TR)
         TR = MathAbs(Low[Shift] - Close[Shift + 1]);
      if(Shift == satb - 3)
        {
         for(J = 0; Shift <= artp - 1; J++)
           {
            Values[J] = TR;
           }
        }
      Values[glava] = TR;
      ATR = 0;
      Weight = artp;
      Curr = glava;
      for(J = 0; J <= artp - 1; J++)
        {
         ATR += Values[Curr] * Weight;
         Weight -= 1.0;
         Curr--;
         if(Curr == -1)
            Curr = artp - 1;
        }
      ATR = 2.0 * ATR / (dartp * (dartp + 1.0));
      glava++;
      if(glava == artp)
         glava = 0;
      widcha = cecf * ATR;
      if(river && Low[Shift] < Emaxtra - widcha)
        {
         river = False;
         Emaxtra = spread + High[Shift];
        }
      if(!river && spread + High[Shift] > Emaxtra + widcha)
        {
         river = True;
         Emaxtra = Low[Shift];
        }
      if(river && Low[Shift] > Emaxtra)
        {
         Emaxtra = Low[Shift];
        }
      if(!river && spread + High[Shift] < Emaxtra)
        {
         Emaxtra = spread + High[Shift];
        }
      Range1 = iATR(NULL, 0, 10, Shift);
      val1 = 0;
      val2 = 0;
      if(river)
        {
         if(p != 1)
            r1 = Low[Shift] - Range1 * s / 3.0;
         if(p == 1)
            r1 = -1.0;
         if(r1 > 0)
           {
            val1 = r1;
            val2 = 0;
           }
         else
           {
            val1 = 0;
            val2 = 0;
           }
         ExtMapBuffer1[Shift] = val1;
         p = 1;
        }
      else
        {
         if(p != 2)
            r1 = spread + High[Shift] + Range1 * s / 3.0;
         if(p == 2)
            r1 = -1.0;
         if(r1 > 0)
           {
            val1 = 0;
            val2 = r1;
           }
         else
           {
            val1 = 0;
            val2 = 0;
           }
         ExtMapBuffer2[Shift] = val2;
         p = 2;
        }
      Shift--;
     }
   if(EnableAlerts == 1)
     {
     string text;
      if(val1 > 0 && tsig != 1)
        {
         tsig = 1;
         text = Symbol()+ " "+ Period()+ " Alert!! BUY NOW !!";
         Alert(text);
         if(EnablePushAlerts)
            SendNotification(text);
        }
      if(val2 > 0 && tsig != 2)
        {
         tsig = 2;
         text = Symbol()+ " "+ Period()+ " Alert!! SELL NOW !!";
         Alert(text);
         if(EnablePushAlerts)
            SendNotification(text);
        }
     }
   return(0);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75678

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC  | 
// |                                                                         http://fxcodebase.com  |
// |                                                               Paypal:  https://goo.gl/9Rj74e   |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by : Mario Jemic   |                    
// |                                                                       mario.jemic@gmail.com    |
// |                                                                       https://mario-jemic.com/ | 
// |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
// |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
// +-----------------+----------------------+-------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                              |
// +-----------------+----------------------+-------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// +-----------------+----------------------+-------------------------------------------------------+ 
// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=72347


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
#property indicator_buffers 2
#property indicator_color1 Lime
#property indicator_color2 Lime

datetime  NewCandleTimeCurrent;
extern int Risk = 3;
extern double ArrowsGap = 1.0;
double G_ibuf_88[];
double G_ibuf_92[];
double G_ibuf_96[];
extern bool   alert_send_notification   =  false;  //   Alert / Send Notification


string   UpcommingSignal    =    "NONE";
string capture_recent_time  =  0 ;


// E37F0136AA3FFAF149B351F6A4C948E9
int init()
  {
   capture_recent_time   =   Time[1];
   IndicatorBuffers(3);
   SetIndexBuffer(0, G_ibuf_88);
   SetIndexStyle(0, DRAW_ARROW);
   SetIndexArrow(0, 234);
   SetIndexBuffer(1, G_ibuf_92);
   SetIndexStyle(1, DRAW_ARROW);
   SetIndexArrow(1, 233);
   SetIndexBuffer(2, G_ibuf_96);
   return (0);
  }

// EA2B2676C28C0DB26D39331A336C6B92
int start()
  {

   if(IsNewCandleCurrent())
     {
      int period_28;
      double Ld_32;
      bool Li_44;
      bool Li_48;
      int Li_0 = IndicatorCounted();
      if(Li_0 < 0)
         return (-1);
      if(Li_0 > 0)
         Li_0--;
      int Li_4 = MathMin(Bars - Li_0, Bars - 1);
      double Ld_8 = Risk + 67.0;
      double Ld_16 = 33.0 - Risk;
      for(int Li_24 = Li_4; Li_24 >= 1; Li_24--)
        {
         period_28 = Risk * 2 + 3;
         Ld_32 = 0;
         for(int count_40 = 0; count_40 < 10; count_40++)
            Ld_32 += High[Li_24 + count_40] - (Low[Li_24 + count_40]);
         Ld_32 /= 10.0;
         Li_44 = FALSE;
         for(count_40 = 0; count_40 < 6 && !Li_44; count_40++)
            Li_44 = MathAbs(Open[Li_24 + count_40] - (Close[Li_24 + count_40 + 1])) >= 2.0 * Ld_32;
         Li_48 = FALSE;
         for(count_40 = 0; count_40 < 9 && !Li_48; count_40++)
            Li_48 = MathAbs(Close[Li_24 + count_40 + 3] - (Close[Li_24 + count_40])) >= 4.6 * Ld_32;
         if(Li_44)
            period_28 = 3;
         if(Li_48)
            period_28 = 4;
         G_ibuf_96[Li_24] = iWPR(NULL, 0, period_28, Li_24) + 100.0;
         G_ibuf_88[Li_24] = EMPTY_VALUE;
         G_ibuf_92[Li_24] = EMPTY_VALUE;
         string  capture_time;
         if(G_ibuf_96[Li_24] < Ld_16)
           {
            for(count_40 = 1; Li_24 + count_40 < Bars && G_ibuf_96[Li_24 + count_40] >= Ld_16 && G_ibuf_96[Li_24 + count_40] <= Ld_8; count_40++)
              {
              }
            if(G_ibuf_96[Li_24 + count_40] > Ld_8)
              {

               G_ibuf_88[Li_24] = High[Li_24] + Ld_32 * ArrowsGap;

               if(alert_send_notification    == true)
                 {
                  //  Buying  Goes Here
                  capture_time =    Time[Li_24];
                  if(StringCompare(capture_recent_time,  capture_time) == -1   && (UpcommingSignal    ==  "NONE"  || UpcommingSignal  ==  "BUY"))
                    {
                     UpcommingSignal    =   "SELL";
                     Alert("Symbol :",    Symbol(),   " Selling")  ;
                     SendNotification("Symbol :"   +   Symbol()    +     " Selling");

                    }


                 }

               //


              }
           }
         if(G_ibuf_96[Li_24] > Ld_8)
           {
            for(count_40 = 1; Li_24 + count_40 < Bars && G_ibuf_96[Li_24 + count_40] >= Ld_16 && G_ibuf_96[Li_24 + count_40] <= Ld_8; count_40++)
              {
              }
            if(G_ibuf_96[Li_24 + count_40] < Ld_16)
              {

               G_ibuf_92[Li_24] = Low[Li_24] - Ld_32 * ArrowsGap;
               if(alert_send_notification     ==  true)
                 {
                  //Selling  Goes Here
                  capture_time =    Time[Li_24];
                  if(StringCompare(capture_recent_time,  capture_time) == -1  && (UpcommingSignal    ==  "NONE"  || UpcommingSignal  ==  "SELL"))
                    {
                     UpcommingSignal    =   "BUY";
                     Alert("Symbol :",    Symbol(),   " Buying")  ;
                     SendNotification("Symbol :"  +     Symbol()   +   " Buying");
                    }
                 }


              }
           }
        }


     }
   return (0);
  }





//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsNewCandleCurrent()
  {
   if(NewCandleTimeCurrent == iTime(Symbol(), PERIOD_CURRENT, 0))
      return false;
   else
     {
      NewCandleTimeCurrent = iTime(Symbol(), PERIOD_CURRENT, 0);
      return true;
     }
  }
//+------------------------------------------------------------------+

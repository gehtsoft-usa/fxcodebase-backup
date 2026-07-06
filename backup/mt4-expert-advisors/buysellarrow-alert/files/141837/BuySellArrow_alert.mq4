// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=71159


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

//+------------------------------------------------------------------------+
//|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF         |
//|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D |
//|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C         |
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c |  
//|Binance Address (BEP2 only): bnb136ns6lfw4zs5hg4n85vdthaad7hq5m4gtkgf23 |
//|Binance MEMO (BEP2 only)   : 107152697                                  |   
//|LiteCoin Address           : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD         |  
//+------------------------------------------------------------------------+


#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Lime
#property indicator_color2 Red

double CrossUp[];
double CrossDown[];
input int FasterMovingAverage = 5;
input int SlowerMovingAverage = 200;
input int RSIPeriod = 12;
input int MagicFilterPeriod = 14;
input int BollingerbandsPeriod = 20;
input int BollingerbandsShift = 0;
input double BollingerbandsDeviation = 1.6;
input int BullsPowerPeriod = 50;
input int BearsPowerPeriod = 50;
bool Alerts = false;

input string Alert;
input bool UseSound = true;
input bool AlertSound = true;
input string SoundFileBuy = "alert2.wav";
input string SoundFileSell = "email.wav";
input bool SendMailPossible = false;
input int SIGNAL_BAR = 1;
bool SoundBuy = false;
bool SoundSell = false;

input string Arrow;
input int _High_ = 222;
input int _Low_ = 221;
input int _Distance_ = 0.5;
input int bars_limit = 10000; // Bars limit

bool Gi_132 = FALSE;
bool Gi_136 = FALSE;
bool Gi_140 = FALSE;
bool Gi_144 = FALSE;
bool Gi_148 = FALSE;
bool Gi_152 = FALSE;
bool Gi_156 = FALSE;
bool Gi_160 = FALSE;
bool Gi_164 = FALSE;
bool Gi_168 = FALSE;
int Gi_172 = 0;
bool Gi_176 = FALSE;
bool Gi_180 = FALSE;

// E37F0136AA3FFAF149B351F6A4C948E9
int init()
{
   SetIndexStyle(0, DRAW_ARROW, EMPTY, 5);
   SetIndexArrow(0, _Low_);
   SetIndexBuffer(0, CrossUp);
   SetIndexStyle(1, DRAW_ARROW, EMPTY, 5);
   SetIndexArrow(1, _High_);
   SetIndexBuffer(1, CrossDown);
   return (0);
}

// 52D46093050F38C27267BCE42543EF60
int deinit()
{
   return (0);
}

// EA2B2676C28C0DB26D39331A336C6B92
int start()
{
   int Li_8;
   double ima_12;
   double ima_20;
   double ima_28;
   double ima_36;
   double irsi_44;
   double irsi_52;
   double ibullspower_60;
   double ibullspower_68;
   double ibearspower_76;
   double ibearspower_84;
   double Ld_92;
   double Ld_100;
   double Ld_108;
   double Ld_116;
   double Ld_124;
   double Ld_132;
   double Ld_140;
   double ibands_152;
   double ibands_160;
   double ibands_168;
   double ibands_176;
   int Li_148 = IndicatorCounted();
   if (Li_148 < 0)
      return (-1);
   if (Li_148 > 0)
      Li_148--;
   int toSkip = 1;
   for (int shift = MathMin(bars_limit, Bars - 1 - MathMax(Li_148 - 1, toSkip)); shift >= 0 && !IsStopped(); --shift)
   {
      Li_8 = shift;
      Ld_132 = 0;
      Ld_140 = 0;
      for (Li_8 = shift; Li_8 <= shift + 10; Li_8++)
         Ld_140 += MathAbs(High[Li_8] - Low[Li_8]);
      Ld_132 = Ld_140 / 10.0;
      ima_12 = iMA(NULL, 0, FasterMovingAverage, 0, MODE_EMA, PRICE_CLOSE, shift);
      ima_28 = iMA(NULL, 0, FasterMovingAverage, 0, MODE_EMA, PRICE_CLOSE, shift + 1);
      ima_20 = iMA(NULL, 0, SlowerMovingAverage, 0, MODE_EMA, PRICE_CLOSE, shift);
      ima_36 = iMA(NULL, 0, SlowerMovingAverage, 0, MODE_EMA, PRICE_CLOSE, shift + 1);
      irsi_44 = iRSI(NULL, 0, RSIPeriod, PRICE_CLOSE, shift);
      irsi_52 = iRSI(NULL, 0, RSIPeriod, PRICE_CLOSE, shift + 1);
      ibullspower_60 = iBullsPower(NULL, 0, BullsPowerPeriod, PRICE_CLOSE, shift);
      ibullspower_68 = iBullsPower(NULL, 0, BullsPowerPeriod, PRICE_CLOSE, shift + 1);
      ibearspower_76 = iBearsPower(NULL, 0, BearsPowerPeriod, PRICE_CLOSE, shift);
      ibearspower_84 = iBearsPower(NULL, 0, BearsPowerPeriod, PRICE_CLOSE, shift + 1);
      ibands_152 = iBands(NULL, 0, BollingerbandsPeriod, BollingerbandsDeviation, BollingerbandsShift, PRICE_CLOSE, MODE_UPPER, shift);
      ibands_160 = iBands(NULL, 0, BollingerbandsPeriod, BollingerbandsDeviation, BollingerbandsShift, PRICE_CLOSE, MODE_LOWER, shift);
      ibands_168 = iBands(NULL, 0, BollingerbandsPeriod, BollingerbandsDeviation, BollingerbandsShift, PRICE_CLOSE, MODE_UPPER, shift + 1);
      ibands_176 = iBands(NULL, 0, BollingerbandsPeriod, BollingerbandsDeviation, BollingerbandsShift, PRICE_CLOSE, MODE_LOWER, shift + 1);
      Ld_92 = iHighest(NULL, 0, MODE_HIGH, MagicFilterPeriod, shift);
      Ld_100 = iHighest(NULL, 0, MODE_LOW, MagicFilterPeriod, shift);
      Ld_108 = 100 - 100.0 * ((Ld_92 - 0.0) / 10.0);
      Ld_116 = 100 - 100.0 * ((Ld_100 - 0.0) / 10.0);
      if (Ld_108 == 0.0)
         Ld_108 = 0.0000001;
      if (Ld_116 == 0.0)
         Ld_116 = 0.0000001;
      Ld_124 = Ld_108 - Ld_116;
      if (Ld_124 >= 0.0)
      {
         Gi_148 = TRUE;
         Gi_168 = FALSE;
      }
      else
      {
         if (Ld_124 < 0.0)
         {
            Gi_148 = FALSE;
            Gi_168 = TRUE;
         }
      }
      if (Close[shift] > ibands_152 && Close[shift + 1] >= ibands_168)
      {
         Gi_144 = FALSE;
         Gi_164 = TRUE;
      }
      if (Close[shift] < ibands_160 && Close[shift + 1] <= ibands_176)
      {
         Gi_144 = TRUE;
         Gi_164 = FALSE;
      }
      if (ibullspower_60 > 0.0 && ibullspower_68 > ibullspower_60)
      {
         Gi_140 = FALSE;
         Gi_160 = TRUE;
      }
      if (ibearspower_76 < 0.0 && ibearspower_84 < ibearspower_76)
      {
         Gi_140 = TRUE;
         Gi_160 = FALSE;
      }
      if (irsi_44 > 50.0 && irsi_52 < 50.0)
      {
         Gi_136 = TRUE;
         Gi_156 = FALSE;
      }
      if (irsi_44 < 50.0 && irsi_52 > 50.0)
      {
         Gi_136 = FALSE;
         Gi_156 = TRUE;
      }
      if (ima_12 > ima_20 && ima_28 < ima_36)
      {
         Gi_132 = TRUE;
         Gi_152 = FALSE;
      }
      if (ima_12 < ima_20 && ima_28 > ima_36)
      {
         Gi_132 = FALSE;
         Gi_152 = TRUE;
      }
      if (Gi_132 == TRUE && Gi_136 == TRUE && Gi_144 == TRUE && Gi_140 == TRUE && Gi_148 == TRUE && Gi_172 != 1)
      {
         CrossUp[shift] = Low[shift] - _Distance_ * Ld_132;
         if (shift <= 2 && Alerts && (!Gi_176))
         {
            Alert(Symbol(), " ", Period(), "   BUY");
            Gi_176 = TRUE;
            Gi_180 = FALSE;
         }
         Gi_172 = 1;
      }
      else
      {
         if (Gi_152 == TRUE && Gi_156 == TRUE && Gi_164 == TRUE && Gi_160 == TRUE && Gi_168 == FALSE && Gi_172 != 2)
         {
            CrossDown[shift] = High[shift] + _Distance_ * Ld_132;
            if (shift <= 2 && Alerts && (!Gi_180))
            {
               Alert(Symbol(), " ", Period(), "   SELL");
               Gi_180 = TRUE;
               Gi_176 = FALSE;
            }
            Gi_172 = 2;
         }
      }
   }

   string message = StringConcatenate(WindowExpertName() + "", " -", " ", "BUY", " -", " ", Symbol(), " -", " ", Period(), " ", "-", " ", TimeToStr(TimeLocal(), TIME_SECONDS));
   string message2 = StringConcatenate(WindowExpertName() + "", " -", " ", "SELL", " -", " ", Symbol(), " -", " ", Period(), " ", "-", " ", TimeToStr(TimeLocal(), TIME_SECONDS));
   //     //                              //     //
   if (CrossUp[SIGNAL_BAR] != EMPTY_VALUE && CrossUp[SIGNAL_BAR] != 0 && SoundBuy)
   {
      SoundBuy = False;
      if (UseSound)
         PlaySound(SoundFileBuy);
      if (AlertSound)
      {
         Alert(message);
         if (SendMailPossible)
            SendMail(Symbol(), message);
      }
   } //     //                              //     //
   if (!SoundBuy && (CrossUp[SIGNAL_BAR] == EMPTY_VALUE || CrossUp[SIGNAL_BAR] == 0))
      SoundBuy = True;
   //       //                              //       //
   if (CrossDown[SIGNAL_BAR] != EMPTY_VALUE && CrossDown[SIGNAL_BAR] != 0 && SoundSell)
   {
      SoundSell = False;
      if (UseSound)
         PlaySound(SoundFileSell);
      if (AlertSound)
      {
         Alert(message2);
         if (SendMailPossible)
            SendMail(Symbol(), message2);
      }
   } //       //                              //       //
   if (!SoundSell && (CrossDown[SIGNAL_BAR] == EMPTY_VALUE || CrossDown[SIGNAL_BAR] == 0))
      SoundSell = True;

   return (0);
}

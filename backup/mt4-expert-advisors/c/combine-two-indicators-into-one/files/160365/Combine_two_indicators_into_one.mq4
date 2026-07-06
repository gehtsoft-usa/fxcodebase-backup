//Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=73429

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
//------
#property indicator_chart_window
#property indicator_buffers 11
#property indicator_color1 clrBlue  // Green
#property indicator_color2 clrRed   // Red
//------
#property indicator_width1 2
#property indicator_width2 2
//------
#property indicator_style1 STYLE_DOT
#property indicator_style2 STYLE_DOT
//------

// #property indicator_buffers 6
#property indicator_color4 Blue
#property indicator_color5 White
#property indicator_color6 Green
#property indicator_color7 Yellow
#property indicator_color8 Yellow
#property indicator_color9 Yellow

extern bool Email        = TRUE;
extern int  SL_add_pips  = 11;
int         gi_84        = 1;
extern int  changeLiner  = 1;
int         gi_unused_92 = 1;
int         g_shift_96   = 977;
extern int  Gup          = 4;
double      g_ibuf_104[];
double      g_ibuf_108[];
double      ArrowUp[];
int         g_period_116 = 2;
double      ArrowDn[];
double      g_ibuf_124[];
double      g_ibuf_128[];
bool        gi_unused_132 = FALSE;
bool        gi_unused_136 = FALSE;
bool        gi_140        = FALSE;
bool        gi_unused_144 = TRUE;
string      gs_148        = "BuySellWait";
string      g_name_156;
int         gi_164 = 1;
int         gi_168 = 1;
int         gi_172 = 1;
double      gd_176 = 1.0;
double      gd_184 = 1.0;
int         gi_192 = -1;
datetime    g_time_196;

// ------------------------------------------------------------------
extern int                Length        = 12;           // 45;  //50;
extern ENUM_MA_METHOD     Mode          = MODE_SMMA;    // MODE_LWMA;
extern ENUM_APPLIED_PRICE Price         = PRICE_CLOSE;  // Applied price
extern bool               ShowHighLow   = false;
extern int                SIGNALBAR     = 1;     // На каком баре сигналить....
extern bool               AlertsMessage = true,  // false,
    AlertsSound                         = true,  // false,
    AlertsEmail                         = false,
            AlertsMobile                = false;
extern string SoundFile                 = "alert2.wav";  //"news.wav";   //"expert.wav";  //   //"stops.wav"   //"alert2.wav"   //

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
double   BUYY[], SELL[];
datetime TimeBar = 0;
double   Array1[], MA[];
int      SqLength;

double trend[];

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
int init()
{
  Length   = fmax(Length, 1);
  SqLength = MathSqrt(Length);
  IndicatorShortName("Trend Lord TT [" + (string)Length + ">" + (string)SqLength + "]");
  SetIndexLabel(0, stringMTF(_Period) + ":  BUY   " + StringSubstr(EnumToString(Mode), 5) + " [" + (string)Length + ">" + (string)SqLength + "]");
  SetIndexLabel(1, stringMTF(_Period) + ":  SELL  " + StringSubstr(EnumToString(Mode), 5) + " [" + (string)Length + ">" + (string)SqLength + "]");
  IndicatorBuffers(4);
  IndicatorDigits(Digits);  // if (Digits==3 || Digits==5) IndicatorDigits(Digits-1);
  SetIndexBuffer(0, BUYY);
  SetIndexDrawBegin(0, Length + SqLength);
  SetIndexBuffer(1, SELL);
  SetIndexDrawBegin(1, Length + SqLength);
  SetIndexBuffer(2, Array1);
  SetIndexBuffer(3, MA);
  SetIndexStyle(0, DRAW_HISTOGRAM);
  SetIndexStyle(1, DRAW_HISTOGRAM);
  SetIndexStyle(2, DRAW_NONE);
  SetIndexStyle(3, DRAW_NONE);

  //------ Arrows
  SetIndexBuffer(8, g_ibuf_104);
  SetIndexStyle(8, DRAW_NONE);
  SetIndexBuffer(9, g_ibuf_108);
  SetIndexStyle(9, DRAW_NONE);

  SetIndexBuffer(4, g_ibuf_124);
  SetIndexStyle(4, DRAW_NONE);

  SetIndexBuffer(5, g_ibuf_128);
  SetIndexStyle(5, DRAW_NONE);

  SetIndexBuffer(6, ArrowUp);
  SetIndexStyle(6, DRAW_ARROW, STYLE_DOT, gi_164, clrGreen);
  SetIndexArrow(6, 233);

  SetIndexBuffer(7, ArrowDn);
  SetIndexArrow(7, 234);
  SetIndexStyle(7, DRAW_ARROW, STYLE_DOT, gi_164, clrRed);

  
	//--- lo agrego para juntar los indicadores
	SetIndexBuffer(10, trend);
  SetIndexStyle(10, DRAW_NONE);

  return (0);
}
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
int deinit()
{
  Comment(" ");
  ObjectDelete(g_name_156);
  return (0);
}
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

int OnCalculate(const int       rates_total,
                const int       prev_calculated,
                const datetime& time[],
                const double&   open[],
                const double&   high[],
                const double&   low[],
                const double&   close[],
                const long&     tick_volume[],
                const long&     volume[],
                const int&      spread[])
{

	int i, CountedBars = IndicatorCounted();
  if (CountedBars < 0) return (-1);  // Стандарт+Tankk-Вариант!!!
  if (CountedBars > 0) CountedBars--;
  int limit = fmin(Bars - CountedBars, Bars - 2);  //+MAX*10*TFK
  //---

  //--- ARROWS

  double ld_0;
  double ld_8;
  double ld_16;
  int    li_24;
  f0_0();
  int li_28 = IndicatorCounted();
  if (li_28 < 0) return (-1);
  if (li_28 > 0) li_28--;
  int li_32 = Bars - li_28;
  if (gi_140)
  {
    li_24 = li_32;
    Comment("");
  } else
    li_24 = 1000;
  int li_36 = 0;

  // for (int i = li_24; i > 0; i--)
	for (i = limit; i >= 0; i--)
  {
    
		if (f0_1(i))
    {
      gi_168 = 0;
      gi_172 = gi_192;
      gd_176 = High[i];
      li_36  = -1;
    
		  if (i == 1)
      {
        ld_0  = -1;
 
        ld_8  = High[1] + SL_add_pips * Point;
 
        ld_16 = 0;
        f0_4("Sell signal", ld_16, ld_8, Close[1]);
      }
    }
    
		if (f0_2(i))
    {
      gi_168 = 0;
      gi_172 = gi_192;
      gd_176 = Low[i];
      li_36  = 1;
      
			if (i == 1)
      {
        ld_0  = 1;
        ld_8  = Low[2] - SL_add_pips * Point;
        ld_16 = 0;
        f0_4("Buy signal", ld_16, ld_8, Close[1]);
      }
    }
    
		gd_184 = gd_176 - Close[i];
    gi_168 += Volume[i];
    gi_172++;
    
		if (li_36 == 1)
    {
      g_ibuf_124[i] = gi_168;
      g_ibuf_128[i] = 0;
    } else
    {
      g_ibuf_128[i] = gi_168;
      g_ibuf_124[i] = 0;
    }
    f0_3(ld_0);
  }
	


//--- TREND LORD NRP INDICATOR:	



  // int i, CountedBars = IndicatorCounted();
  // if (CountedBars < 0) return (-1);  // Стандарт+Tankk-Вариант!!!
  // if (CountedBars > 0) CountedBars--;
  // int limit = fmin(Bars - CountedBars, Bars - 2);  //+MAX*10*TFK
  //---
  for (i = limit; i >= 0; i--) MA[i] = iMA(NULL, 0, Length, 0, Mode, Price, i);
  //---
  for (i = limit; i >= 0; i--)
  {
    Array1[i] = iMAOnArray(MA, Bars, SqLength, 0, Mode, i);
    //---
    double slotLL = (ShowHighLow) ? Low[i] : MA[i];  /// можно сделать и fmax(Array1[i],Low[i])....
    double slotHH = (ShowHighLow) ? High[i] : MA[i];
    //---
    if (Array1[i] > Array1[i + 1])
    {
      BUYY[i] = slotLL;
      SELL[i] = Array1[i];
      trend[i]   = 1;
			// ArrowDn[i] = EMPTY_VALUE;
    }
    if (Array1[i] < Array1[i + 1])
    {
      BUYY[i] = slotHH;
      SELL[i] = Array1[i];
      trend[i]   = -1;
			// ArrowUp[i] = EMPTY_VALUE;
    }

  // si tendencia es roja, ArrowUp es empty
  // if (trend==-1) ArrowUp[i] = EMPTY_VALUE;
  // si tendencia es verde, ArrowDn es empty
  // if (trend==1) ArrowDn[i] = EMPTY_VALUE;


  }
  //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  if (AlertsMessage || AlertsEmail || AlertsMobile || AlertsSound)
  {                                                                                                                      /// CCI w Haos [MK]  —
    string messageUP = WindowExpertName() + ":  " + _Symbol + ", " + stringMTF(_Period) + "  >> Trend changed to BUY";   /// Arrow UP >> BUY";   ///+"  >>  Fast above Slow  >>  BUY";
    string messageDN = WindowExpertName() + ":  " + _Symbol + ", " + stringMTF(_Period) + "  << Trend changed to SELL";  /// Arrow DN << SELL";   ///+"  <<  Fast below Slow  <<  SELL";
    //------
    if (TimeBar != Time[0] && (Array1[SIGNALBAR] > Array1[1 + SIGNALBAR] && Array1[1 + SIGNALBAR] <= Array1[2 + SIGNALBAR]))
    {  ////(MAIN[SGB] > FINSIG[SGB] && MAIN[SGB+1] <= FINSIG[SGB+1])) {
      if (AlertsMessage) Alert(messageUP);
      if (AlertsEmail) SendMail(_Symbol, messageUP);
      if (AlertsMobile) SendNotification(messageUP);
      if (AlertsSound) PlaySound(SoundFile);  //"stops.wav"   //"news.wav"   //"alert2.wav"  //"expert.wav"
      TimeBar = Time[0];
    }  // return(0);
    //------
    else if (TimeBar != Time[0] && (Array1[SIGNALBAR] < Array1[1 + SIGNALBAR] && Array1[1 + SIGNALBAR] >= Array1[2 + SIGNALBAR]))
    {  ////(MAIN[SGB] < FINSIG[SGB] && MAIN[SGB+1] >= FINSIG[SGB+1])) {
      if (AlertsMessage) Alert(messageDN);
      if (AlertsEmail) SendMail(_Symbol, messageDN);
      if (AlertsMobile) SendNotification(messageDN);
      if (AlertsSound) PlaySound(SoundFile);  //"stops.wav"   //"news.wav"   //"alert2.wav"  //"expert.wav"
      TimeBar = Time[0];
    }  // return(0);
  }    //*конец* Алертов


  //------
  return (rates_total);
}
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//%%%                            iMAX AA MTF TT                            %%%
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
string stringMTF(int perMTF)
{
  if (perMTF == 0) perMTF = _Period;
  if (perMTF == 1) return ("M1");
  if (perMTF == 5) return ("M5");
  if (perMTF == 15) return ("M15");
  if (perMTF == 30) return ("M30");
  if (perMTF == 60) return ("H1");
  if (perMTF == 240) return ("H4");
  if (perMTF == 1440) return ("D1");
  if (perMTF == 10080) return ("W1");
  if (perMTF == 43200) return ("MN1");
  if (perMTF == 2 || 3 || 4 || 6 || 7 || 8 || 9 ||  /// нестандартные периоды для грфиков Renko
      10 || 11 || 12 || 13 || 14 || 16 || 17 || 18) return ("M" + (string)_Period);
  //------
  return ("Ошибка периода");
}
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

//--- Arrows:

void f0_3(double ad_0)
{
  g_name_156    = gs_148 + "BuySellwait";
  string text_8 = " Current Signal: ";
  if (ad_0 == 0.0) text_8 = text_8 + "Wait Next Signal ";
  if (ad_0 < 0.0) text_8 = text_8 + "Sell";
  if (ad_0 > 0.0) text_8 = text_8 + "Buy";
  int    li_16       = WindowBarsPerChart();
  int    li_20       = 60 * Period();
  double ld_24       = High[iHighest(NULL, 0, MODE_HIGH, li_16 * 4 / 5, 0)];
  double ld_32       = Low[iLowest(NULL, 0, MODE_LOW, li_16 * 4 / 5, 0)];
  double datetime_40 = Time[0] + (li_16 / 75 + 10) * li_20;
  double price_48    = ld_32 + (ld_24 - ld_32) / 10.0;
  double ld_56       = MathMax(7, 3.0 * MathCeil(li_16 / 5.0 / 3.0) + 1.0 - 3.0) * li_20;
  ObjectDelete(g_name_156);
  ObjectCreate(g_name_156, OBJ_TEXT, 0, datetime_40, price_48, 0, 0, 0, 0);
  ObjectSetText(g_name_156, text_8);
  ObjectSet(g_name_156, OBJPROP_COLOR, Yellow);
}

int f0_1(int ai_0)
{
  if (ArrowDn[ai_0] == EMPTY_VALUE) return (0);
  return (ArrowDn[ai_0] > 0.0);
}

int f0_2(int ai_0)
{
  if (ArrowUp[ai_0] == EMPTY_VALUE) return (0);
  return (ArrowUp[ai_0] > 0.0);
}

void f0_0()
{
  int    li_0;
  double lda_4[25000];
  double lda_8[25000];
  double lda_12[25000];
  double lda_16[25000];
  for (int shift_20 = g_shift_96; shift_20 > 0; shift_20--)
  {
    g_ibuf_104[shift_20] = 0;
    g_ibuf_108[shift_20] = 0;
    ArrowUp[shift_20]    = EMPTY_VALUE;
    ArrowDn[shift_20]    = EMPTY_VALUE;
  }
  for (shift_20 = g_shift_96 - g_period_116 - 1; shift_20 > 0; shift_20--)
  {
    lda_4[shift_20] = iBands(NULL, 0, g_period_116, Gup, 0, PRICE_CLOSE, MODE_UPPER, shift_20);
    lda_8[shift_20] = iBands(NULL, 0, g_period_116, Gup, 0, PRICE_CLOSE, MODE_LOWER, shift_20);
    if (Close[shift_20] > lda_4[shift_20 + 1]) li_0 = 1;
    if (Close[shift_20] < lda_8[shift_20 + 1]) li_0 = -1;
    if (li_0 > 0 && lda_8[shift_20] < lda_8[shift_20 + 1]) lda_8[shift_20] = lda_8[shift_20 + 1];
    if (li_0 < 0 && lda_4[shift_20] > lda_4[shift_20 + 1]) lda_4[shift_20] = lda_4[shift_20 + 1];
    lda_12[shift_20] = lda_4[shift_20] + (gi_84 - 1) / 2.0 * (lda_4[shift_20] - lda_8[shift_20]);
    lda_16[shift_20] = lda_8[shift_20] - (gi_84 - 1) / 2.0 * (lda_4[shift_20] - lda_8[shift_20]);
    if (li_0 > 0 && lda_16[shift_20] < lda_16[shift_20 + 1]) lda_16[shift_20] = lda_16[shift_20 + 1];
    if (li_0 < 0 && lda_12[shift_20] > lda_12[shift_20 + 1]) lda_12[shift_20] = lda_12[shift_20 + 1];
    
		if (li_0 > 0)
    {
      if (changeLiner > 0 && g_ibuf_104[shift_20 + 1] == -1.0)
      {
		if(trend[shift_20]>0)		
        ArrowUp[shift_20]    = lda_16[shift_20];
        g_ibuf_104[shift_20] = lda_16[shift_20];
      } else
      {
        g_ibuf_104[shift_20] = lda_16[shift_20];
        ArrowUp[shift_20]    = EMPTY_VALUE;
      }
      if (changeLiner == 2) g_ibuf_104[shift_20] = 0;
      ArrowDn[shift_20]    = EMPTY_VALUE;
      g_ibuf_108[shift_20] = -1.0;
    }
		
    if (li_0 < 0)
    {
      if (changeLiner > 0 && g_ibuf_108[shift_20 + 1] == -1.0)
      {
		if(trend[shift_20]<0)
        ArrowDn[shift_20]    = lda_12[shift_20];
        g_ibuf_108[shift_20] = lda_12[shift_20];
      } else
      {
        g_ibuf_108[shift_20] = lda_12[shift_20];
        ArrowDn[shift_20]    = EMPTY_VALUE;
      }
      if (changeLiner == 2) g_ibuf_108[shift_20] = 0;
      ArrowUp[shift_20]    = EMPTY_VALUE;
      g_ibuf_104[shift_20] = -1.0;
    }
  }
}

void f0_4(string as_0, double ad_8, double ad_16, double ad_24)
{
  string ls_32;
  string ls_40;
  string ls_48;
  string ls_56;
  string ls_64;
  if (Time[0] != g_time_196)
  {
    g_time_196 = Time[0];
    if (ad_24 != 0.0)
      ls_48 = " price " + DoubleToStr(ad_24, 4);
    else
      ls_48 = "";
    if (ad_8 != 0.0)
      ls_40 = ", TakeProfit on " + DoubleToStr(ad_8, 4);
    else
      ls_40 = "";
    if (ad_16 != 0.0)
      ls_32 = ", StopLoss on " + DoubleToStr(ad_16, 4);
    else
      ls_32 = "";

    ls_56 = "BuySellWait " + as_0 + ls_48;
    ls_64 = "BuySellWait " + as_0 + ls_48 + ls_40 + ls_32 + " " + Symbol() + ", " + Period() + " minutes chart";
    if (Email) SendMail(ls_56, ls_64);
  }
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
// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=72085

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

#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 5
#property indicator_buffers 8
#property indicator_color1 Red
#property indicator_color2 Blue
#property indicator_color3 Red
#property indicator_color4 Blue
#property indicator_color5 Red
#property indicator_color6 Blue

//---- parameters
extern bool AutoDisplay = true;
extern int  UniqueNum   = 339;
extern int  tf1         = 240;
extern int  tf2         = 1440;
extern int  tf3         = 10080;
extern int  tf4         = 10080;

extern int   BarWidth     = 0;  // 3;
extern color UpBarColor   = Blue;
extern color DownBarColor = Red;
extern color TextColor    = White;

double Gap = 1;  // Gap between the lines of bars
//---- buffers

double buf4_up[];
double buf4_down[];

double buf3_up[];
double buf3_down[];
double buf2_up[];
double buf2_down[];
double buf1_up[];
double buf1_down[];
double haOpen;
double haClose;

string shortname = "";
bool   firstTime = true;

int ArrSize = 110;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   firstTime = true;

   //---- indicators
   SetIndexStyle(0, DRAW_ARROW, 0, BarWidth, UpBarColor);
   SetIndexArrow(0, ArrSize);
   SetIndexBuffer(0, buf1_up);
   SetIndexEmptyValue(0, 0.0);
   SetIndexStyle(1, DRAW_ARROW, 0, BarWidth, DownBarColor);
   SetIndexArrow(1, ArrSize);
   SetIndexBuffer(1, buf1_down);
   SetIndexEmptyValue(1, 0.0);
   SetIndexStyle(2, DRAW_ARROW, 0, BarWidth, UpBarColor);
   SetIndexArrow(2, ArrSize);
   SetIndexBuffer(2, buf2_up);
   SetIndexEmptyValue(2, 0.0);
   SetIndexStyle(3, DRAW_ARROW, 0, BarWidth, DownBarColor);
   SetIndexArrow(3, ArrSize);
   SetIndexBuffer(3, buf2_down);
   SetIndexEmptyValue(3, 0.0);
   SetIndexStyle(4, DRAW_ARROW, 0, BarWidth, UpBarColor);
   SetIndexArrow(4, ArrSize);
   SetIndexBuffer(4, buf3_up);
   SetIndexEmptyValue(4, 0.0);
   SetIndexStyle(5, DRAW_ARROW, 0, BarWidth, DownBarColor);
   SetIndexArrow(5, ArrSize);
   SetIndexBuffer(5, buf3_down);
   SetIndexEmptyValue(5, 0.0);

   SetIndexStyle(6, DRAW_ARROW, 0, BarWidth, UpBarColor);
   SetIndexArrow(6, ArrSize);
   SetIndexBuffer(6, buf4_up);
   SetIndexEmptyValue(6, 0.0);
   SetIndexStyle(7, DRAW_ARROW, 0, BarWidth, DownBarColor);
   SetIndexArrow(7, ArrSize);
   SetIndexBuffer(7, buf4_down);
   SetIndexEmptyValue(7, 0.0);

   shortname = "MTF HA Bar";
   IndicatorShortName(shortname);

   SetIndexLabel(0, "");
   SetIndexLabel(1, "");
   SetIndexLabel(2, "");
   SetIndexLabel(3, "");
   SetIndexLabel(4, "");
   SetIndexLabel(5, "");
   SetIndexLabel(6, "");
   SetIndexLabel(7, "");

   IndicatorDigits(0);
   //----
   return (0);
}
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
{
   firstTime = true;
   int win   = UniqueNum;
   for (int ii = ObjectsTotal() - 1; ii > -1; ii--)
   {
      if (StringFind(ObjectName(ii), "FF_" + win + "_") >= 0)
         ObjectDelete(ObjectName(ii));
      else
         ii = -1;
   }
   //----
   return (0);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
   int counted_bars = IndicatorCounted();
   int i = 0, y15m = 0, y4h = 0, y1h = 0, y30m = 0;
   int limit = Bars - counted_bars;

   if (AutoDisplay)
   {
      int Period_1, Period_2, Period_3, Period_4;
      // clang-format off
      // toma el periodo actual y te busca 4 TF superiores:
   switch(Period()) 
      {
         case 1:     Period_1=1;     Period_2=5;     Period_3=15;    Period_4=30;  break;
         case 5:     Period_1=5;     Period_2=15;    Period_3=30;    Period_4=60;  break;
         case 15:    Period_1=15;    Period_2=30;    Period_3=60;    Period_4=240;  break;
         case 30:    Period_1=30;    Period_2=60;    Period_3=240;   Period_4=1440; break;
         case 60:    Period_1=60;    Period_2=240;   Period_3=1440;  Period_4=10080; break;
         case 240:   Period_1=240;   Period_2=1440;  Period_3=10080; Period_4=43200; break;
         case 1440:  Period_1=1440;  Period_2=10080; Period_3=43200; Period_4=43200; break;
         case 10080: Period_1=10080; Period_2=43200; Period_3=43200; Period_4=43200; break;
         case 43200: Period_1=43200; Period_2=43200; Period_3=43200; Period_4=43200; break;
      }
      // clang-format on
   } else
   {
      // En modo manual toma los que le pasó el usuario
      Period_1 = tf1;
      Period_2 = tf2;
      Period_3 = tf3;
      Period_4 = tf4;
   }

   datetime TimeArray_4H[], TimeArray_1H[], TimeArray_30M[], TimeArray_15M[];
   //----

   if (firstTime || NewBar())
   {
      firstTime  = false;
      int    win = UniqueNum;
      double dif = Time[0] - Time[1];
      
      // borra todos los objetos que tienen el UniqueNum
      for (int ii = ObjectsTotal() - 1; ii > -1; ii--)
      {
         if (StringFind(ObjectName(ii), "FF_" + win + "_") >= 0)
            ObjectDelete(ObjectName(ii));
         else
            ii = -1;
      }

      double shift = 0.2;
      
      for (ii = 0; ii < 4; ii++)
      {
         string txt = "??";
         double gp;

         // recorre los 4 time frames (que le paso el usuario o que se generaron automatico)
         // Armar las Labels y las ubica
         switch (ii)
         {
            case 0:
               // txt = tf2txt(Period_3);
               txt = tf2txt(Period_4);
               gp  = 1 + shift;
               break;
            case 1:
               // txt = tf2txt(Period_2);
               txt = tf2txt(Period_3);
               gp  = 1 + Gap + shift;
               break;
            case 2:
               // txt = tf2txt(Period_1);
               txt = tf2txt(Period_2);
               gp  = 1 + Gap * 2 + shift;
               break;
            case 3:
               // txt = tf2txt(Period_4);
               txt = tf2txt(Period_1);
               gp  = 1 + Gap * 3 + shift;
               break;
         }
         
         // crea cada etiqueta de los time frames:
         string name = "FF_" + win + "_" + ii + "_" + txt;
         ObjectCreate(name, OBJ_TEXT, WindowFind(shortname), iTime(NULL, 0, 0) + dif * 3, gp);
         ObjectSetText(name, txt, 6, "Arial", TextColor);
      }
   }

   // levanta los datos de los time frames que necesitas:
   ArrayCopySeries(TimeArray_15M, MODE_TIME, _Symbol, Period_1);
   ArrayCopySeries(TimeArray_30M, MODE_TIME, _Symbol, Period_2);
   ArrayCopySeries(TimeArray_1H,  MODE_TIME, _Symbol, Period_3);
   ArrayCopySeries(TimeArray_4H,  MODE_TIME, _Symbol, Period_4);

   for (i = 0, y15m = 0, y4h = 0, y1h = 0, y30m = 0; i < limit; i++)
   {
      if (Time[i] < TimeArray_15M[y15m]) y15m++;
      if (Time[i] < TimeArray_30M[y30m]) y30m++;
      if (Time[i] < TimeArray_1H[y1h])   y1h++;
      if (Time[i] < TimeArray_4H[y4h])   y4h++;

      for (int tf = 0; tf < 4; tf++)
      {
         int prd, shft;       
         // clang-format off  
         
         // setea las variables para calcular el Heinkn Ashi para cada tf
         switch (tf)
         {
            case 0: prd = Period_1; shft  = y15m; break;
            case 1: prd = Period_2; shft  = y30m; break;
            case 2: prd = Period_3; shft  = y1h; break;
            case 3: prd = Period_4; shft  = y4h; break;
         }

         // calcula el indicador para cada tf para la vela 2 y 3
         haOpen  = iCustom(NULL, prd, "Heiken Ashi", 3, shft);
         haClose = iCustom(NULL, prd, "Heiken Ashi", 2, shft);

         double dUp = EMPTY_VALUE;
         double dDn = EMPTY_VALUE;
   
         // determina si es Dn o Up
         if (haOpen < haClose) dDn = 1; else dUp = 1;

         // segun el valor up o Dn, hubica los buffers
         switch (tf)
         {
            case 0: if (dUp == EMPTY_VALUE) buf1_down[i] = 1 + Gap * 3; else buf1_up[i] = 1 + Gap * 3; break;
            case 1: if (dUp == EMPTY_VALUE) buf2_down[i] = 1 + Gap * 2; else buf2_up[i] = 1 + Gap * 2; break;
            case 2: if (dUp == EMPTY_VALUE) buf3_down[i] = 1 + Gap * 1; else buf3_up[i] = 1 + Gap * 1; break;
            case 3: if (dUp == EMPTY_VALUE) buf4_down[i] = 1 + Gap * 0; else buf4_up[i] = 1 + Gap * 0; break;
         }
      }
   }

   return (0);
}
//+------------------------------------------------------------------+

string tf2txt(int tf)
{
   if (tf == PERIOD_M1) return ("M1");
   if (tf == PERIOD_M5) return ("M5");
   if (tf == PERIOD_M15) return ("M15");
   if (tf == PERIOD_M30) return ("M30");
   if (tf == PERIOD_H1) return ("H1");
   if (tf == PERIOD_H4) return ("H4");
   if (tf == PERIOD_D1) return ("D1");
   if (tf == PERIOD_W1) return ("W1");
   if (tf == PERIOD_MN1) return ("MN1");

   return ("??");
}

bool NewBar()
{
   static datetime dt = 0;

   if (Time[0] != dt)
   {
      dt = Time[0];
      return (true);
   }
   return (false);
}

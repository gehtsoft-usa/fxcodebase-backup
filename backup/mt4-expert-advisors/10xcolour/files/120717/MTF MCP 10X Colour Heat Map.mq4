// Id: 22124
// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=66581

//+------------------------------------------------------------------+
//|                               Copyright © 2018, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------+
//|                                Patreon :  https://goo.gl/GdXWeN  |
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2018, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.1"

#property indicator_separate_window
#property indicator_buffers 21
#property strict

extern int MVAVPeriod = 20; // Periods of Volume SMA
extern double VPercent = 50; // Percentage of Volume above the SMA
extern int ADXPeriod = 14; // Period ADX
extern double ADXLevel = 20; // ADX Strength level
extern int DMIPeriod = 14; // Period DMI
extern int History_limit = 1000; // Limit number of processed bars
extern color clrA = clrGreen; // Ascending color
extern color clrD = clrRed; // Descending color
extern color clrAC = 0x80FFFF; // Ascending conviction color
extern color clrDC = 0xFF80FF; // Descending conviction color
extern color clrR = 0xFFFF00; // Range color
extern string Instrument1= "EURUSD";
extern string Instrument2= "USDJPY";
extern string Instrument3= "GBPUSD";
extern string Instrument4= "USDCHF";
extern string Instrument5= "AUSUSD";
extern string Instrument6= "USDCAD";
extern string Instrument7= "NZDUSD";
extern string Instrument8= "EURJPY";
extern string Instrument9= "EURGBP";
extern string Instrument10= "GBPJPY";

extern color UpColor = Blue;
extern color DownColor = Red;

extern int scaleX = 30,// horizontal interval at which the squares are created
scaleY = 30,           // vertical interval
offsetX = 60,          // horizontal indent of all squares
offsetY = 30,          // vertical indent
fontSize = 30;         // font size

string PAIR[] = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "10" }; 
string TF[] = { "m1", "m5", "m15", "m30", "H1", "H4", "D1", "W1", "MN1" };
int iTF[] = { PERIOD_M1, PERIOD_M5, PERIOD_M15, PERIOD_M30, PERIOD_H1, PERIOD_H4, PERIOD_D1, PERIOD_W1, PERIOD_MN1 };

string IndiShortName = "MTF_MCP_10X";

int init()
{
       double temp = iCustom(NULL, 0, "10XColour", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the '10XColour' indicator");
       return INIT_FAILED;
   }
   IndicatorShortName(IndiShortName);
   int windowIndex = WindowFind(IndiShortName);
   
   PAIR[0] = Instrument1;
   PAIR[1] = Instrument2;
   PAIR[2] = Instrument3;
   PAIR[3] = Instrument4;
   PAIR[4] = Instrument5;
   PAIR[5] = Instrument6;
   PAIR[6] = Instrument7;
   PAIR[7] = Instrument8;
   PAIR[8] = Instrument9;
   PAIR[9] = Instrument10;

   if(windowIndex < 0)
   {
      // if the subwindow number is -1, there is an error
      Print("Can\'t find window");
      return(0);
   }

   for(int x=0;x<ArraySize(TF);x++)
      for(int y=0;y<ArraySize(PAIR);y++)
      {
         ObjectCreate("signal"+windowIndex+x+y,OBJ_LABEL,windowIndex,0,0,0,0);
         ObjectSet("signal"+windowIndex+x+y,OBJPROP_XDISTANCE,x*scaleX+offsetX);
         ObjectSet("signal"+windowIndex+x+y,OBJPROP_YDISTANCE,y*scaleY+offsetY);
         ObjectSetText("signal"+windowIndex+x+y,CharToStr(110),fontSize,"Wingdings",Gold);
      }

   for(int x=0;x<ArraySize(TF);x++)
   {
      ObjectCreate("textPeriod"+windowIndex+x,OBJ_LABEL,windowIndex,0,0,0,0);
      ObjectSet("textPeriod"+windowIndex+x,OBJPROP_XDISTANCE,x*scaleX+offsetX);
      ObjectSet("textPeriod"+windowIndex+x,OBJPROP_YDISTANCE,offsetY-10);
      ObjectSetText("textPeriod"+windowIndex+x,TF[x],8,"Tahoma",Blue);
   }

   for (int y = 0; y < ArraySize(PAIR); y++)
   {
      ObjectCreate("textSignal"+windowIndex+y,OBJ_LABEL,windowIndex,0,0,0,0);
      ObjectSet("textSignal"+windowIndex+y,OBJPROP_XDISTANCE,offsetX-50);
      ObjectSet("textSignal"+windowIndex+y,OBJPROP_YDISTANCE,y*scaleY+offsetY+8);
      ObjectSetText("textSignal"+windowIndex+y,PAIR[y],8,"Tahoma",Blue);
   }
   
   return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
{
   int windowIndex = WindowFind(IndiShortName);
  
   for(int x=0;x<ArraySize(TF);x++)
   {
      for(int y=0;y<ArraySize(PAIR);y++)
      {
         ObjectDelete("signal"+windowIndex+x+y);
      }
   }

   for(int x=0;x<ArraySize(TF);x++)
   {
      ObjectDelete("textPeriod"+windowIndex+x);     
   }
   for(int x=0;x<ArraySize(PAIR);x++)
   {
      ObjectDelete("textSignal"+windowIndex+x);
   }
   return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
   int windowIndex=WindowFind(IndiShortName);
   
   for(int x=0;x<ArraySize(TF);x++)
   {
      for(int y=0;y<ArraySize(PAIR);y++)
      { 
         double color_code = iCustom(PAIR[y], iTF[x], "10XColour", MVAVPeriod, VPercent, ADXPeriod, ADXLevel, DMIPeriod, 
            10, 0, 0, 0, 0, 0, 0, 0);
         if (color_code == 0)
         {
            ObjectSetText("signal" + windowIndex + x + y, CharToStr(110), fontSize, "Wingdings", clrR);
         }
         else if (color_code == 1)
         {
            ObjectSetText("signal" + windowIndex + x + y, CharToStr(110), fontSize, "Wingdings", clrAC);
         }
         else if (color_code == 2)
         {
            ObjectSetText("signal" + windowIndex + x + y, CharToStr(110), fontSize, "Wingdings", clrA);
         }           
         else if (color_code == 3)
         {
            ObjectSetText("signal" + windowIndex + x + y, CharToStr(110), fontSize, "Wingdings", clrDC);
         }           
         else if (color_code == 4)
         {
            ObjectSetText("signal" + windowIndex + x + y, CharToStr(110), fontSize, "Wingdings", clrD);
         }
      }
   }

   return(0);
}

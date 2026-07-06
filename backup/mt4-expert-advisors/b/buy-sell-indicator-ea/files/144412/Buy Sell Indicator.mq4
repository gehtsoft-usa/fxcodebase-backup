// More information about this indicator can be found at:
// http://fxcodebase.com/ 

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2021, Gehtsoft USA LLC  | 
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




#property copyright "Copyright © 2021, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict
#property indicator_chart_window

#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_width1 1
#property indicator_label1 "BUY"
#property indicator_color2 OrangeRed
#property indicator_width2 1
#property indicator_label2 "SELL"

input   string                bb="BB";                       
input   int                   bb_period=20;                  
input   int                   bb_bands_shift=0;              
input   double                bb_deviation=2;                
input   ENUM_APPLIED_PRICE    bb_applied_price=PRICE_CLOSE;  

input   string                ma1="MA";                      // --- MA ---
input   int                   ma_period2=50;                 // MA Period
input   int                   ma_shift2=0;                   // MA shift
input   ENUM_MA_METHOD        ma_method2=MODE_EMA;           // Method
input   ENUM_APPLIED_PRICE    applied_price2=PRICE_CLOSE;    // Applied price

input   bool                  notifications=true;            // Notifications
input   bool                  desktop_notifications=true;    // Desktop MT4 Notifications
input   bool                  email_notifications=true;      // Email Notifications
input   bool                  push_notifications=true;       // Push Mobile Notifications

double    BuyArrow[],SellArrow[];
datetime  current;
//+--------------------------------------------------------------------+
//| Custom indicator initialization function                           |
//+--------------------------------------------------------------------+
int OnInit()
  {
   IndicatorBuffers(2);

   SetIndexStyle(0,DRAW_ARROW,EMPTY);
   SetIndexArrow(0,217);
   SetIndexBuffer(0,BuyArrow);

   SetIndexStyle(1,DRAW_ARROW,EMPTY);
   SetIndexArrow(1,218);
   SetIndexBuffer(1,SellArrow);

   return(INIT_SUCCEEDED);
  }
//+--------------------------------------------------------------------+
//| Custom indicator iteration function                                |
//+--------------------------------------------------------------------+
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
      if(Time[0]!=current)
        {
         current=Time[0];

      int i,
         Counted_bars;                

      Counted_bars=IndicatorCounted(); 
      i=Bars-Counted_bars-3;           

      if(i==-1)
        {
         i=0;
        }

      while(i>=0) 
        {
         double bb_high=iBands(_Symbol,_Period,bb_period,bb_deviation,bb_bands_shift,bb_applied_price,MODE_UPPER,i+1);
         double bb_low=iBands(_Symbol,_Period,bb_period,bb_deviation,bb_bands_shift,bb_applied_price,MODE_LOWER,i+1);

         double bb_high_prev=iBands(_Symbol,_Period,bb_period,bb_deviation,bb_bands_shift,bb_applied_price,MODE_UPPER,i+2);
         double bb_low_prev=iBands(_Symbol,_Period,bb_period,bb_deviation,bb_bands_shift,bb_applied_price,MODE_LOWER,i+2);

         double ma_5 = iMA(_Symbol,_Period,ma_period2,ma_shift2,ma_method2,applied_price2,i+1);

         double ma_5_prev = iMA(_Symbol,_Period,ma_period2,ma_shift2,ma_method2,applied_price2,i+2);

         if((ma_5_prev > bb_low_prev) && (ma_5<bb_low))
           {
            BuyArrow[i+1]=Low[i+1]-getPoint();
            if(i==0)
              {
               Notifications(0);
              }
           }

         if((ma_5_prev < bb_high_prev) && (ma_5>bb_high))
           {
            SellArrow[i+1]=High[i+1]+getPoint();
            if(i==0)
              {
               Notifications(1);
              }
           }
         i--;
        }
     }
   return(rates_total);
  }
//+--------------------------------------------------------------------+
//| Notifications Function                                             |
//+--------------------------------------------------------------------+
void Notifications(int type)
  {
   int i = 1;
   double EntryPrice=Close[1];
   double TakeProfit=iBands(_Symbol,_Period,bb_period,bb_deviation,bb_bands_shift,bb_applied_price,MODE_MAIN,i);

   string text="";
   if(type == 0)
      text += _Symbol+" "+GetTimeFrame(_Period)+" BUY ";
   else
      text += _Symbol+" "+GetTimeFrame(_Period)+" SELL ";
      
   text += " ";

   if(!notifications)
      return;
   if(desktop_notifications)
      Alert(text);
   if(push_notifications)
      SendNotification(text);
   if(email_notifications)
      SendMail("MetaTrader Notification",text);
  }
//+--------------------------------------------------------------------+
//| GetPoint Function                                                  |
//+--------------------------------------------------------------------+
double getPoint()
  {
   if(Period()==1)
      return 5*Point;
   if(Period()==5)
      return 10*Point;
   if(Period()==15)
      return 22*Point;
   if(Period()==30)
      return 44*Point;
   if(Period()==60)
      return 80*Point;
   if(Period()==240)
      return 120*Point;
   if(Period()==1440)
      return 170*Point;
   if(Period()==10080)
      return 500*Point;
   if(Period()==43200)
      return 900*Point;
   return 20*Point;
  }
//+--------------------------------------------------------------------+
//| GetTimeFrame Function                                              |
//+--------------------------------------------------------------------+
string GetTimeFrame(int lPeriod)
  {
   switch(lPeriod)
     {
      case PERIOD_M1:
         return("M1");
      case PERIOD_M5:
         return("M5");
      case PERIOD_M15:
         return("M15");
      case PERIOD_M30:
         return("M30");
      case PERIOD_H1:
         return("H1");
      case PERIOD_H4:
         return("H4");
      case PERIOD_D1:
         return("D1");
      case PERIOD_W1:
         return("W1");
      case PERIOD_MN1:
         return("MN1");
     }
   return IntegerToString(lPeriod);
  }
//+--------------------------------------------------------------------+

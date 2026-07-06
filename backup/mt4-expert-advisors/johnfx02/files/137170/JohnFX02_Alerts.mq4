//http://fxcodebase.com/code/viewtopic.php?f=38&t=70349
// http://fxcodebase.com/
//+------------------------------------------------------------------+
//|                               Copyright © 2020, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  | 
//|                                    Paypal: https://goo.gl/9Rj74e |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                           https://AppliedMachineLearning.systems |
//|                                Patreon :  https://goo.gl/GdXWeN  |  
//+------------------------------------------------------------------+

#property copyright "Copyright 2020, FXCodeBase"
#property link      "https://fxcodebase.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 clrGreen
#property indicator_label1 "Aux"
extern bool Send_Email = false;
extern bool Audible_Alerts = true;
extern bool Push_Notifications = false;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
//--- Variables Declaration
    datetime lastActionTime;
    double sma5_0, sma5_1, sma10_0, sma10_1;
    double rsi_0, rsi_1, stoch_0, stoch_1;

    double buffer1[];
//---


int OnInit()
{
//--- indicator buffers mapping
    SetIndexBuffer(0, buffer1);
    SetIndexStyle(0, DRAW_LINE);
    ObjectsDeleteAll(0, -1);
//---
return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
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
//---
    if (lastActionTime != Time[0])
    {
        int i, countedBars;

        countedBars = IndicatorCounted();
        i = Bars - countedBars - 1;
        while (i >= 0)
        {
            sma5_0 = iMA(Symbol(), 0, 5, 0, MODE_SMA, PRICE_CLOSE, i);
            sma5_1 = iMA(Symbol(), 0, 5, 0, MODE_SMA, PRICE_CLOSE, i + 1);

            sma10_0 = iMA(Symbol(), 0, 10, 0, MODE_SMA, PRICE_CLOSE, i);
            sma10_1 = iMA(Symbol(), 0, 10, 0, MODE_SMA, PRICE_CLOSE, i + 1);

            rsi_0 = iRSI(Symbol(), 0, 9, PRICE_CLOSE, i);
            rsi_1 = iRSI(Symbol(), 0, 9, PRICE_CLOSE, i + 1);

            stoch_0 = iStochastic(Symbol(), 0, 14, 3, 3, MODE_SMA, 0, MODE_MAIN, i);
            stoch_1 = iStochastic(Symbol(), 0, 14, 3, 3, MODE_SMA, 0, MODE_MAIN, i + 1);

            if (
                sma5_0 > sma10_0 && sma5_1 < sma10_1    // sma5 crossing up sma10
                && rsi_0 > 50 && rsi_1 < 50             // rsi crossing up 50
                && stoch_0 > 50 && rsi_1 < 50           // stochastic crossing up 50
            )
            {
                ObjectDelete("Arrow" + (string)i);
                ObjectCreate(   "Arrow" + (string)i,
                                OBJ_ARROW_UP,
                                0,
                                time[i],
                                low[i] - (high[i]-low[i])/5
                                );

                ObjectSet(  "Arrow" + (string)i,
                            OBJPROP_COLOR,
                            clrLime);

               if(i == 1) myAlert(i);

            }
            if (
                sma5_0 < sma10_0 && sma5_1 > sma10_1    // sma5 crossing down sma10
                && rsi_0 < 50 && rsi_1 > 50             // rsi crossing down 50
                && stoch_0 < 50 && rsi_1 > 50           // stochastic crossing down 50
                )
            {
                ObjectDelete("Arrow" + (string)i);
                ObjectCreate(   "Arrow" + (string)i,
                                OBJ_ARROW_DOWN,
                                0,
                                time[i],
                                high[i] + (high[i]-low[i])/2
                                );

                ObjectSet(  "Arrow" + (string)i,
                            OBJPROP_COLOR,
                            clrRed);

               if(i == 1) myAlert(i, 1);
            }

            i--;
        }
        lastActionTime = Time[0];
    }

//--- return value of prev_calculated for next call
    return(rates_total);
}
//+------------------------------------------------------------------+

void OnDeinit(const int reason)
{
    ObjectsDeleteAll(0, -1);
}


void myAlert(int time,int type = 0)
  {
      string order_type = "Short";
      if(type == 1)order_type = "Long";
      string alert_message = order_type+ " Signal Created on" + Symbol()+" "+Period() + " "+string(Time[time]);
      string email_subject = "John Alert On "+Symbol();
      Print(alert_message);
      if(Audible_Alerts) Alert(alert_message);
      if(Send_Email) SendMail(email_subject, alert_message);
      if(Push_Notifications) 
      if (!SendNotification(alert_message))
      {
          Print("Error sending long push notification: " + (string)GetLastError());
      }
  }
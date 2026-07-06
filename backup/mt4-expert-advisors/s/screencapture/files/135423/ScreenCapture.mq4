// More information about this indicator can be found at:
http://fxcodebase.com/code/viewtopic.php?f=38&t=70100


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

#property copyright "Copyright © 2020, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window

extern int MaxShots = 100;
extern int size_x = 400;
extern int size_y = 300;
extern int start_bar = -1;
extern int chart_scale = 3;
extern int chart_mode = -1;
datetime Gt_100 = 0;
int Gi_104 = 1;
string Gs_108;
string Gs_116;

int init() {
   return (0);
}

int deinit() {
   return (0);
}

int start() {
   if (Gt_100 != Time[0] && Gi_104 < MaxShots) {
      Gs_116 = "";
      if (Gi_104 < 100) Gs_116 = "0";
      if (Gi_104 < 10) Gs_116 = "00";
      Gs_108 = Symbol() + Period() + "-" + Gs_116 + Gi_104 + ".gif";
      WindowScreenShot(Gs_108, size_x, size_y, start_bar, chart_scale, chart_mode);
      Gt_100 = Time[0];
      Gi_104++;
   }
   return (0);
}

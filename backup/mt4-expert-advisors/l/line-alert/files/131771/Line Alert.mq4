// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=69507
//+------------------------------------------------------------------+
//|                               Copyright © 2020, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                           mario.jemic@gmail.com  |
//|                          https://AppliedMachineLearning.systems  |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//|                                 Patreon : https://goo.gl/GdXWeN  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2020, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property strict

#property indicator_chart_window

extern int Temporalidad = 15;
extern int Separacion = 7;
bool Gi_84 = TRUE;
extern bool Alarma_MT4 = TRUE;
extern bool Alarma_Email = FALSE;
extern bool Alarma_Mobil = TRUE;
extern bool Color_Todos = FALSE;
extern color Color_Exclusivo = LimeGreen;

 
int init() {
   return (0);
}

 
int deinit() {
   return (0);
}

 
int start() {
   string name_8;
   double Ld_32;
   double close = iClose(Symbol(), Temporalidad, 0);
   double close1 = iClose(Symbol(), Temporalidad, 1);
   int Li_0 = ObjectsTotal() - 1;
   for (int Li_4 = Li_0; Li_4 >= 0; Li_4--) {
      name_8 = ObjectName(Li_4);
      if (ObjectType(name_8) == 2 || ObjectType(name_8) == 1 && ObjectFind(name_8) == 0 && Color_Todos || ((!Color_Todos) && ObjectGet(name_8, OBJPROP_COLOR) == Color_Exclusivo)) {
         Ld_32 = 0;
         if (ObjectType(name_8) == 2) Ld_32 = ObjectGetValueByShift(name_8, 0);
         if (ObjectType(name_8) == 1) Ld_32 = ObjectGet(name_8, OBJPROP_PRICE1);
         if ((close1 > Ld_32 && close <= Ld_32) || (close1 < Ld_32 && close >= Ld_32))
         {
            if (TimeCurrent() >= GlobalVariableGet(Symbol() + name_8 + "Last Touch") + 60 * (Separacion * Temporalidad))
            {
               f0_0(Symbol() + " M" + Period() + " - TL");
               GlobalVariableSet(Symbol() + name_8 + "Last Touch", TimeCurrent());
            }
         }
      }
   }
   return (0);
}

// A3D282B86AE40A08D6CBD5D3B4992554
void f0_0(string As_0) {
   if (Gi_84) Print(As_0);
   if (Alarma_Email) SendMail("Trend Line Touch", As_0);
   if (Alarma_Mobil) SendNotification(As_0);
   if (Alarma_MT4) Alert(As_0);
}

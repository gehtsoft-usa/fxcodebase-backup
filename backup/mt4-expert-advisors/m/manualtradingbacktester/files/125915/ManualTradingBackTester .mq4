// Id: 24780
// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68379

//+------------------------------------------------------------------+
//|                               Copyright © 2019, Gehtsoft USA LLC | 
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

#import "user32.dll"
   bool GetAsyncKeyState(int a0);
#import

extern string KEY = " --- Hot Key Settings --- ";
extern string HotKey_Buy = "B";
extern string HotKey_Sell = "S";
extern string HotKey_Close_Buy = "0";
extern string HotKey_Close_Sell = "1";
extern string HotKey_CloseAll = "C";
extern string GENERAL = " --- General Settings --- ";
extern double OpenLot = 0.1;
extern bool UseAutoLots = FALSE;
extern double Risk_Ratio = 5.0;
extern double TakeProfit = 50.0;
extern double StopLoss = 50.0;
extern bool UseBE = FALSE;
extern double BEPoint = 25.0;
extern bool UseTrailingStop = FALSE;
extern double TrailingStop = 25.0;
extern double TrailingStep = 1.0;
extern bool DisplayData = TRUE;
int G_digits_204;
int G_count_208;
int G_count_212;
int buy_key;
int sell_key;
int close_buy_key;
int close_sell_key;
int close_all_key;
int G_magic_236 = 100;
double Gd_240;
double Gd_248;
double Gd_256;
string G_comment_264;
int G_datetime_272;

string IndicatorName;
string IndicatorObjPrefix;

string GenerateIndicatorName(const string target)
{
   string name = target;
   int try = 2;
   while (WindowFind(name) != -1)
   {
      name = target + " #" + IntegerToString(try++);
   }
   return name;
}


// E37F0136AA3FFAF149B351F6A4C948E9
int init() {
   Gd_240 = MarketInfo(Symbol(), MODE_POINT);
   G_digits_204 = MarketInfo(Symbol(), MODE_DIGITS);
   if (G_digits_204 == 3 || G_digits_204 == 5) Gd_240 = 10.0 * Gd_240;
   buy_key = f0_11(HotKey_Buy);
   sell_key = f0_11(HotKey_Sell);
   close_buy_key = f0_11(HotKey_Close_Buy);
   close_sell_key = f0_11(HotKey_Close_Sell);
   close_all_key = f0_11(HotKey_CloseAll);
   G_comment_264 = "ManualTradingBackTester, " + Symbol() + " " + Period();
   G_datetime_272 = TimeCurrent();
   IndicatorName = GenerateIndicatorName("ManualTradingBackTester");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   return (0);
}

// 52D46093050F38C27267BCE42543EF60
int deinit() {
   Comment("");
   f0_0("LOGO");
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return (0);
}

#define VK_LSHIFT         0xA0
#define VK_RSHIFT         0xA1
#define VK_LCONTROL       0xA2
#define VK_RCONTROL       0xA3
#define VK_LMENU          0xA4
#define VK_RMENU          0xA5

int start() 
{
   f0_8();
   if (GetAsyncKeyState(VK_LCONTROL))
   {
      if (GetAsyncKeyState(buy_key)) 
         f0_6(OP_BUY);
      else if (GetAsyncKeyState(sell_key)) 
         f0_6(OP_SELL);
      else if (GetAsyncKeyState(close_buy_key)) 
         f0_7(OP_BUY);
      else if (GetAsyncKeyState(close_sell_key)) 
         f0_7(OP_SELL);
      else if (GetAsyncKeyState(close_all_key)) 
         f0_7(OP_BUYLIMIT);
   }
   f0_9();
   f0_5();
   return (0);
}

// E3A54926DC5EF1106D81EFCA47E35C6C
void f0_8() {
   for (int pos_0 = OrdersTotal() - 1; pos_0 >= 0; pos_0--) {
      if (OrderSelect(pos_0, SELECT_BY_POS)) {
         if (OrderSymbol() == Symbol()) {
            if (OrderMagicNumber() == G_magic_236) {
               if (UseBE) f0_4();
               if (UseTrailingStop) f0_2();
            }
         }
      }
   }
}

// 5BADBB6A5D8ADD05F899BB7058AC9FA4
void f0_2() {
   if (OrderType() == OP_BUY && Bid >= OrderOpenPrice() + TrailingStop * Gd_240) {
      if (!(OrderStopLoss() == 0.0 || OrderStopLoss() < Bid - TrailingStop * Gd_240 - TrailingStep * Gd_240)) return;
      OrderModify(OrderTicket(), OrderOpenPrice(), Bid - TrailingStop * Gd_240, OrderTakeProfit(), 0, CLR_NONE);
      return;
   }
   if (OrderType() == OP_SELL && Ask <= OrderOpenPrice() - TrailingStop * Gd_240)
      if (OrderStopLoss() == 0.0 || OrderStopLoss() > Ask + TrailingStop * Gd_240 + TrailingStep * Gd_240) OrderModify(OrderTicket(), OrderOpenPrice(), Ask + TrailingStop * Gd_240, OrderTakeProfit(), 0, CLR_NONE);
}

// A5D053FE96FA99510D8C6DC908118731
void f0_4() {
   if (OrderStopLoss() != OrderOpenPrice()) {
      if (OrderType() == OP_BUY) {
         if (!(OrderStopLoss() == 0.0 || OrderStopLoss() < OrderOpenPrice() && Bid >= OrderOpenPrice() + BEPoint * Gd_240)) return;
         OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice(), OrderTakeProfit(), 0, CLR_NONE);
         return;
      }
      if (OrderType() == OP_SELL)
         if (OrderStopLoss() == 0.0 || OrderStopLoss() > OrderOpenPrice() && Ask <= OrderOpenPrice() - BEPoint * Gd_240) OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice(), OrderTakeProfit(), 0, CLR_NONE);
   }
}

// D7D6DDD9B8A483B70E970CCB2F0BCCA3
void f0_7(int A_cmd_0) {
   int pos_4 = 0;
   while (pos_4 < OrdersTotal()) {
      if (!(OrderSelect(pos_4, SELECT_BY_POS))) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == G_magic_236 && A_cmd_0 == OP_BUYLIMIT || OrderType() == A_cmd_0) f0_12();
      else pos_4++;
   }
}

// EBF78B512222FE4DCD14E7D5060A15B0
void f0_9() {
   string Ls_4;
   if (DisplayData) {
      Gd_248 = 0;
      Gd_256 = 0;
      G_count_208 = 0;
      G_count_212 = 0;
      for (int pos_0 = OrdersHistoryTotal() - 1; pos_0 >= 0; pos_0--) {
         if (OrderSelect(pos_0, SELECT_BY_POS, MODE_HISTORY)) {
            if (OrderSymbol() == Symbol()) {
               if (OrderMagicNumber() == G_magic_236) {
                  if (OrderCloseTime() >= G_datetime_272) {
                     if (OrderProfit() >= 0.0) {
                        G_count_208++;
                        Gd_248 += OrderProfit();
                        continue;
                     }
                     G_count_212++;
                     Gd_256 += OrderProfit();
                  }
               }
            }
         }
      }
   }
   if (!DisplayData) Ls_4 = "";
   else {
      Ls_4 = "\n-----------------------------" 
         + "\n-- " + "Total realized profit/loss:  " + DoubleToStr(Gd_248 + Gd_256, 2) 
         + "\n-- " + "Total # of trades:  " + ((G_count_208 + G_count_212)) 
         + "\n-----------------------------" 
         + "\n-- " + "# of winning trades:  " + G_count_208 
         + "\n-- " + "Total realized profit from winning trades:  " + DoubleToStr(Gd_248, 2) 
         + "\n-- " + "# of losing trades:  " + G_count_212 
      + "\n-- " + "Total realized loss from losing trades:  " + DoubleToStr(Gd_256, 2);
   }
   Comment("\nWise-EA Concept EA: CL_EC_01_ManualTradingBackTester" 
      + "\n-----------------------------" 
      + "\n-- " + "Buy:  " + HotKey_Buy + " | Sell:  " + HotKey_Sell + " | Close_Buy:  " + HotKey_Close_Buy + " | Close_Sell:  " + HotKey_Close_Sell + " | Close All:  " + HotKey_CloseAll + Ls_4 
   + "\n-----------------------------");
}

// B3780894B1A8A1CA3FE972FC3314C77C
void f0_6(int A_cmd_0) {
   string Ls_4;
   double price_12;
   double price_20;
   double price_28;
   int error_48;
   color color_36 = Lime;
   if (A_cmd_0 == OP_SELL || A_cmd_0 == OP_SELLLIMIT || A_cmd_0 == OP_SELLSTOP) color_36 = Red;
   if (A_cmd_0 == OP_BUY) {
      price_12 = Ask;
      Ls_4 = " BUY";
   } else {
      if (A_cmd_0 == OP_SELL) {
         price_12 = Bid;
         Ls_4 = " SELL";
      }
   }
   int ticket_40 = OrderSend(Symbol(), A_cmd_0, f0_10(), price_12, 5, 0, 0, G_comment_264, G_magic_236, 0, color_36);
   if (ticket_40 > 0) {
      if (ticket_40 > 0 && OrderSelect(ticket_40, SELECT_BY_TICKET, MODE_TRADES)) {
         Alert(TimeToStr(TimeCurrent(), TIME_DATE|TIME_SECONDS) + " | " + G_comment_264 + " | " + Ls_4 + " order (" + OrderTicket() + ") opened: " + " @" + DoubleToStr(OrderOpenPrice(),
            G_digits_204));
         if (A_cmd_0 == OP_BUY) {
            if (StopLoss != 0.0) price_20 = OrderOpenPrice() - StopLoss * Gd_240;
            else price_20 = 0;
            if (TakeProfit != 0.0) price_28 = OrderOpenPrice() + TakeProfit * Gd_240;
            else price_28 = 0;
         } else {
            if (A_cmd_0 == OP_SELL) {
               if (StopLoss != 0.0) price_20 = OrderOpenPrice() + StopLoss * Gd_240;
               else price_20 = 0;
               if (TakeProfit != 0.0) price_28 = OrderOpenPrice() - TakeProfit * Gd_240;
               else price_28 = 0;
            }
         }
         if (price_28 != 0.0 || price_20 != 0.0) {
            for (int Li_44 = 5; Li_44 > 0; Li_44--) {
               OrderModify(ticket_40, OrderOpenPrice(), price_20, price_28, 0, CLR_NONE);
               error_48 = GetLastError();
               if (error_48 == 1/* NO_RESULT */) error_48 = 0;
               if (error_48 == 0/* NO_ERROR */) break;
               Sleep(1000);
               RefreshRates();
            }
         }
      }
   } else Print(TimeToStr(TimeCurrent(), TIME_DATE|TIME_SECONDS) + " | " + G_comment_264 + " | " + " Error opening order : ", GetLastError());
}

// FD195FAAFB381C3C831EC9C02B980F3F
void f0_12() {
   double price_0;
   if (OrderType() == OP_BUY) price_0 = Bid;
   else
      if (OrderType() == OP_SELL) price_0 = Ask;
   bool is_closed_8 = OrderClose(OrderTicket(), OrderLots(), price_0, 5, MediumSeaGreen);
   if (is_closed_8) {
      Alert(TimeToStr(TimeCurrent(), TIME_DATE|TIME_SECONDS) + " | " + G_comment_264 + " | " + " Order (" + OrderTicket() + ")  closed: " + " @" + DoubleToStr(OrderClosePrice(),
         G_digits_204));
      return;
   }
   Print(TimeToStr(TimeCurrent(), TIME_DATE|TIME_SECONDS) + " | " + G_comment_264 + " | " + " Error closing order : ", GetLastError());
}

// EBFE91FAEB07FF5788FD1001AD46AE29
double f0_10() {
   int Li_8;
   double marginrequired_12;
   double Ld_ret_0 = 0;
   if (UseAutoLots) {
      if (MarketInfo(Symbol(), MODE_LOTSTEP) == 0.01) Li_8 = 2;
      else {
         if (MarketInfo(Symbol(), MODE_LOTSTEP) == 0.1) Li_8 = 1;
         else Li_8 = 0;
      }
      marginrequired_12 = MarketInfo(Symbol(), MODE_MARGINREQUIRED);
      Ld_ret_0 = NormalizeDouble(AccountBalance() * (Risk_Ratio / 100.0) / marginrequired_12, Li_8);
   } else Ld_ret_0 = OpenLot;
   if (Ld_ret_0 < MarketInfo(Symbol(), MODE_MINLOT)) Ld_ret_0 = MarketInfo(Symbol(), MODE_MINLOT);
   else
      if (Ld_ret_0 > MarketInfo(Symbol(), MODE_MAXLOT)) Ld_ret_0 = MarketInfo(Symbol(), MODE_MAXLOT);
   return (Ld_ret_0);
}

// F2821E8CBB270B407F5B101147B88072
int f0_11(string As_0) {
   if (StringFind(f0_3(As_0), "0") > -1) return (48);
   if (StringFind(f0_3(As_0), "1") > -1) return (49);
   if (StringFind(f0_3(As_0), "2") > -1) return (50);
   if (StringFind(f0_3(As_0), "3") > -1) return (51);
   if (StringFind(f0_3(As_0), "4") > -1) return (52);
   if (StringFind(f0_3(As_0), "5") > -1) return (53);
   if (StringFind(f0_3(As_0), "6") > -1) return (54);
   if (StringFind(f0_3(As_0), "7") > -1) return (55);
   if (StringFind(f0_3(As_0), "8") > -1) return (56);
   if (StringFind(f0_3(As_0), "9") > -1) return (57);
   if (StringFind(f0_3(As_0), "A") > -1) return (65);
   if (StringFind(f0_3(As_0), "B") > -1) return (66);
   if (StringFind(f0_3(As_0), "C") > -1) return (67);
   if (StringFind(f0_3(As_0), "D") > -1) return (68);
   if (StringFind(f0_3(As_0), "E") > -1) return (69);
   if (StringFind(f0_3(As_0), "F") > -1) return (70);
   if (StringFind(f0_3(As_0), "G") > -1) return (71);
   if (StringFind(f0_3(As_0), "H") > -1) return (72);
   if (StringFind(f0_3(As_0), "I") > -1) return (73);
   if (StringFind(f0_3(As_0), "J") > -1) return (74);
   if (StringFind(f0_3(As_0), "K") > -1) return (75);
   if (StringFind(f0_3(As_0), "L") > -1) return (76);
   if (StringFind(f0_3(As_0), "M") > -1) return (77);
   if (StringFind(f0_3(As_0), "N") > -1) return (78);
   if (StringFind(f0_3(As_0), "O") > -1) return (79);
   if (StringFind(f0_3(As_0), "P") > -1) return (80);
   if (StringFind(f0_3(As_0), "Q") > -1) return (81);
   if (StringFind(f0_3(As_0), "R") > -1) return (82);
   if (StringFind(f0_3(As_0), "S") > -1) return (83);
   if (StringFind(f0_3(As_0), "T") > -1) return (84);
   if (StringFind(f0_3(As_0), "U") > -1) return (85);
   if (StringFind(f0_3(As_0), "V") > -1) return (86);
   if (StringFind(f0_3(As_0), "W") > -1) return (87);
   if (StringFind(f0_3(As_0), "X") > -1) return (88);
   if (StringFind(f0_3(As_0), "Y") > -1) return (89);
   if (StringFind(f0_3(As_0), "Z") > -1) return (90);
   return (0);
}

// 92DFF40263F725411B5FB6096A8D564E
string f0_3(string As_0) {
   string Ls_ret_16;
   int str_len_8 = StringLen(As_0);
   int Li_12 = 0;
   for (int Li_24 = 0; Li_24 < str_len_8; Li_24++) {
      Li_12 = StringGetChar(As_0, Li_24);
      if (Li_12 >= 97 && Li_12 <= 122) Li_12 -= 32;
      Ls_ret_16 = Ls_ret_16 + CharToStr(Li_12);
   }
   return (Ls_ret_16);
}

// B0A937E0707BD38336617900D00D24A0
void f0_5() {
   f0_1("LOGO" + "0", "", 20, DarkGray, 3, 275, 5, "Arial", 150);
   f0_1("LOGO" + "1", "Product of Wise-EA Programming", 10, DarkGray, 3, 70, 10, "Arial", 0);
   f0_1("LOGO" + "2", "", 20, DarkGray, 3, 37, 5, "Arial", 151);
}

// 509EB2CDBFCCB9AF9DD0ADFF16C70741
void f0_1(string A_name_0, string A_text_8, int A_fontsize_16, color A_color_20, int A_corner_24, int A_x_28, int A_y_32, string A_fontname_36, int Ai_44) {
   ObjectDelete(IndicatorObjPrefix + A_name_0);
   ObjectCreate(IndicatorObjPrefix + A_name_0, OBJ_LABEL, 0, 0, 0);
   if (A_text_8 != "") ObjectSetText(IndicatorObjPrefix + A_name_0, A_text_8, A_fontsize_16, A_fontname_36, A_color_20);
   else ObjectSetText(IndicatorObjPrefix + A_name_0, CharToStr(Ai_44), A_fontsize_16, "Wingdings", A_color_20);
   ObjectSet(IndicatorObjPrefix + A_name_0, OBJPROP_CORNER, A_corner_24);
   ObjectSet(IndicatorObjPrefix + A_name_0, OBJPROP_XDISTANCE, A_x_28);
   ObjectSet(IndicatorObjPrefix + A_name_0, OBJPROP_YDISTANCE, A_y_32);
}

// 1295BD0766D450411297FF78E4068DA3
void f0_0(string As_0) {
   string name_12;
   int Li_8 = 0;
   while (Li_8 < ObjectsTotal()) {
      name_12 = ObjectName(Li_8);
      if (StringSubstr(name_12, 0, StringLen(As_0)) == As_0) ObjectDelete(name_12);
      else Li_8++;
   }
}

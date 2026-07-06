// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=75582

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC  | 
// |                                                                         http://fxcodebase.com  |
// |                                                               Paypal:  https://goo.gl/9Rj74e   |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by : Mario Jemic   |                    
// |                                                                       mario.jemic@gmail.com    |
// |                                                                       https://mario-jemic.com/ | 
// |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
// |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
// +-----------------+----------------------+-------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                              |
// +-----------------+----------------------+-------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// +-----------------+----------------------+-------------------------------------------------------+ 


#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property indicator_chart_window
#property indicator_buffers 7
#property indicator_plots 7
#property strict
#property indicator_type1  DRAW_LINE
#property indicator_style1 STYLE_SOLID
#property indicator_color1 clrBlue
#property indicator_width1 1

#property indicator_type2  DRAW_LINE
#property indicator_style2 STYLE_SOLID
#property indicator_color2 clrDimGray
#property indicator_width2 1

#property indicator_type3  DRAW_LINE
#property indicator_style3 STYLE_SOLID
#property indicator_color3 clrRed
#property indicator_width3 1

#property indicator_type4  DRAW_LINE
#property indicator_style4 STYLE_SOLID
#property indicator_color4 clrRed
#property indicator_width4 1

#property indicator_type5  DRAW_LINE
#property indicator_style5 STYLE_SOLID
#property indicator_color5 clrDimGray
#property indicator_width5 1

#property indicator_type6  DRAW_LINE
#property indicator_style6 STYLE_SOLID
#property indicator_color6 clrLimeGreen
#property indicator_width6 1

#property indicator_type7  DRAW_LINE
#property indicator_style7 STYLE_SOLID
#property indicator_color7 clrLimeGreen
#property indicator_width7 1

input string MBFXSYS= "---MBFX SYSTEM---";
input int    Nmbr_Bars = 120;
input int    Order = 3;
input double Ecart = 1.61803399;

input string MBFXTIMING= "---MBFX TIMING---";
input int Len = 7;
input double Filter = 0.0;

input string MBFXALERT= "---ALERT---";
input bool ShowAlert=true;
input bool EmailAlert=false;

double REG[];
double X1[];
double X2[];
double X3[];
double Z1[];
double Z2[];
double Z3[];
double mass1[20][20];
double mass2[20];
double mass3[20];
double mass4[20];
int    i,cycle,numM,flag,def,Nmb,cycle3;
double flagR,StdDev,rMass,flagS,sMass;
double LineY[];//Yellow
double LineG[];//Green
double LineR[];//Red

double mode,slope;
double ResL,ResY,ResR,ResB,DevY,DevR,DevB,ShtftY,ShtftR,ShtftB,EnterY,EnterR,EnterB;
double Akun,FilledR,FilledB,changeY,changeR,changeB,changeG,StepY,StepR,StepB,Range;

double NormalisedPip=0;
datetime pTimeBar=0;
bool TouchedGreen=false;
bool TouchedRed=false;
bool YellowTiming=false;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
{
  Comment("MBFX System");
  SetIndexBuffer(0, REG);
  SetIndexBuffer(1, X1);
  SetIndexBuffer(2, X2);//Red
  SetIndexBuffer(3, X3);//Red
  SetIndexBuffer(4, Z1);
  SetIndexBuffer(5, Z2);//Lime Green
  SetIndexBuffer(6, Z3);//Lime Green
  ArraySetAsSeries(REG,true);
  ArraySetAsSeries(X1,true);
  ArraySetAsSeries(X2,true);
  ArraySetAsSeries(X3,true);
  ArraySetAsSeries(Z1,true);
  ArraySetAsSeries(Z2,true);
  ArraySetAsSeries(Z3,true);
  if (Digits() == 3 || Digits() == 5) NormalisedPip = 10.0 * Point();
  else NormalisedPip = Point();
//-
  ObjectCreate(0,"REG", OBJ_ARROW_RIGHT_PRICE, 0, 0, 0);
  ObjectCreate(0,"X1", OBJ_ARROW_RIGHT_PRICE, 0, 0, 0);
  ObjectCreate(0,"X2", OBJ_ARROW_RIGHT_PRICE, 0, 0, 0);
  ObjectCreate(0,"X3", OBJ_ARROW_RIGHT_PRICE, 0, 0, 0);
  ObjectCreate(0,"Z1", OBJ_ARROW_RIGHT_PRICE, 0, 0, 0);
  ObjectCreate(0,"Z2", OBJ_ARROW_RIGHT_PRICE, 0, 0, 0);
  ObjectCreate(0,"Z3", OBJ_ARROW_RIGHT_PRICE, 0, 0, 0);
//-
  hStdDev=iStdDev(NULL, 0, Nmbr_Bars, 0, MODE_SMA, PRICE_HIGH);
  ChartRedraw();
  return(INIT_SUCCEEDED);
}
int hStdDev=-1;
double buf[1];

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
  Comment("");
  ObjectDelete(0,"REG");
  ObjectDelete(0,"X1");
  ObjectDelete(0,"X2");
  ObjectDelete(0,"X3");
  ObjectDelete(0,"Z1");
  ObjectDelete(0,"Z2");
  ObjectDelete(0,"Z3");
  ChartRedraw();
}
//+------------------------------------------------------------------+
//|                                                                  |
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
  if(prev_calculated<1) {
    ArrayInitialize(REG,EMPTY_VALUE);
    ArrayInitialize(X1,EMPTY_VALUE);
    ArrayInitialize(X2,EMPTY_VALUE);
    ArrayInitialize(X3,EMPTY_VALUE);
    ArrayInitialize(Z1,EMPTY_VALUE);
    ArrayInitialize(Z2,EMPTY_VALUE);
    ArrayInitialize(Z3,EMPTY_VALUE);
  }
  ArraySetAsSeries(time,true);
  ArraySetAsSeries(open,true);
  ArraySetAsSeries(high,true);
  ArraySetAsSeries(low,true);
  ArraySetAsSeries(close,true);

  PlotIndexSetInteger(0,PLOT_DRAW_BEGIN, rates_total - Nmbr_Bars - 1);
  PlotIndexSetInteger(1,PLOT_DRAW_BEGIN, rates_total - Nmbr_Bars - 1);
  PlotIndexSetInteger(2,PLOT_DRAW_BEGIN, rates_total - Nmbr_Bars - 1);
  PlotIndexSetInteger(3,PLOT_DRAW_BEGIN, rates_total - Nmbr_Bars - 1);
  PlotIndexSetInteger(4,PLOT_DRAW_BEGIN, rates_total - Nmbr_Bars - 1);
  PlotIndexSetInteger(5,PLOT_DRAW_BEGIN, rates_total - Nmbr_Bars - 1);
  PlotIndexSetInteger(6,PLOT_DRAW_BEGIN, rates_total - Nmbr_Bars - 1);

  int NewBarVar=NewBar();
  int BARS = rates_total - Len - 1;
  ArrayResize(LineY, BARS+2);
  ArrayResize(LineG, BARS+2);
  ArrayResize(LineR, BARS+2);
//MBFX System
  def = Order + 1;
  mass2[1] = Nmbr_Bars + 1;
  for (cycle3 = 1; cycle3 <= def * 2 - 2; cycle3++) {
    flagR = 0;
    for (Nmb = 0; Nmb <= Nmbr_Bars; Nmb++) flagR += MathPow(Nmb, cycle3);
    mass2[cycle3 + 1] = flagR;
  }
  for (cycle3 = 1; cycle3 <= def; cycle3++) {
    flagR = 0;
    for (Nmb = 0; Nmb <= Nmbr_Bars; Nmb++) {
      if (cycle3 == 1) flagR += (high[Nmb] + low[Nmb]) / 2.0;
      else flagR += (high[Nmb] + low[Nmb]) / 2.0 * MathPow(Nmb, cycle3 - 1);
    }
    mass3[cycle3] = flagR;
  }
  for (cycle = 1; cycle <= def; cycle++) {
    for (i = 1; i <= def; i++) {
      numM = i + cycle - 1;
      mass1[i][cycle] = mass2[numM];
    }
  }
  for (numM = 1; numM <= def - 1; numM++) {
    flag = 0;
    flagS = 0;
    for (i = numM; i <= def; i++) {
      if (MathAbs(mass1[i][numM]) > flagS) {
        flagS = MathAbs(mass1[i][numM]);
        flag = i;
      }
    }
    if (flag == 0) return(rates_total);
    if (flag != numM) {
      for (cycle = 1; cycle <= def; cycle++) {
        sMass = mass1[numM][cycle];
        mass1[numM][cycle] = mass1[flag][cycle];
        mass1[flag][cycle] = sMass;
      }
      sMass = mass3[numM];
      mass3[numM] = mass3[flag];
      mass3[flag] = sMass;
    }
    for (i = numM + 1; i <= def; i++) {
      rMass = mass1[i][numM] / mass1[numM][numM];
      for (cycle = 1; cycle <= def; cycle++) {
        if (cycle == numM) mass1[i][cycle] = 0;
        else mass1[i][cycle] = mass1[i][cycle] - rMass * mass1[numM][cycle];
      }
      mass3[i] = mass3[i] - rMass * mass3[numM];
    }
  }
  mass4[def] = mass3[def] / mass1[def][def];
  for (i = def - 1; i >= 1; i--) {
    sMass = 0;
    for (cycle = 1; cycle <= def - i; cycle++) {
      sMass += (mass1[i][i + cycle]) * (mass4[i + cycle]);
      mass4[i] = 1 / mass1[i][i] * (mass3[i] - sMass);
    }
  }
  for (Nmb = 0; Nmb <= Nmbr_Bars; Nmb++) {
    flagR = 0;
    for (numM = 1; numM <= Order; numM++) flagR += (mass4[numM + 1]) * MathPow(Nmb, numM);
    REG[Nmb] = mass4[1] + flagR;
  }
  CopyBuffer(hStdDev,0,0,1,buf);
  StdDev = buf[0]/*iStdDev(NULL, 0, Nmbr_Bars, 0, MODE_SMA, PRICE_HIGH, 0)*/ * Ecart;
  for (Nmb = 0; Nmb <= Nmbr_Bars; Nmb++) {
    X3[Nmb] = REG[Nmb] + StdDev;//Red
    X2[Nmb] = REG[Nmb] + (X3[Nmb] - REG[Nmb]) / 1.382;//low Line Red
    X1[Nmb] = REG[Nmb] + (X2[Nmb] - REG[Nmb]) / 1.618;
    Z3[Nmb] = REG[Nmb] - StdDev;//Lime
    Z2[Nmb] = REG[Nmb] - (REG[Nmb] - Z3[Nmb]) / 1.382;//high Line Lime
    Z1[Nmb] = REG[Nmb] - (REG[Nmb] - Z2[Nmb]) / 1.618;
  }
//Check Touch Red/Green Line
  if (NewBarVar==1) {
    if ((Z2[1]>=low[1]) && (TouchedGreen==false)) {
      TouchedGreen=true;
    }
    if ((X2[1]<=high[1]) && (TouchedRed==false)) {
      TouchedRed=true;
    }
  }

  ObjectSetInteger(0,"REG", OBJPROP_TIME, time[0]);
  ObjectSetDouble(0,"REG", OBJPROP_PRICE, REG[0]);
  ObjectSetInteger(0,"REG", OBJPROP_COLOR, clrBlue);
  ObjectSetInteger(0,"X1", OBJPROP_TIME, time[0]);
  ObjectSetDouble(0,"X1", OBJPROP_PRICE, X1[0]);
  ObjectSetInteger(0,"X1", OBJPROP_COLOR, clrDimGray);
  ObjectSetInteger(0,"X2", OBJPROP_TIME, time[0]);
  ObjectSetDouble(0,"X2", OBJPROP_PRICE, X2[0]);
  ObjectSetInteger(0,"X2", OBJPROP_COLOR, clrRed);
  ObjectSetInteger(0,"X3", OBJPROP_TIME, time[0]);
  ObjectSetDouble(0,"X3", OBJPROP_PRICE, X3[0]);
  ObjectSetInteger(0,"X3", OBJPROP_COLOR, clrRed);
  ObjectSetInteger(0,"Z1", OBJPROP_TIME, time[0]);
  ObjectSetDouble(0,"Z1", OBJPROP_PRICE, Z1[0]);
  ObjectSetInteger(0,"Z1", OBJPROP_COLOR, clrDimGray);
  ObjectSetInteger(0,"Z2", OBJPROP_TIME, time[0]);
  ObjectSetDouble(0,"Z2", OBJPROP_PRICE, Z2[0]);
  ObjectSetInteger(0,"Z2", OBJPROP_COLOR, clrLimeGreen);
  ObjectSetInteger(0,"Z3", OBJPROP_TIME, time[0]);
  ObjectSetDouble(0,"Z3", OBJPROP_PRICE, Z3[0]);
  ObjectSetInteger(0,"Z3", OBJPROP_COLOR, clrLimeGreen);
//Timing
  double limit=0;
  for (int li_224 = BARS; li_224 >= 0; li_224--) {
    if (mode == 0.0) {
      mode = 1.0;
      slope = 0.0;
      if (Len - 1 >= 5) limit = Len - 1.0;
      else limit = 5.0;
      ShtftY = 100.0 * ((high[li_224] + low[li_224] + close[li_224]) / 3.0);
      ShtftB = 3.0 / (Len + 2.0);
      EnterY = 1.0 - ShtftB;
    } else {
      if (limit <= mode) mode = limit + 1.0;
      else mode += 1.0;
      ShtftR = ShtftY;
      ShtftY = 100.0 * ((high[li_224] + low[li_224] + close[li_224]) / 3.0);
      ResY = ShtftY - ShtftR;
      EnterR = EnterY * EnterR + ShtftB * ResY;
      EnterB = ShtftB * EnterR + EnterY * EnterB;
      ResR = 1.5 * EnterR - EnterB / 2.0;
      Akun = EnterY * Akun + ShtftB * ResR;
      Range = ShtftB * Akun + EnterY * Range;
      ResB = 1.5 * Akun - Range / 2.0;
      FilledR = EnterY * FilledR + ShtftB * ResB;
      changeY = ShtftB * FilledR + EnterY * changeY;
      DevY = 1.5 * FilledR - changeY / 2.0;
      changeR = EnterY * changeR + ShtftB * MathAbs(ResY);
      changeB = ShtftB * changeR + EnterY * changeB;
      DevR = 1.5 * changeR - changeB / 2.0;
      changeG = EnterY * changeG + ShtftB * DevR;
      StepY = ShtftB * changeG + EnterY * StepY;
      FilledB = 1.5 * changeG - StepY / 2.0;
      StepR = EnterY * StepR + ShtftB * FilledB;
      StepB = ShtftB * StepR + EnterY * StepB;
      DevB = 1.5 * StepR - StepB / 2.0;
      if (limit >= mode && ShtftY != ShtftR) slope = 1.0;
      if (limit == mode && slope == 0.0) mode = 0.0;
    }
    if (limit < mode && DevB > 0.0000000001) {
      ResL = 50.0 * (DevY / DevB + 1.0);
      if (ResL > 100.0) ResL = 100.0;
      if (ResL < 0.0) ResL = 0.0;
    } else ResL = 50.0;
    LineY[li_224] = ResL;//Yellow
    LineG[li_224] = ResL;//Green
    LineR[li_224] = ResL;//Red
    if (LineY[li_224] > LineY[li_224 + 1] - Filter) {
      LineR[li_224] = EMPTY_VALUE;
      YellowTiming=false;
    } else {
      if (LineY[li_224] < LineY[li_224 + 1] + Filter) {
        LineG[li_224] = EMPTY_VALUE;
        YellowTiming=false;
      } else {
        if (LineY[li_224] == LineY[li_224 + 1] + Filter) {
          LineG[li_224] = EMPTY_VALUE;
          LineR[li_224] = EMPTY_VALUE;
        }
      }
    }
  }
//Check rule
  if (NewBarVar==0) return(rates_total);
  if (NewBarVar==1) {
    if ((LineG[2]== EMPTY_VALUE && LineR[2]!= EMPTY_VALUE && LineG[1]!= EMPTY_VALUE && LineR[1]== EMPTY_VALUE)||
        ((LineG[2]!= EMPTY_VALUE && LineR[2]== EMPTY_VALUE && LineG[1]== EMPTY_VALUE && LineR[1]!= EMPTY_VALUE))) {
      YellowTiming=true;
    } else YellowTiming=false;
  }

  if (YellowTiming) { //Yellow Timing
    if (TouchedRed) { //Sell Alert
      TouchedRed=false;
      if (ShowAlert) Alert("MBFX Signal: SELL " + Symbol() + " On M" + (string)Period() + " At " + DoubleToString(SymbolInfoDouble(Symbol(),SYMBOL_BID), Digits()));
      if (EmailAlert) SendMail("MBFX Signal","MBFX Signal: SELL " + Symbol() + " On M" + (string)Period() + " At " + DoubleToString(SymbolInfoDouble(Symbol(),SYMBOL_BID), Digits()));
    } else if (TouchedGreen) { //Buy Alert
      TouchedGreen=false;
      if (ShowAlert) Alert("MBFX Signal: BUY " + Symbol() + " On M" + (string)Period() + " At " + DoubleToString(SymbolInfoDouble(Symbol(),SYMBOL_ASK), Digits()));
      if (EmailAlert) SendMail("MBFX Signal","MBFX Signal: BUY " + Symbol() + " On M" + (string)Period() + " At " + DoubleToString(SymbolInfoDouble(Symbol(),SYMBOL_ASK), Digits()));
    }
  }
  return(rates_total);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int NewBar()
{
  if (iTime(NULL,0,0) != pTimeBar) {
    pTimeBar = iTime(NULL,0,0);
    return(1);
  }
  return(0);
}
//+------------------------------------------------------------------+
// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=75582

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC  | 
// |                                                                         http://fxcodebase.com  |
// |                                                               Paypal:  https://goo.gl/9Rj74e   |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by : Mario Jemic   |                    
// |                                                                       mario.jemic@gmail.com    |
// |                                                                       https://mario-jemic.com/ | 
// |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
// |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
// +-----------------+----------------------+-------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                              |
// +-----------------+----------------------+-------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// +-----------------+----------------------+-------------------------------------------------------+ 
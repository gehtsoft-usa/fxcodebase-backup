// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=72440

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
#property indicator_buffers 6
#property indicator_plots 6

#property indicator_label1 "1Green"
#property indicator_type1  DRAW_LINE
#property indicator_color1 clrGreen
#property indicator_style1 STYLE_SOLID
#property indicator_width1 3
#property indicator_label2 "1Red"
#property indicator_type2  DRAW_LINE
#property indicator_color2 clrRed
#property indicator_style2 STYLE_SOLID
#property indicator_width2 3
#property indicator_label3 "2Green"
#property indicator_type3  DRAW_LINE
#property indicator_color3 clrGreen
#property indicator_style3 STYLE_SOLID
#property indicator_width3 3
#property indicator_label4 "2Red"
#property indicator_type4  DRAW_LINE
#property indicator_color4 clrRed
#property indicator_style4 STYLE_SOLID
#property indicator_width4 3
#property indicator_label5 "3Green"
#property indicator_type5  DRAW_LINE
#property indicator_color5 clrGreen
#property indicator_style5 STYLE_SOLID
#property indicator_width5 3
#property indicator_label6 "3Red"
#property indicator_type6  DRAW_LINE
#property indicator_color6 clrRed
#property indicator_style6 STYLE_SOLID
#property indicator_width6 3

#property indicator_minimum 0
#property indicator_maximum 2

//--- indicator buffers
double FirstLineGreen[];
double FirstLineRed[];
double SecondLineGreen[];
double SecondLineRed[];
double TherdLineGreen[];
double TherdLineRed[];

// NOTE: Inputs
// ------------------------------------------------------------------
input string             ma1t            = "== MA1 Setup ==";  // == MA1 Setup ==
input int                ma1Period       = 20;                 // Period
int                      ma1Shift        = 0;                  // Ma Shift
input ENUM_MA_METHOD     ma1Method       = MODE_EMA;           // Method
input ENUM_APPLIED_PRICE ma1AppliedPrice = PRICE_CLOSE;        // Applied Price
input string             ma2t            = "== MA2 Setup ==";  // == MA2 Setup ==
input int                ma2Period       = 50;                 // Period
int                      ma2Shift        = 0;                  // Ma Shift
input ENUM_MA_METHOD     ma2Method       = MODE_EMA;           // Method
input ENUM_APPLIED_PRICE ma2AppliedPrice = PRICE_CLOSE;        // Applied Price
input string             ma3t            = "== MA3 Setup ==";  // == MA3 Setup ==
input int                ma3Period       = 50;                 // Period
int                      ma3Shift        = 0;                  // Ma Shift
input ENUM_MA_METHOD     ma3Method       = MODE_EMA;           // Method
input ENUM_APPLIED_PRICE ma3AppliedPrice = PRICE_CLOSE;        // Applied Price
input string             ma4t            = "== MA4 Setup ==";  // == MA4 Setup ==
input int                ma4Period       = 100;                // Period
int                      ma4Shift        = 0;                  // Ma Shift
input ENUM_MA_METHOD     ma4Method       = MODE_EMA;           // Method
input ENUM_APPLIED_PRICE ma4AppliedPrice = PRICE_CLOSE;        // Applied Price
input string             ma5t            = "== MA5 Setup ==";  // == MA5 Setup ==
input int                ma5Period       = 100;                // Period
int                      ma5Shift        = 0;                  // Ma Shift
input ENUM_MA_METHOD     ma5Method       = MODE_EMA;           // Method
input ENUM_APPLIED_PRICE ma5AppliedPrice = PRICE_CLOSE;        // Applied Price
input string             ma6t            = "== MA6 Setup ==";  // == MA6 Setup ==
input int                ma6Period       = 200;                // Period
int                      ma6Shift        = 0;                  // Ma Shift
input ENUM_MA_METHOD     ma6Method       = MODE_EMA;           // Method
input ENUM_APPLIED_PRICE ma6AppliedPrice = PRICE_CLOSE;        // Applied Price
// ------------------------------------------------------------------

// NOTE: moving averages Class
class MovingAverage
{
  string _symbol;
  int    _tf;

  struct MovingAverageParameters
  {
    int setup0;  //  Period
    int setup1;  //  Ma Shift
    int setup2;  //  Method
    int setup3;  //  Applied Price
  };
  MovingAverageParameters _setup;

 public:
  MovingAverage()
  {
    _symbol = _Symbol;
    _tf     = Period();
    // setSetup(Period, maShift, Method, AppliedPrice);
  }
  MovingAverage(string Symbol, int TimeFrame)
  {
    _symbol = Symbol;
    _tf     = TimeFrame;
    // setSetup(Period, maShift, Method, AppliedPrice);
  }
  ~MovingAverage() { ; }

  void setSetup(
      int set0,
      int set1,
      int set2,
      int set3)
  {
    _setup.setup0 = set0;
    _setup.setup1 = set1;
    _setup.setup2 = set2;
    _setup.setup3 = set3;
  }

  double calculate(int buffer, int shift)
  {
    return iMA(_symbol, _tf,
               _setup.setup0,
               _setup.setup1,
               _setup.setup2,
               _setup.setup3,
               shift);
  }

  double index(int shift)
  {
    return calculate(0, shift);
  }
};
MovingAverage ma1();
MovingAverage ma2();
MovingAverage ma3();
MovingAverage ma4();
MovingAverage ma5();
MovingAverage ma6();

// NOTE: OnInit
// ------------------------------------------------------------------
int OnInit()
{
  //--- indicator buffers mapping
  SetIndexBuffer(0, FirstLineGreen, INDICATOR_DATA);
  SetIndexBuffer(1, FirstLineRed, INDICATOR_DATA);
  SetIndexBuffer(2, SecondLineGreen, INDICATOR_DATA);
  SetIndexBuffer(3, SecondLineRed, INDICATOR_DATA);
  SetIndexBuffer(4, TherdLineGreen, INDICATOR_DATA);
  SetIndexBuffer(5, TherdLineRed, INDICATOR_DATA);

  // NOTE: ma en onInit
  ma1.setSetup(ma1Period, ma1Shift, ma1Method, ma1AppliedPrice);
  ma2.setSetup(ma2Period, ma2Shift, ma2Method, ma2AppliedPrice);
  ma3.setSetup(ma3Period, ma3Shift, ma3Method, ma3AppliedPrice);
  ma4.setSetup(ma4Period, ma4Shift, ma4Method, ma4AppliedPrice);
  ma5.setSetup(ma5Period, ma5Shift, ma5Method, ma5AppliedPrice);
  ma6.setSetup(ma6Period, ma6Shift, ma6Method, ma6AppliedPrice);
  

	//---
  return (INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
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
  int i = rates_total - prev_calculated + 1;
  if (i >= rates_total) i = rates_total - 1;
  for (; i > 0; i--)
  {
		if(ma1.index(i) > ma2.index(i)) { FirstLineGreen[i] = 1.5; }
		if(ma1.index(i) < ma2.index(i)) { FirstLineRed[i]   = 1.5; }
		if(ma3.index(i) > ma4.index(i)) { SecondLineGreen[i]= 1.0; }
		if(ma3.index(i) < ma4.index(i)) { SecondLineRed[i]  = 1.0; }
		if(ma5.index(i) > ma6.index(i)) { TherdLineGreen[i] = 0.5; }
		if(ma5.index(i) < ma6.index(i)) { TherdLineRed[i]   = 0.5; }
  }

  return (rates_total);
}
//+------------------------------------------------------------------+
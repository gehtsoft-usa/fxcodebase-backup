// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=72805

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
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
#property description "Multi-asset cluster indicator taking all currencies as a sum of values forming market unity (1.0)"


#define BUF_NUM 19
#define SYM_NUM 15


#property indicator_separate_window
#property indicator_buffers BUF_NUM
#property indicator_plots BUF_NUM

#property indicator_color1 Green
#property indicator_color2 DarkBlue
#property indicator_color3 Red
#property indicator_color4 Gray
#property indicator_color5 Peru
#property indicator_color6 Gold
#property indicator_color7 Purple
#property indicator_color8 Teal

#property indicator_color9 LightGreen
#property indicator_color10 LightBlue
#property indicator_color11 Orange
#property indicator_color12 LightGray
#property indicator_color13 Brown
#property indicator_color14 Yellow
#property indicator_color15 Magenta

#property indicator_color16 Gray
#property indicator_color17 Gray
#property indicator_color18 LightGray
#property indicator_color19 LightGray

input string _1 = ""; // Cluster Indicator Settings
input string Instruments = "EURUSD,GBPUSD,USDCHF,USDJPY,AUDUSD,USDCAD,NZDUSD"; // ·    Instruments
input int BarLimit = 1000; // ·    BarLimit
input ENUM_DRAW_TYPE Draw = DRAW_LINE; // ·    Draw
input ENUM_APPLIED_PRICE PriceType = PRICE_CLOSE; // ·    PriceType
input ENUM_MA_METHOD PriceMethod = MODE_EMA; // ·    PriceMethod
input int PricePeriod = 1; // ·    PricePeriod
input bool AbsoluteValues = false; // ·    AbsoluteValues
input double Momentum = 0; // ·    Momentum [0..1]
input double Sigma1 = 1; // ·    Deviation Level Sigma 1 [0..3]
input double Sigma2 = 2; // ·    Deviation Level Sigma 2 [0..3]

input string _2 = ""; // Data Export to CSV file
input string SaveToFile = ""; // ·    SaveToFile
input bool ShiftLastBuffer = false; // ·    ShiftLastBuffer
input int BarLookback = 1; // ·    BarLookback

int ShiftedBuffer = -1;

bool initDone = false;

#include <CSOM/IndArray.mqh>
#include <CSOM/HashMapTemplate.mqh>

IndicatorArray buffers(BUF_NUM);
IndicatorArrayGetter getter(buffers);

string Symbols[];
int Direction[];
double Contracts[];
int Handles[];
int SymbolCount;

HashMapTemplate<string,int> workCurrencies;
int baseIndex = 0;
string BaseCurrency;
int LastBarCount;

bool initSymbols()
{
  SymbolCount = StringSplit(Instruments, ',', Symbols);
  if(SymbolCount >= SYM_NUM)
  {
    SymbolCount = SYM_NUM - 1;
    ArrayResize(Symbols, SymbolCount);
  }
  else if(SymbolCount == 0)
  {
    SymbolCount = 1;
    ArrayResize(Symbols, SymbolCount);
    Symbols[0] = Symbol();
  }
  
  ArrayResize(Direction, SymbolCount);
  ArrayInitialize(Direction, 0);
  ArrayResize(Contracts, SymbolCount);
  ArrayInitialize(Contracts, 1);
  ArrayResize(Handles, SymbolCount);
  ArrayInitialize(Handles, INVALID_HANDLE);
  
  string base = NULL;
  
  for(int i = 0; i < SymbolCount; i++)
  {
    if(!SymbolSelect(Symbols[i], true))
    {
      Print("Can't select ", Symbols[i]);
      return false;
    }
    
    string first, second;
    first = SymbolInfoString(Symbols[i], SYMBOL_CURRENCY_BASE);
    second = SymbolInfoString(Symbols[i], SYMBOL_CURRENCY_PROFIT);
    
    if(first != second)
    {
      workCurrencies.inc(first, 1);
      workCurrencies.inc(second, 1);
    }
    else
    {
      workCurrencies.inc(Symbols[i], 1);
    }
  }
  
  if(workCurrencies.getSize() >= SYM_NUM)
  {
    Print("Too many symbols, max ", (SYM_NUM - 1));
    return false;
  }
  
  if(ShiftLastBuffer)
  {
    ShiftedBuffer = workCurrencies.getSize() - 1;
  }
  
  for(int i = 0; i < workCurrencies.getSize(); i++)
  {
    if(workCurrencies[i] > 1)
    {
      if(base == NULL)
      {
        base = workCurrencies.getKey(i);
        baseIndex = i;
      }
      else
      {
        Print("Collision: multiple base symbols: ", base, "[", workCurrencies[base], "] ", workCurrencies.getKey(i), "[", workCurrencies[i], "]");
        return false;
      }
    }
  }
  
  BaseCurrency = base;
  
  for(int i = 0; i < SymbolCount; i++)
  {
    if(SymbolInfoString(Symbols[i], SYMBOL_CURRENCY_PROFIT) == base) Direction[i] = +1;
    else if(SymbolInfoString(Symbols[i], SYMBOL_CURRENCY_BASE) == base) Direction[i] = -1;
    else
    {
      Print("Ambiguous symbol direction ", Symbols[i], ", defaults used");
      Direction[i] = +1;
    }
    
    Contracts[i] = SymbolInfoDouble(Symbols[i], SYMBOL_TRADE_CONTRACT_SIZE);
    Handles[i] = iMA(Symbols[i], PERIOD_CURRENT, PricePeriod, 0, PriceMethod, PriceType);
  }
  
  return true;
}

int OnInit()
{
  ShiftedBuffer = -1;
  initDone = false;
  
  if(!initSymbols()) return INIT_PARAMETERS_INCORRECT;
  
  string base = SymbolInfoString(_Symbol, SYMBOL_CURRENCY_BASE);
  string profit = SymbolInfoString(_Symbol, SYMBOL_CURRENCY_PROFIT);
  
  int replaceIndex = -1;
  for(int i = 0; i <= SymbolCount; i++)
  {
    string name;
    if(i == 0)
    {
      name = BaseCurrency;
      if(name != workCurrencies.getKey(i))
      {
        replaceIndex = i;
      }
    }
    else
    {
      if(BaseCurrency == workCurrencies.getKey(i) && replaceIndex > -1)
      {
        name = workCurrencies.getKey(replaceIndex);
      }
      else
      {
        name = workCurrencies.getKey(i);
      }
    }
    
    PlotIndexSetString(i, PLOT_LABEL, name);
    int width = (name == base || name == profit || name == _Symbol) ? 2 : 1;
    PlotIndexSetInteger(i, PLOT_DRAW_TYPE, Draw);
    PlotIndexSetInteger(i, PLOT_LINE_WIDTH, width);
    PlotIndexSetInteger(i, PLOT_SHOW_DATA, true);
  }
  
  for(int i = SymbolCount + 1; i < SYM_NUM; i++)
  {
    PlotIndexSetInteger(i, PLOT_SHOW_DATA, false);
  }
  
  for(int i = SYM_NUM; i < BUF_NUM; i++)
  {
    PlotIndexSetString(i, PLOT_LABEL, (string)(float)(i - SYM_NUM < (BUF_NUM - SYM_NUM) / 2 ? Sigma1 : Sigma2) + " Sigma (StdDev)");
    PlotIndexSetInteger(i, PLOT_DRAW_TYPE, Draw);
    PlotIndexSetInteger(i, PLOT_LINE_WIDTH, 1);
    PlotIndexSetInteger(i, PLOT_LINE_STYLE, STYLE_DOT);
    PlotIndexSetInteger(i, PLOT_SHOW_DATA, true);
    PlotIndexSetInteger(i, PLOT_SHIFT, 1);
  }
  
  if(!AbsoluteValues)
  {
    IndicatorSetInteger(INDICATOR_LEVELS, 1);
    IndicatorSetDouble(INDICATOR_LEVELVALUE, 0, 0.0);
  }
  
  string price_type = EnumToString(PriceType);
  StringReplace(price_type, "PRICE_", "");
  string price_mode = (PricePeriod > 1) ? " " + EnumToString(PriceMethod) + "(" + (string)PricePeriod + ")" : "";
  StringReplace(price_mode, "MODE_", "");
  IndicatorSetString(INDICATOR_SHORTNAME, "UnityPro [" + (string)workCurrencies.getSize() + "] " + price_type + price_mode + (AbsoluteValues ? " Abs " : "") + (Momentum > 0 ? " M=" + (string)(float)Momentum : ""));
  IndicatorSetInteger(INDICATOR_DIGITS, 5);
  
  LastBarCount = 0;
  initDone = true;
  
  EventSetTimer(1);

  return INIT_SUCCEEDED;
}


bool calculate(const int bar, double &result[])
{
  datetime time = iTime(_Symbol, PERIOD_CURRENT, bar);
  
  double w[2] = {0};
  double v[][2];
  ArrayResize(v, SymbolCount);
  
  for(int j = 0; j < SymbolCount; j++)
  {
    if(CopyBuffer(Handles[j], 0, time, 2, w) == -1)
    {
      Print("CopyBuffer failed: ", Symbols[j], " ", time, " ", GetLastError());
      return false;
    }

    if(Direction[j] == -1)
    {
      w[0] = 1.0 / w[0];
      w[1] = 1.0 / w[1];
    }

    w[1] *= Contracts[j];
    w[0] *= Contracts[j];
    
    v[j][0] = w[1];
    v[j][1] = w[0];
  }
  
  double sum[2] = {1.0, 1.0};
  
  for(int j = 0; j < SymbolCount; j++)
  {
    sum[0] += v[j][0];
    sum[1] += v[j][1];
  }
  
  const double base_0 = 1.0 / sum[0];
  const double base_1 = 1.0 / sum[1];

  if(AbsoluteValues)
  {
    result[0] = base_0 * Contracts[0];
  }
  else
  {
    result[0] = base_0 / base_1 - 1.0;
  }
  
  for(int j = 1; j <= SymbolCount; j++)
  {
    if(AbsoluteValues)
    {
      result[j] = base_0 * v[j - 1][0];
    }
    else
    {
      result[j] = base_0 * v[j - 1][0] / (base_1 * v[j - 1][1]) - 1.0;
    }
  }
  
  return true;
}

void OnTimer()
{
  const double price[] = {};
  
  if(LastBarCount != Bars(_Symbol, PERIOD_CURRENT))
  {
    int n = OnCalculate(Bars(_Symbol, PERIOD_CURRENT), 0, 0, price);
    if(n > 0)
    {
      EventKillTimer();
      ChartSetSymbolPeriod(0, _Symbol, PERIOD_CURRENT);
      ChartRedraw();
    }
  }
  else
  {
    EventKillTimer();
  }
}

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double& price[])
{
  if(!initDone) return 0;
  
  if(LastBarCount == rates_total && prev_calculated == rates_total && PriceType != PRICE_CLOSE)
  {
    return prev_calculated;
  }
  
  if(prev_calculated == 0)
  {
    for(int i = 0; i < rates_total; i++)
    {
      for(int j = 0; j < BUF_NUM; j++)
      {
        buffers[j][i] = EMPTY_VALUE;
      }
    }
  }
  
  int limit = MathMin(rates_total - prev_calculated + 1, BarLimit);

  double result[], result2[];
  ArrayResize(result, SymbolCount + 1);
  if(Momentum > 0)
  {
    ArrayResize(result2, SymbolCount + 1);
  }
  
  for(int i = 0; i < limit; i++)
  {
    if(!calculate(i, result))
    {
      return 0; // will retry on next tick
    }
    
    if(Momentum > 0)
    {
      if(!calculate(i + 1, result2))
      {
        return 0;
      }
      for(int j = 0; j <= SymbolCount; j++)
      {
        buffers[j][i] = (result[j] - result2[j]) * Momentum + result[j] * (1 - Momentum);
      }
    }
    else
    {
      for(int j = 0; j <= SymbolCount; j++)
      {
        buffers[j][i] = result[j];
      }
    }
    
    if(!AbsoluteValues)
    {
      buffers[BUF_NUM - 4][i] = 0;
      for(int j = 0; j <= SymbolCount; j++)
      {
        buffers[BUF_NUM - 4][i] += pow(getter[j][i], 2);
      }
      double sigma = sqrt(getter[BUF_NUM - 4][i] / SymbolCount); // corrected, unbiassed, because sum is made on SymbolCount + 1
      buffers[BUF_NUM - 4][i] = sigma * Sigma1;
      buffers[BUF_NUM - 3][i] = -sigma * Sigma1;
      buffers[BUF_NUM - 2][i] = sigma * Sigma2;
      buffers[BUF_NUM - 1][i] = -sigma * Sigma2;
    }
  }

  static bool fileSaved = SaveToFile == "";
  if(!fileSaved && !AbsoluteValues)
  {
    SaveBuffersToFile(SaveToFile);
    fileSaved = true;
  }
  
  LastBarCount = rates_total;
  
  return LastBarCount;
}

double GetBuffer(int index, int bar)
{
  return getter[index][bar];
}

bool SaveBuffersToFile(const string filename)
{
  int h = FileOpen(filename, FILE_WRITE | FILE_CSV | FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_ANSI, ';');
  if(h == INVALID_HANDLE) return false;
  
  string line = "datetime";
  for(int k = BarLookback - 1; k >= 0; k--)
  {
    for(int i = 0; i < workCurrencies.getSize(); i++)
    {
      line += ";" + workCurrencies.getKey(i) + (string)(k + 1);
    }
  }
  if(ShiftLastBuffer)
  {
    line += ";FORECAST";
  }
  FileWriteString(h, line + "\n");

  for(int i = BarLimit - BarLookback; i >= (ShiftedBuffer > -1 ? 1 : 0); i--)
  {
    datetime time = iTime(_Symbol, PERIOD_CURRENT, i);
    line = (string)time;
    for(int k = BarLookback - 1; k >= 0; k--)
    {
      for(int j = 0; j < workCurrencies.getSize(); j++)
      {
        line += ";" + (string)GetBuffer(j, i + k);
      }
    }
    if(ShiftLastBuffer)
    {
      line += ";" + (string)GetBuffer(ShiftedBuffer, i - 1); // look into the future for 1 bar
    }
    FileWriteString(h, line + "\n");
  }
  
  FileClose(h);

  Print("File saved ", filename);
  return true;
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
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=72847

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                    Developed by : Mario Jemic  |                                                                                      
//|                                                                         mario.jemic@gmail.com  |                                                                         
//|                                                        https://AppliedMachineLearning.systems  |                                                                      
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                              Paypal: https://goo.gl/9Rj74e     |
//|                                                            Patreon : https://goo.gl/GdXWeN     |  
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2023, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Green

extern int WindowSize = 500;
extern double Bandwidth = 8.0;
extern double Mult = 3.0;

double upper[];
double lower[];

int OnInit()
{
  SetIndexBuffer(0, upper);
  SetIndexBuffer(1, lower);
  SetIndexLabel(0, "Upper Band");
  SetIndexLabel(1, "Lower Band");
  return(INIT_SUCCEEDED);
}

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

  int k = 2;
  double y[];
  ArrayResize(y, WindowSize);
  double sum_e = 0.0;

  for(int i = 0; i < WindowSize; i++)
  {
    double sum = 0.0;
    double sumw = 0.0;
    for(int j = 0; j < WindowSize; j++)
    {
      double w = exp(-(pow(i-j, 2)/(Bandwidth * Bandwidth * 2.0)));
      sum += close[j] * w;
      sumw += w;
    }
    y[i] = sum/sumw;
    sum_e += fabs(close[i] - y[i]);
  }

  double mae = sum_e / WindowSize * Mult;

  for(i = 1; i < WindowSize; i++)
  {
    upper[i] = y[i-1] + mae;
    lower[i] = y[i-1] - mae;
  }

  upper[0] = y[0] + mae;
  lower[0] = y[0] - mae;
  return(rates_total);

}

//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
//+------------------------------------------------------------------------------------------------+
//|  Cryptocurrency  |  Network                    |  Address                                      |
//+------------------------------------------------+-----------------------------------------------+
//|  USDT            |  ERC20 (ETH Ethereum)       |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
//|  USDT            |  TRC20 (Tron)               |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
//|  USDT            |  BEP20 (BSC BNB Smart Chain)|  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  Matic Polygon              |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  SOL Solana                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
//|  USDT            |  ARBITRUM Arbitrum One      |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//+------------------------------------------------+-----------------------------------------------+
//+------------------------------------------------------------------+
//|                               Copyright © 2016, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                         Donate / Support:  http://goo.gl/cEP5h5  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                     BitCoin: 1MfUHS3h86MBTeonJzWdszdzF2iuKESCKU  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2016, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Gray
#property indicator_color2 Green
#property indicator_color3 Red

double Up[], Dn[], Ne[];
int UpFr, DnFr;

extern int EMA_Length=13;
extern int MACD_Period_Fast=12;
extern int MACD_Period_Slow=26;

double alpha;
double alpha1;
double SIGNAL[];
double MACD[];
int init()
{
 IndicatorShortName("Elder Impulse System");
 
 IndicatorBuffers(5);
 
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,Ne);
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,Up);
 SetIndexStyle(2,DRAW_HISTOGRAM);
 SetIndexBuffer(2,Dn);
 
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,SIGNAL); 
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,MACD);
 
 alpha = 2.0 / (9 + 1.0);
 alpha1 = 1.0 - alpha;
 
 UpFr=0; DnFr=0;

 return(0);
}

int deinit()
{

 return(0);
}

int start()
{
 if(Bars<=3) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 pos=limit;
 while(pos>=0)
 {
   
  
  Ne[pos]=1.;
  Up[pos]=0.;
  Dn[pos]=0.;
  
  
    double EMA0 = iMA(NULL,0,EMA_Length,0,1,0,pos);
	double EMA1 = iMA(NULL,0,EMA_Length,0,1,0,pos+1);
    double MACDF = iMA(NULL,0,MACD_Period_Fast,0,1,0,pos);
    double MACDS = iMA(NULL,0,MACD_Period_Slow,0,1,0,pos);
	
 
        double s1v1;
		double s1v2;
        s1v1 = EMA0;
        s1v2 = EMA1;

        MACD[pos] = MACDF - MACDS;
        if (pos == limit)
		{
            SIGNAL[pos] = MACD[pos];
		}	
        else
		{
            SIGNAL[pos] = alpha * MACD[pos] + alpha1 * SIGNAL[pos+1];
        }

        double s2v1;
		double s2v2;

        s2v1 = MACD[pos] - SIGNAL[pos];
        s2v2 = MACD[pos + 1] - SIGNAL[pos + 1]; 
		
		if (s1v1 > s1v2 && s2v1 > s2v2 )
		{
            Up[pos] = 1.;
            Ne[pos] = 0.;
		}	
        else
		{
            Up[pos] = 0.;
       }

        if (s1v1 < s1v2 && s2v1 < s2v2 )
		{
            Dn[pos] = 1.;
            Ne[pos] = 0.;
		}
        else
		{
            Dn[pos] = 0.;
        }

  pos--;
 } 
 return(0);
}


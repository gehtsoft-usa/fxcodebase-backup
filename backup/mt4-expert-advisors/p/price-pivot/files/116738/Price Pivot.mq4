// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=65505

//+------------------------------------------------------------------+
//|                               Copyright © 2018, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  | 
//|                                    Paypal: https://goo.gl/9Rj74e |
//+------------------------------------------------------------------+
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
//|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
//+------------------------------------------------------------------+


#property copyright "Copyright © 2018, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Yellow


enum Price_Types{ Close_Price=0, Open_Price=1, High_Price=2,Low_Price=3, Median_Price=4, Typical_Price=5, Weighted_Price=6 };
 
input  Price_Types Price = Median_Price;

  
double Pivot[];


int init()
  {
   IndicatorShortName("Running Median Indicator");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,Pivot);
  
   return(0);
  }

int deinit()
  {

   return(0);
  }

int start()
{

 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int pos;
 
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 pos=limit;
 while(pos>=0)
 {
  
  
   if (Price== 0)
   { Pivot[pos]=Close[pos];
   }
   if (Price== 1)
   { Pivot[pos]=Open[pos];
   }
   if (Price== 2)
   { Pivot[pos]=High[pos];
   }
   if (Price== 3)
   { Pivot[pos]=Low[pos];
   }
   
   if (Price== 4)
   { Pivot[pos]=(High[pos]+Low[pos])/2;
   }
   if (Price== 5)
   { Pivot[pos]=(High[pos]+Low[pos]+Close[pos])/3;
   }
   if (Price== 6)
   { Pivot[pos]=(High[pos]+Low[pos]+2*Close[pos])/4;
   }
 
  
  
  pos--;
 }

 return(0);
}


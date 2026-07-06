// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=61060


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
#property version "1.0"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red

extern int Length1=22;

extern int Normalization_Period=22;

extern int MA1_Method=0;  // 0 - SMA
                          // 1 - EMA
                          // 2 - SMMA
                          // 3 - LWMA
extern int Length2=22;
extern int MA2_Method=0;  // 0 - SMA
                          // 1 - EMA
                          // 2 - SMMA
                          // 3 - LWMA

double FVE[], Signal[];
double Intra[], Inter[], VE[], Vol[];
double FVE_Data[];
double Min_Value[];
double Max_Value[];
int init()
{
 IndicatorShortName("Finite Volume Elements");
 IndicatorDigits(Digits);
 
  IndicatorBuffers(9);
 
 

 
   SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,FVE);
 
  SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,Signal);
 
  SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,FVE_Data);
 
 
 
  SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,Min_Value);
 
   SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,Max_Value);
 

 

 
 SetIndexStyle(5,DRAW_NONE); 
 SetIndexBuffer(5,Intra);
 
 SetIndexStyle(6,DRAW_NONE);
 SetIndexBuffer(6,Inter);
 
 SetIndexStyle(7,DRAW_NONE);
 SetIndexBuffer(7,VE);
 
 SetIndexStyle(8,DRAW_NONE);
 SetIndexBuffer(8,Vol);
 

 return(0);
}

int deinit()
{

 return(0);
}


double maxValue(double &arrayToSearch[], int count, int start){  
 
   int indexMaxValueOfArray = ArrayMaximum(arrayToSearch, count, start);  
 
   return(arrayToSearch[indexMaxValueOfArray]); 
 
}

double minValue(double &arrayToSearch[], int count, int start){  
 
   int indexMinValueOfArray = ArrayMinimum(arrayToSearch, count, start);  
 
   return(arrayToSearch[indexMinValueOfArray]); 
 
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
  Intra[pos]=MathLog(High[pos])-MathLog(Low[pos]);
  Inter[pos]=MathLog((High[pos]+Low[pos]+Close[pos])/3.)-MathLog((High[pos+1]+Low[pos+1]+Close[pos+1])/3.);
  Vol[pos]=Volume[pos];

  pos--;
 } 
 
 double Vintra, Vinter, Cutoff, MF, MA1;
 pos=limit;
 while(pos>=0)
 {
  Vintra=iStdDevOnArray(Intra, 0, Length1, 0, MODE_SMA, pos);
  Vinter=iStdDevOnArray(Inter, 0, Length1, 0, MODE_SMA, pos);
  Cutoff=0.1*(Vintra+Vinter)*Close[pos];
  MF=Close[pos]-(High[pos]+Low[pos])/2.+High[pos]+Low[pos]+Close[pos]-High[pos+1]-Low[pos+1]-Close[pos+1];
  
  if (MF>Cutoff)
  {
   VE[pos]=Volume[pos];
  }
  else
  {
   if (MF<-Cutoff)
   {
    VE[pos]=-Volume[pos];
   }
   else
   {
    VE[pos]=0.;
   }
  }
  
  pos--;
 }




 
 double MA_VE;
 pos=limit;
 while(pos>=0)
 {
  MA_VE=iMAOnArray(VE, 0, Length1, 0, MODE_SMA, pos);
  MA1=iMAOnArray(Vol, 0, Length1, 0, MA1_Method, pos);
  if (MA1!=0.)
  {
   FVE_Data[pos]=100.*MA_VE/(MA1*Point);
  }
  else
  {
   FVE_Data[pos]=0.;
  } 
  
 

  pos--;
 }  
 
   pos=limit;
 while(pos>=0)
 {
    Max_Value[pos]=maxValue(FVE_Data, Normalization_Period,pos);
    Min_Value[pos]=minValue(FVE_Data, Normalization_Period,pos);
  

  pos--;
 }  
 
 
 
  pos=limit;
 while(pos>=0)
 {
 
   if (Max_Value[pos]!= Min_Value[pos] ) 
   {
   FVE[pos]=(FVE_Data[pos]-Min_Value[pos])/((Max_Value[pos]-Min_Value[pos])/100);
   }
   else
   {
   FVE[pos]=0;
   }
  

  pos--;
 }  
 
 
 
 
 pos=limit;
 while(pos>=0)
 {
  Signal[pos]=iMAOnArray(FVE, 0, Length2, 0, MA2_Method, pos);

  pos--;
 }  
   
 return(0);
}


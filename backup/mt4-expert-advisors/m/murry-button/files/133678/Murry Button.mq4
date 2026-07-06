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

#property copyright "TimeFrame.Modified"
#property link      "mailto:xard777@connectfree.co.uk"
#property indicator_chart_window
//+------------------------------------------------------------------+
//| Define the Variables to use.....                                 |
//+------------------------------------------------------------------+
extern int       beginer=64;
extern int       periodtotake=1400;
extern int       SomeVar=0;
input int button_x = 40;
input int button_y = 30;
bool show_data = true;

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

class VisibilityCotroller
{
   string buttonId;
   string visibilityId;
   bool show_data;
   bool recalc;
public:
   void Init(string id, string indicatorName, string caption, int x, int y)
   {
      recalc = false;
      visibilityId = indicatorName + "_visibility";
      double val;
      if (GlobalVariableGet(visibilityId, val))
         show_data = val != 0;
         
      buttonId = id;
      ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, 1);
      createButton(buttonId, caption, 65, 20, "Impact", 8, clrDarkRed, clrBlack, clrWhite);
      ObjectSetInteger(0, buttonId, OBJPROP_YDISTANCE, x);
      ObjectSetInteger(0, buttonId, OBJPROP_XDISTANCE, y);
   }

   void DeInit()
   {
      ObjectDelete(ChartID(), buttonId);
   }

   bool HandleButtonClicks()
   {
      if (ObjectGetInteger(0, buttonId, OBJPROP_STATE))
      {
         ObjectSetInteger(0, buttonId, OBJPROP_STATE, false);
         show_data = !show_data;
         GlobalVariableSet(visibilityId, show_data ? 1.0 : 0.0);
         recalc = true;
         return true;
      }
      return false;
   }

   bool IsRecalcNeeded()
   {
      return recalc;
   }

   void ResetRecalc()
   {
      recalc = false;
   }

   bool IsVisible()
   {
      return show_data;
   }

private:
   void createButton(string buttonID,string buttonText,int width,int height,string font,int fontSize,color bgColor,color borderColor,color txtColor)
   {
      ObjectDelete(0,buttonID);
      ObjectCreate(0,buttonID,OBJ_BUTTON,0,0,0);
      ObjectSetInteger(0,buttonID,OBJPROP_COLOR,txtColor);
      ObjectSetInteger(0,buttonID,OBJPROP_BGCOLOR,bgColor);
      ObjectSetInteger(0,buttonID,OBJPROP_BORDER_COLOR,borderColor);
      ObjectSetInteger(0,buttonID,OBJPROP_BORDER_TYPE,BORDER_RAISED);
      ObjectSetInteger(0,buttonID,OBJPROP_XDISTANCE,9999);
      ObjectSetInteger(0,buttonID,OBJPROP_YDISTANCE,9999);
      ObjectSetInteger(0,buttonID,OBJPROP_XSIZE,width);
      ObjectSetInteger(0,buttonID,OBJPROP_YSIZE,height);
      ObjectSetString(0,buttonID,OBJPROP_FONT,font);
      ObjectSetString(0,buttonID,OBJPROP_TEXT,buttonText);
      ObjectSetInteger(0,buttonID,OBJPROP_FONTSIZE,fontSize);
      ObjectSetInteger(0,buttonID,OBJPROP_SELECTABLE,0);
      ObjectSetInteger(0,buttonID,OBJPROP_CORNER,2);
      ObjectSetInteger(0,buttonID,OBJPROP_HIDDEN,1);
   }
};
VisibilityCotroller visibility;

int shift=0,i2=0,WorkTime=0,Periods=0;
double sum=0,v1=0,v2=0,fractal=0;
double v45=0,mml00=0,mml0=0,mml1=0,mml2=0,mml3=0,mml4=0,mml5=0,mml6=0,mml7=0,mml8=0,mml9=0,mml98=0,mml99=0;
double mm92=0,mm94=0,mm96=0,mm82=0,mm84=0,mm86=0,mm72=0,mm74=0,mm76=0,mm62=0,mm64=0,mm66=0,mm56=0,mm54=0,mm52=0,mm46=0,mm44=0,mm42=0,mm36=0,mm34=0,mm32=0,mm26=0,mm24=0,mm22=0,mm16=0,mm14=0,mm12s=0,mm06=0,mm04=0,mm02=0,mm106=0,mm104=0,mm102=0,mm1006=0,mm1004=0,mm1002=0;
double range=0,octave=0,mn=0,mx=0,price=0;
double finalH=0,finalL=0;
double x1=0,x2=0,x3=0,x4=0,x5=0,x6=0,y1=0,y2=0,y3=0,y4=0,y5=0,y6=0;
string textArray[13]={"MM-2/8ths_txt","MM-1/8th_txt","MM 0/8th_txt","MM 1/8th_txt","MM 2/8ths_txt","MM 3/8ths_txt","MM 4/8ths_txt","MM 5/8ths_txt","MM 6/8ths_txt","MM 7/8ths_txt","MM 8/8ths_txt","MM+1/8th_txt","MM+2/8ths_txt"};
string lineArray[49]={"MM-2/8ths","MM-1/8th","MM 0/8th","MM 1/8th","MM 2/8ths","MM 3/8ths","MM 4/8ths","mm92","mm94","mm96","mm82","mm84","mm86","mm72","mm74","mm76","mm62","mm64","mm66","mm56","mm54","mm52","mm46","mm44","mm42","mm36","mm34","mm32","mm26","mm24","mm22","mm16","mm14","mm12s","mm06","mm04","mm02","mm106","mm104","mm102","mm1006","mm1004","mm1002","MM 5/8ths","MM 6/8ths","MM 7/8ths","MM 8/8ths","MM+1/8th","MM+2/8ths"};
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
  IndicatorName = GenerateIndicatorName("Murry");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   IndicatorDigits(Digits);
   visibility.Init("show_hide", IndicatorName, "Show/Hide", button_x, button_y);
   return 0;
};
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
   
  {
   visibility.DeInit();
//---- TODO: add your code here
   ObjectsDeleteAll(0, OBJ_HLINE); 
   int count=ArraySize(textArray);
   for(int ch=0;ch<count;ch++) {
      ObjectDelete(textArray[ch]);
      ObjectDelete(lineArray[ch]);
      ObjectsDeleteAll(ChartID());
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
   }
   //ObjectsDeleteAll(0, OBJ_TEXT); 
//----
   return(0);
  }
  
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   if (visibility.HandleButtonClicks())
   {
      start();
   }
}


int start()
{
   visibility.HandleButtonClicks();
   visibility.ResetRecalc();
   
   if (visibility.IsVisible())
   {
      if( (WorkTime != Time[0]) || (Periods != Period()) ) 
      {
         //price
         v1=(Low[Lowest(NULL,0,MODE_LOW,periodtotake+SomeVar,beginer)]);
         v2=(High[Highest(NULL,0,MODE_HIGH,periodtotake+SomeVar,beginer)]);
         //+------------------------------------------------------------------+
         //| Determine which Fractal to use.....                              |
         //+------------------------------------------------------------------+
         if(v2<=250000 && v2>25000) fractal = 100000;
         if(v2<=25000 && v2>2500) fractal = 10000;
         if(v2<=2500 && v2>250) fractal = 1000;
         if(v2<=250 && v2>25) fractal = 100;
         if(v2<=25 && v2>12.5) fractal = 12.5;
         if(v2<=12.5 && v2>6.25) fractal = 12.5;
         if(v2<=6.25 && v2>3.125) fractal = 6.25;
         if(v2<=3.125 && v2>1.5625) fractal = 3.125;
         if(v2<=1.5625 && v2>0.390625) fractal = 1.5625;
         if(v2<=0.390625 && v2>0) fractal = 0.1953125;
         // calculating our octave....      
         range=(v2-v1); sum=MathFloor(MathLog(fractal/range)/MathLog(2));
         octave=fractal*(MathPow(0.5,sum)); mn=MathFloor(v1/octave)*octave;
         if((mn+octave)>v2)mx=mn+octave; mx=mn+(2*octave);
         // calculating xx
         //x2
         if((v1>=(3*(mx-mn)/16+mn))&& (v2<=(9*(mx-mn)/16+mn))) x2=mn+(mx-mn)/2; else x2=0;
         //x1
         if((v1>=(mn-(mx-mn)/8))&& (v2<=(5*(mx-mn)/8+mn)) && (x2==0)) x1=mn+(mx-mn)/2; else x1=0;
         //x4
         if((v1>=(mn+7*(mx-mn)/16))&& (v2<=(13*(mx-mn)/16+mn))) x4=mn+3*(mx-mn)/4; else x4=0;
         //x5
         if((v1>=(mn+3*(mx-mn)/8))&& (v2<=(9*(mx-mn)/8+mn))&& (x4==0)) x5=mx; else x5=0;
         //x3
         if((v1>=(mn+(mx-mn)/8))&& (v2<=(7*(mx-mn)/8+mn))&& (x1==0) && (x2==0) && (x4==0) && (x5==0)) x3=mn+3*(mx-mn)/4; else x3=0;
         //x6 when we have no sbj, du {}
         if((x1+x2+x3+x4+x5)==0) x6=mx; else x6=0;

         finalH=x1+x2+x3+x4+x5+x6;
         // calculating yy
         //y1
         if(x1>0) y1=mn; else y1=0;
         //y2
         if(x2>0) y2=mn+(mx-mn)/4; else y2=0;
         //y3
         if(x3>0) y3=mn+(mx-mn)/4; else y3=0;
         //y4
         if(x4>0) y4=mn+(mx-mn)/2; else y4=0;
         //y5
         if(x5>0) y5=mn+(mx-mn)/2; else y5=0;
         //y6
         if((finalH>0) && ((y1+y2+y3+y4+y5)==0)) y6=mn; else y6=0;

         finalL=y1+y2+y3+y4+y5+y6;

         v45=(finalH-finalL)/8;

         if (show_data)
         {
            mml00=(finalL-v45*2); mml0=(finalL-v45); mml1=(finalL); mml2=(finalL+v45); mml3=(finalL+2*v45);
            mml4=(finalL+3*v45); mml5=(finalL+4*v45); mml6=(finalL+5*v45); mml7=(finalL+6*v45); mml8=(finalL+7*v45);
            mml9=(finalL+8*v45); mml99=(finalL+9*v45); mml98=(finalL+10*v45); 
         }
         else
         {
            mml00 = EMPTY_VALUE;
            mml0 = EMPTY_VALUE;
            mml1 = EMPTY_VALUE;
            mml2 = EMPTY_VALUE;
            mml3 = EMPTY_VALUE;
            mml4 = EMPTY_VALUE;
            mml5 = EMPTY_VALUE;
            mml6 = EMPTY_VALUE;
            mml7 = EMPTY_VALUE;
            mml8 = EMPTY_VALUE;
            mml9 = EMPTY_VALUE;
            mml99 = EMPTY_VALUE;
            mml98 = EMPTY_VALUE;
         }
         Comment("\n","");

         ObjectCreate("MM-2/8ths_txt",OBJ_TEXT,0,Time[12],mml00,Time[0],mml00);
         ObjectSetText("MM-2/8ths_txt","",10,"Arial",Indigo);
         
         ObjectCreate("MM-1/8th_txt",OBJ_TEXT,0,Time[12],mml0,Time[0],mml0);
         ObjectSetText("MM-1/8th_txt","",10,"Arial",Indigo);
         
         ObjectCreate("MM 0/8th_txt",OBJ_TEXT,0,Time[12],mml1,Time[0],mml1);
         ObjectSetText("MM 0/8th_txt","",10,"Arial",Indigo);
         
         ObjectCreate("MM 1/8th_txt",OBJ_TEXT,0,Time[12],mml2,Time[0],mml2);
         ObjectSetText("MM 1/8th_txt","",10,"Arial",Indigo);

         ObjectCreate("MM 2/8ths_txt",OBJ_TEXT,0,Time[12],mml3,Time[0],mml3);
         ObjectSetText("MM 2/8ths_txt","",10,"Arial",Indigo);

         ObjectCreate("MM 3/8ths_txt",OBJ_TEXT,0,Time[12],mml4,Time[0],mml4);
         ObjectSetText("MM 3/8ths_txt","",10,"Arial",Indigo);	
         
         ObjectCreate("MM 4/8ths_txt",OBJ_TEXT,0,Time[12],mml5,Time[0],mml5);
         ObjectSetText("MM 4/8ths_txt","",10,"Arial",Indigo);
         
         ObjectCreate("MM 5/8ths_txt",OBJ_TEXT,0,Time[12],mml6,Time[0],mml6);
         ObjectSetText("MM 5/8ths_txt","",10,"Arial",Indigo);
         
         ObjectCreate("MM 6/8ths_txt",OBJ_TEXT,0,Time[12],mml7,Time[0],mml7);
         ObjectSetText("MM 6/8ths_txt","",10,"Arial",Indigo);
         
         ObjectCreate("MM 7/8ths_txt",OBJ_TEXT,0,Time[12],mml8,Time[0],mml8);
         ObjectSetText("MM 7/8ths_txt","",10,"Arial",Indigo);
         
         ObjectCreate("MM 8/8ths_txt",OBJ_TEXT,0,Time[12],mml9,Time[0],mml9);
         ObjectSetText("MM 8/8ths_txt","",10,"Arial",Indigo);
         
         ObjectCreate("MM+1/8th_txt",OBJ_TEXT,0,Time[12],mml99,Time[0],mml99);
         ObjectSetText("MM+1/8th_txt","",Indigo);
         
         ObjectCreate("MM+2/8ths_txt",OBJ_TEXT,0,Time[12],mml98,Time[0],mml98);
         ObjectSetText("MM+2/8ths_txt","",10,"Arial",Indigo);

         ObjectCreate("MM-2/8ths",OBJ_HLINE,0,Time[0],mml00,Time[0],mml00);
         ObjectSet("MM-2/8ths",OBJPROP_COLOR,Indigo);ObjectSet("MM-2/8ths",OBJPROP_WIDTH,1);ObjectSet("MM-2/8ths",OBJPROP_STYLE,STYLE_SOLID);
         // -2/8
         ObjectCreate("MM-1/8th" ,OBJ_HLINE,0,Time[0],mml0,Time[0],mml0); 
         ObjectSet("MM-1/8th",OBJPROP_COLOR,Indigo);ObjectSet("MM-1/8th",OBJPROP_WIDTH,1);ObjectSet("MM-1/8th",OBJPROP_STYLE,STYLE_SOLID);
         // -1/8
         ObjectCreate("MM 0/8th" ,OBJ_HLINE,0,Time[0],mml1,Time[0],mml1);
         ObjectSet("MM 0/8th",OBJPROP_COLOR,Indigo);ObjectSet("MM 0/8th",OBJPROP_WIDTH,1);ObjectSet("MM 0/8th",OBJPROP_STYLE, STYLE_SOLID);
         // 0/8
         ObjectCreate("MM 1/8th" ,OBJ_HLINE,0,Time[0],mml2,Time[0],mml2); 
         ObjectSet("MM 1/8th",OBJPROP_COLOR,Indigo);ObjectSet("MM 1/8th",OBJPROP_WIDTH,1);ObjectSet("MM 1/8th",OBJPROP_STYLE, STYLE_SOLID);
         // 1/8
         ObjectCreate("MM 2/8ths" ,OBJ_HLINE,0,Time[0],mml3,Time[0],mml3); 
         ObjectSet("MM 2/8ths",OBJPROP_COLOR,Indigo);ObjectSet("MM 2/8ths",OBJPROP_WIDTH,1);ObjectSet("MM 2/8ths",OBJPROP_STYLE, STYLE_SOLID);
         // 2/8
         ObjectCreate("MM 3/8ths" ,OBJ_HLINE,0,Time[0],mml4,Time[0],mml4); 
         ObjectSet("MM 3/8ths",OBJPROP_COLOR,Indigo);ObjectSet("MM 3/8ths",OBJPROP_WIDTH,1);ObjectSet("MM 3/8ths",OBJPROP_STYLE, STYLE_SOLID);
         // 3/8
         ObjectCreate("MM 4/8ths" ,OBJ_HLINE,0,Time[0],mml5,Time[0],mml5); 
         ObjectSet("MM 4/8ths",OBJPROP_COLOR,Indigo);ObjectSet("MM 4/8ths",OBJPROP_WIDTH,1);ObjectSet("MM 4/8ths",OBJPROP_STYLE, STYLE_SOLID);
         // 4/8
         ObjectCreate("MM 5/8ths" ,OBJ_HLINE,0,Time[0],mml6,Time[0],mml6); 
         ObjectSet("MM 5/8ths",OBJPROP_COLOR,Indigo);ObjectSet("MM 5/8ths",OBJPROP_WIDTH,1);ObjectSet("MM 5/8ths",OBJPROP_STYLE, STYLE_SOLID);
         // 5/8
         ObjectCreate("MM 6/8ths" ,OBJ_HLINE,0,Time[0],mml7,Time[0],mml7);
         ObjectSet("MM 6/8ths",OBJPROP_COLOR,Indigo);ObjectSet("MM 6/8ths",OBJPROP_WIDTH,1);ObjectSet("MM 6/8ths",OBJPROP_STYLE, STYLE_SOLID);
         // 6/8
         ObjectCreate("MM 7/8ths" ,OBJ_HLINE,0,Time[0],mml8,Time[0],mml8); 
         ObjectSet("MM 7/8ths",OBJPROP_COLOR,Indigo);ObjectSet("MM 7/8ths",OBJPROP_WIDTH,1);ObjectSet("MM 7/8ths",OBJPROP_STYLE, STYLE_SOLID);
         // 7/8
         ObjectCreate("MM 8/8ths" ,OBJ_HLINE,0,Time[0],mml9,Time[0],mml9); 
         ObjectSet("MM 8/8ths",OBJPROP_COLOR,Indigo);ObjectSet("MM 8/8ths",OBJPROP_WIDTH,1);ObjectSet("MM 8/8ths",OBJPROP_STYLE, STYLE_SOLID);
         // 0/8
         ObjectCreate("MM+1/8th" ,OBJ_HLINE,0,Time[0],mml99,Time[0],mml99);
         ObjectSet("MM+1/8th",OBJPROP_COLOR,Indigo);ObjectSet("MM+1/8th",OBJPROP_WIDTH,1);ObjectSet("MM+1/8th",OBJPROP_STYLE, STYLE_SOLID);
         // +2/8
         ObjectCreate("MM+2/8ths" ,OBJ_HLINE,0,Time[0],mml98,Time[0],mml98);
         ObjectSet("MM+2/8ths",OBJPROP_COLOR,Indigo);ObjectSet("MM+2/8ths",OBJPROP_WIDTH,1);ObjectSet("MM+2/8ths",OBJPROP_STYLE, STYLE_SOLID);
         // +1/8
      }
      WorkTime    = Time[0];
      Periods= Period();
   }
   else
   {
      WorkTime = 0;
      Comment("\n","");
      ObjectDelete("MM-2/8ths_txt");
      ObjectDelete("MM-1/8th_txt");
      ObjectDelete("MM 0/8th_txt");
      ObjectDelete("MM 1/8th_txt");
      ObjectDelete("MM 2/8ths_txt");
      ObjectDelete("MM 3/8ths_txt");
      ObjectDelete("MM 4/8ths_txt");
      ObjectDelete("MM 5/8ths_txt");
      ObjectDelete("MM 6/8ths_txt");
      ObjectDelete("MM 7/8ths_txt");
      ObjectDelete("MM 8/8ths_txt");
      ObjectDelete("MM+1/8th_txt");
      ObjectDelete("MM+2/8ths_txt");
      ObjectDelete("MM-2/8ths");
      ObjectDelete("MM-1/8th");
      ObjectDelete("MM 0/8th");
      ObjectDelete("MM 1/8th");
      ObjectDelete("MM 2/8ths");
      ObjectDelete("MM 3/8ths");
      ObjectDelete("MM 4/8ths");
      ObjectDelete("MM 5/8ths");
      ObjectDelete("MM 6/8ths");
      ObjectDelete("MM 7/8ths");
      ObjectDelete("MM 8/8ths");
      ObjectDelete("MM+1/8th");
      ObjectDelete("MM+2/8ths");
   }
   
   return(0);
}


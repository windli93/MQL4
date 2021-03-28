//+----------------------------------------------------------------+
//|                                             Fractal Levels.mq4 |
//|                                                         Maximo |
//+----------------------------------------------------------------+
#property copyright "Copyright © 2013"
#property link      "Maximo"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Gray
#property indicator_color2 Gray
#property indicator_width1 1
#property indicator_width2 1
double UpperFr[];
double LowerFr[];

extern double MidFractalDist = 6;
extern double OppFractalDist = 11;
extern color  Line1col = Green;
extern color  Line2col = Red;
extern color  Line3col = DarkGreen;
extern color  Line4col = DarkOrange;
double        PointValue;
int           refreshtime;

int init()
{
   if (Digits <= 3) PointValue = 0.01; else PointValue = 0.0001;
   SetIndexBuffer(0, UpperFr);
   SetIndexBuffer(1, LowerFr);
   SetIndexEmptyValue(0, 0);
   SetIndexEmptyValue(1, 0);
   SetIndexStyle(0, DRAW_ARROW);
   SetIndexArrow(0, 217);
   SetIndexStyle(1, DRAW_ARROW);
   SetIndexArrow(1, 218);
   return(0);
}

int deinit()
{
   for (int i = 1; i <= 4; i++) ObjectDelete("Line" + i);
   Comment("");
   return(0);
}

int start()
{
   int counted=IndicatorCounted();
   if (counted < 0) return(-1);
   if (counted > 0) counted--;
   int limit=Bars-counted;

   if (refreshtime != iTime(Symbol(),PERIOD_M15,0))
   {
      refreshtime = iTime(Symbol(),PERIOD_M15,0);
      for (int i = 1; i <= 4; i++) ObjectDelete("Line" + i);
   }
   else return(0);   

   double dy;
   for(i=1; i<=20; i++)
   {
      dy+=0.2*(High[i]-Low[i])/20;
      UpperFr[i]=0; LowerFr[i]=0;
   }
   for(int a=1; a<Bars; a++)
   {
      if(iFractals(NULL, 0, MODE_UPPER,a)!=0)
      {
         double LastUpFractal=iFractals(NULL, 0, MODE_UPPER,a);
         datetime FracUpTime =iTime(Symbol(),PERIOD_M15,a);
         UpperFr[a]=High[a] + dy;
         break;
      }
   }
   for(int s=1; s<Bars; s++)
   {
      if(iFractals(NULL, 0, MODE_LOWER,s)!=0)
      {
         double LastDownFractal=iFractals(NULL, 0, MODE_LOWER,s);
         datetime FracDownTime =iTime(Symbol(),PERIOD_M15,s);
         LowerFr[s]=Low[s] - dy;
         break;
      }
   }
   datetime FracTime;
   if (FracUpTime < FracDownTime) FracTime = FracUpTime;
   else FracTime = FracDownTime;
   
   double midFractal=NormalizeDouble((LastUpFractal+LastDownFractal)/2,Digits);
   double price1 = LastUpFractal-OppFractalDist*PointValue;
   double price2 = LastDownFractal+OppFractalDist*PointValue;
   double price3 = midFractal-MidFractalDist*PointValue;
   double price4 = midFractal+MidFractalDist*PointValue;
   
   ObjectCreate("Line1", OBJ_TREND, 0, FracTime, price1, TimeCurrent(), price1);
   ObjectSet("Line1",OBJPROP_COLOR,Line1col);
   ObjectSet("Line1",OBJPROP_BACK,True);
   ObjectCreate("Line2", OBJ_TREND, 0, FracTime, price2, TimeCurrent(), price2);
   ObjectSet("Line2",OBJPROP_COLOR,Line2col);
   ObjectSet("Line2",OBJPROP_BACK,True);
   ObjectCreate("Line3", OBJ_TREND, 0, FracTime, price3, TimeCurrent(), price3);
   ObjectSet("Line3",OBJPROP_COLOR,Line3col);
   ObjectSet("Line3",OBJPROP_BACK,True);
   ObjectCreate("Line4", OBJ_TREND, 0, FracTime, price4, TimeCurrent(), price4);
   ObjectSet("Line4",OBJPROP_COLOR,Line4col);
   ObjectSet("Line4",OBJPROP_BACK,True);

   return(0);
}


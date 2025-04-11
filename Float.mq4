//+------------------------------------------------------------+
//| Float.mq4                                                  |
//| Copyright © 2005  Barry Stander  Barry_Stander_4@yahoo.com |
//| http://www.4Africa.net/4meta/                              |
//| Float                                                      |
//| Copyright © 2025       Andriy Moraru  www.EarnForex.com    |
//| https://www.earnforex.com/                                 |
//+------------------------------------------------------------+
#property copyright "Copyright © 2025, EarnForex"
#property link      "https://www.earnforex.com/metatrader-indicators/Float/"
#property version   "1.03"
#property strict

#property description "Float - Trend strength, volume, Fibonacci, and Dinapoli levels."

#property indicator_separate_window
#property indicator_buffers 31 //2
#property indicator_color1 clrBlue
#property indicator_width1 1
#property indicator_label1 "Float Histogram"
#property indicator_color2 clrRed
#property indicator_width2 1
#property indicator_style2 STYLE_SOLID
#property indicator_label2 "Float Line"
// These are to be read via iCustom() at position 0:
#property indicator_type3  DRAW_NONE // Swing Top (price)
#property indicator_type4  DRAW_NONE // Swing Bottom (price)
#property indicator_type5  DRAW_NONE // High Distance (bars)
#property indicator_type6  DRAW_NONE // Low Distance (bars)
#property indicator_type7  DRAW_NONE // Swing Time (bars)
#property indicator_type8  DRAW_NONE // Float Volume (volume)
#property indicator_type9  DRAW_NONE // Float Left (volume)
#property indicator_type10 DRAW_NONE // Fibo23 (price)
#property indicator_type11 DRAW_NONE // Fibo38 (price)
#property indicator_type12 DRAW_NONE // Fibo50 (price)
#property indicator_type13 DRAW_NONE // Fibo62 (price)
#property indicator_type14 DRAW_NONE // Fibo76 (price)
#property indicator_type15 DRAW_NONE // Dinap0 (price)
#property indicator_type16 DRAW_NONE // Dinap1 (price)
#property indicator_type17 DRAW_NONE // Dinap2 (price)
#property indicator_type18 DRAW_NONE // Dinap3 (price)
#property indicator_type19 DRAW_NONE // Dinap4 (price)
#property indicator_type20 DRAW_NONE // Dinap5 (price)
#property indicator_type21 DRAW_NONE // CVSTART (datetime)
#property indicator_type22 DRAW_NONE // CVEND (datetime)
#property indicator_type23 DRAW_NONE // SwingEnd1 (datetime)
#property indicator_type24 DRAW_NONE // SwingEnd2 (datetime)
#property indicator_type25 DRAW_NONE // SwingEnd3 (datetime)
#property indicator_type26 DRAW_NONE // SwingEnd4 (datetime)
#property indicator_type27 DRAW_NONE // SwingEnd5 (datetime)
#property indicator_type28 DRAW_NONE // SwingEnd6 (datetime)
#property indicator_type29 DRAW_NONE // SwingEnd7 (datetime)
#property indicator_type30 DRAW_NONE // SwingEnd8 (datetime)
#property indicator_type31 DRAW_NONE // SwingEnd9 (datetime)

input int             Float = 200;
input string          ObjectPrefix = "FI-";
input bool            DisableDinapoli = false;
input bool            DisableFibonacci = false;
input bool            DrawVerticalLinesAsBackground = false;
input color           SwingBorderColor = clrBlue;
input int             SwingBorderWidth = 1;
input ENUM_LINE_STYLE SwingBorderStyle = STYLE_SOLID;
input color           SwingLinesColor = clrRed;
input int             SwingLinesWidth = 1;
input ENUM_LINE_STYLE SwingLinesStyle = STYLE_DOT;
input color           FiboColor = clrGreen;
input int             FiboWidth = 1;
input ENUM_LINE_STYLE FiboStyle = STYLE_DASH;
input color           DinapoliColor = clrRed;
input int             DinapoliWidth = 1;
input ENUM_LINE_STYLE DinapoliStyle = STYLE_DOT;

datetime PrevTime;
double Histogram[];
double Line[];

double bufSwingTop[], bufSwingBottom[];
double bufHighDistance[], bufLowDistance[], bufSwingTime[], bufFloatVolume[], bufFloatLeft[]; // int actually.

double bufFibo23[], bufFibo38[], bufFibo50[], bufFibo62[], bufFibo76[];
double bufDinap0[], bufDinap1[], bufDinap2[], bufDinap3[], bufDinap4[], bufDinap5[];

double bufCVSTART[], bufCVEND[], bufSwingEnd1[], bufSwingEnd2[], bufSwingEnd3[], bufSwingEnd4[], bufSwingEnd5[], bufSwingEnd6[], bufSwingEnd7[], bufSwingEnd8[], bufSwingEnd9[]; // datetime actually.

void OnInit()
{
    IndicatorShortName("Float");

    SetIndexStyle(0, DRAW_HISTOGRAM);
    SetIndexBuffer(0, Histogram);
    SetIndexDrawBegin(0, Float * 2);

    SetIndexStyle(1, DRAW_LINE);
    SetIndexBuffer(1, Line);
    SetIndexDrawBegin(1, Float * 2);

    SetIndexBuffer(2, bufSwingTop);
    SetIndexBuffer(3, bufSwingBottom);
    SetIndexBuffer(4, bufHighDistance);
    SetIndexBuffer(5, bufLowDistance);
    SetIndexBuffer(6, bufSwingTime);
    SetIndexBuffer(7, bufFloatVolume);
    SetIndexBuffer(8, bufFloatLeft);
    SetIndexBuffer(9, bufFibo23);
    SetIndexBuffer(10, bufFibo38);
    SetIndexBuffer(11, bufFibo50);
    SetIndexBuffer(12, bufFibo62);
    SetIndexBuffer(13, bufFibo76);
    SetIndexBuffer(14, bufDinap0);
    SetIndexBuffer(15, bufDinap1);
    SetIndexBuffer(16, bufDinap2);
    SetIndexBuffer(17, bufDinap3);
    SetIndexBuffer(18, bufDinap4);
    SetIndexBuffer(19, bufDinap5);
    SetIndexBuffer(20, bufCVSTART);
    SetIndexBuffer(21, bufCVEND);
    SetIndexBuffer(22, bufSwingEnd1);
    SetIndexBuffer(23, bufSwingEnd2);
    SetIndexBuffer(24, bufSwingEnd3);
    SetIndexBuffer(25, bufSwingEnd4);
    SetIndexBuffer(26, bufSwingEnd5);
    SetIndexBuffer(27, bufSwingEnd6);
    SetIndexBuffer(28, bufSwingEnd7);
    SetIndexBuffer(29, bufSwingEnd8);
    SetIndexBuffer(30, bufSwingEnd9);
}

void OnDeinit(const int reason)
{
    ObjectsDeleteAll(ChartID(), ObjectPrefix);
    Comment("");
}

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time_timeseries[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[]
               )
{
    if (Time[0] == PrevTime) return rates_total; // Recalculate only on new bars.
    PrevTime = Time[0];
    
    bool first = true;
    long cumulativeV = 0;
    double FLOATV = 0, high_bar = 0, low_bar = 0;
    int bars_high = 0, bars_low = 0, shift, swing_time = 0, cvstart = 0, cvend = 0;

    // Find bar counts.
    bars_high = iHighest(NULL, 0, MODE_HIGH, Float, 1);
    bars_low  = iLowest(NULL, 0, MODE_LOW, Float, 1);

    // Find the high and low values over the period.
    high_bar = High[bars_high];
    low_bar  =  Low[bars_low];

    // Find cumulative volume for float period.
    if (bars_high < bars_low) // Uptrend.
    {
        cvstart = bars_low;
        cvend = bars_high;
    }
    else // Downtrend.
    {
        cvstart = bars_high;
        cvend = bars_low;
    }

    if ((first) && (FLOATV == 0))
    {
        for (shift = cvstart; shift >= cvend; shift--)
        {
            FLOATV = FLOATV + Volume[shift];
            first = false;
        }
    }

    // Find float time barcount.
    swing_time = MathAbs(bars_low - bars_high);

    // Find cumulative volume since last turnover.
    for (shift = cvstart; shift >= 0; shift--)
    {
        cumulativeV += Volume[shift];

        if (cumulativeV >= FLOATV) cumulativeV = 0;

        Histogram[shift] = cumulativeV * 0.001; // Blue histogram.
        Line[shift] = FLOATV * 0.001; // Red line.
    }

    bufSwingTop[0] = high_bar;
    bufSwingBottom[0] = low_bar;

    Comment(
        "\n", "High was   ", bars_high, "  bars ago",
        "\n", "Low was    ", bars_low, " bars ago", "\n",
        "\n", "Float time was    = ", swing_time, " bars",
        "\n", "Float volume left = ", FLOATV - cumulativeV,
        "\n", "Float volume      = ", FLOATV);

    bufHighDistance[0] = bars_high;
    bufLowDistance[0] = bars_low;
    bufSwingTime[0] = swing_time;
    bufFloatVolume[0] = FLOATV - cumulativeV;
    bufFloatLeft[0] = FLOATV;

    ObjectDelete(ObjectPrefix + "Swingtop");
    ObjectCreate(ObjectPrefix + "Swingtop", OBJ_TREND, 0, Time[cvstart], high_bar, Time[1], high_bar);
    ObjectSet(ObjectPrefix + "Swingtop", OBJPROP_STYLE, SwingBorderStyle);
    ObjectSet(ObjectPrefix + "Swingtop", OBJPROP_COLOR, SwingBorderColor);
    ObjectSet(ObjectPrefix + "Swingtop", OBJPROP_RAY, 0);
    ObjectSet(ObjectPrefix + "Swingtop", OBJPROP_WIDTH, SwingBorderWidth);

    ObjectDelete(ObjectPrefix + "Swingbottom");
    ObjectCreate(ObjectPrefix + "Swingbottom", OBJ_TREND, 0, Time[cvstart], low_bar, Time[1], low_bar);
    ObjectSet(ObjectPrefix + "Swingbottom", OBJPROP_STYLE, SwingBorderStyle);
    ObjectSet(ObjectPrefix + "Swingbottom", OBJPROP_COLOR, SwingBorderColor);
    ObjectSet(ObjectPrefix + "Swingbottom", OBJPROP_RAY, 0);
    ObjectSet(ObjectPrefix + "Swingbottom", OBJPROP_WIDTH, SwingBorderWidth);

    if ((!DisableDinapoli) || (!DisableFibonacci))
    {
        // Fibonacci.
        ObjectDelete(ObjectPrefix + "Fib23");
        ObjectDelete(ObjectPrefix + "Fib38");
        ObjectDelete(ObjectPrefix + "Fib50");
        ObjectDelete(ObjectPrefix + "Fib62");
        ObjectDelete(ObjectPrefix + "Fib76");
        ObjectDelete(ObjectPrefix + "Fib23t");
        ObjectDelete(ObjectPrefix + "Fib38t");
        ObjectDelete(ObjectPrefix + "Fib50t");
        ObjectDelete(ObjectPrefix + "Fib62t");
        ObjectDelete(ObjectPrefix + "Fib76t");

        ObjectDelete(ObjectPrefix + "Dinap0");
        ObjectDelete(ObjectPrefix + "Dinap1");
        ObjectDelete(ObjectPrefix + "Dinap2");
        ObjectDelete(ObjectPrefix + "Dinap3");
        ObjectDelete(ObjectPrefix + "Dinap4");
        ObjectDelete(ObjectPrefix + "Dinap5");

        double Fib23 = ((high_bar - low_bar) * 0.236) + low_bar;
        double Fib38 = ((high_bar - low_bar) * 0.382) + low_bar;
        double Fib50 = ((high_bar - low_bar) / 2)     + low_bar;
        double Fib62 = ((high_bar - low_bar) * 0.618) + low_bar;
        double Fib76 = ((high_bar - low_bar) * 0.764) + low_bar;
        bufFibo23[0] = Fib23;
        bufFibo38[0] = Fib38;
        bufFibo50[0] = Fib50;
        bufFibo62[0] = Fib62;
        bufFibo76[0] = Fib76;

        if (!DisableFibonacci)
        {
            ObjectCreate(ObjectPrefix + "Fib23", OBJ_TREND, 0, Time[cvstart], Fib23, Time[1], Fib23);
            ObjectSet(ObjectPrefix + "Fib23", OBJPROP_STYLE, FiboStyle);
            ObjectSet(ObjectPrefix + "Fib23", OBJPROP_COLOR, FiboColor);
            ObjectSet(ObjectPrefix + "Fib23", OBJPROP_RAY, 0);
            ObjectSet(ObjectPrefix + "Fib23", OBJPROP_WIDTH, FiboWidth);
            ObjectCreate(ObjectPrefix + "Fib23t", OBJ_TEXT, 0, Time[1], Fib23);
            ObjectSetText(ObjectPrefix + "Fib23t", "23.6", 8, "Arial", FiboColor);

            ObjectCreate(ObjectPrefix + "Fib38", OBJ_TREND, 0, Time[cvstart], Fib38, Time[1], Fib38);
            ObjectSet(ObjectPrefix + "Fib38", OBJPROP_STYLE, FiboStyle);
            ObjectSet(ObjectPrefix + "Fib38", OBJPROP_COLOR, FiboColor);
            ObjectSet(ObjectPrefix + "Fib38", OBJPROP_RAY, 0);
            ObjectSet(ObjectPrefix + "Fib38", OBJPROP_WIDTH, FiboWidth);
            ObjectCreate(ObjectPrefix + "Fib38t", OBJ_TEXT, 0, Time[1], Fib38);
            ObjectSetText(ObjectPrefix + "Fib38t", "38.2", 8, "Arial", FiboColor);

            ObjectCreate(ObjectPrefix + "Fib50", OBJ_TREND, 0, Time[cvstart], Fib50, Time[1], Fib50);
            ObjectSet(ObjectPrefix + "Fib50", OBJPROP_STYLE, STYLE_SOLID);
            ObjectSet(ObjectPrefix + "Fib50", OBJPROP_COLOR, FiboColor);
            ObjectSet(ObjectPrefix + "Fib50", OBJPROP_RAY, 0);
            ObjectSet(ObjectPrefix + "Fib50", OBJPROP_WIDTH, FiboWidth + 1);
            ObjectCreate(ObjectPrefix + "Fib50t", OBJ_TEXT, 0, Time[1], Fib50);
            ObjectSetText(ObjectPrefix + "Fib50t", "50", 8, "Arial", FiboColor);

            ObjectCreate(ObjectPrefix + "Fib62", OBJ_TREND, 0, Time[cvstart], Fib62, Time[1], Fib62);
            ObjectSet(ObjectPrefix + "Fib62", OBJPROP_STYLE, FiboStyle);
            ObjectSet(ObjectPrefix + "Fib62", OBJPROP_COLOR, FiboColor);
            ObjectSet(ObjectPrefix + "Fib62", OBJPROP_RAY, 0);
            ObjectSet(ObjectPrefix + "Fib62", OBJPROP_WIDTH, FiboWidth);
            ObjectCreate(ObjectPrefix + "Fib62t", OBJ_TEXT, 0, Time[1], Fib62);
            ObjectSetText(ObjectPrefix + "Fib62t", "61.8", 8, "Arial", FiboColor);

            ObjectCreate(ObjectPrefix + "Fib76", OBJ_TREND, 0, Time[cvstart], Fib76, Time[1], Fib76);
            ObjectSet(ObjectPrefix + "Fib76", OBJPROP_STYLE, FiboStyle);
            ObjectSet(ObjectPrefix + "Fib76", OBJPROP_COLOR, FiboColor);
            ObjectSet(ObjectPrefix + "Fib76", OBJPROP_RAY, 0);
            ObjectSet(ObjectPrefix + "Fib76", OBJPROP_WIDTH, FiboWidth);
            ObjectCreate(ObjectPrefix + "Fib76t", OBJ_TEXT, 0, Time[1], Fib76);
            ObjectSetText(ObjectPrefix + "Fib76t", "76.4", 8, "Arial", FiboColor);
        }

        // Dinapoli.
        if (!DisableDinapoli)
        {
            double Dinap0 = (low_bar + Fib23) / 2;
            double Dinap1 = (Fib23 + Fib38) / 2;
            double Dinap2 = (Fib38 + Fib50) / 2;
            double Dinap3 = (Fib50 + Fib62) / 2;
            double Dinap4 = (Fib62 + Fib76) / 2;
            double Dinap5 = (high_bar + Fib76) / 2;
            bufDinap0[0] = Dinap0;
            bufDinap1[0] = Dinap1;
            bufDinap2[0] = Dinap2;
            bufDinap3[0] = Dinap3;
            bufDinap4[0] = Dinap4;
            bufDinap5[0] = Dinap5;

            ObjectCreate(ObjectPrefix + "Dinap0", OBJ_TREND, 0, Time[cvstart], Dinap0, Time[1], Dinap0);
            ObjectSet(ObjectPrefix + "Dinap0", OBJPROP_STYLE, DinapoliStyle);
            ObjectSet(ObjectPrefix + "Dinap0", OBJPROP_COLOR, DinapoliColor);
            ObjectSet(ObjectPrefix + "Dinap0", OBJPROP_RAY, 0);
            ObjectSet(ObjectPrefix + "Dinap0", OBJPROP_WIDTH, DinapoliWidth);

            ObjectCreate(ObjectPrefix + "Dinap1", OBJ_TREND, 0, Time[cvstart], Dinap1, Time[1], Dinap1);
            ObjectSet(ObjectPrefix + "Dinap1", OBJPROP_STYLE, DinapoliStyle);
            ObjectSet(ObjectPrefix + "Dinap1", OBJPROP_COLOR, DinapoliColor);
            ObjectSet(ObjectPrefix + "Dinap1", OBJPROP_RAY, 0);
            ObjectSet(ObjectPrefix + "Dinap1", OBJPROP_WIDTH, DinapoliWidth);

            ObjectCreate(ObjectPrefix + "Dinap2", OBJ_TREND, 0, Time[cvstart], Dinap2, Time[1], Dinap2);
            ObjectSet(ObjectPrefix + "Dinap2", OBJPROP_STYLE, DinapoliStyle);
            ObjectSet(ObjectPrefix + "Dinap2", OBJPROP_COLOR, DinapoliColor);
            ObjectSet(ObjectPrefix + "Dinap2", OBJPROP_RAY, 0);
            ObjectSet(ObjectPrefix + "Dinap2", OBJPROP_WIDTH, DinapoliWidth);

            ObjectCreate(ObjectPrefix + "Dinap3", OBJ_TREND, 0, Time[cvstart], Dinap3, Time[1], Dinap3);
            ObjectSet(ObjectPrefix + "Dinap3", OBJPROP_STYLE, DinapoliStyle);
            ObjectSet(ObjectPrefix + "Dinap3", OBJPROP_COLOR, DinapoliColor);
            ObjectSet(ObjectPrefix + "Dinap3", OBJPROP_RAY, 0);
            ObjectSet(ObjectPrefix + "Dinap3", OBJPROP_WIDTH, DinapoliWidth);

            ObjectCreate(ObjectPrefix + "Dinap4", OBJ_TREND, 0, Time[cvstart], Dinap4, Time[1], Dinap4);
            ObjectSet(ObjectPrefix + "Dinap4", OBJPROP_STYLE, DinapoliStyle);
            ObjectSet(ObjectPrefix + "Dinap4", OBJPROP_COLOR, DinapoliColor);
            ObjectSet(ObjectPrefix + "Dinap4", OBJPROP_RAY, 0);
            ObjectSet(ObjectPrefix + "Dinap4", OBJPROP_WIDTH, DinapoliWidth);

            ObjectCreate(ObjectPrefix + "Dinap5", OBJ_TREND, 0, Time[cvstart], Dinap5, Time[1], Dinap5);
            ObjectSet(ObjectPrefix + "Dinap5", OBJPROP_STYLE, DinapoliStyle);
            ObjectSet(ObjectPrefix + "Dinap5", OBJPROP_COLOR, DinapoliColor);
            ObjectSet(ObjectPrefix + "Dinap5", OBJPROP_RAY, 0);
            ObjectSet(ObjectPrefix + "Dinap5", OBJPROP_WIDTH, DinapoliWidth);
        }
    }

    // Vertical float lines. These draw the lines that calculate the float.
    // If you change "trendline" to "vertical line", it will draw through oscillators too. Might be fun.
    ObjectDelete(ObjectPrefix + "CVSTART");
    ObjectCreate(ObjectPrefix + "CVSTART", OBJ_TREND, 0, Time[cvstart], high_bar, Time[cvstart], low_bar * Point);
    ObjectSet(ObjectPrefix + "CVSTART", OBJPROP_STYLE, SwingBorderStyle);
    ObjectSet(ObjectPrefix + "CVSTART", OBJPROP_COLOR, SwingBorderColor);
    ObjectSet(ObjectPrefix + "CVSTART", OBJPROP_RAY, 0);
    ObjectSet(ObjectPrefix + "CVSTART", OBJPROP_WIDTH, SwingBorderWidth);
    ObjectSet(ObjectPrefix + "CVSTART", OBJPROP_BACK, DrawVerticalLinesAsBackground);

    ObjectDelete(ObjectPrefix + "CVEND");
    ObjectCreate(ObjectPrefix + "CVEND", OBJ_TREND, 0, Time[cvend], high_bar, Time[cvend], low_bar * Point);
    ObjectSet(ObjectPrefix + "CVEND", OBJPROP_STYLE, SwingBorderStyle);
    ObjectSet(ObjectPrefix + "CVEND", OBJPROP_COLOR, SwingBorderColor);
    ObjectSet(ObjectPrefix + "CVEND", OBJPROP_RAY, 0);
    ObjectSet(ObjectPrefix + "CVEND", OBJPROP_WIDTH, SwingBorderWidth);
    ObjectSet(ObjectPrefix + "CVEND", OBJPROP_BACK, DrawVerticalLinesAsBackground);

    bufCVSTART[0] = (double)Time[cvstart];
    bufCVEND[0] = (double)Time[cvend];

    // Vertical float predictions. These are time-based only.
    // See blue histogram for real float values.
    // If you change "trendline" to "vertical line", it will draw through oscillators too. Might be fun.
    
    ObjectDelete(ObjectPrefix + "Swingend");
    if (cvend - swing_time > 0)
    {
        ObjectCreate(ObjectPrefix + "Swingend", OBJ_TREND, 0, Time[(cvend - swing_time) + 5], high_bar, Time[cvend - swing_time + 5], low_bar);
        ObjectSet(ObjectPrefix + "Swingend", OBJPROP_STYLE, SwingLinesStyle);
        ObjectSet(ObjectPrefix + "Swingend", OBJPROP_COLOR, SwingLinesColor);
        ObjectSet(ObjectPrefix + "Swingend", OBJPROP_RAY, 0);
        ObjectSet(ObjectPrefix + "Swingend", OBJPROP_WIDTH, SwingLinesWidth);
        bufSwingEnd1[0] = (double)Time[(cvend - swing_time) + 5];
    }

    ObjectDelete(ObjectPrefix + "Swingend2");
    if (cvend - (swing_time * 2) > 0)
    {
        ObjectCreate(ObjectPrefix + "Swingend2", OBJ_TREND, 0, Time[(cvend - (swing_time * 2)) + 5], high_bar, Time[cvend - (swing_time * 2) + 5], low_bar);
        ObjectSet(ObjectPrefix + "Swingend2", OBJPROP_STYLE, SwingLinesStyle);
        ObjectSet(ObjectPrefix + "Swingend2", OBJPROP_COLOR, SwingLinesColor);
        ObjectSet(ObjectPrefix + "Swingend2", OBJPROP_RAY, 0);
        ObjectSet(ObjectPrefix + "Swingend2", OBJPROP_WIDTH, SwingLinesWidth);
        bufSwingEnd2[0] = (double)Time[(cvend - swing_time * 2) + 5];
    }
    
    ObjectDelete(ObjectPrefix + "Swingend3");
    if (cvend - (swing_time * 3) > 0)
    {
        ObjectCreate(ObjectPrefix + "Swingend3", OBJ_TREND, 0, Time[(cvend - (swing_time * 3)) + 5], high_bar, Time[cvend - (swing_time * 3) + 5], low_bar);
        ObjectSet(ObjectPrefix + "Swingend3", OBJPROP_STYLE, SwingLinesStyle);
        ObjectSet(ObjectPrefix + "Swingend3", OBJPROP_COLOR, SwingLinesColor);
        ObjectSet(ObjectPrefix + "Swingend3", OBJPROP_RAY, 0);
        ObjectSet(ObjectPrefix + "Swingend3", OBJPROP_WIDTH, SwingLinesWidth);
        bufSwingEnd3[0] = (double)Time[(cvend - swing_time * 3) + 5];
    }

    ObjectDelete(ObjectPrefix + "Swingend4");
    if (cvend - (swing_time * 4) > 0)
    {
        ObjectCreate(ObjectPrefix + "Swingend4", OBJ_TREND, 0, Time[(cvend - (swing_time * 4)) + 5], high_bar, Time[cvend - (swing_time * 4) + 5], low_bar);
        ObjectSet(ObjectPrefix + "Swingend4", OBJPROP_STYLE, SwingLinesStyle);
        ObjectSet(ObjectPrefix + "Swingend4", OBJPROP_COLOR, SwingLinesColor);
        ObjectSet(ObjectPrefix + "Swingend4", OBJPROP_RAY, 0);
        ObjectSet(ObjectPrefix + "Swingend4", OBJPROP_WIDTH, SwingLinesWidth);
        bufSwingEnd4[0] = (double)Time[(cvend - swing_time * 4) + 5];
    }

    ObjectDelete(ObjectPrefix + "Swingend5");
    if (cvend - (swing_time * 5) > 0)
    {
        ObjectCreate(ObjectPrefix + "Swingend5", OBJ_TREND, 0, Time[(cvend - (swing_time * 5)) + 5], high_bar, Time[cvend - (swing_time * 5) + 5], low_bar);
        ObjectSet(ObjectPrefix + "Swingend5", OBJPROP_STYLE, SwingLinesStyle);
        ObjectSet(ObjectPrefix + "Swingend5", OBJPROP_COLOR, SwingLinesColor);
        ObjectSet(ObjectPrefix + "Swingend5", OBJPROP_RAY, 0);
        ObjectSet(ObjectPrefix + "Swingend5", OBJPROP_WIDTH, SwingLinesWidth);
        bufSwingEnd5[0] = (double)Time[(cvend - swing_time * 5) + 5];
    }

    ObjectDelete(ObjectPrefix + "Swingend6");
    if (cvend - (swing_time * 6) > 0)
    {
        ObjectCreate(ObjectPrefix + "Swingend6", OBJ_TREND, 0, Time[cvend - (swing_time * 6) + 5], high_bar, Time[cvend - (swing_time * 6) + 5], low_bar);
        ObjectSet(ObjectPrefix + "Swingend6", OBJPROP_STYLE, SwingLinesStyle);
        ObjectSet(ObjectPrefix + "Swingend6", OBJPROP_COLOR, SwingLinesColor);
        ObjectSet(ObjectPrefix + "Swingend6", OBJPROP_RAY, 0);
        ObjectSet(ObjectPrefix + "Swingend6", OBJPROP_WIDTH, SwingLinesWidth);
        bufSwingEnd6[0] = (double)Time[(cvend - swing_time * 6) + 5];
    }

    ObjectDelete(ObjectPrefix + "Swingend7");
    if (cvend - (swing_time * 7) > 0)
    {
        ObjectCreate(ObjectPrefix + "Swingend7", OBJ_TREND, 0, Time[cvend - (swing_time * 7) + 5], high_bar, Time[cvend - (swing_time * 7) + 5], low_bar);
        ObjectSet(ObjectPrefix + "Swingend7", OBJPROP_STYLE, SwingLinesStyle);
        ObjectSet(ObjectPrefix + "Swingend7", OBJPROP_COLOR, SwingLinesColor);
        ObjectSet(ObjectPrefix + "Swingend7", OBJPROP_RAY, 0);
        ObjectSet(ObjectPrefix + "Swingend7", OBJPROP_WIDTH, SwingLinesWidth);
        bufSwingEnd7[0] = (double)Time[(cvend - swing_time * 7) + 5];
    }

    ObjectDelete(ObjectPrefix + "Swingend8");
    if (cvend - (swing_time * 8) > 0)
    {
        ObjectCreate(ObjectPrefix + "Swingend8", OBJ_TREND, 0, Time[cvend - (swing_time * 8) + 5], high_bar, Time[cvend - (swing_time * 8) + 5], low_bar);
        ObjectSet(ObjectPrefix + "Swingend8", OBJPROP_STYLE, SwingLinesStyle);
        ObjectSet(ObjectPrefix + "Swingend8", OBJPROP_COLOR, SwingLinesColor);
        ObjectSet(ObjectPrefix + "Swingend8", OBJPROP_RAY, 0);
        ObjectSet(ObjectPrefix + "Swingend8", OBJPROP_WIDTH, SwingLinesWidth);
        bufSwingEnd8[0] = (double)Time[(cvend - swing_time * 8) + 5];
    }

    ObjectDelete(ObjectPrefix + "Swingend9");
    if (cvend - (swing_time * 9) > 0)
    {
        ObjectCreate(ObjectPrefix + "Swingend9", OBJ_TREND, 0, Time[cvend - (swing_time * 9) + 5], high_bar, Time[cvend - (swing_time * 9) + 5], low_bar);
        ObjectSet(ObjectPrefix + "Swingend9", OBJPROP_STYLE, SwingLinesStyle);
        ObjectSet(ObjectPrefix + "Swingend9", OBJPROP_COLOR, SwingLinesColor);
        ObjectSet(ObjectPrefix + "Swingend9", OBJPROP_RAY, 0);
        ObjectSet(ObjectPrefix + "Swingend9", OBJPROP_WIDTH, SwingLinesWidth);
        bufSwingEnd9[0] = (double)Time[(cvend - swing_time * 9) + 5];
    }

    return rates_total;
}
//+------------------------------------------------------------------+
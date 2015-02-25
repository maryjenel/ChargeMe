//
//  GraphView.m
//  MyGraph
//
//  Created by Tewodros Wondimu on 2/24/15.
//  Copyright (c) 2015 Tewodros Wondimu. All rights reserved.
//

#import "GraphView.h"

#define kGraphHeight 200
#define kDefaultGraphWidth 300

#define kOffsetX 30
#define kStepX 40

#define kStepY 50
#define kOffsetY 10

#define kGraphRight 250
#define kGraphLeft 0

#define kGraphBottom 200
#define kGraphTop 20

@interface GraphView ()

@property UIColor *gridColor;

@end

@implementation GraphView

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();

    [self drawHorizontalLines:context];

    [self drawLineGraphWithContext:context];

    [self drawVerticalLines:context];
}

- (void)drawLineGraphWithContext:(CGContextRef)context
{
//    NSArray *dataArray = @[@81.98, @121.97, @41.99, @81.98, @13.25, @20.32];
    NSArray *dataArray = self.dataArray;
//    NSArray *yAxisArray = @[@"SUN", @"MON", @"TUE", @"WED", @"THU", @"FRI", @"SAT"];
    NSArray *yAxisArray = self.yAxisArray;
    float max = [[dataArray valueForKeyPath:@"@max.floatValue"] floatValue];

    // Show the legend on the left for the minimum and maximum values
    [self showLabelsForMinimumAndMaximum:dataArray];

    // Defines the thickness and the color of the graph lines
    CGContextSetLineWidth(context, 2.0);
    CGContextSetStrokeColorWithColor(context, [[UIColor whiteColor] CGColor]);

    int maxGraphHeight = kGraphHeight - kOffsetY - 10;
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, kOffsetX, kGraphHeight - maxGraphHeight * ([dataArray[0] floatValue] / max));

    // Draw out the lines for the graph
    for (int i = 1; i < dataArray.count; i++)
    {
        float dataValue = [dataArray[i] floatValue] / max;
        // Draw a line from the last point to the next point
        CGContextAddLineToPoint(context, kOffsetX + i * kStepX, kGraphHeight - maxGraphHeight * dataValue);
        NSLog(@"%.2f", dataValue);
    }

    // Display labels for the columns in the graph
    for (int i = 0; i < yAxisArray.count; i++)
    {
        // Shows the dates at the bottom of the graph
        UILabel *bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake((kOffsetX + i * kStepX) - 10, kGraphBottom - 10, 50, 30)];
        bottomLabel.textColor = [UIColor grayColor];
        bottomLabel.font = [bottomLabel.font fontWithSize:10];
        [bottomLabel setText:[NSString stringWithFormat:@"%@", yAxisArray[i]]];
        [self addSubview:bottomLabel];
    }

    CGContextDrawPath(context, kCGPathStroke);

    // Draw the spheres for the graph
    for (int i = 0; i < dataArray.count; i++) {
        float dataValue = [dataArray[i] floatValue] / max;

        // Draws the path for the stroke of the sphere on the line intersection
        CGContextSetLineWidth(context,3);
        CGContextSetStrokeColorWithColor(context, [[UIColor whiteColor] CGColor]);
        CGContextAddArc(context,kOffsetX + i * kStepX, kGraphHeight - maxGraphHeight * dataValue,6,0.0,M_PI*2,YES);
        CGContextStrokePath(context);

        // Draws the path for the sphere on the line intersection
        CGContextSetLineWidth(context,5);
        CGContextSetStrokeColorWithColor(context, [self.gridColor CGColor]);
        CGContextAddArc(context,kOffsetX + i * kStepX, kGraphHeight - maxGraphHeight * dataValue,3,0.0,M_PI*2,YES);
        CGContextStrokePath(context);
    }
}

- (void)drawVerticalLines:(CGContextRef)context
{
    // Defines the thickness and the color of the grid lines
    CGContextSetLineWidth(context, 0.5);

    // Make the style dashed for the vertical lines
    CGFloat dash[] = {2.0, 2.0};
    CGContextSetLineDash(context, 0.0, dash, 2);

    // Draw all the vertical lines
    int howMany = (kDefaultGraphWidth - kOffsetX) / kStepX;

    // Here the lines go
    for (int i = 0; i < howMany + 1; i++)
    {
        CGContextMoveToPoint(context, kOffsetX + i * kStepX, kGraphTop);
        CGContextAddLineToPoint(context, kOffsetX + i * kStepX, kGraphBottom - kOffsetY);
    }
    CGContextStrokePath(context);
}

- (void)drawHorizontalLines:(CGContextRef)context
{
    // Define the Grid Color and Background Color
    self.gridColor = [UIColor colorWithRed:76.0/255.0 green:217.0/255.0 blue:100.0/255.0 alpha:1.0];

    // Defines the thickness and the color of the grid lines
    CGContextSetLineWidth(context, 0.5);
    CGContextSetStrokeColorWithColor(context, [self.gridColor CGColor]);

    // Calculates the number of horizontal lines that can be done
    int howManyHorizontalLines = (kGraphBottom - kGraphTop - kOffsetY) / kStepY;

    // Draw all the horizontal lines
    for (int i = 0; i <= howManyHorizontalLines; i++)
    {
        CGContextMoveToPoint(context, kOffsetX, kGraphBottom - kOffsetY - i * kStepY);
        CGContextAddLineToPoint(context, kDefaultGraphWidth, kGraphBottom - kOffsetY - i * kStepY);
    }

    // Draw out the borders for the graph
    CGContextMoveToPoint(context, kGraphLeft + kOffsetX, kGraphBottom - kOffsetY);
    CGContextAddLineToPoint(context, kGraphLeft + kOffsetX, kGraphTop);

    // Execute the drawings
    CGContextStrokePath(context);
}

- (void)showLabelsForMinimumAndMaximum:(NSArray *)dataArray
{
    // Get the maximum and minimum values of the the data array
    int max = [[dataArray valueForKeyPath:@"@max.floatValue"] intValue];
    int min = [[dataArray valueForKeyPath:@"@min.floatValue"] intValue];

    UILabel *topLabel = [[UILabel alloc] initWithFrame:CGRectMake(kOffsetX - 55, kGraphTop - 15, 50, 30)];
    topLabel.textColor = [UIColor grayColor];
    topLabel.textAlignment = NSTextAlignmentRight;
    topLabel.font = [topLabel.font fontWithSize:10];
    [topLabel setText:[NSString stringWithFormat:@"$%i", max]];
    [self addSubview:topLabel];

    UILabel *bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(kOffsetX - 55, kGraphBottom - 25, 50, 30)];
    bottomLabel.textColor = [UIColor grayColor];
    bottomLabel.textAlignment = NSTextAlignmentRight;
    bottomLabel.font = [bottomLabel.font fontWithSize:10];
    [bottomLabel setText:[NSString stringWithFormat:@"$%i", min]];
    [self addSubview:bottomLabel];

}

@end

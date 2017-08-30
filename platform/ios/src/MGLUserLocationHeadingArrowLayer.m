#import "MGLUserLocationHeadingArrowLayer.h"

#import "MGLFaux3DUserLocationAnnotationView.h"
#import "MGLGeometry.h"

const CGFloat MGLUserLocationHeadingArrowSize = MGLUserLocationAnnotationDotSize / 2.5;

@implementation MGLUserLocationHeadingArrowLayer
{

}

- (instancetype)initWithUserLocationAnnotationView:(MGLUserLocationAnnotationView *)userLocationView
{
    self = [super init];
    self.bounds = CGRectMake(0, 0, MGLUserLocationHeadingArrowSize, MGLUserLocationHeadingArrowSize);
    self.position = CGPointMake(MGLUserLocationAnnotationDotSize / 2.0, -5.0);
    self.path = [self arrowPath];
    self.fillColor = userLocationView.tintColor.CGColor;
    self.shouldRasterize = YES;
    self.rasterizationScale = UIScreen.mainScreen.scale;
    self.drawsAsynchronously = YES;

    self.borderColor = [UIColor colorWithWhite:0 alpha:0.25].CGColor;
    self.borderWidth = 1;

    return self;
}

- (void)updateHeadingAccuracy:(CLLocationDirection)accuracy
{
    // unimplemented
}

- (void)updateTintColor:(CGColorRef)color
{
    self.fillColor = color;
}

- (CGPathRef)arrowPath {
    CGFloat max = MGLUserLocationHeadingArrowSize;

    CGPoint top = CGPointMake(max * 0.5, max * 0.4);
    CGPoint left = CGPointMake(0, max);
    CGPoint right = CGPointMake(max, max);
    CGPoint center = CGPointMake(max * 0.5, max * 0.8);

    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:top];
    [bezierPath addLineToPoint:left];
    [bezierPath addQuadCurveToPoint:right controlPoint:center];
    [bezierPath addLineToPoint:top];
    [bezierPath closePath];
    
    return bezierPath.CGPath;
}

@end

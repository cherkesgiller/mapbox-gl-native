#import "MGLUserLocationHeadingArrowLayer.h"

#import "MGLFaux3DUserLocationAnnotationView.h"
#import "MGLGeometry.h"

const CGFloat MGLUserLocationHeadingArrowSize = MGLUserLocationAnnotationDotSize / 4;

@implementation MGLUserLocationHeadingArrowLayer

- (instancetype)initWithUserLocationAnnotationView:(MGLUserLocationAnnotationView *)userLocationView
{
    CGFloat size = MGLUserLocationAnnotationDotSize + roundf(MGLUserLocationHeadingArrowSize * 2);

    self = [super init];
    self.bounds = CGRectMake(0, 0, size, size);
    self.position = CGPointMake(CGRectGetMidX(userLocationView.bounds), CGRectGetMidY(userLocationView.bounds));
    self.path = [self arrowPath];
    self.fillColor = userLocationView.tintColor.CGColor;
    self.shouldRasterize = YES;
    self.rasterizationScale = UIScreen.mainScreen.scale;
    self.drawsAsynchronously = YES;

//    self.borderColor = [UIColor colorWithWhite:0 alpha:0.25].CGColor;
//    self.borderWidth = 1;

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
    CGFloat center = self.bounds.size.width * 0.5;
    CGFloat size = roundf(MGLUserLocationHeadingArrowSize);

    CGPoint top =       CGPointMake(center,         0);
    CGPoint left =      CGPointMake(center - size,  size);
    CGPoint right =     CGPointMake(center + size,  size);
    CGPoint middle =    CGPointMake(center,         size / M_PI);

    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:top];
    [bezierPath addLineToPoint:left];
    [bezierPath addQuadCurveToPoint:right controlPoint:middle];
    [bezierPath addLineToPoint:top];
    [bezierPath closePath];
    
    return bezierPath.CGPath;
}

@end

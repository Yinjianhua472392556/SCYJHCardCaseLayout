//
//  SCYJHCardCaseLayout.m
//  SuperCard
//
//  Created by  on 2017/11/24.
//  Copyright © 2017年 G-mall. All rights reserved.
//

#import "SCYJHCardCaseLayout.h"

@interface SCYJHCardCaseLayout ()

/** cell的尺寸 */
@property (nonatomic) CGSize itemSize;
/** cell之间的间距 */
@property (nonatomic) CGFloat minimumSpacing;
/** 滚动区域 */
@property (nonatomic) CGSize contentSize;
/** 布局信息 */
@property (nonatomic, copy) NSDictionary *layoutInfo;

@property (nonatomic, strong) NSIndexPath *scaledIndexPath;

@end

@implementation SCYJHCardCaseLayout

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        BOOL isX = [UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO;
        if (isX) {
            
            self.minimumSpacing = 30;
        } else {
           
            self.minimumSpacing = 45;
        }
        
    }
    return self;
}

static CGFloat multiple = 0.58;

#pragma mark - override
-(void)prepareLayout {
    //设置item的大小
    CGFloat collectionViewHeight = CGRectGetHeight(self.collectionView.frame);
    CGFloat realHeight = collectionViewHeight;
    CGFloat realWidth = realHeight * multiple;
    self.itemSize = CGSizeMake(realWidth, realHeight);
    
    NSIndexPath *indexPath;
    NSMutableDictionary *attributesDict = [NSMutableDictionary dictionary];
    NSUInteger count = [self.collectionView numberOfItemsInSection:0];
    for (int item = 0; item < count; item++) {
        
        indexPath = [NSIndexPath indexPathForItem:item inSection:0];
        
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        attributes.frame = [self contentFrameForCardAtIndexPath:indexPath];
        NSString *key = [self keyForAttributes:indexPath];
        attributesDict[key] = attributes;
        
        if (item == count - 1) self.contentSize = CGSizeMake(CGRectGetMaxX(attributes.frame) + self.sidesInset, collectionViewHeight);
    }
    self.layoutInfo = attributesDict;
}

- (void)scaleIndexPath:(NSIndexPath *)indexPath {
    
    self.scaledIndexPath = indexPath;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    
    //计算屏幕最中间的x
    CGFloat centerX = self.collectionView.contentOffset.x + self.collectionView.frame.size.width / 2;
    
    //增加预加载区域，防止即将出来的cell出现闪变的情况
    CGFloat preSize = CGRectGetWidth(self.collectionView.frame);
    rect.origin.x -= preSize;
    rect.size.width += preSize * 2;
    
    NSMutableArray *attributesArray = [NSMutableArray array];
    
    [self.layoutInfo enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, UICollectionViewLayoutAttributes * _Nonnull obj, BOOL * _Nonnull stop) {
        
        CGFloat distance = fabs(obj.center.x - centerX);
        CGFloat apartScale = distance / self.collectionView.bounds.size.width;
        
        //按照余弦定理计算形变属性
        if (self.scaledIndexPath.item == obj.indexPath.item && self.scaledIndexPath != nil) {

            obj.transform = CGAffineTransformMakeScale(0.9, 0.9);
        } else {

            CGFloat scale = fabs(cos(apartScale * M_PI / 7));
            obj.transform = CGAffineTransformMakeScale(scale, scale);
        }
        //改变透明度
        if (!_isNeedChangeAlpha) {
            
            CGFloat alpha = fabs(cos(apartScale * M_PI / 2));
            obj.alpha = alpha;
        }
        [attributesArray addObject:obj];
    }];
    
    return attributesArray;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return self.layoutInfo[[self keyForAttributes:indexPath]];
}

- (CGSize)collectionViewContentSize {
    
    return self.contentSize;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    
    return  YES;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
    
    CGPoint destination = proposedContentOffset;
    
    CGRect targetRect = self.collectionView.bounds;//collectionView落在屏幕的区域
    targetRect.origin.x = destination.x;
    CGFloat horizontalCenter = CGRectGetMidX(targetRect);//collectionView落在屏幕中点的x坐标
    
    NSArray *array = [self layoutAttributesForElementsInRect:targetRect];//获得落在屏幕的所有cell的属性
    
    //对当前屏幕中的UICollectionViewLayoutAttributes逐个与屏幕中心进行比较，找出最接近中心的一个
    CGFloat offsetAdjustment = MAXFLOAT;
    NSIndexPath *nearestIndexPath;
    NSIndexPath *nextIndexPath;
    CGFloat velocityValue = velocity.x;
    for (UICollectionViewLayoutAttributes* layoutAttributes in array) {
        
        CGFloat itemHorizontalCenter = layoutAttributes.center.x;
        CGFloat distance = ABS(itemHorizontalCenter - horizontalCenter);
        if (distance < ABS(offsetAdjustment)) {
            
            offsetAdjustment = itemHorizontalCenter - horizontalCenter;
            nearestIndexPath = layoutAttributes.indexPath;
        }
    }
    
    if (velocityValue > 0) {//左滑
        
        if (offsetAdjustment > 0) {
            
            nextIndexPath = nearestIndexPath;
        } else {
            
            nextIndexPath = [NSIndexPath indexPathForItem:nearestIndexPath.item + 1 inSection:nearestIndexPath.section];
        }
    } else {
        
        if (offsetAdjustment > 0) {
            
            nextIndexPath = [NSIndexPath indexPathForItem:nearestIndexPath.item - 1 inSection:nearestIndexPath.section];
        } else {
            
            nextIndexPath = nearestIndexPath;
        }
    }
    
    BOOL flicked = fabs(velocityValue) > [self flickVelocity];
    BOOL panned = fabs(offsetAdjustment) / self.itemSize.width > 0.3;
    CGFloat centerx = 0;
    if (flicked || panned) {
        
        NSUInteger count = [self.collectionView numberOfItemsInSection:0];
        if (count - 1 < nextIndexPath.item) {
            
            centerx = [self layoutAttributesForItemAtIndexPath:nearestIndexPath].center.x;
        } else {
            
            centerx = [self layoutAttributesForItemAtIndexPath:nextIndexPath].center.x;
        }
    } else {
        
        centerx = [self layoutAttributesForItemAtIndexPath:nearestIndexPath].center.x;
    }
    
    destination.x = centerx - CGRectGetWidth(self.collectionView.frame) / 2;
    
    self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    
    return destination;
}

- (CGFloat)flickVelocity {
    
    return 0.3;
}

#pragma mark - Helper
- (CGRect)contentFrameForCardAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat positionX = self.sidesInset + indexPath.item * (self.itemSize.width + self.minimumSpacing);
    
    return (CGRect){{positionX, 0}, self.itemSize};
}

- (CGFloat)sidesInset {
    
    return (CGRectGetWidth(self.collectionView.frame) - CGRectGetHeight(self.collectionView.frame) * multiple) * 0.5;
}

- (NSString *)keyForAttributes:(NSIndexPath *)indexPath {
    
    return [NSString stringWithFormat:@"%ld-%ld", indexPath.section, indexPath.item];
}

@end

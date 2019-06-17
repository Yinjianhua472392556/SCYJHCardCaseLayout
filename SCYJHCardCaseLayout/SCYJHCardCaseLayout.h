//
//  SCWHBCardCaseLayout.h
//  SuperCard
//
//  Created by  on 2017/11/24.
//  Copyright © 2017年 G-mall. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SCWHBCardCaseLayout : UICollectionViewLayout
/** 是否需要改变透明度 */
@property (nonatomic) BOOL isNeedChangeAlpha;

- (void)scaleIndexPath:(NSIndexPath *)indexPath;

@end

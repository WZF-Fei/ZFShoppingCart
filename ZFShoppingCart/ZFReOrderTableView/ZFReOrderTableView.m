//
//  ZFReOrderTableView.m
//
//  Created by WZF on 15/11/13.
//  Copyright © 2015年 WZF. <wzhf366@163.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.


#import "ZFReOrderTableView.h"
#import "ShoppingCartCell.h"

@interface ZFReOrderTableView()

@property (nonatomic,strong) CADisplayLink *scrollDisplayLink;

@property (nonatomic,strong) UIView *snapshot;
//源
@property (nonatomic,strong) NSIndexPath *sourceIndexPath;

@property (nonatomic,strong) NSIndexPath *indexPath;

@property (nonatomic,strong) NSIndexPath *initialSourceIndexPath;

@property (nonatomic,strong) UILongPressGestureRecognizer *longPress;
//初始cell背景
@property (nonatomic,strong) UIColor *originBackgroundColor;
//滚动速率
@property (nonatomic,assign) CGFloat scrollRate;
//是否可以拖动排序
@property (nonatomic,assign) BOOL isReorder;

//合并cell
@property (nonatomic,assign) BOOL canMergeCell;
//拆分cell
@property (nonatomic,assign) BOOL canSplitCell;

@property (nonatomic,strong) NSString *identifier;

@property (nonatomic,strong) NSMutableDictionary *splitedDictionary;

@end

@implementation ZFReOrderTableView

-(instancetype)initWithFrame:(CGRect)frame withObjects:(NSMutableArray *)objects
{
    return [self initWithFrame:frame withObjects:objects canReorder:NO];
}

-(instancetype)initWithFrame:(CGRect)frame withObjects:(NSMutableArray *)objects canReorder:(BOOL)reOrder
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.objects = [NSMutableArray arrayWithArray:objects];
        self.isReorder = reOrder;
        self.canMergeCell = YES;
        self.canSplitCell = YES;
        self.identifier = nil;
        self.splitedDictionary = [NSMutableDictionary dictionary];
        [self layoutUI];
    }
    return self;
}

-(void)layoutUI
{
    self.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.7];
    self.tableView = [[UITableView alloc] initWithFrame:self.bounds];
    self.tableView.bounces = NO;
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.tableView];
    
    if (self.isReorder) {
        _longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognized:)];
        [self.tableView addGestureRecognizer:_longPress];
    }
    
    
}

#pragma mark -手势操作
- (void)longPressGestureRecognized:(id)sender {
    
    UILongPressGestureRecognizer *longPress = (UILongPressGestureRecognizer *)sender;
    UIGestureRecognizerState state = longPress.state;
    
    switch (state)
    {
        case UIGestureRecognizerStateBegan:
            [self didBeginLongPressGestureRecognizer:longPress];
            break;
        case UIGestureRecognizerStateChanged:
            [self didChangeLongPressGestureRecognizer:longPress];
            break;
        case UIGestureRecognizerStateEnded:
            [self didEndLongPressGestureRecognizer:longPress];
        default:
            break;
    }
    
}

- (void)didBeginLongPressGestureRecognizer:(UILongPressGestureRecognizer*)gestureRecognizer
{
    const CGPoint location = [gestureRecognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    
    if (indexPath == nil)
    {
        gestureRecognizer.enabled = NO;
        gestureRecognizer.enabled = YES;
        return;
    }
    
    if (indexPath) {
        _sourceIndexPath = indexPath;
        _initialSourceIndexPath = indexPath;
        _indexPath = indexPath;
     
        
        ShoppingCartCell *cell = (ShoppingCartCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        _originBackgroundColor = cell.backgroundColor;
        
        cell.backgroundColor = [UIColor whiteColor];
        
        
        [self.tableView beginUpdates];
        //拆分单元格，YES:其他单元格都不会移动，NO:其他单元格会exchange and move
        NSMutableArray *sourceArray = [self.objects objectAtIndex:_initialSourceIndexPath.section];
        NSMutableDictionary *currentDictionary = sourceArray[_initialSourceIndexPath.row];
        
        if ([currentDictionary[@"orderCount"] integerValue] ==1 ) {
            self.identifier = nil;
            _canSplitCell = NO;
            NSLog(@"NO");
            
        }
        else if ([currentDictionary[@"orderCount"] integerValue] >1){
            self.identifier = currentDictionary[@"id"];
            _canSplitCell = YES;

            NSInteger count = [currentDictionary[@"orderCount"] integerValue] -1;
            [currentDictionary setObject:[NSNumber numberWithInteger:count] forKey:@"orderCount"];
           
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:_initialSourceIndexPath.row inSection:_initialSourceIndexPath.section]]  withRowAnimation:UITableViewRowAnimationFade];
            
            NSLog(@"YES");
            
        }
        
        if (_canSplitCell) {
            cell.numberLabel.text = @"1";
        }
        
        _snapshot = [self customSnapshoFromView:cell];
        [self.tableView endUpdates];
        __block CGPoint center = cell.center;
        _snapshot.center = center;
        _snapshot.alpha = 0.0;
        [self.tableView addSubview:_snapshot];
        [UIView animateWithDuration:0.25 animations:^{
            
            center.y = location.y;
            _snapshot.center = center;
            _snapshot.transform = CGAffineTransformMakeScale(1.05, 1.05);
            _snapshot.alpha = 0.98;
            cell.alpha = 1.0;
            
        } completion:^(BOOL finished) {
            cell.backgroundColor = [_originBackgroundColor colorWithAlphaComponent:0.6];
            cell.hidden = YES;
            
            if (_canSplitCell) {
                cell.hidden = NO;
            }
            
            
        }];
    }
    
    _scrollDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(scrollTableWithCell:)];
    [_scrollDisplayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)didEndLongPressGestureRecognizer:(UILongPressGestureRecognizer*)gestureRecognizer
{
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:_sourceIndexPath];
    cell.alpha = 0.0;
    
    //应立即关闭定时器
    [_scrollDisplayLink invalidate];
    _scrollDisplayLink = nil;
    
    [_snapshot removeFromSuperview];
    
    BOOL isRollUp =  [self canRollUpTableView:self.tableView];
  
    [UIView animateWithDuration:0.5 animations:^{
        
        CGPoint currentOffset = self.tableView.contentOffset;
        if (isRollUp) {
            currentOffset.y += 30;
        }
        int maxHeight = [UIScreen mainScreen].bounds.size.height - 250 - 30;
        cell.alpha = 1.0;
        if (self.frame.size.height > maxHeight) {
            [self.tableView setContentOffset:currentOffset];
        }
        
        
    } completion:^(BOOL finished) {
        
     
        {
            _scrollRate = 0;
            _sourceIndexPath = nil;
            _snapshot = nil;

        }

        if(self.objects.count <= _indexPath.section && !self.identifier){
            return ;
        }
        if (_canMergeCell) {
            if ([self.delegate respondsToSelector:@selector(mergeRowsInSection:splitRowIdentifier:)])
            {
                [self.delegate mergeRowsInSection:_indexPath.section splitRowIdentifier:self.identifier];
            }
        }

        _identifier = nil;
        cell.hidden = NO;
        
    }];
    
}

#pragma mark - 是否滚动UITableView
-(BOOL) canRollUpTableView:(UITableView *)tableView
{
    BOOL isRollUp = NO;
    
    BOOL isDelete = NO;
    NSUInteger deleteSectionIndex = 0;
    //其中某个section的数组个数为0，则删除整个section
    for (NSMutableArray *sectionArray in self.objects) {
        if ([sectionArray count] <= 0 && deleteSectionIndex < self.objects.count - 1) {
            isDelete = YES;
            break;
        }
        deleteSectionIndex ++;
    }

    [tableView beginUpdates];
    
    if (isDelete && self.objects.count > 2) {
        [tableView deleteSections:[NSIndexSet indexSetWithIndex:deleteSectionIndex] withRowAnimation:UITableViewRowAnimationFade];
        [self.objects removeObjectAtIndex:deleteSectionIndex];
        //更新数据源
        if ([self.delegate respondsToSelector:@selector(updateDataSource:)])
        {
            [self.delegate updateDataSource:self.objects];
        }
    }
    else //insert new scetion
    {
        if ([[self.objects objectAtIndex:([self.objects count] - 2)] count] > 0 && [[self.objects objectAtIndex:([self.objects count] - 1)] count] > 0) {
            [tableView insertSections:[NSIndexSet indexSetWithIndex:[self.objects count]] withRowAnimation:UITableViewRowAnimationFade];
            
            NSMutableArray *newSection = [NSMutableArray array];
            [self.objects addObject:newSection];
            
            if ([self.delegate respondsToSelector:@selector(updateDataSource:)])
            {
                [self.delegate updateDataSource:self.objects];
            }
            isRollUp = YES;
        }
    }

    [tableView endUpdates];
    
    return isRollUp;

}

#pragma mark - setter
-(void) setObjects:(NSMutableArray *)objects
{
    _objects = objects;
}

#pragma mark - 重新排序
//排序
- (void)reorderCurrentRowToIndexPath:(NSIndexPath*)toIndexPath
{
    if (!toIndexPath) {
        return;
    }
    [self.tableView beginUpdates];
    
   
    //同一个section 直接交换,然后move
    if (toIndexPath.section == _sourceIndexPath.section)
    {
        if (!_canSplitCell) {
            NSLog(@"sourceIndexPath1:%@,toIndexPath1:%@",_sourceIndexPath,toIndexPath);
            [self.objects[toIndexPath.section] exchangeObjectAtIndex:toIndexPath.row withObjectAtIndex:_sourceIndexPath.row];
            [self.tableView moveRowAtIndexPath:_sourceIndexPath toIndexPath:toIndexPath];
        }
    }
    else //不同section 需要对数据源处理,然后move
    {

        NSMutableArray *array = [self.objects objectAtIndex:toIndexPath.section];
        NSMutableArray *sourceArray = [self.objects objectAtIndex:_sourceIndexPath.section];
        
        //_sourceIndexPath 源---> toIndexPath 目的
        //判断toIndexPath是否有相同的id。有相同则合并
        
        _indexPath = toIndexPath;

        
        if (!_canSplitCell)
        {
            NSMutableArray *tempArray = [NSMutableArray arrayWithArray:sourceArray];
            [sourceArray removeObject:tempArray[_sourceIndexPath.row]];
            [array insertObject:tempArray[_sourceIndexPath.row] atIndex:toIndexPath.row];
//            NSLog(@"sourceArray:%@,======================array:%@",tempArray,array);
//            
//            NSLog(@"sourcePath:%@,===============toIndexPath:%@",_sourceIndexPath,toIndexPath);
            [self.tableView moveRowAtIndexPath:_sourceIndexPath toIndexPath:toIndexPath];
        }
    
    }
    

    _sourceIndexPath = toIndexPath;
    [self.tableView endUpdates];
}

#pragma mark - Helper methods

/** @brief Returns a customized snapshot of a given view. */
- (UIView *)customSnapshoFromView:(UIView *)inputView {
    
    // Make an image from the input view.
    UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, NO, 0);
    [inputView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Create an image view.
    UIView *snapshot = [[UIImageView alloc] initWithImage:image];
    snapshot.layer.masksToBounds = NO;
    snapshot.layer.cornerRadius = 0.0;
    snapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0);
    snapshot.layer.shadowRadius = 5.0;
    snapshot.layer.shadowOpacity = 0.4;
    return snapshot;
}

// Taken from https://github.com/hpique/HPReorderTableView with minor modifications
//
//  HPReorderTableView.m
//
//  Created by Hermes Pique on 22/01/14.
//  Copyright (c) 2014 Hermes Pique
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
- (void)didChangeLongPressGestureRecognizer:(UILongPressGestureRecognizer*)gestureRecognizer
{
    const CGPoint location = [gestureRecognizer locationInView:self.tableView];
    
    // update position of the drag view
    // don't let it go past the top or the bottom too far
    if (location.y >= 0 && location.y <= self.tableView.contentSize.height + 50)
    {
        _snapshot.center = CGPointMake(self.center.x, location.y);
    }
    
    CGRect rect = self.bounds;
    // adjust rect for content inset as we will use it below for calculating scroll zones
    rect.size.height -= self.tableView.contentInset.top;
    
    [self updateCurrentLocation:gestureRecognizer];
    
    // tell us if we should scroll and which direction
    CGFloat scrollZoneHeight = rect.size.height / 6;
    CGFloat bottomScrollBeginning = self.tableView.contentOffset.y + self.tableView.contentInset.top + rect.size.height - scrollZoneHeight;
    CGFloat topScrollBeginning = self.tableView.contentOffset.y + self.tableView.contentInset.top  + scrollZoneHeight;
    
    // we're in the bottom zone
    if (location.y >= bottomScrollBeginning)
    {
        _scrollRate = (location.y - bottomScrollBeginning) / scrollZoneHeight;
    }
    // we're in the top zone
    else if (location.y <= topScrollBeginning)
    {
        _scrollRate = (location.y - topScrollBeginning) / scrollZoneHeight;
    }
    else
    {
        _scrollRate = 0;
    }
    
}

- (void)scrollTableWithCell:(NSTimer *)timer
{
    UILongPressGestureRecognizer *gesture = self.longPress;
    const CGPoint location = [gesture locationInView:self.tableView];
    
    CGPoint currentOffset = self.tableView.contentOffset;
    CGPoint newOffset = CGPointMake(currentOffset.x, currentOffset.y + _scrollRate * 5);
    
    if (newOffset.y < -self.tableView.contentInset.top)
    {
        newOffset.y = -self.tableView.contentInset.top;
    }
    else if (self.tableView.contentSize.height + self.tableView.contentInset.bottom < self.frame.size.height)
    {
        newOffset = currentOffset;
    }
    else if (newOffset.y > (self.tableView.contentSize.height + self.tableView.contentInset.bottom) - self.frame.size.height)
    {
        newOffset.y = (self.tableView.contentSize.height + self.tableView.contentInset.bottom) - self.frame.size.height;
    }
    
    [self.tableView setContentOffset:newOffset];
    
    if (location.y >= 0 && location.y <= self.tableView.contentSize.height + 50)
    {
        _snapshot.center = CGPointMake(self.center.x, location.y);
        
    }
    
    [self updateCurrentLocation:gesture];
}

- (void)updateCurrentLocation:(UILongPressGestureRecognizer *)gesture
{
    const CGPoint location  = [gesture locationInView:self.tableView];
    NSIndexPath *toIndexPath = [self.tableView indexPathForRowAtPoint:location];
    
    for (int section = 0; section < [self.objects count]; section ++) {
        
        CGRect rect = [self.tableView rectForHeaderInSection:section];

        BOOL isContained = CGRectContainsPoint(rect,location);
        
        if (isContained) {
            toIndexPath = [NSIndexPath indexPathForRow:0 inSection:section];
        }
    }
    
    if ([toIndexPath compare:_sourceIndexPath] == NSOrderedSame) return;
    
    NSInteger originalHeight = _snapshot.frame.size.height;
    NSInteger toHeight = [self.tableView rectForRowAtIndexPath:toIndexPath].size.height;
    UITableViewCell *toCell = [self.tableView cellForRowAtIndexPath:toIndexPath];
    const CGPoint toCellLocation = [gesture locationInView:toCell];
    
    if (toCellLocation.y <= toHeight - originalHeight) return;
    
    [self reorderCurrentRowToIndexPath:toIndexPath];
}


@end

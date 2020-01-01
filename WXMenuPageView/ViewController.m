//
//  ViewController.m
//  WXMenuPageView
//
//  Created by Luke on 2019/12/29.
//  Copyright © 2019 Luocheng. All rights reserved.
//
// 一个菜单栏吸顶列表的另一种实现思路例子

#import "ViewController.h"
#import "PageHeaderView.h"
#import "FirstPageView.h"
#import "SecondPageView.h"
#import "Header.h"

@interface ViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) PageHeaderView    *headerView;
@property (nonatomic, strong) FirstPageView     *firstPageView;
@property (nonatomic, strong) SecondPageView    *secondPageView;
@property (nonatomic, strong) UICollectionView  *collectionView;
@property (nonatomic, strong) UIScrollView      *touchScrollView;
@property (nonatomic, assign) BOOL              hasStickyMenu;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.headerView];
}

#pragma mark - <UICollectionViewDelegate, UICollectionViewDataSource>
- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return 2;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(collectionView.bounds.size.width, collectionView.bounds.size.height);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class]) forIndexPath:indexPath];
    cell.contentView.backgroundColor = kRandomColor;
    if (indexPath.item == 0) {
        [cell.contentView addSubview:self.firstPageView];
    } else {
        [cell.contentView addSubview:self.secondPageView];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath
{
    UIView *pageView = cell.contentView.subviews.firstObject;
    if (!pageView)return;
    UIScrollView *scrollView = [pageView viewWithTag:2019];
    if ([scrollView isKindOfClass:[UIScrollView class]]) {
        self.headerView.mainScrollView = scrollView;

        CGFloat headerViewY = self.headerView.frame.origin.y;
        CGFloat menuMinY = kHeaderHeight - kMenuKeight;
        if (headerViewY <= -menuMinY) {
            if (!self.hasStickyMenu) {
                self.hasStickyMenu = YES;
                [scrollView setContentOffset:CGPointMake(0, -kMenuKeight)];
            }
        } else if (self.touchScrollView) {
            self.hasStickyMenu = NO;
            [scrollView setContentOffset:CGPointMake(0, self.touchScrollView.contentOffset.y)];
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell
        forItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger page = collectionView.contentOffset.x / collectionView.bounds.size.width;
    if (page < [collectionView numberOfItemsInSection:0]) {
        /// 设置头部主ScrollView事件
        [self setupHeaderMainScrollView:page];
        
        /// 选中指定Menu菜单
        [self selectedPageMenu:page];
    }
}

- (void)setupHeaderMainScrollView:(NSInteger)page {
    NSIndexPath *path = [NSIndexPath indexPathForRow:page inSection:0];
    UICollectionViewCell *curCell = [self.collectionView cellForItemAtIndexPath:path];
    UIView *pageView = curCell.contentView.subviews.firstObject;
    if (!pageView)return;
    UIScrollView *scrollView = [pageView viewWithTag:2019];
    if ([scrollView isKindOfClass:[UIScrollView class]]) {
        self.headerView.mainScrollView = scrollView;
    }
}

- (void)selectedPageMenu:(NSInteger)page {
    NSLog(@"当前菜单栏===%ld", (long)page);
    NSArray *menuBtnArray = self.headerView.subviews;
    for (NSInteger i=0; i<menuBtnArray.count; i++) {
        UIButton *menuBtn = menuBtnArray[i];
        if (![menuBtn isKindOfClass:[UIButton class]]) continue;
        if (menuBtn.tag == page) {
            menuBtn.selected = YES;
        } else {
            menuBtn.selected = NO;
        }
    }
}

- (void)scrollToIndexPage:(NSInteger)index {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:(UICollectionViewScrollPositionLeft) animated:YES];
}

- (void(^)(UIScrollView *))listViewDidScroll {
    __weak ViewController *weakSelf = self;
    CGFloat menuMinY = kHeaderHeight - kMenuKeight;
    
    return ^(UIScrollView * scrollView) {
        self.touchScrollView = scrollView;
        
        CGFloat offsetY = scrollView.contentOffset.y;
        CGFloat toOffsetY = -(kHeaderHeight + offsetY);
        if (-toOffsetY > 0 && -toOffsetY > menuMinY) {
            toOffsetY = -menuMinY;
        }
        //NSLog(@"offsetY==%.2f",toOffsetY);
        weakSelf.headerView.frame = CGRectMake(0, toOffsetY, KScreenWidth, kHeaderHeight);
        
        scrollView.showsVerticalScrollIndicator = (toOffsetY <= -menuMinY);
        //scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(kMenuKeight, 0, 0, 0);
    };
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *_flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _flowLayout.minimumLineSpacing = 0;
        _flowLayout.minimumInteritemSpacing = 0;
        _flowLayout.sectionInset = UIEdgeInsetsZero;
        
        _collectionView = [[UICollectionView alloc]initWithFrame:self.view.bounds collectionViewLayout:_flowLayout];
        _collectionView.backgroundColor = [UIColor systemBlueColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.pagingEnabled = YES;
        _collectionView.bounces = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = YES;
        _collectionView.alwaysBounceHorizontal = NO;
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class])];
    }
    return _collectionView;
}

- (PageHeaderView *)headerView {
    if (!_headerView) {
        CGRect rect = CGRectMake(0, 0, KScreenWidth, kHeaderHeight);
        _headerView = [[PageHeaderView alloc] initWithFrame:rect];
        _headerView.backgroundColor = [UIColor systemPinkColor];
        _headerView.userInteractionEnabled = YES;
        
        __weak ViewController *weakSelf = self;
        _headerView.touchMenuBlock = ^(NSInteger index) {
            [weakSelf scrollToIndexPage:index];
        };
    }
    return _headerView;
}

- (FirstPageView *)firstPageView {
    if (!_firstPageView) {
        CGRect rect = CGRectMake(0, 0, KScreenWidth, KScreenHeight - kTopBarHeight);
        _firstPageView = [[FirstPageView alloc] initWithFrame:rect];
        _firstPageView.backgroundColor = [UIColor lightTextColor];
        _firstPageView.listViewDidScroll = self.listViewDidScroll;
    }
    return _firstPageView;
}

- (SecondPageView *)secondPageView {
    if (!_secondPageView) {
        _secondPageView = [[SecondPageView alloc] initWithFrame:self.firstPageView.bounds];
        _secondPageView.backgroundColor = [UIColor grayColor];
        _secondPageView.listViewDidScroll = self.listViewDidScroll;
    }
    return _secondPageView;
}

@end

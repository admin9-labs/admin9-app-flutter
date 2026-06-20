import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/navigation/app_navigator.dart';
import '../../../../core/theme/app_appearance.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_info_list_item.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/primary_pill_button.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../../../core/widgets/quick_action_grid.dart';
import '../../../../data/repositories/points_repository.dart';
import '../../../../domain/models/points.dart';
import '../../../shared/app_state_controller.dart';
import '../../mine/view_models/session_view_model.dart';
import '../../mine/views/auth_page.dart';

void openPointsPage(BuildContext context, Widget page) {
  final session = context.read<SessionViewModel>();
  if (!session.isLoggedIn) {
    showAppSnackBar(context, '登录后查看积分');
    AppNavigator.push(context, const AuthPage());
    return;
  }
  AppNavigator.push(context, page);
}

class PointsCenterPage extends StatelessWidget {
  const PointsCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = context.read<PointsRepository>();
    final state = context.watch<AppStateController>();
    final loggedIn = context.watch<SessionViewModel>().isLoggedIn;
    final recentTransactions = state.pointTransactions.take(3).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('我的积分')),
      body: ListView(
        padding: AppInsets.page,
        children: [
          PointsBalanceCard(
            key: const Key('points-center-balance-card'),
            loggedIn: loggedIn,
            showActions: false,
            onCheckIn: () => _checkIn(context),
            onDetails: () =>
                AppNavigator.push(context, const PointsLedgerPage()),
            onTasks: () => AppNavigator.push(context, const PointsTasksPage()),
            onMall: () => AppNavigator.push(context, const PointsMallPage()),
          ),
          const SizedBox(height: AppSpacing.cardGap),
          QuickActionSection(
            title: null,
            gridKey: const Key('quick-action-grid-points-center'),
            shrinkToItemCount: true,
            items: [
              QuickActionItem(
                icon: Icons.assignment_turned_in_outlined,
                label: '赚积分',
                onTap: () =>
                    AppNavigator.push(context, const PointsTasksPage()),
              ),
              QuickActionItem(
                icon: Icons.receipt_long_outlined,
                label: '积分明细',
                onTap: () =>
                    AppNavigator.push(context, const PointsLedgerPage()),
              ),
              QuickActionItem(
                icon: Icons.card_giftcard_outlined,
                label: '积分商城',
                onTap: () => AppNavigator.push(context, const PointsMallPage()),
              ),
              QuickActionItem(
                icon: Icons.confirmation_number_outlined,
                label: '兑换记录',
                onTap: () =>
                    AppNavigator.push(context, const PointsOrdersPage()),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.cardGap),
          AppSectionHeader(
            title: '快捷任务',
            actionLabel: '全部',
            onActionTap: () =>
                AppNavigator.push(context, const PointsTasksPage()),
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final task in repository.tasks.take(3))
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _taskCard(context, task),
            ),
          const SizedBox(height: AppSpacing.cardGap),
          AppSectionHeader(
            title: '最近明细',
            actionLabel: '查看',
            onActionTap: () =>
                AppNavigator.push(context, const PointsLedgerPage()),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (recentTransactions.isEmpty)
            const EmptyState(title: '暂无积分记录', compact: true)
          else
            for (final transaction in recentTransactions)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _transactionCard(context, transaction),
              ),
        ],
      ),
    );
  }

  void _checkIn(BuildContext context) {
    final success = context.read<AppStateController>().checkInForPoints();
    showAppSnackBar(context, success ? '签到成功，积分 +10' : '今日已签到');
  }
}

class PointsTasksPage extends StatelessWidget {
  const PointsTasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tasks = context.read<PointsRepository>().tasks;

    return Scaffold(
      appBar: AppBar(title: const Text('赚积分')),
      body: ListView.separated(
        padding: AppInsets.page,
        itemBuilder: (context, index) => _taskCard(context, tasks[index]),
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
        itemCount: tasks.length,
      ),
    );
  }
}

class PointsLedgerPage extends StatefulWidget {
  const PointsLedgerPage({super.key});

  @override
  State<PointsLedgerPage> createState() => _PointsLedgerPageState();
}

class _PointsLedgerPageState extends State<PointsLedgerPage> {
  PointTransactionKind? _kind;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateController>();
    final transactions = state.pointTransactions
        .where((item) => _kind == null || item.kind == _kind)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('积分明细')),
      body: ListView(
        padding: AppInsets.page,
        children: [
          _ExpiringNotice(points: state.expiringPoints),
          const SizedBox(height: AppSpacing.cardGap),
          _LedgerFilter(
            selected: _kind,
            onSelected: (kind) => setState(() => _kind = kind),
          ),
          const SizedBox(height: AppSpacing.cardGap),
          if (transactions.isEmpty)
            EmptyState(
              title: '暂无积分记录',
              message: '完成阅读、评论、签到等任务后会显示在这里',
              icon: Icons.receipt_long_outlined,
              action: PrimaryPillButton(
                label: '去赚积分',
                onPressed: () =>
                    AppNavigator.push(context, const PointsTasksPage()),
              ),
            )
          else
            for (final transaction in transactions)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _transactionCard(context, transaction),
              ),
        ],
      ),
    );
  }
}

class PointsMallPage extends StatefulWidget {
  const PointsMallPage({super.key});

  @override
  State<PointsMallPage> createState() => _PointsMallPageState();
}

class _PointsMallPageState extends State<PointsMallPage> {
  PointProductCategory? _category;

  @override
  Widget build(BuildContext context) {
    final products = context
        .read<PointsRepository>()
        .products
        .where((item) => _category == null || item.category == _category)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('积分商城'),
        actions: [
          TextButton(
            onPressed: () =>
                AppNavigator.push(context, const PointsOrdersPage()),
            child: const Text('兑换记录'),
          ),
        ],
      ),
      body: ListView(
        padding: AppInsets.page,
        children: [
          const _MallBalanceHeader(),
          const SizedBox(height: AppSpacing.cardGap),
          _ProductCategoryFilter(
            selected: _category,
            onSelected: (category) => setState(() => _category = category),
          ),
          const SizedBox(height: AppSpacing.cardGap),
          if (products.isEmpty)
            const EmptyState(
              title: '当前分类暂无权益',
              message: '换个分类看看',
              icon: Icons.card_giftcard_outlined,
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 520 ? 3 : 2;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: products.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    mainAxisSpacing: AppSpacing.md,
                    crossAxisSpacing: AppSpacing.md,
                    childAspectRatio: 0.64,
                  ),
                  itemBuilder: (context, index) =>
                      _ProductCard(product: products[index]),
                );
              },
            ),
        ],
      ),
    );
  }
}

class PointProductDetailPage extends StatelessWidget {
  const PointProductDetailPage({super.key, required this.product});

  final PointProduct product;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateController>();
    final blocker = state.canExchangeProduct(product);

    return Scaffold(
      appBar: AppBar(title: const Text('商品详情')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageX,
          AppSpacing.pageTop,
          AppSpacing.pageX,
          112,
        ),
        children: [
          _ProductHero(product: product, large: true),
          const SizedBox(height: AppSpacing.cardGap),
          Text(product.title, style: context.typography.heroTitle),
          const SizedBox(height: AppSpacing.sm),
          Text(product.description, style: context.typography.feedSummary),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Text(
                '${product.pointsPrice} 积分',
                style: context.typography.sectionTitle.copyWith(
                  color: context.tokens.warning,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              StatusPill(
                label: product.inStock ? '库存 ${product.stock}' : '已兑完',
                color: product.inStock
                    ? context.tokens.success.withValues(alpha: 0.14)
                    : context.tokens.textTertiary.withValues(alpha: 0.14),
                foregroundColor: product.inStock
                    ? context.tokens.success
                    : context.tokens.textTertiary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.cardGap),
          _InfoCard(title: '兑换说明', lines: [product.exchangeNote]),
          const SizedBox(height: AppSpacing.cardGap),
          _InfoCard(title: '使用规则', lines: product.rules),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageX,
            AppSpacing.sm,
            AppSpacing.pageX,
            AppSpacing.lg,
          ),
          child: PrimaryPillButton(
            key: const Key('point-product-exchange'),
            label: blocker ?? '立即兑换',
            onPressed: blocker == null
                ? () => AppNavigator.push(
                    context,
                    PointExchangeConfirmPage(product: product),
                  )
                : () => _showProductBlocker(context, blocker),
          ),
        ),
      ),
    );
  }
}

class PointExchangeConfirmPage extends StatelessWidget {
  const PointExchangeConfirmPage({super.key, required this.product});

  final PointProduct product;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateController>();
    final user = context.watch<SessionViewModel>().user;
    final blocker = state.canExchangeProduct(product);

    return Scaffold(
      appBar: AppBar(title: const Text('确认兑换')),
      body: ListView(
        padding: AppInsets.page,
        children: [
          AppCard(
            child: Row(
              children: [
                SizedBox(
                  width: 92,
                  height: 92,
                  child: _ProductHero(product: product),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.title,
                        style: context.typography.feedTitleCompact,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        product.description,
                        style: context.typography.feedMeta,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        '${product.pointsPrice} 积分',
                        style: context.typography.label.copyWith(
                          color: context.tokens.warning,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.cardGap),
          _InfoCard(
            title: '领取信息',
            lines: ['手机号：${user?.maskedPhone ?? '未登录'}', product.exchangeNote],
          ),
          const SizedBox(height: AppSpacing.cardGap),
          _InfoCard(
            title: '积分抵扣',
            lines: [
              '当前可用积分：${state.pointsBalance}',
              '本次将消耗：${product.pointsPrice}',
            ],
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageX,
            AppSpacing.sm,
            AppSpacing.pageX,
            AppSpacing.lg,
          ),
          child: PrimaryPillButton(
            key: const Key('confirm-point-exchange'),
            label: blocker ?? '确认兑换',
            onPressed: blocker == null
                ? () {
                    final order = context
                        .read<AppStateController>()
                        .exchangeProduct(product);
                    if (order == null) {
                      showAppSnackBar(context, '兑换失败，请稍后重试');
                      return;
                    }
                    AppNavigator.push(
                      context,
                      PointExchangeSuccessPage(order: order),
                    );
                  }
                : () => _showProductBlocker(context, blocker),
          ),
        ),
      ),
    );
  }
}

class PointExchangeSuccessPage extends StatelessWidget {
  const PointExchangeSuccessPage({super.key, required this.order});

  final PointExchangeOrder order;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('兑换成功')),
      body: ListView(
        padding: AppInsets.page,
        children: [
          AppCard(
            child: Column(
              children: [
                Icon(
                  Icons.check_circle,
                  color: context.tokens.success,
                  size: 58,
                ),
                const SizedBox(height: AppSpacing.md),
                Text('兑换成功', style: context.typography.pageTitle),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '权益码 ${order.code}',
                  style: context.typography.feedSummary,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.cardGap),
          PrimaryPillButton(
            label: '查看兑换记录',
            onPressed: () =>
                AppNavigator.push(context, const PointsOrdersPage()),
          ),
          const SizedBox(height: AppSpacing.sm),
          PrimaryPillButton(
            label: '继续逛逛',
            variant: AppButtonVariant.secondary,
            onPressed: () => AppNavigator.push(context, const PointsMallPage()),
          ),
        ],
      ),
    );
  }
}

class PointsOrdersPage extends StatefulWidget {
  const PointsOrdersPage({super.key});

  @override
  State<PointsOrdersPage> createState() => _PointsOrdersPageState();
}

class _PointsOrdersPageState extends State<PointsOrdersPage> {
  PointOrderStatus? _status;

  @override
  Widget build(BuildContext context) {
    final orders = context
        .watch<AppStateController>()
        .pointOrders
        .where((order) => _status == null || order.status == _status)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('兑换记录')),
      body: ListView(
        padding: AppInsets.page,
        children: [
          _OrderFilter(
            selected: _status,
            onSelected: (status) => setState(() => _status = status),
          ),
          const SizedBox(height: AppSpacing.cardGap),
          if (orders.isEmpty)
            EmptyState(
              title: '暂无兑换记录',
              message: '兑换后的权益会显示在这里',
              icon: Icons.confirmation_number_outlined,
              action: PrimaryPillButton(
                label: '去积分商城看看',
                onPressed: () =>
                    AppNavigator.push(context, const PointsMallPage()),
              ),
            )
          else
            for (final order in orders)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _OrderCard(order: order),
              ),
        ],
      ),
    );
  }
}

class PointOrderDetailPage extends StatelessWidget {
  const PointOrderDetailPage({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    final order = context
        .watch<AppStateController>()
        .pointOrders
        .where((item) => item.id == orderId)
        .firstOrNull;

    if (order == null) {
      return const Scaffold(body: EmptyState(title: '兑换记录不存在'));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('兑换详情')),
      body: ListView(
        padding: AppInsets.page,
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        order.product.title,
                        style: context.typography.sectionTitle,
                      ),
                    ),
                    _OrderStatusPill(status: order.status),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text('权益码', style: context.typography.feedMeta),
                const SizedBox(height: AppSpacing.xs),
                SelectableText(
                  order.code,
                  style: context.typography.pageTitle.copyWith(
                    color: context.tokens.brand.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text('兑换时间：${order.time}', style: context.typography.feedMeta),
                if (order.usedTime != null)
                  Text(
                    '核销时间：${order.usedTime}',
                    style: context.typography.feedMeta,
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.cardGap),
          _InfoCard(title: '使用规则', lines: order.product.rules),
          const SizedBox(height: AppSpacing.cardGap),
          PrimaryPillButton(
            key: const Key('simulate-point-order-use'),
            label: order.status == PointOrderStatus.pendingUse ? '模拟核销' : '已核销',
            onPressed: order.status == PointOrderStatus.pendingUse
                ? () {
                    context.read<AppStateController>().markPointOrderUsed(
                      order.id,
                    );
                    showAppSnackBar(context, '已模拟核销');
                  }
                : null,
          ),
        ],
      ),
    );
  }
}

class PointsBalanceCard extends StatelessWidget {
  const PointsBalanceCard({
    super.key,
    required this.onCheckIn,
    required this.onDetails,
    required this.onTasks,
    required this.onMall,
    this.loggedIn = true,
    this.showActions = true,
  });

  final VoidCallback onCheckIn;
  final VoidCallback onDetails;
  final VoidCallback onTasks;
  final VoidCallback onMall;
  final bool loggedIn;
  final bool showActions;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateController>();
    final tokens = context.tokens;

    return AppCard(
      key: const Key('mine-points-card'),
      backgroundColor: tokens.warning.withValues(alpha: 0.1),
      borderColor: tokens.warning.withValues(alpha: 0.22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('我的积分', style: context.typography.feedMeta),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      loggedIn ? '${state.pointsBalance}' : '--',
                      style: context.typography.pageTitle.copyWith(
                        color: tokens.warning,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      loggedIn
                          ? '${state.pointsLevel} · 连续签到 ${state.checkInStreak} 天'
                          : '登录后查看积分权益',
                      style: context.typography.feedMeta,
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 116,
                child: PrimaryPillButton(
                  key: const Key('points-checkin-button'),
                  label: loggedIn
                      ? (state.checkedInToday ? '今日已签到' : '签到 +10')
                      : '去登录',
                  onPressed: loggedIn && state.checkedInToday
                      ? null
                      : onCheckIn,
                ),
              ),
            ],
          ),
          if (showActions) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                _InlineLink(label: '积分明细', onTap: onDetails),
                _InlineLink(label: '赚积分', onTap: onTasks),
                _InlineLink(label: '积分商城', onTap: onMall),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

Widget _taskCard(BuildContext context, PointTask task) {
  final state = context.watch<AppStateController>();
  final claimed = state.isPointTaskClaimed(task.id);
  final pending = state.isPointTaskPending(task.id);
  final checkedIn = task.id == 'daily-checkin' && state.checkedInToday;
  final done = claimed || checkedIn;
  final label = done ? '已领取' : (pending || task.daily ? '领取' : '去完成');

  return AppInfoListCard(
    key: Key('point-task-${task.id}'),
    icon: _taskIcon(task.iconKey),
    title: task.title,
    subtitle: task.description,
    showChevron: false,
    trailing: Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '+${task.points}',
          style: context.typography.label.copyWith(
            color: context.tokens.warning,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        SizedBox(
          width: 84,
          child: PrimaryPillButton(
            label: label,
            onPressed: done
                ? null
                : () {
                    if (!pending && !task.daily) {
                      context.read<AppStateController>().markPointTaskReady(
                        task.id,
                      );
                      showAppSnackBar(context, '任务已完成，可领取积分');
                      return;
                    }
                    final success = context
                        .read<AppStateController>()
                        .claimPointTask(task);
                    showAppSnackBar(
                      context,
                      success ? '${task.title}，积分 +${task.points}' : '积分已领取',
                    );
                  },
          ),
        ),
      ],
    ),
  );
}

Widget _transactionCard(BuildContext context, PointTransaction transaction) {
  final positive = transaction.points >= 0;
  return AppInfoListCard(
    icon: positive ? Icons.add_circle_outline : Icons.remove_circle_outline,
    iconColor: positive ? context.tokens.success : context.tokens.warning,
    title: transaction.title,
    subtitle: transaction.kind.label,
    meta: transaction.time,
    showChevron: false,
    trailing: Text(
      '${positive ? '+' : ''}${transaction.points}',
      style: context.typography.sectionTitle.copyWith(
        color: positive ? context.tokens.success : context.tokens.warning,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});

  final PointProduct product;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateController>();
    final blocker = state.canExchangeProduct(product);
    final disabled = !product.inStock;

    return AppCard(
      key: Key('point-product-${product.id}'),
      padding: EdgeInsets.zero,
      enabled: !disabled,
      onTap: () =>
          AppNavigator.push(context, PointProductDetailPage(product: product)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(aspectRatio: 1.15, child: _ProductHero(product: product)),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.typography.feedTitleCompact,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  product.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.typography.feedMeta,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${product.pointsPrice} 积分',
                  style: context.typography.label.copyWith(
                    color: context.tokens.warning,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  blocker ?? '立即兑换',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.typography.label.copyWith(
                    color: blocker == null
                        ? context.tokens.brand.primary
                        : context.tokens.textTertiary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final PointExchangeOrder order;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      key: Key('point-order-${order.id}'),
      onTap: () =>
          AppNavigator.push(context, PointOrderDetailPage(orderId: order.id)),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: _ProductHero(product: order.product),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.product.title,
                  style: context.typography.feedTitleCompact,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${order.product.pointsPrice} 积分 · ${order.time}',
                  style: context.typography.feedMeta,
                ),
              ],
            ),
          ),
          _OrderStatusPill(status: order.status),
        ],
      ),
    );
  }
}

class _ProductHero extends StatelessWidget {
  const _ProductHero({required this.product, this.large = false});

  final PointProduct product;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final color = _productColor(context, product.coverKey);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(
              _productIcon(product.coverKey),
              color: color,
              size: large ? 88 : 42,
            ),
          ),
          if (product.badge != null)
            Positioned(
              top: AppSpacing.sm,
              left: AppSpacing.sm,
              child: StatusPill(
                label: product.badge!,
                color: context.tokens.warning.withValues(alpha: 0.18),
                foregroundColor: context.tokens.warning,
              ),
            ),
        ],
      ),
    );
  }
}

class _InlineLink extends StatelessWidget {
  const _InlineLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextButton(onPressed: onTap, child: Text(label)),
    );
  }
}

class _MallBalanceHeader extends StatelessWidget {
  const _MallBalanceHeader();

  @override
  Widget build(BuildContext context) {
    final balance = context.watch<AppStateController>().pointsBalance;
    return AppInfoListCard(
      icon: Icons.account_balance_wallet_outlined,
      title: '可用积分',
      showChevron: false,
      trailing: Text(
        '$balance',
        style: context.typography.sectionTitle.copyWith(
          color: context.tokens.warning,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ExpiringNotice extends StatelessWidget {
  const _ExpiringNotice({required this.points});

  final int points;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      backgroundColor: context.tokens.warning.withValues(alpha: 0.1),
      borderColor: context.tokens.warning.withValues(alpha: 0.2),
      child: Row(
        children: [
          Icon(Icons.schedule_outlined, color: context.tokens.warning),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              '本月将有 $points 积分过期',
              style: context.typography.feedMeta,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.lines});

  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: context.typography.sectionTitle),
          const SizedBox(height: AppSpacing.sm),
          for (final line in lines)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Text(line, style: context.typography.feedSummary),
            ),
        ],
      ),
    );
  }
}

class _LedgerFilter extends StatelessWidget {
  const _LedgerFilter({required this.selected, required this.onSelected});

  final PointTransactionKind? selected;
  final ValueChanged<PointTransactionKind?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SegmentedButton<PointTransactionKind?>(
        segments: [
          const ButtonSegment(value: null, label: Text('全部')),
          for (final kind in PointTransactionKind.values)
            ButtonSegment(value: kind, label: Text(kind.label)),
        ],
        selected: {selected},
        onSelectionChanged: (values) => onSelected(values.first),
      ),
    );
  }
}

class _ProductCategoryFilter extends StatelessWidget {
  const _ProductCategoryFilter({
    required this.selected,
    required this.onSelected,
  });

  final PointProductCategory? selected;
  final ValueChanged<PointProductCategory?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SegmentedButton<PointProductCategory?>(
        segments: [
          const ButtonSegment(value: null, label: Text('全部')),
          for (final category in PointProductCategory.values)
            ButtonSegment(value: category, label: Text(category.label)),
        ],
        selected: {selected},
        onSelectionChanged: (values) => onSelected(values.first),
      ),
    );
  }
}

class _OrderFilter extends StatelessWidget {
  const _OrderFilter({required this.selected, required this.onSelected});

  final PointOrderStatus? selected;
  final ValueChanged<PointOrderStatus?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SegmentedButton<PointOrderStatus?>(
        segments: [
          const ButtonSegment(value: null, label: Text('全部')),
          for (final status in PointOrderStatus.values)
            ButtonSegment(value: status, label: Text(status.label)),
        ],
        selected: {selected},
        onSelectionChanged: (values) => onSelected(values.first),
      ),
    );
  }
}

class _OrderStatusPill extends StatelessWidget {
  const _OrderStatusPill({required this.status});

  final PointOrderStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      PointOrderStatus.pendingUse => context.tokens.info,
      PointOrderStatus.used => context.tokens.success,
      PointOrderStatus.expired => context.tokens.textTertiary,
      PointOrderStatus.canceled => context.tokens.danger,
    };
    return StatusPill(
      label: status.label,
      color: color.withValues(alpha: 0.12),
      foregroundColor: color,
    );
  }
}

IconData _taskIcon(String key) {
  return switch (key) {
    'checkin' => Icons.today_outlined,
    'read' => Icons.article_outlined,
    'favorite' => Icons.star_border,
    'comment' => Icons.mode_comment_outlined,
    'live' => Icons.play_circle_outline,
    'report' => Icons.campaign_outlined,
    'service' => Icons.assignment_outlined,
    _ => Icons.task_alt_outlined,
  };
}

IconData _productIcon(String key) {
  return switch (key) {
    'coffee' => Icons.local_cafe_outlined,
    'bus' => Icons.directions_bus_outlined,
    'movie' => Icons.local_movies_outlined,
    'bag' => Icons.shopping_bag_outlined,
    'library' => Icons.local_library_outlined,
    'festival' => Icons.festival_outlined,
    _ => Icons.card_giftcard_outlined,
  };
}

Color _productColor(BuildContext context, String key) {
  final tokens = context.tokens;
  return switch (key) {
    'coffee' || 'bag' => tokens.warning,
    'bus' || 'library' => tokens.success,
    'movie' || 'festival' => tokens.info,
    _ => tokens.brand.primary,
  };
}

void _showProductBlocker(BuildContext context, String blocker) {
  if (blocker.startsWith('还差')) {
    showAppSnackBar(context, '积分不够，$blocker，可先去完成任务');
    return;
  }
  showAppSnackBar(context, blocker);
}

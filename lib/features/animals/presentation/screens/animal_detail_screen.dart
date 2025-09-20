import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../../data/models/animal.dart';
import '../../../../data/repositories/animal_repository.dart';
import '../../../../data/repositories/breeding_repository.dart';
import '../../../../data/repositories/event_repository.dart';
import '../../domain/genealogy_analyzer.dart';
import '../cubit/animal_detail_cubit.dart';
import '../widgets/animal_performance_overview.dart';
import '../widgets/animal_photo_gallery.dart';
import '../widgets/animal_timeline.dart';
import '../widgets/genealogy_view.dart';

class AnimalDetailScreen extends StatelessWidget {
  const AnimalDetailScreen({
    required this.animal,
    super.key,
  });

  final Animal animal;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AnimalDetailCubit>(
      create: (BuildContext context) => AnimalDetailCubit(
        animal,
        InMemoryAnimalRepository(),
        InMemoryBreedingRepository(),
        InMemoryEventRepository(),
      )..load(),
      child: const _AnimalDetailView(),
    );
  }
}

class _AnimalDetailView extends StatelessWidget {
  const _AnimalDetailView();

  Future<void> _addPhoto(BuildContext context) async {
    final TextEditingController controller = TextEditingController();
    final String? url = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ajouter une photo'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'URL de l’image',
            ),
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop(controller.text.trim()),
              child: const Text('Ajouter'),
            ),
          ],
        );
      },
    );

    if (!context.mounted) {
      return;
    }

    if (url != null && url.isNotEmpty) {
      context.read<AnimalDetailCubit>().addPhoto(url);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Photo ajoutée.')),
      );
    }
  }

  void _removePhoto(BuildContext context, String url) {
    context.read<AnimalDetailCubit>().removePhoto(url);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Photo retirée.')),
    );
  }

  Future<void> _exportPdf(
    BuildContext context,
    AnimalDetailState state,
  ) async {
    final Animal animal = state.animal;
    final pw.Document doc = pw.Document();
    final String filename = 'animal-${animal.tagId}.pdf';

    String formatDate(DateTime date) =>
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

    final pw.Widget identitySection = pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        pw.Text('Identité', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Text('Tag : ${animal.tagId}'),
        if (animal.name != null) pw.Text('Nom : ${animal.name}'),
        pw.Text('Sexe : ${animal.sex}'),
        pw.Text('Statut : ${animal.status}'),
        pw.Text('Naissance : ${formatDate(animal.birthDate)}'),
        if (animal.origin != null) pw.Text('Origine : ${animal.origin}'),
        if (animal.cageNumber != null) pw.Text('Cage : ${animal.cageNumber}'),
      ],
    );

    final AnimalPerformanceStats? performance = state.performance;
    final pw.Widget? performanceSection = performance == null
        ? null
        : pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: <pw.Widget>[
              pw.Text('Performances',
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Text('Saillies : ${performance.totalMatings}'),
              pw.Text('Réussites : ${performance.successfulMatings}'),
              if (performance.successRate != null)
                pw.Text(
                    'Taux de réussite : ${(performance.successRate! * 100).toStringAsFixed(1)} %'),
              if (performance.averageKitsBornAlive != null)
                pw.Text(
                    'Nés vivants moyens : ${performance.averageKitsBornAlive!.toStringAsFixed(1)}'),
              if (performance.averageKitsWeaned != null)
                pw.Text(
                    'Sevrés moyens : ${performance.averageKitsWeaned!.toStringAsFixed(1)}'),
              pw.Text('Sevrés cumulés : ${performance.totalKitsWeaned}'),
            ],
          );

    final GenealogyAnalysis? genealogy = state.genealogy;
    String generationLabel(int index) {
      if (genealogy == null || index >= genealogy.generations.length) {
        return '';
      }
      final List<Animal?> ancestors = genealogy.generations[index];
      final String joined = ancestors
          .map((Animal? ancestor) => ancestor == null ? 'Inconnu' : ancestor.tagId)
          .join(', ');
      return 'Génération $index : $joined';
    }
    final pw.Widget? genealogySection = genealogy == null
        ? null
        : pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: <pw.Widget>[
              pw.Text('Généalogie',
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              if (genealogy.inbreedingCoefficient != null)
                pw.Text(
                  'Coefficient d’endogamie : ${genealogy.inbreedingCoefficient!.toStringAsFixed(3)}',
                ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: <pw.Widget>[
                  for (int i = 1; i < genealogy.generations.length; i++)
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 2),
                      child: pw.Text(generationLabel(i)),
                    ),
                ],
              ),
            ],
          );

    final pw.Widget timelineSection = pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        pw.Text('Chronologie',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        if (state.timeline.isEmpty)
          pw.Text('Aucun évènement enregistré.')
        else
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: <pw.Widget>[
              for (final AnimalTimelineEntry entry in state.timeline.take(20))
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 2),
                  child: pw.Text(
                    '${formatDate(entry.date)} · ${entry.title}${entry.description != null ? ' — ${entry.description}' : ''}',
                  ),
                ),
            ],
          ),
      ],
    );

    doc.addPage(
      pw.MultiPage(
        build: (pw.Context context) => <pw.Widget>[
          pw.Header(level: 0, child: pw.Text('Fiche ${animal.tagId}')), 
          identitySection,
          pw.SizedBox(height: 12),
          if (performanceSection != null) ...<pw.Widget>[performanceSection, pw.SizedBox(height: 12)],
          if (genealogySection != null) ...<pw.Widget>[genealogySection, pw.SizedBox(height: 12)],
          timelineSection,
        ],
      ),
    );

    await Printing.sharePdf(bytes: await doc.save(), filename: filename);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AnimalDetailCubit, AnimalDetailState>(
      builder: (BuildContext context, AnimalDetailState state) {
        final Animal animal = state.animal;
        switch (state.status) {
          case AnimalDetailStatus.initial:
          case AnimalDetailStatus.loading:
            return Scaffold(
              appBar: AppBar(
                title: Text(animal.name ?? animal.tagId),
              ),
              body: const Center(child: CircularProgressIndicator()),
            );
          case AnimalDetailStatus.failure:
            return Scaffold(
              appBar: AppBar(
                title: Text(animal.name ?? animal.tagId),
              ),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        state.errorMessage ??
                            'Impossible de charger la fiche détaillée.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () =>
                            context.read<AnimalDetailCubit>().load(),
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          case AnimalDetailStatus.success:
            return DefaultTabController(
              length: 5,
              child: Scaffold(
                appBar: AppBar(
                  title: Text(animal.name ?? animal.tagId),
                  actions: <Widget>[
                    IconButton(
                      icon: const Icon(Icons.picture_as_pdf_outlined),
                      tooltip: 'Exporter en PDF',
                      onPressed: () => _exportPdf(context, state),
                    ),
                  ],
                  bottom: const TabBar(
                    isScrollable: true,
                    tabs: <Widget>[
                      Tab(text: 'Synthèse'),
                      Tab(text: 'Reproduction'),
                      Tab(text: 'Santé'),
                      Tab(text: 'Généalogie'),
                      Tab(text: 'Galerie'),
                    ],
                  ),
                ),
                body: TabBarView(
                  children: <Widget>[
                    _buildSummaryTab(context, state),
                    _buildReproductionTab(context, state),
                    _buildHealthTab(context, state),
                    _buildGenealogyTab(context, state),
                    _buildGalleryTab(context, state),
                  ],
                ),
              ),
            );
        }
      },
    );
  }

  Widget _buildSummaryTab(
    BuildContext context,
    AnimalDetailState state,
  ) {
    final List<AnimalTimelineEntry> generalTimeline = _filterTimeline(
      state.timeline,
      const <AnimalTimelineCategory>{
        AnimalTimelineCategory.birth,
        AnimalTimelineCategory.housing,
        AnimalTimelineCategory.general,
      },
    );
    final List<Widget> sections = <Widget>[
      _IdentityCard(
        animal: state.animal,
        primaryPhoto: state.gallery.isNotEmpty ? state.gallery.first : null,
      ),
      AnimalTimeline(
        entries: generalTimeline,
        title: 'Historique général',
        emptyMessage: 'Aucun événement général enregistré.',
      ),
    ];
    return _buildTabContent(context, sections);
  }

  Widget _buildReproductionTab(
    BuildContext context,
    AnimalDetailState state,
  ) {
    final List<AnimalTimelineEntry> reproductionTimeline = _filterTimeline(
      state.timeline,
      const <AnimalTimelineCategory>{AnimalTimelineCategory.breeding},
    );
    final List<Widget> sections = <Widget>[
      if (state.performance != null)
        AnimalPerformanceOverview(performance: state.performance!),
      _LitterHistoryCard(entries: state.litterStats),
      AnimalTimeline(
        entries: reproductionTimeline,
        title: 'Chronologie de reproduction',
        emptyMessage: 'Aucune saillie enregistrée pour le moment.',
      ),
    ];
    return _buildTabContent(context, sections);
  }

  Widget _buildHealthTab(
    BuildContext context,
    AnimalDetailState state,
  ) {
    final List<AnimalTimelineEntry> healthTimeline = _filterTimeline(
      state.timeline,
      const <AnimalTimelineCategory>{
        AnimalTimelineCategory.health,
        AnimalTimelineCategory.weight,
      },
    );
    final List<Widget> sections = <Widget>[
      _WeightHistoryCard(entries: state.weightHistory),
      AnimalTimeline(
        entries: healthTimeline,
        title: 'Suivi santé',
        emptyMessage: 'Aucun soin enregistré pour cet animal.',
      ),
    ];
    return _buildTabContent(context, sections);
  }

  Widget _buildGenealogyTab(
    BuildContext context,
    AnimalDetailState state,
  ) {
    final List<Widget> sections = <Widget>[
      GenealogyView(
        animal: state.animal,
        analysis: state.genealogy,
      ),
    ];
    return _buildTabContent(context, sections);
  }

  Widget _buildGalleryTab(
    BuildContext context,
    AnimalDetailState state,
  ) {
    final List<Widget> sections = <Widget>[
      AnimalPhotoGallery(
        photos: state.gallery,
        onAddPhoto: () => _addPhoto(context),
        onRemovePhoto: state.gallery.isEmpty
            ? null
            : (String url) => _removePhoto(context, url),
      ),
    ];
    return _buildTabContent(context, sections);
  }

  Widget _buildTabContent(
    BuildContext context,
    List<Widget> sections,
  ) {
    return RefreshIndicator(
      onRefresh: () => context.read<AnimalDetailCubit>().load(),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        itemCount: sections.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (BuildContext context, int index) => sections[index],
      ),
    );
  }

  List<AnimalTimelineEntry> _filterTimeline(
    List<AnimalTimelineEntry> entries,
    Set<AnimalTimelineCategory> categories,
  ) {
    return entries
        .where((AnimalTimelineEntry entry) => categories.contains(entry.category))
        .toList();
  }
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({
    required this.animal,
    this.primaryPhoto,
  });

  final Animal animal;
  final String? primaryPhoto;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (primaryPhoto != null)
            SizedBox(
              height: 180,
              width: double.infinity,
              child: Image.network(
                primaryPhoto!,
                fit: BoxFit.cover,
                errorBuilder: (BuildContext context, Object error,
                    StackTrace? stackTrace) {
                  return Container(
                    color: theme.colorScheme.surfaceContainerHighest,
                    alignment: Alignment.center,
                    child: const Icon(Icons.image_not_supported_outlined),
                  );
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Identité', style: theme.textTheme.titleLarge),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    Chip(label: Text(animal.sex)),
                    Chip(label: Text(animal.status)),
                  ],
                ),
                const SizedBox(height: 12),
                _InfoRow(label: 'Tag', value: animal.tagId),
                if (animal.name != null)
                  _InfoRow(label: 'Nom', value: animal.name!),
                _InfoRow(
                  label: 'Cage',
                  value: animal.cageNumber ?? 'Non renseignée',
                ),
                _InfoRow(
                  label: 'Origine',
                  value: animal.origin ?? 'Non renseignée',
                ),
                _InfoRow(
                  label: 'Date de naissance',
                  value: MaterialLocalizations.of(context)
                      .formatMediumDate(animal.birthDate),
                ),
                _InfoRow(
                  label: 'Date d’entrée',
                  value: animal.entryDate != null
                      ? MaterialLocalizations.of(context)
                          .formatMediumDate(animal.entryDate!)
                      : 'Non renseignée',
                ),
                if (animal.firstBreedingDate != null)
                  _InfoRow(
                    label: '1ère saillie',
                    value: _formatFirstBreedingLabel(context, animal),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatFirstBreedingLabel(BuildContext context, Animal animal) {
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);
    final String date = localizations.formatMediumDate(animal.firstBreedingDate!);
    final int ageInDays =
        animal.firstBreedingDate!.difference(animal.birthDate).inDays;
    return '$date · $ageInDays jours';
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(label, style: theme.textTheme.bodyMedium),
          Text(value, style: theme.textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _WeightHistoryCard extends StatelessWidget {
  const _WeightHistoryCard({required this.entries});

  final List<AnimalWeightEntry> entries;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);

    if (entries.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Évolution du poids', style: theme.textTheme.titleLarge),
              const SizedBox(height: 12),
              Text(
                'Aucune pesée enregistrée pour le moment.',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    final List<FlSpot> spots = <FlSpot>[
      for (int i = 0; i < entries.length; i++)
        FlSpot(i.toDouble(), entries[i].weightKg),
    ];

    final double minWeight = entries
        .map((AnimalWeightEntry entry) => entry.weightKg)
        .reduce(math.min);
    final double maxWeight = entries
        .map((AnimalWeightEntry entry) => entry.weightKg)
        .reduce(math.max);
    final double range = maxWeight - minWeight;
    final double padding = range == 0 ? math.max(0.2, maxWeight * 0.1) : range * 0.25;
    final double minY = math.max(0, minWeight - padding);
    final double maxY = maxWeight + padding;
    final double rawInterval = (maxY - minY) / 4;
    final double interval = rawInterval > 0 ? rawInterval : 0.5;
    final int step = math.max(1, (entries.length / 4).ceil());
    final TextStyle tooltipStyle =
        (theme.textTheme.bodyMedium ?? const TextStyle(fontSize: 12))
            .copyWith(
      color: theme.colorScheme.onPrimary,
      fontWeight: FontWeight.w600,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Évolution du poids', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: (entries.length - 1).toDouble(),
                  minY: minY,
                  maxY: maxY,
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    drawVerticalLine: false,
                    horizontalInterval: interval,
                    getDrawingHorizontalLine: (double value) {
                      return FlLine(
                        color: theme.colorScheme.outlineVariant,
                        strokeWidth: 1,
                        dashArray: const <double>[4, 4],
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 44,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          return Text(
                            value.toStringAsFixed(1),
                            style: theme.textTheme.bodySmall,
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        reservedSize: 40,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final int index = value.round();
                          if (index < 0 || index >= entries.length) {
                            return const SizedBox.shrink();
                          }
                          if (index != 0 &&
                              index != entries.length - 1 &&
                              index % step != 0) {
                            return const SizedBox.shrink();
                          }
                          final DateTime date = entries[index].date;
                          final String label = entries.length > 6
                              ? localizations.formatShortDate(date)
                              : localizations.formatMediumDate(date);
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              label,
                              style: theme.textTheme.bodySmall,
                              textAlign: TextAlign.center,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      tooltipBgColor: theme.colorScheme.primary,
                      getTooltipItems:
                          (List<LineBarSpot> touchedSpots) {
                        return touchedSpots.map((LineBarSpot spot) {
                          final int index =
                              spot.x.round().clamp(0, entries.length - 1);
                          final AnimalWeightEntry entry = entries[index];
                          final String date =
                              localizations.formatShortDate(entry.date);
                          return LineTooltipItem(
                            '$date\n${spot.y.toStringAsFixed(2)} kg',
                            tooltipStyle,
                          );
                        }).toList();
                      },
                    ),
                  ),
                  lineBarsData: <LineChartBarData>[
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      barWidth: 3,
                      color: theme.colorScheme.primary,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (
                          FlSpot spot,
                          double percent,
                          LineChartBarData bar,
                          int index,
                        ) {
                          return FlDotCirclePainter(
                            radius: 3.5,
                            color: theme.colorScheme.primary,
                            strokeColor: theme.colorScheme.onPrimary,
                            strokeWidth: 1,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: <Color>[
                            theme.colorScheme.primary.withOpacity(0.18),
                            theme.colorScheme.primary.withOpacity(0.02),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LitterHistoryCard extends StatelessWidget {
  const _LitterHistoryCard({required this.entries});

  final List<AnimalLitterStat> entries;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);

    final bool hasValues = entries.any(
      (AnimalLitterStat stat) =>
          stat.kitsBornAlive != null || stat.kitsWeaned != null,
    );

    if (!hasValues) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Historique des portées', style: theme.textTheme.titleLarge),
              const SizedBox(height: 12),
              Text(
                'Aucune portée enregistrée pour cet animal.',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    final Color bornColor = theme.colorScheme.primary;
    final Color weanedColor = theme.colorScheme.tertiary;

    final List<BarChartGroupData> groups = <BarChartGroupData>[
      for (int i = 0; i < entries.length; i++)
        BarChartGroupData(
          x: i,
          barsSpace: 8,
          barRods: <BarChartRodData>[
            BarChartRodData(
              toY: (entries[i].kitsBornAlive ?? 0).toDouble(),
              color: bornColor,
              width: 12,
              borderRadius: BorderRadius.circular(6),
            ),
            BarChartRodData(
              toY: (entries[i].kitsWeaned ?? 0).toDouble(),
              color: weanedColor,
              width: 12,
              borderRadius: BorderRadius.circular(6),
            ),
          ],
        ),
    ];

    final int maxValue = entries.fold<int>(
      0,
      (int previous, AnimalLitterStat stat) => math.max(
        previous,
        math.max(stat.kitsBornAlive ?? 0, stat.kitsWeaned ?? 0),
      ),
    );
    final double maxY = math.max(5, maxValue + 2).toDouble();
    final int step = math.max(1, (entries.length / 4).ceil());
    final TextStyle tooltipStyle =
        (theme.textTheme.bodyMedium ?? const TextStyle(fontSize: 12))
            .copyWith(
      color: theme.colorScheme.onPrimary,
      fontWeight: FontWeight.w600,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Historique des portées', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            SizedBox(
              height: 240,
              child: BarChart(
                BarChartData(
                  maxY: maxY,
                  minY: 0,
                  gridData: FlGridData(
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (double value) {
                      return FlLine(
                        color: theme.colorScheme.outlineVariant,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          if (value % 1 != 0) {
                            return const SizedBox.shrink();
                          }
                          return Text(
                            value.toStringAsFixed(0),
                            style: theme.textTheme.bodySmall,
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        reservedSize: 40,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final int index = value.round();
                          if (index < 0 || index >= entries.length) {
                            return const SizedBox.shrink();
                          }
                          if (index != 0 &&
                              index != entries.length - 1 &&
                              index % step != 0) {
                            return const SizedBox.shrink();
                          }
                          final DateTime date = entries[index].date;
                          final String label = entries.length > 6
                              ? localizations.formatShortDate(date)
                              : localizations.formatMediumDate(date);
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              label,
                              style: theme.textTheme.bodySmall,
                              textAlign: TextAlign.center,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: theme.colorScheme.primary,
                      getTooltipItem: (
                        BarChartGroupData group,
                        int groupIndex,
                        BarChartRodData rod,
                        int rodIndex,
                      ) {
                        final AnimalLitterStat stat = entries[groupIndex];
                        final String category =
                            rodIndex == 0 ? 'Nés vivants' : 'Sevrés';
                        final int? rawValue =
                            rodIndex == 0 ? stat.kitsBornAlive : stat.kitsWeaned;
                        final String valueLabel = rawValue?.toString() ?? '—';
                        final String date =
                            localizations.formatShortDate(stat.date);
                        return BarTooltipItem(
                          '$date\n$category : $valueLabel',
                          tooltipStyle,
                        );
                      },
                    ),
                  ),
                  barGroups: groups,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: <Widget>[
                _LegendIndicator(color: bornColor, label: 'Nés vivants'),
                _LegendIndicator(color: weanedColor, label: 'Sevrés'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendIndicator extends StatelessWidget {
  const _LegendIndicator({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}
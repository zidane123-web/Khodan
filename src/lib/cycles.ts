/**
 * Module regroupant les calculs des services de cycles.
 * Toutes les fonctions exposees sont pures et renvoient des objets geles.
 */

export type CycleKind = 'personal' | 'business' | 'health';

export interface CycleSegment {
  readonly index: number;
  readonly label: string;
  readonly start: Date;
  readonly end: Date;
}

export interface CyclePeriod {
  readonly kind: CycleKind;
  readonly referenceDate: Date;
  readonly cycleStart: Date;
  readonly cycleEnd: Date;
  readonly segmentLengthDays: number;
  readonly segments: ReadonlyArray<CycleSegment>;
  readonly currentSegmentIndex: number;
}

export interface LunarPhase {
  readonly index: number;
  readonly label: string;
  readonly start: Date;
  readonly end: Date;
  readonly lengthHours: number;
}

export interface LunarUnit {
  readonly referenceDate: Date;
  readonly anchor: Date;
  readonly major: LunarPhase;
  readonly minor: LunarPhase;
}

export interface DailySegment {
  readonly referenceDate: Date;
  readonly timezoneOffsetMinutes: number;
  readonly dayStart: Date;
  readonly segments: ReadonlyArray<CycleSegment>;
  readonly currentSegmentIndex: number;
}

export interface AgeStage extends CycleSegment {
  readonly startAge: number;
  readonly endAge: number;
}

export interface SevenYearStage {
  readonly referenceDate: Date;
  readonly birthDate: Date;
  readonly maxAge: number;
  readonly stages: ReadonlyArray<AgeStage>;
}

export interface SoulPolarityResult {
  readonly referenceDate: Date;
  readonly birthDate: Date;
  readonly rawSum: number;
  readonly rootNumber: number;
  readonly polarity: 'yin' | 'yang';
  readonly element: 'earth' | 'water' | 'air' | 'fire';
  readonly qualities: ReadonlyArray<string>;
  readonly description: string;
}

export interface ReincarnationStage {
  readonly referenceDate: Date;
  readonly blockIndex: number;
  readonly blockStart: Date;
  readonly blockEnd: Date;
  readonly blockLengthYears: number;
  readonly subStages: ReadonlyArray<AgeStage>;
  readonly currentSubStageIndex: number;
}

const DAY_MS = 86_400_000;
const HOUR_MS = 3_600_000;
const MINUTE_MS = 60_000;
const YEAR_MS = 365.2425 * DAY_MS;

const PERSONAL_SEGMENT_LABELS = Object.freeze([
  'Naissance',
  'Impulse',
  'Introspection',
  'Expansion',
  'Consolidation',
  'Transmission',
  'Renouveau',
] as const);

const BUSINESS_SEGMENT_LABELS = Object.freeze([
  'Alignement',
  'Vision',
  'Production',
  'Visibilite',
  'Conversion',
  'Service',
  'Evaluation',
] as const);

const HEALTH_SEGMENT_LABELS = Object.freeze([
  'Detox',
  'Restoration',
  'Stabilisation',
  'Immunite',
  'Vitalite',
  'Integration',
  'Silence',
] as const);

const DAILY_SEGMENT_LABELS = Object.freeze([
  'Respiration',
  'Ancrage',
  'Action',
  'Relation',
  'Transmission',
  'Reflection',
  'Sommeil',
] as const);

const SEVEN_YEAR_STAGE_LABELS = Object.freeze([
  'Enracinement',
  'Exploration',
  'Identite',
  'Creation',
  'Impact',
  'Vision',
  'Heritage',
] as const);

const REINC_SUB_STAGE_LABELS = Object.freeze(['Incubation', 'Expansion', 'Maitrise'] as const);

const PERSONAL_SEGMENT_DAYS = 52;
const PERSONAL_SEGMENT_COUNT = 7;
const PERSONAL_CYCLE_DAYS = PERSONAL_SEGMENT_DAYS * PERSONAL_SEGMENT_COUNT; // 364

const LUNAR_ANCHOR = new Date(Date.UTC(2020, 0, 24, 21, 42, 0));
const LUNAR_MAJOR_HOURS = 84; // 3.5 jours
const LUNAR_MINOR_HOURS = 3;
const LUNAR_MAJOR_LABELS = Object.freeze([
  'Stillness',
  'Emergence',
  'Expression',
  'Clarification',
  'Integration',
  'Vision',
  'Release',
  'Void',
] as const);
const LUNAR_MINOR_LABELS = Object.freeze([
  'Pulse',
  'Flow',
  'Focus',
  'Action',
  'Care',
  'Share',
  'Reflect',
  'Dream',
] as const);

const DAILY_SEGMENT_MINUTES = 205; // 3h25
const DAILY_SEGMENT_COUNT = 7;

const DEFAULT_MAX_AGE = 84;
const REINC_BLOCK_YEARS = 27;
const REINC_SUB_STAGE_YEARS = 9;

const SOUL_NUMBER_PROFILES: Record<
  number,
  { element: SoulPolarityResult['element']; description: string; qualities: readonly string[] }
> = {
  1: {
    element: 'fire',
    description: 'Pionnier qui ouvre les portes par la volonte individuelle.',
    qualities: Object.freeze(['initiative', 'courage', 'vision']),
  },
  2: {
    element: 'water',
    description: 'Mediateur intuitif qui harmonise les relations.',
    qualities: Object.freeze(['empathie', 'ecoute', 'cooperation']),
  },
  3: {
    element: 'air',
    description: 'Createur solaire misant sur la joie et la communication.',
    qualities: Object.freeze(['expression', 'creativite', 'legerete']),
  },
  4: {
    element: 'earth',
    description: 'Architecte patient qui cherche structure et stabilite.',
    qualities: Object.freeze(['fiabilite', 'methode', 'ancrage']),
  },
  5: {
    element: 'air',
    description: 'Explorateur libre qui catalyse les changements.',
    qualities: Object.freeze(['mouvement', 'adaptabilite', 'audace']),
  },
  6: {
    element: 'water',
    description: 'Gardien bienveillant tourne vers le soin et la famille.',
    qualities: Object.freeze(['responsabilite', 'reconfort', 'fidelite']),
  },
  7: {
    element: 'water',
    description: 'Chercheur spirituel oriente vers la profondeur.',
    qualities: Object.freeze(['intuition', 'analyse', 'sagesse']),
  },
  8: {
    element: 'earth',
    description: 'Stratege magnetique qui materialise labondance.',
    qualities: Object.freeze(['pragmatisme', 'leadership', 'influence']),
  },
  9: {
    element: 'fire',
    description: 'Humaniste universel tourne vers la transmission.',
    qualities: Object.freeze(['altruisme', 'inspiration', 'vision globale']),
  },
};

/**
 * Additionne un nombre de jours a une date en conservant la purete.
 */
export function addDays(date: Date, days: number): Date {
  const baseline = assertValidDate(date, 'date');
  const delta = assertFiniteNumber(days, 'days');
  return new Date(baseline.getTime() + delta * DAY_MS);
}

/**
 * Additionne un nombre d'heures a une date.
 */
export function addHours(date: Date, hours: number): Date {
  const baseline = assertValidDate(date, 'date');
  const delta = assertFiniteNumber(hours, 'hours');
  return new Date(baseline.getTime() + delta * HOUR_MS);
}

/**
 * Decoupe une periode en segments consecutifs de meme duree.
 */
export function splitIntoSegments(
  anchor: Date,
  segmentCount: number,
  segmentLengthDays: number,
  labels?: readonly string[],
): ReadonlyArray<CycleSegment> {
  const safeAnchor = assertValidDate(anchor, 'anchor');
  if (!Number.isFinite(segmentCount) || segmentCount < 1) {
    throw new RangeError('segmentCount must be >= 1');
  }
  const safeCount = Math.trunc(segmentCount);
  const length = assertFiniteNumber(segmentLengthDays, 'segmentLengthDays');
  if (length <= 0) {
    throw new RangeError('segmentLengthDays must be > 0');
  }

  const segments: CycleSegment[] = [];
  for (let i = 0; i < safeCount; i += 1) {
    const start = addDays(safeAnchor, i * length);
    const end = addDays(start, length);
    const segment: CycleSegment = Object.freeze({
      index: i,
      label: labels?.[i] ?? `Segment ${i + 1}`,
      start: freezeDate(start),
      end: freezeDate(end),
    });
    segments.push(segment);
  }
  return Object.freeze(segments);
}

export function calculatePersonalYear(birthDate: Date): CyclePeriod {
  const birth = assertValidDate(birthDate, 'birthDate');
  const referenceDate = freezeDate(new Date());
  const cycleStart = determineCycleStart(birth, referenceDate, PERSONAL_CYCLE_DAYS);
  const segments = splitIntoSegments(cycleStart, PERSONAL_SEGMENT_COUNT, PERSONAL_SEGMENT_DAYS, PERSONAL_SEGMENT_LABELS);
  return freezeCyclePeriod({
    kind: 'personal',
    referenceDate,
    cycleStart: freezeDate(cycleStart),
    cycleEnd: freezeDate(addDays(cycleStart, PERSONAL_CYCLE_DAYS)),
    segmentLengthDays: PERSONAL_SEGMENT_DAYS,
    segments,
    currentSegmentIndex: getActiveSegmentIndex(referenceDate, segments),
  });
}

export function calculateBusinessCycle(startDate: Date): CyclePeriod {
  const foundation = assertValidDate(startDate, 'startDate');
  const referenceDate = freezeDate(new Date());
  const cycleStart = determineCycleStart(foundation, referenceDate, PERSONAL_CYCLE_DAYS);
  const segments = splitIntoSegments(
    cycleStart,
    PERSONAL_SEGMENT_COUNT,
    PERSONAL_SEGMENT_DAYS,
    BUSINESS_SEGMENT_LABELS,
  );
  return freezeCyclePeriod({
    kind: 'business',
    referenceDate,
    cycleStart: freezeDate(cycleStart),
    cycleEnd: freezeDate(addDays(cycleStart, PERSONAL_CYCLE_DAYS)),
    segmentLengthDays: PERSONAL_SEGMENT_DAYS,
    segments,
    currentSegmentIndex: getActiveSegmentIndex(referenceDate, segments),
  });
}

export function calculateHealthCycle(birthDate: Date): CyclePeriod {
  const birth = assertValidDate(birthDate, 'birthDate');
  const referenceDate = freezeDate(new Date());
  const cycleStart = determineCycleStart(birth, referenceDate, PERSONAL_CYCLE_DAYS);
  const segments = splitIntoSegments(cycleStart, PERSONAL_SEGMENT_COUNT, PERSONAL_SEGMENT_DAYS, HEALTH_SEGMENT_LABELS);
  return freezeCyclePeriod({
    kind: 'health',
    referenceDate,
    cycleStart: freezeDate(cycleStart),
    cycleEnd: freezeDate(addDays(cycleStart, PERSONAL_CYCLE_DAYS)),
    segmentLengthDays: PERSONAL_SEGMENT_DAYS,
    segments,
    currentSegmentIndex: getActiveSegmentIndex(referenceDate, segments),
  });
}

export function calculateLunarUnits(referenceDate: Date): LunarUnit {
  const reference = freezeDate(assertValidDate(referenceDate, 'referenceDate'));
  const anchor = freezeDate(LUNAR_ANCHOR);
  const majorLengthMs = LUNAR_MAJOR_HOURS * HOUR_MS;
  const diffSinceAnchor = reference.getTime() - anchor.getTime();
  const majorIndex = Math.floor(diffSinceAnchor / majorLengthMs);
  const majorStart = addHours(anchor, majorIndex * LUNAR_MAJOR_HOURS);
  const majorEnd = addHours(majorStart, LUNAR_MAJOR_HOURS);
  const majorPhase: LunarPhase = Object.freeze({
    index: majorIndex,
    label: LUNAR_MAJOR_LABELS[Math.abs(majorIndex) % LUNAR_MAJOR_LABELS.length],
    start: freezeDate(majorStart),
    end: freezeDate(majorEnd),
    lengthHours: LUNAR_MAJOR_HOURS,
  });

  const minorLengthMs = LUNAR_MINOR_HOURS * HOUR_MS;
  const elapsedInsideMajor = reference.getTime() - majorStart.getTime();
  const minorIndex = Math.floor(elapsedInsideMajor / minorLengthMs);
  const minorStart = addHours(majorStart, minorIndex * LUNAR_MINOR_HOURS);
  const minorEnd = addHours(minorStart, LUNAR_MINOR_HOURS);
  const minorPhase: LunarPhase = Object.freeze({
    index: minorIndex,
    label: LUNAR_MINOR_LABELS[((minorIndex % LUNAR_MINOR_LABELS.length) + LUNAR_MINOR_LABELS.length) % LUNAR_MINOR_LABELS.length],
    start: freezeDate(minorStart),
    end: freezeDate(minorEnd),
    lengthHours: LUNAR_MINOR_HOURS,
  });

  return Object.freeze({
    referenceDate: reference,
    anchor,
    major: majorPhase,
    minor: minorPhase,
  });
}

export function calculateDailyCycle(referenceDate: Date, tzOffsetMinutes: number): DailySegment {
  const reference = freezeDate(assertValidDate(referenceDate, 'referenceDate'));
  const offset = assertFiniteNumber(tzOffsetMinutes, 'tzOffsetMinutes');

  const localReference = shiftMinutes(reference, offset);
  const dayStartLocal = startOfDay(localReference);
  const dayStartUtc = shiftMinutes(dayStartLocal, -offset);

  const segments: CycleSegment[] = [];
  for (let i = 0; i < DAILY_SEGMENT_COUNT; i += 1) {
    const startLocal = addMinutes(dayStartLocal, i * DAILY_SEGMENT_MINUTES);
    const endLocal = addMinutes(startLocal, DAILY_SEGMENT_MINUTES);
    const startUtc = shiftMinutes(startLocal, -offset);
    const endUtc = shiftMinutes(endLocal, -offset);
    const segment: CycleSegment = Object.freeze({
      index: i,
      label: DAILY_SEGMENT_LABELS[i] ?? `Segment ${i + 1}`,
      start: freezeDate(startUtc),
      end: freezeDate(endUtc),
    });
    segments.push(segment);
  }

  return Object.freeze({
    referenceDate: reference,
    timezoneOffsetMinutes: offset,
    dayStart: freezeDate(dayStartUtc),
    segments: Object.freeze(segments),
    currentSegmentIndex: getActiveSegmentIndex(reference, segments),
  });
}

export function calculateSoulPolarity(birthDate: Date): SoulPolarityResult {
  const birth = freezeDate(assertValidDate(birthDate, 'birthDate'));
  const referenceDate = freezeDate(new Date());
  const isoDigits = birth.toISOString().slice(0, 10).replace(/-/g, '');
  const rawSum = isoDigits.split('').reduce((sum, char) => sum + Number.parseInt(char, 10), 0);
  const rootNumber = reduceToRootNumber(rawSum);
  const polarity: SoulPolarityResult['polarity'] = rootNumber % 2 === 0 ? 'yin' : 'yang';
  const profile = SOUL_NUMBER_PROFILES[rootNumber] ?? SOUL_NUMBER_PROFILES[1];
  const description = `${profile.description} Polarite ${polarity === 'yin' ? 'receptive' : 'rayonnante'}.`;

  return Object.freeze({
    referenceDate,
    birthDate: birth,
    rawSum,
    rootNumber,
    polarity,
    element: profile.element,
    qualities: profile.qualities,
    description,
  });
}

export function calculateSevenYearStages(birthDate: Date, maxAge: number = DEFAULT_MAX_AGE): SevenYearStage {
  const birth = freezeDate(assertValidDate(birthDate, 'birthDate'));
  const sanitizedMaxAge = Math.max(7, Math.min(assertFiniteNumber(maxAge, 'maxAge'), 112));
  const stageCount = Math.ceil(sanitizedMaxAge / 7);
  const stages: AgeStage[] = [];

  for (let i = 0; i < stageCount; i += 1) {
    const startAge = i * 7;
    const endAge = Math.min((i + 1) * 7, sanitizedMaxAge);
    const start = addYears(birth, startAge);
    const end = addYears(birth, endAge);
    stages.push(
      freezeAgeStage({
        index: i,
        label: SEVEN_YEAR_STAGE_LABELS[i % SEVEN_YEAR_STAGE_LABELS.length],
        start,
        end,
        startAge,
        endAge,
      }),
    );
  }

  return Object.freeze({
    referenceDate: freezeDate(new Date()),
    birthDate: birth,
    maxAge: sanitizedMaxAge,
    stages: Object.freeze(stages),
  });
}

export function calculateReincarnationBlock(birthDate: Date): ReincarnationStage {
  const birth = freezeDate(assertValidDate(birthDate, 'birthDate'));
  const referenceDate = freezeDate(new Date());
  const elapsedYears = Math.max(0, getYearSpan(birth, referenceDate));
  const blockIndex = Math.floor(elapsedYears / REINC_BLOCK_YEARS);
  const blockStart = addYears(birth, blockIndex * REINC_BLOCK_YEARS);
  const blockEnd = addYears(blockStart, REINC_BLOCK_YEARS);

  const subStages: AgeStage[] = [];
  for (let i = 0; i < REINC_SUB_STAGE_LABELS.length; i += 1) {
    const startAge = blockIndex * REINC_BLOCK_YEARS + i * REINC_SUB_STAGE_YEARS;
    const endAge = startAge + REINC_SUB_STAGE_YEARS;
    const start = addYears(birth, startAge);
    const end = addYears(birth, Math.min(endAge, (blockIndex + 1) * REINC_BLOCK_YEARS));
    subStages.push(
      freezeAgeStage({
        index: i,
        label: REINC_SUB_STAGE_LABELS[i],
        start,
        end,
        startAge,
        endAge,
      }),
    );
  }

  return Object.freeze({
    referenceDate,
    blockIndex,
    blockStart: freezeDate(blockStart),
    blockEnd: freezeDate(blockEnd),
    blockLengthYears: REINC_BLOCK_YEARS,
    subStages: Object.freeze(subStages),
    currentSubStageIndex: getActiveSegmentIndex(referenceDate, subStages),
  });
}

function freezeCyclePeriod(payload: CyclePeriod): CyclePeriod {
  return Object.freeze({
    ...payload,
    segments: Object.freeze(payload.segments.slice()),
  });
}

function freezeAgeStage(stage: AgeStage): AgeStage {
  return Object.freeze({
    ...stage,
    start: freezeDate(stage.start),
    end: freezeDate(stage.end),
  });
}

function freezeDate(date: Date): Date {
  return Object.freeze(new Date(date.getTime()));
}

function addMinutes(date: Date, minutes: number): Date {
  const baseline = assertValidDate(date, 'date');
  const delta = assertFiniteNumber(minutes, 'minutes');
  return new Date(baseline.getTime() + delta * MINUTE_MS);
}

function shiftMinutes(date: Date, minutes: number): Date {
  return addMinutes(date, minutes);
}

function startOfDay(date: Date): Date {
  const copy = assertValidDate(date, 'date');
  copy.setHours(0, 0, 0, 0);
  return copy;
}

function determineCycleStart(base: Date, reference: Date, cycleLengthDays: number): Date {
  const lengthMs = cycleLengthDays * DAY_MS;
  const ref = reference.getTime();
  const origin = base.getTime();
  if (ref <= origin) {
    return new Date(origin);
  }
  const diffMs = ref - origin;
  const cyclesElapsed = Math.floor(diffMs / lengthMs);
  return new Date(origin + cyclesElapsed * lengthMs);
}

function getActiveSegmentIndex<T extends { readonly start: Date; readonly end: Date }>(
  reference: Date,
  segments: ReadonlyArray<T>,
): number {
  const refTime = reference.getTime();
  for (let i = 0; i < segments.length; i += 1) {
    const segment = segments[i];
    if (refTime >= segment.start.getTime() && refTime < segment.end.getTime()) {
      return i;
    }
  }
  return -1;
}

function assertValidDate(value: Date, label: string): Date {
  if (!(value instanceof Date) || Number.isNaN(value.getTime())) {
    throw new TypeError(`Invalid date provided for ${label}`);
  }
  return new Date(value.getTime());
}

function assertFiniteNumber(value: number, label: string): number {
  if (!Number.isFinite(value)) {
    throw new TypeError(`${label} must be a finite number`);
  }
  return value;
}

function reduceToRootNumber(value: number): number {
  let result = Math.abs(Math.trunc(value));
  while (result > 9) {
    result = result
      .toString()
      .split('')
      .reduce((sum, digit) => sum + Number.parseInt(digit, 10), 0);
  }
  return result === 0 ? 9 : result;
}

function addYears(date: Date, years: number): Date {
  const baseline = assertValidDate(date, 'date');
  const totalYears = assertFiniteNumber(years, 'years');
  const wholeYears = Math.trunc(totalYears);
  const remainder = totalYears - wholeYears;
  baseline.setFullYear(baseline.getFullYear() + wholeYears);
  if (remainder !== 0) {
    baseline.setTime(baseline.getTime() + remainder * YEAR_MS);
  }
  return baseline;
}

function getYearSpan(start: Date, end: Date): number {
  return (end.getTime() - start.getTime()) / YEAR_MS;
}

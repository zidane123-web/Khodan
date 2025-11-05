import {
  calculateBusinessCycle,
  calculateDailyCycle,
  calculateHealthCycle,
  calculateLunarUnits,
  calculatePersonalYear,
  calculateReincarnationBlock,
  calculateSevenYearStages,
  calculateSoulPolarity,
} from './cycles';

/**
 * Documentation vivante: exemples simples qui servent aussi de garde-fous de compilation.
 * Les fonctions ne sont pas executees en production, mais tsc garantit la coherance des signatures.
 */
export function cyclesDocExamples(): void {
  const birth = new Date('1990-05-21T00:00:00Z');
  const companyStart = new Date('2018-03-12T00:00:00Z');

  const personal = calculatePersonalYear(birth);
  const business = calculateBusinessCycle(companyStart);
  const health = calculateHealthCycle(birth);
  if (personal.segments.length !== 7 || business.segments.length !== 7 || health.segments.length !== 7) {
    throw new Error('All 52 day cycles must expose 7 segments.');
  }

  const lunar = calculateLunarUnits(new Date('2025-05-01T12:00:00Z'));
  if (lunar.major.lengthHours !== 84 || lunar.minor.lengthHours !== 3) {
    throw new Error('Unexpected lunar unit length.');
  }

  const daily = calculateDailyCycle(new Date('2025-05-01T08:00:00Z'), 0);
  if (daily.segments.length !== 7) {
    throw new Error('Daily cycle must expose 7 segments.');
  }

  const soul = calculateSoulPolarity(birth);
  if (soul.rootNumber < 1 || soul.rootNumber > 9) {
    throw new Error('Root number must stay in numerology range.');
  }

  const sevenYear = calculateSevenYearStages(birth, 35);
  if (sevenYear.stages.length !== 5) {
    throw new Error('35 years should produce 5 seven year stages.');
  }

  const reincarnation = calculateReincarnationBlock(birth);
  if (reincarnation.subStages.length !== 3) {
    throw new Error('Reincarnation block exposes 3 sub stages.');
  }

  // Ces instructions vides empechent TypeScript de signaler les resultats comme inutilises.
  void daily.currentSegmentIndex;
  void personal.currentSegmentIndex;
}

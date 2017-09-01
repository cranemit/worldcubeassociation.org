import events from 'wca/events.js.erb'

function parseMbValue(mbValue) {
  let old = Math.floor(mbValue / 1000000000) !== 0;
  let timeSeconds, attempted, solved;
  if(old) {
    timeSeconds = mbValue % 100000;
    mbValue = Math.floor(mbValue / 100000);
    attempted = mbValue % 100;
    mbValue = Math.floor(mbValue / 100);
    solved = 99 - mbValue % 100;
  } else {
    let missed = mbValue % 100;
    mbValue = Math.floor(mbValue / 100);
    timeSeconds = mbValue % 100000;
    mbValue = Math.floor(mbValue / 100000);
    let difference = 99 - (mbValue % 100);

    solved = difference + missed;
    attempted = solved + missed;
  }

  let timeCentiseconds = timeSeconds == 99999 ? null : timeSeconds * 100;
  return { solved, attempted, timeCentiseconds };
}

function parsedMbToAttemptResult(parsedMb) {
  let { solved, attempted, timeCentiseconds } = parsedMb;
  let missed = attempted - solved;

  let mm = missed;
  let dd = 99 - (solved - missed);
  let ttttt = Math.floor(timeCentiseconds / 100);
  return (dd * 1e7 + ttttt * 1e2 + mm);
}

// See https://www.worldcubeassociation.org/regulations/#9f12c
export function attemptResultToMbPoints(mbValue) {
  let { solved, attempted } = parseMbValue(mbValue);
  let missed = attempted - solved;
  return solved - missed;
}

export function mbPointsToAttemptResult(mbPoints) {
  let solved = mbPoints;
  let attempted = mbPoints;
  let timeCentiseconds = 99999*100;
  return parsedMbToAttemptResult({ solved, attempted, timeCentiseconds });
}

export function attemptResultToString(attemptResult, eventId) {
  let event = events.byId[eventId];
  if(event.timed_event) {
    return centisecondsToString(attemptResult);
  } else if(event.fewest_moves) {
    return `${attemptResult} moves`;
  } else if(event.multiple_blindfolded) {
    return `${attemptResultToMbPoints(attemptResult)} points`;
  } else {
    throw new Error(`Unrecognized event type: ${eventId}`);
  }
}

export function centisecondsToString(centiseconds) {
  const seconds = centiseconds / 100;
  const minutes = seconds / 60;
  const hours = minutes / 60;

  if(hours >= 1) {
    return `${hours.toFixed(2)} hours`;
  } else if(minutes >= 1) {
    return `${minutes.toFixed(2)} minutes`;
  } else {
    return `${seconds.toFixed(2)} seconds`;
  }
}

export function roundIdToString(roundId) {
  let [ eventId, roundNumber ] = roundId.split("-");
  roundNumber = parseInt(roundNumber);
  let event = events.byId[eventId];
  return `${event.name}, Round ${roundNumber}`;
}

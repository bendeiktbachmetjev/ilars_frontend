"""Writes fixtures/patient.json: an invented iLARS patient for the store pictures.

Nothing here is real. Dates are stored as "days ago", so the capture test can
place them around the day it runs and the chart windows always look full.

    python3 store/pictures/make_fixture.py

The patient: about four months after surgery and slowly getting better.
Weekly LARS score drifts from about 36 down to about 24, steps rise from about
3 500 to about 6 500 a day. Today's daily form is not filled in yet.
"""

import json
import math
import random
from pathlib import Path

rng = random.Random(20261126)

REGISTERED_DAYS_AGO = 122  # about four months

# Weekly LARS, every 7 days, the last one 6 days ago (so today only the daily
# form is due, as the server would decide).
weekly = []
weeks = list(range(REGISTERED_DAYS_AGO - 2, 0, -7))  # 120, 113, ..., 1? -> trim
weeks = [d for d in weeks if d >= 6]
n = len(weeks)
for i, days_ago in enumerate(weeks):
    t = i / max(1, n - 1)
    trend = 36 - 12 * (1 - (1 - t) ** 1.4)  # faster at first, then levelling
    wobble = rng.choice([-2, -1, -1, 0, 0, 1, 1, 2])
    score = int(round(trend + wobble))
    if i == 0:
        score = 36
    if i == n - 1:
        score = 24
    weekly.append({"days_ago": days_ago, "score": max(20, min(39, score))})

# Daily step counts up to yesterday. A few days have no data (phone left at
# home); weekends a little higher; a slow rise with day-to-day noise.
steps = []
for days_ago in range(REGISTERED_DAYS_AGO, 0, -1):
    if rng.random() < 0.04:
        continue
    t = (REGISTERED_DAYS_AGO - days_ago) / REGISTERED_DAYS_AGO
    base = 3400 + 3000 * t
    weekly_rhythm = 450 * math.sin(days_ago * 2 * math.pi / 7)
    noise = rng.gauss(0, 520)
    value = int(round(base + weekly_rhythm + noise))
    steps.append({"days_ago": days_ago, "steps": max(2600, min(7400, value))})

fixture = {
    "_note": "Invented data for store pictures. Not a real patient.",
    "patient_code": "DEMO-0426",
    "registered_days_ago": REGISTERED_DAYS_AGO,
    "next_questionnaire": {
        "status": "ok",
        "questionnaire_type": "daily",
        "is_today_filled": False,
        "today_filled_type": None,
        # Exactly what the backend sends (it is not translated there).
        "reason": "Daily questionnaire available",
    },
    "weekly_lars": weekly,
    "steps": steps,
    # Today's daily form as the patient is filling it in: mild values.
    "daily_in_progress": {
        "stool_count": 3,
        "pads_used": 1,
        "urgency": "Yes",
        "night_stools": "No",
        "leakage": "None",
        "incomplete_evacuation": "No",
        "bloating": 3,
        "impact_score": 2,
        "activity_interfere": 2,
    },
    # The food and drink part, a few items chosen.
    "food_in_progress": {
        "food_vegetables_all": 2,
        "food_root_vegetables": 1,
        "food_whole_grain_bread": 2,
        "food_soft_fruits_no_skin": 1,
        "drink_water": 6,
        "drink_coffee": 1,
        "drink_tea": 2,
    },
}

out = Path(__file__).parent / "fixtures" / "patient.json"
out.parent.mkdir(parents=True, exist_ok=True)
out.write_text(json.dumps(fixture, indent=1, ensure_ascii=False) + "\n")
print(out, "weekly:", [w["score"] for w in weekly])
print("steps:", len(steps), "min", min(s["steps"] for s in steps), "max", max(s["steps"] for s in steps))

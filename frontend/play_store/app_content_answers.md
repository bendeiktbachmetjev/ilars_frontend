# Play Store — App content: suggested answers (copy-paste)

Use these when filling **App content** in Play Console (Data safety, Health declaration, Ads, etc.).

---

## Data safety (Безопасность данных)

- **Does your app collect or share user data?** → **Yes**
- **Is this data collected, shared, or both?** → **Collected** (and optionally **Shared** if your backend is considered a “third party” by Google; usually “collected” is enough if you only send to your own server)
- **Is this data processed ephemerally?** → **No**
- **Is this data required or optional?** → **Required** (app does not work without patient code and symptom data)

**Data types to add:**

| Data type        | Category   | Purpose            | Optional? |
|------------------|------------|--------------------|----------|
| Health           | Health and fitness (e.g. steps, symptoms, bowel habits) | App functionality | No (steps optional in app, but declare as collected if user grants) |
| App activity     | App interactions (e.g. feature usage) | App functionality, Analytics (if you do any) | No / Optional depending on what you log |
| Device or other IDs | User ID (e.g. pseudonymized patient code) | App functionality | No |

**Short summary for “Data safety” section (you can paste or adapt):**  
“ABBA LARS collects health-related data (bowel and symptom logs, optional step count) and a pseudonymized user code to provide symptom tracking and to link data to your care team. We do not collect names, emails, or phone numbers. Data is not sold or used for advertising. See our Privacy Policy for details.”

---

## Health and fitness (Health declaration)

- **Does your app collect health or fitness data?** → **Yes**
- **What data?** → e.g. “Bowel and digestive symptoms, optional daily step count (via Health Connect / Google Fit). No name, email, or other identifiers.”
- **Why?** → “To provide symptom tracking and optional activity tracking for recovery; data is linked to a pseudonymized patient code and may be viewed by the user’s care team. See Privacy Policy.”

---

## Health Connect by Android permissions (rationale to paste in Play Console)

Use the text below in the Health Connect permissions / “Why does your app need read access …” fields (write it in your own words if needed).

### Steps (read)
- **Purpose in the app:** We read the user’s aggregated daily step count from Health Connect to support post-surgical recovery monitoring.
- **How the data is used:** The step count is used as an objective indicator of physical activity level over time and is displayed as part of the patient’s recovery/activity information. The app does not require or use precise per-step sensor streams.
- **Benefits to the user:** Clinicians can better understand functional progress during recovery using objective activity data.
- **Privacy:** Step data is linked only to the user’s pseudonymized patient code (no names/emails/other direct identifiers in the app).

### StepsCadence (read)
- **Purpose in the app:** We only import daily aggregated step counts needed for activity monitoring during recovery.
- **Why Health Connect asks for this permission category:** Health Connect may surface additional step-related permission categories together with step data access. Our implementation reads total steps for the day and does not use cadence/stride timing metrics as a separate feature.
- **Benefits to the user:** Same as above—objective daily activity trend for recovery monitoring.
- **Privacy:** Same as above—linked to the pseudonymized patient code.

---

## Ads declaration

- **Does your app contain ads?** → **No**
- **No ads** → Select “No” or “My app does not contain ads.”

---

## Content rating

- **Category:** Health, Medical (or similar).
- **Questionnaire:** Typically “No” for violence, sexual content, bad language, etc. → Result usually **Everyone** or **3+** (or **Teen** if you state medical content; for clinical use **Everyone** or **3+** is common).

---

## Target audience

- **Age groups:** e.g. **18+** (recommended for a medical / post-surgery app).

---

## App access (if asked)

- **Special access (e.g. login) required?** → “Yes. Users need a unique patient code provided by their clinic to access their dashboard. No public content.”
- **Instructions for reviewers:** e.g. “Use test patient code: [provide a test code if your backend has one] to log in and review the app.”

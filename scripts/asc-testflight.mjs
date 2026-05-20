#!/usr/bin/env node
// Sync TestFlight Test Information + per-build "What to Test" + export
// compliance via the App Store Connect API. Idempotent: re-running updates
// existing records rather than duplicating them.
//
// Usage:  node scripts/asc-testflight.mjs

import crypto from "node:crypto";
import { readFile } from "node:fs/promises";

// =============================================================
// Config
// =============================================================
const KEY_ID = "FG37DQT4A8";
const ISSUER_ID = "69a6de81-473d-47e3-e053-5b8c7c11a4d1";
const P8_PATH = "/Users/lucaswoj/Downloads/AuthKey_FG37DQT4A8.p8";
const BUNDLE_ID = "com.lucaswoj.grouporma";

const TEST_INFO = {
  description:
    "Group ORMA is a decision aid for search-and-rescue teams running a group Operational Risk Management Assessment. Each participant drags a token to thumbs up, sideways, or down across eight risk categories. The app averages the votes and produces a risk score band that frames the go/no-go decision. All data stays on device. Not affiliated with the National Park Service.",
  feedbackEmail: "hello@lucaswoj.com",
  marketingUrl: "",
  privacyPolicyUrl: "", // fill in before external review goes live
};

const APP_REVIEW = {
  contactFirstName: "Lucas",
  contactLastName: "Wojciechowski",
  contactPhone: "", // fill in if you want to overwrite what's currently set
  contactEmail: "hello@lucaswoj.com",
  demoAccountRequired: false,
  notes:
    'Group ORMA is a decision aid for search-and-rescue teams running a group risk assessment. No accounts, no network calls, all data stored locally on device.\n\nTo test: tap "Begin" on the start screen. Drag the token to one of three zones (thumbs up, sideways, down) on each of eight category screens. Optionally type notes in the field on each screen. Swipe to the final Summary screen. Tap Share to export the result.\n\nNot affiliated with the National Park Service.',
};

const WHATS_NEW =
  "First TestFlight build. Run a full ORMA cycle: set participant count on the start screen, drag tokens through all eight categories, add notes, view the Summary screen, tap Share. Report anything that crashes, mislays a token, or shows the wrong score band.";

// =============================================================
// JWT (ES256)
// =============================================================
async function signJWT() {
  const pem = await readFile(P8_PATH, "utf8");
  const header = { alg: "ES256", kid: KEY_ID, typ: "JWT" };
  const now = Math.floor(Date.now() / 1000);
  const payload = {
    iss: ISSUER_ID,
    iat: now,
    exp: now + 1200,
    aud: "appstoreconnect-v1",
  };
  const b64 = (obj) =>
    Buffer.from(JSON.stringify(obj)).toString("base64url");
  const signingInput = `${b64(header)}.${b64(payload)}`;
  const key = crypto.createPrivateKey(pem);
  // JWT requires raw R||S signature, not DER. Node default is DER.
  const sig = crypto.sign("sha256", Buffer.from(signingInput), {
    key,
    dsaEncoding: "ieee-p1363",
  });
  return `${signingInput}.${sig.toString("base64url")}`;
}

// =============================================================
// API helper
// =============================================================
const BASE = "https://api.appstoreconnect.apple.com";
let token;

async function api(method, path, body) {
  const res = await fetch(`${BASE}${path}`, {
    method,
    headers: {
      Authorization: `Bearer ${token}`,
      "Content-Type": "application/json",
    },
    body: body ? JSON.stringify(body) : undefined,
  });
  const text = await res.text();
  if (!res.ok) {
    throw new Error(`${method} ${path} -> ${res.status}\n${text}`);
  }
  return text ? JSON.parse(text) : null;
}

// Drop empty-string/undefined keys; keep `false` and numbers.
function clean(obj) {
  const out = {};
  for (const [k, v] of Object.entries(obj)) {
    if (v === "" || v === undefined || v === null) continue;
    out[k] = v;
  }
  return out;
}

// =============================================================
// Main
// =============================================================
async function main() {
  token = await signJWT();

  const apps = await api(
    "GET",
    `/v1/apps?filter[bundleId]=${encodeURIComponent(BUNDLE_ID)}`,
  );
  if (!apps.data?.length) throw new Error(`App ${BUNDLE_ID} not found`);
  const appId = apps.data[0].id;
  console.log(`App: ${apps.data[0].attributes.name} (${appId})`);

  // Beta App Localization (en-US) — description, feedback email, URLs.
  const locs = await api(
    "GET",
    `/v1/apps/${appId}/betaAppLocalizations`,
  );
  const existingLoc = locs.data.find(
    (d) => d.attributes.locale === "en-US",
  );
  const locAttrs = clean({
    description: TEST_INFO.description,
    feedbackEmail: TEST_INFO.feedbackEmail,
    marketingUrl: TEST_INFO.marketingUrl,
    privacyPolicyUrl: TEST_INFO.privacyPolicyUrl,
  });
  if (existingLoc) {
    await api(
      "PATCH",
      `/v1/betaAppLocalizations/${existingLoc.id}`,
      {
        data: {
          type: "betaAppLocalizations",
          id: existingLoc.id,
          attributes: locAttrs,
        },
      },
    );
    console.log("  beta app localization (en-US): updated");
  } else {
    await api("POST", "/v1/betaAppLocalizations", {
      data: {
        type: "betaAppLocalizations",
        attributes: { locale: "en-US", ...locAttrs },
        relationships: { app: { data: { type: "apps", id: appId } } },
      },
    });
    console.log("  beta app localization (en-US): created");
  }

  // Beta App Review Detail — contact info, sign-in, notes.
  const detail = await api(
    "GET",
    `/v1/apps/${appId}/betaAppReviewDetail`,
  );
  const detailAttrs = clean({
    contactFirstName: APP_REVIEW.contactFirstName,
    contactLastName: APP_REVIEW.contactLastName,
    contactPhone: APP_REVIEW.contactPhone,
    contactEmail: APP_REVIEW.contactEmail,
    demoAccountRequired: APP_REVIEW.demoAccountRequired,
    notes: APP_REVIEW.notes,
  });
  await api(
    "PATCH",
    `/v1/betaAppReviewDetails/${detail.data.id}`,
    {
      data: {
        type: "betaAppReviewDetails",
        id: detail.data.id,
        attributes: detailAttrs,
      },
    },
  );
  console.log("  beta app review detail: updated");

  // Latest build — export compliance + "What to Test".
  const builds = await api(
    "GET",
    `/v1/builds?filter[app]=${appId}&sort=-uploadedDate&limit=1`,
  );
  if (!builds.data?.length) {
    console.log("No builds found; done.");
    return;
  }
  const build = builds.data[0];
  console.log(
    `Build: ${build.attributes.version} (${build.attributes.expired ? "expired" : "active"}) (${build.id})`,
  );

  if (build.attributes.usesNonExemptEncryption === null) {
    await api("PATCH", `/v1/builds/${build.id}`, {
      data: {
        type: "builds",
        id: build.id,
        attributes: { usesNonExemptEncryption: false },
      },
    });
    console.log("  usesNonExemptEncryption: false");
  } else {
    console.log(
      `  usesNonExemptEncryption: already ${build.attributes.usesNonExemptEncryption} (from Info.plist), leaving as-is`,
    );
  }

  const buildLocs = await api(
    "GET",
    `/v1/builds/${build.id}/betaBuildLocalizations`,
  );
  const existingBuildLoc = buildLocs.data.find(
    (d) => d.attributes.locale === "en-US",
  );
  if (existingBuildLoc) {
    await api(
      "PATCH",
      `/v1/betaBuildLocalizations/${existingBuildLoc.id}`,
      {
        data: {
          type: "betaBuildLocalizations",
          id: existingBuildLoc.id,
          attributes: { whatsNew: WHATS_NEW },
        },
      },
    );
    console.log("  build localization (en-US): updated");
  } else {
    await api("POST", "/v1/betaBuildLocalizations", {
      data: {
        type: "betaBuildLocalizations",
        attributes: { locale: "en-US", whatsNew: WHATS_NEW },
        relationships: {
          build: { data: { type: "builds", id: build.id } },
        },
      },
    });
    console.log("  build localization (en-US): created");
  }

  console.log("\nDone.");
}

main().catch((e) => {
  console.error(e.message);
  process.exit(1);
});

import crypto from "node:crypto";
import fs from "node:fs/promises";
import path from "node:path";

const API_BASE = "https://api.appstoreconnect.apple.com/v1";
const APP_ID = required("ASC_APP_ID");
const KEY_ID = required("ASC_KEY_ID");
const ISSUER_ID = required("ASC_ISSUER_ID");
const ASSET_ROOT = process.env.SUBSCRIPTION_REVIEW_ASSETS_DIR
  ?? "MarketingAssets/AppStore/SubscriptionReview/ReviewScreenshots-640x920";

const SUBSCRIPTIONS = [
  {
    productId: "snappolish.creator.monthly",
    label: "Creator Pro Monthly",
    screenshot: "01-creator-pro-monthly.png",
  },
  {
    productId: "snappolish.creator.yearly",
    label: "Creator Pro Yearly",
    screenshot: "02-creator-pro-yearly.png",
  },
  {
    productId: "snappolish.agency.monthly",
    label: "Agency Monthly",
    screenshot: "03-agency-monthly.png",
  },
];

function required(name) {
  const value = process.env[name];
  if (!value) {
    throw new Error(`${name} is required`);
  }
  return value;
}

function privateKey() {
  const encoded = process.env.ASC_PRIVATE_KEY_BASE64;
  const value = encoded
    ? Buffer.from(encoded, "base64").toString("utf8")
    : required("ASC_PRIVATE_KEY");

  return value.replace(/\\n/g, "\n");
}

function base64url(value) {
  const input = Buffer.isBuffer(value) ? value : Buffer.from(JSON.stringify(value));
  return input
    .toString("base64")
    .replace(/=/g, "")
    .replace(/\+/g, "-")
    .replace(/\//g, "_");
}

function token() {
  const now = Math.floor(Date.now() / 1000);
  const header = { alg: "ES256", kid: KEY_ID, typ: "JWT" };
  const payload = {
    iss: ISSUER_ID,
    exp: now + 20 * 60,
    aud: "appstoreconnect-v1",
  };
  const signingInput = `${base64url(header)}.${base64url(payload)}`;
  const signature = crypto.sign("sha256", Buffer.from(signingInput), {
    key: privateKey(),
    dsaEncoding: "ieee-p1363",
  });
  return `${signingInput}.${base64url(signature)}`;
}

let jwt = token();

async function api(method, requestPath, body, accepted = [200, 201, 204]) {
  let response = await request(method, requestPath, body);

  if (response.status === 401) {
    jwt = token();
    response = await request(method, requestPath, body);
  }

  const parsed = await parse(response);
  if (!accepted.includes(response.status)) {
    const details = typeof parsed === "string" ? parsed : JSON.stringify(parsed, null, 2);
    throw new Error(`${method} ${requestPath} failed with ${response.status}: ${details}`);
  }

  return parsed;
}

async function request(method, requestPath, body) {
  return fetch(`${API_BASE}${requestPath}`, {
    method,
    headers: {
      Authorization: `Bearer ${jwt}`,
      "Content-Type": "application/json",
    },
    body: body ? JSON.stringify(body) : undefined,
  });
}

async function parse(response) {
  const text = await response.text();
  if (!text) {
    return null;
  }

  try {
    return JSON.parse(text);
  } catch {
    return text;
  }
}

function encodeQuery(params) {
  return new URLSearchParams(params).toString();
}

async function listAll(requestPath) {
  const items = [];
  let next = requestPath;

  while (next) {
    const response = await api("GET", next);
    items.push(...(response.data ?? []));
    next = response.links?.next ? new URL(response.links.next).pathname + new URL(response.links.next).search : null;
  }

  return items;
}

async function bestEffort(label, work) {
  try {
    await work();
    console.log(`${label}: ok`);
  } catch (error) {
    console.log(`${label}: skipped (${error.message})`);
  }
}

async function subscriptionGroups() {
  const params = encodeQuery({ limit: "200" });
  return listAll(`/apps/${APP_ID}/subscriptionGroups?${params}`);
}

async function subscriptionsForGroup(groupId) {
  const params = encodeQuery({ limit: "200" });
  return listAll(`/subscriptionGroups/${groupId}/subscriptions?${params}`);
}

async function findSubscriptions() {
  const groups = await subscriptionGroups();
  if (!groups.length) {
    throw new Error(`No subscription groups found for app ${APP_ID}`);
  }

  const subscriptions = [];
  for (const group of groups) {
    const groupSubscriptions = await subscriptionsForGroup(group.id);
    for (const subscription of groupSubscriptions) {
      subscriptions.push({ ...subscription, groupId: group.id });
    }
  }

  const byProductId = new Map(
    subscriptions.map((subscription) => [subscription.attributes?.productId, subscription])
  );

  const missing = SUBSCRIPTIONS
    .filter((config) => !byProductId.has(config.productId))
    .map((config) => config.productId);

  if (missing.length) {
    throw new Error(`Missing App Store Connect subscriptions: ${missing.join(", ")}`);
  }

  return {
    groups,
    subscriptions: SUBSCRIPTIONS.map((config) => ({
      ...config,
      resource: byProductId.get(config.productId),
    })),
  };
}

async function currentReviewScreenshot(subscriptionId) {
  const response = await api(
    "GET",
    `/subscriptions/${subscriptionId}/appStoreReviewScreenshot`,
    null,
    [200, 404]
  );

  return response?.data ?? null;
}

async function getSubscription(subscriptionId) {
  const response = await api("GET", `/subscriptions/${subscriptionId}`);
  return response.data;
}

function screenshotIsComplete(screenshot) {
  const state = screenshot?.attributes?.assetDeliveryState?.state;
  return state === "COMPLETE" || state === "UPLOAD_COMPLETE";
}

async function deleteReviewScreenshot(screenshot) {
  if (!screenshot?.id) {
    return;
  }

  await bestEffort(`Delete old screenshot ${screenshot.id}`, async () => {
    await api("DELETE", `/subscriptionAppStoreReviewScreenshots/${screenshot.id}`);
  });
}

async function createReviewScreenshot(subscriptionId, fileName, fileSize) {
  const response = await api("POST", "/subscriptionAppStoreReviewScreenshots", {
    data: {
      type: "subscriptionAppStoreReviewScreenshots",
      attributes: { fileName, fileSize },
      relationships: {
        subscription: {
          data: { type: "subscriptions", id: subscriptionId },
        },
      },
    },
  });

  return response.data;
}

async function uploadChunks(file, uploadOperations) {
  for (const operation of uploadOperations ?? []) {
    const headers = Object.fromEntries(
      (operation.requestHeaders ?? []).map((header) => [header.name, header.value])
    );
    const offset = operation.offset ?? 0;
    const length = operation.length ?? file.length;
    const chunk = file.subarray(offset, offset + length);
    const response = await fetch(operation.url, {
      method: operation.method ?? "PUT",
      headers,
      body: chunk,
    });

    if (!response.ok) {
      const details = await response.text();
      throw new Error(`Screenshot chunk upload failed with ${response.status}: ${details}`);
    }
  }
}

async function commitReviewScreenshot(screenshotId, checksum) {
  const payload = {
    data: {
      type: "subscriptionAppStoreReviewScreenshots",
      id: screenshotId,
      attributes: {
        uploaded: true,
        sourceFileChecksum: checksum,
      },
    },
  };

  try {
    await api("PATCH", `/subscriptionAppStoreReviewScreenshots/${screenshotId}`, payload);
  } catch (error) {
    payload.data.attributes = { uploaded: true };
    await api("PATCH", `/subscriptionAppStoreReviewScreenshots/${screenshotId}`, payload);
  }
}

async function waitForScreenshot(screenshotId) {
  const deadline = Date.now() + 2 * 60 * 1000;

  while (Date.now() < deadline) {
    const response = await api("GET", `/subscriptionAppStoreReviewScreenshots/${screenshotId}`);
    const state = response.data?.attributes?.assetDeliveryState?.state;
    console.log(`Screenshot ${screenshotId}: ${state ?? "unknown"}`);

    if (state === "COMPLETE" || state === "UPLOAD_COMPLETE") {
      return;
    }

    if (state === "FAILED") {
      throw new Error(`Screenshot ${screenshotId} failed processing`);
    }

    await new Promise((resolve) => setTimeout(resolve, 5000));
  }

  throw new Error(`Timed out waiting for screenshot ${screenshotId}`);
}

async function ensureReviewScreenshot(config) {
  const subscription = config.resource;
  const existing = await currentReviewScreenshot(subscription.id);
  if (screenshotIsComplete(existing)) {
    console.log(`${config.label}: review screenshot already complete`);
    return;
  }

  await deleteReviewScreenshot(existing);

  const filePath = path.join(ASSET_ROOT, config.screenshot);
  const file = await fs.readFile(filePath);
  const checksum = crypto.createHash("md5").update(file).digest("hex");
  const screenshot = await createReviewScreenshot(subscription.id, path.basename(filePath), file.length);

  await uploadChunks(file, screenshot.attributes?.uploadOperations);
  await commitReviewScreenshot(screenshot.id, checksum);
  await waitForScreenshot(screenshot.id);
  console.log(`${config.label}: review screenshot uploaded`);
}

async function submitGroup(groupId) {
  await api("POST", "/subscriptionGroupSubmissions", {
    data: {
      type: "subscriptionGroupSubmissions",
      relationships: {
        subscriptionGroup: {
          data: { type: "subscriptionGroups", id: groupId },
        },
      },
    },
  });
}

async function submitSubscription(config) {
  const state = config.resource.attributes?.state;
  if (state === "WAITING_FOR_REVIEW" || state === "IN_REVIEW" || state === "APPROVED") {
    console.log(`${config.label}: already ${state}`);
    return false;
  }

  try {
    await api("POST", "/subscriptionSubmissions", {
      data: {
        type: "subscriptionSubmissions",
        relationships: {
          subscription: {
            data: { type: "subscriptions", id: config.resource.id },
          },
        },
      },
    });
  } catch (error) {
    if (error.message.includes("STATE_ERROR.FIRST_SUBSCRIPTION_MUST_BE_SUBMITTED_ON_VERSION")) {
      console.log(`${config.label}: will be reviewed with the app version`);
      return false;
    }

    throw error;
  }

  return true;
}

const { groups, subscriptions } = await findSubscriptions();

for (const config of subscriptions) {
  console.log(`${config.label}: ${config.resource.id} (${config.resource.attributes?.state})`);
  await ensureReviewScreenshot(config);
  config.resource = await getSubscription(config.resource.id);
  console.log(`${config.label}: ${config.resource.attributes?.state}`);
}

for (const group of groups) {
  await bestEffort(`Submit subscription group ${group.id}`, async () => {
    await submitGroup(group.id);
  });
}

for (const config of subscriptions) {
  const submitted = await submitSubscription(config);
  if (submitted) {
    console.log(`${config.label}: submitted for review`);
  }
}

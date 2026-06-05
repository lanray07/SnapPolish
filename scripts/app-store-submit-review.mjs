import crypto from "node:crypto";

const API_BASE = "https://api.appstoreconnect.apple.com/v1";
const APP_ID = required("ASC_APP_ID");
const VERSION_STRING = required("ASC_VERSION_STRING");
const BUILD_NUMBER = required("ASC_BUILD_NUMBER");
const KEY_ID = required("ASC_KEY_ID");
const ISSUER_ID = required("ASC_ISSUER_ID");

function required(name) {
  const value = process.env[name];
  if (!value) {
    throw new Error(`${name} is required`);
  }
  return value;
}

function privateKey() {
  const encoded = process.env.ASC_PRIVATE_KEY_BASE64;
  const plain = process.env.ASC_PRIVATE_KEY;
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

async function api(method, path, body, accepted = [200, 201, 204]) {
  const response = await fetch(`${API_BASE}${path}`, {
    method,
    headers: {
      Authorization: `Bearer ${jwt}`,
      "Content-Type": "application/json",
    },
    body: body ? JSON.stringify(body) : undefined,
  });

  const text = await response.text();
  let parsed = null;
  if (text) {
    try {
      parsed = JSON.parse(text);
    } catch {
      parsed = text;
    }
  }

  if (response.status === 401) {
    jwt = token();
  }

  if (!accepted.includes(response.status)) {
    const details = typeof parsed === "string" ? parsed : JSON.stringify(parsed, null, 2);
    throw new Error(`${method} ${path} failed with ${response.status}: ${details}`);
  }

  return parsed;
}

async function bestEffort(label, work) {
  try {
    await work();
    console.log(`${label}: ok`);
  } catch (error) {
    console.log(`${label}: skipped (${error.message})`);
  }
}

function encodeQuery(params) {
  return new URLSearchParams(params).toString();
}

async function getVersion() {
  const params = encodeQuery({
    "filter[platform]": "IOS",
    "filter[versionString]": VERSION_STRING,
    include: "build",
    limit: "10",
  });
  const response = await api("GET", `/apps/${APP_ID}/appStoreVersions?${params}`);
  const versions = response.data ?? [];
  const preferredStates = [
    "PREPARE_FOR_SUBMISSION",
    "READY_FOR_REVIEW",
    "WAITING_FOR_REVIEW",
    "IN_REVIEW",
  ];
  const version = versions.find((item) =>
    preferredStates.includes(item.attributes?.appStoreState)
  ) ?? versions[0];

  if (!version) {
    throw new Error(`No iOS App Store version ${VERSION_STRING} found for app ${APP_ID}`);
  }

  console.log(`Version ${VERSION_STRING}: ${version.id} (${version.attributes?.appStoreState})`);
  return version;
}

function buildMatchesVersion(build, includedById) {
  const preReleaseId = build.relationships?.preReleaseVersion?.data?.id;
  const preRelease = preReleaseId ? includedById.get(preReleaseId) : null;
  return !preRelease || preRelease.attributes?.version === VERSION_STRING;
}

async function listBuilds() {
  const params = encodeQuery({
    "filter[app]": APP_ID,
    "filter[version]": BUILD_NUMBER,
    include: "preReleaseVersion",
    sort: "-uploadedDate",
    limit: "10",
  });
  const response = await api("GET", `/builds?${params}`);
  const includedById = new Map((response.included ?? []).map((item) => [item.id, item]));
  return (response.data ?? []).filter((build) => buildMatchesVersion(build, includedById));
}

async function waitForBuild() {
  const deadline = Date.now() + 30 * 60 * 1000;
  while (Date.now() < deadline) {
    const builds = await listBuilds();
    const build = builds.find((item) => item.attributes?.version === BUILD_NUMBER) ?? builds[0];
    if (build) {
      const state = build.attributes?.processingState;
      console.log(`Build ${BUILD_NUMBER}: ${build.id} (${state})`);
      if (state === "VALID") {
        return build;
      }
      if (state === "FAILED" || state === "INVALID") {
        throw new Error(`Build ${BUILD_NUMBER} finished with processing state ${state}`);
      }
    } else {
      console.log(`Build ${BUILD_NUMBER}: not visible yet`);
    }
    await new Promise((resolve) => setTimeout(resolve, 30000));
  }

  throw new Error(`Timed out waiting for build ${BUILD_NUMBER} to become VALID`);
}

async function attachBuild(versionId, buildId) {
  await api("PATCH", `/appStoreVersions/${versionId}/relationships/build`, {
    data: { type: "builds", id: buildId },
  });
  console.log(`Attached build ${buildId} to version ${versionId}`);
}

async function existingReviewSubmission(versionId) {
  const params = encodeQuery({
    "filter[app]": APP_ID,
    "filter[platform]": "IOS",
    include: "items,appStoreVersionForReview",
    limit: "20",
  });
  const response = await api("GET", `/reviewSubmissions?${params}`);
  const activeStates = new Set(["READY_FOR_REVIEW", "WAITING_FOR_REVIEW", "IN_REVIEW"]);

  for (const submission of response.data ?? []) {
    if (!activeStates.has(submission.attributes?.state)) {
      continue;
    }

    const directVersion = submission.relationships?.appStoreVersionForReview?.data?.id;
    if (directVersion === versionId) {
      return submission;
    }
  }

  return null;
}

async function createSubmission() {
  const response = await api("POST", "/reviewSubmissions", {
    data: {
      type: "reviewSubmissions",
      attributes: { platform: "IOS" },
      relationships: {
        app: { data: { type: "apps", id: APP_ID } },
      },
    },
  });
  console.log(`Created review submission ${response.data.id}`);
  return response.data;
}

async function addVersionToSubmission(submissionId, versionId) {
  await api("POST", "/reviewSubmissionItems", {
    data: {
      type: "reviewSubmissionItems",
      relationships: {
        reviewSubmission: {
          data: { type: "reviewSubmissions", id: submissionId },
        },
        appStoreVersion: {
          data: { type: "appStoreVersions", id: versionId },
        },
      },
    },
  }, [200, 201]);
  console.log(`Added version ${versionId} to submission ${submissionId}`);
}

async function submitForReview(submissionId) {
  const response = await api("PATCH", `/reviewSubmissions/${submissionId}`, {
    data: {
      type: "reviewSubmissions",
      id: submissionId,
      attributes: { submitted: true },
    },
  });
  console.log(`Submission state: ${response.data.attributes?.state}`);
  return response.data;
}

const version = await getVersion();

await bestEffort("Set content rights", async () => {
  await api("PATCH", `/apps/${APP_ID}`, {
    data: {
      type: "apps",
      id: APP_ID,
      attributes: { contentRightsDeclaration: "DOES_NOT_USE_THIRD_PARTY_CONTENT" },
    },
  });
});

await bestEffort("Set IDFA usage", async () => {
  await api("PATCH", `/appStoreVersions/${version.id}`, {
    data: {
      type: "appStoreVersions",
      id: version.id,
      attributes: { usesIdfa: false },
    },
  });
});

const build = await waitForBuild();
await attachBuild(version.id, build.id);

let submission = await existingReviewSubmission(version.id);
if (submission) {
  console.log(`Using existing review submission ${submission.id} (${submission.attributes?.state})`);
} else {
  submission = await createSubmission();
  await addVersionToSubmission(submission.id, version.id);
}

if (submission.attributes?.state === "WAITING_FOR_REVIEW" || submission.attributes?.state === "IN_REVIEW") {
  console.log(`Already submitted: ${submission.attributes.state}`);
} else {
  await submitForReview(submission.id);
}

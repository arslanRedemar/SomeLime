// Creates the general board documents in Firestore (politics, humor, sports)
// Uses the Firestore REST API with Firebase CLI access token
// Run: node scripts/create-general-boards.mjs

import { readFileSync } from "fs";
import { homedir } from "os";
import { join } from "path";

const configPath = join(homedir(), ".config", "configstore", "firebase-tools.json");
const config = JSON.parse(readFileSync(configPath, "utf8"));
const accessToken = config.tokens.access_token;
const refreshToken = config.tokens.refresh_token;
const projectId = "somlime-47d80";

// Refresh the access token first
async function getAccessToken() {
  // Try the stored token first, if it fails, use refresh token
  const clientId = config.tokens.client_id || "563584335869-fgrhgmd47bqnekij5i8b5pr03ho849e6.apps.googleusercontent.com";
  const clientSecret = config.tokens.client_secret || "j9iVZfS8kkCEFUPaAeJV0sAi";

  const resp = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "refresh_token",
      refresh_token: refreshToken,
      client_id: clientId,
      client_secret: clientSecret,
    }),
  });
  const data = await resp.json();
  if (data.access_token) return data.access_token;
  throw new Error("Failed to refresh token: " + JSON.stringify(data));
}

async function createDocument(collectionId, documentId, fields) {
  const token = await getAccessToken();
  const url = `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents/${collectionId}?documentId=${documentId}`;

  const resp = await fetch(url, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${token}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ fields }),
  });

  if (!resp.ok) {
    const err = await resp.text();
    // If already exists, try PATCH instead
    if (resp.status === 409) {
      console.log(`  ${documentId} already exists, updating...`);
      const patchUrl = `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents/${collectionId}/${documentId}`;
      const patchResp = await fetch(patchUrl, {
        method: "PATCH",
        headers: {
          Authorization: `Bearer ${token}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ fields }),
      });
      if (!patchResp.ok) throw new Error(`PATCH failed: ${await patchResp.text()}`);
      return;
    }
    throw new Error(`Create failed (${resp.status}): ${err}`);
  }
}

function toFirestoreValue(val) {
  if (typeof val === "string") return { stringValue: val };
  if (typeof val === "number" && Number.isInteger(val)) return { integerValue: String(val) };
  if (typeof val === "number") return { doubleValue: val };
  if (typeof val === "boolean") return { booleanValue: val };
  if (Array.isArray(val)) return { arrayValue: { values: val.map(toFirestoreValue) } };
  if (typeof val === "object" && val !== null) {
    const fields = {};
    for (const [k, v] of Object.entries(val)) fields[k] = toFirestoreValue(v);
    return { mapValue: { fields } };
  }
  return { nullValue: null };
}

function toFirestoreFields(obj) {
  const fields = {};
  for (const [k, v] of Object.entries(obj)) fields[k] = toFirestoreValue(v);
  return fields;
}

const boards = [
  {
    id: "politics",
    data: {
      BoardDescription: "정치 관련 자유 토론 게시판입니다.",
      BoardLevel: 0,
      BoardOwnerId: "",
      BoardTapList: ["전체", "잡담", "질문", "정보"],
    },
  },
  {
    id: "humor",
    data: {
      BoardDescription: "유머와 재미있는 이야기를 공유하는 게시판입니다.",
      BoardLevel: 0,
      BoardOwnerId: "",
      BoardTapList: ["전체", "잡담", "질문", "정보"],
    },
  },
  {
    id: "sports",
    data: {
      BoardDescription: "스포츠 이야기를 나누는 게시판입니다.",
      BoardLevel: 0,
      BoardOwnerId: "",
      BoardTapList: ["전체", "잡담", "질문", "정보"],
    },
  },
];

for (const board of boards) {
  try {
    await createDocument("BoardInfo", board.id, toFirestoreFields(board.data));
    console.log(`Created BoardInfo/${board.id}`);
  } catch (e) {
    console.error(`Failed to create BoardInfo/${board.id}:`, e.message);
  }
}

console.log("Done!");

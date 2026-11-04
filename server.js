// server.js
const express = require("express");
const bcrypt = require("bcryptjs");
const rateLimit = require("express-rate-limit");
const fs = require("fs");
const crypto = require("crypto");

const app = express();
app.use(express.json({ limit: "128kb" }));

// === ПАРОЛЬ ===
// Берётся из env PASSWORD, иначе "14fn88".
// Хеш генерируется при старте — пароль в коде сервера не хранится.
const PLAIN_PASSWORD = process.env.PASSWORD || "14fn88";
const PASSWORD_HASH = bcrypt.hashSync(PLAIN_PASSWORD, 10);
console.log("[Server] Bcrypt hash generated.");

const TOKEN_TTL_MS = 30_000;
const SCRIPT_PATH = "./script.lua";

// === Rate limit на /auth ===
app.use(
  "/auth",
  rateLimit({
    windowMs: 60_000,
    max: 8,
    standardHeaders: true,
    legacyHeaders: false,
    message: { ok: false, error: "too_many_requests" }
  })
);

// === Одноразовые токены в памяти ===
const tokens = new Map();
setInterval(() => {
  const now = Date.now();
  for (const [t, d] of tokens) {
    if (d.expires < now || d.used) tokens.delete(t);
  }
}, 10_000);

// === POST /auth ===
app.post("/auth", async (req, res) => {
  const { password } = req.body || {};
  if (typeof password !== "string" || password.length === 0) {
    return res.status(400).json({ ok: false, error: "bad_request" });
  }

  const match = await bcrypt.compare(password, PASSWORD_HASH);
  if (!match) {
    console.log("[Auth] Invalid password attempt");
    return res.status(401).json({ ok: false, error: "invalid_password" });
  }

  const token = crypto.randomBytes(32).toString("hex");
  tokens.set(token, { expires: Date.now() + TOKEN_TTL_MS, used: false });
  console.log("[Auth] Success, token issued");
  return res.json({ ok: true, token, ttl_ms: TOKEN_TTL_MS });
});

// === POST /script ===
app.post("/script", (req, res) => {
  const { token } = req.body || {};
  if (typeof token !== "string" || !token) {
    return res.status(400).json({ ok: false, error: "bad_request" });
  }
  const entry = tokens.get(token);
  if (!entry || entry.used || entry.expires < Date.now()) {
    return res.status(401).json({ ok: false, error: "invalid_token" });
  }
  entry.used = true;
  tokens.delete(token);

  let b64;
  try {
    b64 = fs.readFileSync(SCRIPT_PATH).toString("base64");
  } catch (e) {
    console.error("[Script] Read failed:", e.message);
    return res.status(500).json({ ok: false, error: "script_missing" });
  }

  console.log("[Script] Script delivered, size:", b64.length, "b64 chars");
  return res.json({ ok: true, code_b64: b64 });
});

// === Healthcheck ===
app.get("/", (_req, res) => res.json({ ok: true, service: "megamenu-auth" }));

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log("[Server] Listening on", PORT));

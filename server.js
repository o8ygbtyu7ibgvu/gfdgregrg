const express = require("express");
const fs = require("fs");
const path = require("path");

const app = express();
app.use(express.json());

// ==========================================
// ПАРОЛЬ УБРАН. Скрипт отдаётся сразу.
// ==========================================

// Раздача script.lua в base64
app.get("/script", (req, res) => {
    try {
        const luaPath = path.join(__dirname, "script.lua");
        if (!fs.existsSync(luaPath)) {
            return res.status(404).json({ ok: false, error: "script.lua not found" });
        }
        const b64 = fs.readFileSync(luaPath).toString("base64");
        return res.json({ ok: true, code_b64: b64 });
    } catch (e) {
        console.error("[Server] Ошибка чтения:", e.message);
        return res.status(500).json({ ok: false, error: e.message });
    }
});

// Healthcheck (для проверки что сервер жив)
app.get("/", (req, res) => {
    res.json({ ok: true, status: "Сервер работает. Пароль не требуется." });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, "0.0.0.0", () => {
    console.log(`[Server] Слушаю порт ${PORT}`);
    console.log(`[Server] Endpoint скрипта: http://<твой_IP>:${PORT}/script`);
});

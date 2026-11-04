const express = require("express");
const fs = require("fs");
const crypto = require("crypto");

const app = express();
app.use(express.json());

// Пароль жестко зашит здесь
const PASSWORD = "14fn88"; 
const tokens = new Map();

app.post("/auth", (req, res) => {
    const { password } = req.body || {};
    
    // ВЫВОДИМ В ЛОГИ ТО, ЧТО ПРИШЛО
    console.log("СЕРВЕР ПОЛУЧИЛ ПАРОЛЬ:", password);

    if (password && password.trim() === PASSWORD) {
        console.log("УСПЕХ! Пароль совпал.");
        const token = crypto.randomBytes(16).toString("hex");
        tokens.set(token, Date.now() + 30000);
        return res.json({ ok: true, token });
    }
    
    console.log("ОШИБКА! Пароль не совпал.");
    return res.status(401).json({ ok: false });
});

app.post("/script", (req, res) => {
    const { token } = req.body || {};
    if (token && tokens.has(token)) {
        tokens.delete(token);
        try {
            const b64 = fs.readFileSync("./script.lua").toString("base64");
            return res.json({ ok: true, code_b64: b64 });
        } catch (e) {
            return res.status(500).json({ ok: false });
        }
    }
    return res.status(401).json({ ok: false });
});

// Если открыть сайт в браузере, покажет пароль (для проверки)
app.get("/", (req, res) => {
    res.json({ ok: true, password: PASSWORD, status: "Сервер работает!" });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, "0.0.0.0", () => {
    console.log(`[Server] Listening on port ${PORT}`);
});
